import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wear_score_event.dart';

export 'wear_score_event.dart';

/// Riverpod provider for [WearBridgeService].
/// Use this provider to obtain the singleton bridge in widget and provider trees.
final wearBridgeServiceProvider = Provider<WearBridgeService>(
  (ref) => WearBridgeService(),
);

/// Dart wrapper around the phone-side `WearDataBridgePlugin` Kotlin plugin.
///
/// Exposes:
/// - [pushHoleState] — pushes current hole context to the watch via DataLayer.
/// - [isPhoneConnectedToWatch] — returns true if any watch node is connected.
/// - [scoreEvents] — broadcast stream of [WearScoreEvent] from the watch.
///
/// Channel contract:
/// - MethodChannel: `com.brdy.brdy01/wear`
/// - EventChannel:  `com.brdy.brdy01/wear/scores`
class WearBridgeService {
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  /// Lazily initialised broadcast stream — created on first access.
  Stream<WearScoreEvent>? _scoreStream;

  WearBridgeService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel =
            methodChannel ?? const MethodChannel('com.brdy.brdy01/wear'),
        _eventChannel =
            eventChannel ?? const EventChannel('com.brdy.brdy01/wear/scores');

  /// Pushes hole context to the watch via `sendHoleState`.
  ///
  /// Returns `true` on success, `false` if the DataItem put fails (T-04-04).
  /// Failures are logged via [developer.log] — they are not thrown.
  Future<bool> pushHoleState({
    required String roundId,
    required int holeIndex,
    required int par,
    int? si,
  }) async {
    try {
      await _methodChannel.invokeMethod<void>('sendHoleState', {
        'roundId': roundId,
        'holeIndex': holeIndex,
        'par': par,
        if (si != null) 'si': si,
      });
      return true;
    } on MissingPluginException {
      // Wear OS channel only exists on Android — silently no-op on iOS.
      return false;
    } on PlatformException catch (e) {
      developer.log(
        'WearBridgeService.pushHoleState failed: ${e.code} — ${e.message}',
        name: 'WearBridgeService',
        error: e,
      );
      return false;
    }
  }

  /// Returns `true` if any Wear OS node is currently connected to the phone.
  Future<bool> isPhoneConnectedToWatch() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('connectionStatus', {});
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      developer.log(
        'WearBridgeService.isPhoneConnectedToWatch failed: ${e.code}',
        name: 'WearBridgeService',
        error: e,
      );
      return false;
    }
  }

  /// Broadcast stream of [WearScoreEvent] emitted whenever the watch records a score.
  ///
  /// Malformed events are logged and skipped — they do NOT terminate the stream.
  /// Note: wiring `scoreEvents` into the UI is deferred to Plan 04-04.
  Stream<WearScoreEvent> get scoreEvents {
    _scoreStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as Map)
        .map((map) {
          try {
            return WearScoreEvent(
              holeIndex: (map['holeIndex'] as num).toInt(),
              outcome: holeOutcomeFromString(map['outcome'] as String),
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                (map['timestamp'] as num).toInt(),
              ),
            );
          } catch (e) {
            developer.log(
              'WearBridgeService.scoreEvents: malformed event — $map',
              name: 'WearBridgeService',
              error: e,
            );
            return null;
          }
        })
        .where((event) => event != null)
        .cast<WearScoreEvent>();
    return _scoreStream!;
  }
}
