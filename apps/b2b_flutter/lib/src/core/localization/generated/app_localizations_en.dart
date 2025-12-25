// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ashachar Marketplace';

  @override
  String get loginAppBarTitle => 'Ashachar Marketplace';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Enter your email and password to continue.';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginButtonLoading => 'Signing in...';

  @override
  String get loginDemoCta => 'Try the demo';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailRequired => 'Email is required.';

  @override
  String get loginEmailInvalid => 'Enter a valid email address.';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Password is required.';

  @override
  String get loginPasswordTooShort => 'The password is too short.';

  @override
  String get loginErrorInvalidCredentials =>
      'The email or password is incorrect. Try again.';

  @override
  String get loginErrorRateLimited =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Your email is not confirmed yet. Check your inbox for the verification message.';

  @override
  String get loginErrorGeneric =>
      'We couldn\'t sign you in. Please try again shortly.';

  @override
  String get loginErrorUnexpected =>
      'Something went wrong. Try again in a moment.';

  @override
  String get loginErrorDemoUnavailable =>
      'Demo credentials are not available in this environment.';

  @override
  String get loginErrorDemoGeneric =>
      'We couldn\'t sign in to the demo. Try again.';

  @override
  String get signOut => 'Sign out';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get signInSwitchUser => 'Sign in / switch user';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeGreeting => 'Welcome back!';

  @override
  String get homeGreetingSubtitle => 'What would you like to do today?';

  @override
  String get homeSearchPlaceholder => 'Search products';

  @override
  String get homeSearchTooltip => 'Search';

  @override
  String get homeMenuTooltip => 'Menu';

  @override
  String get homeCampaignTitle => 'Promotions 2025';

  @override
  String get homeCampaignSubtitle =>
      'Seasonal bundles and tailored offers for your business.';

  @override
  String get homeCampaignCta => 'Browse deals';

  @override
  String get homeCurrentOrderTitle => 'Current order';

  @override
  String get homeCurrentOrderEmpty => 'You don\'t have an active draft yet.';

  @override
  String get homeCurrentOrderLoading => 'Updating draft...';

  @override
  String get homeCurrentOrderValue => 'Order value';

  @override
  String homeCurrentOrderItems(Object count) {
    return '$count items';
  }

  @override
  String get homeContinueOrder => 'Continue order';

  @override
  String get homeTilePromotions => 'Promotions';

  @override
  String get homeTilePromotionsDescription =>
      'Curated discounts and seasonal bundles';

  @override
  String get homeTileCatalog => 'Catalog';

  @override
  String get homeTileCatalogDescription => 'Browse the full assortment';

  @override
  String get homeTileQuickOrder => 'Quick order';

  @override
  String get homeTileQuickOrderDescription => 'Fast entry for repeat items';

  @override
  String get homeTileCart => 'Order cart';

  @override
  String get homeTileCartDescription => 'Review your draft order';

  @override
  String get homeTileOrders => 'My orders';

  @override
  String get homeTileOrdersDescription => 'Track statuses and delivery';

  @override
  String get homeTileApprovals => 'Approvals';

  @override
  String get homeTileApprovalsDescription => 'Requests awaiting your review';

  @override
  String get homeReorderTitle => 'Reorder shortcuts';

  @override
  String get homeSavedListsShortcut => 'Saved lists';

  @override
  String get homeViewAllOrders => 'View all orders';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get aboutTitle => 'About Ashachar';

  @override
  String get aboutSubtitle =>
      'A B2B marketplace for smart, multi-vendor procurement.';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutMissionTitle => 'Our mission';

  @override
  String get aboutMissionBody =>
      'Make B2B purchasing fast, transparent, and reliable — from sourcing to delivery.';

  @override
  String get aboutHighlightsTitle => 'What you can do';

  @override
  String get aboutHighlightOrdersTitle => 'Order in minutes';

  @override
  String get aboutHighlightOrdersBody =>
      'Consolidate vendors, manage approvals, and track every shipment.';

  @override
  String get aboutHighlightPricingTitle => 'Smart pricing';

  @override
  String get aboutHighlightPricingBody =>
      'Customer-specific pricing, promos, and contract rates.';

  @override
  String get aboutHighlightInsightsTitle => 'Operational insights';

  @override
  String get aboutHighlightInsightsBody =>
      'Dashboards and alerts that keep the supply chain on track.';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutContactPhoneLabel => 'Phone';

  @override
  String get aboutContactPhoneValue => '03-1234567';

  @override
  String get aboutContactEmailLabel => 'Email';

  @override
  String get aboutContactEmailValue => 'support@ashachar.co.il';

  @override
  String get aboutContactHoursLabel => 'Hours';

  @override
  String get aboutContactHoursValue => 'Sun-Thu 08:00-17:00';

  @override
  String get aboutLegalTitle => 'Legal';

  @override
  String get aboutLegalTerms => 'Terms of use';

  @override
  String get aboutLegalPrivacy => 'Privacy policy';

  @override
  String get aboutLegalSoon => 'Coming soon';

  @override
  String get customerCompanyProfileTitle => 'Customer profile';

  @override
  String get customerCompanyProfileTabOverview => 'Overview';

  @override
  String get customerCompanyProfileTabOrders => 'Orders';

  @override
  String get customerCompanyProfileTabQuotes => 'Quotes';

  @override
  String get customerCompanyProfileTabCredit => 'Credit';

  @override
  String get customerCompanyProfileTabContracts => 'Contracts';

  @override
  String get customerCompanyProfileComingSoon => 'coming soon';

  @override
  String get customerCompanyProfileLoadError => 'Unable to load profile.';

  @override
  String get customerCompanyProfileTierLabel => 'Tier';

  @override
  String get customerCompanyProfileIndustryLabel => 'Industry';

  @override
  String get customerCompanyProfileSalesRepLabel => 'Sales Rep';

  @override
  String get customerCompanyProfileEmailLabel => 'Email';

  @override
  String get customerCompanyProfileContactTitle => 'Contact details';

  @override
  String get adminDashboardTitle => 'Admin workspace';

  @override
  String get adminDashboardOverviewHeading => 'Business overview';

  @override
  String get adminDashboardQuickActionsHeading => 'Quick actions';

  @override
  String get adminDashboardSignalsHeading => 'Operational signals';

  @override
  String get adminDashboardTotalGmv => 'Total GMV';

  @override
  String get adminDashboardTotalGmvTrend => '+12.4% vs. last month';

  @override
  String get adminDashboardActiveVendors => 'Active vendors';

  @override
  String get adminDashboardActiveVendorsTrend => '2 onboarding right now';

  @override
  String get adminDashboardApprovals => 'Pending approvals';

  @override
  String get adminDashboardApprovalsTrend => 'SLA 3h remaining';

  @override
  String get adminDashboardSupportCta => 'Open support inbox';

  @override
  String get adminDashboardSupportDescription =>
      'Track escalations and SLA breaches';

  @override
  String get adminDashboardTaxSettingsCta => 'Configure tax rules';

  @override
  String get adminDashboardTaxSettingsDescription =>
      'VAT, exemptions, export profiles';

  @override
  String get adminDashboardAuditLogCta => 'Review audit log';

  @override
  String get adminDashboardAuditLogDescription =>
      'Latest configuration changes & impersonations';

  @override
  String get adminDashboardVendorsCta => 'Manage vendor queue';

  @override
  String get adminDashboardVendorsDescription =>
      'Approve or reject onboarding requests';

  @override
  String get adminDashboardSupportAlerts => 'Support alerts';

  @override
  String get adminDashboardComplianceAlerts => 'Compliance & approvals';

  @override
  String get adminDashboardSupportAlert1Title => '#2034 Login issue';

  @override
  String get adminDashboardSupportAlert1Subtitle =>
      'SLA breach in 12m • Assigned to Support Team';

  @override
  String get adminDashboardSupportAlert2Title => '#2033 Order not delivered';

  @override
  String get adminDashboardSupportAlert2Subtitle =>
      'Escalated to Logistics • ETA 4h';

  @override
  String get adminDashboardComplianceAlert1Title =>
      '2 approval requests awaiting admin review';

  @override
  String get adminDashboardComplianceAlert1Subtitle =>
      'Net 60 override • Vendor onboarding';

  @override
  String get adminDashboardComplianceAlert2Title =>
      '1 tax rule expiring this month';

  @override
  String get adminDashboardComplianceAlert2Subtitle =>
      'IL Non-profit exemption – refresh required';

  @override
  String get adminDashboardNotes =>
      'Demo metrics for illustration purposes only.';

  @override
  String get adminAuditLogTitle => 'Audit log';

  @override
  String get adminAuditLogFiltersApplied => 'Filters applied to audit log.';

  @override
  String get adminAuditLogExportStarted => 'Export started in the background.';

  @override
  String get adminAuditLogLoadError => 'Failed to load audit log.';

  @override
  String get adminAuditLogEmpty => 'No audit activity recorded.';

  @override
  String get adminAuditLogFilterDateRangeLabel => 'Date range';

  @override
  String get adminAuditLogFilterDateRangeHint => 'Last 7 days';

  @override
  String get adminAuditLogFilterUserLabel => 'User';

  @override
  String get adminAuditLogFilterUserHint => 'Search by user';

  @override
  String get adminAuditLogFilterModuleLabel => 'Module';

  @override
  String get adminAuditLogFilterModuleHint => 'Any module';

  @override
  String get adminAuditLogFilterActionLabel => 'Action';

  @override
  String get adminAuditLogFilterActionHint => 'Action type';

  @override
  String get adminAuditLogExport => 'Export';

  @override
  String get adminAuditLogApplyFilters => 'Apply filters';

  @override
  String get adminAuditLogStatusSuccess => 'Success';

  @override
  String get adminAuditLogStatusWarning => 'Warning';

  @override
  String get adminAuditLogStatusError => 'Error';

  @override
  String get adminContactTitle => 'Get in touch';

  @override
  String get adminContactFieldName => 'Name';

  @override
  String get adminContactFieldEmail => 'Email';

  @override
  String get adminContactFieldCompany => 'Company';

  @override
  String get adminContactFieldPhone => 'Phone';

  @override
  String get adminContactSubmit => 'Send message';

  @override
  String get adminDockSchedulingTitle => 'Dock scheduling';

  @override
  String get adminDockFilterDateRange => 'Date range';

  @override
  String get adminDockFilterWarehouse => 'Warehouse';

  @override
  String get adminDockFilterCarrier => 'Carrier';

  @override
  String get adminDockFilterStatus => 'Status';

  @override
  String get adminDockPanelTitle => 'Dock / Door';

  @override
  String get adminDockPanelTime => 'Time window';

  @override
  String get adminDockPanelMode => 'Mode';

  @override
  String get adminDockPanelSpecialInstructions => 'Special instructions';

  @override
  String get adminDockPanelLiftGate => 'Lift gate';

  @override
  String get adminDockPanelCallOnArrival => 'Call on arrival';

  @override
  String get adminDockReserve => 'Reserve slot';

  @override
  String get adminDockLegendOutForDelivery => 'Out for delivery';

  @override
  String get adminDockLegendDelivered => 'Delivered';

  @override
  String get adminDockLegendCapacity => 'Capacity';

  @override
  String get adminDockLegendScheduled => 'Scheduled';

  @override
  String get adminDockActionTrack => 'Track';

  @override
  String get adminDockActionContact => 'Contact';

  @override
  String get adminDockActionReschedule => 'Reschedule';

  @override
  String get adminDockActionPrintBol => 'Print BOL';

  @override
  String get adminPayablesTitle => 'Accounts payable run';

  @override
  String get adminPayablesBankAccount => 'Bank account';

  @override
  String get adminPayablesScheduleDate => 'Schedule date';

  @override
  String get adminPayablesFilterVendors => 'Filter invoices';

  @override
  String get adminPayablesPaymentMethod => 'Payment method';

  @override
  String get adminPayablesChecksum => 'Checksum';

  @override
  String get adminPayablesSchedule => 'Schedule payments';

  @override
  String get adminPayablesTotal => 'Total invoice';

  @override
  String get adminPayablesDueDates => 'Due dates';

  @override
  String get adminExportsTitle => 'Data export';

  @override
  String get adminExportsDataset => 'Dataset';

  @override
  String get adminExportsDateRange => 'Date range';

  @override
  String get adminExportsSelectFields => 'Select fields...';

  @override
  String get adminExportsFormat => 'Format';

  @override
  String get adminExportsDestination => 'Destination';

  @override
  String get adminExportsFrequencyLabel => 'Frequency';

  @override
  String get adminExportsOnce => 'Once';

  @override
  String get adminExportsDaily => 'Daily';

  @override
  String get adminExportsWeekly => 'Weekly';

  @override
  String get adminExportsIncludeFilters => 'Include filters';

  @override
  String get adminExportsLastExports => 'Last exports';

  @override
  String get adminExportsCompleted => 'Completed';

  @override
  String get adminExportsPending => 'Pending';

  @override
  String get adminExportsDownload => 'Download';

  @override
  String get adminApprovalTitle => 'Order approval';

  @override
  String get adminApprovalCartItems => 'Cart items';

  @override
  String get adminApprovalSubtotal => 'Subtotal';

  @override
  String get adminApprovalFlagOverBudget => 'Over budget';

  @override
  String get adminApprovalFlagNonPreferred => 'Non-preferred vendor';

  @override
  String get adminApprovalFlagSplit => 'Split by warehouse';

  @override
  String get adminApprovalBudgetHeading => 'Budget utilization';

  @override
  String get adminApprovalAddComment => 'Add a comment...';

  @override
  String get adminApprovalApprove => 'Approve';

  @override
  String get adminApprovalReject => 'Reject';

  @override
  String get adminApprovalRejectReason => 'Reject reason required';

  @override
  String get adminApprovalViewCart => 'View cart items';

  @override
  String get adminApprovalSla => 'SLA';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersTableOrder => 'Order';

  @override
  String get ordersTableCreated => 'Created';

  @override
  String get ordersTableStatus => 'Status';

  @override
  String get ordersTableTotal => 'Total';

  @override
  String get savedListsTitle => 'Saved lists';

  @override
  String get newList => 'New list';

  @override
  String get reorderTitle => 'Quick reorder';

  @override
  String get addAll => 'Add all';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String lastUpdated(Object timestamp) {
    return 'Last updated $timestamp';
  }

  @override
  String get savedListsEmptyTitle => 'No saved lists yet';

  @override
  String get savedListsEmptyMessage =>
      'Create lists to quickly add repeat items.';

  @override
  String get savedListsErrorTitle => 'Saved lists unavailable';

  @override
  String savedListsAddAllSuccess(Object itemCount, Object listName) {
    return 'Added all $itemCount items from \"$listName\"';
  }

  @override
  String get reorderEmptyTitle => 'No items to reorder';

  @override
  String get reorderEmptyMessage =>
      'Select a previous order to add its items again.';

  @override
  String get reorderErrorTitle => 'Reorder unavailable';

  @override
  String reorderTotalUnitsLabel(Object count) {
    return 'Total units: $count';
  }

  @override
  String get reorderTableItem => 'Item';

  @override
  String get reorderTableSku => 'SKU';

  @override
  String get reorderTableQuantity => 'Quantity';

  @override
  String reorderAddAllSuccess(Object itemCount) {
    return 'Added $itemCount items to cart';
  }

  @override
  String get cartTitle => 'Cart';

  @override
  String get vendorQueue => 'Vendor Approval Queue';

  @override
  String get reports => 'Reports';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyCta => 'Go to catalog';

  @override
  String get ordersError => 'Failed to load orders';

  @override
  String get ordersRetry => 'Try again';

  @override
  String get ordersRfqsTooltip => 'Requests for quotes';

  @override
  String get ordersStatusDraft => 'Draft';

  @override
  String get ordersStatusProcessing => 'Processing';

  @override
  String get ordersStatusSubmitted => 'Submitted';

  @override
  String get ordersStatusPendingApproval => 'Pending approval';

  @override
  String get ordersStatusApproved => 'Approved';

  @override
  String get ordersStatusRejected => 'Rejected';

  @override
  String get ordersStatusCompleted => 'Completed';

  @override
  String get ordersStatusShipped => 'Shipped';

  @override
  String get ordersStatusCancelled => 'Cancelled';

  @override
  String get ordersStatusInTransit => 'In transit';

  @override
  String get statusPlaced => 'Placed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusRequested => 'Requested';

  @override
  String get statusReceived => 'Received';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get orderDetailTitle => 'Order Detail';

  @override
  String get orderDetailLines => 'Order lines';

  @override
  String get orderDetailShipments => 'Shipments';

  @override
  String get orderDetailNoLines => 'No lines for this order';

  @override
  String get orderDetailNoShipments => 'Shipments are not ready yet';

  @override
  String get orderDetailSubtotal => 'Subtotal';

  @override
  String get orderDetailTax => 'VAT';

  @override
  String get orderDetailTotal => 'Total';

  @override
  String get statusLabel => 'Status';

  @override
  String get subtotalShort => 'Subtotal';

  @override
  String get vatShort => 'VAT';

  @override
  String get totalShort => 'Total';

  @override
  String get reorder => 'Reorder';

  @override
  String get order_detail_reorder_btn => 'Reorder order';

  @override
  String orderDetailReorderError(Object message) {
    return 'Couldn\'t reorder this order. Error: $message';
  }

  @override
  String get orderDetailSkuPrefix => 'SKU';

  @override
  String get orderDetailLineSkuLabel => 'SKU';

  @override
  String get orderDetailLineQuantityLabel => 'Quantity';

  @override
  String get orderDetailLineUnitPriceLabel => 'Unit price';

  @override
  String get orderDetailTrackingLabel => 'Tracking';

  @override
  String get orderDetailCreatedAt => 'Created at';

  @override
  String get orderCancelTitle => 'Cancel order';

  @override
  String get orderCancelSubtitle =>
      'You can cancel this order before it ships.';

  @override
  String get orderCancelButton => 'Cancel order';

  @override
  String get orderCancelStatusTitle => 'Cancellation';

  @override
  String get orderCancelStatusSubtitle => 'This order has been cancelled.';

  @override
  String orderCancelCancelledAt(Object date) {
    return 'Cancelled on $date';
  }

  @override
  String orderCancelReasonValue(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get orderCancelDialogTitle => 'Cancel this order?';

  @override
  String get orderCancelDialogMessage =>
      'Tell us why you are cancelling (optional).';

  @override
  String get orderCancelReasonLabel => 'Reason (optional)';

  @override
  String get orderCancelDialogKeep => 'Keep order';

  @override
  String get orderCancelDialogConfirm => 'Cancel order';

  @override
  String get orderCancelQueued =>
      'Saved offline. We\'ll cancel when you\'re back online.';

  @override
  String get orderCancelSuccess => 'Order cancelled.';

  @override
  String get orderCancelError => 'Unable to cancel order.';

  @override
  String get orderReturnsTitle => 'Returns';

  @override
  String get orderReturnsSubtitle => 'Request a return for delivered items.';

  @override
  String get orderReturnsNotEligible => 'Returns open after shipment.';

  @override
  String get orderReturnsFetchError =>
      'Return history is currently unavailable.';

  @override
  String get orderReturnsReturnableLabel => 'Returnable';

  @override
  String get orderReturnsRequestButton => 'Request return';

  @override
  String get orderReturnsExistingLabel => 'Existing requests';

  @override
  String get orderReturnsNoReturnable => 'No returnable quantity left.';

  @override
  String get orderReturnsDialogTitle => 'Request a return';

  @override
  String orderReturnsMaxHint(Object max) {
    return 'Max $max';
  }

  @override
  String get orderReturnsReasonLabel => 'Reason (optional)';

  @override
  String get orderReturnsReasonHint =>
      'Tell us why you are returning this item.';

  @override
  String get orderReturnsCancel => 'Cancel';

  @override
  String get orderReturnsSubmit => 'Submit request';

  @override
  String get orderReturnsQueued =>
      'Saved offline. We\'ll submit when you\'re back online.';

  @override
  String get orderReturnsSubmitted => 'Return request submitted.';

  @override
  String get orderReturnsError => 'Unable to submit return request.';

  @override
  String get orderRatingTitle => 'Rate your vendors';

  @override
  String get orderRatingSubtitle =>
      'Help other buyers by sharing your feedback.';

  @override
  String get orderRatingCommentLabel => 'Comment (optional)';

  @override
  String get orderRatingCommentHint =>
      'Share what worked well or what to improve.';

  @override
  String get orderRatingSubmit => 'Submit rating';

  @override
  String get orderRatingSubmitted => 'Thanks for your feedback.';

  @override
  String get orderRatingQueued =>
      'Saved offline. We\'ll submit when you\'re back online.';

  @override
  String orderRatingSummary(Object avg, Object count) {
    return '$avg / $count ratings';
  }

  @override
  String get orderRatingEmptySummary => 'No ratings yet';

  @override
  String get orderRatingLoadingSummary => 'Loading ratings...';

  @override
  String get orderRatingSummaryError => 'Ratings unavailable';

  @override
  String get orderRatingError => 'Unable to submit rating.';

  @override
  String get supportAiTitle => 'AI Support Assistant';

  @override
  String get supportAiSubtitle =>
      'Ask about orders, invoices, or vendor policies.';

  @override
  String get supportAiHint => 'Ask a question...';

  @override
  String get supportAiSend => 'Send';

  @override
  String get supportAiIntro =>
      'Hi! I can help with orders, returns, and account questions.';

  @override
  String get supportAiOfflineFallback =>
      'You\'re offline. I can share general guidance, but account-specific answers need a connection.';

  @override
  String get supportAiError => 'Couldn\'t reach the assistant. Try again.';

  @override
  String get supportAiDisclaimer =>
      'AI answers are best-effort. Verify critical details.';

  @override
  String get approvalTimeline => 'Approval timeline';

  @override
  String get approved => 'Approved';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get resendForApproval => 'Resend for approval';

  @override
  String get catalogSearchTitle => 'Catalog search';

  @override
  String get catalogSearchPlaceholder => 'Search by name, SKU or vendor';

  @override
  String get catalogSearchEmpty => 'No products found for this search.';

  @override
  String get catalogSearchError => 'We couldn\'t load products right now.';

  @override
  String get catalogSearchRetry => 'Try search again';

  @override
  String get catalogSearchAddToCart => 'Add to cart';

  @override
  String get catalogSearchAddToCartError => 'Couldn\'t add to cart. Try again.';

  @override
  String get filterInStockOnly => 'In stock only';

  @override
  String get filterMinPrice => 'Min price';

  @override
  String get filterMaxPrice => 'Max price';

  @override
  String get filterCategoriesLoading => 'Loading...';

  @override
  String get filterAllCategoriesShort => 'All categories';

  @override
  String get filterAllCategories => 'All categories';

  @override
  String get catalogSearchLoadMore => 'Load more';

  @override
  String get catalogRequestAccess => 'Request access';

  @override
  String get catalogRequestAccessSuccess => 'Request sent to the sales team.';

  @override
  String get catalogRequestAccessError => 'We couldn\'t send the request.';

  @override
  String get quickOrderTitle => 'Quick order';

  @override
  String get quickOrderPlaceholder => 'Scan barcode, type SKU or keyword';

  @override
  String get quickOrderAddButton => 'Add';

  @override
  String get quickOrderSubmitDraft => 'Submit draft';

  @override
  String get quickOrderSubmitDisabled => 'Add at least one line';

  @override
  String get quickOrderSubmitSuccess => 'Draft submitted';

  @override
  String get quickOrderSubmitError => 'Submit failed';

  @override
  String get quickOrderAddSuccess => 'Added to draft';

  @override
  String get quickOrderAddError => 'Failed to add';

  @override
  String get quickOrderTabQuickOrder => 'Quick order';

  @override
  String get quickOrderTabReorders => 'Reorders';

  @override
  String get quickOrderCategoryFilter => 'Category';

  @override
  String get quickOrderCategoryAll => 'All categories';

  @override
  String get quickOrderTabCatalog => 'Catalog';

  @override
  String get quickOrderTabCategories => 'Categories';

  @override
  String get quickOrderTabPromotions => 'Promotions';

  @override
  String get quickOrderTabCart => 'Cart';

  @override
  String get quickOrderTabCheckout => 'Checkout';

  @override
  String get quickOrderReorderEmpty =>
      'Your repeat purchases will appear here soon.';

  @override
  String get quickOrderCategoriesEmpty =>
      'Browse categories to filter quick order results.';

  @override
  String get quickOrderCheckoutUnavailable =>
      'Add items to your cart before proceeding to checkout.';

  @override
  String get quickOrderEmpty => 'No matches yet.';

  @override
  String get quickOrderLoadMore => 'Load more results';

  @override
  String get catalogErrorTitle => 'Catalog unavailable';

  @override
  String get catalogErrorMessage =>
      'We couldn\'t load the catalog right now. Please try again shortly.';

  @override
  String get catalogRetry => 'Try again';

  @override
  String get catalogEmptyTitle => 'No products yet';

  @override
  String get catalogEmptyMessage => 'Please check back soon or adjust filters.';

  @override
  String get catalogEmptyCta => 'Refresh catalog';

  @override
  String get ordersEmptyMessage =>
      'After you place orders you will see them here.';

  @override
  String get quickOrderBulkHint => 'Bulk input (SKU or keyword list)';

  @override
  String get quickOrderBulkExample => 'e.g. SKU-1 x2, BAR-998 x5, mint x3';

  @override
  String get quickOrderBulkReviewAction => 'Review entries';

  @override
  String get quickOrderBulkPasteCsv => 'Paste CSV';

  @override
  String get quickOrderBulkClear => 'Clear list';

  @override
  String get quickOrderBulkReviewTitle => 'Review and confirm';

  @override
  String get quickOrderBulkReviewEmpty => 'Nothing to add yet.';

  @override
  String get quickOrderBulkReviewConfirmPending =>
      'Confirm matches before adding.';

  @override
  String get quickOrderBulkClipboardEmpty => 'Clipboard is empty.';

  @override
  String get quickOrderBulkCsvError => 'Could not parse CSV input';

  @override
  String get quickOrderBulkParsing => 'Looking up items...';

  @override
  String get quickOrderBulkTableHeaderCode => 'Code';

  @override
  String get quickOrderBulkTableHeaderQty => 'Qty';

  @override
  String get quickOrderBulkTableHeaderResult => 'Result';

  @override
  String get quickOrderBulkStatusMatched => 'Matched';

  @override
  String get quickOrderBulkStatusAdjusted => 'Adjusted';

  @override
  String get quickOrderBulkStatusKeyword => 'Keyword match';

  @override
  String get quickOrderBulkStatusAmbiguous => 'Multiple matches';

  @override
  String get quickOrderBulkStatusNotFound => 'Not found';

  @override
  String get quickOrderBulkStatusError => 'Invalid entry';

  @override
  String get quickOrderBulkStatusAdded => 'Added';

  @override
  String get quickOrderBulkStatusNeedsReview => 'Select a product to confirm';

  @override
  String get quickOrderBulkStatusDetailsLabel => 'Details';

  @override
  String get quickOrderBulkSkuLabel => 'SKU';

  @override
  String get quickOrderBulkSelectSuggestion => 'Pick a suggestion';

  @override
  String get quickOrderBulkChangeSelection => 'Change selection';

  @override
  String get quickOrderBulkSuggestionTitle => 'Choose a product';

  @override
  String get quickOrderBulkSuggestionCancel => 'Close';

  @override
  String get quickOrderBulkStatusMatchedManual => 'Confirmed manually';

  @override
  String quickOrderBulkAdjustmentPackApplied(
      Object packSize, Object packs, Object units) {
    return 'Applied pack size $packSize: $packs x $packSize = $units';
  }

  @override
  String quickOrderBulkAdjustmentPackMissing(Object requested) {
    return 'Pack size not configured; using $requested as units.';
  }

  @override
  String quickOrderBulkAdjustmentRaisedMoq(
      Object finalValue, Object moq, Object requested) {
    return 'MOQ $moq; raised from $requested to $finalValue';
  }

  @override
  String quickOrderBulkAdjustmentRoundedPack(
      Object finalValue, Object packSize, Object requested) {
    return 'Rounded to pack multiple $packSize: $requested -> $finalValue';
  }

  @override
  String get quickOrderBulkAddAll => 'Add all';

  @override
  String get quickOrderBulkSnackbarAdded => 'Added lines to draft';

  @override
  String get quickOrderBulkUndoLabel => 'Undo';

  @override
  String get quickOrderBulkUndoDone => 'Bulk add undone';

  @override
  String get catalogSearchRecent => 'Recent searches';

  @override
  String get catalogSearchClear => 'Clear';

  @override
  String get catalogSearchNoRecent => 'No recent searches yet.';

  @override
  String get vendorConsoleTitle => 'Vendor Console';

  @override
  String get vendorOrdersTab => 'Orders';

  @override
  String get vendorRfqsTab => 'RFQs';

  @override
  String get vendorOrdersEmptyTitle => 'No vendor orders yet';

  @override
  String get vendorOrdersEmptyBody =>
      'Orders assigned to your company will appear here.';

  @override
  String get vendorOrdersError => 'Failed to load vendor orders';

  @override
  String get vendorOrdersRetry => 'Try again';

  @override
  String get vendorOrdersOrderLabel => 'Order';

  @override
  String get vendorOrdersAmountLabel => 'Amount';

  @override
  String get vendorShipmentsTab => 'Shipments';

  @override
  String get vendorShipmentsFiltersStatus => 'Status';

  @override
  String get vendorShipmentsFiltersReset => 'Reset';

  @override
  String get vendorShipmentsDateRangePlaceholder => 'Date range';

  @override
  String get vendorShipmentsDateRangeClear => 'Clear';

  @override
  String get vendorShipmentsFiltersSearchPlaceholder => 'Search shipments';

  @override
  String get vendorShipmentsSearchClear => 'Clear search';

  @override
  String get vendorShipmentsEmptyTitle => 'No shipments yet';

  @override
  String get vendorShipmentsEmptyBody =>
      'Shipments will appear once orders are fulfilled.';

  @override
  String get vendorShipmentsError => 'Failed to load shipments';

  @override
  String get vendorShipmentsRetry => 'Try again';

  @override
  String get vendorShipmentsOrderLabel => 'Order ID';

  @override
  String get vendorShipmentsCreatedLabel => 'Created';

  @override
  String get vendorShipmentsRowTracking => 'Tracking';

  @override
  String get vendorShipmentsTrackingPlaceholder => 'No tracking number yet';

  @override
  String get vendorShipmentsUpdateAction => 'Update';

  @override
  String get vendorShipmentsUpdateTitle => 'Update shipment';

  @override
  String get vendorShipmentsUpdateStatusLabel => 'Status';

  @override
  String get vendorShipmentsUpdateTrackingLabel => 'Tracking number';

  @override
  String get vendorShipmentsUpdateCancel => 'Cancel';

  @override
  String get vendorShipmentsUpdateSave => 'Save';

  @override
  String get vendorShipmentsUpdated => 'Shipment updated';

  @override
  String get vendorShipmentsUpdateFailed => 'Failed to update shipment';

  @override
  String get shipmentStatusPending => 'Pending';

  @override
  String get shipmentStatusReady => 'Ready';

  @override
  String get shipmentStatusInTransit => 'In transit';

  @override
  String get shipmentStatusDelivered => 'Delivered';

  @override
  String get shipmentStatusCancelled => 'Cancelled';

  @override
  String get productGalleryTitle => 'Gallery';

  @override
  String get productVariantsTitle => 'Variants';

  @override
  String get productSpecsTitle => 'Product details';

  @override
  String get productAttributesTitle => 'Attributes';

  @override
  String get productAddToDraft => 'Add to draft';

  @override
  String get productAddedToDraft => 'Added to draft';

  @override
  String get productAddFailed => 'Couldn\'t add to draft';

  @override
  String get productSpecsUom => 'Unit of measure';

  @override
  String get productSpecsMoq => 'Minimum order quantity';

  @override
  String get productSpecsLeadTime => 'Lead time';

  @override
  String get productSpecsLeadTimeUnit => 'days';

  @override
  String get productSpecsUnknown => 'Not specified';

  @override
  String get productQtyHeading => 'Order quantity';

  @override
  String get productQtyUomLabel => 'Unit of measure';

  @override
  String get productQtyUomUnit => 'Unit';

  @override
  String get productQtyUomCase => 'Case';

  @override
  String get productQtyUomPallet => 'Pallet';

  @override
  String productQtyUomUnitDetail(Object uom) {
    return 'Unit • $uom';
  }

  @override
  String productQtyUomCaseDetail(Object count, Object uom) {
    return 'Case • $count $uom';
  }

  @override
  String get productQtyUomCaseUnavailable => 'Case details unavailable';

  @override
  String productQtyUomPalletDetail(Object count, Object uom) {
    return 'Pallet • $count $uom';
  }

  @override
  String productQtyUomPalletCasesSuffix(Object cases) {
    return '($cases cases)';
  }

  @override
  String get productQtyUomPalletUnavailable => 'Pallet details unavailable';

  @override
  String get productQtyMoqLabel => 'MOQ';

  @override
  String get productQtyStepLabel => 'Step (multiples)';

  @override
  String productQtyErrorBelowMoq(Object moq) {
    return 'Order at least $moq.';
  }

  @override
  String productQtyErrorStep(Object step) {
    return 'Order in multiples of $step.';
  }

  @override
  String get productQtyUomUnavailableTooltip => 'Unavailable for this variant';

  @override
  String get productQtyStepperSemantic => 'Order quantity';

  @override
  String get productQtyStepperIncrease => 'Increase quantity';

  @override
  String get productQtyStepperDecrease => 'Decrease quantity';

  @override
  String get productPriceBreaksLabel => 'Price breaks';

  @override
  String get productPriceBreaksQty => 'Qty';

  @override
  String get productPriceBreaksPrice => 'Unit price';

  @override
  String get productPriceBreaksLoading => '…';

  @override
  String get productPriceBreaksUnavailable => '—';

  @override
  String get productEffectivePriceLabel => 'Effective price';

  @override
  String get productEffectivePriceLoading => 'Loading…';

  @override
  String get productEffectivePriceUnavailable => '—';

  @override
  String get pricingContractTag => 'Contract price';

  @override
  String get pricingSourceContract => 'Contract price';

  @override
  String get pricingSourcePriceList => 'Price list';

  @override
  String get pricingSourceBase => 'Base price';

  @override
  String get pricingSourceFallback => 'Standard price';

  @override
  String get contractPrice => 'Contract price';

  @override
  String get notInCatalog => 'Not available for your account';

  @override
  String get notInCatalogShort => 'Out of private catalog';

  @override
  String get notInCatalogDetail =>
      'This product isn\'t included in your organization\'s catalog';

  @override
  String get priceBreaks => 'Price breaks';

  @override
  String get atQty => 'at qty';

  @override
  String get dash => '—';

  @override
  String get productSelectWarehouse => 'Choose warehouse';

  @override
  String get productWarehousesTitle => 'Warehouse availability';

  @override
  String get productWarehousesEmpty =>
      'No warehouses available for this variant.';

  @override
  String get productWarehousePrimary => 'Primary warehouse';

  @override
  String get productWarehouseQtyLabel => 'Stock';

  @override
  String get productWarehouseQtyUnknown => 'Not available';

  @override
  String get productWarehouseLeadTimeLabel => 'Lead time';

  @override
  String get productWarehouseLeadTimeUnknown => 'Not available';

  @override
  String get productSkuLabel => 'SKU';

  @override
  String get productNotFound => 'Product not available';

  @override
  String get adminOrdersTitle => 'Admin • Orders';

  @override
  String get adminOrdersReload => 'Reload';

  @override
  String get adminOrdersFiltersTitle => 'Filters';

  @override
  String get adminOrdersFiltersSearchLabel => 'Search orders';

  @override
  String get adminOrdersFiltersStatusLabel => 'Status';

  @override
  String get adminOrdersFiltersStatusAll => 'All statuses';

  @override
  String get adminOrdersFiltersDateLabel => 'Date range';

  @override
  String get adminOrdersFiltersDateClear => 'Clear';

  @override
  String get adminOrdersFiltersRangeAll => 'All dates';

  @override
  String get adminOrdersFiltersClear => 'Reset filters';

  @override
  String get adminOrdersFiltersActiveHint =>
      'Filters applied to the table below.';

  @override
  String get adminOrdersErrorTitle => 'Unable to load orders';

  @override
  String get adminOrdersEmptyTitle => 'No orders match your filters';

  @override
  String get adminOrdersEmptyBody =>
      'Adjust status, dates, or search to see results.';

  @override
  String get adminOrdersTableOrder => 'Order';

  @override
  String get adminOrdersTableCreated => 'Created';

  @override
  String get adminOrdersTableStatus => 'Status';

  @override
  String get adminOrdersTableTotal => 'Total';

  @override
  String get adminOrdersTableActions => 'Actions';

  @override
  String get adminOrdersSplitAction => 'Split order';

  @override
  String get adminOrdersSplitInProgress => 'Splitting...';

  @override
  String get adminOrdersSplitSuccess =>
      'Order split triggered. Shipments will sync shortly.';

  @override
  String adminOrdersSplitSuccessWithCount(Object count) {
    return 'Order split across $count vendor shipments.';
  }

  @override
  String adminOrdersSplitVendorCount(Object count) {
    return 'Vendors queued: $count';
  }

  @override
  String get adminOrdersSplitEdgeWarning =>
      'Edge sync failed. Shipments were created via RPC.';

  @override
  String adminOrdersSplitFailure(Object error) {
    return 'Failed to split order: $error';
  }

  @override
  String get adminReportsTitle => 'Admin • Reports';

  @override
  String get adminReportsRecentTitle => 'Recent exports';

  @override
  String get adminReportsEmptyTitle => 'No reports yet';

  @override
  String get adminReportsEmptyBody =>
      'Generate a report to receive a signed download link.';

  @override
  String get adminReportsGenerateCsv => 'Generate CSV';

  @override
  String get adminReportsGenerateJson => 'Generate JSON';

  @override
  String get adminReportsDescriptionTitle => 'Generate export files';

  @override
  String get adminReportsDescriptionBody =>
      'Choose a date range and export format to receive a signed URL. Links remain active for a limited time.';

  @override
  String get adminReportsPickRange => 'Select range';

  @override
  String get adminReportsClearRange => 'Clear';

  @override
  String get adminReportsRangeAll => 'All dates';

  @override
  String get adminReportsSuccess => 'Report ready.';

  @override
  String get adminReportsSignedUrlTitle => 'Report link ready';

  @override
  String get adminReportsSignedUrlBody =>
      'Copy the signed URL or open it in a new tab.';

  @override
  String get adminReportsSignedUrlClose => 'Close';

  @override
  String adminReportsFailure(Object error) {
    return 'Report failed: $error';
  }

  @override
  String get adminReportsOpenFailed => 'Could not open report link.';

  @override
  String get adminReportsCopySuccess => 'Link copied to clipboard';

  @override
  String get adminReportsCopyLink => 'Copy link';

  @override
  String get adminReportsOpenLink => 'Open link';

  @override
  String get adminReportsGeneratedAt => 'Generated at:';

  @override
  String get adminPriceImportTitle => 'Admin • Price import';

  @override
  String get adminPriceImportReloadVendors => 'Reload vendors';

  @override
  String get adminPriceImportVendorsFailed => 'Failed to load vendors';

  @override
  String get adminPriceImportSelectVendor => 'Select vendor';

  @override
  String get adminPriceImportInstructions =>
      'Upload a CSV with columns variant_id, min_qty, unit_price.';

  @override
  String get adminPriceImportHeader => 'Import vendor prices';

  @override
  String get adminPriceImportChooseFile => 'Choose CSV';

  @override
  String get adminPriceImportImportButton => 'Import prices';

  @override
  String get adminPriceImportRefreshButton => 'Refresh effective prices';

  @override
  String get adminPriceImportProcessing => 'Processing...';

  @override
  String get adminPriceImportSelectedFile => 'Selected file';

  @override
  String get adminPriceImportPreviewTitle => 'Preview (first rows)';

  @override
  String get adminPriceImportPreviewHint =>
      'Choose a CSV to preview the first rows before importing.';

  @override
  String get adminPriceImportPreviewEmpty => 'CSV appears empty.';

  @override
  String get adminPriceImportSelectVendorFirst =>
      'Select a vendor before importing.';

  @override
  String get adminPriceImportSelectFileFirst => 'Choose a CSV file to import.';

  @override
  String adminPriceImportSuccess(Object count) {
    return 'Rows processed: $count';
  }

  @override
  String adminPriceImportFailure(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get adminPriceImportRefreshSuccess => 'Effective prices refreshed.';

  @override
  String adminPriceImportRefreshFailure(Object error) {
    return 'Refresh failed: $error';
  }

  @override
  String get adminPriceImportColumn => 'Column';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutBillToTitle => 'Bill-to address';

  @override
  String get checkoutBillToLabel => 'Billing account';

  @override
  String get checkoutBillToHint => 'Choose the billing account';

  @override
  String get checkoutShipToTitle => 'Ship-to address';

  @override
  String get checkoutShipToLabel => 'Delivery location';

  @override
  String get checkoutShipToHint => 'Choose the ship-to location';

  @override
  String get checkoutPaymentTermsTitle => 'Payment terms';

  @override
  String get checkoutBillToPrimaryTitle => 'Primary billing account';

  @override
  String get checkoutBillToPrimaryDescription => '123 Herzl St, Tel Aviv';

  @override
  String get checkoutBillToFinanceTitle => 'Finance department';

  @override
  String get checkoutBillToFinanceDescription =>
      'Accounting HQ - 56 Rothschild Blvd';

  @override
  String get checkoutShipToWarehouseTitle => 'Main warehouse';

  @override
  String get checkoutShipToWarehouseDescription =>
      'Logistics Center, Ashdod Port';

  @override
  String get checkoutShipToBranchTitle => 'Southern branch';

  @override
  String get checkoutShipToBranchDescription =>
      '152 Emek Hefer Industrial Park';

  @override
  String get checkoutPaymentNet30 => 'Net 30';

  @override
  String get checkoutPaymentNet45 => 'Net 45';

  @override
  String get checkoutPaymentNet60 => 'Net 60';

  @override
  String get checkoutPaymentPayNow => 'Pay now';

  @override
  String get checkoutSummaryTitle => 'Order summary';

  @override
  String get checkoutSummarySubtotal => 'Subtotal';

  @override
  String get checkoutSummaryTaxes => 'Estimated VAT';

  @override
  String get checkoutSummaryTotal => 'Estimated total';

  @override
  String get checkoutSummaryError => 'We could not load order totals.';

  @override
  String get checkoutSummaryEmpty => 'Your cart is empty.';

  @override
  String get approvalSendButton => 'Send for approval';

  @override
  String get approvalResendButton => 'Resend for approval';

  @override
  String get approvalSendLoading => 'Sending...';

  @override
  String get approvalSendSuccess => 'Approval request sent.';

  @override
  String get approvalSendError => 'Could not send approval request.';

  @override
  String get approvalPendingCta => 'Awaiting approval';

  @override
  String get approvalSubmitButton => 'Submit order';

  @override
  String get approvalSubmitLoading => 'Submitting...';

  @override
  String get approvalSubmitSuccess => 'Order submitted successfully.';

  @override
  String get approvalSubmitError => 'Could not submit the order.';

  @override
  String get approvalBannerNotRequired =>
      'No approval required. Submit whenever you are ready.';

  @override
  String get approvalBannerRequires =>
      'This order requires approval before submission.';

  @override
  String get approvalBannerPending => 'Awaiting approval from your approvers.';

  @override
  String get approvalBannerApproved => 'Approved — ready to submit.';

  @override
  String get approvalBannerRejected =>
      'Approval was rejected. Update and resend.';

  @override
  String approvalBannerRejectedWithReason(Object reason) {
    return 'Approval rejected: $reason';
  }

  @override
  String get approvalBannerError => 'Could not load approval status.';

  @override
  String get approvalRejectedHint =>
      'Review the order and address any notes before resending.';

  @override
  String get approvalsInboxTitle => 'Approvals Inbox';

  @override
  String get approvalsInboxRefresh => 'Refresh inbox';

  @override
  String get approvalsInboxEmptyTitle => 'No pending approvals';

  @override
  String get approvalsInboxEmptyBody => 'You are all caught up.';

  @override
  String get approvalsInboxErrorTitle => 'Inbox unavailable';

  @override
  String get approvalsInboxRetry => 'Try again';

  @override
  String get approvalsInboxApprove => 'Approve';

  @override
  String get approvalsInboxReject => 'Reject';

  @override
  String get approvalsInboxApproveSuccess => 'Approval recorded.';

  @override
  String get approvalsInboxRejectSuccess => 'Rejection recorded.';

  @override
  String get approvalsInboxActionError => 'Action failed. Try again.';

  @override
  String get approvalsInboxRejectDialogTitle => 'Reject approval';

  @override
  String get approvalsInboxRejectDialogLabel => 'Note';

  @override
  String get approvalsInboxRejectDialogHint =>
      'Explain the rejection (optional)';

  @override
  String get approvalsInboxRejectCancel => 'Cancel';

  @override
  String get approvalsInboxRejectConfirm => 'Reject';

  @override
  String approvalsInboxRequestedBy(Object name) {
    return 'Requested by: $name';
  }

  @override
  String approvalsInboxBuyer(Object name) {
    return 'Buyer: $name';
  }

  @override
  String approvalsInboxRequestedAt(Object time) {
    return 'Requested at $time';
  }

  @override
  String get approvalsInboxNoteLabel => 'Note';

  @override
  String get checkoutDraftMissing => 'Unable to open checkout without a cart.';

  @override
  String get checkoutContinueButton => 'Review and confirm';

  @override
  String get checkoutMissingBillTo => 'Bill-to address';

  @override
  String get checkoutMissingShipTo => 'Ship-to address';

  @override
  String get checkoutMissingPaymentTerms => 'Payment terms';

  @override
  String checkoutMissingData(Object fields) {
    return 'Please complete: $fields';
  }

  @override
  String get checkoutMissingSeparator => ', ';

  @override
  String get checkoutComingSoon => 'Checkout submission coming soon.';

  @override
  String get cartProceedToCheckout => 'Proceed to checkout';

  @override
  String get cartDraftLoadError => 'We couldn\'t load your draft cart.';

  @override
  String get cartLoadError => 'We couldn\'t load the cart.';

  @override
  String get cartActionFailed => 'Cart action failed.';

  @override
  String get cartEmptyMessage => 'Your cart is empty right now.';

  @override
  String get cartBrowseCatalog => 'Back to catalog';

  @override
  String get cartRequestQuote => 'Request a quote';

  @override
  String cartVendorLabel(Object vendor) {
    return 'Vendor $vendor';
  }

  @override
  String get cartVendorRestricted =>
      'Some items from this vendor require approval.';

  @override
  String get cartVendorRequestSuccess => 'Request sent to vendor.';

  @override
  String get cartRequestAccess => 'Request access';

  @override
  String get cartRequestAccessSuccess => 'Request sent to vendor.';

  @override
  String get cartCreateQuoteError => 'Couldn\'t create request.';

  @override
  String get cartCreateQuoteSuccess => 'Request sent to vendors.';

  @override
  String get cartRemoveLineTooltip => 'Remove';

  @override
  String get cartRecommendationsTitle => 'Complete your order';

  @override
  String get cartRecommendationsSubtitle => 'Products often ordered together';

  @override
  String get cartRecommendationsAdd => 'Add';

  @override
  String get cartRecommendationsAdded => 'Added to cart';

  @override
  String get recommendationFastDelivery => 'Fast delivery';

  @override
  String get recommendationLowMoq => 'Low MOQ';

  @override
  String get recommendationSmallPack => 'Small pack';

  @override
  String get recommendationDefault => 'Suggested';

  @override
  String get commonRetry => 'Try again';

  @override
  String get rfqStatusAwaitingQuotes => 'Awaiting quotes';

  @override
  String get rfqStatusQuoted => 'Quoted';

  @override
  String get rfqStatusExpired => 'Expired';

  @override
  String get rfqLatestQuoteStatusLabel => 'Latest quote status';

  @override
  String get rfqListTitle => 'Requests for quotes';

  @override
  String get rfqCreateCta => 'New RFQ';

  @override
  String get rfqCustomerStatusLabel => 'Customer status';

  @override
  String get rfqVendorStatusLabel => 'Vendor status';

  @override
  String get rfqQuoteSectionTitle => 'Received quotes';

  @override
  String get rfqQuotesEmpty => 'No quotes yet';

  @override
  String get rfqQuotesEmptyHint => 'Suppliers have not responded yet';

  @override
  String get rfqItemsSectionTitle => 'Items';

  @override
  String get rfqMessagesSectionTitle => 'Questions & updates';

  @override
  String get rfqSendMessageLabel => 'New message';

  @override
  String get rfqSendMessage => 'Send to vendor';

  @override
  String get rfqMessagesEmpty => 'No messages yet';

  @override
  String get rfqQuoteAmountLabel => 'Estimated total';

  @override
  String get rfqQuoteVendorLabel => 'Vendor';

  @override
  String get rfqQuoteTermsLabel => 'Terms';

  @override
  String get rfqLastUpdatedLabel => 'Created at';

  @override
  String get rfqNeedByLabel => 'Need by';

  @override
  String get rfqItemQuantityLabel => 'Quantity';

  @override
  String get rfqItemNotesLabel => 'Notes';

  @override
  String get rfqItemCountLabel => 'Item count';

  @override
  String get rfqQuoteCountLabel => 'Quotes received';

  @override
  String get rfqResubmit => 'Resend for approval';

  @override
  String get rfqItemFallbackLabel => 'Unnamed item';

  @override
  String get rfqAcceptQuote => 'Accept quote';

  @override
  String get rfqMessageAuthorVendor => 'Vendor reply';

  @override
  String get rfqMessageAuthorAdmin => 'System';

  @override
  String get rfqMessageAuthorCustomer => 'Customer message';

  @override
  String get rfqQuoteLabel => 'Quote';

  @override
  String get rfqQuoteDateLabel => 'Date';

  @override
  String get rfqListError => 'Could not load RFQs.';

  @override
  String get rfqRetry => 'Refresh';

  @override
  String get rfqEmptyTitle => 'No active requests';

  @override
  String get rfqEmptyCta => 'Create a new request';

  @override
  String get rfqVendorListTitle => 'Customer RFQs';

  @override
  String get rfqVendorMessageLabel => 'Reply to buyer';

  @override
  String get rfqVendorSendMessage => 'Send message';

  @override
  String get rfqVendorMessageEmpty => 'No messages for this request';

  @override
  String get rfqVendorThreadTitle => 'Message thread';

  @override
  String get rfqVendorQuoteDetailsTitle => 'Quote details';

  @override
  String get rfqVendorQuoteRejectedTitle => 'Request marked as rejected';

  @override
  String get rfqVendorQuoteRejectedBody =>
      'You can submit a new quote if needed.';

  @override
  String get rfqVendorSubmitQuote => 'Submit quote';

  @override
  String get rfqVendorRejectQuote => 'Reject request';

  @override
  String get rfqVendorSuccessSnack => 'Quote submitted successfully';

  @override
  String get rfqVendorRejectSuccess => 'Request rejected successfully';

  @override
  String get rfqVendorSubmitError => 'Failed to submit quote';

  @override
  String get rfqVendorRejectError => 'Failed to reject request';

  @override
  String get rfqVendorMessageErrorEmpty => 'Enter a message';

  @override
  String get rfqVendorMessageSendFailed => 'Failed to send message';

  @override
  String get rfqVendorUnitPriceLabel => 'Unit price (₪)';

  @override
  String get rfqVendorMOQLabel => 'MOQ';

  @override
  String get rfqVendorStepQtyLabel => 'Step qty';

  @override
  String get rfqVendorLeadTimeLabel => 'Lead time (days)';

  @override
  String get rfqVendorCustomerTermsLabel => 'Customer terms';

  @override
  String get rfqVendorListError => 'Could not load vendor RFQs.';

  @override
  String get rfqVendorEmptyTitle => 'No vendor requests pending';

  @override
  String get rfqVendorPriceRequired => 'Price required for';

  @override
  String get rfqResubmitFailed => 'Failed to resend for approval';

  @override
  String get rfqMessageErrorEmpty => 'Enter a message';

  @override
  String get rfqMessageSendFailed => 'Failed to send message';

  @override
  String get rfqAcceptQuoteFailed => 'Failed to accept quote';

  @override
  String get billingTitle => 'Billing';

  @override
  String get openDebtsTitle => 'Open debts';

  @override
  String get invoicesTitle => 'Invoices';

  @override
  String get aging => 'Aging';

  @override
  String get totalDue => 'Total due';

  @override
  String get download => 'Download';

  @override
  String get statement => 'Statement';

  @override
  String get export => 'Export';

  @override
  String get openDebtsEmpty => 'All clear';

  @override
  String get openDebtsEmptyHint => 'No outstanding balances at the moment.';

  @override
  String get openDebtsError => 'Unable to load balances';

  @override
  String get openDebtsDownloadStatement => 'Download statement';

  @override
  String get openDebtsBucket_0_30 => '0-30 days';

  @override
  String get openDebtsBucket_31_60 => '31-60 days';

  @override
  String get openDebtsBucket_61_90 => '61-90 days';

  @override
  String get openDebtsBucket_90_plus => '90+ days';

  @override
  String get invoicesError => 'Invoices unavailable';

  @override
  String get invoicesEmpty => 'No open invoices';

  @override
  String get invoicesEmptyHint =>
      'Once invoices are issued they will appear here.';

  @override
  String get promotionsTitle => 'Promotions';

  @override
  String get promotionsEmpty => 'No active promotions right now.';

  @override
  String get promotionsError => 'We couldn\'t load promotions.';

  @override
  String promotionsValidUntil(Object date) {
    return 'Valid until $date';
  }

  @override
  String promotionsTermsApply(Object terms) {
    return 'Terms apply $terms';
  }

  @override
  String get viewProducts => 'View products';

  @override
  String get validUntil => 'Valid until';

  @override
  String get termsApply => 'Terms apply';

  @override
  String get rfq_title => 'Request for quote';

  @override
  String get rfq_create => 'Create RFQ';

  @override
  String get rfq_add_line => 'Add line';

  @override
  String get rfq_submit => 'Submit RFQ';

  @override
  String get rfq_created => 'RFQ submitted to vendors';

  @override
  String get rfq_error => 'We couldn\'t submit your RFQ. Try again.';

  @override
  String get rfq_notes_label => 'Notes for vendor';

  @override
  String get rfq_delivery_date => 'Requested delivery';

  @override
  String get rfq_select_date => 'Select date';

  @override
  String get rfq_currency => 'Currency';

  @override
  String get rfq_product => 'Product';

  @override
  String get rfq_uom => 'Unit of measure';

  @override
  String get rfq_quantity => 'Quantity';

  @override
  String get field_required => 'Required';

  @override
  String get rfq_qty_invalid => 'Enter a positive quantity';

  @override
  String get rfq_target_price => 'Target unit price';

  @override
  String get rfq_sku_label => 'SKU';

  @override
  String get quote_title => 'Quote';

  @override
  String get quote_valid_until => 'Valid until';

  @override
  String get quote_empty => 'Waiting for vendor quotes';

  @override
  String get rfq_unit_price => 'Unit price';

  @override
  String get rfq_lead_time => 'Lead time (days)';

  @override
  String get rfq_to_order => 'Convert to order';

  @override
  String get rfq_to_order_success => 'Order created from quote';

  @override
  String get rfq_to_order_error => 'Couldn\'t convert quote';

  @override
  String get ship_from => 'Ship from';

  @override
  String get eta => 'ETA - Estimated arrival';

  @override
  String get allow_backorder => 'Allow backorder';

  @override
  String get warehouse_picker => 'Warehouse selection';

  @override
  String get in_stock => 'In stock';

  @override
  String get out_of_stock => 'Out of stock';

  @override
  String get low_stock => 'Low stock';

  @override
  String get backorder_available => 'Backorder available';

  @override
  String get shipping_method => 'Shipping method';

  @override
  String get rate => 'Rate';

  @override
  String get asn_created => 'ASN created';

  @override
  String get tracking => 'Tracking';

  @override
  String get pod_received => 'POD received';

  @override
  String get payment_terms => 'Payment terms';

  @override
  String get escrow_held => 'Held in escrow';

  @override
  String get escrow_released => 'Released from escrow';

  @override
  String get statement_export => 'Export statement';

  @override
  String get payout_run => 'Run payout';

  @override
  String get net_terms => 'Net terms';

  @override
  String get days_until_due => 'Days until due';

  @override
  String get overdue => 'Overdue';

  @override
  String get moq_minimum => 'Minimum quantity';

  @override
  String get quantity_not_multiple => 'Quantity must be a multiple of';

  @override
  String get uom_adjusted_info => 'Quantity adjusted to UOM';

  @override
  String get hidden_for_your_account => 'Hidden for your account';

  @override
  String get private_catalog_only => 'Private catalog only';

  @override
  String get adminDashboardUsersCta => 'Manage users';

  @override
  String get adminDashboardUsersDescription =>
      'Invite admins and manage access controls';

  @override
  String get adminUsersTitle => 'User management';

  @override
  String get adminUsersSubtitle =>
      'Invite, deactivate, and monitor team access across the marketplace.';

  @override
  String get adminUsersSearchHint => 'Search by name or email';

  @override
  String get adminUsersFilterAll => 'All';

  @override
  String get adminUsersFilterActive => 'Active';

  @override
  String get adminUsersFilterDisabled => 'Disabled';

  @override
  String get adminUsersInviteCta => 'Invite user';

  @override
  String get adminUsersInviteTitle => 'Invite new user';

  @override
  String get adminUsersInviteEmailLabel => 'Email';

  @override
  String get adminUsersInviteFullNameLabel => 'Full name (optional)';

  @override
  String get adminUsersInviteRoleLabel => 'Role';

  @override
  String get adminUsersInviteCancel => 'Cancel';

  @override
  String get adminUsersInviteSubmit => 'Send invite';

  @override
  String get adminUsersInviteEmailError => 'Enter a valid corporate email';

  @override
  String get adminUsersInviteRoleError => 'Select a role';

  @override
  String get adminUsersEmptyTitle => 'No users yet';

  @override
  String get adminUsersEmptySubtitle =>
      'Use the invite button to add your first teammate.';

  @override
  String get adminUsersDeactivateCta => 'Disable';

  @override
  String get adminUsersActivateCta => 'Activate';

  @override
  String get adminUsersStatusDisabled => 'Disabled';

  @override
  String get adminUsersStatusActive => 'Active';

  @override
  String get adminUsersStatusHeader => 'Status';

  @override
  String get adminUsersActionsHeader => 'Actions';

  @override
  String get adminUsersIdentityHeader => 'User';

  @override
  String get adminUsersRoleHeader => 'Role';

  @override
  String get adminUsersLastSignIn => 'Last sign-in';

  @override
  String get adminUsersInvitedAt => 'Invited';

  @override
  String get adminUsersDeactivateTitle => 'Disable user';

  @override
  String get adminUsersDeactivateMessage =>
      'The user will lose access immediately. You can reactivate later.';

  @override
  String get adminUsersDeactivateReasonHint => 'Reason (optional)';

  @override
  String get adminUsersDeactivateConfirm => 'Disable user';

  @override
  String get adminUsersActivateTitle => 'Reactivate user';

  @override
  String get adminUsersActivateMessage => 'Restore access for this user?';

  @override
  String get adminUsersActivateConfirm => 'Activate user';

  @override
  String get adminUsersQueuedSnack =>
      'Queued offline. Will sync when back online.';

  @override
  String adminUsersInviteSuccess(Object email) {
    return 'Invitation sent to $email';
  }

  @override
  String adminUsersDeactivateSuccess(Object email) {
    return '$email disabled';
  }

  @override
  String adminUsersActivateSuccess(Object email) {
    return '$email reactivated';
  }

  @override
  String adminUsersError(Object message) {
    return 'Operation failed: $message';
  }

  @override
  String get adminUsersRefresh => 'Refresh';

  @override
  String get adminUsersNever => 'Never';

  @override
  String get adminUserRoleAdmin => 'Platform admin';

  @override
  String get adminUserRoleVendorAdmin => 'Vendor admin';

  @override
  String get adminUserRoleVendorUser => 'Vendor user';

  @override
  String get adminUserRoleCustomerAdmin => 'Customer admin';

  @override
  String get adminUserRoleBuyer => 'Buyer';
}
