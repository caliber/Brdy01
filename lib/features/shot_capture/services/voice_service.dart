import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../domain/enums/hole_outcome.dart';
import '../providers/active_hole_index_provider.dart';
import '../providers/hole_score_notifier.dart';
import 'voice_command_parser.dart';

class VoiceService {
  final WidgetRef _ref;
  final int roundId;

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _available = false;
  bool _listening = false;
  bool _handled = false;           // prevents double-fire between onResult + onStatus
  bool _disposed = false;          // guards all _ref.read() calls after widget disposal
  void Function(bool)? _onListeningChanged;
  void Function(String)? _onHeard;
  void Function(HoleOutcome outcome, int holeIndex)? onOutcomeRecorded;
  String _lastRecognised = '';

  bool get isAvailable => _available;
  bool get isListening => _listening;

  VoiceService({required this.roundId, required WidgetRef ref}) : _ref = ref;

  Future<bool> initialize() async {
    _available = await _stt.initialize(
      onError: (e) {
        debugPrint('🎙️ STT error: $e');
        // error_no_match means it heard something but couldn't identify it
        // Don't kill the session — just reset so user can try again
        if (e.errorMsg == 'error_no_match') {
          _onHeard?.call('NOT RECOGNISED — TRY AGAIN');
          Future.delayed(const Duration(seconds: 2), () {
            _onHeard?.call('');
          });
        }
        _setListening(false);
        _handled = false;
      },
      onStatus: (status) {
        debugPrint('🎙️ STT status: $status | last: "$_lastRecognised"');
        if ((status == 'done' || status == 'notListening') && !_handled) {
          // Fallback — fires if finalResult never came through
          if (_lastRecognised.isNotEmpty) {
            _handled = true;
            _handleResult(_lastRecognised);
          }
          _lastRecognised = '';
          _setListening(false);
        }
      },
    );
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    return _available;
  }

  void _setListening(bool value) {
    if (_disposed) return;
    _listening = value;
    _onListeningChanged?.call(value);
  }

  Future<void> startListening({
    required void Function(bool) onListeningChanged,
    void Function(String)? onPartialResult,
  }) async {
    if (!_available || _listening) return;
    _onListeningChanged = onListeningChanged;
    _onHeard = onPartialResult;
    _lastRecognised = '';
    _handled = false;
    _setListening(true);

    await _stt.listen(
      onResult: (result) {
        debugPrint('🎙️ STT result: "${result.recognizedWords}" final=${result.finalResult}');
        _lastRecognised = result.recognizedWords;
        // Show partial text live as user speaks
        onPartialResult?.call(_lastRecognised);
        // Primary trigger — fire as soon as STT confirms final result
        if (result.finalResult && _lastRecognised.isNotEmpty && !_handled) {
          _handled = true;
          onPartialResult?.call('');
          _handleResult(_lastRecognised);
          _lastRecognised = '';
          _setListening(false);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'en_AU', // Closest to NZ accent, better match than en_US
      listenOptions: SpeechListenOptions(cancelOnError: false), // Don't cancel on no_match
    );
  }

  Future<void> stopListening({
    required void Function(bool) onListeningChanged,
  }) async {
    if (!_listening) return;
    _onListeningChanged = onListeningChanged;
    await _stt.stop();
    _setListening(false);
  }

  void _handleResult(String text) {
    if (_disposed || text.isEmpty) return;
    debugPrint('🎙️ Handling: "$text"');
    HapticFeedback.mediumImpact();
    final command = VoiceCommandParser.parse(text);
    final holeIndex = _ref.read(activeHoleIndexProvider);

    switch (command) {
      case ShotsCommand(:final shots):
        // Derive outcome from shots taken vs par
        final currentHole =
            _ref.read(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
        final par = currentHole?.par ?? 4;
        final outcome = VoiceCommandParser.outcomeFromShots(shots, par);
        if (outcome != null) _recordOutcome(outcome, holeIndex);
      case OutcomeCommand(:final outcome):
        _recordOutcome(outcome, holeIndex);
      case NextHoleCommand():
        if (holeIndex < 17) {
          _ref.read(activeHoleIndexProvider.notifier).set(holeIndex + 1);
          _speak('Hole ${holeIndex + 2}');
        }
      case PrevHoleCommand():
        if (holeIndex > 0) {
          _ref.read(activeHoleIndexProvider.notifier).set(holeIndex - 1);
          _speak('Hole $holeIndex');
        }
      case UndoCommand():
        _ref
            .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
            .undoOutcome();
        _speak('Undone');
      case SetPuttsCommand(:final count):
        _ref
            .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
            .setPutts(count, par: 4);
        _speak('$count putts');
      case FairwayHitCommand():
        _ref
            .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
            .setFairwayHit(true, par: 4);
        _speak('Fairway hit');
      case GirCommand():
        _ref
            .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
            .setGir(true, par: 4);
        _speak('Green in regulation');
      case UnrecognisedCommand():
        _speak('Try saying took four or four shots');
    }
  }

  void _recordOutcome(HoleOutcome outcome, int holeIndex) {
    final label = switch (outcome) {
      HoleOutcome.eagle => 'Eagle',
      HoleOutcome.birdie => 'Birdie',
      HoleOutcome.par => 'Par',
      HoleOutcome.bogey => 'Bogey',
      HoleOutcome.doubleBogey => 'Double bogey',
      HoleOutcome.pickup => 'Pickup',
    };
    final currentHole =
        _ref.read(holeScoreNotifierProvider(roundId, holeIndex)).valueOrNull;
    final par = currentHole?.par ?? 4;
    _ref
        .read(holeScoreNotifierProvider(roundId, holeIndex).notifier)
        .recordOutcome(outcome: outcome, par: par);
    _speak('$label, hole ${holeIndex + 1}');
    onOutcomeRecorded?.call(outcome, holeIndex);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> dispose() async {
    _disposed = true;
    _onListeningChanged = null;
    _onHeard = null;
    onOutcomeRecorded = null;
    await _stt.stop();
    await _tts.stop();
  }
}
