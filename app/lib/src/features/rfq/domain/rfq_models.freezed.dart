// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rfq_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RfqLine {
  String get productId;
  String get sku;
  String get uom;
  int get quantity;
  double? get targetUnitPrice;

  /// Create a copy of RfqLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RfqLineCopyWith<RfqLine> get copyWith =>
      _$RfqLineCopyWithImpl<RfqLine>(this as RfqLine, _$identity);

  /// Serializes this RfqLine to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RfqLine &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.targetUnitPrice, targetUnitPrice) ||
                other.targetUnitPrice == targetUnitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, sku, uom, quantity, targetUnitPrice);

  @override
  String toString() {
    return 'RfqLine(productId: $productId, sku: $sku, uom: $uom, quantity: $quantity, targetUnitPrice: $targetUnitPrice)';
  }
}

/// @nodoc
abstract mixin class $RfqLineCopyWith<$Res> {
  factory $RfqLineCopyWith(RfqLine value, $Res Function(RfqLine) _then) =
      _$RfqLineCopyWithImpl;
  @useResult
  $Res call(
      {String productId,
      String sku,
      String uom,
      int quantity,
      double? targetUnitPrice});
}

/// @nodoc
class _$RfqLineCopyWithImpl<$Res> implements $RfqLineCopyWith<$Res> {
  _$RfqLineCopyWithImpl(this._self, this._then);

  final RfqLine _self;
  final $Res Function(RfqLine) _then;

