// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Category {
  String get id;
  String get nameHe;
  String get nameEn;
  String? get parentId;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<Category> get copyWith =>
      _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Category &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameHe, nameEn, parentId);

  @override
  String toString() {
    return 'Category(id: $id, nameHe: $nameHe, nameEn: $nameEn, parentId: $parentId)';
  }
}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) =
      _$CategoryCopyWithImpl;
  @useResult
  $Res call({String id, String nameHe, String nameEn, String? parentId});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res> implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameHe = null,
    Object? nameEn = null,
    Object? parentId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _self.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _self.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _self.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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
    TResult Function(_Category value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
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
    TResult Function(_Category value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category():
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
    TResult? Function(_Category value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
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
    TResult Function(String id, String nameHe, String nameEn, String? parentId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
        return $default(_that.id, _that.nameHe, _that.nameEn, _that.parentId);
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
    TResult Function(String id, String nameHe, String nameEn, String? parentId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category():
        return $default(_that.id, _that.nameHe, _that.nameEn, _that.parentId);
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
            String id, String nameHe, String nameEn, String? parentId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Category() when $default != null:
        return $default(_that.id, _that.nameHe, _that.nameEn, _that.parentId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Category implements Category {
  const _Category(
      {required this.id,
      required this.nameHe,
      required this.nameEn,
      this.parentId});
  factory _Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  @override
  final String id;
  @override
  final String nameHe;
  @override
  final String nameEn;
  @override
  final String? parentId;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CategoryCopyWith<_Category> get copyWith =>
      __$CategoryCopyWithImpl<_Category>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CategoryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Category &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameHe, nameEn, parentId);

  @override
  String toString() {
    return 'Category(id: $id, nameHe: $nameHe, nameEn: $nameEn, parentId: $parentId)';
  }
}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) =
      __$CategoryCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String nameHe, String nameEn, String? parentId});
}

/// @nodoc
class __$CategoryCopyWithImpl<$Res> implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? nameHe = null,
    Object? nameEn = null,
    Object? parentId = freezed,
  }) {
    return _then(_Category(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _self.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _self.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _self.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Product {
  String get id;
  String get vendorCompanyId;
  String get sku;
  String get nameHe;
  String get nameEn;
  bool get active;
  String get uom;
  int get packSize;
  int get moq;
  int get leadTime;
  List<ProductVariant> get variants;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProductCopyWith<Product> get copyWith =>
      _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Product &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorCompanyId, vendorCompanyId) ||
                other.vendorCompanyId == vendorCompanyId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.packSize, packSize) ||
                other.packSize == packSize) &&
            (identical(other.moq, moq) || other.moq == moq) &&
            (identical(other.leadTime, leadTime) ||
                other.leadTime == leadTime) &&
            const DeepCollectionEquality().equals(other.variants, variants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      vendorCompanyId,
      sku,
      nameHe,
      nameEn,
      active,
      uom,
      packSize,
      moq,
      leadTime,
      const DeepCollectionEquality().hash(variants));

  @override
  String toString() {
    return 'Product(id: $id, vendorCompanyId: $vendorCompanyId, sku: $sku, nameHe: $nameHe, nameEn: $nameEn, active: $active, uom: $uom, packSize: $packSize, moq: $moq, leadTime: $leadTime, variants: $variants)';
  }
}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) =
      _$ProductCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String vendorCompanyId,
      String sku,
      String nameHe,
      String nameEn,
      bool active,
      String uom,
      int packSize,
      int moq,
      int leadTime,
      List<ProductVariant> variants});
}

/// @nodoc
class _$ProductCopyWithImpl<$Res> implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorCompanyId = null,
    Object? sku = null,
    Object? nameHe = null,
    Object? nameEn = null,
    Object? active = null,
    Object? uom = null,
    Object? packSize = null,
    Object? moq = null,
    Object? leadTime = null,
    Object? variants = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vendorCompanyId: null == vendorCompanyId
          ? _self.vendorCompanyId
          : vendorCompanyId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _self.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _self.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _self.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      packSize: null == packSize
          ? _self.packSize
          : packSize // ignore: cast_nullable_to_non_nullable
              as int,
      moq: null == moq
          ? _self.moq
          : moq // ignore: cast_nullable_to_non_nullable
              as int,
      leadTime: null == leadTime
          ? _self.leadTime
          : leadTime // ignore: cast_nullable_to_non_nullable
              as int,
      variants: null == variants
          ? _self.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<ProductVariant>,
    ));
  }
}

