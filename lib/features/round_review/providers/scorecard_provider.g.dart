// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scorecard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scorecardHash() => r'40006794a95a25de84a2087d45c6c24a746fef5d';

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

/// See also [scorecard].
@ProviderFor(scorecard)
const scorecardProvider = ScorecardFamily();

/// See also [scorecard].
class ScorecardFamily extends Family<ScorecardData?> {
  /// See also [scorecard].
  const ScorecardFamily();

  /// See also [scorecard].
  ScorecardProvider call(
    int roundId,
  ) {
    return ScorecardProvider(
      roundId,
    );
  }

  @override
  ScorecardProvider getProviderOverride(
    covariant ScorecardProvider provider,
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
  String? get name => r'scorecardProvider';
}

/// See also [scorecard].
class ScorecardProvider extends AutoDisposeProvider<ScorecardData?> {
  /// See also [scorecard].
  ScorecardProvider(
    int roundId,
  ) : this._internal(
          (ref) => scorecard(
            ref as ScorecardRef,
            roundId,
          ),
          from: scorecardProvider,
          name: r'scorecardProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$scorecardHash,
          dependencies: ScorecardFamily._dependencies,
          allTransitiveDependencies: ScorecardFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  ScorecardProvider._internal(
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
    ScorecardData? Function(ScorecardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ScorecardProvider._internal(
        (ref) => create(ref as ScorecardRef),
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
  AutoDisposeProviderElement<ScorecardData?> createElement() {
    return _ScorecardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScorecardProvider && other.roundId == roundId;
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
mixin ScorecardRef on AutoDisposeProviderRef<ScorecardData?> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _ScorecardProviderElement
    extends AutoDisposeProviderElement<ScorecardData?> with ScorecardRef {
  _ScorecardProviderElement(super.provider);

  @override
  int get roundId => (origin as ScorecardProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
