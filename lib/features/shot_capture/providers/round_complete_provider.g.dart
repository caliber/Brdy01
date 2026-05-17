// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_complete_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roundCompleteHash() => r'bc8a24ba2f331efc989fa392565ae3b9c69d0f43';

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

/// See also [roundComplete].
@ProviderFor(roundComplete)
const roundCompleteProvider = RoundCompleteFamily();

/// See also [roundComplete].
class RoundCompleteFamily extends Family<bool> {
  /// See also [roundComplete].
  const RoundCompleteFamily();

  /// See also [roundComplete].
  RoundCompleteProvider call(
    int roundId,
  ) {
    return RoundCompleteProvider(
      roundId,
    );
  }

  @override
  RoundCompleteProvider getProviderOverride(
    covariant RoundCompleteProvider provider,
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
  String? get name => r'roundCompleteProvider';
}

/// See also [roundComplete].
class RoundCompleteProvider extends AutoDisposeProvider<bool> {
  /// See also [roundComplete].
  RoundCompleteProvider(
    int roundId,
  ) : this._internal(
          (ref) => roundComplete(
            ref as RoundCompleteRef,
            roundId,
          ),
          from: roundCompleteProvider,
          name: r'roundCompleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roundCompleteHash,
          dependencies: RoundCompleteFamily._dependencies,
          allTransitiveDependencies:
              RoundCompleteFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  RoundCompleteProvider._internal(
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
    bool Function(RoundCompleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoundCompleteProvider._internal(
        (ref) => create(ref as RoundCompleteRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _RoundCompleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoundCompleteProvider && other.roundId == roundId;
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
mixin RoundCompleteRef on AutoDisposeProviderRef<bool> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _RoundCompleteProviderElement extends AutoDisposeProviderElement<bool>
    with RoundCompleteRef {
  _RoundCompleteProviderElement(super.provider);

  @override
  int get roundId => (origin as RoundCompleteProvider).roundId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