/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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
    TResult Function(_Product value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Product() when $default != null:
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
    TResult Function(_Product value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Product():
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
    TResult? Function(_Product value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Product() when $default != null:
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
            String vendorCompanyId,
            String sku,
            String nameHe,
            String nameEn,
            bool active,
            String uom,
            int packSize,
            int moq,
            int leadTime,
            List<ProductVariant> variants)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Product() when $default != null:
        return $default(
            _that.id,
            _that.vendorCompanyId,
            _that.sku,
            _that.nameHe,
            _that.nameEn,
            _that.active,
            _that.uom,
            _that.packSize,
            _that.moq,
            _that.leadTime,
            _that.variants);
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
            String vendorCompanyId,
            String sku,
            String nameHe,
            String nameEn,
            bool active,
            String uom,
            int packSize,
            int moq,
            int leadTime,
            List<ProductVariant> variants)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Product():
        return $default(
            _that.id,
            _that.vendorCompanyId,
            _that.sku,
            _that.nameHe,
            _that.nameEn,
            _that.active,
            _that.uom,
            _that.packSize,
            _that.moq,
            _that.leadTime,
            _that.variants);
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
            String vendorCompanyId,
            String sku,
            String nameHe,
            String nameEn,
            bool active,
            String uom,
            int packSize,
            int moq,
            int leadTime,
            List<ProductVariant> variants)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Product() when $default != null:
        return $default(
            _that.id,
            _that.vendorCompanyId,
            _that.sku,
            _that.nameHe,
            _that.nameEn,
            _that.active,
            _that.uom,
            _that.packSize,
            _that.moq,
            _that.leadTime,
            _that.variants);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Product implements Product {
  const _Product(
      {required this.id,
      required this.vendorCompanyId,
      required this.sku,
      required this.nameHe,
      required this.nameEn,
      required this.active,
      required this.uom,
      required this.packSize,
      required this.moq,
      required this.leadTime,
      required final List<ProductVariant> variants})
      : _variants = variants;
  factory _Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  @override
  final String id;
  @override
  final String vendorCompanyId;
  @override
  final String sku;
  @override
  final String nameHe;
  @override
  final String nameEn;
  @override
  final bool active;
  @override
  final String uom;
  @override
  final int packSize;
  @override
  final int moq;
  @override
  final int leadTime;
  final List<ProductVariant> _variants;
  @override
  List<ProductVariant> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProductCopyWith<_Product> get copyWith =>
      __$ProductCopyWithImpl<_Product>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProductToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Product &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorCompanyId, vendorCompanyId) ||
                other.vendorCompanyId == vendorCompanyId) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.nameHe, nameHe) || other.nameHe == nameHe) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.packSize, packSize) ||
                other.packSize == packSize) &&
            (identical(other.moq, moq) || other.moq == moq) &&
            (identical(other.leadTime, leadTime) ||
                other.leadTime == leadTime) &&
            const DeepCollectionEquality().equals(other._variants, _variants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      vendorCompanyId,
      sku,
      nameHe,
      nameEn,
      active,
      uom,
      packSize,
      moq,
      leadTime,
      const DeepCollectionEquality().hash(_variants));

  @override
  String toString() {
    return 'Product(id: $id, vendorCompanyId: $vendorCompanyId, sku: $sku, nameHe: $nameHe, nameEn: $nameEn, active: $active, uom: $uom, packSize: $packSize, moq: $moq, leadTime: $leadTime, variants: $variants)';
  }
}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) =
      __$ProductCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String vendorCompanyId,
      String sku,
      String nameHe,
      String nameEn,
      bool active,
      String uom,
      int packSize,
      int moq,
      int leadTime,
      List<ProductVariant> variants});
}

/// @nodoc
class __$ProductCopyWithImpl<$Res> implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? vendorCompanyId = null,
    Object? sku = null,
    Object? nameHe = null,
    Object? nameEn = null,
    Object? active = null,
    Object? uom = null,
    Object? packSize = null,
    Object? moq = null,
    Object? leadTime = null,
    Object? variants = null,
  }) {
    return _then(_Product(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vendorCompanyId: null == vendorCompanyId
          ? _self.vendorCompanyId
          : vendorCompanyId // ignore: cast_nullable_to_non_nullable
              as String,
      sku: null == sku
          ? _self.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String,
      nameHe: null == nameHe
          ? _self.nameHe
          : nameHe // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _self.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      packSize: null == packSize
          ? _self.packSize
          : packSize // ignore: cast_nullable_to_non_nullable
              as int,
      moq: null == moq
          ? _self.moq
          : moq // ignore: cast_nullable_to_non_nullable
              as int,
      leadTime: null == leadTime
          ? _self.leadTime
          : leadTime // ignore: cast_nullable_to_non_nullable
              as int,
      variants: null == variants
          ? _self._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<ProductVariant>,
    ));
  }
}