  /// Create a copy of RfqLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? uom = null,
    Object? quantity = null,
    Object? targetUnitPrice = freezed,
  }) {
    return _then(_self.copyWith(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _self.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      targetUnitPrice: freezed == targetUnitPrice
          ? _self.targetUnitPrice
          : targetUnitPrice // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [RfqLine].
extension RfqLinePatterns on RfqLine {
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
    TResult Function(_RfqLine value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RfqLine() when $default != null:
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
    TResult Function(_RfqLine value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqLine():
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
    TResult? Function(_RfqLine value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqLine() when $default != null:
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
    TResult Function(String productId, String sku, String uom, int quantity,
            double? targetUnitPrice)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RfqLine() when $default != null:
        return $default(_that.productId, _that.sku, _that.uom, _that.quantity,
            _that.targetUnitPrice);
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
    TResult Function(String productId, String sku, String uom, int quantity,
            double? targetUnitPrice)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqLine():
        return $default(_that.productId, _that.sku, _that.uom, _that.quantity,
            _that.targetUnitPrice);
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
    TResult? Function(String productId, String sku, String uom, int quantity,
            double? targetUnitPrice)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqLine() when $default != null:
        return $default(_that.productId, _that.sku, _that.uom, _that.quantity,
            _that.targetUnitPrice);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RfqLine implements RfqLine {
  const _RfqLine(
      {required this.productId,
      required this.sku,
      required this.uom,
      required this.quantity,
      this.targetUnitPrice});
  factory _RfqLine.fromJson(Map<String, dynamic> json) =>
      _$RfqLineFromJson(json);

  @override
  final String productId;
  @override
  final String sku;
  @override
  final String uom;
  @override
  final int quantity;
  @override
  final double? targetUnitPrice;

  /// Create a copy of RfqLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RfqLineCopyWith<_RfqLine> get copyWith =>
      __$RfqLineCopyWithImpl<_RfqLine>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RfqLineToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RfqLine &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.targetUnitPrice, targetUnitPrice) ||
                other.targetUnitPrice == targetUnitPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, productId, sku, uom, quantity, targetUnitPrice);

  @override
  String toString() {
    return 'RfqLine(productId: $productId, sku: $sku, uom: $uom, quantity: $quantity, targetUnitPrice: $targetUnitPrice)';
  }
}

/// @nodoc
abstract mixin class _$RfqLineCopyWith<$Res> implements $RfqLineCopyWith<$Res> {
  factory _$RfqLineCopyWith(_RfqLine value, $Res Function(_RfqLine) _then) =
      __$RfqLineCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String productId,
      String sku,
      String uom,
      int quantity,
      double? targetUnitPrice});
}

/// @nodoc
class __$RfqLineCopyWithImpl<$Res> implements _$RfqLineCopyWith<$Res> {
  __$RfqLineCopyWithImpl(this._self, this._then);

  final _RfqLine _self;
  final $Res Function(_RfqLine) _then;

  /// Create a copy of RfqLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? uom = null,
    Object? quantity = null,
    Object? targetUnitPrice = freezed,
  }) {
    return _then(_RfqLine(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _self.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      targetUnitPrice: freezed == targetUnitPrice
          ? _self.targetUnitPrice
          : targetUnitPrice // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
mixin _$QuoteLine {
  String get productId;
  String get sku;
  String get uom;
  int get minQty;
  double get unitPrice;
  int get leadTimeDays;

  /// Create a copy of QuoteLine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuoteLineCopyWith<QuoteLine> get copyWith =>
      _$QuoteLineCopyWithImpl<QuoteLine>(this as QuoteLine, _$identity);

  /// Serializes this QuoteLine to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuoteLine &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.minQty, minQty) || other.minQty == minQty) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.leadTimeDays, leadTimeDays) ||
                other.leadTimeDays == leadTimeDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, productId, sku, uom, minQty, unitPrice, leadTimeDays);

  @override
  String toString() {
    return 'QuoteLine(productId: $productId, sku: $sku, uom: $uom, minQty: $minQty, unitPrice: $unitPrice, leadTimeDays: $leadTimeDays)';
  }
}

/// @nodoc
abstract mixin class $QuoteLineCopyWith<$Res> {
  factory $QuoteLineCopyWith(QuoteLine value, $Res Function(QuoteLine) _then) =
      _$QuoteLineCopyWithImpl;
  @useResult
  $Res call(
      {String productId,
      String sku,
      String uom,
      int minQty,
      double unitPrice,
      int leadTimeDays});
}

/// @nodoc
class _$QuoteLineCopyWithImpl<$Res> implements $QuoteLineCopyWith<$Res> {
  _$QuoteLineCopyWithImpl(this._self, this._then);

  final QuoteLine _self;
  final $Res Function(QuoteLine) _then;

  /// Create a copy of QuoteLine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? uom = null,
    Object? minQty = null,
    Object? unitPrice = null,
    Object? leadTimeDays = null,
  }) {
    return _then(_self.copyWith(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _self.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      minQty: null == minQty
          ? _self.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      leadTimeDays: null == leadTimeDays
          ? _self.leadTimeDays
          : leadTimeDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [QuoteLine].
extension QuoteLinePatterns on QuoteLine {
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
    TResult Function(_QuoteLine value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuoteLine() when $default != null:
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
    TResult Function(_QuoteLine value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuoteLine():
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
    TResult? Function(_QuoteLine value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuoteLine() when $default != null:
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
    TResult Function(String productId, String sku, String uom, int minQty,
            double unitPrice, int leadTimeDays)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuoteLine() when $default != null:
        return $default(_that.productId, _that.sku, _that.uom, _that.minQty,
            _that.unitPrice, _that.leadTimeDays);
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
    TResult Function(String productId, String sku, String uom, int minQty,
            double unitPrice, int leadTimeDays)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuoteLine():
        return $default(_that.productId, _that.sku, _that.uom, _that.minQty,
            _that.unitPrice, _that.leadTimeDays);
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
    TResult? Function(String productId, String sku, String uom, int minQty,
            double unitPrice, int leadTimeDays)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuoteLine() when $default != null:
        return $default(_that.productId, _that.sku, _that.uom, _that.minQty,
            _that.unitPrice, _that.leadTimeDays);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _QuoteLine implements QuoteLine {
  const _QuoteLine(
      {required this.productId,
      required this.sku,
      required this.uom,
      required this.minQty,
      required this.unitPrice,
      required this.leadTimeDays});
  factory _QuoteLine.fromJson(Map<String, dynamic> json) =>
      _$QuoteLineFromJson(json);

  @override
  final String productId;
  @override
  final String sku;
  @override
  final String uom;
  @override
  final int minQty;
  @override
  final double unitPrice;
  @override
  final int leadTimeDays;

  /// Create a copy of QuoteLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuoteLineCopyWith<_QuoteLine> get copyWith =>
      __$QuoteLineCopyWithImpl<_QuoteLine>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuoteLineToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QuoteLine &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.minQty, minQty) || other.minQty == minQty) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.leadTimeDays, leadTimeDays) ||
                other.leadTimeDays == leadTimeDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, productId, sku, uom, minQty, unitPrice, leadTimeDays);

  @override
  String toString() {
    return 'QuoteLine(productId: $productId, sku: $sku, uom: $uom, minQty: $minQty, unitPrice: $unitPrice, leadTimeDays: $leadTimeDays)';
  }
}

/// @nodoc
abstract mixin class _$QuoteLineCopyWith<$Res>
    implements $QuoteLineCopyWith<$Res> {
  factory _$QuoteLineCopyWith(
          _QuoteLine value, $Res Function(_QuoteLine) _then) =
      __$QuoteLineCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String productId,
      String sku,
      String uom,
      int minQty,
      double unitPrice,
      int leadTimeDays});
}

/// @nodoc
class __$QuoteLineCopyWithImpl<$Res> implements _$QuoteLineCopyWith<$Res> {
  __$QuoteLineCopyWithImpl(this._self, this._then);

  final _QuoteLine _self;
  final $Res Function(_QuoteLine) _then;

  /// Create a copy of QuoteLine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productId = null,
    Object? sku = null,
    Object? uom = null,
    Object? minQty = null,
    Object? unitPrice = null,
    Object? leadTimeDays = null,
  }) {
    return _then(_QuoteLine(
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _self.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      minQty: null == minQty
          ? _self.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      leadTimeDays: null == leadTimeDays
          ? _self.leadTimeDays
          : leadTimeDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$RfqRequest {
  String get id;
  String get buyerId;
  List<RfqLine> get lines;
  String? get notes;
  String get targetCurrency;
  DateTime get requestedDeliveryDate;
  RfqStatus get status;

  /// Create a copy of RfqRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RfqRequestCopyWith<RfqRequest> get copyWith =>
      _$RfqRequestCopyWithImpl<RfqRequest>(this as RfqRequest, _$identity);

  /// Serializes this RfqRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RfqRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            const DeepCollectionEquality().equals(other.lines, lines) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.targetCurrency, targetCurrency) ||
                other.targetCurrency == targetCurrency) &&
            (identical(other.requestedDeliveryDate, requestedDeliveryDate) ||
                other.requestedDeliveryDate == requestedDeliveryDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      buyerId,
      const DeepCollectionEquality().hash(lines),
      notes,
      targetCurrency,
      requestedDeliveryDate,
      status);

  @override
  String toString() {
    return 'RfqRequest(id: $id, buyerId: $buyerId, lines: $lines, notes: $notes, targetCurrency: $targetCurrency, requestedDeliveryDate: $requestedDeliveryDate, status: $status)';
  }
}

/// @nodoc
abstract mixin class $RfqRequestCopyWith<$Res> {
  factory $RfqRequestCopyWith(
          RfqRequest value, $Res Function(RfqRequest) _then) =
      _$RfqRequestCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String buyerId,
      List<RfqLine> lines,
      String? notes,
      String targetCurrency,
      DateTime requestedDeliveryDate,
      RfqStatus status});
}

/// @nodoc
class _$RfqRequestCopyWithImpl<$Res> implements $RfqRequestCopyWith<$Res> {
  _$RfqRequestCopyWithImpl(this._self, this._then);

  final RfqRequest _self;
  final $Res Function(RfqRequest) _then;

  /// Create a copy of RfqRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? lines = null,
    Object? notes = freezed,
    Object? targetCurrency = null,
    Object? requestedDeliveryDate = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      buyerId: null == buyerId
          ? _self.buyerId
          : buyerId // ignore: cast_nullable_to_non_nullable
              as String,
      lines: null == lines
          ? _self.lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<RfqLine>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      targetCurrency: null == targetCurrency
          ? _self.targetCurrency
          : targetCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      requestedDeliveryDate: null == requestedDeliveryDate
          ? _self.requestedDeliveryDate
          : requestedDeliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RfqStatus,
    ));
  }
}

