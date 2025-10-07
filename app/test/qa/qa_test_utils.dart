import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
  Duration step = const Duration(milliseconds: 50),
}) async {
  final Stopwatch sw = Stopwatch()..start();
  int iterations = 0;
  while (sw.elapsed < timeout) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    iterations++;
    if (iterations % 20 == 0) {
      debugPrint(
        '[QA] pumpUntilFound waiting for $finder after ${sw.elapsed.inMilliseconds}ms',
      );
    }
  }
  final String message =
      '[QA] pumpUntilFound timeout after ${timeout.inSeconds}s waiting for $finder';
  debugPrint(message);
  throw TestFailure(message);
}

void setDeviceSize(
  WidgetTester tester, {
  double width = 375,
  double height = 812,
}) {
  final view = tester.view;
  final double devicePixelRatio = view.devicePixelRatio;
  view.devicePixelRatio = devicePixelRatio;
  view.physicalSize = Size(width, height) * devicePixelRatio;
  addTearDown(view.resetPhysicalSize);
  addTearDown(view.resetDevicePixelRatio);
}
