// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hole_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$holeListHash() => r'd1120e0c5d6d411df8fb4b0009b6789b988bf7d4';

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

/// See also [holeList].
@ProviderFor(holeList)
const holeListProvider = HoleListFamily();

/// See also [holeList].
class HoleListFamily extends Family<AsyncValue<List<Hole>>> {
  /// See also [holeList].
  const HoleListFamily();

  /// See also [holeList].
  HoleListProvider call(
    int roundId,
  ) {
    return HoleListProvider(
      roundId,
    );
  }

  @override
  HoleListProvider getProviderOverride(
    covariant HoleListProvider provider,
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
  String? get name => r'holeListProvider';
}

/// See also [holeList].
class HoleListProvider extends AutoDisposeStreamProvider<List<Hole>> {
  /// See also [holeList].
  HoleListProvider(
    int roundId,
  ) : this._internal(
          (ref) => holeList(
            ref as HoleListRef,
            roundId,
          ),
          from: holeListProvider,
          name: r'holeListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$holeListHash,
          dependencies: HoleListFamily._dependencies,
          allTransitiveDependencies: HoleListFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  HoleListProvider._internal(
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
    Stream<List<Hole>> Function(HoleListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HoleListProvider._internal(
        (ref) => create(ref as HoleListRef),
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
  AutoDisposeStreamProviderElement<List<Hole>> createElement() {
    return _HoleListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HoleListProvider && other.roundId == roundId;
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
mixin HoleListRef on AutoDisposeStreamProviderRef<List<Hole>> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _HoleListProviderElement
    extends AutoDisposeStreamProviderElement<List<Hole>> with HoleListRef {
  _HoleListProviderElement(super.provider);

  @override
  int get roundId => (origin as HoleListProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
