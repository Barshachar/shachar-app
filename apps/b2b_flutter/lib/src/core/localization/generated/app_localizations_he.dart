// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מרקטפלייס א.שחר';

  @override
  String get loginAppBarTitle => 'מרקטפלייס א.שחר';

  @override
  String get loginTitle => 'כניסה לחשבון';

  @override
  String get loginSubtitle => 'הזינו את פרטי ההתחברות שלכם כדי להמשיך.';

  @override
  String get loginButton => 'התחבר';

  @override
  String get loginButtonLoading => 'מתחבר...';

  @override
  String get loginDemoCta => 'כניסה לדמו';

  @override
  String get loginEmailLabel => 'אימייל';

  @override
  String get loginEmailRequired => 'נדרש אימייל.';

  @override
  String get loginEmailInvalid => 'אנא הזינו אימייל תקין.';

  @override
  String get loginPasswordLabel => 'סיסמה';

  @override
  String get loginPasswordRequired => 'נדרשת סיסמה.';

  @override
  String get loginPasswordTooShort => 'הסיסמה קצרה מדי.';

  @override
  String get loginErrorInvalidCredentials =>
      'האימייל או הסיסמה שגויים. נסו שוב.';

  @override
  String get loginErrorRateLimited =>
      'בוצעו יותר מדי ניסיונות. המתינו רגע ונסו שוב.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'האימייל טרם אומת. בדקו את תיבת הדואר לאישור.';

  @override
  String get loginErrorGeneric => 'לא הצלחנו להתחבר. נסו שוב בעוד רגע.';

  @override
  String get loginErrorUnexpected => 'אירעה תקלה. נסו שוב בעוד רגע.';

  @override
  String get loginErrorDemoUnavailable => 'פרטי ההדגמה אינם זמינים בסביבה זו.';

  @override
  String get loginErrorDemoGeneric => 'אירעה תקלה בעת התחברות הדמו. נסו שוב.';

  @override
  String get signOut => 'התנתקות';

  @override
  String get authSignIn => 'התחברות';

  @override
  String get signInSwitchUser => 'התחברות / החלפת משתמש';

  @override
  String get homeTitle => 'עמוד הבית';

  @override
  String get homeGreeting => 'ברוך שובך!';

  @override
  String get homeGreetingSubtitle => 'מה נרצה לעשות היום?';

  @override
  String get homeSearchPlaceholder => 'חפש מוצרים';

  @override
  String get homeSearchTooltip => 'חיפוש';

  @override
  String get homeMenuTooltip => 'תפריט';

  @override
  String get homeCampaignTitle => 'מבצעים 2025';

  @override
  String get homeCampaignSubtitle => 'חבילות משתלמות והטבות ללקוחות החוזרים';

  @override
  String get homeCampaignCta => 'לכל המבצעים';

  @override
  String get homeCurrentOrderTitle => 'הזמנה נוכחית';

  @override
  String get homeCurrentOrderEmpty => 'אין טיוטת הזמנה פעילה כרגע.';

  @override
  String get homeCurrentOrderLoading => 'טוען טיוטה...';

  @override
  String get homeCurrentOrderValue => 'שווי הזמנה';

  @override
  String homeCurrentOrderItems(Object count) {
    return '$count פריטים';
  }

  @override
  String get homeContinueOrder => 'המשך להזמנה';

  @override
  String get homeTilePromotions => 'מבצעים';

  @override
  String get homeTilePromotionsDescription => 'קבלו חבילות וקידומים עדכניים';

  @override
  String get homeTileCatalog => 'קטלוג';

  @override
  String get homeTileCatalogDescription => 'סיור בכל המוצרים הזמינים';

  @override
  String get homeTileQuickOrder => 'הזמנה מהירה';

  @override
  String get homeTileQuickOrderDescription => 'הוספה מרוכזת למוצרים קבועים';

  @override
  String get homeTileCart => 'סל הזמנה';

  @override
  String get homeTileCartDescription => 'בדיקת הטיוטה והמשך תהליך';

  @override
  String get homeTileOrders => 'הזמנות שלי';

  @override
  String get homeTileOrdersDescription => 'מעקב אחר סטטוסים ומשלוחים';

  @override
  String get homeTileApprovals => 'אישורים';

  @override
  String get homeTileApprovalsDescription => 'בקשות ממתינות לאישור';

  @override
  String get homeReorderTitle => 'הזמנה חוזרת';

  @override
  String get homeSavedListsShortcut => 'רשימות שמורות';

  @override
  String get homeViewAllOrders => 'כל ההזמנות';

  @override
  String get profile => 'הפרופיל שלי';

  @override
  String get settings => 'הגדרות';

  @override
  String get help => 'עזרה';

  @override
  String get about => 'אודות';

  @override
  String get aboutTitle => 'אודות א.שחר';

  @override
  String get aboutSubtitle => 'פלטפורמת רכש B2B למרקטפלייס רב-ספקי.';

  @override
  String get aboutVersionLabel => 'גרסה';

  @override
  String get aboutMissionTitle => 'המשימה שלנו';

  @override
  String get aboutMissionBody =>
      'להפוך רכש B2B למהיר, שקוף ואמין — מהמקור ועד האספקה.';

  @override
  String get aboutHighlightsTitle => 'מה תוכלו לעשות';

  @override
  String get aboutHighlightOrdersTitle => 'להזמין תוך דקות';

  @override
  String get aboutHighlightOrdersBody =>
      'איחוד ספקים, אישורים ומעקב משלוחים במקום אחד.';

  @override
  String get aboutHighlightPricingTitle => 'תמחור חכם';

  @override
  String get aboutHighlightPricingBody =>
      'מחירים מותאמים ללקוח, מבצעים וחוזים.';

  @override
  String get aboutHighlightInsightsTitle => 'תובנות תפעוליות';

  @override
  String get aboutHighlightInsightsBody =>
      'דשבורדים והתראות שמחזיקים את השרשרת בשליטה.';

  @override
  String get aboutContactTitle => 'צור קשר';

  @override
  String get aboutContactPhoneLabel => 'טלפון';

  @override
  String get aboutContactPhoneValue => '03-1234567';

  @override
  String get aboutContactEmailLabel => 'אימייל';

  @override
  String get aboutContactEmailValue => 'support@ashachar.co.il';

  @override
  String get aboutContactHoursLabel => 'שעות פעילות';

  @override
  String get aboutContactHoursValue => 'א\'-ה\' 08:00-17:00';

  @override
  String get aboutLegalTitle => 'משפטי';

  @override
  String get aboutLegalTerms => 'תנאי שימוש';

  @override
  String get aboutLegalPrivacy => 'מדיניות פרטיות';

  @override
  String get aboutLegalSoon => 'בקרוב';

  @override
  String get customerCompanyProfileTitle => 'פרופיל חברה';

  @override
  String get customerCompanyProfileTabOverview => 'סקירה';

  @override
  String get customerCompanyProfileTabOrders => 'הזמנות';

  @override
  String get customerCompanyProfileTabQuotes => 'הצעות מחיר';

  @override
  String get customerCompanyProfileTabCredit => 'אשראי';

  @override
  String get customerCompanyProfileTabContracts => 'חוזים';

  @override
  String get customerCompanyProfileComingSoon => 'בקרוב';

  @override
  String get customerCompanyProfileLoadError => 'לא ניתן לטעון את פרטי החברה';

  @override
  String get customerCompanyProfileTierLabel => 'דרג';

  @override
  String get customerCompanyProfileIndustryLabel => 'תחום פעילות';

  @override
  String get customerCompanyProfileSalesRepLabel => 'נציג מכירות';

  @override
  String get customerCompanyProfileEmailLabel => 'אימייל';

  @override
  String get customerCompanyProfileContactTitle => 'פרטי קשר';

  @override
  String get adminDashboardTitle => 'מרכז ניהול';

  @override
  String get adminDashboardOverviewHeading => 'סקירת פעילות';

  @override
  String get adminDashboardQuickActionsHeading => 'פעולות מהירות';

  @override
  String get adminDashboardSignalsHeading => 'התראות תפעוליות';

  @override
  String get adminDashboardTotalGmv => 'מחזור מכירות';

  @override
  String get adminDashboardTotalGmvTrend => '+12.4% לעומת החודש שעבר';

  @override
  String get adminDashboardActiveVendors => 'ספקים פעילים';

  @override
  String get adminDashboardActiveVendorsTrend => '2 בתהליך קליטה כעת';

  @override
  String get adminDashboardApprovals => 'אישורים ממתינים';

  @override
  String get adminDashboardApprovalsTrend => '3 שעות SLA שנותרו';

  @override
  String get adminDashboardSupportCta => 'פתיחת תיבת תמיכה';

  @override
  String get adminDashboardSupportDescription => 'מעקב אחר הסלמות וחריגות SLA';

  @override
  String get adminDashboardTaxSettingsCta => 'הגדרת כללי מיסוי';

  @override
  String get adminDashboardTaxSettingsDescription =>
      'מע\"מ, פטורים ופרופילי יצוא';

  @override
  String get adminDashboardAuditLogCta => 'צפייה ביומן פעילות';

  @override
  String get adminDashboardAuditLogDescription =>
      'שינויים אחרונים וניהול משתמשים';

  @override
  String get adminDashboardVendorsCta => 'ניהול תור ספקים';

  @override
  String get adminDashboardVendorsDescription => 'אישור או דחיית בקשות הצטרפות';

  @override
  String get adminDashboardSupportAlerts => 'התראות תמיכה';

  @override
  String get adminDashboardComplianceAlerts => 'עמידה במדיניות ואישורים';

  @override
  String get adminDashboardSupportAlert1Title => '#2034 תקלה בהתחברות';

  @override
  String get adminDashboardSupportAlert1Subtitle =>
      'חריגת SLA בתוך 12 דקות • הועבר לצוות התמיכה';

  @override
  String get adminDashboardSupportAlert2Title => '#2033 הזמנה שלא סופקה';

  @override
  String get adminDashboardSupportAlert2Subtitle =>
      'הועבר ללוגיסטיקה • ETA ארבע שעות';

  @override
  String get adminDashboardComplianceAlert1Title =>
      '2 בקשות אישור ממתינות לאדמין';

  @override
  String get adminDashboardComplianceAlert1Subtitle =>
      'שוטף 60 חריג • תהליך קליטת ספק';

  @override
  String get adminDashboardComplianceAlert2Title => 'כלל מס אחד פג תוקף החודש';

  @override
  String get adminDashboardComplianceAlert2Subtitle =>
      'פטור לעמותות – נדרש רענון';

  @override
  String get adminDashboardNotes => 'הנתונים בדשבורד הינם לצרכי הדגמה בלבד.';

  @override
  String get adminAuditLogTitle => 'יומן פעילות';

  @override
  String get adminAuditLogFiltersApplied => 'המסננים הוחלו על היומן.';

  @override
  String get adminAuditLogExportStarted => 'הייצוא החל ברקע.';

  @override
  String get adminAuditLogLoadError => 'לא ניתן לטעון את יומן הפעילות.';

  @override
  String get adminAuditLogEmpty => 'לא נמצאה פעילות ביומן.';

  @override
  String get adminAuditLogFilterDateRangeLabel => 'טווח תאריכים';

  @override
  String get adminAuditLogFilterDateRangeHint => '7 הימים האחרונים';

  @override
  String get adminAuditLogFilterUserLabel => 'משתמש';

  @override
  String get adminAuditLogFilterUserHint => 'חיפוש לפי משתמש';

  @override
  String get adminAuditLogFilterModuleLabel => 'מודול';

  @override
  String get adminAuditLogFilterModuleHint => 'כל מודול';

  @override
  String get adminAuditLogFilterActionLabel => 'פעולה';

  @override
  String get adminAuditLogFilterActionHint => 'סוג פעולה';

  @override
  String get adminAuditLogExport => 'ייצוא';

  @override
  String get adminAuditLogApplyFilters => 'החל מסננים';

  @override
  String get adminAuditLogStatusSuccess => 'הצלחה';

  @override
  String get adminAuditLogStatusWarning => 'אזהרה';

  @override
  String get adminAuditLogStatusError => 'שגיאה';

  @override
  String get adminContactTitle => 'צור קשר';

  @override
  String get adminContactFieldName => 'שם מלא';

  @override
  String get adminContactFieldEmail => 'אימייל';

  @override
  String get adminContactFieldCompany => 'חברה';

  @override
  String get adminContactFieldPhone => 'טלפון';

  @override
  String get adminContactSubmit => 'שליחת הודעה';

  @override
  String get adminDockSchedulingTitle => 'תיאום רציפים';

  @override
  String get adminDockFilterDateRange => 'טווח תאריכים';

  @override
  String get adminDockFilterWarehouse => 'מחסן';

  @override
  String get adminDockFilterCarrier => 'חברת שילוח';

  @override
  String get adminDockFilterStatus => 'סטטוס';

  @override
  String get adminDockPanelTitle => 'רציף / דלת';

  @override
  String get adminDockPanelTime => 'חלון זמן';

  @override
  String get adminDockPanelMode => 'סוג משלוח';

  @override
  String get adminDockPanelSpecialInstructions => 'הוראות מיוחדות';

  @override
  String get adminDockPanelLiftGate => 'מעלית משאית';

  @override
  String get adminDockPanelCallOnArrival => 'שיחה בעת הגעה';

  @override
  String get adminDockReserve => 'שריין משבצת';

  @override
  String get adminDockLegendOutForDelivery => 'במסירה';

  @override
  String get adminDockLegendDelivered => 'נמסר';

  @override
  String get adminDockLegendCapacity => 'קיבולת';

  @override
  String get adminDockLegendScheduled => 'מתוכנן';

  @override
  String get adminDockActionTrack => 'מעקב';

  @override
  String get adminDockActionContact => 'יצירת קשר';

  @override
  String get adminDockActionReschedule => 'תזמון מחדש';

  @override
  String get adminDockActionPrintBol => 'הדפס BOL';

  @override
  String get adminPayablesTitle => 'הרצת תשלומים לספקים';

  @override
  String get adminPayablesBankAccount => 'חשבון בנק';

  @override
  String get adminPayablesScheduleDate => 'תאריך הפעלה';

  @override
  String get adminPayablesFilterVendors => 'סינון חשבוניות';

  @override
  String get adminPayablesPaymentMethod => 'אמצעי תשלום';

  @override
  String get adminPayablesChecksum => 'בדיקת סכום';

  @override
  String get adminPayablesSchedule => 'קבע תשלומים';

  @override
  String get adminPayablesTotal => 'סך חשבונית';

  @override
  String get adminPayablesDueDates => 'תאריכי יעד';

  @override
  String get adminExportsTitle => 'ייצוא נתונים';

  @override
  String get adminExportsDataset => 'מאגר נתונים';

  @override
  String get adminExportsDateRange => 'טווח תאריכים';

  @override
  String get adminExportsSelectFields => 'בחרו שדות...';

  @override
  String get adminExportsFormat => 'פורמט';

  @override
  String get adminExportsDestination => 'יעד';

  @override
  String get adminExportsFrequencyLabel => 'תדירות';

  @override
  String get adminExportsOnce => 'חד פעמי';

  @override
  String get adminExportsDaily => 'יומי';

  @override
  String get adminExportsWeekly => 'שבועי';

  @override
  String get adminExportsIncludeFilters => 'כלול סינונים';

  @override
  String get adminExportsLastExports => 'ייצואים אחרונים';

  @override
  String get adminExportsCompleted => 'הושלם';

  @override
  String get adminExportsPending => 'בהמתנה';

  @override
  String get adminExportsDownload => 'הורדה';

  @override
  String get adminApprovalTitle => 'אישור הזמנה';

  @override
  String get adminApprovalCartItems => 'פריטי סל';

  @override
  String get adminApprovalSubtotal => 'סכום ביניים';

  @override
  String get adminApprovalFlagOverBudget => 'חריגה מתקציב';

  @override
  String get adminApprovalFlagNonPreferred => 'ספק שאינו מועדף';

  @override
  String get adminApprovalFlagSplit => 'פיצול לפי מחסן';

  @override
  String get adminApprovalBudgetHeading => 'ניצול תקציב';

  @override
  String get adminApprovalAddComment => 'הוספת הערה...';

  @override
  String get adminApprovalApprove => 'אישור';

  @override
  String get adminApprovalReject => 'דחייה';

  @override
  String get adminApprovalRejectReason => 'יש לציין סיבת דחייה';

  @override
  String get adminApprovalViewCart => 'צפייה בפריטי הסל';

  @override
  String get adminApprovalSla => 'SLA';

  @override
  String get catalogTitle => 'קטלוג';

  @override
  String get ordersTitle => 'הזמנות';

  @override
  String get ordersTableOrder => 'הזמנה';

  @override
  String get ordersTableCreated => 'נוצרה';

  @override
  String get ordersTableStatus => 'סטטוס';

  @override
  String get ordersTableTotal => 'סה\"כ';

  @override
  String get savedListsTitle => 'רשימות שמורות';

  @override
  String get newList => 'רשימה חדשה';

  @override
  String get reorderTitle => 'הזמנה מחדש מהירה';

  @override
  String get addAll => 'הוסף הכל';

  @override
  String itemsCount(Object count) {
    return '$count פריטים';
  }

  @override
  String lastUpdated(Object timestamp) {
    return 'עודכן לאחרונה $timestamp';
  }

  @override
  String get savedListsEmptyTitle => 'אין רשימות שמורות עדיין';

  @override
  String get savedListsEmptyMessage =>
      'צרו רשימות כדי להוסיף במהירות פריטים חוזרים.';

  @override
  String get savedListsErrorTitle => 'לא ניתן לטעון רשימות שמורות';

  @override
  String savedListsAddAllSuccess(Object itemCount, Object listName) {
    return 'הוספנו את כל $itemCount הפריטים מהרשימה \"$listName\"';
  }

  @override
  String get reorderEmptyTitle => 'אין פריטים להזמנה מחדש';

  @override
  String get reorderEmptyMessage =>
      'בחרו הזמנה קודמת כדי להוסיף ממנה פריטים מחדש.';

  @override
  String get reorderErrorTitle => 'לא ניתן להציג הזמנה מחדש';

  @override
  String reorderTotalUnitsLabel(Object count) {
    return 'סה\"כ כמות: $count';
  }

  @override
  String get reorderTableItem => 'פריט';

  @override
  String get reorderTableSku => 'מק\"ט';

  @override
  String get reorderTableQuantity => 'כמות';

  @override
  String reorderAddAllSuccess(Object itemCount) {
    return 'הוספנו $itemCount פריטים לסל';
  }

  @override
  String get cartTitle => 'סל';

  @override
  String get vendorQueue => 'תור ספקים';

  @override
  String get reports => 'דוחות';

  @override
  String get ordersEmptyTitle => 'אין הזמנות עדיין';

  @override
  String get ordersEmptyCta => 'עבור לקטלוג';

  @override
  String get ordersError => 'שגיאה בטעינת הזמנות';

  @override
  String get ordersRetry => 'נסו שוב';

  @override
  String get ordersRfqsTooltip => 'בקשות הצעות מחיר';

  @override
  String get ordersStatusDraft => 'טיוטה';

  @override
  String get ordersStatusProcessing => 'בטיפול';

  @override
  String get ordersStatusSubmitted => 'הוזמנה';

  @override
  String get ordersStatusPendingApproval => 'ממתין לאישור';

  @override
  String get ordersStatusApproved => 'מאושר';

  @override
  String get ordersStatusRejected => 'נדחה';

  @override
  String get ordersStatusCompleted => 'הושלמה';

  @override
  String get ordersStatusShipped => 'נשלחה';

  @override
  String get ordersStatusCancelled => 'מבוטלת';

  @override
  String get ordersStatusInTransit => 'בדרך';

  @override
  String get statusPlaced => 'הוזמנה';

  @override
  String get statusPending => 'ממתין';

  @override
  String get statusApproved => 'מאושר';

  @override
  String get statusRejected => 'נדחה';

  @override
  String get statusDraft => 'טיוטה';

  @override
  String get statusCancelled => 'בוטלה';

  @override
  String get statusProcessing => 'בטיפול';

  @override
  String get statusCompleted => 'הושלמה';

  @override
  String get statusShipped => 'נשלחה';

  @override
  String get statusRequested => 'הוגשה בקשה';

  @override
  String get statusReceived => 'התקבל';

  @override
  String get statusRefunded => 'הוחזר';

  @override
  String get orderDetailTitle => 'פרטי הזמנה';

  @override
  String get orderDetailLines => 'שורות הזמנה';

  @override
  String get orderDetailShipments => 'משלוחים';

  @override
  String get orderDetailNoLines => 'אין שורות להזמנה זו';

  @override
  String get orderDetailNoShipments => 'טרם נוצרו משלוחים';

  @override
  String get orderDetailSubtotal => 'סכום ביניים';

  @override
  String get orderDetailTax => 'מע\"מ';

  @override
  String get orderDetailTotal => 'סה\"כ';

  @override
  String get statusLabel => 'סטטוס';

  @override
  String get subtotalShort => 'סכום ביניים';

  @override
  String get vatShort => 'מע״מ';

  @override
  String get totalShort => 'ס״כ';

  @override
  String get reorder => 'הזמנה חוזרת';

  @override
  String get order_detail_reorder_btn => 'הזמן שוב את ההזמנה';

  @override
  String orderDetailReorderError(Object message) {
    return 'לא ניתן לבצע הזמנה חוזרת כעת. שגיאה: $message';
  }

  @override
  String get orderDetailSkuPrefix => 'מק\"ט';

  @override
  String get orderDetailLineSkuLabel => 'מק\"ט';

  @override
  String get orderDetailLineQuantityLabel => 'כמות';

  @override
  String get orderDetailLineUnitPriceLabel => 'מחיר יחידה';

  @override
  String get orderDetailTrackingLabel => 'מספר מעקב';

  @override
  String get orderDetailCreatedAt => 'נוצר ב';

  @override
  String get orderCancelTitle => 'ביטול הזמנה';

  @override
  String get orderCancelSubtitle => 'אפשר לבטל את ההזמנה לפני המשלוח.';

  @override
  String get orderCancelButton => 'בטל הזמנה';

  @override
  String get orderCancelStatusTitle => 'ביטול';

  @override
  String get orderCancelStatusSubtitle => 'הזמנה זו בוטלה.';

  @override
  String orderCancelCancelledAt(Object date) {
    return 'בוטלה ב-$date';
  }

  @override
  String orderCancelReasonValue(Object reason) {
    return 'סיבה: $reason';
  }

  @override
  String get orderCancelDialogTitle => 'לבטל את ההזמנה?';

  @override
  String get orderCancelDialogMessage => 'אפשר לציין סיבה לביטול (לא חובה).';

  @override
  String get orderCancelReasonLabel => 'סיבה (לא חובה)';

  @override
  String get orderCancelDialogKeep => 'להשאיר הזמנה';

  @override
  String get orderCancelDialogConfirm => 'בטל הזמנה';

  @override
  String get orderCancelQueued =>
      'נשמר במצב אופליין. נבטל ברגע שתהיה חזרה לרשת.';

  @override
  String get orderCancelSuccess => 'ההזמנה בוטלה.';

  @override
  String get orderCancelError => 'לא ניתן לבטל את ההזמנה.';

  @override
  String get orderReturnsTitle => 'החזרות';

  @override
  String get orderReturnsSubtitle => 'אפשר לבקש החזרה עבור פריטים שסופקו.';

  @override
  String get orderReturnsNotEligible => 'החזרות זמינות לאחר שההזמנה נשלחת.';

  @override
  String get orderReturnsFetchError => 'היסטוריית ההחזרות אינה זמינה כרגע.';

  @override
  String get orderReturnsReturnableLabel => 'זמין להחזרה';

  @override
  String get orderReturnsRequestButton => 'בקשת החזרה';

  @override
  String get orderReturnsExistingLabel => 'בקשות קיימות';

  @override
  String get orderReturnsNoReturnable => 'אין כמות זמינה להחזרה.';

  @override
  String get orderReturnsDialogTitle => 'בקשת החזרה';

  @override
  String orderReturnsMaxHint(Object max) {
    return 'מקסימום $max';
  }

  @override
  String get orderReturnsReasonLabel => 'סיבה (לא חובה)';

  @override
  String get orderReturnsReasonHint => 'ספר לנו למה אתה מחזיר את הפריט.';

  @override
  String get orderReturnsCancel => 'ביטול';

  @override
  String get orderReturnsSubmit => 'שלח בקשה';

  @override
  String get orderReturnsQueued => 'נשמר אופליין. נשלח כשאתה חוזר לרשת.';

  @override
  String get orderReturnsSubmitted => 'בקשת החזרה נשלחה.';

  @override
  String get orderReturnsError => 'לא ניתן לשלוח בקשת החזרה.';

  @override
  String get orderRatingTitle => 'דירוג ספקים';

  @override
  String get orderRatingSubtitle => 'עזרו לקונים אחרים בעזרת המשוב שלכם.';

  @override
  String get orderRatingCommentLabel => 'הערה (לא חובה)';

  @override
  String get orderRatingCommentHint => 'שתפו מה עבד טוב ומה אפשר לשפר.';

  @override
  String get orderRatingSubmit => 'שליחת דירוג';

  @override
  String get orderRatingSubmitted => 'תודה על המשוב!';

  @override
  String get orderRatingQueued => 'נשמר אופליין. נשלח כשיש חיבור.';

  @override
  String orderRatingSummary(Object avg, Object count) {
    return '$avg / $count דירוגים';
  }

  @override
  String get orderRatingEmptySummary => 'עדיין אין דירוגים';

  @override
  String get orderRatingLoadingSummary => 'טוען דירוגים...';

  @override
  String get orderRatingSummaryError => 'לא ניתן לטעון דירוגים';

  @override
  String get orderRatingError => 'שליחת הדירוג נכשלה.';

  @override
  String get supportAiTitle => 'עוזר תמיכה AI';

  @override
  String get supportAiSubtitle => 'שאלו על הזמנות, חשבוניות או מדיניות ספקים.';

  @override
  String get supportAiHint => 'כתבו שאלה...';

  @override
  String get supportAiSend => 'שליחה';

  @override
  String get supportAiIntro =>
      'היי! אני כאן לעזור עם הזמנות, החזרות ושאלות חשבון.';

  @override
  String get supportAiOfflineFallback =>
      'אתם אופליין. אפשר לתת הנחיות כלליות, אך תשובות מותאמות דורשות חיבור.';

  @override
  String get supportAiError => 'לא ניתן להתחבר לעוזר. נסו שוב.';

  @override
  String get supportAiDisclaimer =>
      'תשובות ה-AI הן הערכה בלבד. בדקו פרטים חשובים.';

  @override
  String get approvalTimeline => 'ציר אישורים';

  @override
  String get approved => 'מאושר';

  @override
  String get pending => 'ממתין';

  @override
  String get rejected => 'נדחה';

  @override
  String get resendForApproval => 'שלח/שלחי שוב לאישור';

  @override
  String get catalogSearchTitle => 'חיפוש קטלוג';

  @override
  String get catalogSearchPlaceholder => 'חיפוש לפי שם, SKU או ספק';

  @override
  String get catalogSearchEmpty => 'לא נמצאו מוצרים לחיפוש זה.';

  @override
  String get catalogSearchError => 'לא ניתן לטעון מוצרים כעת.';

  @override
  String get catalogSearchRetry => 'נסו שוב לחפש';

  @override
  String get catalogSearchAddToCart => 'הוסף לסל';

  @override
  String get catalogSearchAddToCartError => 'לא ניתן להוסיף לסל. נסו שוב.';

  @override
  String get filterInStockOnly => 'זמינים במלאי בלבד';

  @override
  String get filterMinPrice => 'מחיר מינימלי';

  @override
  String get filterMaxPrice => 'מחיר מקסימלי';

  @override
  String get filterCategoriesLoading => 'טוען קטגוריות...';

  @override
  String get filterAllCategoriesShort => 'כל הקטגוריות';

  @override
  String get filterAllCategories => 'כל הקטגוריות';

  @override
  String get catalogSearchLoadMore => 'טען עוד';

  @override
  String get catalogRequestAccess => 'בקש גישה';

  @override
  String get catalogRequestAccessSuccess => 'הבקשה נשלחה לצוות המכירות.';

  @override
  String get catalogRequestAccessError => 'לא הצלחנו לשלוח בקשה.';

  @override
  String get quickOrderTitle => 'הזמנה מהירה';

  @override
  String get quickOrderPlaceholder => 'סרקו ברקוד או הקלידו SKU/מוצר';

  @override
  String get quickOrderAddButton => 'הוספה';

  @override
  String get quickOrderSubmitDraft => 'שליחת טיוטה';

  @override
  String get quickOrderSubmitDisabled => 'הוסיפו לפחות פריט אחד';

  @override
  String get quickOrderSubmitSuccess => 'הטיוטה נשלחה';

  @override
  String get quickOrderSubmitError => 'שליחה נכשלה';

  @override
  String get quickOrderAddSuccess => 'נוסף לטיוטה';

  @override
  String get quickOrderAddError => 'הוספה נכשלה';

  @override
  String get quickOrderTabQuickOrder => 'הזמנה מהירה';

  @override
  String get quickOrderTabReorders => 'קניות קודמות';

  @override
  String get quickOrderCategoryFilter => 'קטגוריה';

  @override
  String get quickOrderCategoryAll => 'כל הקטגוריות';

  @override
  String get quickOrderTabCatalog => 'קטלוג';

  @override
  String get quickOrderTabCategories => 'קטגוריות';

  @override
  String get quickOrderTabPromotions => 'מבצעים';

  @override
  String get quickOrderTabCart => 'סל';

  @override
  String get quickOrderTabCheckout => 'קופה';

  @override
  String get quickOrderReorderEmpty => 'ההזמנות האחרונות יופיעו כאן בקרוב.';

  @override
  String get quickOrderCategoriesEmpty => 'בחר קטגוריה כדי לסנן את התוצאות.';

  @override
  String get quickOrderCheckoutUnavailable =>
      'הוסיפו פריטים לעגלה לפני מעבר לקופה.';

  @override
  String get quickOrderEmpty => 'אין תוצאות עדיין.';

  @override
  String get quickOrderLoadMore => 'טען עוד תוצאות';

  @override
  String get catalogErrorTitle => 'לא ניתן להציג את הקטלוג';

  @override
  String get catalogErrorMessage =>
      'לא הצלחנו לטעון את הקטלוג כרגע. נסו שוב בעוד רגע.';

  @override
  String get catalogRetry => 'נסו שוב';

  @override
  String get catalogEmptyTitle => 'אין מוצרים זמינים';

  @override
  String get catalogEmptyMessage => 'נסו שוב מאוחר יותר או עדכנו את הסינון.';

  @override
  String get catalogEmptyCta => 'רענון הקטלוג';

  @override
  String get ordersEmptyMessage => 'לאחר שתבצעו הזמנות הן יופיעו כאן.';

  @override
  String get quickOrderBulkHint => 'הוספה מרוכזת (רשימת SKU או חיפוש)';

  @override
  String get quickOrderBulkExample => 'לדוגמה: SKU-1 x2, BAR-998 x5, mint x3';

  @override
  String get quickOrderBulkReviewAction => 'בדיקת רשימה';

  @override
  String get quickOrderBulkPasteCsv => 'הדבק CSV';

  @override
  String get quickOrderBulkClear => 'נקה רשימה';

  @override
  String get quickOrderBulkReviewTitle => 'בדקו לפני הוספה';

  @override
  String get quickOrderBulkReviewEmpty => 'אין פריטים להוספה.';

  @override
  String get quickOrderBulkReviewConfirmPending =>
      'אשרו את ההתאמות לפני ההוספה.';

  @override
  String get quickOrderBulkClipboardEmpty => 'לוח ההעתקה ריק.';

  @override
  String get quickOrderBulkCsvError => 'לא ניתן לנתח את קובץ ה-CSV';

  @override
  String get quickOrderBulkParsing => 'טוען התאמות...';

  @override
  String get quickOrderBulkTableHeaderCode => 'קוד';

  @override
  String get quickOrderBulkTableHeaderQty => 'כמות';

  @override
  String get quickOrderBulkTableHeaderResult => 'תוצאה';

  @override
  String get quickOrderBulkStatusMatched => 'התאמה מדויקת';

  @override
  String get quickOrderBulkStatusAdjusted => 'מותאם';

  @override
  String get quickOrderBulkStatusKeyword => 'התאמת מילות חיפוש';

  @override
  String get quickOrderBulkStatusAmbiguous => 'יותר מדי התאמות';

  @override
  String get quickOrderBulkStatusNotFound => 'לא נמצא';

  @override
  String get quickOrderBulkStatusError => 'שגיאה בשורה';

  @override
  String get quickOrderBulkStatusAdded => 'נוסף';

  @override
  String get quickOrderBulkStatusNeedsReview => 'בחרו מוצר לפני ההוספה';

  @override
  String get quickOrderBulkStatusDetailsLabel => 'פרטים';

  @override
  String get quickOrderBulkSkuLabel => 'מק\"ט';

  @override
  String get quickOrderBulkSelectSuggestion => 'בחירת הצעה';

  @override
  String get quickOrderBulkChangeSelection => 'שינוי בחירה';

  @override
  String get quickOrderBulkSuggestionTitle => 'בחרו מוצר מתאים';

  @override
  String get quickOrderBulkSuggestionCancel => 'סגירה';

  @override
  String get quickOrderBulkStatusMatchedManual => 'ההתאמה אושרה ידנית';

  @override
  String quickOrderBulkAdjustmentPackApplied(
      Object packSize, Object packs, Object units) {
    return 'הומר באמצעות גודל מארז $packSize: $packs x $packSize = $units';
  }

  @override
  String quickOrderBulkAdjustmentPackMissing(Object requested) {
    return 'גודל המארז לא הוגדר; משתמשים בכמות $requested יחידות.';
  }

  @override
  String quickOrderBulkAdjustmentRaisedMoq(
      Object finalValue, Object moq, Object requested) {
    return 'MOQ $moq; הועלה מ-$requested ל-$finalValue';
  }

  @override
  String quickOrderBulkAdjustmentRoundedPack(
      Object finalValue, Object packSize, Object requested) {
    return 'עוגל למכפלה של גודל מארז $packSize: $requested -> $finalValue';
  }

  @override
  String get quickOrderBulkAddAll => 'הוסיפו הכל';

  @override
  String get quickOrderBulkSnackbarAdded => 'השורות נוספו לטיוטה';

  @override
  String get quickOrderBulkUndoLabel => 'בטל';

  @override
  String get quickOrderBulkUndoDone => 'ההוספה בוטלה';

  @override
  String get catalogSearchRecent => 'חיפושים אחרונים';

  @override
  String get catalogSearchClear => 'נקה';

  @override
  String get catalogSearchNoRecent => 'אין חיפושים אחרונים.';

  @override
  String get vendorConsoleTitle => 'קונסולת ספק';

  @override
  String get vendorOrdersTab => 'הזמנות';

  @override
  String get vendorRfqsTab => 'בקשות מחיר';

  @override
  String get vendorOrdersEmptyTitle => 'אין הזמנות ספק';

  @override
  String get vendorOrdersEmptyBody =>
      'ברגע שהזמנות ישויכו לספק שלכם הן יופיעו כאן.';

  @override
  String get vendorOrdersError => 'שגיאה בטעינת הזמנות ספק';

  @override
  String get vendorOrdersRetry => 'נסו שוב';

  @override
  String get vendorOrdersOrderLabel => 'הזמנה';

  @override
  String get vendorOrdersAmountLabel => 'סכום';

  @override
  String get vendorShipmentsTab => 'משלוחים';

  @override
  String get vendorShipmentsFiltersStatus => 'סטטוס';

  @override
  String get vendorShipmentsFiltersReset => 'איפוס';

  @override
  String get vendorShipmentsDateRangePlaceholder => 'טווח תאריכים';

  @override
  String get vendorShipmentsDateRangeClear => 'נקה';

  @override
  String get vendorShipmentsFiltersSearchPlaceholder => 'חיפוש משלוחים';

  @override
  String get vendorShipmentsSearchClear => 'נקה חיפוש';

  @override
  String get vendorShipmentsEmptyTitle => 'אין משלוחים עדיין';

  @override
  String get vendorShipmentsEmptyBody =>
      'משלוחים יופיעו לאחר פיצול ההזמנה למימוש.';

  @override
  String get vendorShipmentsError => 'שגיאה בטעינת משלוחים';

  @override
  String get vendorShipmentsRetry => 'נסו שוב';

  @override
  String get vendorShipmentsOrderLabel => 'מספר הזמנה';

  @override
  String get vendorShipmentsCreatedLabel => 'נוצר ב';

  @override
  String get vendorShipmentsRowTracking => 'מספר מעקב';

  @override
  String get vendorShipmentsTrackingPlaceholder => 'אין מספר מעקב עדיין';

  @override
  String get vendorShipmentsUpdateAction => 'עדכון';

  @override
  String get vendorShipmentsUpdateTitle => 'עדכון משלוח';

  @override
  String get vendorShipmentsUpdateStatusLabel => 'סטטוס';

  @override
  String get vendorShipmentsUpdateTrackingLabel => 'מספר מעקב';

  @override
  String get vendorShipmentsUpdateCancel => 'ביטול';

  @override
  String get vendorShipmentsUpdateSave => 'שמירה';

  @override
  String get vendorShipmentsUpdated => 'המשלוח עודכן';

  @override
  String get vendorShipmentsUpdateFailed => 'עדכון המשלוח נכשל';

  @override
  String get shipmentStatusPending => 'ממתין';

  @override
  String get shipmentStatusReady => 'מוכן';

  @override
  String get shipmentStatusInTransit => 'בדרך';

  @override
  String get shipmentStatusDelivered => 'נמסר';

  @override
  String get shipmentStatusCancelled => 'בוטל';

  @override
  String get productGalleryTitle => 'גלריה';

  @override
  String get productVariantsTitle => 'וריאציות';

  @override
  String get productSpecsTitle => 'פרטי מוצר';

  @override
  String get productAttributesTitle => 'מאפיינים';

  @override
  String get productAddToDraft => 'הוסף לטיוטה';

  @override
  String get productAddedToDraft => 'נוסף לטיוטה';

  @override
  String get productAddFailed => 'הוספה לטיוטה נכשלה';

  @override
  String get productSpecsUom => 'יחידת מידה';

  @override
  String get productSpecsMoq => 'כמות מינימום להזמנה';

  @override
  String get productSpecsLeadTime => 'זמן אספקה';

  @override
  String get productSpecsLeadTimeUnit => 'ימים';

  @override
  String get productSpecsUnknown => 'לא צוין';

  @override
  String get productQtyHeading => 'כמות להזמנה';

  @override
  String get productQtyUomLabel => 'יחידת מידה';

  @override
  String get productQtyUomUnit => 'יחידה';

  @override
  String get productQtyUomCase => 'קרטון';

  @override
  String get productQtyUomPallet => 'משטח';

  @override
  String productQtyUomUnitDetail(Object uom) {
    return 'יחידה • $uom';
  }

  @override
  String productQtyUomCaseDetail(Object count, Object uom) {
    return 'קרטון • $count $uom';
  }

  @override
  String get productQtyUomCaseUnavailable => 'אין נתוני קרטון';

  @override
  String productQtyUomPalletDetail(Object count, Object uom) {
    return 'משטח • $count $uom';
  }

  @override
  String productQtyUomPalletCasesSuffix(Object cases) {
    return '($cases קרטונים)';
  }

  @override
  String get productQtyUomPalletUnavailable => 'אין נתוני משטח';

  @override
  String get productQtyMoqLabel => 'MOQ';

  @override
  String get productQtyStepLabel => 'צעד (מכפלות)';

  @override
  String productQtyErrorBelowMoq(Object moq) {
    return 'יש להזמין לפחות $moq.';
  }

  @override
  String productQtyErrorStep(Object step) {
    return 'הזמנה במכפלות של $step.';
  }

  @override
  String get productQtyUomUnavailableTooltip => 'לא זמין למוצר זה';

  @override
  String get productQtyStepperSemantic => 'כמות להזמנה';

  @override
  String get productQtyStepperIncrease => 'הגדל כמות';

  @override
  String get productQtyStepperDecrease => 'הקטן כמות';

  @override
  String get productPriceBreaksLabel => 'הנחות כמות';

  @override
  String get productPriceBreaksQty => 'כמות';

  @override
  String get productPriceBreaksPrice => 'מחיר יחידה';

  @override
  String get productPriceBreaksLoading => '…';

  @override
  String get productPriceBreaksUnavailable => '—';

  @override
  String get productEffectivePriceLabel => 'מחיר אפקטיבי';

  @override
  String get productEffectivePriceLoading => 'טוען…';

  @override
  String get productEffectivePriceUnavailable => '—';

  @override
  String get pricingContractTag => 'מחיר חוזה';

  @override
  String get pricingSourceContract => 'מחיר חוזה';

  @override
  String get pricingSourcePriceList => 'מחיר מחירון';

  @override
  String get pricingSourceBase => 'מחיר בסיס';

  @override
  String get pricingSourceFallback => 'מחיר סטנדרטי';

  @override
  String get contractPrice => 'מחיר חוזה';

  @override
  String get notInCatalog => 'לא זמין לחשבון שלך';

  @override
  String get notInCatalogShort => 'מחוץ לקטלוג';

  @override
  String get notInCatalogDetail => 'המוצר אינו כלול בקטלוג של הארגון שלך';

  @override
  String get priceBreaks => 'מדרגות מחיר';

  @override
  String get atQty => 'בכמות';

  @override
  String get dash => '—';

  @override
  String get productSelectWarehouse => 'בחר מחסן';

  @override
  String get productWarehousesTitle => 'זמינות במחסנים';

  @override
  String get productWarehousesEmpty => 'אין מחסנים זמינים לגרסה זו.';

  @override
  String get productWarehousePrimary => 'מחסן ראשי';

  @override
  String get productWarehouseQtyLabel => 'מלאי';

  @override
  String get productWarehouseQtyUnknown => 'לא זמין';

  @override
  String get productWarehouseLeadTimeLabel => 'זמן אספקה';

  @override
  String get productWarehouseLeadTimeUnknown => 'לא זמין';

  @override
  String get productSkuLabel => 'מק\"ט';

  @override
  String get productNotFound => 'המוצר אינו זמין';

  @override
  String get adminOrdersTitle => 'ניהול • הזמנות';

  @override
  String get adminOrdersReload => 'רענון';

  @override
  String get adminOrdersFiltersTitle => 'מסננים';

  @override
  String get adminOrdersFiltersSearchLabel => 'חיפוש הזמנות';

  @override
  String get adminOrdersFiltersStatusLabel => 'סטטוס';

  @override
  String get adminOrdersFiltersStatusAll => 'כל הסטטוסים';

  @override
  String get adminOrdersFiltersDateLabel => 'טווח תאריכים';

  @override
  String get adminOrdersFiltersDateClear => 'נקה';

  @override
  String get adminOrdersFiltersRangeAll => 'כל התאריכים';

  @override
  String get adminOrdersFiltersClear => 'איפוס מסננים';

  @override
  String get adminOrdersFiltersActiveHint => 'מסננים פעילים בטבלה שלמטה.';

  @override
  String get adminOrdersErrorTitle => 'לא ניתן לטעון הזמנות';

  @override
  String get adminOrdersEmptyTitle => 'אין הזמנות שתואמות למסננים';

  @override
  String get adminOrdersEmptyBody =>
      'שנו סטטוס, טווח תאריכים או חיפוש כדי לראות תוצאות.';

  @override
  String get adminOrdersTableOrder => 'הזמנה';

  @override
  String get adminOrdersTableCreated => 'נוצר ב';

  @override
  String get adminOrdersTableStatus => 'סטטוס';

  @override
  String get adminOrdersTableTotal => 'סכום';

  @override
  String get adminOrdersTableActions => 'פעולות';

  @override
  String get adminOrdersSplitAction => 'פיצול הזמנה';

  @override
  String get adminOrdersSplitInProgress => 'מפצל...';

  @override
  String get adminOrdersSplitSuccess => 'הפיצול הופעל. המשלוחים יתעדכנו בקרוב.';

  @override
  String adminOrdersSplitSuccessWithCount(Object count) {
    return 'ההזמנה חולקה ל-$count משלוחים לספקים.';
  }

  @override
  String adminOrdersSplitVendorCount(Object count) {
    return 'מספר ספקים בתור: $count';
  }

  @override
  String get adminOrdersSplitEdgeWarning =>
      'סנכרון ה-Edge נכשל. המשלוחים נוצרו דרך ה-RPC.';

  @override
  String adminOrdersSplitFailure(Object error) {
    return 'פיצול ההזמנה נכשל: $error';
  }

  @override
  String get adminReportsTitle => 'ניהול • דוחות';

  @override
  String get adminReportsRecentTitle => 'יצוא אחרונים';

  @override
  String get adminReportsEmptyTitle => 'אין דוחות עדיין';

  @override
  String get adminReportsEmptyBody => 'צרו דוח כדי לקבל קישור חתום להורדה.';

  @override
  String get adminReportsGenerateCsv => 'דוח CSV';

  @override
  String get adminReportsGenerateJson => 'דוח JSON';

  @override
  String get adminReportsDescriptionTitle => 'יצירת קבצי יצוא';

  @override
  String get adminReportsDescriptionBody =>
      'בחרו טווח תאריכים ופורמט יצוא לקבלת קישור חתום. הקישורים פעילים לזמן מוגבל.';

  @override
  String get adminReportsPickRange => 'בחירת טווח';

  @override
  String get adminReportsClearRange => 'ניקוי';

  @override
  String get adminReportsRangeAll => 'כל התאריכים';

  @override
  String get adminReportsSuccess => 'הדוח מוכן.';

  @override
  String get adminReportsSignedUrlTitle => 'הקישור מוכן להורדה';

  @override
  String get adminReportsSignedUrlBody =>
      'העתיקו את הקישור החתום או פתחו אותו בלשונית חדשה.';

  @override
  String get adminReportsSignedUrlClose => 'סגור';

  @override
  String adminReportsFailure(Object error) {
    return 'הדוח נכשל: $error';
  }

  @override
  String get adminReportsOpenFailed => 'לא ניתן לפתוח את הקישור.';

  @override
  String get adminReportsCopySuccess => 'הקישור הועתק ללוח.';

  @override
  String get adminReportsCopyLink => 'העתקת קישור';

  @override
  String get adminReportsOpenLink => 'פתיחת קישור';

  @override
  String get adminReportsGeneratedAt => 'נוצר ב:';

  @override
  String get adminPriceImportTitle => 'ניהול • יבוא מחירונים';

  @override
  String get adminPriceImportReloadVendors => 'רענון ספקים';

  @override
  String get adminPriceImportVendorsFailed => 'טעינת הספקים נכשלה';

  @override
  String get adminPriceImportSelectVendor => 'בחירת ספק';

  @override
  String get adminPriceImportInstructions =>
      'העלו CSV עם העמודות variant_id, min_qty, unit_price.';

  @override
  String get adminPriceImportHeader => 'יבוא מחירי ספק';

  @override
  String get adminPriceImportChooseFile => 'בחירת CSV';

  @override
  String get adminPriceImportImportButton => 'יבוא מחירים';

  @override
  String get adminPriceImportRefreshButton => 'רענון מחירים אפקטיביים';

  @override
  String get adminPriceImportProcessing => 'מעבד...';

  @override
  String get adminPriceImportSelectedFile => 'קובץ שנבחר';

  @override
  String get adminPriceImportPreviewTitle => 'תצוגה מקדימה (שורות ראשונות)';

  @override
  String get adminPriceImportPreviewHint =>
      'בחרו CSV כדי לראות תצוגה מקדימה לפני היבוא.';

  @override
  String get adminPriceImportPreviewEmpty => 'ה-CSV נראה ריק.';

  @override
  String get adminPriceImportSelectVendorFirst => 'בחרו ספק לפני ביצוע היבוא.';

  @override
  String get adminPriceImportSelectFileFirst => 'בחרו קובץ CSV ליבוא.';

  @override
  String adminPriceImportSuccess(Object count) {
    return 'שורות שעובדו: $count';
  }

  @override
  String adminPriceImportFailure(Object error) {
    return 'היבוא נכשל: $error';
  }

  @override
  String get adminPriceImportRefreshSuccess => 'המחירים האפקטיביים רועננו.';

  @override
  String adminPriceImportRefreshFailure(Object error) {
    return 'הרענון נכשל: $error';
  }

  @override
  String get adminPriceImportColumn => 'עמודה';

  @override
  String get checkoutTitle => 'סיום הזמנה';

  @override
  String get checkoutBillToTitle => 'כתובת לחיוב';

  @override
  String get checkoutBillToLabel => 'חשבון חיוב';

  @override
  String get checkoutBillToHint => 'בחרו חשבון חיוב';

  @override
  String get checkoutShipToTitle => 'כתובת למשלוח';

  @override
  String get checkoutShipToLabel => 'מיקום משלוח';

  @override
  String get checkoutShipToHint => 'בחרו מיקום משלוח';

  @override
  String get checkoutPaymentTermsTitle => 'תנאי תשלום';

  @override
  String get checkoutBillToPrimaryTitle => 'חשבון החיוב הראשי';

  @override
  String get checkoutBillToPrimaryDescription => 'הרצל 123, תל אביב';

  @override
  String get checkoutBillToFinanceTitle => 'מחלקת כספים';

  @override
  String get checkoutBillToFinanceDescription => 'מטה הכספים - רוטשילד 56';

  @override
  String get checkoutShipToWarehouseTitle => 'מחסן מרכזי';

  @override
  String get checkoutShipToWarehouseDescription => 'מרכז לוגיסטי, נמל אשדוד';

  @override
  String get checkoutShipToBranchTitle => 'סניף דרום';

  @override
  String get checkoutShipToBranchDescription => 'פארק התעשייה עמק חפר 152';

  @override
  String get checkoutPaymentNet30 => 'שוטף +30';

  @override
  String get checkoutPaymentNet45 => 'שוטף +45';

  @override
  String get checkoutPaymentNet60 => 'שוטף +60';

  @override
  String get checkoutPaymentPayNow => 'תשלום מיידי';

  @override
  String get checkoutSummaryTitle => 'סיכום הזמנה';

  @override
  String get checkoutSummarySubtotal => 'סכום ביניים';

  @override
  String get checkoutSummaryTaxes => 'מע\"מ משוער';

  @override
  String get checkoutSummaryTotal => 'סה\"כ משוער';

  @override
  String get checkoutSummaryError => 'לא הצלחנו לטעון את הסכומים.';

  @override
  String get checkoutSummaryEmpty => 'העגלה ריקה.';

  @override
  String get approvalSendButton => 'שלח לאישור';

  @override
  String get approvalResendButton => 'שליחה חוזרת לאישור';

  @override
  String get approvalSendLoading => 'שולח...';

  @override
  String get approvalSendSuccess => 'הבקשה לאישור נשלחה.';

  @override
  String get approvalSendError => 'לא ניתן לשלוח את בקשת האישור.';

  @override
  String get approvalPendingCta => 'ממתין לאישור';

  @override
  String get approvalSubmitButton => 'בצע הזמנה';

  @override
  String get approvalSubmitLoading => 'שולח...';

  @override
  String get approvalSubmitSuccess => 'ההזמנה הוגשה בהצלחה.';

  @override
  String get approvalSubmitError => 'לא ניתן להגיש את ההזמנה.';

  @override
  String get approvalBannerNotRequired =>
      'אין צורך באישור. ניתן להגיש כאשר תהיו מוכנים.';

  @override
  String get approvalBannerRequires => 'הזמנה זו דורשת אישור לפני שליחה.';

  @override
  String get approvalBannerPending => 'ההזמנה ממתינה לאישור המחליטים.';

  @override
  String get approvalBannerApproved => 'מאושר — אפשר לבצע את ההזמנה.';

  @override
  String get approvalBannerRejected => 'הבקשה נדחתה. עדכנו ושלחו מחדש.';

  @override
  String approvalBannerRejectedWithReason(Object reason) {
    return 'הבקשה נדחתה: $reason';
  }

  @override
  String get approvalBannerError => 'לא ניתן לטעון את סטטוס האישור.';

  @override
  String get approvalRejectedHint =>
      'בדקו את הערות המאשר ועדכנו לפני שליחה חוזרת.';

  @override
  String get approvalsInboxTitle => 'תיבת אישורים';

  @override
  String get approvalsInboxRefresh => 'רענון התיבה';

  @override
  String get approvalsInboxEmptyTitle => 'אין בקשות ממתינות';

  @override
  String get approvalsInboxEmptyBody => 'אתם מעודכנים.';

  @override
  String get approvalsInboxErrorTitle => 'לא ניתן להציג את התיבה';

  @override
  String get approvalsInboxRetry => 'נסו שוב';

  @override
  String get approvalsInboxApprove => 'אשר';

  @override
  String get approvalsInboxReject => 'דחה';

  @override
  String get approvalsInboxApproveSuccess => 'האישור נרשם.';

  @override
  String get approvalsInboxRejectSuccess => 'הדחייה נרשמה.';

  @override
  String get approvalsInboxActionError => 'הפעולה נכשלה. נסו שוב.';

  @override
  String get approvalsInboxRejectDialogTitle => 'דחיית בקשה';

  @override
  String get approvalsInboxRejectDialogLabel => 'הערה';

  @override
  String get approvalsInboxRejectDialogHint => 'הסבירו את הדחייה (לא חובה)';

  @override
  String get approvalsInboxRejectCancel => 'ביטול';

  @override
  String get approvalsInboxRejectConfirm => 'דחו';

  @override
  String approvalsInboxRequestedBy(Object name) {
    return 'הוגשה על ידי: $name';
  }

  @override
  String approvalsInboxBuyer(Object name) {
    return 'לקוח: $name';
  }

  @override
  String approvalsInboxRequestedAt(Object time) {
    return 'הוגשה ב-$time';
  }

  @override
  String get approvalsInboxNoteLabel => 'הערה';

  @override
  String get checkoutDraftMissing => 'לא נמצאה עגלת טיוטה פעילה.';

  @override
  String get checkoutContinueButton => 'סקירה ואישור';

  @override
  String get checkoutMissingBillTo => 'כתובת לחיוב';

  @override
  String get checkoutMissingShipTo => 'כתובת למשלוח';

  @override
  String get checkoutMissingPaymentTerms => 'תנאי תשלום';

  @override
  String checkoutMissingData(Object fields) {
    return 'השלימו את הפרטים: $fields';
  }

  @override
  String get checkoutMissingSeparator => ', ';

  @override
  String get checkoutComingSoon => 'הגשת ההזמנה תושלם בהמשך.';

  @override
  String get cartProceedToCheckout => 'מעבר לסיום הזמנה';

  @override
  String get cartDraftLoadError => 'לא הצלחנו לטעון את עגלת הטיוטה.';

  @override
  String get cartLoadError => 'לא הצלחנו לטעון את העגלה.';

  @override
  String get cartActionFailed => 'פעולת העגלה נכשלה.';

  @override
  String get cartEmptyMessage => 'העגלה שלכם ריקה כרגע.';

  @override
  String get cartBrowseCatalog => 'חזרה לקטלוג';

  @override
  String get cartRequestQuote => 'בקשת הצעת מחיר';

  @override
  String cartVendorLabel(Object vendor) {
    return 'ספק $vendor';
  }

  @override
  String get cartVendorRestricted => 'חלק מהמוצרים של ספק זה דורשים אישור.';

  @override
  String get cartVendorRequestSuccess => 'הבקשה נשלחה לספק.';

  @override
  String get cartRequestAccess => 'בקש גישה';

  @override
  String get cartRequestAccessSuccess => 'הבקשה נשלחה לספק.';

  @override
  String get cartCreateQuoteError => 'יצירת הבקשה נכשלה.';

  @override
  String get cartCreateQuoteSuccess => 'הבקשה נשלחה לספקים.';

  @override
  String get cartRemoveLineTooltip => 'הסרה';

  @override
  String get cartRecommendationsTitle => 'השלימו את ההזמנה';

  @override
  String get cartRecommendationsSubtitle => 'מוצרים שנרכשים יחד לעיתים קרובות';

  @override
  String get cartRecommendationsAdd => 'הוספה';

  @override
  String get cartRecommendationsAdded => 'נוסף לעגלה';

  @override
  String get recommendationFastDelivery => 'משלוח מהיר';

  @override
  String get recommendationLowMoq => 'MOQ נמוך';

  @override
  String get recommendationSmallPack => 'אריזה קטנה';

  @override
  String get recommendationDefault => 'מומלץ';

  @override
  String get commonRetry => 'נסו שוב';

  @override
  String get rfqStatusAwaitingQuotes => 'ממתין להצעות';

  @override
  String get rfqStatusQuoted => 'התקבלו הצעות';

  @override
  String get rfqStatusExpired => 'פג תוקף';

  @override
  String get rfqLatestQuoteStatusLabel => 'סטטוס הצעה אחרונה';

  @override
  String get rfqListTitle => 'בקשות להצעות מחיר';

  @override
  String get rfqCreateCta => 'בקשת RFQ חדשה';

  @override
  String get rfqCustomerStatusLabel => 'סטטוס לקוח';

  @override
  String get rfqVendorStatusLabel => 'סטטוס ספק';

  @override
  String get rfqQuoteSectionTitle => 'הצעות שהתקבלו';

  @override
  String get rfqQuotesEmpty => 'עדיין אין הצעות';

  @override
  String get rfqQuotesEmptyHint => 'הספקים עדיין לא שלחו הצעת מחיר';

  @override
  String get rfqItemsSectionTitle => 'פריטים';

  @override
  String get rfqMessagesSectionTitle => 'שאלות ותשובות';

  @override
  String get rfqSendMessageLabel => 'שאלה או עדכון חדש';

  @override
  String get rfqSendMessage => 'שליחה לספק';

  @override
  String get rfqMessagesEmpty => 'טרם נשלחו הודעות';

  @override
  String get rfqQuoteAmountLabel => 'סכום משוער';

  @override
  String get rfqQuoteVendorLabel => 'ספק';

  @override
  String get rfqQuoteTermsLabel => 'תנאים';

  @override
  String get rfqLastUpdatedLabel => 'נוצר בתאריך';

  @override
  String get rfqNeedByLabel => 'נדרש עד';

  @override
  String get rfqItemQuantityLabel => 'כמות';

  @override
  String get rfqItemNotesLabel => 'הערות';

  @override
  String get rfqItemCountLabel => 'מספר פריטים';

  @override
  String get rfqQuoteCountLabel => 'הצעות שהתקבלו';

  @override
  String get rfqResubmit => 'שלח/י שוב לאישור';

  @override
  String get rfqItemFallbackLabel => 'פריט ללא שם';

  @override
  String get rfqAcceptQuote => 'קבלת הצעה';

  @override
  String get rfqMessageAuthorVendor => 'מענה ספק';

  @override
  String get rfqMessageAuthorAdmin => 'מערכת';

  @override
  String get rfqMessageAuthorCustomer => 'הודעת לקוח';

  @override
  String get rfqQuoteLabel => 'הצעה';

  @override
  String get rfqQuoteDateLabel => 'תאריך';

  @override
  String get rfqListError => 'לא ניתן היה לטעון בקשות RFQ.';

  @override
  String get rfqRetry => 'רענון';

  @override
  String get rfqEmptyTitle => 'לא נמצאו בקשות פעילות';

  @override
  String get rfqEmptyCta => 'יצירת בקשה חדשה';

  @override
  String get rfqVendorListTitle => 'בקשות לקוחות (RFQ)';

  @override
  String get rfqVendorMessageLabel => 'תגובה לרוכש';

  @override
  String get rfqVendorSendMessage => 'שליחת הודעה';

  @override
  String get rfqVendorMessageEmpty => 'אין הודעות עבור בקשה זו';

  @override
  String get rfqVendorThreadTitle => 'שרשור הודעות';

  @override
  String get rfqVendorQuoteDetailsTitle => 'פרטי הצעה';

  @override
  String get rfqVendorQuoteRejectedTitle => 'הבקשה סומנה כנמחקה';

  @override
  String get rfqVendorQuoteRejectedBody =>
      'ניתן לחזור ולמלא הצעה חדשה במידת הצורך.';

  @override
  String get rfqVendorSubmitQuote => 'שליחת הצעת מחיר';

  @override
  String get rfqVendorRejectQuote => 'דחיית בקשה';

  @override
  String get rfqVendorSuccessSnack => 'הצעת מחיר נשלחה בהצלחה';

  @override
  String get rfqVendorRejectSuccess => 'הבקשה נדחתה בהצלחה';

  @override
  String get rfqVendorSubmitError => 'שליחת ההצעה נכשלה';

  @override
  String get rfqVendorRejectError => 'דחיית הבקשה נכשלה';

  @override
  String get rfqVendorMessageErrorEmpty => 'נא להזין הודעה';

  @override
  String get rfqVendorMessageSendFailed => 'שליחת ההודעה נכשלה';

  @override
  String get rfqVendorUnitPriceLabel => 'מחיר יחידה (₪)';

  @override
  String get rfqVendorMOQLabel => 'MOQ';

  @override
  String get rfqVendorStepQtyLabel => 'כמות מדרגה';

  @override
  String get rfqVendorLeadTimeLabel => 'Lead Time (ימים)';

  @override
  String get rfqVendorCustomerTermsLabel => 'תנאי לקוח';

  @override
  String get rfqVendorListError => 'לא ניתן היה לטעון בקשות לספק.';

  @override
  String get rfqVendorEmptyTitle => 'אין בקשות בהמתנה כרגע';

  @override
  String get rfqVendorPriceRequired => 'נדרש מחיר עבור';

  @override
  String get rfqResubmitFailed => 'שליחה מחדש נכשלה';

  @override
  String get rfqMessageErrorEmpty => 'נא להזין הודעה';

  @override
  String get rfqMessageSendFailed => 'שליחת ההודעה נכשלה';

  @override
  String get rfqAcceptQuoteFailed => 'קבלת ההצעה נכשלה';

  @override
  String get billingTitle => 'חיובים';

  @override
  String get openDebtsTitle => 'חובות פתוחים';

  @override
  String get invoicesTitle => 'חשבוניות פתוחות';

  @override
  String get aging => 'גיל חוב';

  @override
  String get totalDue => 'יתרה לתשלום';

  @override
  String get download => 'הורדה';

  @override
  String get statement => 'דוח';

  @override
  String get export => 'ייצוא';

  @override
  String get openDebtsEmpty => 'אין חובות פתוחים';

  @override
  String get openDebtsEmptyHint => 'אין יתרות לתשלום כרגע.';

  @override
  String get openDebtsError => 'לא ניתן לטעון יתרות';

  @override
  String get openDebtsDownloadStatement => 'הורדת דוח';

  @override
  String get openDebtsBucket_0_30 => '0-30 ימים';

  @override
  String get openDebtsBucket_31_60 => '31-60 ימים';

  @override
  String get openDebtsBucket_61_90 => '61-90 ימים';

  @override
  String get openDebtsBucket_90_plus => '90+ ימים';

  @override
  String get invoicesError => 'לא ניתן לטעון חשבוניות';

  @override
  String get invoicesEmpty => 'אין חשבוניות פתוחות';

  @override
  String get invoicesEmptyHint => 'כאשר יופקו חשבוניות הן יופיעו כאן.';

  @override
  String get promotionsTitle => 'מבצעים';

  @override
  String get promotionsEmpty => 'אין מבצעים פעילים כרגע.';

  @override
  String get promotionsError => 'לא ניתן לטעון את רשימת המבצעים.';

  @override
  String promotionsValidUntil(Object date) {
    return 'בתוקף עד $date';
  }

  @override
  String promotionsTermsApply(Object terms) {
    return 'תנאים חלים $terms';
  }

  @override
  String get viewProducts => 'ראה מוצרים';

  @override
  String get validUntil => 'בתוקף עד';

  @override
  String get termsApply => 'תנאים חלים';

  @override
  String get rfq_title => 'בקשת הצעת מחיר';

  @override
  String get rfq_create => 'צור בקשה';

  @override
  String get rfq_add_line => 'הוסף שורה';

  @override
  String get rfq_submit => 'שליחת בקשה';

  @override
  String get rfq_created => 'בקשת ההצעת מחיר נשלחה לספקים';

  @override
  String get rfq_error => 'לא הצלחנו לשלוח את הבקשה. נסו שוב.';

  @override
  String get rfq_notes_label => 'הערות לספק';

  @override
  String get rfq_delivery_date => 'תאריך אספקה מבוקש';

  @override
  String get rfq_select_date => 'בחרו תאריך';

  @override
  String get rfq_currency => 'מטבע';

  @override
  String get rfq_product => 'מוצר';

  @override
  String get rfq_uom => 'יחידת מידה';

  @override
  String get rfq_quantity => 'כמות';

  @override
  String get field_required => 'שדה חובה';

  @override
  String get rfq_qty_invalid => 'יש להזין כמות חיובית';

  @override
  String get rfq_target_price => 'מחיר יעד ליחידה';

  @override
  String get rfq_sku_label => 'מק\"ט';

  @override
  String get quote_title => 'הצעת מחיר';

  @override
  String get quote_valid_until => 'בתוקף עד';

  @override
  String get quote_empty => 'ממתינים להצעות ספקים';

  @override
  String get rfq_unit_price => 'מחיר ליחידה';

  @override
  String get rfq_lead_time => 'זמן אספקה (ימים)';

  @override
  String get rfq_to_order => 'המרה להזמנה';

  @override
  String get rfq_to_order_success => 'נוצרה הזמנה מההצעה';

  @override
  String get rfq_to_order_error => 'לא ניתן להמיר את ההצעה להזמנה';

  @override
  String get ship_from => 'משלוח מ';

  @override
  String get eta => 'ETA - זמן הגעה משוער';

  @override
  String get allow_backorder => 'אפשר הזמנה עתידית';

  @override
  String get warehouse_picker => 'בחירת מחסן';

  @override
  String get in_stock => 'במלאי';

  @override
  String get out_of_stock => 'אזל מהמלאי';

  @override
  String get low_stock => 'מלאי נמוך';

  @override
  String get backorder_available => 'זמין להזמנה עתידית';

  @override
  String get shipping_method => 'שיטת משלוח';

  @override
  String get rate => 'תעריף';

  @override
  String get asn_created => 'הודעת משלוח נוצרה';

  @override
  String get tracking => 'מעקב';

  @override
  String get pod_received => 'אישור קבלה התקבל';

  @override
  String get payment_terms => 'תנאי תשלום';

  @override
  String get escrow_held => 'סכום בנאמנות';

  @override
  String get escrow_released => 'סכום שוחרר מנאמנות';

  @override
  String get statement_export => 'ייצוא דוח חשבון';

  @override
  String get payout_run => 'הפעלת תשלום';

  @override
  String get net_terms => 'תנאי שוטף';

  @override
  String get days_until_due => 'ימים עד תשלום';

  @override
  String get overdue => 'באיחור';

  @override
  String get moq_minimum => 'כמות מינימום';

  @override
  String get quantity_not_multiple => 'הכמות חייבת להיות מכפלה של';

  @override
  String get uom_adjusted_info => 'הכמות הותאמה ליחידת מידה';

  @override
  String get hidden_for_your_account => 'מוסתר עבור החשבון שלך';

  @override
  String get private_catalog_only => 'זמין רק בקטלוג פרטי';

  @override
  String get adminDashboardUsersCta => 'ניהול משתמשים';

  @override
  String get adminDashboardUsersDescription =>
      'הזמנת אדמינים וניהול הרשאות גישה';

  @override
  String get adminUsersTitle => 'ניהול משתמשים';

  @override
  String get adminUsersSubtitle =>
      'הזמנה, השבתה וניטור של הרשאות המשתמשים במערכת.';

  @override
  String get adminUsersSearchHint => 'חיפוש לפי שם או אימייל';

  @override
  String get adminUsersFilterAll => 'כולם';

  @override
  String get adminUsersFilterActive => 'פעילים';

  @override
  String get adminUsersFilterDisabled => 'מושבתים';

  @override
  String get adminUsersInviteCta => 'הזמן משתמש';

  @override
  String get adminUsersInviteTitle => 'הזמנת משתמש חדש';

  @override
  String get adminUsersInviteEmailLabel => 'אימייל';

  @override
  String get adminUsersInviteFullNameLabel => 'שם מלא (לא חובה)';

  @override
  String get adminUsersInviteRoleLabel => 'תפקיד';

  @override
  String get adminUsersInviteCancel => 'ביטול';

  @override
  String get adminUsersInviteSubmit => 'שליחת הזמנה';

  @override
  String get adminUsersInviteEmailError =>
      'נא להזין כתובת אימייל ארגונית תקינה';

  @override
  String get adminUsersInviteRoleError => 'נא לבחור תפקיד';

  @override
  String get adminUsersEmptyTitle => 'אין משתמשים עדיין';

  @override
  String get adminUsersEmptySubtitle =>
      'השתמשו בכפתור ההזמנה כדי להוסיף את המשתמש הראשון.';

  @override
  String get adminUsersDeactivateCta => 'השבתה';

  @override
  String get adminUsersActivateCta => 'הפעלה';

  @override
  String get adminUsersStatusDisabled => 'מושבת';

  @override
  String get adminUsersStatusActive => 'פעיל';

  @override
  String get adminUsersStatusHeader => 'סטטוס';

  @override
  String get adminUsersActionsHeader => 'פעולות';

  @override
  String get adminUsersIdentityHeader => 'משתמש';

  @override
  String get adminUsersRoleHeader => 'תפקיד';

  @override
  String get adminUsersLastSignIn => 'כניסה אחרונה';

  @override
  String get adminUsersInvitedAt => 'תאריך הזמנה';

  @override
  String get adminUsersDeactivateTitle => 'השבתת משתמש';

  @override
  String get adminUsersDeactivateMessage =>
      'הגישה של המשתמש תיחסם מיידית. ניתן יהיה להחזירה מאוחר יותר.';

  @override
  String get adminUsersDeactivateReasonHint => 'סיבת השבתה (לא חובה)';

  @override
  String get adminUsersDeactivateConfirm => 'השבתת משתמש';

  @override
  String get adminUsersActivateTitle => 'הפעלת משתמש';

  @override
  String get adminUsersActivateMessage => 'להחזיר למשתמש זה גישה למערכת?';

  @override
  String get adminUsersActivateConfirm => 'הפעלת משתמש';

  @override
  String get adminUsersQueuedSnack =>
      'הפעולה נכנסה לתור ותתבצע עם חזרת הקישוריות.';

  @override
  String adminUsersInviteSuccess(Object email) {
    return 'הזמנה נשלחה ל-$email';
  }

  @override
  String adminUsersDeactivateSuccess(Object email) {
    return '$email הושבת';
  }

  @override
  String adminUsersActivateSuccess(Object email) {
    return '$email הופעל מחדש';
  }

  @override
  String adminUsersError(Object message) {
    return 'הפעולה נכשלה: $message';
  }

  @override
  String get adminUsersRefresh => 'רענון';

  @override
  String get adminUsersNever => 'מעולם לא';

  @override
  String get adminUserRoleAdmin => 'מנהל מערכת';

  @override
  String get adminUserRoleVendorAdmin => 'מנהל ספק';

  @override
  String get adminUserRoleVendorUser => 'משתמש ספק';

  @override
  String get adminUserRoleCustomerAdmin => 'מנהל לקוח';

  @override
  String get adminUserRoleBuyer => 'קניין';
}