/// @nodoc
mixin _$ProductVariant {
  String get id;
  String get productId;
  Map<String, dynamic> get attributes;
  String? get barcode;
  bool get active;
  String get uom;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProductVariantCopyWith<ProductVariant> get copyWith =>
      _$ProductVariantCopyWithImpl<ProductVariant>(
          this as ProductVariant, _$identity);

  /// Serializes this ProductVariant to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProductVariant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            const DeepCollectionEquality()
                .equals(other.attributes, attributes) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.uom, uom) || other.uom == uom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, productId,
      const DeepCollectionEquality().hash(attributes), barcode, active, uom);

  @override
  String toString() {
    return 'ProductVariant(id: $id, productId: $productId, attributes: $attributes, barcode: $barcode, active: $active, uom: $uom)';
  }
}

/// @nodoc
abstract mixin class $ProductVariantCopyWith<$Res> {
  factory $ProductVariantCopyWith(
          ProductVariant value, $Res Function(ProductVariant) _then) =
      _$ProductVariantCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String productId,
      Map<String, dynamic> attributes,
      String? barcode,
      bool active,
      String uom});
}

/// @nodoc
class _$ProductVariantCopyWithImpl<$Res>
    implements $ProductVariantCopyWith<$Res> {
  _$ProductVariantCopyWithImpl(this._self, this._then);

  final ProductVariant _self;
  final $Res Function(ProductVariant) _then;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? attributes = null,
    Object? barcode = freezed,
    Object? active = null,
    Object? uom = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _self.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      barcode: freezed == barcode
          ? _self.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProductVariant].
extension ProductVariantPatterns on ProductVariant {
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
    TResult Function(_ProductVariant value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProductVariant() when $default != null:
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
    TResult Function(_ProductVariant value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductVariant():
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
    TResult? Function(_ProductVariant value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductVariant() when $default != null:
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
            String productId,
            Map<String, dynamic> attributes,
            String? barcode,
            bool active,
            String uom)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProductVariant() when $default != null:
        return $default(_that.id, _that.productId, _that.attributes,
            _that.barcode, _that.active, _that.uom);
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
            String productId,
            Map<String, dynamic> attributes,
            String? barcode,
            bool active,
            String uom)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductVariant():
        return $default(_that.id, _that.productId, _that.attributes,
            _that.barcode, _that.active, _that.uom);
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
            String productId,
            Map<String, dynamic> attributes,
            String? barcode,
            bool active,
            String uom)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductVariant() when $default != null:
        return $default(_that.id, _that.productId, _that.attributes,
            _that.barcode, _that.active, _that.uom);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ProductVariant implements ProductVariant {
  const _ProductVariant(
      {required this.id,
      required this.productId,
      required final Map<String, dynamic> attributes,
      this.barcode,
      required this.active,
      required this.uom})
      : _attributes = attributes;
  factory _ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);

  @override
  final String id;
  @override
  final String productId;
  final Map<String, dynamic> _attributes;
  @override
  Map<String, dynamic> get attributes {
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attributes);
  }

  @override
  final String? barcode;
  @override
  final bool active;
  @override
  final String uom;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProductVariantCopyWith<_ProductVariant> get copyWith =>
      __$ProductVariantCopyWithImpl<_ProductVariant>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProductVariantToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProductVariant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.uom, uom) || other.uom == uom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, productId,
      const DeepCollectionEquality().hash(_attributes), barcode, active, uom);

  @override
  String toString() {
    return 'ProductVariant(id: $id, productId: $productId, attributes: $attributes, barcode: $barcode, active: $active, uom: $uom)';
  }
}

/// @nodoc
abstract mixin class _$ProductVariantCopyWith<$Res>
    implements $ProductVariantCopyWith<$Res> {
  factory _$ProductVariantCopyWith(
          _ProductVariant value, $Res Function(_ProductVariant) _then) =
      __$ProductVariantCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      Map<String, dynamic> attributes,
      String? barcode,
      bool active,
      String uom});
}