/// Adds pattern-matching-related methods to [RfqRequest].
extension RfqRequestPatterns on RfqRequest {
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
    TResult Function(_RfqRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RfqRequest() when $default != null:
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
    TResult Function(_RfqRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqRequest():
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
    TResult? Function(_RfqRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqRequest() when $default != null:
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
            String buyerId,
            List<RfqLine> lines,
            String? notes,
            String targetCurrency,
            DateTime requestedDeliveryDate,
            RfqStatus status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RfqRequest() when $default != null:
        return $default(_that.id, _that.buyerId, _that.lines, _that.notes,
            _that.targetCurrency, _that.requestedDeliveryDate, _that.status);
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
            String buyerId,
            List<RfqLine> lines,
            String? notes,
            String targetCurrency,
            DateTime requestedDeliveryDate,
            RfqStatus status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqRequest():
        return $default(_that.id, _that.buyerId, _that.lines, _that.notes,
            _that.targetCurrency, _that.requestedDeliveryDate, _that.status);
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
            String buyerId,
            List<RfqLine> lines,
            String? notes,
            String targetCurrency,
            DateTime requestedDeliveryDate,
            RfqStatus status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RfqRequest() when $default != null:
        return $default(_that.id, _that.buyerId, _that.lines, _that.notes,
            _that.targetCurrency, _that.requestedDeliveryDate, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RfqRequest implements RfqRequest {
  const _RfqRequest(
      {required this.id,
      required this.buyerId,
      required final List<RfqLine> lines,
      this.notes,
      required this.targetCurrency,
      required this.requestedDeliveryDate,
      this.status = RfqStatus.draft})
      : _lines = lines;
  factory _RfqRequest.fromJson(Map<String, dynamic> json) =>
      _$RfqRequestFromJson(json);

  @override
  final String id;
  @override
  final String buyerId;
  final List<RfqLine> _lines;
  @override
  List<RfqLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  final String? notes;
  @override
  final String targetCurrency;
  @override
  final DateTime requestedDeliveryDate;
  @override
  @JsonKey()
  final RfqStatus status;

  /// Create a copy of RfqRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RfqRequestCopyWith<_RfqRequest> get copyWith =>
      __$RfqRequestCopyWithImpl<_RfqRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RfqRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RfqRequest &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            const DeepCollectionEquality().equals(other._lines, _lines) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.targetCurrency, targetCurrency) ||
                other.targetCurrency == targetCurrency) &&
            (identical(other.requestedDeliveryDate, requestedDeliveryDate) ||
                other.requestedDeliveryDate == requestedDeliveryDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      buyerId,
      const DeepCollectionEquality().hash(_lines),
      notes,
      targetCurrency,
      requestedDeliveryDate,
      status);

  @override
  String toString() {
    return 'RfqRequest(id: $id, buyerId: $buyerId, lines: $lines, notes: $notes, targetCurrency: $targetCurrency, requestedDeliveryDate: $requestedDeliveryDate, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$RfqRequestCopyWith<$Res>
    implements $RfqRequestCopyWith<$Res> {
  factory _$RfqRequestCopyWith(
          _RfqRequest value, $Res Function(_RfqRequest) _then) =
      __$RfqRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String buyerId,
      List<RfqLine> lines,
      String? notes,
      String targetCurrency,
      DateTime requestedDeliveryDate,
      RfqStatus status});
}

/// @nodoc
class __$RfqRequestCopyWithImpl<$Res> implements _$RfqRequestCopyWith<$Res> {
  __$RfqRequestCopyWithImpl(this._self, this._then);

  final _RfqRequest _self;
  final $Res Function(_RfqRequest) _then;

  /// Create a copy of RfqRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? buyerId = null,
    Object? lines = null,
    Object? notes = freezed,
    Object? targetCurrency = null,
    Object? requestedDeliveryDate = null,
    Object? status = null,
  }) {
    return _then(_RfqRequest(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      buyerId: null == buyerId
          ? _self.buyerId
          : buyerId // ignore: cast_nullable_to_non_nullable
              as String,
      lines: null == lines
          ? _self._lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<RfqLine>,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      targetCurrency: null == targetCurrency
          ? _self.targetCurrency
          : targetCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      requestedDeliveryDate: null == requestedDeliveryDate
          ? _self.requestedDeliveryDate
          : requestedDeliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RfqStatus,
    ));
  }
}

/// @nodoc
mixin _$Quote {
  String get id;
  String get rfqId;
  String get vendorId;
  DateTime get validUntil;
  String get currency;
  List<QuoteLine> get lines;
  String? get terms;
  int get version;

  /// Create a copy of Quote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuoteCopyWith<Quote> get copyWith =>
      _$QuoteCopyWithImpl<Quote>(this as Quote, _$identity);

  /// Serializes this Quote to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Quote &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rfqId, rfqId) || other.rfqId == rfqId) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality().equals(other.lines, lines) &&
            (identical(other.terms, terms) || other.terms == terms) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, rfqId, vendorId, validUntil,
      currency, const DeepCollectionEquality().hash(lines), terms, version);

