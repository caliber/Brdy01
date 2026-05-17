// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whs_differential_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$whsDifferentialHash() => r'f253eba404108a8bd92f44eff480f2a792033317';

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

/// See also [whsDifferential].
@ProviderFor(whsDifferential)
const whsDifferentialProvider = WhsDifferentialFamily();

/// See also [whsDifferential].
class WhsDifferentialFamily extends Family<AsyncValue<WhsDifferential>> {
  /// See also [whsDifferential].
  const WhsDifferentialFamily();

  /// See also [whsDifferential].
  WhsDifferentialProvider call(
    int roundId,
  ) {
    return WhsDifferentialProvider(
      roundId,
    );
  }

  @override
  WhsDifferentialProvider getProviderOverride(
    covariant WhsDifferentialProvider provider,
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
  String? get name => r'whsDifferentialProvider';
}

/// See also [whsDifferential].
class WhsDifferentialProvider
    extends AutoDisposeFutureProvider<WhsDifferential> {
  /// See also [whsDifferential].
  WhsDifferentialProvider(
    int roundId,
  ) : this._internal(
          (ref) => whsDifferential(
            ref as WhsDifferentialRef,
            roundId,
          ),
          from: whsDifferentialProvider,
          name: r'whsDifferentialProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$whsDifferentialHash,
          dependencies: WhsDifferentialFamily._dependencies,
          allTransitiveDependencies:
              WhsDifferentialFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  WhsDifferentialProvider._internal(
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
    FutureOr<WhsDifferential> Function(WhsDifferentialRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WhsDifferentialProvider._internal(
        (ref) => create(ref as WhsDifferentialRef),
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
  AutoDisposeFutureProviderElement<WhsDifferential> createElement() {
    return _WhsDifferentialProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WhsDifferentialProvider && other.roundId == roundId;
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
mixin WhsDifferentialRef on AutoDisposeFutureProviderRef<WhsDifferential> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _WhsDifferentialProviderElement
    extends AutoDisposeFutureProviderElement<WhsDifferential>
    with WhsDifferentialRef {
  _WhsDifferentialProviderElement(super.provider);

  @override
  int get roundId => (origin as WhsDifferentialProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
