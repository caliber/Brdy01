// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_scored_outcome_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lastScoredOutcomeHash() => r'c45dcc43bfd7dd1ebb32af6d95d17af7c61a94f3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$LastScoredOutcome
    extends BuildlessAutoDisposeNotifier<HoleOutcome?> {
  late final int roundId;

  HoleOutcome? build(
    int roundId,
  );
}

/// See also [LastScoredOutcome].
@ProviderFor(LastScoredOutcome)
const lastScoredOutcomeProvider = LastScoredOutcomeFamily();

/// See also [LastScoredOutcome].
class LastScoredOutcomeFamily extends Family<HoleOutcome?> {
  /// See also [LastScoredOutcome].
  const LastScoredOutcomeFamily();

  /// See also [LastScoredOutcome].
  LastScoredOutcomeProvider call(
    int roundId,
  ) {
    return LastScoredOutcomeProvider(
      roundId,
    );
  }

  @override
  LastScoredOutcomeProvider getProviderOverride(
    covariant LastScoredOutcomeProvider provider,
  ) {
    return call(
      provider.roundId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lastScoredOutcomeProvider';
}

/// See also [LastScoredOutcome].
class LastScoredOutcomeProvider
    extends AutoDisposeNotifierProviderImpl<LastScoredOutcome, HoleOutcome?> {
  /// See also [LastScoredOutcome].
  LastScoredOutcomeProvider(
    int roundId,
  ) : this._internal(
          () => LastScoredOutcome()..roundId = roundId,
          from: lastScoredOutcomeProvider,
          name: r'lastScoredOutcomeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lastScoredOutcomeHash,
          dependencies: LastScoredOutcomeFamily._dependencies,
          allTransitiveDependencies:
              LastScoredOutcomeFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  LastScoredOutcomeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roundId,
  }) : super.internal();

  final int roundId;

  @override
  HoleOutcome? runNotifierBuild(
    covariant LastScoredOutcome notifier,
  ) {
    return notifier.build(
      roundId,
    );
  }

  @override
  Override overrideWith(LastScoredOutcome Function() create) {
    return ProviderOverride(
      origin: this,
      override: LastScoredOutcomeProvider._internal(
        () => create()..roundId = roundId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roundId: roundId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<LastScoredOutcome, HoleOutcome?>
      createElement() {
    return _LastScoredOutcomeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LastScoredOutcomeProvider && other.roundId == roundId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roundId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LastScoredOutcomeRef on AutoDisposeNotifierProviderRef<HoleOutcome?> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _LastScoredOutcomeProviderElement
    extends AutoDisposeNotifierProviderElement<LastScoredOutcome, HoleOutcome?>
    with LastScoredOutcomeRef {
  _LastScoredOutcomeProviderElement(super.provider);

  @override
  int get roundId => (origin as LastScoredOutcomeProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