  @override
  String toString() {
    return 'Quote(id: $id, rfqId: $rfqId, vendorId: $vendorId, validUntil: $validUntil, currency: $currency, lines: $lines, terms: $terms, version: $version)';
  }
}

/// @nodoc
abstract mixin class $QuoteCopyWith<$Res> {
  factory $QuoteCopyWith(Quote value, $Res Function(Quote) _then) =
      _$QuoteCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String rfqId,
      String vendorId,
      DateTime validUntil,
      String currency,
      List<QuoteLine> lines,
      String? terms,
      int version});
}

/// @nodoc
class _$QuoteCopyWithImpl<$Res> implements $QuoteCopyWith<$Res> {
  _$QuoteCopyWithImpl(this._self, this._then);

  final Quote _self;
  final $Res Function(Quote) _then;

  /// Create a copy of Quote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rfqId = null,
    Object? vendorId = null,
    Object? validUntil = null,
    Object? currency = null,
    Object? lines = null,
    Object? terms = freezed,
    Object? version = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rfqId: null == rfqId
          ? _self.rfqId
          : rfqId // ignore: cast_nullable_to_non_nullable
              as String,
      vendorId: null == vendorId
          ? _self.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      validUntil: null == validUntil
          ? _self.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      lines: null == lines
          ? _self.lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<QuoteLine>,
      terms: freezed == terms
          ? _self.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as String?,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Quote].
