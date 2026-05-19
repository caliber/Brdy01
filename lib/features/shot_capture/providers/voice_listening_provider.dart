import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_listening_provider.g.dart';

/// True when the mic is actively listening for a command.
@riverpod
class VoiceListening extends _$VoiceListening {
  @override
  bool build() => false;

  void set(bool listening) => state = listening;
}
