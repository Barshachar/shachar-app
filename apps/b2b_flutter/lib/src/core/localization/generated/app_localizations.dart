import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ashachar Marketplace'**
  String get appTitle;

  /// No description provided for @loginAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Ashachar Marketplace'**
  String get loginAppBarTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to continue.'**
  String get loginSubtitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginButtonLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginButtonLoading;

  /// No description provided for @loginDemoCta.
  ///
  /// In en, this message translates to:
  /// **'Try the demo'**
  String get loginDemoCta;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password is too short.'**
  String get loginPasswordTooShort;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect. Try again.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get loginErrorRateLimited;

  /// No description provided for @loginErrorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email is not confirmed yet. Check your inbox for the verification message.'**
  String get loginErrorEmailNotConfirmed;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign you in. Please try again shortly.'**
  String get loginErrorGeneric;

  /// No description provided for @loginErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again in a moment.'**
  String get loginErrorUnexpected;

  /// No description provided for @loginErrorDemoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Demo credentials are not available in this environment.'**
  String get loginErrorDemoUnavailable;

  /// No description provided for @loginErrorDemoGeneric.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t sign in to the demo. Try again.'**
  String get loginErrorDemoGeneric;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @signInSwitchUser.
  ///
  /// In en, this message translates to:
  /// **'Sign in / switch user'**
  String get signInSwitchUser;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get homeGreeting;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do today?'**
  String get homeGreetingSubtitle;

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchTooltip;

  /// No description provided for @homeMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get homeMenuTooltip;

  /// No description provided for @homeCampaignTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotions 2025'**
  String get homeCampaignTitle;

  /// No description provided for @homeCampaignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal bundles and tailored offers for your business.'**
  String get homeCampaignSubtitle;

  /// No description provided for @homeCampaignCta.
  ///
  /// In en, this message translates to:
  /// **'Browse deals'**
  String get homeCampaignCta;

  /// No description provided for @homeCurrentOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Current order'**
  String get homeCurrentOrderTitle;

  /// No description provided for @homeCurrentOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have an active draft yet.'**
  String get homeCurrentOrderEmpty;

  /// No description provided for @homeCurrentOrderLoading.
  ///
  /// In en, this message translates to:
  /// **'Updating draft...'**
  String get homeCurrentOrderLoading;

  /// No description provided for @homeCurrentOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Order value'**
  String get homeCurrentOrderValue;

  /// No description provided for @homeCurrentOrderItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String homeCurrentOrderItems(Object count);

  /// No description provided for @homeContinueOrder.
  ///
  /// In en, this message translates to:
  /// **'Continue order'**
  String get homeContinueOrder;

  /// No description provided for @homeTilePromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get homeTilePromotions;

  /// No description provided for @homeTilePromotionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Curated discounts and seasonal bundles'**
  String get homeTilePromotionsDescription;

  /// No description provided for @homeTileCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get homeTileCatalog;

  /// No description provided for @homeTileCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse the full assortment'**
  String get homeTileCatalogDescription;

  /// No description provided for @homeTileQuickOrder.
  ///
  /// In en, this message translates to:
  /// **'Quick order'**
  String get homeTileQuickOrder;

  /// No description provided for @homeTileQuickOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Fast entry for repeat items'**
  String get homeTileQuickOrderDescription;

  /// No description provided for @homeTileCart.
  ///
  /// In en, this message translates to:
  /// **'Order cart'**
  String get homeTileCart;

  /// No description provided for @homeTileCartDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your draft order'**
  String get homeTileCartDescription;

  /// No description provided for @homeTileOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get homeTileOrders;

  /// No description provided for @homeTileOrdersDescription.
  ///
  /// In en, this message translates to:
  /// **'Track statuses and delivery'**
  String get homeTileOrdersDescription;

  /// No description provided for @homeTileApprovals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get homeTileApprovals;

  /// No description provided for @homeTileApprovalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Requests awaiting your review'**
  String get homeTileApprovalsDescription;

  /// No description provided for @homeReorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder shortcuts'**
  String get homeReorderTitle;

  /// No description provided for @homeSavedListsShortcut.
  ///
  /// In en, this message translates to:
  /// **'Saved lists'**
  String get homeSavedListsShortcut;

  /// No description provided for @homeViewAllOrders.
  ///
  /// In en, this message translates to:
  /// **'View all orders'**
  String get homeViewAllOrders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Ashachar'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A B2B marketplace for smart, multi-vendor procurement.'**
  String get aboutSubtitle;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'Make B2B purchasing fast, transparent, and reliable — from sourcing to delivery.'**
  String get aboutMissionBody;

  /// No description provided for @aboutHighlightsTitle.
  ///
  /// In en, this message translates to:
  /// **'What you can do'**
  String get aboutHighlightsTitle;

  /// No description provided for @aboutHighlightOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Order in minutes'**
  String get aboutHighlightOrdersTitle;

  /// No description provided for @aboutHighlightOrdersBody.
  ///
  /// In en, this message translates to:
  /// **'Consolidate vendors, manage approvals, and track every shipment.'**
  String get aboutHighlightOrdersBody;

  /// No description provided for @aboutHighlightPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart pricing'**
  String get aboutHighlightPricingTitle;

  /// No description provided for @aboutHighlightPricingBody.
  ///
  /// In en, this message translates to:
  /// **'Customer-specific pricing, promos, and contract rates.'**
  String get aboutHighlightPricingBody;

  /// No description provided for @aboutHighlightInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operational insights'**
  String get aboutHighlightInsightsTitle;

  /// No description provided for @aboutHighlightInsightsBody.
  ///
  /// In en, this message translates to:
  /// **'Dashboards and alerts that keep the supply chain on track.'**
  String get aboutHighlightInsightsBody;

  /// No description provided for @aboutContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContactTitle;

  /// No description provided for @aboutContactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get aboutContactPhoneLabel;

  /// No description provided for @aboutContactPhoneValue.
  ///
  /// In en, this message translates to:
  /// **'03-1234567'**
  String get aboutContactPhoneValue;

  /// No description provided for @aboutContactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutContactEmailLabel;

  /// No description provided for @aboutContactEmailValue.
  ///
  /// In en, this message translates to:
  /// **'support@ashachar.co.il'**
  String get aboutContactEmailValue;

  /// No description provided for @aboutContactHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get aboutContactHoursLabel;

  /// No description provided for @aboutContactHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Sun-Thu 08:00-17:00'**
  String get aboutContactHoursValue;

  /// No description provided for @aboutLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get aboutLegalTitle;

  /// No description provided for @aboutLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get aboutLegalTerms;

  /// No description provided for @aboutLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutLegalPrivacy;

  /// No description provided for @aboutLegalSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get aboutLegalSoon;

  /// No description provided for @customerCompanyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer profile'**
  String get customerCompanyProfileTitle;

  /// No description provided for @customerCompanyProfileTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get customerCompanyProfileTabOverview;

  /// No description provided for @customerCompanyProfileTabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get customerCompanyProfileTabOrders;

  /// No description provided for @customerCompanyProfileTabQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get customerCompanyProfileTabQuotes;

  /// No description provided for @customerCompanyProfileTabCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get customerCompanyProfileTabCredit;

  /// No description provided for @customerCompanyProfileTabContracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get customerCompanyProfileTabContracts;

  /// No description provided for @customerCompanyProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'coming soon'**
  String get customerCompanyProfileComingSoon;

  /// No description provided for @customerCompanyProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get customerCompanyProfileLoadError;

  /// No description provided for @customerCompanyProfileTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get customerCompanyProfileTierLabel;

  /// No description provided for @customerCompanyProfileIndustryLabel.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get customerCompanyProfileIndustryLabel;

  /// No description provided for @customerCompanyProfileSalesRepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales Rep'**
  String get customerCompanyProfileSalesRepLabel;

  /// No description provided for @customerCompanyProfileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get customerCompanyProfileEmailLabel;

  /// No description provided for @customerCompanyProfileContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get customerCompanyProfileContactTitle;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin workspace'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardOverviewHeading.
  ///
  /// In en, this message translates to:
  /// **'Business overview'**
  String get adminDashboardOverviewHeading;

  /// No description provided for @adminDashboardQuickActionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get adminDashboardQuickActionsHeading;

  /// No description provided for @adminDashboardSignalsHeading.
  ///
  /// In en, this message translates to:
  /// **'Operational signals'**
  String get adminDashboardSignalsHeading;

  /// No description provided for @adminDashboardTotalGmv.
  ///
  /// In en, this message translates to:
  /// **'Total GMV'**
  String get adminDashboardTotalGmv;

  /// No description provided for @adminDashboardTotalGmvTrend.
  ///
  /// In en, this message translates to:
  /// **'+12.4% vs. last month'**
  String get adminDashboardTotalGmvTrend;

  /// No description provided for @adminDashboardActiveVendors.
  ///
  /// In en, this message translates to:
  /// **'Active vendors'**
  String get adminDashboardActiveVendors;

  /// No description provided for @adminDashboardActiveVendorsTrend.
  ///
  /// In en, this message translates to:
  /// **'2 onboarding right now'**
  String get adminDashboardActiveVendorsTrend;

  /// No description provided for @adminDashboardApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get adminDashboardApprovals;

  /// No description provided for @adminDashboardApprovalsTrend.
  ///
  /// In en, this message translates to:
  /// **'SLA 3h remaining'**
  String get adminDashboardApprovalsTrend;

  /// No description provided for @adminDashboardSupportCta.
  ///
  /// In en, this message translates to:
  /// **'Open support inbox'**
  String get adminDashboardSupportCta;

  /// No description provided for @adminDashboardSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Track escalations and SLA breaches'**
  String get adminDashboardSupportDescription;

  /// No description provided for @adminDashboardTaxSettingsCta.
  ///
  /// In en, this message translates to:
  /// **'Configure tax rules'**
  String get adminDashboardTaxSettingsCta;

  /// No description provided for @adminDashboardTaxSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'VAT, exemptions, export profiles'**
  String get adminDashboardTaxSettingsDescription;

  /// No description provided for @adminDashboardAuditLogCta.
  ///
  /// In en, this message translates to:
  /// **'Review audit log'**
  String get adminDashboardAuditLogCta;

  /// No description provided for @adminDashboardAuditLogDescription.
  ///
  /// In en, this message translates to:
  /// **'Latest configuration changes & impersonations'**
  String get adminDashboardAuditLogDescription;

  /// No description provided for @adminDashboardVendorsCta.
  ///
  /// In en, this message translates to:
  /// **'Manage vendor queue'**
  String get adminDashboardVendorsCta;

  /// No description provided for @adminDashboardVendorsDescription.
  ///
  /// In en, this message translates to:
  /// **'Approve or reject onboarding requests'**
  String get adminDashboardVendorsDescription;

  /// No description provided for @adminDashboardSupportAlerts.
  ///
  /// In en, this message translates to:
  /// **'Support alerts'**
  String get adminDashboardSupportAlerts;

  /// No description provided for @adminDashboardComplianceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Compliance & approvals'**
  String get adminDashboardComplianceAlerts;

  /// No description provided for @adminDashboardSupportAlert1Title.
  ///
  /// In en, this message translates to:
  /// **'#2034 Login issue'**
  String get adminDashboardSupportAlert1Title;

  /// No description provided for @adminDashboardSupportAlert1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'SLA breach in 12m • Assigned to Support Team'**
  String get adminDashboardSupportAlert1Subtitle;

  /// No description provided for @adminDashboardSupportAlert2Title.
  ///
  /// In en, this message translates to:
  /// **'#2033 Order not delivered'**
  String get adminDashboardSupportAlert2Title;

  /// No description provided for @adminDashboardSupportAlert2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Escalated to Logistics • ETA 4h'**
  String get adminDashboardSupportAlert2Subtitle;

  /// No description provided for @adminDashboardComplianceAlert1Title.
  ///
  /// In en, this message translates to:
  /// **'2 approval requests awaiting admin review'**
  String get adminDashboardComplianceAlert1Title;

  /// No description provided for @adminDashboardComplianceAlert1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Net 60 override • Vendor onboarding'**
  String get adminDashboardComplianceAlert1Subtitle;

  /// No description provided for @adminDashboardComplianceAlert2Title.
  ///
  /// In en, this message translates to:
  /// **'1 tax rule expiring this month'**
  String get adminDashboardComplianceAlert2Title;

  /// No description provided for @adminDashboardComplianceAlert2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'IL Non-profit exemption – refresh required'**
  String get adminDashboardComplianceAlert2Subtitle;

  /// No description provided for @adminDashboardNotes.
  ///
  /// In en, this message translates to:
  /// **'Demo metrics for illustration purposes only.'**
  String get adminDashboardNotes;

  /// No description provided for @adminAuditLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get adminAuditLogTitle;

  /// No description provided for @adminAuditLogFiltersApplied.
  ///
  /// In en, this message translates to:
  /// **'Filters applied to audit log.'**
  String get adminAuditLogFiltersApplied;

  /// No description provided for @adminAuditLogExportStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started in the background.'**
  String get adminAuditLogExportStarted;

  /// No description provided for @adminAuditLogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load audit log.'**
  String get adminAuditLogLoadError;

  /// No description provided for @adminAuditLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No audit activity recorded.'**
  String get adminAuditLogEmpty;

  /// No description provided for @adminAuditLogFilterDateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get adminAuditLogFilterDateRangeLabel;

  /// No description provided for @adminAuditLogFilterDateRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get adminAuditLogFilterDateRangeHint;

  /// No description provided for @adminAuditLogFilterUserLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminAuditLogFilterUserLabel;

  /// No description provided for @adminAuditLogFilterUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search by user'**
  String get adminAuditLogFilterUserHint;

  /// No description provided for @adminAuditLogFilterModuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get adminAuditLogFilterModuleLabel;

  /// No description provided for @adminAuditLogFilterModuleHint.
  ///
  /// In en, this message translates to:
  /// **'Any module'**
  String get adminAuditLogFilterModuleHint;

  /// No description provided for @adminAuditLogFilterActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get adminAuditLogFilterActionLabel;

  /// No description provided for @adminAuditLogFilterActionHint.
  ///
  /// In en, this message translates to:
  /// **'Action type'**
  String get adminAuditLogFilterActionHint;

  /// No description provided for @adminAuditLogExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get adminAuditLogExport;

  /// No description provided for @adminAuditLogApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get adminAuditLogApplyFilters;

  /// No description provided for @adminAuditLogStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get adminAuditLogStatusSuccess;

  /// No description provided for @adminAuditLogStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get adminAuditLogStatusWarning;

  /// No description provided for @adminAuditLogStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get adminAuditLogStatusError;

  /// No description provided for @adminContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get adminContactTitle;

  /// No description provided for @adminContactFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminContactFieldName;

  /// No description provided for @adminContactFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminContactFieldEmail;

  /// No description provided for @adminContactFieldCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get adminContactFieldCompany;

  /// No description provided for @adminContactFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminContactFieldPhone;

  /// No description provided for @adminContactSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get adminContactSubmit;

  /// No description provided for @adminDockSchedulingTitle.
  ///
  /// In en, this message translates to:
  /// **'Dock scheduling'**
  String get adminDockSchedulingTitle;

  /// No description provided for @adminDockFilterDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get adminDockFilterDateRange;

  /// No description provided for @adminDockFilterWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get adminDockFilterWarehouse;

  /// No description provided for @adminDockFilterCarrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get adminDockFilterCarrier;

  /// No description provided for @adminDockFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminDockFilterStatus;

  /// No description provided for @adminDockPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Dock / Door'**
  String get adminDockPanelTitle;

  /// No description provided for @adminDockPanelTime.
  ///
  /// In en, this message translates to:
  /// **'Time window'**
  String get adminDockPanelTime;

  /// No description provided for @adminDockPanelMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get adminDockPanelMode;

  /// No description provided for @adminDockPanelSpecialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions'**
  String get adminDockPanelSpecialInstructions;

  /// No description provided for @adminDockPanelLiftGate.
  ///
  /// In en, this message translates to:
  /// **'Lift gate'**
  String get adminDockPanelLiftGate;

  /// No description provided for @adminDockPanelCallOnArrival.
  ///
  /// In en, this message translates to:
  /// **'Call on arrival'**
  String get adminDockPanelCallOnArrival;

  /// No description provided for @adminDockReserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve slot'**
  String get adminDockReserve;

  /// No description provided for @adminDockLegendOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get adminDockLegendOutForDelivery;

  /// No description provided for @adminDockLegendDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get adminDockLegendDelivered;

  /// No description provided for @adminDockLegendCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get adminDockLegendCapacity;

  /// No description provided for @adminDockLegendScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get adminDockLegendScheduled;

  /// No description provided for @adminDockActionTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get adminDockActionTrack;

  /// No description provided for @adminDockActionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get adminDockActionContact;

  /// No description provided for @adminDockActionReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get adminDockActionReschedule;

  /// No description provided for @adminDockActionPrintBol.
  ///
  /// In en, this message translates to:
  /// **'Print BOL'**
  String get adminDockActionPrintBol;

  /// No description provided for @adminPayablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts payable run'**
  String get adminPayablesTitle;

  /// No description provided for @adminPayablesBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get adminPayablesBankAccount;

  /// No description provided for @adminPayablesScheduleDate.
  ///
  /// In en, this message translates to:
  /// **'Schedule date'**
  String get adminPayablesScheduleDate;

  /// No description provided for @adminPayablesFilterVendors.
  ///
  /// In en, this message translates to:
  /// **'Filter invoices'**
  String get adminPayablesFilterVendors;

  /// No description provided for @adminPayablesPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get adminPayablesPaymentMethod;

  /// No description provided for @adminPayablesChecksum.
  ///
  /// In en, this message translates to:
  /// **'Checksum'**
  String get adminPayablesChecksum;

  /// No description provided for @adminPayablesSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule payments'**
  String get adminPayablesSchedule;

  /// No description provided for @adminPayablesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total invoice'**
  String get adminPayablesTotal;

  /// No description provided for @adminPayablesDueDates.
  ///
  /// In en, this message translates to:
  /// **'Due dates'**
  String get adminPayablesDueDates;

  /// No description provided for @adminExportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data export'**
  String get adminExportsTitle;

  /// No description provided for @adminExportsDataset.
  ///
  /// In en, this message translates to:
  /// **'Dataset'**
  String get adminExportsDataset;

  /// No description provided for @adminExportsDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get adminExportsDateRange;

  /// No description provided for @adminExportsSelectFields.
  ///
  /// In en, this message translates to:
  /// **'Select fields...'**
  String get adminExportsSelectFields;

  /// No description provided for @adminExportsFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get adminExportsFormat;

  /// No description provided for @adminExportsDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get adminExportsDestination;

  /// No description provided for @adminExportsFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get adminExportsFrequencyLabel;

  /// No description provided for @adminExportsOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get adminExportsOnce;

  /// No description provided for @adminExportsDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get adminExportsDaily;

  /// No description provided for @adminExportsWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get adminExportsWeekly;

  /// No description provided for @adminExportsIncludeFilters.
  ///
  /// In en, this message translates to:
  /// **'Include filters'**
  String get adminExportsIncludeFilters;

  /// No description provided for @adminExportsLastExports.
  ///
  /// In en, this message translates to:
  /// **'Last exports'**
  String get adminExportsLastExports;

  /// No description provided for @adminExportsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get adminExportsCompleted;

  /// No description provided for @adminExportsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminExportsPending;

  /// No description provided for @adminExportsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get adminExportsDownload;

  /// No description provided for @adminApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Order approval'**
  String get adminApprovalTitle;

  /// No description provided for @adminApprovalCartItems.
  ///
  /// In en, this message translates to:
  /// **'Cart items'**
  String get adminApprovalCartItems;

  /// No description provided for @adminApprovalSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get adminApprovalSubtotal;

  /// No description provided for @adminApprovalFlagOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get adminApprovalFlagOverBudget;

  /// No description provided for @adminApprovalFlagNonPreferred.
  ///
  /// In en, this message translates to:
  /// **'Non-preferred vendor'**
  String get adminApprovalFlagNonPreferred;

  /// No description provided for @adminApprovalFlagSplit.
  ///
  /// In en, this message translates to:
  /// **'Split by warehouse'**
  String get adminApprovalFlagSplit;

  /// No description provided for @adminApprovalBudgetHeading.
  ///
  /// In en, this message translates to:
  /// **'Budget utilization'**
  String get adminApprovalBudgetHeading;

  /// No description provided for @adminApprovalAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get adminApprovalAddComment;

  /// No description provided for @adminApprovalApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprovalApprove;

  /// No description provided for @adminApprovalReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminApprovalReject;

  /// No description provided for @adminApprovalRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reject reason required'**
  String get adminApprovalRejectReason;

  /// No description provided for @adminApprovalViewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart items'**
  String get adminApprovalViewCart;

  /// No description provided for @adminApprovalSla.
  ///
  /// In en, this message translates to:
  /// **'SLA'**
  String get adminApprovalSla;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersTableOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get ordersTableOrder;

  /// No description provided for @ordersTableCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get ordersTableCreated;

  /// No description provided for @ordersTableStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ordersTableStatus;

  /// No description provided for @ordersTableTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersTableTotal;

  /// No description provided for @savedListsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved lists'**
  String get savedListsTitle;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newList;

  /// No description provided for @reorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick reorder'**
  String get reorderTitle;

  /// No description provided for @addAll.
  ///
  /// In en, this message translates to:
  /// **'Add all'**
  String get addAll;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {timestamp}'**
  String lastUpdated(Object timestamp);

  /// No description provided for @savedListsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved lists yet'**
  String get savedListsEmptyTitle;

  /// No description provided for @savedListsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create lists to quickly add repeat items.'**
  String get savedListsEmptyMessage;

  /// No description provided for @savedListsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved lists unavailable'**
  String get savedListsErrorTitle;

  /// No description provided for @savedListsAddAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added all {itemCount} items from \"{listName}\"'**
  String savedListsAddAllSuccess(Object itemCount, Object listName);

  /// No description provided for @reorderEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No items to reorder'**
  String get reorderEmptyTitle;

  /// No description provided for @reorderEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a previous order to add its items again.'**
  String get reorderEmptyMessage;

  /// No description provided for @reorderErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder unavailable'**
  String get reorderErrorTitle;

  /// No description provided for @reorderTotalUnitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total units: {count}'**
  String reorderTotalUnitsLabel(Object count);

  /// No description provided for @reorderTableItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get reorderTableItem;

  /// No description provided for @reorderTableSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get reorderTableSku;

  /// No description provided for @reorderTableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get reorderTableQuantity;

  /// No description provided for @reorderAddAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added {itemCount} items to cart'**
  String reorderAddAllSuccess(Object itemCount);

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @vendorQueue.
  ///
  /// In en, this message translates to:
  /// **'Vendor Approval Queue'**
  String get vendorQueue;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Go to catalog'**
  String get ordersEmptyCta;

  /// No description provided for @ordersError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get ordersError;

  /// No description provided for @ordersRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ordersRetry;

  /// No description provided for @ordersRfqsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Requests for quotes'**
  String get ordersRfqsTooltip;

  /// No description provided for @ordersStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get ordersStatusDraft;

  /// No description provided for @ordersStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get ordersStatusProcessing;

  /// No description provided for @ordersStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get ordersStatusSubmitted;

  /// No description provided for @ordersStatusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get ordersStatusPendingApproval;

  /// No description provided for @ordersStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get ordersStatusApproved;

  /// No description provided for @ordersStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get ordersStatusRejected;

  /// No description provided for @ordersStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersStatusCompleted;

  /// No description provided for @ordersStatusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersStatusShipped;

  /// No description provided for @ordersStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersStatusCancelled;

  /// No description provided for @ordersStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get ordersStatusInTransit;

  /// No description provided for @statusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Placed'**
  String get statusPlaced;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get statusRequested;

  /// No description provided for @statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get statusReceived;

  /// No description provided for @statusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get statusRefunded;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetailTitle;

  /// No description provided for @orderDetailLines.
  ///
  /// In en, this message translates to:
  /// **'Order lines'**
  String get orderDetailLines;

  /// No description provided for @orderDetailShipments.
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get orderDetailShipments;

  /// No description provided for @orderDetailNoLines.
  ///
  /// In en, this message translates to:
  /// **'No lines for this order'**
  String get orderDetailNoLines;

  /// No description provided for @orderDetailNoShipments.
  ///
  /// In en, this message translates to:
  /// **'Shipments are not ready yet'**
  String get orderDetailNoShipments;

  /// No description provided for @orderDetailSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get orderDetailSubtotal;

  /// No description provided for @orderDetailTax.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get orderDetailTax;

  /// No description provided for @orderDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderDetailTotal;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @subtotalShort.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalShort;

  /// No description provided for @vatShort.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vatShort;

  /// No description provided for @totalShort.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalShort;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @order_detail_reorder_btn.
  ///
  /// In en, this message translates to:
  /// **'Reorder order'**
  String get order_detail_reorder_btn;

  /// No description provided for @orderDetailReorderError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reorder this order. Error: {message}'**
  String orderDetailReorderError(Object message);

  /// No description provided for @orderDetailSkuPrefix.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get orderDetailSkuPrefix;

  /// No description provided for @orderDetailLineSkuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get orderDetailLineSkuLabel;

  /// No description provided for @orderDetailLineQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get orderDetailLineQuantityLabel;

  /// No description provided for @orderDetailLineUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get orderDetailLineUnitPriceLabel;

  /// No description provided for @orderDetailTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get orderDetailTrackingLabel;

  /// No description provided for @orderDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get orderDetailCreatedAt;

  /// No description provided for @orderCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancelTitle;

  /// No description provided for @orderCancelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can cancel this order before it ships.'**
  String get orderCancelSubtitle;

  /// No description provided for @orderCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancelButton;

  /// No description provided for @orderCancelStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get orderCancelStatusTitle;

  /// No description provided for @orderCancelStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This order has been cancelled.'**
  String get orderCancelStatusSubtitle;

  /// No description provided for @orderCancelCancelledAt.
  ///
  /// In en, this message translates to:
  /// **'Cancelled on {date}'**
  String orderCancelCancelledAt(Object date);

  /// No description provided for @orderCancelReasonValue.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String orderCancelReasonValue(Object reason);

  /// No description provided for @orderCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get orderCancelDialogTitle;

  /// No description provided for @orderCancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you are cancelling (optional).'**
  String get orderCancelDialogMessage;

  /// No description provided for @orderCancelReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get orderCancelReasonLabel;

  /// No description provided for @orderCancelDialogKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get orderCancelDialogKeep;

  /// No description provided for @orderCancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancelDialogConfirm;

  /// No description provided for @orderCancelQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. We\'ll cancel when you\'re back online.'**
  String get orderCancelQueued;

  /// No description provided for @orderCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get orderCancelSuccess;

  /// No description provided for @orderCancelError.
  ///
  /// In en, this message translates to:
  /// **'Unable to cancel order.'**
  String get orderCancelError;

  /// No description provided for @orderReturnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get orderReturnsTitle;

  /// No description provided for @orderReturnsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request a return for delivered items.'**
  String get orderReturnsSubtitle;

  /// No description provided for @orderReturnsNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Returns open after shipment.'**
  String get orderReturnsNotEligible;

  /// No description provided for @orderReturnsFetchError.
  ///
  /// In en, this message translates to:
  /// **'Return history is currently unavailable.'**
  String get orderReturnsFetchError;

  /// No description provided for @orderReturnsReturnableLabel.
  ///
  /// In en, this message translates to:
  /// **'Returnable'**
  String get orderReturnsReturnableLabel;

  /// No description provided for @orderReturnsRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Request return'**
  String get orderReturnsRequestButton;

  /// No description provided for @orderReturnsExistingLabel.
  ///
  /// In en, this message translates to:
  /// **'Existing requests'**
  String get orderReturnsExistingLabel;

  /// No description provided for @orderReturnsNoReturnable.
  ///
  /// In en, this message translates to:
  /// **'No returnable quantity left.'**
  String get orderReturnsNoReturnable;

  /// No description provided for @orderReturnsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a return'**
  String get orderReturnsDialogTitle;

  /// No description provided for @orderReturnsMaxHint.
  ///
  /// In en, this message translates to:
  /// **'Max {max}'**
  String orderReturnsMaxHint(Object max);

  /// No description provided for @orderReturnsReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get orderReturnsReasonLabel;

  /// No description provided for @orderReturnsReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you are returning this item.'**
  String get orderReturnsReasonHint;

  /// No description provided for @orderReturnsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orderReturnsCancel;

  /// No description provided for @orderReturnsSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get orderReturnsSubmit;

  /// No description provided for @orderReturnsQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. We\'ll submit when you\'re back online.'**
  String get orderReturnsQueued;

  /// No description provided for @orderReturnsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Return request submitted.'**
  String get orderReturnsSubmitted;

  /// No description provided for @orderReturnsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit return request.'**
  String get orderReturnsError;

  /// No description provided for @orderRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your vendors'**
  String get orderRatingTitle;

  /// No description provided for @orderRatingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help other buyers by sharing your feedback.'**
  String get orderRatingSubtitle;

  /// No description provided for @orderRatingCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get orderRatingCommentLabel;

  /// No description provided for @orderRatingCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share what worked well or what to improve.'**
  String get orderRatingCommentHint;

  /// No description provided for @orderRatingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get orderRatingSubmit;

  /// No description provided for @orderRatingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback.'**
  String get orderRatingSubmitted;

  /// No description provided for @orderRatingQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. We\'ll submit when you\'re back online.'**
  String get orderRatingQueued;

  /// No description provided for @orderRatingSummary.
  ///
  /// In en, this message translates to:
  /// **'{avg} / {count} ratings'**
  String orderRatingSummary(Object avg, Object count);

  /// No description provided for @orderRatingEmptySummary.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get orderRatingEmptySummary;

  /// No description provided for @orderRatingLoadingSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading ratings...'**
  String get orderRatingLoadingSummary;

  /// No description provided for @orderRatingSummaryError.
  ///
  /// In en, this message translates to:
  /// **'Ratings unavailable'**
  String get orderRatingSummaryError;

  /// No description provided for @orderRatingError.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit rating.'**
  String get orderRatingError;

  /// No description provided for @supportAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Support Assistant'**
  String get supportAiTitle;

  /// No description provided for @supportAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about orders, invoices, or vendor policies.'**
  String get supportAiSubtitle;

  /// No description provided for @supportAiHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a question...'**
  String get supportAiHint;

  /// No description provided for @supportAiSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supportAiSend;

  /// No description provided for @supportAiIntro.
  ///
  /// In en, this message translates to:
  /// **'Hi! I can help with orders, returns, and account questions.'**
  String get supportAiIntro;

  /// No description provided for @supportAiOfflineFallback.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. I can share general guidance, but account-specific answers need a connection.'**
  String get supportAiOfflineFallback;

  /// No description provided for @supportAiError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the assistant. Try again.'**
  String get supportAiError;

  /// No description provided for @supportAiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI answers are best-effort. Verify critical details.'**
  String get supportAiDisclaimer;

  /// No description provided for @approvalTimeline.
  ///
  /// In en, this message translates to:
  /// **'Approval timeline'**
  String get approvalTimeline;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @resendForApproval.
  ///
  /// In en, this message translates to:
  /// **'Resend for approval'**
  String get resendForApproval;

  /// No description provided for @catalogSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog search'**
  String get catalogSearchTitle;

  /// No description provided for @catalogSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, SKU or vendor'**
  String get catalogSearchPlaceholder;

  /// No description provided for @catalogSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products found for this search.'**
  String get catalogSearchEmpty;

  /// No description provided for @catalogSearchError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load products right now.'**
  String get catalogSearchError;

  /// No description provided for @catalogSearchRetry.
  ///
  /// In en, this message translates to:
  /// **'Try search again'**
  String get catalogSearchRetry;

  /// No description provided for @catalogSearchAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get catalogSearchAddToCart;

  /// No description provided for @catalogSearchAddToCartError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add to cart. Try again.'**
  String get catalogSearchAddToCartError;

  /// No description provided for @filterInStockOnly.
  ///
  /// In en, this message translates to:
  /// **'In stock only'**
  String get filterInStockOnly;

  /// No description provided for @filterMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get filterMinPrice;

  /// No description provided for @filterMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get filterMaxPrice;

  /// No description provided for @filterCategoriesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get filterCategoriesLoading;

  /// No description provided for @filterAllCategoriesShort.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get filterAllCategoriesShort;

  /// No description provided for @filterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get filterAllCategories;

  /// No description provided for @catalogSearchLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get catalogSearchLoadMore;

  /// No description provided for @catalogRequestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get catalogRequestAccess;

  /// No description provided for @catalogRequestAccessSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent to the sales team.'**
  String get catalogRequestAccessSuccess;

  /// No description provided for @catalogRequestAccessError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send the request.'**
  String get catalogRequestAccessError;

  /// No description provided for @quickOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick order'**
  String get quickOrderTitle;

  /// No description provided for @quickOrderPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode, type SKU or keyword'**
  String get quickOrderPlaceholder;

  /// No description provided for @quickOrderAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get quickOrderAddButton;

  /// No description provided for @quickOrderSubmitDraft.
  ///
  /// In en, this message translates to:
  /// **'Submit draft'**
  String get quickOrderSubmitDraft;

  /// No description provided for @quickOrderSubmitDisabled.
  ///
  /// In en, this message translates to:
  /// **'Add at least one line'**
  String get quickOrderSubmitDisabled;

  /// No description provided for @quickOrderSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Draft submitted'**
  String get quickOrderSubmitSuccess;

  /// No description provided for @quickOrderSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Submit failed'**
  String get quickOrderSubmitError;

  /// No description provided for @quickOrderAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to draft'**
  String get quickOrderAddSuccess;

  /// No description provided for @quickOrderAddError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add'**
  String get quickOrderAddError;

  /// No description provided for @quickOrderTabQuickOrder.
  ///
  /// In en, this message translates to:
  /// **'Quick order'**
  String get quickOrderTabQuickOrder;

  /// No description provided for @quickOrderTabReorders.
  ///
  /// In en, this message translates to:
  /// **'Reorders'**
  String get quickOrderTabReorders;

  /// No description provided for @quickOrderCategoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get quickOrderCategoryFilter;

  /// No description provided for @quickOrderCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get quickOrderCategoryAll;

  /// No description provided for @quickOrderTabCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get quickOrderTabCatalog;

  /// No description provided for @quickOrderTabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get quickOrderTabCategories;

  /// No description provided for @quickOrderTabPromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get quickOrderTabPromotions;

  /// No description provided for @quickOrderTabCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get quickOrderTabCart;

  /// No description provided for @quickOrderTabCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get quickOrderTabCheckout;

  /// No description provided for @quickOrderReorderEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your repeat purchases will appear here soon.'**
  String get quickOrderReorderEmpty;

  /// No description provided for @quickOrderCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Browse categories to filter quick order results.'**
  String get quickOrderCategoriesEmpty;

  /// No description provided for @quickOrderCheckoutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Add items to your cart before proceeding to checkout.'**
  String get quickOrderCheckoutUnavailable;

  /// No description provided for @quickOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matches yet.'**
  String get quickOrderEmpty;

  /// No description provided for @quickOrderLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more results'**
  String get quickOrderLoadMore;

  /// No description provided for @catalogErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog unavailable'**
  String get catalogErrorTitle;

  /// No description provided for @catalogErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the catalog right now. Please try again shortly.'**
  String get catalogErrorMessage;

  /// No description provided for @catalogRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get catalogRetry;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check back soon or adjust filters.'**
  String get catalogEmptyMessage;

  /// No description provided for @catalogEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Refresh catalog'**
  String get catalogEmptyCta;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'After you place orders you will see them here.'**
  String get ordersEmptyMessage;

  /// No description provided for @quickOrderBulkHint.
  ///
  /// In en, this message translates to:
  /// **'Bulk input (SKU or keyword list)'**
  String get quickOrderBulkHint;

  /// No description provided for @quickOrderBulkExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. SKU-1 x2, BAR-998 x5, mint x3'**
  String get quickOrderBulkExample;

  /// No description provided for @quickOrderBulkReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review entries'**
  String get quickOrderBulkReviewAction;

  /// No description provided for @quickOrderBulkPasteCsv.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV'**
  String get quickOrderBulkPasteCsv;

  /// No description provided for @quickOrderBulkClear.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get quickOrderBulkClear;

  /// No description provided for @quickOrderBulkReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review and confirm'**
  String get quickOrderBulkReviewTitle;

  /// No description provided for @quickOrderBulkReviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to add yet.'**
  String get quickOrderBulkReviewEmpty;

  /// No description provided for @quickOrderBulkReviewConfirmPending.
  ///
  /// In en, this message translates to:
  /// **'Confirm matches before adding.'**
  String get quickOrderBulkReviewConfirmPending;

  /// No description provided for @quickOrderBulkClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty.'**
  String get quickOrderBulkClipboardEmpty;

  /// No description provided for @quickOrderBulkCsvError.
  ///
  /// In en, this message translates to:
  /// **'Could not parse CSV input'**
  String get quickOrderBulkCsvError;

  /// No description provided for @quickOrderBulkParsing.
  ///
  /// In en, this message translates to:
  /// **'Looking up items...'**
  String get quickOrderBulkParsing;

  /// No description provided for @quickOrderBulkTableHeaderCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get quickOrderBulkTableHeaderCode;

  /// No description provided for @quickOrderBulkTableHeaderQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quickOrderBulkTableHeaderQty;

  /// No description provided for @quickOrderBulkTableHeaderResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get quickOrderBulkTableHeaderResult;

  /// No description provided for @quickOrderBulkStatusMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get quickOrderBulkStatusMatched;

  /// No description provided for @quickOrderBulkStatusAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Adjusted'**
  String get quickOrderBulkStatusAdjusted;

  /// No description provided for @quickOrderBulkStatusKeyword.
  ///
  /// In en, this message translates to:
  /// **'Keyword match'**
  String get quickOrderBulkStatusKeyword;

  /// No description provided for @quickOrderBulkStatusAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Multiple matches'**
  String get quickOrderBulkStatusAmbiguous;

  /// No description provided for @quickOrderBulkStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get quickOrderBulkStatusNotFound;

  /// No description provided for @quickOrderBulkStatusError.
  ///
  /// In en, this message translates to:
  /// **'Invalid entry'**
  String get quickOrderBulkStatusError;

  /// No description provided for @quickOrderBulkStatusAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get quickOrderBulkStatusAdded;

  /// No description provided for @quickOrderBulkStatusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Select a product to confirm'**
  String get quickOrderBulkStatusNeedsReview;

  /// No description provided for @quickOrderBulkStatusDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get quickOrderBulkStatusDetailsLabel;

  /// No description provided for @quickOrderBulkSkuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get quickOrderBulkSkuLabel;

  /// No description provided for @quickOrderBulkSelectSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Pick a suggestion'**
  String get quickOrderBulkSelectSuggestion;

  /// No description provided for @quickOrderBulkChangeSelection.
  ///
  /// In en, this message translates to:
  /// **'Change selection'**
  String get quickOrderBulkChangeSelection;

  /// No description provided for @quickOrderBulkSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a product'**
  String get quickOrderBulkSuggestionTitle;

  /// No description provided for @quickOrderBulkSuggestionCancel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get quickOrderBulkSuggestionCancel;

  /// No description provided for @quickOrderBulkStatusMatchedManual.
  ///
  /// In en, this message translates to:
  /// **'Confirmed manually'**
  String get quickOrderBulkStatusMatchedManual;

  /// No description provided for @quickOrderBulkAdjustmentPackApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied pack size {packSize}: {packs} x {packSize} = {units}'**
  String quickOrderBulkAdjustmentPackApplied(
      Object packSize, Object packs, Object units);

  /// No description provided for @quickOrderBulkAdjustmentPackMissing.
  ///
  /// In en, this message translates to:
  /// **'Pack size not configured; using {requested} as units.'**
  String quickOrderBulkAdjustmentPackMissing(Object requested);

  /// No description provided for @quickOrderBulkAdjustmentRaisedMoq.
  ///
  /// In en, this message translates to:
  /// **'MOQ {moq}; raised from {requested} to {finalValue}'**
  String quickOrderBulkAdjustmentRaisedMoq(
      Object finalValue, Object moq, Object requested);

  /// No description provided for @quickOrderBulkAdjustmentRoundedPack.
  ///
  /// In en, this message translates to:
  /// **'Rounded to pack multiple {packSize}: {requested} -> {finalValue}'**
  String quickOrderBulkAdjustmentRoundedPack(
      Object finalValue, Object packSize, Object requested);

  /// No description provided for @quickOrderBulkAddAll.
  ///
  /// In en, this message translates to:
  /// **'Add all'**
  String get quickOrderBulkAddAll;

  /// No description provided for @quickOrderBulkSnackbarAdded.
  ///
  /// In en, this message translates to:
  /// **'Added lines to draft'**
  String get quickOrderBulkSnackbarAdded;

  /// No description provided for @quickOrderBulkUndoLabel.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get quickOrderBulkUndoLabel;

  /// No description provided for @quickOrderBulkUndoDone.
  ///
  /// In en, this message translates to:
  /// **'Bulk add undone'**
  String get quickOrderBulkUndoDone;

  /// No description provided for @catalogSearchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get catalogSearchRecent;

  /// No description provided for @catalogSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get catalogSearchClear;

  /// No description provided for @catalogSearchNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No recent searches yet.'**
  String get catalogSearchNoRecent;

  /// No description provided for @vendorConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Vendor Console'**
  String get vendorConsoleTitle;

  /// No description provided for @vendorOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get vendorOrdersTab;

  /// No description provided for @vendorRfqsTab.
  ///
  /// In en, this message translates to:
  /// **'RFQs'**
  String get vendorRfqsTab;

  /// No description provided for @vendorOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No vendor orders yet'**
  String get vendorOrdersEmptyTitle;

  /// No description provided for @vendorOrdersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Orders assigned to your company will appear here.'**
  String get vendorOrdersEmptyBody;

  /// No description provided for @vendorOrdersError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vendor orders'**
  String get vendorOrdersError;

  /// No description provided for @vendorOrdersRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get vendorOrdersRetry;

  /// No description provided for @vendorOrdersOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get vendorOrdersOrderLabel;

  /// No description provided for @vendorOrdersAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get vendorOrdersAmountLabel;

  /// No description provided for @vendorShipmentsTab.
  ///
  /// In en, this message translates to:
  /// **'Shipments'**
  String get vendorShipmentsTab;

  /// No description provided for @vendorShipmentsFiltersStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get vendorShipmentsFiltersStatus;

  /// No description provided for @vendorShipmentsFiltersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get vendorShipmentsFiltersReset;

  /// No description provided for @vendorShipmentsDateRangePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get vendorShipmentsDateRangePlaceholder;

  /// No description provided for @vendorShipmentsDateRangeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get vendorShipmentsDateRangeClear;

  /// No description provided for @vendorShipmentsFiltersSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search shipments'**
  String get vendorShipmentsFiltersSearchPlaceholder;

  /// No description provided for @vendorShipmentsSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get vendorShipmentsSearchClear;

  /// No description provided for @vendorShipmentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shipments yet'**
  String get vendorShipmentsEmptyTitle;

  /// No description provided for @vendorShipmentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Shipments will appear once orders are fulfilled.'**
  String get vendorShipmentsEmptyBody;

  /// No description provided for @vendorShipmentsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shipments'**
  String get vendorShipmentsError;

  /// No description provided for @vendorShipmentsRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get vendorShipmentsRetry;

  /// No description provided for @vendorShipmentsOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get vendorShipmentsOrderLabel;

  /// No description provided for @vendorShipmentsCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get vendorShipmentsCreatedLabel;

  /// No description provided for @vendorShipmentsRowTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get vendorShipmentsRowTracking;

  /// No description provided for @vendorShipmentsTrackingPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No tracking number yet'**
  String get vendorShipmentsTrackingPlaceholder;

  /// No description provided for @vendorShipmentsUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get vendorShipmentsUpdateAction;

  /// No description provided for @vendorShipmentsUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update shipment'**
  String get vendorShipmentsUpdateTitle;

  /// No description provided for @vendorShipmentsUpdateStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get vendorShipmentsUpdateStatusLabel;

  /// No description provided for @vendorShipmentsUpdateTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get vendorShipmentsUpdateTrackingLabel;

  /// No description provided for @vendorShipmentsUpdateCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get vendorShipmentsUpdateCancel;

  /// No description provided for @vendorShipmentsUpdateSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get vendorShipmentsUpdateSave;

  /// No description provided for @vendorShipmentsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shipment updated'**
  String get vendorShipmentsUpdated;

  /// No description provided for @vendorShipmentsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update shipment'**
  String get vendorShipmentsUpdateFailed;

  /// No description provided for @shipmentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get shipmentStatusPending;

  /// No description provided for @shipmentStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get shipmentStatusReady;

  /// No description provided for @shipmentStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get shipmentStatusInTransit;

  /// No description provided for @shipmentStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get shipmentStatusDelivered;

  /// No description provided for @shipmentStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get shipmentStatusCancelled;

  /// No description provided for @productGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get productGalleryTitle;

  /// No description provided for @productVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get productVariantsTitle;

  /// No description provided for @productSpecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productSpecsTitle;

  /// No description provided for @productAttributesTitle.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get productAttributesTitle;

  /// No description provided for @productAddToDraft.
  ///
  /// In en, this message translates to:
  /// **'Add to draft'**
  String get productAddToDraft;

  /// No description provided for @productAddedToDraft.
  ///
  /// In en, this message translates to:
  /// **'Added to draft'**
  String get productAddedToDraft;

  /// No description provided for @productAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add to draft'**
  String get productAddFailed;

  /// No description provided for @productSpecsUom.
  ///
  /// In en, this message translates to:
  /// **'Unit of measure'**
  String get productSpecsUom;

  /// No description provided for @productSpecsMoq.
  ///
  /// In en, this message translates to:
  /// **'Minimum order quantity'**
  String get productSpecsMoq;

  /// No description provided for @productSpecsLeadTime.
  ///
  /// In en, this message translates to:
  /// **'Lead time'**
  String get productSpecsLeadTime;

  /// No description provided for @productSpecsLeadTimeUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get productSpecsLeadTimeUnit;

  /// No description provided for @productSpecsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get productSpecsUnknown;

  /// No description provided for @productQtyHeading.
  ///
  /// In en, this message translates to:
  /// **'Order quantity'**
  String get productQtyHeading;

  /// No description provided for @productQtyUomLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit of measure'**
  String get productQtyUomLabel;

  /// No description provided for @productQtyUomUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get productQtyUomUnit;

  /// No description provided for @productQtyUomCase.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get productQtyUomCase;

  /// No description provided for @productQtyUomPallet.
  ///
  /// In en, this message translates to:
  /// **'Pallet'**
  String get productQtyUomPallet;

  /// No description provided for @productQtyUomUnitDetail.
  ///
  /// In en, this message translates to:
  /// **'Unit • {uom}'**
  String productQtyUomUnitDetail(Object uom);

  /// No description provided for @productQtyUomCaseDetail.
  ///
  /// In en, this message translates to:
  /// **'Case • {count} {uom}'**
  String productQtyUomCaseDetail(Object count, Object uom);

  /// No description provided for @productQtyUomCaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Case details unavailable'**
  String get productQtyUomCaseUnavailable;

  /// No description provided for @productQtyUomPalletDetail.
  ///
  /// In en, this message translates to:
  /// **'Pallet • {count} {uom}'**
  String productQtyUomPalletDetail(Object count, Object uom);

  /// No description provided for @productQtyUomPalletCasesSuffix.
  ///
  /// In en, this message translates to:
  /// **'({cases} cases)'**
  String productQtyUomPalletCasesSuffix(Object cases);

  /// No description provided for @productQtyUomPalletUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Pallet details unavailable'**
  String get productQtyUomPalletUnavailable;

  /// No description provided for @productQtyMoqLabel.
  ///
  /// In en, this message translates to:
  /// **'MOQ'**
  String get productQtyMoqLabel;

  /// No description provided for @productQtyStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step (multiples)'**
  String get productQtyStepLabel;

  /// No description provided for @productQtyErrorBelowMoq.
  ///
  /// In en, this message translates to:
  /// **'Order at least {moq}.'**
  String productQtyErrorBelowMoq(Object moq);

  /// No description provided for @productQtyErrorStep.
  ///
  /// In en, this message translates to:
  /// **'Order in multiples of {step}.'**
  String productQtyErrorStep(Object step);

  /// No description provided for @productQtyUomUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unavailable for this variant'**
  String get productQtyUomUnavailableTooltip;

  /// No description provided for @productQtyStepperSemantic.
  ///
  /// In en, this message translates to:
  /// **'Order quantity'**
  String get productQtyStepperSemantic;

  /// No description provided for @productQtyStepperIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get productQtyStepperIncrease;

  /// No description provided for @productQtyStepperDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get productQtyStepperDecrease;

  /// No description provided for @productPriceBreaksLabel.
  ///
  /// In en, this message translates to:
  /// **'Price breaks'**
  String get productPriceBreaksLabel;

  /// No description provided for @productPriceBreaksQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get productPriceBreaksQty;

  /// No description provided for @productPriceBreaksPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get productPriceBreaksPrice;

  /// No description provided for @productPriceBreaksLoading.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get productPriceBreaksLoading;

  /// No description provided for @productPriceBreaksUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get productPriceBreaksUnavailable;

  /// No description provided for @productEffectivePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Effective price'**
  String get productEffectivePriceLabel;

  /// No description provided for @productEffectivePriceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get productEffectivePriceLoading;

  /// No description provided for @productEffectivePriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get productEffectivePriceUnavailable;

  /// No description provided for @pricingContractTag.
  ///
  /// In en, this message translates to:
  /// **'Contract price'**
  String get pricingContractTag;

  /// No description provided for @pricingSourceContract.
  ///
  /// In en, this message translates to:
  /// **'Contract price'**
  String get pricingSourceContract;

  /// No description provided for @pricingSourcePriceList.
  ///
  /// In en, this message translates to:
  /// **'Price list'**
  String get pricingSourcePriceList;

  /// No description provided for @pricingSourceBase.
  ///
  /// In en, this message translates to:
  /// **'Base price'**
  String get pricingSourceBase;

  /// No description provided for @pricingSourceFallback.
  ///
  /// In en, this message translates to:
  /// **'Standard price'**
  String get pricingSourceFallback;

  /// No description provided for @contractPrice.
  ///
  /// In en, this message translates to:
  /// **'Contract price'**
  String get contractPrice;

  /// No description provided for @notInCatalog.
  ///
  /// In en, this message translates to:
  /// **'Not available for your account'**
  String get notInCatalog;

  /// No description provided for @notInCatalogShort.
  ///
  /// In en, this message translates to:
  /// **'Out of private catalog'**
  String get notInCatalogShort;

  /// No description provided for @notInCatalogDetail.
  ///
  /// In en, this message translates to:
  /// **'This product isn\'t included in your organization\'s catalog'**
  String get notInCatalogDetail;

  /// No description provided for @priceBreaks.
  ///
  /// In en, this message translates to:
  /// **'Price breaks'**
  String get priceBreaks;

  /// No description provided for @atQty.
  ///
  /// In en, this message translates to:
  /// **'at qty'**
  String get atQty;

  /// No description provided for @dash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get dash;

  /// No description provided for @productSelectWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Choose warehouse'**
  String get productSelectWarehouse;

  /// No description provided for @productWarehousesTitle.
  ///
  /// In en, this message translates to:
  /// **'Warehouse availability'**
  String get productWarehousesTitle;

  /// No description provided for @productWarehousesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No warehouses available for this variant.'**
  String get productWarehousesEmpty;

  /// No description provided for @productWarehousePrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary warehouse'**
  String get productWarehousePrimary;

  /// No description provided for @productWarehouseQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get productWarehouseQtyLabel;

  /// No description provided for @productWarehouseQtyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get productWarehouseQtyUnknown;

  /// No description provided for @productWarehouseLeadTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Lead time'**
  String get productWarehouseLeadTimeLabel;

  /// No description provided for @productWarehouseLeadTimeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get productWarehouseLeadTimeUnknown;

  /// No description provided for @productSkuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get productSkuLabel;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not available'**
  String get productNotFound;

  /// No description provided for @adminOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin • Orders'**
  String get adminOrdersTitle;

  /// No description provided for @adminOrdersReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get adminOrdersReload;

  /// No description provided for @adminOrdersFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get adminOrdersFiltersTitle;

  /// No description provided for @adminOrdersFiltersSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get adminOrdersFiltersSearchLabel;

  /// No description provided for @adminOrdersFiltersStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminOrdersFiltersStatusLabel;

  /// No description provided for @adminOrdersFiltersStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get adminOrdersFiltersStatusAll;

  /// No description provided for @adminOrdersFiltersDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get adminOrdersFiltersDateLabel;

  /// No description provided for @adminOrdersFiltersDateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get adminOrdersFiltersDateClear;

  /// No description provided for @adminOrdersFiltersRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get adminOrdersFiltersRangeAll;

  /// No description provided for @adminOrdersFiltersClear.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get adminOrdersFiltersClear;

  /// No description provided for @adminOrdersFiltersActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Filters applied to the table below.'**
  String get adminOrdersFiltersActiveHint;

  /// No description provided for @adminOrdersErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load orders'**
  String get adminOrdersErrorTitle;

  /// No description provided for @adminOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders match your filters'**
  String get adminOrdersEmptyTitle;

  /// No description provided for @adminOrdersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust status, dates, or search to see results.'**
  String get adminOrdersEmptyBody;

  /// No description provided for @adminOrdersTableOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get adminOrdersTableOrder;

  /// No description provided for @adminOrdersTableCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get adminOrdersTableCreated;

  /// No description provided for @adminOrdersTableStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminOrdersTableStatus;

  /// No description provided for @adminOrdersTableTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminOrdersTableTotal;

  /// No description provided for @adminOrdersTableActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminOrdersTableActions;

  /// No description provided for @adminOrdersSplitAction.
  ///
  /// In en, this message translates to:
  /// **'Split order'**
  String get adminOrdersSplitAction;

  /// No description provided for @adminOrdersSplitInProgress.
  ///
  /// In en, this message translates to:
  /// **'Splitting...'**
  String get adminOrdersSplitInProgress;

  /// No description provided for @adminOrdersSplitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order split triggered. Shipments will sync shortly.'**
  String get adminOrdersSplitSuccess;

  /// No description provided for @adminOrdersSplitSuccessWithCount.
  ///
  /// In en, this message translates to:
  /// **'Order split across {count} vendor shipments.'**
  String adminOrdersSplitSuccessWithCount(Object count);

  /// No description provided for @adminOrdersSplitVendorCount.
  ///
  /// In en, this message translates to:
  /// **'Vendors queued: {count}'**
  String adminOrdersSplitVendorCount(Object count);

  /// No description provided for @adminOrdersSplitEdgeWarning.
  ///
  /// In en, this message translates to:
  /// **'Edge sync failed. Shipments were created via RPC.'**
  String get adminOrdersSplitEdgeWarning;

  /// No description provided for @adminOrdersSplitFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to split order: {error}'**
  String adminOrdersSplitFailure(Object error);

  /// No description provided for @adminReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin • Reports'**
  String get adminReportsTitle;

  /// No description provided for @adminReportsRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent exports'**
  String get adminReportsRecentTitle;

  /// No description provided for @adminReportsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get adminReportsEmptyTitle;

  /// No description provided for @adminReportsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Generate a report to receive a signed download link.'**
  String get adminReportsEmptyBody;

  /// No description provided for @adminReportsGenerateCsv.
  ///
  /// In en, this message translates to:
  /// **'Generate CSV'**
  String get adminReportsGenerateCsv;

  /// No description provided for @adminReportsGenerateJson.
  ///
  /// In en, this message translates to:
  /// **'Generate JSON'**
  String get adminReportsGenerateJson;

  /// No description provided for @adminReportsDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate export files'**
  String get adminReportsDescriptionTitle;

  /// No description provided for @adminReportsDescriptionBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a date range and export format to receive a signed URL. Links remain active for a limited time.'**
  String get adminReportsDescriptionBody;

  /// No description provided for @adminReportsPickRange.
  ///
  /// In en, this message translates to:
  /// **'Select range'**
  String get adminReportsPickRange;

  /// No description provided for @adminReportsClearRange.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get adminReportsClearRange;

  /// No description provided for @adminReportsRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get adminReportsRangeAll;

  /// No description provided for @adminReportsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report ready.'**
  String get adminReportsSuccess;

  /// No description provided for @adminReportsSignedUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Report link ready'**
  String get adminReportsSignedUrlTitle;

  /// No description provided for @adminReportsSignedUrlBody.
  ///
  /// In en, this message translates to:
  /// **'Copy the signed URL or open it in a new tab.'**
  String get adminReportsSignedUrlBody;

  /// No description provided for @adminReportsSignedUrlClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get adminReportsSignedUrlClose;

  /// No description provided for @adminReportsFailure.
  ///
  /// In en, this message translates to:
  /// **'Report failed: {error}'**
  String adminReportsFailure(Object error);

  /// No description provided for @adminReportsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open report link.'**
  String get adminReportsOpenFailed;

  /// No description provided for @adminReportsCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get adminReportsCopySuccess;

  /// No description provided for @adminReportsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get adminReportsCopyLink;

  /// No description provided for @adminReportsOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get adminReportsOpenLink;

  /// No description provided for @adminReportsGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated at:'**
  String get adminReportsGeneratedAt;

  /// No description provided for @adminPriceImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin • Price import'**
  String get adminPriceImportTitle;

  /// No description provided for @adminPriceImportReloadVendors.
  ///
  /// In en, this message translates to:
  /// **'Reload vendors'**
  String get adminPriceImportReloadVendors;

  /// No description provided for @adminPriceImportVendorsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vendors'**
  String get adminPriceImportVendorsFailed;

  /// No description provided for @adminPriceImportSelectVendor.
  ///
  /// In en, this message translates to:
  /// **'Select vendor'**
  String get adminPriceImportSelectVendor;

  /// No description provided for @adminPriceImportInstructions.
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV with columns variant_id, min_qty, unit_price.'**
  String get adminPriceImportInstructions;

  /// No description provided for @adminPriceImportHeader.
  ///
  /// In en, this message translates to:
  /// **'Import vendor prices'**
  String get adminPriceImportHeader;

  /// No description provided for @adminPriceImportChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV'**
  String get adminPriceImportChooseFile;

  /// No description provided for @adminPriceImportImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import prices'**
  String get adminPriceImportImportButton;

  /// No description provided for @adminPriceImportRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh effective prices'**
  String get adminPriceImportRefreshButton;

  /// No description provided for @adminPriceImportProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get adminPriceImportProcessing;

  /// No description provided for @adminPriceImportSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Selected file'**
  String get adminPriceImportSelectedFile;

  /// No description provided for @adminPriceImportPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview (first rows)'**
  String get adminPriceImportPreviewTitle;

  /// No description provided for @adminPriceImportPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV to preview the first rows before importing.'**
  String get adminPriceImportPreviewHint;

  /// No description provided for @adminPriceImportPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'CSV appears empty.'**
  String get adminPriceImportPreviewEmpty;

  /// No description provided for @adminPriceImportSelectVendorFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a vendor before importing.'**
  String get adminPriceImportSelectVendorFirst;

  /// No description provided for @adminPriceImportSelectFileFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV file to import.'**
  String get adminPriceImportSelectFileFirst;

  /// No description provided for @adminPriceImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rows processed: {count}'**
  String adminPriceImportSuccess(Object count);

  /// No description provided for @adminPriceImportFailure.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String adminPriceImportFailure(Object error);

  /// No description provided for @adminPriceImportRefreshSuccess.
  ///
  /// In en, this message translates to:
  /// **'Effective prices refreshed.'**
  String get adminPriceImportRefreshSuccess;

  /// No description provided for @adminPriceImportRefreshFailure.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed: {error}'**
  String adminPriceImportRefreshFailure(Object error);

  /// No description provided for @adminPriceImportColumn.
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get adminPriceImportColumn;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutBillToTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill-to address'**
  String get checkoutBillToTitle;

  /// No description provided for @checkoutBillToLabel.
  ///
  /// In en, this message translates to:
  /// **'Billing account'**
  String get checkoutBillToLabel;

  /// No description provided for @checkoutBillToHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the billing account'**
  String get checkoutBillToHint;

  /// No description provided for @checkoutShipToTitle.
  ///
  /// In en, this message translates to:
  /// **'Ship-to address'**
  String get checkoutShipToTitle;

  /// No description provided for @checkoutShipToLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery location'**
  String get checkoutShipToLabel;

  /// No description provided for @checkoutShipToHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the ship-to location'**
  String get checkoutShipToHint;

  /// No description provided for @checkoutPaymentTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get checkoutPaymentTermsTitle;

  /// No description provided for @checkoutBillToPrimaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Primary billing account'**
  String get checkoutBillToPrimaryTitle;

  /// No description provided for @checkoutBillToPrimaryDescription.
  ///
  /// In en, this message translates to:
  /// **'123 Herzl St, Tel Aviv'**
  String get checkoutBillToPrimaryDescription;

  /// No description provided for @checkoutBillToFinanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance department'**
  String get checkoutBillToFinanceTitle;

  /// No description provided for @checkoutBillToFinanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Accounting HQ - 56 Rothschild Blvd'**
  String get checkoutBillToFinanceDescription;

  /// No description provided for @checkoutShipToWarehouseTitle.
  ///
  /// In en, this message translates to:
  /// **'Main warehouse'**
  String get checkoutShipToWarehouseTitle;

  /// No description provided for @checkoutShipToWarehouseDescription.
  ///
  /// In en, this message translates to:
  /// **'Logistics Center, Ashdod Port'**
  String get checkoutShipToWarehouseDescription;

  /// No description provided for @checkoutShipToBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Southern branch'**
  String get checkoutShipToBranchTitle;

  /// No description provided for @checkoutShipToBranchDescription.
  ///
  /// In en, this message translates to:
  /// **'152 Emek Hefer Industrial Park'**
  String get checkoutShipToBranchDescription;

  /// No description provided for @checkoutPaymentNet30.
  ///
  /// In en, this message translates to:
  /// **'Net 30'**
  String get checkoutPaymentNet30;

  /// No description provided for @checkoutPaymentNet45.
  ///
  /// In en, this message translates to:
  /// **'Net 45'**
  String get checkoutPaymentNet45;

  /// No description provided for @checkoutPaymentNet60.
  ///
  /// In en, this message translates to:
  /// **'Net 60'**
  String get checkoutPaymentNet60;

  /// No description provided for @checkoutPaymentPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get checkoutPaymentPayNow;

  /// No description provided for @checkoutSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get checkoutSummaryTitle;

  /// No description provided for @checkoutSummarySubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get checkoutSummarySubtotal;

  /// No description provided for @checkoutSummaryTaxes.
  ///
  /// In en, this message translates to:
  /// **'Estimated VAT'**
  String get checkoutSummaryTaxes;

  /// No description provided for @checkoutSummaryTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get checkoutSummaryTotal;

  /// No description provided for @checkoutSummaryError.
  ///
  /// In en, this message translates to:
  /// **'We could not load order totals.'**
  String get checkoutSummaryError;

  /// No description provided for @checkoutSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get checkoutSummaryEmpty;

  /// No description provided for @approvalSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send for approval'**
  String get approvalSendButton;

  /// No description provided for @approvalResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend for approval'**
  String get approvalResendButton;

  /// No description provided for @approvalSendLoading.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get approvalSendLoading;

  /// No description provided for @approvalSendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Approval request sent.'**
  String get approvalSendSuccess;

  /// No description provided for @approvalSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send approval request.'**
  String get approvalSendError;

  /// No description provided for @approvalPendingCta.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get approvalPendingCta;

  /// No description provided for @approvalSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit order'**
  String get approvalSubmitButton;

  /// No description provided for @approvalSubmitLoading.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get approvalSubmitLoading;

  /// No description provided for @approvalSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order submitted successfully.'**
  String get approvalSubmitSuccess;

  /// No description provided for @approvalSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit the order.'**
  String get approvalSubmitError;

  /// No description provided for @approvalBannerNotRequired.
  ///
  /// In en, this message translates to:
  /// **'No approval required. Submit whenever you are ready.'**
  String get approvalBannerNotRequired;

  /// No description provided for @approvalBannerRequires.
  ///
  /// In en, this message translates to:
  /// **'This order requires approval before submission.'**
  String get approvalBannerRequires;

  /// No description provided for @approvalBannerPending.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval from your approvers.'**
  String get approvalBannerPending;

  /// No description provided for @approvalBannerApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved — ready to submit.'**
  String get approvalBannerApproved;

  /// No description provided for @approvalBannerRejected.
  ///
  /// In en, this message translates to:
  /// **'Approval was rejected. Update and resend.'**
  String get approvalBannerRejected;

  /// No description provided for @approvalBannerRejectedWithReason.
  ///
  /// In en, this message translates to:
  /// **'Approval rejected: {reason}'**
  String approvalBannerRejectedWithReason(Object reason);

  /// No description provided for @approvalBannerError.
  ///
  /// In en, this message translates to:
  /// **'Could not load approval status.'**
  String get approvalBannerError;

  /// No description provided for @approvalRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'Review the order and address any notes before resending.'**
  String get approvalRejectedHint;

  /// No description provided for @approvalsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Approvals Inbox'**
  String get approvalsInboxTitle;

  /// No description provided for @approvalsInboxRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh inbox'**
  String get approvalsInboxRefresh;

  /// No description provided for @approvalsInboxEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending approvals'**
  String get approvalsInboxEmptyTitle;

  /// No description provided for @approvalsInboxEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get approvalsInboxEmptyBody;

  /// No description provided for @approvalsInboxErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox unavailable'**
  String get approvalsInboxErrorTitle;

  /// No description provided for @approvalsInboxRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get approvalsInboxRetry;

  /// No description provided for @approvalsInboxApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approvalsInboxApprove;

  /// No description provided for @approvalsInboxReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get approvalsInboxReject;

  /// No description provided for @approvalsInboxApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Approval recorded.'**
  String get approvalsInboxApproveSuccess;

  /// No description provided for @approvalsInboxRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rejection recorded.'**
  String get approvalsInboxRejectSuccess;

  /// No description provided for @approvalsInboxActionError.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Try again.'**
  String get approvalsInboxActionError;

  /// No description provided for @approvalsInboxRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject approval'**
  String get approvalsInboxRejectDialogTitle;

  /// No description provided for @approvalsInboxRejectDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get approvalsInboxRejectDialogLabel;

  /// No description provided for @approvalsInboxRejectDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the rejection (optional)'**
  String get approvalsInboxRejectDialogHint;

  /// No description provided for @approvalsInboxRejectCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get approvalsInboxRejectCancel;

  /// No description provided for @approvalsInboxRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get approvalsInboxRejectConfirm;

  /// No description provided for @approvalsInboxRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested by: {name}'**
  String approvalsInboxRequestedBy(Object name);

  /// No description provided for @approvalsInboxBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer: {name}'**
  String approvalsInboxBuyer(Object name);

  /// No description provided for @approvalsInboxRequestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested at {time}'**
  String approvalsInboxRequestedAt(Object time);

  /// No description provided for @approvalsInboxNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get approvalsInboxNoteLabel;

  /// No description provided for @checkoutDraftMissing.
  ///
  /// In en, this message translates to:
  /// **'Unable to open checkout without a cart.'**
  String get checkoutDraftMissing;

  /// No description provided for @checkoutContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Review and confirm'**
  String get checkoutContinueButton;

  /// No description provided for @checkoutMissingBillTo.
  ///
  /// In en, this message translates to:
  /// **'Bill-to address'**
  String get checkoutMissingBillTo;

  /// No description provided for @checkoutMissingShipTo.
  ///
  /// In en, this message translates to:
  /// **'Ship-to address'**
  String get checkoutMissingShipTo;

  /// No description provided for @checkoutMissingPaymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get checkoutMissingPaymentTerms;

  /// No description provided for @checkoutMissingData.
  ///
  /// In en, this message translates to:
  /// **'Please complete: {fields}'**
  String checkoutMissingData(Object fields);

  /// No description provided for @checkoutMissingSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get checkoutMissingSeparator;

  /// No description provided for @checkoutComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Checkout submission coming soon.'**
  String get checkoutComingSoon;

  /// No description provided for @cartProceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get cartProceedToCheckout;

  /// No description provided for @cartDraftLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your draft cart.'**
  String get cartDraftLoadError;

  /// No description provided for @cartLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the cart.'**
  String get cartLoadError;

  /// No description provided for @cartActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Cart action failed.'**
  String get cartActionFailed;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty right now.'**
  String get cartEmptyMessage;

  /// No description provided for @cartBrowseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Back to catalog'**
  String get cartBrowseCatalog;

  /// No description provided for @cartRequestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request a quote'**
  String get cartRequestQuote;

  /// No description provided for @cartVendorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor {vendor}'**
  String cartVendorLabel(Object vendor);

  /// No description provided for @cartVendorRestricted.
  ///
  /// In en, this message translates to:
  /// **'Some items from this vendor require approval.'**
  String get cartVendorRestricted;

  /// No description provided for @cartVendorRequestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent to vendor.'**
  String get cartVendorRequestSuccess;

  /// No description provided for @cartRequestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get cartRequestAccess;

  /// No description provided for @cartRequestAccessSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent to vendor.'**
  String get cartRequestAccessSuccess;

  /// No description provided for @cartCreateQuoteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create request.'**
  String get cartCreateQuoteError;

  /// No description provided for @cartCreateQuoteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request sent to vendors.'**
  String get cartCreateQuoteSuccess;

  /// No description provided for @cartRemoveLineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartRemoveLineTooltip;

  /// No description provided for @cartRecommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your order'**
  String get cartRecommendationsTitle;

  /// No description provided for @cartRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Products often ordered together'**
  String get cartRecommendationsSubtitle;

  /// No description provided for @cartRecommendationsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get cartRecommendationsAdd;

  /// No description provided for @cartRecommendationsAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get cartRecommendationsAdded;

  /// No description provided for @recommendationFastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery'**
  String get recommendationFastDelivery;

  /// No description provided for @recommendationLowMoq.
  ///
  /// In en, this message translates to:
  /// **'Low MOQ'**
  String get recommendationLowMoq;

  /// No description provided for @recommendationSmallPack.
  ///
  /// In en, this message translates to:
  /// **'Small pack'**
  String get recommendationSmallPack;

  /// No description provided for @recommendationDefault.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get recommendationDefault;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @rfqStatusAwaitingQuotes.
  ///
  /// In en, this message translates to:
  /// **'Awaiting quotes'**
  String get rfqStatusAwaitingQuotes;

  /// No description provided for @rfqStatusQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted'**
  String get rfqStatusQuoted;

  /// No description provided for @rfqStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get rfqStatusExpired;

  /// No description provided for @rfqLatestQuoteStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest quote status'**
  String get rfqLatestQuoteStatusLabel;

  /// No description provided for @rfqListTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests for quotes'**
  String get rfqListTitle;

  /// No description provided for @rfqCreateCta.
  ///
  /// In en, this message translates to:
  /// **'New RFQ'**
  String get rfqCreateCta;

  /// No description provided for @rfqCustomerStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer status'**
  String get rfqCustomerStatusLabel;

  /// No description provided for @rfqVendorStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor status'**
  String get rfqVendorStatusLabel;

  /// No description provided for @rfqQuoteSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Received quotes'**
  String get rfqQuoteSectionTitle;

  /// No description provided for @rfqQuotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quotes yet'**
  String get rfqQuotesEmpty;

  /// No description provided for @rfqQuotesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Suppliers have not responded yet'**
  String get rfqQuotesEmptyHint;

  /// No description provided for @rfqItemsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get rfqItemsSectionTitle;

  /// No description provided for @rfqMessagesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions & updates'**
  String get rfqMessagesSectionTitle;

  /// No description provided for @rfqSendMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get rfqSendMessageLabel;

  /// No description provided for @rfqSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send to vendor'**
  String get rfqSendMessage;

  /// No description provided for @rfqMessagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get rfqMessagesEmpty;

  /// No description provided for @rfqQuoteAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated total'**
  String get rfqQuoteAmountLabel;

  /// No description provided for @rfqQuoteVendorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get rfqQuoteVendorLabel;

  /// No description provided for @rfqQuoteTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get rfqQuoteTermsLabel;

  /// No description provided for @rfqLastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get rfqLastUpdatedLabel;

  /// No description provided for @rfqNeedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Need by'**
  String get rfqNeedByLabel;

  /// No description provided for @rfqItemQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get rfqItemQuantityLabel;

  /// No description provided for @rfqItemNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get rfqItemNotesLabel;

  /// No description provided for @rfqItemCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Item count'**
  String get rfqItemCountLabel;

  /// No description provided for @rfqQuoteCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Quotes received'**
  String get rfqQuoteCountLabel;

  /// No description provided for @rfqResubmit.
  ///
  /// In en, this message translates to:
  /// **'Resend for approval'**
  String get rfqResubmit;

  /// No description provided for @rfqItemFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get rfqItemFallbackLabel;

  /// No description provided for @rfqAcceptQuote.
  ///
  /// In en, this message translates to:
  /// **'Accept quote'**
  String get rfqAcceptQuote;

  /// No description provided for @rfqMessageAuthorVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor reply'**
  String get rfqMessageAuthorVendor;

  /// No description provided for @rfqMessageAuthorAdmin.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get rfqMessageAuthorAdmin;

  /// No description provided for @rfqMessageAuthorCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer message'**
  String get rfqMessageAuthorCustomer;

  /// No description provided for @rfqQuoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get rfqQuoteLabel;

  /// No description provided for @rfqQuoteDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get rfqQuoteDateLabel;

  /// No description provided for @rfqListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load RFQs.'**
  String get rfqListError;

  /// No description provided for @rfqRetry.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get rfqRetry;

  /// No description provided for @rfqEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active requests'**
  String get rfqEmptyTitle;

  /// No description provided for @rfqEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create a new request'**
  String get rfqEmptyCta;

  /// No description provided for @rfqVendorListTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer RFQs'**
  String get rfqVendorListTitle;

  /// No description provided for @rfqVendorMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply to buyer'**
  String get rfqVendorMessageLabel;

  /// No description provided for @rfqVendorSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get rfqVendorSendMessage;

  /// No description provided for @rfqVendorMessageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages for this request'**
  String get rfqVendorMessageEmpty;

  /// No description provided for @rfqVendorThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Message thread'**
  String get rfqVendorThreadTitle;

  /// No description provided for @rfqVendorQuoteDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote details'**
  String get rfqVendorQuoteDetailsTitle;

  /// No description provided for @rfqVendorQuoteRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request marked as rejected'**
  String get rfqVendorQuoteRejectedTitle;

  /// No description provided for @rfqVendorQuoteRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'You can submit a new quote if needed.'**
  String get rfqVendorQuoteRejectedBody;

  /// No description provided for @rfqVendorSubmitQuote.
  ///
  /// In en, this message translates to:
  /// **'Submit quote'**
  String get rfqVendorSubmitQuote;

  /// No description provided for @rfqVendorRejectQuote.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get rfqVendorRejectQuote;

  /// No description provided for @rfqVendorSuccessSnack.
  ///
  /// In en, this message translates to:
  /// **'Quote submitted successfully'**
  String get rfqVendorSuccessSnack;

  /// No description provided for @rfqVendorRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request rejected successfully'**
  String get rfqVendorRejectSuccess;

  /// No description provided for @rfqVendorSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit quote'**
  String get rfqVendorSubmitError;

  /// No description provided for @rfqVendorRejectError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject request'**
  String get rfqVendorRejectError;

  /// No description provided for @rfqVendorMessageErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get rfqVendorMessageErrorEmpty;

  /// No description provided for @rfqVendorMessageSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get rfqVendorMessageSendFailed;

  /// No description provided for @rfqVendorUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price (₪)'**
  String get rfqVendorUnitPriceLabel;

  /// No description provided for @rfqVendorMOQLabel.
  ///
  /// In en, this message translates to:
  /// **'MOQ'**
  String get rfqVendorMOQLabel;

  /// No description provided for @rfqVendorStepQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Step qty'**
  String get rfqVendorStepQtyLabel;

  /// No description provided for @rfqVendorLeadTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Lead time (days)'**
  String get rfqVendorLeadTimeLabel;

  /// No description provided for @rfqVendorCustomerTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer terms'**
  String get rfqVendorCustomerTermsLabel;

  /// No description provided for @rfqVendorListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load vendor RFQs.'**
  String get rfqVendorListError;

  /// No description provided for @rfqVendorEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No vendor requests pending'**
  String get rfqVendorEmptyTitle;

  /// No description provided for @rfqVendorPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price required for'**
  String get rfqVendorPriceRequired;

  /// No description provided for @rfqResubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend for approval'**
  String get rfqResubmitFailed;

  /// No description provided for @rfqMessageErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get rfqMessageErrorEmpty;

  /// No description provided for @rfqMessageSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get rfqMessageSendFailed;

  /// No description provided for @rfqAcceptQuoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept quote'**
  String get rfqAcceptQuoteFailed;

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billingTitle;

  /// No description provided for @openDebtsTitle.
  ///
  /// In en, this message translates to:
  /// **'Open debts'**
  String get openDebtsTitle;

  /// No description provided for @invoicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoicesTitle;

  /// No description provided for @aging.
  ///
  /// In en, this message translates to:
  /// **'Aging'**
  String get aging;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total due'**
  String get totalDue;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @statement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get statement;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @openDebtsEmpty.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get openDebtsEmpty;

  /// No description provided for @openDebtsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No outstanding balances at the moment.'**
  String get openDebtsEmptyHint;

  /// No description provided for @openDebtsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load balances'**
  String get openDebtsError;

  /// No description provided for @openDebtsDownloadStatement.
  ///
  /// In en, this message translates to:
  /// **'Download statement'**
  String get openDebtsDownloadStatement;

  /// No description provided for @openDebtsBucket_0_30.
  ///
  /// In en, this message translates to:
  /// **'0-30 days'**
  String get openDebtsBucket_0_30;

  /// No description provided for @openDebtsBucket_31_60.
  ///
  /// In en, this message translates to:
  /// **'31-60 days'**
  String get openDebtsBucket_31_60;

  /// No description provided for @openDebtsBucket_61_90.
  ///
  /// In en, this message translates to:
  /// **'61-90 days'**
  String get openDebtsBucket_61_90;

  /// No description provided for @openDebtsBucket_90_plus.
  ///
  /// In en, this message translates to:
  /// **'90+ days'**
  String get openDebtsBucket_90_plus;

  /// No description provided for @invoicesError.
  ///
  /// In en, this message translates to:
  /// **'Invoices unavailable'**
  String get invoicesError;

  /// No description provided for @invoicesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open invoices'**
  String get invoicesEmpty;

  /// No description provided for @invoicesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Once invoices are issued they will appear here.'**
  String get invoicesEmptyHint;

  /// No description provided for @promotionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotionsTitle;

  /// No description provided for @promotionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active promotions right now.'**
  String get promotionsEmpty;

  /// No description provided for @promotionsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load promotions.'**
  String get promotionsError;

  /// No description provided for @promotionsValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String promotionsValidUntil(Object date);

  /// No description provided for @promotionsTermsApply.
  ///
  /// In en, this message translates to:
  /// **'Terms apply {terms}'**
  String promotionsTermsApply(Object terms);

  /// No description provided for @viewProducts.
  ///
  /// In en, this message translates to:
  /// **'View products'**
  String get viewProducts;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// No description provided for @termsApply.
  ///
  /// In en, this message translates to:
  /// **'Terms apply'**
  String get termsApply;

  /// No description provided for @rfq_title.
  ///
  /// In en, this message translates to:
  /// **'Request for quote'**
  String get rfq_title;

  /// No description provided for @rfq_create.
  ///
  /// In en, this message translates to:
  /// **'Create RFQ'**
  String get rfq_create;

  /// No description provided for @rfq_add_line.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get rfq_add_line;

  /// No description provided for @rfq_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit RFQ'**
  String get rfq_submit;

  /// No description provided for @rfq_created.
  ///
  /// In en, this message translates to:
  /// **'RFQ submitted to vendors'**
  String get rfq_created;

  /// No description provided for @rfq_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t submit your RFQ. Try again.'**
  String get rfq_error;

  /// No description provided for @rfq_notes_label.
  ///
  /// In en, this message translates to:
  /// **'Notes for vendor'**
  String get rfq_notes_label;

  /// No description provided for @rfq_delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Requested delivery'**
  String get rfq_delivery_date;

  /// No description provided for @rfq_select_date.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get rfq_select_date;

  /// No description provided for @rfq_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get rfq_currency;

  /// No description provided for @rfq_product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get rfq_product;

  /// No description provided for @rfq_uom.
  ///
  /// In en, this message translates to:
  /// **'Unit of measure'**
  String get rfq_uom;

  /// No description provided for @rfq_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get rfq_quantity;

  /// No description provided for @field_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get field_required;

  /// No description provided for @rfq_qty_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive quantity'**
  String get rfq_qty_invalid;

  /// No description provided for @rfq_target_price.
  ///
  /// In en, this message translates to:
  /// **'Target unit price'**
  String get rfq_target_price;

  /// No description provided for @rfq_sku_label.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get rfq_sku_label;

  /// No description provided for @quote_title.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote_title;

  /// No description provided for @quote_valid_until.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get quote_valid_until;

  /// No description provided for @quote_empty.
  ///
  /// In en, this message translates to:
  /// **'Waiting for vendor quotes'**
  String get quote_empty;

  /// No description provided for @rfq_unit_price.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get rfq_unit_price;

  /// No description provided for @rfq_lead_time.
  ///
  /// In en, this message translates to:
  /// **'Lead time (days)'**
  String get rfq_lead_time;

  /// No description provided for @rfq_to_order.
  ///
  /// In en, this message translates to:
  /// **'Convert to order'**
  String get rfq_to_order;

  /// No description provided for @rfq_to_order_success.
  ///
  /// In en, this message translates to:
  /// **'Order created from quote'**
  String get rfq_to_order_success;

  /// No description provided for @rfq_to_order_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t convert quote'**
  String get rfq_to_order_error;

  /// No description provided for @ship_from.
  ///
  /// In en, this message translates to:
  /// **'Ship from'**
  String get ship_from;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'ETA - Estimated arrival'**
  String get eta;

  /// No description provided for @allow_backorder.
  ///
  /// In en, this message translates to:
  /// **'Allow backorder'**
  String get allow_backorder;

  /// No description provided for @warehouse_picker.
  ///
  /// In en, this message translates to:
  /// **'Warehouse selection'**
  String get warehouse_picker;

  /// No description provided for @in_stock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get in_stock;

  /// No description provided for @out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get out_of_stock;

  /// No description provided for @low_stock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get low_stock;

  /// No description provided for @backorder_available.
  ///
  /// In en, this message translates to:
  /// **'Backorder available'**
  String get backorder_available;

  /// No description provided for @shipping_method.
  ///
  /// In en, this message translates to:
  /// **'Shipping method'**
  String get shipping_method;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @asn_created.
  ///
  /// In en, this message translates to:
  /// **'ASN created'**
  String get asn_created;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @pod_received.
  ///
  /// In en, this message translates to:
  /// **'POD received'**
  String get pod_received;

  /// No description provided for @payment_terms.
  ///
  /// In en, this message translates to:
  /// **'Payment terms'**
  String get payment_terms;

  /// No description provided for @escrow_held.
  ///
  /// In en, this message translates to:
  /// **'Held in escrow'**
  String get escrow_held;

  /// No description provided for @escrow_released.
  ///
  /// In en, this message translates to:
  /// **'Released from escrow'**
  String get escrow_released;

  /// No description provided for @statement_export.
  ///
  /// In en, this message translates to:
  /// **'Export statement'**
  String get statement_export;

  /// No description provided for @payout_run.
  ///
  /// In en, this message translates to:
  /// **'Run payout'**
  String get payout_run;

  /// No description provided for @net_terms.
  ///
  /// In en, this message translates to:
  /// **'Net terms'**
  String get net_terms;

  /// No description provided for @days_until_due.
  ///
  /// In en, this message translates to:
  /// **'Days until due'**
  String get days_until_due;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @moq_minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity'**
  String get moq_minimum;

  /// No description provided for @quantity_not_multiple.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be a multiple of'**
  String get quantity_not_multiple;

  /// No description provided for @uom_adjusted_info.
  ///
  /// In en, this message translates to:
  /// **'Quantity adjusted to UOM'**
  String get uom_adjusted_info;

  /// No description provided for @hidden_for_your_account.
  ///
  /// In en, this message translates to:
  /// **'Hidden for your account'**
  String get hidden_for_your_account;

  /// No description provided for @private_catalog_only.
  ///
  /// In en, this message translates to:
  /// **'Private catalog only'**
  String get private_catalog_only;

  /// No description provided for @adminDashboardUsersCta.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get adminDashboardUsersCta;

  /// No description provided for @adminDashboardUsersDescription.
  ///
  /// In en, this message translates to:
  /// **'Invite admins and manage access controls'**
  String get adminDashboardUsersDescription;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite, deactivate, and monitor team access across the marketplace.'**
  String get adminUsersSubtitle;

  /// No description provided for @adminUsersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get adminUsersSearchHint;

  /// No description provided for @adminUsersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminUsersFilterAll;

  /// No description provided for @adminUsersFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminUsersFilterActive;

  /// No description provided for @adminUsersFilterDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get adminUsersFilterDisabled;

  /// No description provided for @adminUsersInviteCta.
  ///
  /// In en, this message translates to:
  /// **'Invite user'**
  String get adminUsersInviteCta;

  /// No description provided for @adminUsersInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite new user'**
  String get adminUsersInviteTitle;

  /// No description provided for @adminUsersInviteEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminUsersInviteEmailLabel;

  /// No description provided for @adminUsersInviteFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name (optional)'**
  String get adminUsersInviteFullNameLabel;

  /// No description provided for @adminUsersInviteRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminUsersInviteRoleLabel;

  /// No description provided for @adminUsersInviteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminUsersInviteCancel;

  /// No description provided for @adminUsersInviteSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get adminUsersInviteSubmit;

  /// No description provided for @adminUsersInviteEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid corporate email'**
  String get adminUsersInviteEmailError;

  /// No description provided for @adminUsersInviteRoleError.
  ///
  /// In en, this message translates to:
  /// **'Select a role'**
  String get adminUsersInviteRoleError;

  /// No description provided for @adminUsersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get adminUsersEmptyTitle;

  /// No description provided for @adminUsersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the invite button to add your first teammate.'**
  String get adminUsersEmptySubtitle;

  /// No description provided for @adminUsersDeactivateCta.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get adminUsersDeactivateCta;

  /// No description provided for @adminUsersActivateCta.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get adminUsersActivateCta;

  /// No description provided for @adminUsersStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get adminUsersStatusDisabled;

  /// No description provided for @adminUsersStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminUsersStatusActive;

  /// No description provided for @adminUsersStatusHeader.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminUsersStatusHeader;

  /// No description provided for @adminUsersActionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminUsersActionsHeader;

  /// No description provided for @adminUsersIdentityHeader.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get adminUsersIdentityHeader;

  /// No description provided for @adminUsersRoleHeader.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminUsersRoleHeader;

  /// No description provided for @adminUsersLastSignIn.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in'**
  String get adminUsersLastSignIn;

  /// No description provided for @adminUsersInvitedAt.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get adminUsersInvitedAt;

  /// No description provided for @adminUsersDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable user'**
  String get adminUsersDeactivateTitle;

  /// No description provided for @adminUsersDeactivateMessage.
  ///
  /// In en, this message translates to:
  /// **'The user will lose access immediately. You can reactivate later.'**
  String get adminUsersDeactivateMessage;

  /// No description provided for @adminUsersDeactivateReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get adminUsersDeactivateReasonHint;

  /// No description provided for @adminUsersDeactivateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disable user'**
  String get adminUsersDeactivateConfirm;

  /// No description provided for @adminUsersActivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate user'**
  String get adminUsersActivateTitle;

  /// No description provided for @adminUsersActivateMessage.
  ///
  /// In en, this message translates to:
  /// **'Restore access for this user?'**
  String get adminUsersActivateMessage;

  /// No description provided for @adminUsersActivateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Activate user'**
  String get adminUsersActivateConfirm;

  /// No description provided for @adminUsersQueuedSnack.
  ///
  /// In en, this message translates to:
  /// **'Queued offline. Will sync when back online.'**
  String get adminUsersQueuedSnack;

  /// No description provided for @adminUsersInviteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {email}'**
  String adminUsersInviteSuccess(Object email);

  /// No description provided for @adminUsersDeactivateSuccess.
  ///
  /// In en, this message translates to:
  /// **'{email} disabled'**
  String adminUsersDeactivateSuccess(Object email);

  /// No description provided for @adminUsersActivateSuccess.
  ///
  /// In en, this message translates to:
  /// **'{email} reactivated'**
  String adminUsersActivateSuccess(Object email);

  /// No description provided for @adminUsersError.
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {message}'**
  String adminUsersError(Object message);

  /// No description provided for @adminUsersRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminUsersRefresh;

  /// No description provided for @adminUsersNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get adminUsersNever;

  /// No description provided for @adminUserRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Platform admin'**
  String get adminUserRoleAdmin;

  /// No description provided for @adminUserRoleVendorAdmin.
  ///
  /// In en, this message translates to:
  /// **'Vendor admin'**
  String get adminUserRoleVendorAdmin;

  /// No description provided for @adminUserRoleVendorUser.
  ///
  /// In en, this message translates to:
  /// **'Vendor user'**
  String get adminUserRoleVendorUser;

  /// No description provided for @adminUserRoleCustomerAdmin.
  ///
  /// In en, this message translates to:
  /// **'Customer admin'**
  String get adminUserRoleCustomerAdmin;

  /// No description provided for @adminUserRoleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get adminUserRoleBuyer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
