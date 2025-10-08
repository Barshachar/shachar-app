// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipping_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShippingMethod {
  String get id;
  String get name;
  String get code;
  double get rate;
  String? get currency;
  String? get estimatedDays;
  String? get carrier;
  bool get active;

  /// Create a copy of ShippingMethod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ShippingMethodCopyWith<ShippingMethod> get copyWith =>
      _$ShippingMethodCopyWithImpl<ShippingMethod>(
          this as ShippingMethod, _$identity);

  /// Serializes this ShippingMethod to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ShippingMethod &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.estimatedDays, estimatedDays) ||
                other.estimatedDays == estimatedDays) &&
            (identical(other.carrier, carrier) || other.carrier == carrier) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, code, rate, currency,
      estimatedDays, carrier, active);

  @override
  String toString() {
    return 'ShippingMethod(id: $id, name: $name, code: $code, rate: $rate, currency: $currency, estimatedDays: $estimatedDays, carrier: $carrier, active: $active)';
  }
}

/// @nodoc
abstract mixin class $ShippingMethodCopyWith<$Res> {
  factory $ShippingMethodCopyWith(
          ShippingMethod value, $Res Function(ShippingMethod) _then) =
      _$ShippingMethodCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      double rate,
      String? currency,
      String? estimatedDays,
      String? carrier,
      bool active});
}

/// @nodoc
class _$ShippingMethodCopyWithImpl<$Res>
    implements $ShippingMethodCopyWith<$Res> {
  _$ShippingMethodCopyWithImpl(this._self, this._then);

  final ShippingMethod _self;
  final $Res Function(ShippingMethod) _then;

  /// Create a copy of ShippingMethod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? rate = null,
    Object? currency = freezed,
    Object? estimatedDays = freezed,
    Object? carrier = freezed,
    Object? active = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      rate: null == rate
          ? _self.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      currency: freezed == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDays: freezed == estimatedDays
          ? _self.estimatedDays
          : estimatedDays // ignore: cast_nullable_to_non_nullable
              as String?,
      carrier: freezed == carrier
          ? _self.carrier
          : carrier // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ShippingMethod].
extension ShippingMethodPatterns on ShippingMethod {
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
    TResult Function(_ShippingMethod value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ShippingMethod() when $default != null:
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
    TResult Function(_ShippingMethod value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShippingMethod():
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
    TResult? Function(_ShippingMethod value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShippingMethod() when $default != null:
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
    TResult Function(
            String id,
            String name,
            String code,
            double rate,
            String? currency,
            String? estimatedDays,
            String? carrier,
            bool active)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ShippingMethod() when $default != null:
        return $default(_that.id, _that.name, _that.code, _that.rate,
            _that.currency, _that.estimatedDays, _that.carrier, _that.active);
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
    TResult Function(
            String id,
            String name,
            String code,
            double rate,
            String? currency,
            String? estimatedDays,
            String? carrier,
            bool active)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShippingMethod():
        return $default(_that.id, _that.name, _that.code, _that.rate,
            _that.currency, _that.estimatedDays, _that.carrier, _that.active);
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
    TResult? Function(
            String id,
            String name,
            String code,
            double rate,
            String? currency,
            String? estimatedDays,
            String? carrier,
            bool active)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ShippingMethod() when $default != null:
        return $default(_that.id, _that.name, _that.code, _that.rate,
            _that.currency, _that.estimatedDays, _that.carrier, _that.active);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ShippingMethod implements ShippingMethod {
  const _ShippingMethod(
      {required this.id,
      required this.name,
      required this.code,
      required this.rate,
      this.currency,
      this.estimatedDays,
      this.carrier,
      required this.active});
  factory _ShippingMethod.fromJson(Map<String, dynamic> json) =>
      _$ShippingMethodFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final double rate;
  @override
  final String? currency;
  @override
  final String? estimatedDays;
  @override
  final String? carrier;
  @override
  final bool active;

  /// Create a copy of ShippingMethod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ShippingMethodCopyWith<_ShippingMethod> get copyWith =>
      __$ShippingMethodCopyWithImpl<_ShippingMethod>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ShippingMethodToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ShippingMethod &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.estimatedDays, estimatedDays) ||
                other.estimatedDays == estimatedDays) &&
            (identical(other.carrier, carrier) || other.carrier == carrier) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, code, rate, currency,
      estimatedDays, carrier, active);

  @override
  String toString() {
    return 'ShippingMethod(id: $id, name: $name, code: $code, rate: $rate, currency: $currency, estimatedDays: $estimatedDays, carrier: $carrier, active: $active)';
  }
}

/// @nodoc
abstract mixin class _$ShippingMethodCopyWith<$Res>
    implements $ShippingMethodCopyWith<$Res> {
  factory _$ShippingMethodCopyWith(
          _ShippingMethod value, $Res Function(_ShippingMethod) _then) =
      __$ShippingMethodCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      double rate,
      String? currency,
      String? estimatedDays,
      String? carrier,
      bool active});
}

