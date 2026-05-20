package com.brdy.brdy01

import android.content.Intent
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.WearableListenerService

/**
 * Handles /brdy/score/ DataItems when the Flutter app is backgrounded (phone in bag).
 *
 * Without this service, WEAR-02 only works when the phone app is foregrounded.
 * When a score DataItem arrives, this service broadcasts it locally so that
 * WearDataBridgePlugin can relay it to the active Flutter EventChannel sink once
 * the app is brought back to the foreground.
 *
 * Sequence: score arrives → WearDataBridgeService broadcasts → WearDataBridgePlugin
 * relays to Flutter EventChannel → Dart scoreEvents stream emits → Drift write.
 */
class WearDataBridgeService : WearableListenerService() {
    override fun onDataChanged(events: DataEventBuffer) {
        for (event in events) {
            if (event.type == DataEvent.TYPE_CHANGED &&
                event.dataItem.uri.path?.startsWith("/brdy/score/") == true
            ) {
                val map = DataMapItem.fromDataItem(event.dataItem).dataMap
                val holeIndex = map.getInt("holeIndex")
                val outcome = map.getString("outcome") ?: continue
                val timestamp = map.getLong("timestamp")

                // Broadcast locally so any active WearDataBridgePlugin picks it up
                val intent = Intent("com.brdy.brdy01.WEAR_SCORE").apply {
                    putExtra("holeIndex", holeIndex)
                    putExtra("outcome", outcome)
                    putExtra("timestamp", timestamp)
                }
                LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
            }
        }
    }
}
