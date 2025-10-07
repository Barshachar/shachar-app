// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'effective_price.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EffectivePrice {
  String get vendorId;
  String get variantId;
  String get currency;
  double get unitPrice;
  String get scope;

  /// Create a copy of EffectivePrice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EffectivePriceCopyWith<EffectivePrice> get copyWith =>
      _$EffectivePriceCopyWithImpl<EffectivePrice>(
          this as EffectivePrice, _$identity);

  /// Serializes this EffectivePrice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EffectivePrice &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, vendorId, variantId, currency, unitPrice, scope);

  @override
  String toString() {
    return 'EffectivePrice(vendorId: $vendorId, variantId: $variantId, currency: $currency, unitPrice: $unitPrice, scope: $scope)';
  }
}

/// @nodoc
abstract mixin class $EffectivePriceCopyWith<$Res> {
  factory $EffectivePriceCopyWith(
          EffectivePrice value, $Res Function(EffectivePrice) _then) =
      _$EffectivePriceCopyWithImpl;
  @useResult
  $Res call(
      {String vendorId,
      String variantId,
      String currency,
      double unitPrice,
      String scope});
}

/// @nodoc
class _$EffectivePriceCopyWithImpl<$Res>
    implements $EffectivePriceCopyWith<$Res> {
  _$EffectivePriceCopyWithImpl(this._self, this._then);

  final EffectivePrice _self;
  final $Res Function(EffectivePrice) _then;

  /// Create a copy of EffectivePrice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? variantId = null,
    Object? currency = null,
    Object? unitPrice = null,
    Object? scope = null,
  }) {
    return _then(_self.copyWith(
      vendorId: null == vendorId
          ? _self.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      variantId: null == variantId
          ? _self.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      scope: null == scope
          ? _self.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [EffectivePrice].
extension EffectivePricePatterns on EffectivePrice {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_EffectivePrice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EffectivePrice() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_EffectivePrice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EffectivePrice():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_EffectivePrice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EffectivePrice() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String vendorId, String variantId, String currency,
            double unitPrice, String scope)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EffectivePrice() when $default != null:
        return $default(_that.vendorId, _that.variantId, _that.currency,
            _that.unitPrice, _that.scope);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String vendorId, String variantId, String currency,
            double unitPrice, String scope)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EffectivePrice():
        return $default(_that.vendorId, _that.variantId, _that.currency,
            _that.unitPrice, _that.scope);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String vendorId, String variantId, String currency,
            double unitPrice, String scope)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EffectivePrice() when $default != null:
        return $default(_that.vendorId, _that.variantId, _that.currency,
            _that.unitPrice, _that.scope);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _EffectivePrice implements EffectivePrice {
  const _EffectivePrice(
      {required this.vendorId,
      required this.variantId,
      required this.currency,
      required this.unitPrice,
      required this.scope});
  factory _EffectivePrice.fromJson(Map<String, dynamic> json) =>
      _$EffectivePriceFromJson(json);

  @override
  final String vendorId;
  @override
  final String variantId;
  @override
  final String currency;
  @override
  final double unitPrice;
  @override
  final String scope;

  /// Create a copy of EffectivePrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EffectivePriceCopyWith<_EffectivePrice> get copyWith =>
      __$EffectivePriceCopyWithImpl<_EffectivePrice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$EffectivePriceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EffectivePrice &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.scope, scope) || other.scope == scope));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, vendorId, variantId, currency, unitPrice, scope);

  @override
  String toString() {
    return 'EffectivePrice(vendorId: $vendorId, variantId: $variantId, currency: $currency, unitPrice: $unitPrice, scope: $scope)';
  }
}

/// @nodoc
abstract mixin class _$EffectivePriceCopyWith<$Res>
    implements $EffectivePriceCopyWith<$Res> {
  factory _$EffectivePriceCopyWith(
          _EffectivePrice value, $Res Function(_EffectivePrice) _then) =
      __$EffectivePriceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String vendorId,
      String variantId,
      String currency,
      double unitPrice,
      String scope});
}

/// @nodoc
class __$EffectivePriceCopyWithImpl<$Res>
    implements _$EffectivePriceCopyWith<$Res> {
  __$EffectivePriceCopyWithImpl(this._self, this._then);

  final _EffectivePrice _self;
  final $Res Function(_EffectivePrice) _then;

  /// Create a copy of EffectivePrice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? vendorId = null,
    Object? variantId = null,
    Object? currency = null,
    Object? unitPrice = null,
    Object? scope = null,
  }) {
    return _then(_EffectivePrice(
      vendorId: null == vendorId
          ? _self.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      variantId: null == variantId
          ? _self.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      scope: null == scope
          ? _self.scope
          : scope // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