/// @nodoc
class __$ShippingMethodCopyWithImpl<$Res>
    implements _$ShippingMethodCopyWith<$Res> {
  __$ShippingMethodCopyWithImpl(this._self, this._then);

  final _ShippingMethod _self;
  final $Res Function(_ShippingMethod) _then;

  /// Create a copy of ShippingMethod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? rate = null,
    Object? currency = freezed,
    Object? estimatedDays = freezed,
    Object? carrier = freezed,
    Object? active = null,
  }) {
    return _then(_ShippingMethod(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      rate: null == rate
          ? _self.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      currency: freezed == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedDays: freezed == estimatedDays
          ? _self.estimatedDays
          : estimatedDays // ignore: cast_nullable_to_non_nullable
              as String?,
      carrier: freezed == carrier
          ? _self.carrier
          : carrier // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$AdvancedShippingNotice {
  String get id;
  String get orderId;
  String get shipmentId;
  DateTime get expectedArrival;
  String? get trackingNumber;
  String? get carrier;
  List<AsnPackage> get packages;
  String? get notes;
  DateTime get createdAt;

  /// Create a copy of AdvancedShippingNotice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AdvancedShippingNoticeCopyWith<AdvancedShippingNotice> get copyWith =>
      _$AdvancedShippingNoticeCopyWithImpl<AdvancedShippingNotice>(
          this as AdvancedShippingNotice, _$identity);

  /// Serializes this AdvancedShippingNotice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AdvancedShippingNotice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.shipmentId, shipmentId) ||
                other.shipmentId == shipmentId) &&
            (identical(other.expectedArrival, expectedArrival) ||
                other.expectedArrival == expectedArrival) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.carrier, carrier) || other.carrier == carrier) &&
            const DeepCollectionEquality().equals(other.packages, packages) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      shipmentId,
      expectedArrival,
      trackingNumber,
      carrier,
      const DeepCollectionEquality().hash(packages),
      notes,
      createdAt);

  @override
  String toString() {
    return 'AdvancedShippingNotice(id: $id, orderId: $orderId, shipmentId: $shipmentId, expectedArrival: $expectedArrival, trackingNumber: $trackingNumber, carrier: $carrier, packages: $packages, notes: $notes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $AdvancedShippingNoticeCopyWith<$Res> {
  factory $AdvancedShippingNoticeCopyWith(AdvancedShippingNotice value,
          $Res Function(AdvancedShippingNotice) _then) =
      _$AdvancedShippingNoticeCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String orderId,
      String shipmentId,
      DateTime expectedArrival,
      String? trackingNumber,
      String? carrier,
      List<AsnPackage> packages,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$AdvancedShippingNoticeCopyWithImpl<$Res>
    implements $AdvancedShippingNoticeCopyWith<$Res> {
  _$AdvancedShippingNoticeCopyWithImpl(this._self, this._then);

  final AdvancedShippingNotice _self;
  final $Res Function(AdvancedShippingNotice) _then;

  /// Create a copy of AdvancedShippingNotice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? shipmentId = null,
    Object? expectedArrival = null,
    Object? trackingNumber = freezed,
    Object? carrier = freezed,
    Object? packages = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _self.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      shipmentId: null == shipmentId
          ? _self.shipmentId
          : shipmentId // ignore: cast_nullable_to_non_nullable
              as String,
      expectedArrival: null == expectedArrival
          ? _self.expectedArrival
          : expectedArrival // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trackingNumber: freezed == trackingNumber
          ? _self.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      carrier: freezed == carrier
          ? _self.carrier
          : carrier // ignore: cast_nullable_to_non_nullable
              as String?,
      packages: null == packages
          ? _self.packages
          : packages // ignore: cast_nullable_to_non_nullable
              as List<AsnPackage>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [AdvancedShippingNotice].
extension AdvancedShippingNoticePatterns on AdvancedShippingNotice {
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
    TResult Function(_AdvancedShippingNotice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AdvancedShippingNotice() when $default != null:
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
    TResult Function(_AdvancedShippingNotice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdvancedShippingNotice():
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
    TResult? Function(_AdvancedShippingNotice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdvancedShippingNotice() when $default != null:
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
    TResult Function(
            String id,
            String orderId,
            String shipmentId,
            DateTime expectedArrival,
            String? trackingNumber,
            String? carrier,
            List<AsnPackage> packages,
            String? notes,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AdvancedShippingNotice() when $default != null:
        return $default(
            _that.id,
            _that.orderId,
            _that.shipmentId,
            _that.expectedArrival,
            _that.trackingNumber,
            _that.carrier,
            _that.packages,
            _that.notes,
            _that.createdAt);
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
    TResult Function(
            String id,
            String orderId,
            String shipmentId,
            DateTime expectedArrival,
            String? trackingNumber,
            String? carrier,
            List<AsnPackage> packages,
            String? notes,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdvancedShippingNotice():
        return $default(
            _that.id,
            _that.orderId,
            _that.shipmentId,
            _that.expectedArrival,
            _that.trackingNumber,
            _that.carrier,
            _that.packages,
            _that.notes,
            _that.createdAt);
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
    TResult? Function(
            String id,
            String orderId,
            String shipmentId,
            DateTime expectedArrival,
            String? trackingNumber,
            String? carrier,
            List<AsnPackage> packages,
            String? notes,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdvancedShippingNotice() when $default != null:
        return $default(
            _that.id,
            _that.orderId,
            _that.shipmentId,
            _that.expectedArrival,
            _that.trackingNumber,
            _that.carrier,
            _that.packages,
            _that.notes,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AdvancedShippingNotice implements AdvancedShippingNotice {
  const _AdvancedShippingNotice(
      {required this.id,
      required this.orderId,
      required this.shipmentId,
      required this.expectedArrival,
      this.trackingNumber,
      this.carrier,
      required final List<AsnPackage> packages,
      this.notes,
      required this.createdAt})
      : _packages = packages;
  factory _AdvancedShippingNotice.fromJson(Map<String, dynamic> json) =>
      _$AdvancedShippingNoticeFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String shipmentId;
  @override
  final DateTime expectedArrival;
  @override
  final String? trackingNumber;
  @override
  final String? carrier;
  final List<AsnPackage> _packages;
  @override
  List<AsnPackage> get packages {
    if (_packages is EqualUnmodifiableListView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_packages);
  }

  @override
  final String? notes;
  @override
  final DateTime createdAt;

  /// Create a copy of AdvancedShippingNotice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AdvancedShippingNoticeCopyWith<_AdvancedShippingNotice> get copyWith =>
      __$AdvancedShippingNoticeCopyWithImpl<_AdvancedShippingNotice>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AdvancedShippingNoticeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AdvancedShippingNotice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.shipmentId, shipmentId) ||
                other.shipmentId == shipmentId) &&
            (identical(other.expectedArrival, expectedArrival) ||
                other.expectedArrival == expectedArrival) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.carrier, carrier) || other.carrier == carrier) &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      orderId,
      shipmentId,
      expectedArrival,
      trackingNumber,
      carrier,
      const DeepCollectionEquality().hash(_packages),
      notes,
      createdAt);

  @override
  String toString() {
    return 'AdvancedShippingNotice(id: $id, orderId: $orderId, shipmentId: $shipmentId, expectedArrival: $expectedArrival, trackingNumber: $trackingNumber, carrier: $carrier, packages: $packages, notes: $notes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$AdvancedShippingNoticeCopyWith<$Res>
    implements $AdvancedShippingNoticeCopyWith<$Res> {
  factory _$AdvancedShippingNoticeCopyWith(_AdvancedShippingNotice value,
          $Res Function(_AdvancedShippingNotice) _then) =
      __$AdvancedShippingNoticeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String orderId,
      String shipmentId,
      DateTime expectedArrival,
      String? trackingNumber,
      String? carrier,
      List<AsnPackage> packages,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$AdvancedShippingNoticeCopyWithImpl<$Res>
    implements _$AdvancedShippingNoticeCopyWith<$Res> {
  __$AdvancedShippingNoticeCopyWithImpl(this._self, this._then);

  final _AdvancedShippingNotice _self;
  final $Res Function(_AdvancedShippingNotice) _then;

  /// Create a copy of AdvancedShippingNotice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? shipmentId = null,
    Object? expectedArrival = null,
    Object? trackingNumber = freezed,
    Object? carrier = freezed,
    Object? packages = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_AdvancedShippingNotice(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _self.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      shipmentId: null == shipmentId
          ? _self.shipmentId
          : shipmentId // ignore: cast_nullable_to_non_nullable
              as String,
      expectedArrival: null == expectedArrival
          ? _self.expectedArrival
          : expectedArrival // ignore: cast_nullable_to_non_nullable
              as DateTime,
      trackingNumber: freezed == trackingNumber
          ? _self.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      carrier: freezed == carrier
          ? _self.carrier
          : carrier // ignore: cast_nullable_to_non_nullable
              as String?,
      packages: null == packages
          ? _self._packages
          : packages // ignore: cast_nullable_to_non_nullable
              as List<AsnPackage>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$AsnPackage {
  String get id;
  String get packageNumber;
  double get weight;
  String? get weightUnit;
  Map<String, dynamic>? get dimensions;
  List<AsnItem> get items;

  /// Create a copy of AsnPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AsnPackageCopyWith<AsnPackage> get copyWith =>
      _$AsnPackageCopyWithImpl<AsnPackage>(this as AsnPackage, _$identity);

  /// Serializes this AsnPackage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AsnPackage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packageNumber, packageNumber) ||
                other.packageNumber == packageNumber) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            const DeepCollectionEquality()
                .equals(other.dimensions, dimensions) &&
            const DeepCollectionEquality().equals(other.items, items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      packageNumber,
      weight,
      weightUnit,
      const DeepCollectionEquality().hash(dimensions),
      const DeepCollectionEquality().hash(items));

  @override
  String toString() {
    return 'AsnPackage(id: $id, packageNumber: $packageNumber, weight: $weight, weightUnit: $weightUnit, dimensions: $dimensions, items: $items)';
  }
}

/// @nodoc
abstract mixin class $AsnPackageCopyWith<$Res> {
  factory $AsnPackageCopyWith(
          AsnPackage value, $Res Function(AsnPackage) _then) =
      _$AsnPackageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String packageNumber,
      double weight,
      String? weightUnit,
      Map<String, dynamic>? dimensions,
      List<AsnItem> items});
}

/// @nodoc
class _$AsnPackageCopyWithImpl<$Res> implements $AsnPackageCopyWith<$Res> {
  _$AsnPackageCopyWithImpl(this._self, this._then);

  final AsnPackage _self;
  final $Res Function(AsnPackage) _then;

  /// Create a copy of AsnPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? packageNumber = null,
    Object? weight = null,
    Object? weightUnit = freezed,
    Object? dimensions = freezed,
    Object? items = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      packageNumber: null == packageNumber
          ? _self.packageNumber
          : packageNumber // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      weightUnit: freezed == weightUnit
          ? _self.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _self.dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<AsnItem>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AsnPackage].
extension AsnPackagePatterns on AsnPackage {
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
    TResult Function(_AsnPackage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AsnPackage() when $default != null:
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
    TResult Function(_AsnPackage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnPackage():
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
    TResult? Function(_AsnPackage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnPackage() when $default != null:
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
    TResult Function(
            String id,
            String packageNumber,
            double weight,
            String? weightUnit,
            Map<String, dynamic>? dimensions,
            List<AsnItem> items)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AsnPackage() when $default != null:
        return $default(_that.id, _that.packageNumber, _that.weight,
            _that.weightUnit, _that.dimensions, _that.items);
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
    TResult Function(
            String id,
            String packageNumber,
            double weight,
            String? weightUnit,
            Map<String, dynamic>? dimensions,
            List<AsnItem> items)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnPackage():
        return $default(_that.id, _that.packageNumber, _that.weight,
            _that.weightUnit, _that.dimensions, _that.items);
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
    TResult? Function(
            String id,
            String packageNumber,
            double weight,
            String? weightUnit,
            Map<String, dynamic>? dimensions,
            List<AsnItem> items)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnPackage() when $default != null:
        return $default(_that.id, _that.packageNumber, _that.weight,
            _that.weightUnit, _that.dimensions, _that.items);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AsnPackage implements AsnPackage {
  const _AsnPackage(
      {required this.id,
      required this.packageNumber,
      required this.weight,
      this.weightUnit,
      final Map<String, dynamic>? dimensions,
      required final List<AsnItem> items})
      : _dimensions = dimensions,
        _items = items;
  factory _AsnPackage.fromJson(Map<String, dynamic> json) =>
      _$AsnPackageFromJson(json);

  @override
  final String id;
  @override
  final String packageNumber;
  @override
  final double weight;
  @override
  final String? weightUnit;
  final Map<String, dynamic>? _dimensions;
  @override
  Map<String, dynamic>? get dimensions {
    final value = _dimensions;
    if (value == null) return null;
    if (_dimensions is EqualUnmodifiableMapView) return _dimensions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<AsnItem> _items;
  @override
  List<AsnItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Create a copy of AsnPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AsnPackageCopyWith<_AsnPackage> get copyWith =>
      __$AsnPackageCopyWithImpl<_AsnPackage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AsnPackageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AsnPackage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packageNumber, packageNumber) ||
                other.packageNumber == packageNumber) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.weightUnit, weightUnit) ||
                other.weightUnit == weightUnit) &&
            const DeepCollectionEquality()
                .equals(other._dimensions, _dimensions) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      packageNumber,
      weight,
      weightUnit,
      const DeepCollectionEquality().hash(_dimensions),
      const DeepCollectionEquality().hash(_items));

  @override
  String toString() {
    return 'AsnPackage(id: $id, packageNumber: $packageNumber, weight: $weight, weightUnit: $weightUnit, dimensions: $dimensions, items: $items)';
  }
}

/// @nodoc
abstract mixin class _$AsnPackageCopyWith<$Res>
    implements $AsnPackageCopyWith<$Res> {
  factory _$AsnPackageCopyWith(
          _AsnPackage value, $Res Function(_AsnPackage) _then) =
      __$AsnPackageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String packageNumber,
      double weight,
      String? weightUnit,
      Map<String, dynamic>? dimensions,
      List<AsnItem> items});
}

/// @nodoc
class __$AsnPackageCopyWithImpl<$Res> implements _$AsnPackageCopyWith<$Res> {
  __$AsnPackageCopyWithImpl(this._self, this._then);

  final _AsnPackage _self;
  final $Res Function(_AsnPackage) _then;

  /// Create a copy of AsnPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? packageNumber = null,
    Object? weight = null,
    Object? weightUnit = freezed,
    Object? dimensions = freezed,
    Object? items = null,
  }) {
    return _then(_AsnPackage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      packageNumber: null == packageNumber
          ? _self.packageNumber
          : packageNumber // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      weightUnit: freezed == weightUnit
          ? _self.weightUnit
          : weightUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      dimensions: freezed == dimensions
          ? _self._dimensions
          : dimensions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<AsnItem>,
    ));
  }
}

/// @nodoc
mixin _$AsnItem {
  String get orderItemId;
  String get variantId;
  double get qty;
  String? get lotNumber;
  DateTime? get expiryDate;

  /// Create a copy of AsnItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AsnItemCopyWith<AsnItem> get copyWith =>
      _$AsnItemCopyWithImpl<AsnItem>(this as AsnItem, _$identity);

  /// Serializes this AsnItem to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AsnItem &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.lotNumber, lotNumber) ||
                other.lotNumber == lotNumber) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, orderItemId, variantId, qty, lotNumber, expiryDate);

  @override
  String toString() {
    return 'AsnItem(orderItemId: $orderItemId, variantId: $variantId, qty: $qty, lotNumber: $lotNumber, expiryDate: $expiryDate)';
  }
}

