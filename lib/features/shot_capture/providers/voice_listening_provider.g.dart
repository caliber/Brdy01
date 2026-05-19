// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_listening_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceListeningHash() => r'2987e5f7d918773ec72821aaa3d5e72de67857c0';

/// True when the mic is actively listening for a command.
///
/// Copied from [VoiceListening].
@ProviderFor(VoiceListening)
final voiceListeningProvider =
    AutoDisposeNotifierProvider<VoiceListening, bool>.internal(
  VoiceListening.new,
  name: r'voiceListeningProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voiceListeningHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VoiceListening = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
