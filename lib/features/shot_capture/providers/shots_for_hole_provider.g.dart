// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shots_for_hole_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shotsForHoleHash() => r'cc5265cfeb847ea754e0a636a9074f1c7117e036';

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

/// Streams shots for the given [holeIndex] within [roundId].
///
/// Looks up the hole row by (roundId, holeNumber). If the hole row does not
/// yet exist (unscored hole), yields an empty list rather than crashing or
/// waiting indefinitely.
///
/// Uses @riverpod (auto-dispose) — screen-level lifetime only.
///
/// Copied from [shotsForHole].
@ProviderFor(shotsForHole)
const shotsForHoleProvider = ShotsForHoleFamily();

/// Streams shots for the given [holeIndex] within [roundId].
///
/// Looks up the hole row by (roundId, holeNumber). If the hole row does not
/// yet exist (unscored hole), yields an empty list rather than crashing or
/// waiting indefinitely.
///
/// Uses @riverpod (auto-dispose) — screen-level lifetime only.
///
/// Copied from [shotsForHole].
class ShotsForHoleFamily extends Family<AsyncValue<List<Shot>>> {
  /// Streams shots for the given [holeIndex] within [roundId].
  ///
  /// Looks up the hole row by (roundId, holeNumber). If the hole row does not
  /// yet exist (unscored hole), yields an empty list rather than crashing or
  /// waiting indefinitely.
  ///
  /// Uses @riverpod (auto-dispose) — screen-level lifetime only.
  ///
  /// Copied from [shotsForHole].
  const ShotsForHoleFamily();

  /// Streams shots for the given [holeIndex] within [roundId].
  ///
  /// Looks up the hole row by (roundId, holeNumber). If the hole row does not
  /// yet exist (unscored hole), yields an empty list rather than crashing or
  /// waiting indefinitely.
  ///
  /// Uses @riverpod (auto-dispose) — screen-level lifetime only.
  ///
  /// Copied from [shotsForHole].
  ShotsForHoleProvider call(
    int roundId,
    int holeIndex,
  ) {
    return ShotsForHoleProvider(
      roundId,
      holeIndex,
    );
  }

  @override
  ShotsForHoleProvider getProviderOverride(
    covariant ShotsForHoleProvider provider,
  ) {
    return call(
      provider.roundId,
      provider.holeIndex,
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
  String? get name => r'shotsForHoleProvider';
}

/// Streams shots for the given [holeIndex] within [roundId].
///
/// Looks up the hole row by (roundId, holeNumber). If the hole row does not
/// yet exist (unscored hole), yields an empty list rather than crashing or
/// waiting indefinitely.
///
/// Uses @riverpod (auto-dispose) — screen-level lifetime only.
///
/// Copied from [shotsForHole].
class ShotsForHoleProvider extends AutoDisposeStreamProvider<List<Shot>> {
  /// Streams shots for the given [holeIndex] within [roundId].
  ///
  /// Looks up the hole row by (roundId, holeNumber). If the hole row does not
  /// yet exist (unscored hole), yields an empty list rather than crashing or
  /// waiting indefinitely.
  ///
  /// Uses @riverpod (auto-dispose) — screen-level lifetime only.
  ///
  /// Copied from [shotsForHole].
  ShotsForHoleProvider(
    int roundId,
    int holeIndex,
  ) : this._internal(
          (ref) => shotsForHole(
            ref as ShotsForHoleRef,
            roundId,
            holeIndex,
          ),
          from: shotsForHoleProvider,
          name: r'shotsForHoleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shotsForHoleHash,
          dependencies: ShotsForHoleFamily._dependencies,
          allTransitiveDependencies:
              ShotsForHoleFamily._allTransitiveDependencies,
          roundId: roundId,
          holeIndex: holeIndex,
        );

  ShotsForHoleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roundId,
    required this.holeIndex,
  }) : super.internal();

  final int roundId;
  final int holeIndex;

  @override
  Override overrideWith(
    Stream<List<Shot>> Function(ShotsForHoleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShotsForHoleProvider._internal(
        (ref) => create(ref as ShotsForHoleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roundId: roundId,
        holeIndex: holeIndex,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Shot>> createElement() {
    return _ShotsForHoleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShotsForHoleProvider &&
        other.roundId == roundId &&
        other.holeIndex == holeIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roundId.hashCode);
    hash = _SystemHash.combine(hash, holeIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShotsForHoleRef on AutoDisposeStreamProviderRef<List<Shot>> {
  /// The parameter `roundId` of this provider.
  int get roundId;

  /// The parameter `holeIndex` of this provider.
  int get holeIndex;
}

class _ShotsForHoleProviderElement
    extends AutoDisposeStreamProviderElement<List<Shot>> with ShotsForHoleRef {
  _ShotsForHoleProviderElement(super.provider);

  @override
  int get roundId => (origin as ShotsForHoleProvider).roundId;
  @override
  int get holeIndex => (origin as ShotsForHoleProvider).holeIndex;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
