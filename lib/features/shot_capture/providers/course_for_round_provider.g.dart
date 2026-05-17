// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_for_round_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$courseForRoundHash() => r'd81b0e2b8d93b9b23d891d19a7fcff71bc352aaf';

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

/// See also [courseForRound].
@ProviderFor(courseForRound)
const courseForRoundProvider = CourseForRoundFamily();

/// See also [courseForRound].
class CourseForRoundFamily extends Family<AsyncValue<CourseModel?>> {
  /// See also [courseForRound].
  const CourseForRoundFamily();

  /// See also [courseForRound].
  CourseForRoundProvider call(
    int roundId,
  ) {
    return CourseForRoundProvider(
      roundId,
    );
  }

  @override
  CourseForRoundProvider getProviderOverride(
    covariant CourseForRoundProvider provider,
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
  String? get name => r'courseForRoundProvider';
}

/// See also [courseForRound].
class CourseForRoundProvider extends AutoDisposeFutureProvider<CourseModel?> {
  /// See also [courseForRound].
  CourseForRoundProvider(
    int roundId,
  ) : this._internal(
          (ref) => courseForRound(
            ref as CourseForRoundRef,
            roundId,
          ),
          from: courseForRoundProvider,
          name: r'courseForRoundProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$courseForRoundHash,
          dependencies: CourseForRoundFamily._dependencies,
          allTransitiveDependencies:
              CourseForRoundFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  CourseForRoundProvider._internal(
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
    FutureOr<CourseModel?> Function(CourseForRoundRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CourseForRoundProvider._internal(
        (ref) => create(ref as CourseForRoundRef),
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
  AutoDisposeFutureProviderElement<CourseModel?> createElement() {
    return _CourseForRoundProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CourseForRoundProvider && other.roundId == roundId;
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
mixin CourseForRoundRef on AutoDisposeFutureProviderRef<CourseModel?> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _CourseForRoundProviderElement
    extends AutoDisposeFutureProviderElement<CourseModel?>
    with CourseForRoundRef {
  _CourseForRoundProviderElement(super.provider);

  @override
  int get roundId => (origin as CourseForRoundProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
