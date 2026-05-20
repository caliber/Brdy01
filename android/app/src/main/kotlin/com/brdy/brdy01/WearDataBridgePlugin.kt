package com.brdy.brdy01

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.Looper
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.android.gms.wearable.DataClient
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.PutDataMapRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class WearDataBridgePlugin : FlutterPlugin, MethodCallHandler,
    EventChannel.StreamHandler, DataClient.OnDataChangedListener {

    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var scoreSink: EventChannel.EventSink? = null
    private var context: Context? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    // Receives LOCAL_BROADCAST intents from WearDataBridgeService (background scores)
    private val wearScoreReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            if (intent?.action != "com.brdy.brdy01.WEAR_SCORE") return
            val holeIndex = intent.getIntExtra("holeIndex", -1)
            val outcome = intent.getStringExtra("outcome") ?: return
            val timestamp = intent.getLongExtra("timestamp", 0L)
            mainHandler.post {
                scoreSink?.success(
                    mapOf(
                        "holeIndex" to holeIndex,
                        "outcome" to outcome,
                        "timestamp" to timestamp
                    )
                )
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "com.brdy.brdy01/wear")
        methodChannel!!.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "com.brdy.brdy01/wear/scores")
        eventChannel!!.setStreamHandler(this)

        Wearable.getDataClient(binding.applicationContext).addListener(this)

        // Register local broadcast receiver for scores from WearDataBridgeService
        LocalBroadcastManager.getInstance(binding.applicationContext)
            .registerReceiver(wearScoreReceiver, IntentFilter("com.brdy.brdy01.WEAR_SCORE"))
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context ?: return result.error("NO_CONTEXT", "Plugin not attached", null)

        when (call.method) {
            "sendHoleState" -> {
                val args = call.arguments as? Map<*, *>
                    ?: return result.error("BAD_ARGS", "Expected Map arguments", null)
                val roundId = args["roundId"] as? String
                    ?: return result.error("BAD_ARGS", "roundId missing", null)
                val holeIndex = (args["holeIndex"] as? Number)?.toInt()
                    ?: return result.error("BAD_ARGS", "holeIndex missing", null)
                val par = (args["par"] as? Number)?.toInt()
                    ?: return result.error("BAD_ARGS", "par missing", null)
                val si = (args["si"] as? Number)?.toInt()

                val request = PutDataMapRequest.create("/brdy/hole").apply {
                    dataMap.putString("roundId", roundId)
                    dataMap.putInt("holeIndex", holeIndex)
                    dataMap.putInt("par", par)
                    si?.let { dataMap.putInt("si", it) }
                    dataMap.putLong("ts", System.currentTimeMillis())
                }.asPutDataRequest().setUrgent()

                Wearable.getDataClient(ctx).putDataItem(request)
                    .addOnSuccessListener { result.success(null) }
                    .addOnFailureListener { e -> result.error("PUT_FAILED", e.message, null) }
            }

            "sendScoreAck" -> {
                val args = call.arguments as? Map<*, *>
                    ?: return result.error("BAD_ARGS", "Expected Map arguments", null)
                val holeIndex = (args["holeIndex"] as? Number)?.toInt()
                    ?: return result.error("BAD_ARGS", "holeIndex missing", null)
                val outcome = args["outcome"] as? String
                    ?: return result.error("BAD_ARGS", "outcome missing", null)

                val request = PutDataMapRequest.create("/brdy/ack/$holeIndex").apply {
                    dataMap.putString("outcome", outcome)
                    dataMap.putLong("ts", System.currentTimeMillis())
                }.asPutDataRequest().setUrgent()

                Wearable.getDataClient(ctx).putDataItem(request)
                    .addOnSuccessListener { result.success(null) }
                    .addOnFailureListener { e -> result.error("PUT_FAILED", e.message, null) }
            }

            "connectionStatus" -> {
                Wearable.getNodeClient(ctx).connectedNodes
                    .addOnSuccessListener { nodes -> result.success(nodes.isNotEmpty()) }
                    .addOnFailureListener { result.success(false) }
            }

            else -> result.notImplemented()
        }
    }

    // ── EventChannel.StreamHandler ────────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        scoreSink = events
    }

    override fun onCancel(arguments: Any?) {
        scoreSink = null
    }

    // ── DataClient.OnDataChangedListener (foreground reception) ───────────────

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        // Collect data before the buffer is released
        data class ScoreData(val holeIndex: Int, val outcome: String, val ts: Long)
        val scores = mutableListOf<ScoreData>()

        for (event in dataEvents) {
            if (event.type == DataEvent.TYPE_CHANGED &&
                event.dataItem.uri.path?.startsWith("/brdy/score/") == true
            ) {
                val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap
                scores.add(
                    ScoreData(
                        holeIndex = dataMap.getInt("holeIndex"),
                        outcome = dataMap.getString("outcome") ?: continue,
                        ts = dataMap.getLong("timestamp")
                    )
                )
            }
        }

        // Post to main thread after buffer is released
        for (score in scores) {
            mainHandler.post {
                scoreSink?.success(
                    mapOf(
                        "holeIndex" to score.holeIndex,
                        "outcome" to score.outcome,
                        "timestamp" to score.ts
                    )
                )
            }
        }
    }

    // ── FlutterPlugin ─────────────────────────────────────────────────────────

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Wearable.getDataClient(binding.applicationContext).removeListener(this)
        LocalBroadcastManager.getInstance(binding.applicationContext)
            .unregisterReceiver(wearScoreReceiver)
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        scoreSink = null
        context = null
    }
}
