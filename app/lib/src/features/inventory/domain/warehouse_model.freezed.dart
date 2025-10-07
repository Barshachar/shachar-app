// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'warehouse_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Warehouse {
  String get id;
  String get name;
  String get code;
  String? get address;
  bool get active;
  DateTime? get createdAt;

  /// Create a copy of Warehouse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WarehouseCopyWith<Warehouse> get copyWith =>
      _$WarehouseCopyWithImpl<Warehouse>(this as Warehouse, _$identity);

  /// Serializes this Warehouse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Warehouse &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, code, address, active, createdAt);

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, code: $code, address: $address, active: $active, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $WarehouseCopyWith<$Res> {
  factory $WarehouseCopyWith(Warehouse value, $Res Function(Warehouse) _then) =
      _$WarehouseCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      String? address,
      bool active,
      DateTime? createdAt});
}

/// @nodoc
class _$WarehouseCopyWithImpl<$Res> implements $WarehouseCopyWith<$Res> {
  _$WarehouseCopyWithImpl(this._self, this._then);

  final Warehouse _self;
  final $Res Function(Warehouse) _then;

  /// Create a copy of Warehouse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? address = freezed,
    Object? active = null,
    Object? createdAt = freezed,
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
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Warehouse].
extension WarehousePatterns on Warehouse {
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
    TResult Function(_Warehouse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Warehouse() when $default != null:
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
    TResult Function(_Warehouse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Warehouse():
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
    TResult? Function(_Warehouse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Warehouse() when $default != null:
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
    TResult Function(String id, String name, String code, String? address,
            bool active, DateTime? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Warehouse() when $default != null:
        return $default(_that.id, _that.name, _that.code, _that.address,
            _that.active, _that.createdAt);
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
    TResult Function(String id, String name, String code, String? address,
            bool active, DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Warehouse():
        return $default(_that.id, _that.name, _that.code, _that.address,
            _that.active, _that.createdAt);
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
    TResult? Function(String id, String name, String code, String? address,
            bool active, DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Warehouse() when $default != null:
        return $default(_that.id, _that.name, _that.code, _that.address,
            _that.active, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Warehouse implements Warehouse {
  const _Warehouse(
      {required this.id,
      required this.name,
      required this.code,
      this.address,
      required this.active,
      this.createdAt});
  factory _Warehouse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String? address;
  @override
  final bool active;
  @override
  final DateTime? createdAt;

  /// Create a copy of Warehouse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WarehouseCopyWith<_Warehouse> get copyWith =>
      __$WarehouseCopyWithImpl<_Warehouse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WarehouseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Warehouse &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, code, address, active, createdAt);

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, code: $code, address: $address, active: $active, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$WarehouseCopyWith<$Res>
    implements $WarehouseCopyWith<$Res> {
  factory _$WarehouseCopyWith(
          _Warehouse value, $Res Function(_Warehouse) _then) =
      __$WarehouseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      String? address,
      bool active,
      DateTime? createdAt});
}

/// @nodoc
class __$WarehouseCopyWithImpl<$Res> implements _$WarehouseCopyWith<$Res> {
  __$WarehouseCopyWithImpl(this._self, this._then);

  final _Warehouse _self;
  final $Res Function(_Warehouse) _then;

  /// Create a copy of Warehouse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? address = freezed,
    Object? active = null,
    Object? createdAt = freezed,
  }) {
    return _then(_Warehouse(
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
      address: freezed == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$WarehouseInventory {
  String get warehouseId;
  String get variantId;
  double get qty;
  double get lowStockThreshold;
  DateTime? get inboundEta;
  bool get backorderAllowed;
  DateTime? get updatedAt;

  /// Create a copy of WarehouseInventory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WarehouseInventoryCopyWith<WarehouseInventory> get copyWith =>
      _$WarehouseInventoryCopyWithImpl<WarehouseInventory>(
          this as WarehouseInventory, _$identity);

  /// Serializes this WarehouseInventory to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WarehouseInventory &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.inboundEta, inboundEta) ||
                other.inboundEta == inboundEta) &&
            (identical(other.backorderAllowed, backorderAllowed) ||
                other.backorderAllowed == backorderAllowed) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, warehouseId, variantId, qty,
      lowStockThreshold, inboundEta, backorderAllowed, updatedAt);

  @override
  String toString() {
    return 'WarehouseInventory(warehouseId: $warehouseId, variantId: $variantId, qty: $qty, lowStockThreshold: $lowStockThreshold, inboundEta: $inboundEta, backorderAllowed: $backorderAllowed, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $WarehouseInventoryCopyWith<$Res> {
  factory $WarehouseInventoryCopyWith(
          WarehouseInventory value, $Res Function(WarehouseInventory) _then) =
      _$WarehouseInventoryCopyWithImpl;
  @useResult
  $Res call(
      {String warehouseId,
      String variantId,
      double qty,
      double lowStockThreshold,
      DateTime? inboundEta,
      bool backorderAllowed,
      DateTime? updatedAt});
}

/// @nodoc
class _$WarehouseInventoryCopyWithImpl<$Res>
    implements $WarehouseInventoryCopyWith<$Res> {
  _$WarehouseInventoryCopyWithImpl(this._self, this._then);

  final WarehouseInventory _self;
  final $Res Function(WarehouseInventory) _then;

  /// Create a copy of WarehouseInventory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? warehouseId = null,
    Object? variantId = null,
    Object? qty = null,
    Object? lowStockThreshold = null,
    Object? inboundEta = freezed,
    Object? backorderAllowed = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      variantId: null == variantId
          ? _self.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String,
      qty: null == qty
          ? _self.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as double,
      lowStockThreshold: null == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      inboundEta: freezed == inboundEta
          ? _self.inboundEta
          : inboundEta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      backorderAllowed: null == backorderAllowed
          ? _self.backorderAllowed
          : backorderAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WarehouseInventory].
extension WarehouseInventoryPatterns on WarehouseInventory {
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
    TResult Function(_WarehouseInventory value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WarehouseInventory() when $default != null:
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
    TResult Function(_WarehouseInventory value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseInventory():
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
    TResult? Function(_WarehouseInventory value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseInventory() when $default != null:
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
            String warehouseId,
            String variantId,
            double qty,
            double lowStockThreshold,
            DateTime? inboundEta,
            bool backorderAllowed,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WarehouseInventory() when $default != null:
        return $default(
            _that.warehouseId,
            _that.variantId,
            _that.qty,
            _that.lowStockThreshold,
            _that.inboundEta,
            _that.backorderAllowed,
            _that.updatedAt);
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
            String warehouseId,
            String variantId,
            double qty,
            double lowStockThreshold,
            DateTime? inboundEta,
            bool backorderAllowed,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseInventory():
        return $default(
            _that.warehouseId,
            _that.variantId,
            _that.qty,
            _that.lowStockThreshold,
            _that.inboundEta,
            _that.backorderAllowed,
            _that.updatedAt);
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
            String warehouseId,
            String variantId,
            double qty,
            double lowStockThreshold,
            DateTime? inboundEta,
            bool backorderAllowed,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseInventory() when $default != null:
        return $default(
            _that.warehouseId,
            _that.variantId,
            _that.qty,
            _that.lowStockThreshold,
            _that.inboundEta,
            _that.backorderAllowed,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WarehouseInventory implements WarehouseInventory {
  const _WarehouseInventory(
      {required this.warehouseId,
      required this.variantId,
      required this.qty,
      required this.lowStockThreshold,
      this.inboundEta,
      this.backorderAllowed = false,
      this.updatedAt});
  factory _WarehouseInventory.fromJson(Map<String, dynamic> json) =>
      _$WarehouseInventoryFromJson(json);

  @override
  final String warehouseId;
  @override
  final String variantId;
  @override
  final double qty;
  @override
  final double lowStockThreshold;
  @override
  final DateTime? inboundEta;
  @override
  @JsonKey()
  final bool backorderAllowed;
  @override
  final DateTime? updatedAt;

  /// Create a copy of WarehouseInventory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WarehouseInventoryCopyWith<_WarehouseInventory> get copyWith =>
      __$WarehouseInventoryCopyWithImpl<_WarehouseInventory>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WarehouseInventoryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WarehouseInventory &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.inboundEta, inboundEta) ||
                other.inboundEta == inboundEta) &&
            (identical(other.backorderAllowed, backorderAllowed) ||
                other.backorderAllowed == backorderAllowed) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, warehouseId, variantId, qty,
      lowStockThreshold, inboundEta, backorderAllowed, updatedAt);

  @override
  String toString() {
    return 'WarehouseInventory(warehouseId: $warehouseId, variantId: $variantId, qty: $qty, lowStockThreshold: $lowStockThreshold, inboundEta: $inboundEta, backorderAllowed: $backorderAllowed, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$WarehouseInventoryCopyWith<$Res>
    implements $WarehouseInventoryCopyWith<$Res> {
  factory _$WarehouseInventoryCopyWith(
          _WarehouseInventory value, $Res Function(_WarehouseInventory) _then) =
      __$WarehouseInventoryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String warehouseId,
      String variantId,
      double qty,
      double lowStockThreshold,
      DateTime? inboundEta,
      bool backorderAllowed,
      DateTime? updatedAt});
}

/// @nodoc
class __$WarehouseInventoryCopyWithImpl<$Res>
    implements _$WarehouseInventoryCopyWith<$Res> {
  __$WarehouseInventoryCopyWithImpl(this._self, this._then);

  final _WarehouseInventory _self;
  final $Res Function(_WarehouseInventory) _then;

  /// Create a copy of WarehouseInventory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? warehouseId = null,
    Object? variantId = null,
    Object? qty = null,
    Object? lowStockThreshold = null,
    Object? inboundEta = freezed,
    Object? backorderAllowed = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_WarehouseInventory(
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      variantId: null == variantId
          ? _self.variantId
          : variantId // ignore: cast_nullable_to_non_nullable
              as String,
      qty: null == qty
          ? _self.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as double,
      lowStockThreshold: null == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      inboundEta: freezed == inboundEta
          ? _self.inboundEta
          : inboundEta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      backorderAllowed: null == backorderAllowed
          ? _self.backorderAllowed
          : backorderAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$InventoryStatus {
  double get totalQty;
  bool get inStock;
  bool get lowStock;
  DateTime? get earliestEta;
  bool get backorderAvailable;
  List<WarehouseInventory> get warehouseBreakdown;

  /// Create a copy of InventoryStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryStatusCopyWith<InventoryStatus> get copyWith =>
      _$InventoryStatusCopyWithImpl<InventoryStatus>(
          this as InventoryStatus, _$identity);

  /// Serializes this InventoryStatus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryStatus &&
            (identical(other.totalQty, totalQty) ||
                other.totalQty == totalQty) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.lowStock, lowStock) ||
                other.lowStock == lowStock) &&
            (identical(other.earliestEta, earliestEta) ||
                other.earliestEta == earliestEta) &&
            (identical(other.backorderAvailable, backorderAvailable) ||
                other.backorderAvailable == backorderAvailable) &&
            const DeepCollectionEquality()
                .equals(other.warehouseBreakdown, warehouseBreakdown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalQty,
      inStock,
      lowStock,
      earliestEta,
      backorderAvailable,
      const DeepCollectionEquality().hash(warehouseBreakdown));

  @override
  String toString() {
    return 'InventoryStatus(totalQty: $totalQty, inStock: $inStock, lowStock: $lowStock, earliestEta: $earliestEta, backorderAvailable: $backorderAvailable, warehouseBreakdown: $warehouseBreakdown)';
  }
}

/// @nodoc
abstract mixin class $InventoryStatusCopyWith<$Res> {
  factory $InventoryStatusCopyWith(
          InventoryStatus value, $Res Function(InventoryStatus) _then) =
      _$InventoryStatusCopyWithImpl;
  @useResult
  $Res call(
      {double totalQty,
      bool inStock,
      bool lowStock,
      DateTime? earliestEta,
      bool backorderAvailable,
      List<WarehouseInventory> warehouseBreakdown});
}

/// @nodoc
class _$InventoryStatusCopyWithImpl<$Res>
    implements $InventoryStatusCopyWith<$Res> {
  _$InventoryStatusCopyWithImpl(this._self, this._then);

  final InventoryStatus _self;
  final $Res Function(InventoryStatus) _then;

  /// Create a copy of InventoryStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalQty = null,
    Object? inStock = null,
    Object? lowStock = null,
    Object? earliestEta = freezed,
    Object? backorderAvailable = null,
    Object? warehouseBreakdown = null,
  }) {
    return _then(_self.copyWith(
      totalQty: null == totalQty
          ? _self.totalQty
          : totalQty // ignore: cast_nullable_to_non_nullable
              as double,
      inStock: null == inStock
          ? _self.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      lowStock: null == lowStock
          ? _self.lowStock
          : lowStock // ignore: cast_nullable_to_non_nullable
              as bool,
      earliestEta: freezed == earliestEta
          ? _self.earliestEta
          : earliestEta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      backorderAvailable: null == backorderAvailable
          ? _self.backorderAvailable
          : backorderAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      warehouseBreakdown: null == warehouseBreakdown
          ? _self.warehouseBreakdown
          : warehouseBreakdown // ignore: cast_nullable_to_non_nullable
              as List<WarehouseInventory>,
    ));
  }
}

/// Adds pattern-matching-related methods to [InventoryStatus].
extension InventoryStatusPatterns on InventoryStatus {
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
    TResult Function(_InventoryStatus value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventoryStatus() when $default != null:
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
    TResult Function(_InventoryStatus value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryStatus():
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
    TResult? Function(_InventoryStatus value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryStatus() when $default != null:
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
            double totalQty,
            bool inStock,
            bool lowStock,
            DateTime? earliestEta,
            bool backorderAvailable,
            List<WarehouseInventory> warehouseBreakdown)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventoryStatus() when $default != null:
        return $default(
            _that.totalQty,
            _that.inStock,
            _that.lowStock,
            _that.earliestEta,
            _that.backorderAvailable,
            _that.warehouseBreakdown);
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
            double totalQty,
            bool inStock,
            bool lowStock,
            DateTime? earliestEta,
            bool backorderAvailable,
            List<WarehouseInventory> warehouseBreakdown)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryStatus():
        return $default(
            _that.totalQty,
            _that.inStock,
            _that.lowStock,
            _that.earliestEta,
            _that.backorderAvailable,
            _that.warehouseBreakdown);
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
            double totalQty,
            bool inStock,
            bool lowStock,
            DateTime? earliestEta,
            bool backorderAvailable,
            List<WarehouseInventory> warehouseBreakdown)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryStatus() when $default != null:
        return $default(
            _that.totalQty,
            _that.inStock,
            _that.lowStock,
            _that.earliestEta,
            _that.backorderAvailable,
            _that.warehouseBreakdown);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryStatus implements InventoryStatus {
  const _InventoryStatus(
      {required this.totalQty,
      required this.inStock,
      required this.lowStock,
      this.earliestEta,
      this.backorderAvailable = false,
      required final List<WarehouseInventory> warehouseBreakdown})
      : _warehouseBreakdown = warehouseBreakdown;
  factory _InventoryStatus.fromJson(Map<String, dynamic> json) =>
      _$InventoryStatusFromJson(json);

  @override
  final double totalQty;
  @override
  final bool inStock;
  @override
  final bool lowStock;
  @override
  final DateTime? earliestEta;
  @override
  @JsonKey()
  final bool backorderAvailable;
  final List<WarehouseInventory> _warehouseBreakdown;
  @override
  List<WarehouseInventory> get warehouseBreakdown {
    if (_warehouseBreakdown is EqualUnmodifiableListView)
      return _warehouseBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warehouseBreakdown);
  }

  /// Create a copy of InventoryStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryStatusCopyWith<_InventoryStatus> get copyWith =>
      __$InventoryStatusCopyWithImpl<_InventoryStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryStatusToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryStatus &&
            (identical(other.totalQty, totalQty) ||
                other.totalQty == totalQty) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.lowStock, lowStock) ||
                other.lowStock == lowStock) &&
            (identical(other.earliestEta, earliestEta) ||
                other.earliestEta == earliestEta) &&
            (identical(other.backorderAvailable, backorderAvailable) ||
                other.backorderAvailable == backorderAvailable) &&
            const DeepCollectionEquality()
                .equals(other._warehouseBreakdown, _warehouseBreakdown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalQty,
      inStock,
      lowStock,
      earliestEta,
      backorderAvailable,
      const DeepCollectionEquality().hash(_warehouseBreakdown));

  @override
  String toString() {
    return 'InventoryStatus(totalQty: $totalQty, inStock: $inStock, lowStock: $lowStock, earliestEta: $earliestEta, backorderAvailable: $backorderAvailable, warehouseBreakdown: $warehouseBreakdown)';
  }
}

/// @nodoc
abstract mixin class _$InventoryStatusCopyWith<$Res>
    implements $InventoryStatusCopyWith<$Res> {
  factory _$InventoryStatusCopyWith(
          _InventoryStatus value, $Res Function(_InventoryStatus) _then) =
      __$InventoryStatusCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double totalQty,
      bool inStock,
      bool lowStock,
      DateTime? earliestEta,
      bool backorderAvailable,
      List<WarehouseInventory> warehouseBreakdown});
}

/// @nodoc
class __$InventoryStatusCopyWithImpl<$Res>
    implements _$InventoryStatusCopyWith<$Res> {
  __$InventoryStatusCopyWithImpl(this._self, this._then);

  final _InventoryStatus _self;
  final $Res Function(_InventoryStatus) _then;

  /// Create a copy of InventoryStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalQty = null,
    Object? inStock = null,
    Object? lowStock = null,
    Object? earliestEta = freezed,
    Object? backorderAvailable = null,
    Object? warehouseBreakdown = null,
  }) {
    return _then(_InventoryStatus(
      totalQty: null == totalQty
          ? _self.totalQty
          : totalQty // ignore: cast_nullable_to_non_nullable
              as double,
      inStock: null == inStock
          ? _self.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      lowStock: null == lowStock
          ? _self.lowStock
          : lowStock // ignore: cast_nullable_to_non_nullable
              as bool,
      earliestEta: freezed == earliestEta
          ? _self.earliestEta
          : earliestEta // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      backorderAvailable: null == backorderAvailable
          ? _self.backorderAvailable
          : backorderAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      warehouseBreakdown: null == warehouseBreakdown
          ? _self._warehouseBreakdown
          : warehouseBreakdown // ignore: cast_nullable_to_non_nullable
              as List<WarehouseInventory>,
    ));
  }
}

/// @nodoc
mixin _$WarehouseZone {
  String get id;
  @JsonKey(name: 'warehouse_id')
  String get warehouseId;
  String get name;
  @JsonKey(name: 'sort_order')
  int get sortOrder;

  /// Create a copy of WarehouseZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WarehouseZoneCopyWith<WarehouseZone> get copyWith =>
      _$WarehouseZoneCopyWithImpl<WarehouseZone>(
          this as WarehouseZone, _$identity);

  /// Serializes this WarehouseZone to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WarehouseZone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, warehouseId, name, sortOrder);

  @override
  String toString() {
    return 'WarehouseZone(id: $id, warehouseId: $warehouseId, name: $name, sortOrder: $sortOrder)';
  }
}

/// @nodoc
abstract mixin class $WarehouseZoneCopyWith<$Res> {
  factory $WarehouseZoneCopyWith(
          WarehouseZone value, $Res Function(WarehouseZone) _then) =
      _$WarehouseZoneCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'warehouse_id') String warehouseId,
      String name,
      @JsonKey(name: 'sort_order') int sortOrder});
}

