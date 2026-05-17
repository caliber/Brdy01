// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hole_score_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$holeScoreNotifierHash() => r'28f14e6436a12ba5dd457351e02890023ebd9f58';

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

abstract class _$HoleScoreNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Hole?> {
  late final int roundId;
  late final int holeIndex;

  FutureOr<Hole?> build(
    int roundId,
    int holeIndex,
  );
}

/// See also [HoleScoreNotifier].
@ProviderFor(HoleScoreNotifier)
const holeScoreNotifierProvider = HoleScoreNotifierFamily();

/// See also [HoleScoreNotifier].
class HoleScoreNotifierFamily extends Family<AsyncValue<Hole?>> {
  /// See also [HoleScoreNotifier].
  const HoleScoreNotifierFamily();

  /// See also [HoleScoreNotifier].
  HoleScoreNotifierProvider call(
    int roundId,
    int holeIndex,
  ) {
    return HoleScoreNotifierProvider(
      roundId,
      holeIndex,
    );
  }

  @override
  HoleScoreNotifierProvider getProviderOverride(
    covariant HoleScoreNotifierProvider provider,
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
  String? get name => r'holeScoreNotifierProvider';
}

/// See also [HoleScoreNotifier].
class HoleScoreNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<HoleScoreNotifier, Hole?> {
  /// See also [HoleScoreNotifier].
  HoleScoreNotifierProvider(
    int roundId,
    int holeIndex,
  ) : this._internal(
          () => HoleScoreNotifier()
            ..roundId = roundId
            ..holeIndex = holeIndex,
          from: holeScoreNotifierProvider,
          name: r'holeScoreNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$holeScoreNotifierHash,
          dependencies: HoleScoreNotifierFamily._dependencies,
          allTransitiveDependencies:
              HoleScoreNotifierFamily._allTransitiveDependencies,
          roundId: roundId,
          holeIndex: holeIndex,
        );

  HoleScoreNotifierProvider._internal(
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
  FutureOr<Hole?> runNotifierBuild(
    covariant HoleScoreNotifier notifier,
  ) {
    return notifier.build(
      roundId,
      holeIndex,
    );
  }

  @override
  Override overrideWith(HoleScoreNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: HoleScoreNotifierProvider._internal(
        () => create()
          ..roundId = roundId
          ..holeIndex = holeIndex,
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
  AutoDisposeAsyncNotifierProviderElement<HoleScoreNotifier, Hole?>
      createElement() {
    return _HoleScoreNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HoleScoreNotifierProvider &&
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
mixin HoleScoreNotifierRef on AutoDisposeAsyncNotifierProviderRef<Hole?> {
  /// The parameter `roundId` of this provider.
  int get roundId;

  /// The parameter `holeIndex` of this provider.
  int get holeIndex;
}

class _HoleScoreNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HoleScoreNotifier, Hole?>
    with HoleScoreNotifierRef {
  _HoleScoreNotifierProviderElement(super.provider);

  @override
  int get roundId => (origin as HoleScoreNotifierProvider).roundId;
  @override
  int get holeIndex => (origin as HoleScoreNotifierProvider).holeIndex;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
