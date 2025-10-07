// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_center.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CostCenterRule {
  String get label;
  String get value;

  /// Create a copy of CostCenterRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CostCenterRuleCopyWith<CostCenterRule> get copyWith =>
      _$CostCenterRuleCopyWithImpl<CostCenterRule>(
          this as CostCenterRule, _$identity);

  /// Serializes this CostCenterRule to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CostCenterRule &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value);

  @override
  String toString() {
    return 'CostCenterRule(label: $label, value: $value)';
  }
}

/// @nodoc
abstract mixin class $CostCenterRuleCopyWith<$Res> {
  factory $CostCenterRuleCopyWith(
          CostCenterRule value, $Res Function(CostCenterRule) _then) =
      _$CostCenterRuleCopyWithImpl;
  @useResult
  $Res call({String label, String value});
}

/// @nodoc
class _$CostCenterRuleCopyWithImpl<$Res>
    implements $CostCenterRuleCopyWith<$Res> {
  _$CostCenterRuleCopyWithImpl(this._self, this._then);

  final CostCenterRule _self;
  final $Res Function(CostCenterRule) _then;

  /// Create a copy of CostCenterRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CostCenterRule].
extension CostCenterRulePatterns on CostCenterRule {
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
    TResult Function(_CostCenterRule value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CostCenterRule() when $default != null:
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
    TResult Function(_CostCenterRule value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenterRule():
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
    TResult? Function(_CostCenterRule value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenterRule() when $default != null:
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
    TResult Function(String label, String value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CostCenterRule() when $default != null:
        return $default(_that.label, _that.value);
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
    TResult Function(String label, String value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenterRule():
        return $default(_that.label, _that.value);
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
    TResult? Function(String label, String value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenterRule() when $default != null:
        return $default(_that.label, _that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CostCenterRule implements CostCenterRule {
  const _CostCenterRule({required this.label, required this.value});
  factory _CostCenterRule.fromJson(Map<String, dynamic> json) =>
      _$CostCenterRuleFromJson(json);

  @override
  final String label;
  @override
  final String value;

  /// Create a copy of CostCenterRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CostCenterRuleCopyWith<_CostCenterRule> get copyWith =>
      __$CostCenterRuleCopyWithImpl<_CostCenterRule>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CostCenterRuleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CostCenterRule &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value);

  @override
  String toString() {
    return 'CostCenterRule(label: $label, value: $value)';
  }
}

/// @nodoc
abstract mixin class _$CostCenterRuleCopyWith<$Res>
    implements $CostCenterRuleCopyWith<$Res> {
  factory _$CostCenterRuleCopyWith(
          _CostCenterRule value, $Res Function(_CostCenterRule) _then) =
      __$CostCenterRuleCopyWithImpl;
  @override
  @useResult
  $Res call({String label, String value});
}

/// @nodoc
class __$CostCenterRuleCopyWithImpl<$Res>
    implements _$CostCenterRuleCopyWith<$Res> {
  __$CostCenterRuleCopyWithImpl(this._self, this._then);

  final _CostCenterRule _self;
  final $Res Function(_CostCenterRule) _then;

  /// Create a copy of CostCenterRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_CostCenterRule(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$CostCenter {
  String get id;
  @JsonKey(name: 'company_id')
  String get companyId;
  @JsonKey(name: 'business_unit')
  String get businessUnit;
  String get code;
  String get name;
  String get department;
  @JsonKey(name: 'approver_name')
  String? get approverName;
  @JsonKey(name: 'ytd_budget')
  double get ytdBudget;
  @JsonKey(name: 'ytd_spent')
  double get ytdSpent;
  @JsonKey(name: 'requires_approver')
  bool get requiresApprover;
  @JsonKey(name: 'auto_assign_rules')
  List<CostCenterRule> get autoAssignRules;
  @JsonKey(name: 'status')
  CostCenterStatus get status;
  String? get notes;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of CostCenter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CostCenterCopyWith<CostCenter> get copyWith =>
      _$CostCenterCopyWithImpl<CostCenter>(this as CostCenter, _$identity);

  /// Serializes this CostCenter to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CostCenter &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.businessUnit, businessUnit) ||
                other.businessUnit == businessUnit) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.approverName, approverName) ||
                other.approverName == approverName) &&
            (identical(other.ytdBudget, ytdBudget) ||
                other.ytdBudget == ytdBudget) &&
            (identical(other.ytdSpent, ytdSpent) ||
                other.ytdSpent == ytdSpent) &&
            (identical(other.requiresApprover, requiresApprover) ||
                other.requiresApprover == requiresApprover) &&
            const DeepCollectionEquality()
                .equals(other.autoAssignRules, autoAssignRules) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      companyId,
      businessUnit,
      code,
      name,
      department,
      approverName,
      ytdBudget,
      ytdSpent,
      requiresApprover,
      const DeepCollectionEquality().hash(autoAssignRules),
      status,
      notes,
      updatedAt);

  @override
  String toString() {
    return 'CostCenter(id: $id, companyId: $companyId, businessUnit: $businessUnit, code: $code, name: $name, department: $department, approverName: $approverName, ytdBudget: $ytdBudget, ytdSpent: $ytdSpent, requiresApprover: $requiresApprover, autoAssignRules: $autoAssignRules, status: $status, notes: $notes, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CostCenterCopyWith<$Res> {
  factory $CostCenterCopyWith(
          CostCenter value, $Res Function(CostCenter) _then) =
      _$CostCenterCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'company_id') String companyId,
      @JsonKey(name: 'business_unit') String businessUnit,
      String code,
      String name,
      String department,
      @JsonKey(name: 'approver_name') String? approverName,
      @JsonKey(name: 'ytd_budget') double ytdBudget,
      @JsonKey(name: 'ytd_spent') double ytdSpent,
      @JsonKey(name: 'requires_approver') bool requiresApprover,
      @JsonKey(name: 'auto_assign_rules') List<CostCenterRule> autoAssignRules,
      @JsonKey(name: 'status') CostCenterStatus status,
      String? notes,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$CostCenterCopyWithImpl<$Res> implements $CostCenterCopyWith<$Res> {
  _$CostCenterCopyWithImpl(this._self, this._then);

  final CostCenter _self;
  final $Res Function(CostCenter) _then;

  /// Create a copy of CostCenter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? businessUnit = null,
    Object? code = null,
    Object? name = null,
    Object? department = null,
    Object? approverName = freezed,
    Object? ytdBudget = null,
    Object? ytdSpent = null,
    Object? requiresApprover = null,
    Object? autoAssignRules = null,
    Object? status = null,
    Object? notes = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      companyId: null == companyId
          ? _self.companyId
          : companyId // ignore: cast_nullable_to_non_nullable
              as String,
      businessUnit: null == businessUnit
          ? _self.businessUnit
          : businessUnit // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      department: null == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      approverName: freezed == approverName
          ? _self.approverName
          : approverName // ignore: cast_nullable_to_non_nullable
              as String?,
      ytdBudget: null == ytdBudget
          ? _self.ytdBudget
          : ytdBudget // ignore: cast_nullable_to_non_nullable
              as double,
      ytdSpent: null == ytdSpent
          ? _self.ytdSpent
          : ytdSpent // ignore: cast_nullable_to_non_nullable
              as double,
      requiresApprover: null == requiresApprover
          ? _self.requiresApprover
          : requiresApprover // ignore: cast_nullable_to_non_nullable
              as bool,
      autoAssignRules: null == autoAssignRules
          ? _self.autoAssignRules
          : autoAssignRules // ignore: cast_nullable_to_non_nullable
              as List<CostCenterRule>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CostCenterStatus,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CostCenter].
extension CostCenterPatterns on CostCenter {
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
    TResult Function(_CostCenter value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CostCenter() when $default != null:
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
    TResult Function(_CostCenter value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenter():
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
    TResult? Function(_CostCenter value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenter() when $default != null:
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
            @JsonKey(name: 'company_id') String companyId,
            @JsonKey(name: 'business_unit') String businessUnit,
            String code,
            String name,
            String department,
            @JsonKey(name: 'approver_name') String? approverName,
            @JsonKey(name: 'ytd_budget') double ytdBudget,
            @JsonKey(name: 'ytd_spent') double ytdSpent,
            @JsonKey(name: 'requires_approver') bool requiresApprover,
            @JsonKey(name: 'auto_assign_rules')
            List<CostCenterRule> autoAssignRules,
            @JsonKey(name: 'status') CostCenterStatus status,
            String? notes,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CostCenter() when $default != null:
        return $default(
            _that.id,
            _that.companyId,
            _that.businessUnit,
            _that.code,
            _that.name,
            _that.department,
            _that.approverName,
            _that.ytdBudget,
            _that.ytdSpent,
            _that.requiresApprover,
            _that.autoAssignRules,
            _that.status,
            _that.notes,
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
            String id,
            @JsonKey(name: 'company_id') String companyId,
            @JsonKey(name: 'business_unit') String businessUnit,
            String code,
            String name,
            String department,
            @JsonKey(name: 'approver_name') String? approverName,
            @JsonKey(name: 'ytd_budget') double ytdBudget,
            @JsonKey(name: 'ytd_spent') double ytdSpent,
            @JsonKey(name: 'requires_approver') bool requiresApprover,
            @JsonKey(name: 'auto_assign_rules')
            List<CostCenterRule> autoAssignRules,
            @JsonKey(name: 'status') CostCenterStatus status,
            String? notes,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenter():
        return $default(
            _that.id,
            _that.companyId,
            _that.businessUnit,
            _that.code,
            _that.name,
            _that.department,
            _that.approverName,
            _that.ytdBudget,
            _that.ytdSpent,
            _that.requiresApprover,
            _that.autoAssignRules,
            _that.status,
            _that.notes,
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
            String id,
            @JsonKey(name: 'company_id') String companyId,
            @JsonKey(name: 'business_unit') String businessUnit,
            String code,
            String name,
            String department,
            @JsonKey(name: 'approver_name') String? approverName,
            @JsonKey(name: 'ytd_budget') double ytdBudget,
            @JsonKey(name: 'ytd_spent') double ytdSpent,
            @JsonKey(name: 'requires_approver') bool requiresApprover,
            @JsonKey(name: 'auto_assign_rules')
            List<CostCenterRule> autoAssignRules,
            @JsonKey(name: 'status') CostCenterStatus status,
            String? notes,
            @JsonKey(name: 'updated_at') DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CostCenter() when $default != null:
        return $default(
            _that.id,
            _that.companyId,
            _that.businessUnit,
            _that.code,
            _that.name,
            _that.department,
            _that.approverName,
            _that.ytdBudget,
            _that.ytdSpent,
            _that.requiresApprover,
            _that.autoAssignRules,
            _that.status,
            _that.notes,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CostCenter extends CostCenter {
  const _CostCenter(
      {required this.id,
      @JsonKey(name: 'company_id') required this.companyId,
      @JsonKey(name: 'business_unit') required this.businessUnit,
      required this.code,
      required this.name,
      required this.department,
      @JsonKey(name: 'approver_name') this.approverName,
      @JsonKey(name: 'ytd_budget') this.ytdBudget = 0,
      @JsonKey(name: 'ytd_spent') this.ytdSpent = 0,
      @JsonKey(name: 'requires_approver') this.requiresApprover = false,
      @JsonKey(name: 'auto_assign_rules')
      final List<CostCenterRule> autoAssignRules = const <CostCenterRule>[],
      @JsonKey(name: 'status') this.status = CostCenterStatus.active,
      this.notes,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _autoAssignRules = autoAssignRules,
        super._();
  factory _CostCenter.fromJson(Map<String, dynamic> json) =>
      _$CostCenterFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'company_id')
  final String companyId;
  @override
  @JsonKey(name: 'business_unit')
  final String businessUnit;
  @override
  final String code;
  @override
  final String name;
  @override
  final String department;
  @override
  @JsonKey(name: 'approver_name')
  final String? approverName;
  @override
  @JsonKey(name: 'ytd_budget')
  final double ytdBudget;
  @override
  @JsonKey(name: 'ytd_spent')
  final double ytdSpent;
  @override
  @JsonKey(name: 'requires_approver')
  final bool requiresApprover;
  final List<CostCenterRule> _autoAssignRules;
  @override
  @JsonKey(name: 'auto_assign_rules')
  List<CostCenterRule> get autoAssignRules {
    if (_autoAssignRules is EqualUnmodifiableListView) return _autoAssignRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_autoAssignRules);
  }

  @override
  @JsonKey(name: 'status')
  final CostCenterStatus status;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of CostCenter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CostCenterCopyWith<_CostCenter> get copyWith =>
      __$CostCenterCopyWithImpl<_CostCenter>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CostCenterToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CostCenter &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyId, companyId) ||
                other.companyId == companyId) &&
            (identical(other.businessUnit, businessUnit) ||
                other.businessUnit == businessUnit) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.approverName, approverName) ||
                other.approverName == approverName) &&
            (identical(other.ytdBudget, ytdBudget) ||
                other.ytdBudget == ytdBudget) &&
            (identical(other.ytdSpent, ytdSpent) ||
                other.ytdSpent == ytdSpent) &&
            (identical(other.requiresApprover, requiresApprover) ||
                other.requiresApprover == requiresApprover) &&
            const DeepCollectionEquality()
                .equals(other._autoAssignRules, _autoAssignRules) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      companyId,
      businessUnit,
      code,
      name,
      department,
      approverName,
      ytdBudget,
      ytdSpent,
      requiresApprover,
      const DeepCollectionEquality().hash(_autoAssignRules),
      status,
      notes,
      updatedAt);

  @override
  String toString() {
    return 'CostCenter(id: $id, companyId: $companyId, businessUnit: $businessUnit, code: $code, name: $name, department: $department, approverName: $approverName, ytdBudget: $ytdBudget, ytdSpent: $ytdSpent, requiresApprover: $requiresApprover, autoAssignRules: $autoAssignRules, status: $status, notes: $notes, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CostCenterCopyWith<$Res>
    implements $CostCenterCopyWith<$Res> {
  factory _$CostCenterCopyWith(
          _CostCenter value, $Res Function(_CostCenter) _then) =
      __$CostCenterCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'company_id') String companyId,
      @JsonKey(name: 'business_unit') String businessUnit,
      String code,
      String name,
      String department,
      @JsonKey(name: 'approver_name') String? approverName,
      @JsonKey(name: 'ytd_budget') double ytdBudget,
      @JsonKey(name: 'ytd_spent') double ytdSpent,
      @JsonKey(name: 'requires_approver') bool requiresApprover,
      @JsonKey(name: 'auto_assign_rules') List<CostCenterRule> autoAssignRules,
      @JsonKey(name: 'status') CostCenterStatus status,
      String? notes,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$CostCenterCopyWithImpl<$Res> implements _$CostCenterCopyWith<$Res> {
  __$CostCenterCopyWithImpl(this._self, this._then);

  final _CostCenter _self;
  final $Res Function(_CostCenter) _then;

  /// Create a copy of CostCenter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? companyId = null,
    Object? businessUnit = null,
    Object? code = null,
    Object? name = null,
    Object? department = null,
    Object? approverName = freezed,
    Object? ytdBudget = null,
    Object? ytdSpent = null,
    Object? requiresApprover = null,
    Object? autoAssignRules = null,
    Object? status = null,
    Object? notes = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_CostCenter(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      companyId: null == companyId
          ? _self.companyId
          : companyId // ignore: cast_nullable_to_non_nullable
              as String,
      businessUnit: null == businessUnit
          ? _self.businessUnit
          : businessUnit // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      department: null == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      approverName: freezed == approverName
          ? _self.approverName
          : approverName // ignore: cast_nullable_to_non_nullable
              as String?,
      ytdBudget: null == ytdBudget
          ? _self.ytdBudget
          : ytdBudget // ignore: cast_nullable_to_non_nullable
              as double,
      ytdSpent: null == ytdSpent
          ? _self.ytdSpent
          : ytdSpent // ignore: cast_nullable_to_non_nullable
              as double,
      requiresApprover: null == requiresApprover
          ? _self.requiresApprover
          : requiresApprover // ignore: cast_nullable_to_non_nullable
              as bool,
      autoAssignRules: null == autoAssignRules
          ? _self._autoAssignRules
          : autoAssignRules // ignore: cast_nullable_to_non_nullable
              as List<CostCenterRule>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CostCenterStatus,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
