import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildHost(Widget child) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AColors.background,
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AButton clips long label with ellipsis on compact width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(240, 200));
    await tester.pumpWidget(
      _buildHost(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: AButton.primary(
            label: 'הוספת פריטים מאוד ארוכים שלא צריכים להישבר',
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Text textWidget = tester.widget<Text>(find.textContaining('פריטים'));
    expect(textWidget.maxLines, 1);
    expect(textWidget.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AStatusChip keeps size and typography on small devices',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    await tester.pumpWidget(
      _buildHost(
        const AStatusChip(
          statusCode: 'pending',
          label: 'ממתין לאישור עם טקסט ארוך',
        ),
      ),
    );
    await tester.pump();

    final RenderBox chipBox = tester.renderObject(find.byType(AStatusChip));
    expect(chipBox.size.height, greaterThanOrEqualTo(24));
    expect(tester.takeException(), isNull);
  });
}
