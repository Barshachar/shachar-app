import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:ashachar_marketplace/main.dart' as entry;
import 'package:ashachar_marketplace/src/app/app_bootstrap.dart';
import 'package:ashachar_marketplace/src/router/app_router.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_keys.dart';

// Admin/vendor journeys are heavy; only run when opting in.
const bool kRunAdminVendor =
    bool.fromEnvironment('RUN_ADMIN_VENDOR', defaultValue: false);

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
  throw TestFailure('Finder $finder not found within $timeout');
}

Future<SnackBar> _waitForSnackBar(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  await _pumpUntilFound(
    tester,
    find.byType(SnackBar),
    timeout: timeout,
  );
  return tester.widget<SnackBar>(find.byType(SnackBar).first);
}

Finder _localizedText(List<String> candidates) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        candidates.contains(widget.data),
  );
}

Finder _filledButtonWithIcon(IconData icon) {
  return find.widgetWithIcon(FilledButton, icon);
}

Finder _outlinedButtonWithIcon(IconData icon) {
  return find.widgetWithIcon(OutlinedButton, icon);
}

Future<void> _signInAs(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.runAsync(() async {
    final auth = Supabase.instance.client.auth;
    await auth.signOut();
    await auth.signInWithPassword(email: email, password: password);
  });
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _goToRoute(
  WidgetTester tester,
  ProviderContainer container,
  String route,
) async {
  await tester.runAsync(() async {
    final GoRouter router = container.read(appRouterProvider);
    router.go(route);
  });
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _pumpApp(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const entry.MarketplaceApp(),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

class _FakeUrlLauncher extends UrlLauncherPlatform {
  String? launchedUrl;
  bool closed = false;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    launchedUrl = url;
    return true;
  }

  @override
  Future<void> closeWebView() async {
    closed = true;
  }
}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this.result);

  final FilePickerResult? result;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return result;
  }

  @override
  Future<List<String>?> pickFileAndDirectoryPaths({
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool?> clearTemporaryFiles() async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    Uint8List? bytes,
    bool lockParentWindow = false,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    throw UnimplementedError();
  }
}

