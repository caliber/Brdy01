// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statsHash() => r'b1fcfaf264f2439ee59f7409442056c76d1696f2';

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

/// See also [stats].
@ProviderFor(stats)
const statsProvider = StatsFamily();

/// See also [stats].
class StatsFamily extends Family<AsyncValue<StatsData?>> {
  /// See also [stats].
  const StatsFamily();

  /// See also [stats].
  StatsProvider call(
    int roundId,
  ) {
    return StatsProvider(
      roundId,
    );
  }

  @override
  StatsProvider getProviderOverride(
    covariant StatsProvider provider,
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
  String? get name => r'statsProvider';
}

/// See also [stats].
class StatsProvider extends AutoDisposeFutureProvider<StatsData?> {
  /// See also [stats].
  StatsProvider(
    int roundId,
  ) : this._internal(
          (ref) => stats(
            ref as StatsRef,
            roundId,
          ),
          from: statsProvider,
          name: r'statsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$statsHash,
          dependencies: StatsFamily._dependencies,
          allTransitiveDependencies: StatsFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  StatsProvider._internal(
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
    FutureOr<StatsData?> Function(StatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StatsProvider._internal(
        (ref) => create(ref as StatsRef),
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
  AutoDisposeFutureProviderElement<StatsData?> createElement() {
    return _StatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StatsProvider && other.roundId == roundId;
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
mixin StatsRef on AutoDisposeFutureProviderRef<StatsData?> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _StatsProviderElement extends AutoDisposeFutureProviderElement<StatsData?>
    with StatsRef {
  _StatsProviderElement(super.provider);

  @override
  int get roundId => (origin as StatsProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