extension QuotePatterns on Quote {
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
    TResult Function(_Quote value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Quote() when $default != null:
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
    TResult Function(_Quote value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Quote():
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
    TResult? Function(_Quote value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Quote() when $default != null:
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
            String rfqId,
            String vendorId,
            DateTime validUntil,
            String currency,
            List<QuoteLine> lines,
            String? terms,
            int version)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Quote() when $default != null:
        return $default(_that.id, _that.rfqId, _that.vendorId, _that.validUntil,
            _that.currency, _that.lines, _that.terms, _that.version);
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
            String rfqId,
            String vendorId,
            DateTime validUntil,
            String currency,
            List<QuoteLine> lines,
            String? terms,
            int version)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Quote():
        return $default(_that.id, _that.rfqId, _that.vendorId, _that.validUntil,
            _that.currency, _that.lines, _that.terms, _that.version);
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
            String rfqId,
            String vendorId,
            DateTime validUntil,
            String currency,
            List<QuoteLine> lines,
            String? terms,
            int version)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Quote() when $default != null:
        return $default(_that.id, _that.rfqId, _that.vendorId, _that.validUntil,
            _that.currency, _that.lines, _that.terms, _that.version);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Quote implements Quote {
  const _Quote(
      {required this.id,
      required this.rfqId,
      required this.vendorId,
      required this.validUntil,
      required this.currency,
      required final List<QuoteLine> lines,
      this.terms,
      this.version = 1})
      : _lines = lines;
  factory _Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  @override
  final String id;
  @override
  final String rfqId;
  @override
  final String vendorId;
  @override
  final DateTime validUntil;
  @override
  final String currency;
  final List<QuoteLine> _lines;
  @override
  List<QuoteLine> get lines {
    if (_lines is EqualUnmodifiableListView) return _lines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lines);
  }

  @override
  final String? terms;
  @override
  @JsonKey()
  final int version;

  /// Create a copy of Quote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuoteCopyWith<_Quote> get copyWith =>
      __$QuoteCopyWithImpl<_Quote>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuoteToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Quote &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rfqId, rfqId) || other.rfqId == rfqId) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality().equals(other._lines, _lines) &&
            (identical(other.terms, terms) || other.terms == terms) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, rfqId, vendorId, validUntil,
      currency, const DeepCollectionEquality().hash(_lines), terms, version);

  @override
  String toString() {
    return 'Quote(id: $id, rfqId: $rfqId, vendorId: $vendorId, validUntil: $validUntil, currency: $currency, lines: $lines, terms: $terms, version: $version)';
  }
}

/// @nodoc
abstract mixin class _$QuoteCopyWith<$Res> implements $QuoteCopyWith<$Res> {
  factory _$QuoteCopyWith(_Quote value, $Res Function(_Quote) _then) =
      __$QuoteCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String rfqId,
      String vendorId,
      DateTime validUntil,
      String currency,
      List<QuoteLine> lines,
      String? terms,
      int version});
}

/// @nodoc
class __$QuoteCopyWithImpl<$Res> implements _$QuoteCopyWith<$Res> {
  __$QuoteCopyWithImpl(this._self, this._then);

  final _Quote _self;
  final $Res Function(_Quote) _then;

  /// Create a copy of Quote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? rfqId = null,
    Object? vendorId = null,
    Object? validUntil = null,
    Object? currency = null,
    Object? lines = null,
    Object? terms = freezed,
    Object? version = null,
  }) {
    return _then(_Quote(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rfqId: null == rfqId
          ? _self.rfqId
          : rfqId // ignore: cast_nullable_to_non_nullable
              as String,
      vendorId: null == vendorId
          ? _self.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String,
      validUntil: null == validUntil
          ? _self.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currency: null == currency
          ? _self.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      lines: null == lines
          ? _self._lines
          : lines // ignore: cast_nullable_to_non_nullable
              as List<QuoteLine>,
      terms: freezed == terms
          ? _self.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as String?,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