const String _adminEmail = 'admin@demo.local';
const String _vendorEmail = 'vendor1@demo.local';
const String _demoPassword = 'Demo123!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: Test Order flow submits and navigates to detail',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await AppBootstrap(container: container).initialize();

    // מפעיל את האפליקציה
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const entry.MarketplaceApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // נווט למסך הקטלוג כדי להפעיל את כפתור Test Order
    await _goToRoute(tester, container, '/catalog');

    // לוחץ על כפתור Test Order (ב־Catalog)
    final testOrderFinder = find.text('Test Order');
    await _pumpUntilFound(tester, testOrderFinder);
    await tester.tap(testOrderFinder);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // מחפש Snackbar "Order submitted: <uuid>"
    final snack = find.byType(SnackBar);
    // אם ה-Snackbar כבר נסגר, נחפש טקסט המכיל "Order submitted:" במסך
    final submittedTxt = find.textContaining('Order submitted:');
    expect(
        snack.evaluate().isNotEmpty || submittedTxt.evaluate().isNotEmpty, true,
        reason:
            'Expected a Snackbar or text containing "Order submitted:" after tapping Test Order');

    // וידוא שמסך Order Detail נטען (יש כותרת "Lines" ו-"Shipments")
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await _pumpUntilFound(
      tester,
      _localizedText(const ['Lines', 'שורות הזמנה']),
    );
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, -400),
      1000,
    );
    for (int i = 0; i < 8; i++) {
      if (_localizedText(const ['Shipments', 'משלוחים'])
          .evaluate()
          .isNotEmpty) {
        break;
      }
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await _pumpUntilFound(
      tester,
      _localizedText(const ['Shipments', 'משלוחים']),
    );

    await tester.runAsync(() async {
      final SupabaseClient client = Supabase.instance.client;
      final dynamic latestOrder = await client
          .from('orders')
          .select('id')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final String orderId = latestOrder['id'] as String;
      final List<dynamic> shipments =
          await client.from('shipments').select('id').eq('order_id', orderId);
      if (shipments.isEmpty) {
        throw TestFailure('Expected at least one shipment row to be visible');
      }
    });
  });

  testWidgets('Admin: Split order workflow surfaces confirmation',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await AppBootstrap(container: container).initialize();
    await _signInAs(
      tester,
      email: _adminEmail,
      password: _demoPassword,
    );
    await _pumpApp(tester, container);
    await _goToRoute(tester, container, '/admin/orders');

    await _pumpUntilFound(tester, find.byType(DataTable));

    final Finder splitButtonFinder = _filledButtonWithIcon(Icons.alt_route);
    await _pumpUntilFound(tester, splitButtonFinder);
    await tester.ensureVisible(splitButtonFinder.first);

    await tester.tap(splitButtonFinder.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.descendant(
        of: splitButtonFinder,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );

    final SnackBar snackBar = await _waitForSnackBar(tester);
    final Widget snackContent = snackBar.content;
    if (snackContent is Text) {
      final String resolved = snackContent.data ??
          snackContent.textSpan?.toPlainText(includePlaceholders: false) ??
          '';
      expect(resolved, contains('Order split'));
    }

    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(
      find.descendant(
        of: _filledButtonWithIcon(Icons.alt_route),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsNothing,
    );
  }, skip: !kRunAdminVendor);

  testWidgets('Admin: Report export surfaces signed URL', (tester) async {
    final container = ProviderContainer();
    final UrlLauncherPlatform previousLauncher = UrlLauncherPlatform.instance;
    final _FakeUrlLauncher fakeLauncher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = fakeLauncher;
    addTearDown(() {
      UrlLauncherPlatform.instance = previousLauncher;
    });
    addTearDown(container.dispose);

    await AppBootstrap(container: container).initialize();
    await _signInAs(
      tester,
      email: _adminEmail,
      password: _demoPassword,
    );
    await _pumpApp(tester, container);
    await _goToRoute(tester, container, '/admin/reports');

    await _pumpUntilFound(tester, find.byType(ListView));

    final Finder generateCsvButton = _filledButtonWithIcon(Icons.table_view);
    await _pumpUntilFound(tester, generateCsvButton);
    await tester.ensureVisible(generateCsvButton.first);

    await tester.tap(generateCsvButton.first);
    await tester.pump();

    final SnackBar snackBar = await _waitForSnackBar(tester);
    final Widget snackContent = snackBar.content;
    if (snackContent is Text) {
      final String resolved = snackContent.data ??
          snackContent.textSpan?.toPlainText(includePlaceholders: false) ??
          '';
      final bool matchesSuccess =
          resolved.contains('Report ready') || resolved.contains('הדוח מוכן');
      expect(
        matchesSuccess,
        isTrue,
        reason: 'Unexpected success message: "$resolved"',
      );
    }

    expect(fakeLauncher.launchedUrl, isNotNull);

    await tester.pumpAndSettle(const Duration(seconds: 6));
  }, skip: !kRunAdminVendor);

  testWidgets('Admin: Price import surfaces processed rows', (tester) async {
    final container = ProviderContainer();
    FilePicker? previousPicker;
    bool hadPreviousPicker = true;
    try {
      previousPicker = FilePicker.platform;
    } catch (_) {
      hadPreviousPicker = false;
    }

    final String csvContent =
        'variant_id,unit_price\n70000000-0000-0000-0000-000000000000,35.50\n';
    final Uint8List csvBytes = Uint8List.fromList(utf8.encode(csvContent));
    final FilePickerResult fakeResult = FilePickerResult([
      PlatformFile(
        name: 'import.csv',
        size: csvBytes.length,
        bytes: csvBytes,
      ),
    ]);
    final _FakeFilePicker fakePicker = _FakeFilePicker(fakeResult);
    FilePicker.platform = fakePicker;
    addTearDown(() {
      if (hadPreviousPicker && previousPicker != null) {
        FilePicker.platform = previousPicker;
      }
    });
    addTearDown(container.dispose);

    await AppBootstrap(container: container).initialize();
    await _signInAs(
      tester,
      email: _adminEmail,
      password: _demoPassword,
    );
    await _pumpApp(tester, container);
    await _goToRoute(tester, container, '/admin/price-lists');

    await _pumpUntilFound(tester, find.byType(DropdownButtonFormField<String>));

    Finder chooseFileButton = _outlinedButtonWithIcon(Icons.upload_file);
    if (chooseFileButton.evaluate().isEmpty) {
      chooseFileButton = _outlinedButtonWithIcon(Icons.upload_file_outlined);
    }
    await _pumpUntilFound(tester, chooseFileButton);
    await tester.ensureVisible(chooseFileButton.first);
    await tester.tap(chooseFileButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final Finder importButton = _filledButtonWithIcon(Icons.playlist_add_check);
    await _pumpUntilFound(tester, importButton);
    await tester.ensureVisible(importButton.first);
    await tester.tap(importButton.first);
    await tester.pump();

    await tester.pumpAndSettle(const Duration(seconds: 6));

    await _pumpUntilFound(tester, find.byIcon(Icons.check_circle));
    expect(find.textContaining('Imported '), findsWidgets);
    expect(find.textContaining('Imported 0 price rows.'), findsNothing);
  }, skip: !kRunAdminVendor);

  testWidgets('Vendor: Shipment update dialog saves and refreshes',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await AppBootstrap(container: container).initialize();
    await _signInAs(
      tester,
      email: _vendorEmail,
      password: _demoPassword,
    );
    await _pumpApp(tester, container);
    await _goToRoute(tester, container, '/vendor');

    await _pumpUntilFound(tester, find.byType(TabBar));
    final Finder tabs = find.byType(Tab);
    expect(tabs, findsAtLeastNWidgets(2));
    await tester.tap(tabs.at(1));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // מצא כפתור עריכה במספר אסטרטגיות (Key → IconButton → TextButton → Icon → טקסט)
    Finder edit = find.byKey(VendorKeys.shipmentEditButton);
    if (edit.evaluate().isEmpty) {
      edit = find.widgetWithIcon(IconButton, Icons.edit);
    }
    if (edit.evaluate().isEmpty) {
      edit = find.widgetWithIcon(TextButton, Icons.edit);
    }
    if (edit.evaluate().isEmpty) {
      edit = find.byIcon(Icons.edit);
    }
    if (edit.evaluate().isEmpty) {
      edit = find.textContaining(RegExp(r'Edit|Update|עריכה|עדכון'));
    }

    expect(edit, findsOneWidget,
        reason: 'Could not locate shipment edit action');
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();

    // בחר סטטוס: קודם לפי Key, ואם אין — ע"י טיפוס
    final Finder statusKeyFinder = find.byKey(VendorKeys.shipmentStatusField);
    final Finder statusField = statusKeyFinder.evaluate().isNotEmpty
        ? statusKeyFinder
        : find.byType(DropdownButtonFormField<String>);
    await tester.tap(statusField);
    await tester.pumpAndSettle();

    // תמיכה גם בעברית ('Ready' / 'מוכן')
    Finder readyItem = find.text('Ready');
    if (readyItem.evaluate().isEmpty) {
      readyItem = find.text('מוכן');
    }
    await tester.tap(readyItem.last);
    await tester.pumpAndSettle();

    // קוד מעקב: לפי Key ואם אין — השדה הטקסטואלי הראשון בדיאלוג
    final Finder trackingKeyFinder =
        find.byKey(VendorKeys.shipmentTrackingField);
    final Finder trackingField = trackingKeyFinder.evaluate().isNotEmpty
        ? trackingKeyFinder
        : find.byType(TextFormField).first;
    await tester.enterText(trackingField, 'TEST-TRACK-123');

    // Save: לפי Key ואם אין — לפי טקסט
    final Finder saveKeyFinder =
        find.byKey(VendorKeys.shipmentUpdateSaveButton);
    final Finder save = saveKeyFinder.evaluate().isNotEmpty
        ? saveKeyFinder
        : find.widgetWithText(TextButton, 'Save');
    await tester.tap(save);
    await tester.pumpAndSettle();

    // אימות: או שסנאקבר הופיע, או שהטקסט החדש מופיע בשורה
    final bool savedSnack = find.byType(SnackBar).evaluate().isNotEmpty;
    final bool trackingVisible =
        find.textContaining('TEST-TRACK-123').evaluate().isNotEmpty;
    expect(savedSnack || trackingVisible, true,
        reason: 'Expected success feedback or updated tracking text');

    // עדיין אפשר לערוך אחרי הרענון
    expect(
      find.byKey(VendorKeys.shipmentEditButton).evaluate().isNotEmpty ||
          find.byIcon(Icons.edit).evaluate().isNotEmpty,
      true,
    );
  });
}