/// @nodoc
class __$ProductVariantCopyWithImpl<$Res>
    implements _$ProductVariantCopyWith<$Res> {
  __$ProductVariantCopyWithImpl(this._self, this._then);

  final _ProductVariant _self;
  final $Res Function(_ProductVariant) _then;

  /// Create a copy of ProductVariant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? attributes = null,
    Object? barcode = freezed,
    Object? active = null,
    Object? uom = null,
  }) {
    return _then(_ProductVariant(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      attributes: null == attributes
          ? _self._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      barcode: freezed == barcode
          ? _self.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      active: null == active
          ? _self.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      uom: null == uom
          ? _self.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$PriceQuote {
  String get vendorId;
  String get variantId;
  String get currency;
  double get unitPrice;
  int get minQty;

  /// Create a copy of PriceQuote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PriceQuoteCopyWith<PriceQuote> get copyWith =>
      _$PriceQuoteCopyWithImpl<PriceQuote>(this as PriceQuote, _$identity);

  /// Serializes this PriceQuote to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PriceQuote &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.minQty, minQty) || other.minQty == minQty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, vendorId, variantId, currency, unitPrice, minQty);

  @override
  String toString() {
    return 'PriceQuote(vendorId: $vendorId, variantId: $variantId, currency: $currency, unitPrice: $unitPrice, minQty: $minQty)';
  }
}

/// @nodoc
abstract mixin class $PriceQuoteCopyWith<$Res> {
  factory $PriceQuoteCopyWith(
          PriceQuote value, $Res Function(PriceQuote) _then) =
      _$PriceQuoteCopyWithImpl;
  @useResult
  $Res call(
      {String vendorId,
      String variantId,
      String currency,
      double unitPrice,
      int minQty});
}

/// @nodoc
class _$PriceQuoteCopyWithImpl<$Res> implements $PriceQuoteCopyWith<$Res> {
  _$PriceQuoteCopyWithImpl(this._self, this._then);

  final PriceQuote _self;
  final $Res Function(PriceQuote) _then;

  /// Create a copy of PriceQuote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vendorId = null,
    Object? variantId = null,
    Object? currency = null,
    Object? unitPrice = null,
    Object? minQty = null,
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
      minQty: null == minQty
          ? _self.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PriceQuote].
extension PriceQuotePatterns on PriceQuote {
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
    TResult Function(_PriceQuote value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PriceQuote() when $default != null:
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
    TResult Function(_PriceQuote value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PriceQuote():
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
    TResult? Function(_PriceQuote value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PriceQuote() when $default != null:
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
            double unitPrice, int minQty)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PriceQuote() when $default != null:
        return $default(_that.vendorId, _that.variantId, _that.currency,
            _that.unitPrice, _that.minQty);
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
            double unitPrice, int minQty)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PriceQuote():
        return $default(_that.vendorId, _that.variantId, _that.currency,
            _that.unitPrice, _that.minQty);
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
            double unitPrice, int minQty)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PriceQuote() when $default != null:
        return $default(_that.vendorId, _that.variantId, _that.currency,
            _that.unitPrice, _that.minQty);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PriceQuote implements PriceQuote {
  const _PriceQuote(
      {required this.vendorId,
      required this.variantId,
      required this.currency,
      required this.unitPrice,
      required this.minQty});
  factory _PriceQuote.fromJson(Map<String, dynamic> json) =>
      _$PriceQuoteFromJson(json);

  @override
  final String vendorId;
  @override
  final String variantId;
  @override
  final String currency;
  @override
  final double unitPrice;
  @override
  final int minQty;

  /// Create a copy of PriceQuote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PriceQuoteCopyWith<_PriceQuote> get copyWith =>
      __$PriceQuoteCopyWithImpl<_PriceQuote>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PriceQuoteToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PriceQuote &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.variantId, variantId) ||
                other.variantId == variantId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.minQty, minQty) || other.minQty == minQty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, vendorId, variantId, currency, unitPrice, minQty);

  @override
  String toString() {
    return 'PriceQuote(vendorId: $vendorId, variantId: $variantId, currency: $currency, unitPrice: $unitPrice, minQty: $minQty)';
  }
}

/// @nodoc
abstract mixin class _$PriceQuoteCopyWith<$Res>
    implements $PriceQuoteCopyWith<$Res> {
  factory _$PriceQuoteCopyWith(
          _PriceQuote value, $Res Function(_PriceQuote) _then) =
      __$PriceQuoteCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String vendorId,
      String variantId,
      String currency,
      double unitPrice,
      int minQty});
}

/// @nodoc
class __$PriceQuoteCopyWithImpl<$Res> implements _$PriceQuoteCopyWith<$Res> {
  __$PriceQuoteCopyWithImpl(this._self, this._then);

  final _PriceQuote _self;
  final $Res Function(_PriceQuote) _then;

  /// Create a copy of PriceQuote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? vendorId = null,
    Object? variantId = null,
    Object? currency = null,
    Object? unitPrice = null,
    Object? minQty = null,
  }) {
    return _then(_PriceQuote(
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
      minQty: null == minQty
          ? _self.minQty
          : minQty // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
