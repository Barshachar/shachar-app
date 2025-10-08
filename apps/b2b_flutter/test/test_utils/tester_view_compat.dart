import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension TesterViewCompat on WidgetTester {
  Future<void> setSurfaceSize(Size size) async {
    view.physicalSize = size;
    addTearDown(view.resetPhysicalSize);
    if (binding.rootElement != null) {
      await pumpAndSettle();
    }
  }

  Future<void> setDevicePixelRatio(double dpr) async {
    view.devicePixelRatio = dpr;
    addTearDown(view.resetDevicePixelRatio);
    if (binding.rootElement != null) {
      await pump();
    }
  }

  Size getSurfaceSize() => view.physicalSize;
}
