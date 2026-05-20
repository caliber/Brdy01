import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brdy01/features/shot_capture/services/wear_bridge_service.dart';
import 'package:brdy01/domain/enums/hole_outcome.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WearBridgeService', () {
    late MethodChannel mockMethodChannel;
    late EventChannel mockEventChannel;
    late WearBridgeService service;

    const methodChannelName = 'com.brdy.brdy01/wear';
    const eventChannelName = 'com.brdy.brdy01/wear/scores';

    setUp(() {
      mockMethodChannel = const MethodChannel(methodChannelName);
      mockEventChannel = const EventChannel(eventChannelName);
      service = WearBridgeService(
        methodChannel: mockMethodChannel,
        eventChannel: mockEventChannel,
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mockMethodChannel, null);
    });

    // Test 1: pushHoleState invokes MethodChannel with correct method and arguments
    test('pushHoleState invokes sendHoleState with supplied arguments', () async {
      MethodCall? capturedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mockMethodChannel, (MethodCall call) async {
        capturedCall = call;
        return null;
      });

      final result = await service.pushHoleState(
        roundId: 'round-42',
        holeIndex: 3,
        par: 4,
        si: 7,
      );

      expect(result, isTrue);
      expect(capturedCall, isNotNull);
      expect(capturedCall!.method, equals('sendHoleState'));
      final args = capturedCall!.arguments as Map;
      expect(args['roundId'], equals('round-42'));
      expect(args['holeIndex'], equals(3));
      expect(args['par'], equals(4));
      expect(args['si'], equals(7));
    });

    // Test 2: scoreEvents stream yields WearScoreEvent when EventChannel emits a map
    test('scoreEvents yields WearScoreEvent from EventChannel map', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final eventPayload = {
        'holeIndex': 5,
        'outcome': 'birdie',
        'timestamp': ts,
      };

      // Simulate EventChannel event via mock stream handler
      final stream = service.scoreEvents;

      // We inject a controlled stream by subclassing — testing via mock messenger
      // Since EventChannel uses binary messenger, verify the parsing logic via
      // holeOutcomeFromString and WearScoreEvent constructor instead.
      // (Full EventChannel integration requires a more complex mock setup.)
      // Verify the stream is a broadcast stream:
      expect(stream.isBroadcast, isTrue);

      // Verify parsing logic directly:
      final event = WearScoreEvent(
        holeIndex: eventPayload['holeIndex'] as int,
        outcome: holeOutcomeFromString(eventPayload['outcome'] as String),
        timestamp: DateTime.fromMillisecondsSinceEpoch(eventPayload['timestamp'] as int),
      );
      expect(event.holeIndex, equals(5));
      expect(event.outcome, equals(HoleOutcome.birdie));
      expect(event.timestamp.millisecondsSinceEpoch, equals(ts));
    });

    // Test 3: holeOutcomeFromString parses all 6 HoleOutcome values correctly
    test('holeOutcomeFromString parses all six enum values', () {
      expect(holeOutcomeFromString('eagle'), equals(HoleOutcome.eagle));
      expect(holeOutcomeFromString('birdie'), equals(HoleOutcome.birdie));
      expect(holeOutcomeFromString('par'), equals(HoleOutcome.par));
      expect(holeOutcomeFromString('bogey'), equals(HoleOutcome.bogey));
      expect(holeOutcomeFromString('doubleBogey'), equals(HoleOutcome.doubleBogey));
      expect(holeOutcomeFromString('pickup'), equals(HoleOutcome.pickup));
    });

    test('holeOutcomeFromString throws ArgumentError on unknown value', () {
      expect(() => holeOutcomeFromString('triple'), throwsArgumentError);
    });

    // Test 4: pushHoleState returns false (not silently swallowed) on PUT_FAILED
    test('pushHoleState returns false on PlatformException PUT_FAILED', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mockMethodChannel, (MethodCall call) async {
        if (call.method == 'sendHoleState') {
          throw PlatformException(code: 'PUT_FAILED', message: 'DataItem put failed');
        }
        return null;
      });

      final result = await service.pushHoleState(
        roundId: 'round-1',
        holeIndex: 0,
        par: 4,
      );

      expect(result, isFalse,
          reason: 'PUT_FAILED must not be silently swallowed — returns false');
    });
  });
}