/// @nodoc
class _$WarehouseZoneCopyWithImpl<$Res>
    implements $WarehouseZoneCopyWith<$Res> {
  _$WarehouseZoneCopyWithImpl(this._self, this._then);

  final WarehouseZone _self;
  final $Res Function(WarehouseZone) _then;

  /// Create a copy of WarehouseZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? warehouseId = null,
    Object? name = null,
    Object? sortOrder = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [WarehouseZone].
extension WarehouseZonePatterns on WarehouseZone {
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
    TResult Function(_WarehouseZone value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WarehouseZone() when $default != null:
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
    TResult Function(_WarehouseZone value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseZone():
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
    TResult? Function(_WarehouseZone value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseZone() when $default != null:
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
            @JsonKey(name: 'warehouse_id') String warehouseId,
            String name,
            @JsonKey(name: 'sort_order') int sortOrder)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WarehouseZone() when $default != null:
        return $default(
            _that.id, _that.warehouseId, _that.name, _that.sortOrder);
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
            @JsonKey(name: 'warehouse_id') String warehouseId,
            String name,
            @JsonKey(name: 'sort_order') int sortOrder)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseZone():
        return $default(
            _that.id, _that.warehouseId, _that.name, _that.sortOrder);
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
            @JsonKey(name: 'warehouse_id') String warehouseId,
            String name,
            @JsonKey(name: 'sort_order') int sortOrder)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseZone() when $default != null:
        return $default(
            _that.id, _that.warehouseId, _that.name, _that.sortOrder);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WarehouseZone implements WarehouseZone {
  const _WarehouseZone(
      {required this.id,
      @JsonKey(name: 'warehouse_id') required this.warehouseId,
      required this.name,
      @JsonKey(name: 'sort_order') this.sortOrder = 0});
  factory _WarehouseZone.fromJson(Map<String, dynamic> json) =>
      _$WarehouseZoneFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'warehouse_id')
  final String warehouseId;
  @override
  final String name;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  /// Create a copy of WarehouseZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WarehouseZoneCopyWith<_WarehouseZone> get copyWith =>
      __$WarehouseZoneCopyWithImpl<_WarehouseZone>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WarehouseZoneToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WarehouseZone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.warehouseId, warehouseId) ||
                other.warehouseId == warehouseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, warehouseId, name, sortOrder);

  @override
  String toString() {
    return 'WarehouseZone(id: $id, warehouseId: $warehouseId, name: $name, sortOrder: $sortOrder)';
  }
}

