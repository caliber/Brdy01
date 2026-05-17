// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highest_scored_hole_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$highestScoredHoleIndexHash() =>
    r'36d06ec52d494c679fb8b4940c40608772e4698f';

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

/// See also [highestScoredHoleIndex].
@ProviderFor(highestScoredHoleIndex)
const highestScoredHoleIndexProvider = HighestScoredHoleIndexFamily();

/// See also [highestScoredHoleIndex].
class HighestScoredHoleIndexFamily extends Family<int> {
  /// See also [highestScoredHoleIndex].
  const HighestScoredHoleIndexFamily();

  /// See also [highestScoredHoleIndex].
  HighestScoredHoleIndexProvider call(
    int roundId,
  ) {
    return HighestScoredHoleIndexProvider(
      roundId,
    );
  }

  @override
  HighestScoredHoleIndexProvider getProviderOverride(
    covariant HighestScoredHoleIndexProvider provider,
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
  String? get name => r'highestScoredHoleIndexProvider';
}

/// See also [highestScoredHoleIndex].
class HighestScoredHoleIndexProvider extends AutoDisposeProvider<int> {
  /// See also [highestScoredHoleIndex].
  HighestScoredHoleIndexProvider(
    int roundId,
  ) : this._internal(
          (ref) => highestScoredHoleIndex(
            ref as HighestScoredHoleIndexRef,
            roundId,
          ),
          from: highestScoredHoleIndexProvider,
          name: r'highestScoredHoleIndexProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$highestScoredHoleIndexHash,
          dependencies: HighestScoredHoleIndexFamily._dependencies,
          allTransitiveDependencies:
              HighestScoredHoleIndexFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  HighestScoredHoleIndexProvider._internal(
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
    int Function(HighestScoredHoleIndexRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HighestScoredHoleIndexProvider._internal(
        (ref) => create(ref as HighestScoredHoleIndexRef),
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
  AutoDisposeProviderElement<int> createElement() {
    return _HighestScoredHoleIndexProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HighestScoredHoleIndexProvider && other.roundId == roundId;
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
mixin HighestScoredHoleIndexRef on AutoDisposeProviderRef<int> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _HighestScoredHoleIndexProviderElement
    extends AutoDisposeProviderElement<int> with HighestScoredHoleIndexRef {
  _HighestScoredHoleIndexProviderElement(super.provider);

  @override
  int get roundId => (origin as HighestScoredHoleIndexProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
