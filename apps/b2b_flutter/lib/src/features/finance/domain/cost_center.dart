import 'package:freezed_annotation/freezed_annotation.dart';

part 'cost_center.freezed.dart';
part 'cost_center.g.dart';

@JsonEnum(alwaysCreate: true)
enum CostCenterStatus { active, archived }

@freezed
abstract class CostCenterRule with _$CostCenterRule {
  const factory CostCenterRule({
    required String label,
    required String value,
  }) = _CostCenterRule;

  factory CostCenterRule.fromJson(Map<String, dynamic> json) =>
      _$CostCenterRuleFromJson(json);
}

@freezed
abstract class CostCenter with _$CostCenter {
  const CostCenter._();

  const factory CostCenter({
    required String id,
    @JsonKey(name: 'company_id') required String companyId,
    @JsonKey(name: 'business_unit') required String businessUnit,
    required String code,
    required String name,
    required String department,
    @JsonKey(name: 'approver_name') String? approverName,
    @JsonKey(name: 'ytd_budget') @Default(0) double ytdBudget,
    @JsonKey(name: 'ytd_spent') @Default(0) double ytdSpent,
    @JsonKey(name: 'requires_approver') @Default(false) bool requiresApprover,
    @JsonKey(name: 'auto_assign_rules')
    @Default(<CostCenterRule>[])
    List<CostCenterRule> autoAssignRules,
    @JsonKey(name: 'status')
    @Default(CostCenterStatus.active)
    CostCenterStatus status,
    String? notes,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CostCenter;

  factory CostCenter.fromJson(Map<String, dynamic> json) =>
      _$CostCenterFromJson(json);

  double get remainingBudget => ytdBudget - ytdSpent;

  bool get isOverBudget => remainingBudget < 0;
}