/// @nodoc
abstract mixin class _$WarehouseZoneCopyWith<$Res>
    implements $WarehouseZoneCopyWith<$Res> {
  factory _$WarehouseZoneCopyWith(
          _WarehouseZone value, $Res Function(_WarehouseZone) _then) =
      __$WarehouseZoneCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'warehouse_id') String warehouseId,
      String name,
      @JsonKey(name: 'sort_order') int sortOrder});
}

/// @nodoc
class __$WarehouseZoneCopyWithImpl<$Res>
    implements _$WarehouseZoneCopyWith<$Res> {
  __$WarehouseZoneCopyWithImpl(this._self, this._then);

  final _WarehouseZone _self;
  final $Res Function(_WarehouseZone) _then;

  /// Create a copy of WarehouseZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? warehouseId = null,
    Object? name = null,
    Object? sortOrder = null,
  }) {
    return _then(_WarehouseZone(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      warehouseId: null == warehouseId
          ? _self.warehouseId
          : warehouseId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$WarehouseBin {
  String get id;
  @JsonKey(name: 'zone_id')
  String get zoneId;
  String get aisle;
  String get bin;
  @JsonKey(name: 'fill_state')
  WarehouseBinFill get fillState;
  @JsonKey(name: 'current_qty')
  double get currentQty;
  double? get capacity;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of WarehouseBin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WarehouseBinCopyWith<WarehouseBin> get copyWith =>
      _$WarehouseBinCopyWithImpl<WarehouseBin>(
          this as WarehouseBin, _$identity);

  /// Serializes this WarehouseBin to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WarehouseBin &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.aisle, aisle) || other.aisle == aisle) &&
            (identical(other.bin, bin) || other.bin == bin) &&
            (identical(other.fillState, fillState) ||
                other.fillState == fillState) &&
            (identical(other.currentQty, currentQty) ||
                other.currentQty == currentQty) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, zoneId, aisle, bin,
      fillState, currentQty, capacity, updatedAt);

  @override
  String toString() {
    return 'WarehouseBin(id: $id, zoneId: $zoneId, aisle: $aisle, bin: $bin, fillState: $fillState, currentQty: $currentQty, capacity: $capacity, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $WarehouseBinCopyWith<$Res> {
  factory $WarehouseBinCopyWith(
          WarehouseBin value, $Res Function(WarehouseBin) _then) =
      _$WarehouseBinCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'zone_id') String zoneId,
      String aisle,
      String bin,
      @JsonKey(name: 'fill_state') WarehouseBinFill fillState,
      @JsonKey(name: 'current_qty') double currentQty,
      double? capacity,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$WarehouseBinCopyWithImpl<$Res> implements $WarehouseBinCopyWith<$Res> {
  _$WarehouseBinCopyWithImpl(this._self, this._then);

  final WarehouseBin _self;
  final $Res Function(WarehouseBin) _then;

  /// Create a copy of WarehouseBin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? zoneId = null,
    Object? aisle = null,
    Object? bin = null,
    Object? fillState = null,
    Object? currentQty = null,
    Object? capacity = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _self.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      aisle: null == aisle
          ? _self.aisle
          : aisle // ignore: cast_nullable_to_non_nullable
              as String,
      bin: null == bin
          ? _self.bin
          : bin // ignore: cast_nullable_to_non_nullable
              as String,
      fillState: null == fillState
          ? _self.fillState
          : fillState // ignore: cast_nullable_to_non_nullable
              as WarehouseBinFill,
      currentQty: null == currentQty
          ? _self.currentQty
          : currentQty // ignore: cast_nullable_to_non_nullable
              as double,
      capacity: freezed == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as double?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WarehouseBin].
extension WarehouseBinPatterns on WarehouseBin {
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
    TResult Function(_WarehouseBin value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WarehouseBin() when $default != null:
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
    TResult Function(_WarehouseBin value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseBin():
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
    TResult? Function(_WarehouseBin value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseBin() when $default != null:
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
            @JsonKey(name: 'zone_id') String zoneId,
            String aisle,
            String bin,
            @JsonKey(name: 'fill_state') WarehouseBinFill fillState,
            @JsonKey(name: 'current_qty') double currentQty,
            double? capacity,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WarehouseBin() when $default != null:
        return $default(_that.id, _that.zoneId, _that.aisle, _that.bin,
            _that.fillState, _that.currentQty, _that.capacity, _that.updatedAt);
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
            @JsonKey(name: 'zone_id') String zoneId,
            String aisle,
            String bin,
            @JsonKey(name: 'fill_state') WarehouseBinFill fillState,
            @JsonKey(name: 'current_qty') double currentQty,
            double? capacity,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseBin():
        return $default(_that.id, _that.zoneId, _that.aisle, _that.bin,
            _that.fillState, _that.currentQty, _that.capacity, _that.updatedAt);
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
            @JsonKey(name: 'zone_id') String zoneId,
            String aisle,
            String bin,
            @JsonKey(name: 'fill_state') WarehouseBinFill fillState,
            @JsonKey(name: 'current_qty') double currentQty,
            double? capacity,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WarehouseBin() when $default != null:
        return $default(_that.id, _that.zoneId, _that.aisle, _that.bin,
            _that.fillState, _that.currentQty, _that.capacity, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WarehouseBin extends WarehouseBin {
  const _WarehouseBin(
      {required this.id,
      @JsonKey(name: 'zone_id') required this.zoneId,
      required this.aisle,
      required this.bin,
      @JsonKey(name: 'fill_state') required this.fillState,
      @JsonKey(name: 'current_qty') this.currentQty = 0,
      this.capacity,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();
  factory _WarehouseBin.fromJson(Map<String, dynamic> json) =>
      _$WarehouseBinFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'zone_id')
  final String zoneId;
  @override
  final String aisle;
  @override
  final String bin;
  @override
  @JsonKey(name: 'fill_state')
  final WarehouseBinFill fillState;
  @override
  @JsonKey(name: 'current_qty')
  final double currentQty;
  @override
  final double? capacity;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of WarehouseBin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WarehouseBinCopyWith<_WarehouseBin> get copyWith =>
      __$WarehouseBinCopyWithImpl<_WarehouseBin>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WarehouseBinToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WarehouseBin &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.aisle, aisle) || other.aisle == aisle) &&
            (identical(other.bin, bin) || other.bin == bin) &&
            (identical(other.fillState, fillState) ||
                other.fillState == fillState) &&
            (identical(other.currentQty, currentQty) ||
                other.currentQty == currentQty) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, zoneId, aisle, bin,
      fillState, currentQty, capacity, updatedAt);

  @override
  String toString() {
    return 'WarehouseBin(id: $id, zoneId: $zoneId, aisle: $aisle, bin: $bin, fillState: $fillState, currentQty: $currentQty, capacity: $capacity, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$WarehouseBinCopyWith<$Res>
    implements $WarehouseBinCopyWith<$Res> {
  factory _$WarehouseBinCopyWith(
          _WarehouseBin value, $Res Function(_WarehouseBin) _then) =
      __$WarehouseBinCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'zone_id') String zoneId,
      String aisle,
      String bin,
      @JsonKey(name: 'fill_state') WarehouseBinFill fillState,
      @JsonKey(name: 'current_qty') double currentQty,
      double? capacity,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$WarehouseBinCopyWithImpl<$Res>
    implements _$WarehouseBinCopyWith<$Res> {
  __$WarehouseBinCopyWithImpl(this._self, this._then);

  final _WarehouseBin _self;
  final $Res Function(_WarehouseBin) _then;

  /// Create a copy of WarehouseBin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? zoneId = null,
    Object? aisle = null,
    Object? bin = null,
    Object? fillState = null,
    Object? currentQty = null,
    Object? capacity = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_WarehouseBin(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      zoneId: null == zoneId
          ? _self.zoneId
          : zoneId // ignore: cast_nullable_to_non_nullable
              as String,
      aisle: null == aisle
          ? _self.aisle
          : aisle // ignore: cast_nullable_to_non_nullable
              as String,
      bin: null == bin
          ? _self.bin
          : bin // ignore: cast_nullable_to_non_nullable
              as String,
      fillState: null == fillState
          ? _self.fillState
          : fillState // ignore: cast_nullable_to_non_nullable
              as WarehouseBinFill,
      currentQty: null == currentQty
          ? _self.currentQty
          : currentQty // ignore: cast_nullable_to_non_nullable
              as double,
      capacity: freezed == capacity
          ? _self.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as double?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