/// @nodoc
abstract mixin class $AsnItemCopyWith<$Res> {
  factory $AsnItemCopyWith(AsnItem value, $Res Function(AsnItem) _then) =
      _$AsnItemCopyWithImpl;
  @useResult
  $Res call(
      {String orderItemId,
      String variantId,
      double qty,
      String? lotNumber,
      DateTime? expiryDate});
}

/// @nodoc
class _$AsnItemCopyWithImpl<$Res> implements $AsnItemCopyWith<$Res> {
  _$AsnItemCopyWithImpl(this._self, this._then);

  final AsnItem _self;
  final $Res Function(AsnItem) _then;

  /// Create a copy of AsnItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderItemId = null,
    Object? variantId = null,
    Object? qty = null,
    Object? lotNumber = freezed,
    Object? expiryDate = freezed,
  }) {
    return _then(_self.copyWith(
      orderItemId: null == orderItemId
          ? _self.orderItemId
          : orderItemId // ignore: cast_nullable_to_non_nullable
              as String,
      variantId: null == variantId
          ? _self.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String,
      qty: null == qty
          ? _self.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as double,
      lotNumber: freezed == lotNumber
          ? _self.lotNumber
          : lotNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AsnItem].
extension AsnItemPatterns on AsnItem {
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
    TResult Function(_AsnItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AsnItem() when $default != null:
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
    TResult Function(_AsnItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnItem():
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
    TResult? Function(_AsnItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnItem() when $default != null:
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
    TResult Function(String orderItemId, String variantId, double qty,
            String? lotNumber, DateTime? expiryDate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AsnItem() when $default != null:
        return $default(_that.orderItemId, _that.variantId, _that.qty,
            _that.lotNumber, _that.expiryDate);
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
    TResult Function(String orderItemId, String variantId, double qty,
            String? lotNumber, DateTime? expiryDate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnItem():
        return $default(_that.orderItemId, _that.variantId, _that.qty,
            _that.lotNumber, _that.expiryDate);
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
    TResult? Function(String orderItemId, String variantId, double qty,
            String? lotNumber, DateTime? expiryDate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AsnItem() when $default != null:
        return $default(_that.orderItemId, _that.variantId, _that.qty,
            _that.lotNumber, _that.expiryDate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AsnItem implements AsnItem {
  const _AsnItem(
      {required this.orderItemId,
      required this.variantId,
      required this.qty,
      this.lotNumber,
      this.expiryDate});
  factory _AsnItem.fromJson(Map<String, dynamic> json) =>
      _$AsnItemFromJson(json);

  @override
  final String orderItemId;
  @override
  final String variantId;
  @override
  final double qty;
  @override
  final String? lotNumber;
  @override
  final DateTime? expiryDate;

  /// Create a copy of AsnItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AsnItemCopyWith<_AsnItem> get copyWith =>
      __$AsnItemCopyWithImpl<_AsnItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AsnItemToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AsnItem &&
            (identical(other.orderItemId, orderItemId) ||
                other.orderItemId == orderItemId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.lotNumber, lotNumber) ||
                other.lotNumber == lotNumber) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, orderItemId, variantId, qty, lotNumber, expiryDate);

  @override
  String toString() {
    return 'AsnItem(orderItemId: $orderItemId, variantId: $variantId, qty: $qty, lotNumber: $lotNumber, expiryDate: $expiryDate)';
  }
}

/// @nodoc
abstract mixin class _$AsnItemCopyWith<$Res> implements $AsnItemCopyWith<$Res> {
  factory _$AsnItemCopyWith(_AsnItem value, $Res Function(_AsnItem) _then) =
      __$AsnItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String orderItemId,
      String variantId,
      double qty,
      String? lotNumber,
      DateTime? expiryDate});
}

/// @nodoc
class __$AsnItemCopyWithImpl<$Res> implements _$AsnItemCopyWith<$Res> {
  __$AsnItemCopyWithImpl(this._self, this._then);

  final _AsnItem _self;
  final $Res Function(_AsnItem) _then;

  /// Create a copy of AsnItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? orderItemId = null,
    Object? variantId = null,
    Object? qty = null,
    Object? lotNumber = freezed,
    Object? expiryDate = freezed,
  }) {
    return _then(_AsnItem(
      orderItemId: null == orderItemId
          ? _self.orderItemId
          : orderItemId // ignore: cast_nullable_to_non_nullable
              as String,
      variantId: null == variantId
          ? _self.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String,
      qty: null == qty
          ? _self.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as double,
      lotNumber: freezed == lotNumber
          ? _self.lotNumber
          : lotNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _self.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$ProofOfDelivery {
  String get id;
  String get shipmentId;
  DateTime get deliveredAt;
  String get recipientName;
  String? get recipientSignature;
  List<String>? get photoUrls;
  String? get notes;
  DateTime get createdAt;

  /// Create a copy of ProofOfDelivery
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProofOfDeliveryCopyWith<ProofOfDelivery> get copyWith =>
      _$ProofOfDeliveryCopyWithImpl<ProofOfDelivery>(
          this as ProofOfDelivery, _$identity);

  /// Serializes this ProofOfDelivery to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProofOfDelivery &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shipmentId, shipmentId) ||
                other.shipmentId == shipmentId) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientSignature, recipientSignature) ||
                other.recipientSignature == recipientSignature) &&
            const DeepCollectionEquality().equals(other.photoUrls, photoUrls) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      shipmentId,
      deliveredAt,
      recipientName,
      recipientSignature,
      const DeepCollectionEquality().hash(photoUrls),
      notes,
      createdAt);

  @override
  String toString() {
    return 'ProofOfDelivery(id: $id, shipmentId: $shipmentId, deliveredAt: $deliveredAt, recipientName: $recipientName, recipientSignature: $recipientSignature, photoUrls: $photoUrls, notes: $notes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $ProofOfDeliveryCopyWith<$Res> {
  factory $ProofOfDeliveryCopyWith(
          ProofOfDelivery value, $Res Function(ProofOfDelivery) _then) =
      _$ProofOfDeliveryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String shipmentId,
      DateTime deliveredAt,
      String recipientName,
      String? recipientSignature,
      List<String>? photoUrls,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$ProofOfDeliveryCopyWithImpl<$Res>
    implements $ProofOfDeliveryCopyWith<$Res> {
  _$ProofOfDeliveryCopyWithImpl(this._self, this._then);

  final ProofOfDelivery _self;
  final $Res Function(ProofOfDelivery) _then;

  /// Create a copy of ProofOfDelivery
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shipmentId = null,
    Object? deliveredAt = null,
    Object? recipientName = null,
    Object? recipientSignature = freezed,
    Object? photoUrls = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shipmentId: null == shipmentId
          ? _self.shipmentId
          : shipmentId // ignore: cast_nullable_to_non_nullable
              as String,
      deliveredAt: null == deliveredAt
          ? _self.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recipientName: null == recipientName
          ? _self.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      recipientSignature: freezed == recipientSignature
          ? _self.recipientSignature
          : recipientSignature // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrls: freezed == photoUrls
          ? _self.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProofOfDelivery].
extension ProofOfDeliveryPatterns on ProofOfDelivery {
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
    TResult Function(_ProofOfDelivery value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProofOfDelivery() when $default != null:
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
    TResult Function(_ProofOfDelivery value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProofOfDelivery():
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
    TResult? Function(_ProofOfDelivery value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProofOfDelivery() when $default != null:
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
    TResult Function(
            String id,
            String shipmentId,
            DateTime deliveredAt,
            String recipientName,
            String? recipientSignature,
            List<String>? photoUrls,
            String? notes,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProofOfDelivery() when $default != null:
        return $default(
            _that.id,
            _that.shipmentId,
            _that.deliveredAt,
            _that.recipientName,
            _that.recipientSignature,
            _that.photoUrls,
            _that.notes,
            _that.createdAt);
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
    TResult Function(
            String id,
            String shipmentId,
            DateTime deliveredAt,
            String recipientName,
            String? recipientSignature,
            List<String>? photoUrls,
            String? notes,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProofOfDelivery():
        return $default(
            _that.id,
            _that.shipmentId,
            _that.deliveredAt,
            _that.recipientName,
            _that.recipientSignature,
            _that.photoUrls,
            _that.notes,
            _that.createdAt);
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
    TResult? Function(
            String id,
            String shipmentId,
            DateTime deliveredAt,
            String recipientName,
            String? recipientSignature,
            List<String>? photoUrls,
            String? notes,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProofOfDelivery() when $default != null:
        return $default(
            _that.id,
            _that.shipmentId,
            _that.deliveredAt,
            _that.recipientName,
            _that.recipientSignature,
            _that.photoUrls,
            _that.notes,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProofOfDelivery implements ProofOfDelivery {
  const _ProofOfDelivery(
      {required this.id,
      required this.shipmentId,
      required this.deliveredAt,
      required this.recipientName,
      this.recipientSignature,
      final List<String>? photoUrls,
      this.notes,
      required this.createdAt})
      : _photoUrls = photoUrls;
  factory _ProofOfDelivery.fromJson(Map<String, dynamic> json) =>
      _$ProofOfDeliveryFromJson(json);

  @override
  final String id;
  @override
  final String shipmentId;
  @override
  final DateTime deliveredAt;
  @override
  final String recipientName;
  @override
  final String? recipientSignature;
  final List<String>? _photoUrls;
  @override
  List<String>? get photoUrls {
    final value = _photoUrls;
    if (value == null) return null;
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? notes;
  @override
  final DateTime createdAt;

  /// Create a copy of ProofOfDelivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProofOfDeliveryCopyWith<_ProofOfDelivery> get copyWith =>
      __$ProofOfDeliveryCopyWithImpl<_ProofOfDelivery>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProofOfDeliveryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProofOfDelivery &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shipmentId, shipmentId) ||
                other.shipmentId == shipmentId) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientSignature, recipientSignature) ||
                other.recipientSignature == recipientSignature) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      shipmentId,
      deliveredAt,
      recipientName,
      recipientSignature,
      const DeepCollectionEquality().hash(_photoUrls),
      notes,
      createdAt);

  @override
  String toString() {
    return 'ProofOfDelivery(id: $id, shipmentId: $shipmentId, deliveredAt: $deliveredAt, recipientName: $recipientName, recipientSignature: $recipientSignature, photoUrls: $photoUrls, notes: $notes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$ProofOfDeliveryCopyWith<$Res>
    implements $ProofOfDeliveryCopyWith<$Res> {
  factory _$ProofOfDeliveryCopyWith(
          _ProofOfDelivery value, $Res Function(_ProofOfDelivery) _then) =
      __$ProofOfDeliveryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String shipmentId,
      DateTime deliveredAt,
      String recipientName,
      String? recipientSignature,
      List<String>? photoUrls,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$ProofOfDeliveryCopyWithImpl<$Res>
    implements _$ProofOfDeliveryCopyWith<$Res> {
  __$ProofOfDeliveryCopyWithImpl(this._self, this._then);

  final _ProofOfDelivery _self;
  final $Res Function(_ProofOfDelivery) _then;

  /// Create a copy of ProofOfDelivery
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? shipmentId = null,
    Object? deliveredAt = null,
    Object? recipientName = null,
    Object? recipientSignature = freezed,
    Object? photoUrls = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_ProofOfDelivery(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shipmentId: null == shipmentId
          ? _self.shipmentId
          : shipmentId // ignore: cast_nullable_to_non_nullable
              as String,
      deliveredAt: null == deliveredAt
          ? _self.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recipientName: null == recipientName
          ? _self.recipientName
          : recipientName // ignore: cast_nullable_to_non_nullable
              as String,
      recipientSignature: freezed == recipientSignature
          ? _self.recipientSignature
          : recipientSignature // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrls: freezed == photoUrls
          ? _self._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
