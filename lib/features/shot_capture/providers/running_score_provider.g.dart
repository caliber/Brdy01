// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$runningScoreHash() => r'8f0021442478efa8e9efaef9c08930e5d21a71b0';

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

/// See also [runningScore].
@ProviderFor(runningScore)
const runningScoreProvider = RunningScoreFamily();

/// See also [runningScore].
class RunningScoreFamily extends Family<int?> {
  /// See also [runningScore].
  const RunningScoreFamily();

  /// See also [runningScore].
  RunningScoreProvider call(
    int roundId,
  ) {
    return RunningScoreProvider(
      roundId,
    );
  }

  @override
  RunningScoreProvider getProviderOverride(
    covariant RunningScoreProvider provider,
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
  String? get name => r'runningScoreProvider';
}

/// See also [runningScore].
class RunningScoreProvider extends AutoDisposeProvider<int?> {
  /// See also [runningScore].
  RunningScoreProvider(
    int roundId,
  ) : this._internal(
          (ref) => runningScore(
            ref as RunningScoreRef,
            roundId,
          ),
          from: runningScoreProvider,
          name: r'runningScoreProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$runningScoreHash,
          dependencies: RunningScoreFamily._dependencies,
          allTransitiveDependencies:
              RunningScoreFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  RunningScoreProvider._internal(
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
  Override overrideWith(
    int? Function(RunningScoreRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RunningScoreProvider._internal(
        (ref) => create(ref as RunningScoreRef),
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
  AutoDisposeProviderElement<int?> createElement() {
    return _RunningScoreProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RunningScoreProvider && other.roundId == roundId;
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
mixin RunningScoreRef on AutoDisposeProviderRef<int?> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _RunningScoreProviderElement extends AutoDisposeProviderElement<int?>
    with RunningScoreRef {
  _RunningScoreProviderElement(super.provider);

  @override
  int get roundId => (origin as RunningScoreProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
