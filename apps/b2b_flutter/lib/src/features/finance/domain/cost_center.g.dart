// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_center.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CostCenterRule _$CostCenterRuleFromJson(Map<String, dynamic> json) =>
    _CostCenterRule(
      label: json['label'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$CostCenterRuleToJson(_CostCenterRule instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
    };

_CostCenter _$CostCenterFromJson(Map<String, dynamic> json) => _CostCenter(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      businessUnit: json['business_unit'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      approverName: json['approver_name'] as String?,
      ytdBudget: (json['ytd_budget'] as num?)?.toDouble() ?? 0,
      ytdSpent: (json['ytd_spent'] as num?)?.toDouble() ?? 0,
      requiresApprover: json['requires_approver'] as bool? ?? false,
      autoAssignRules: (json['auto_assign_rules'] as List<dynamic>?)
              ?.map((e) => CostCenterRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CostCenterRule>[],
      status: $enumDecodeNullable(_$CostCenterStatusEnumMap, json['status']) ??
          CostCenterStatus.active,
      notes: json['notes'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CostCenterToJson(_CostCenter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'business_unit': instance.businessUnit,
      'code': instance.code,
      'name': instance.name,
      'department': instance.department,
      'approver_name': instance.approverName,
      'ytd_budget': instance.ytdBudget,
      'ytd_spent': instance.ytdSpent,
      'requires_approver': instance.requiresApprover,
      'auto_assign_rules': instance.autoAssignRules,
      'status': _$CostCenterStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$CostCenterStatusEnumMap = {
  CostCenterStatus.active: 'active',
  CostCenterStatus.archived: 'archived',
};
