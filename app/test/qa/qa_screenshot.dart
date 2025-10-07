import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

Future<void> savePngFromFinder(
  WidgetTester tester, {
  required Finder target,
  required String path,
  double pixelRatio = 3.0,
}) async {
  final element = tester.element(target);
  final RenderRepaintBoundary? boundary =
      element.renderObject as RenderRepaintBoundary?;
  expect(boundary, isNotNull, reason: 'Target must be within RepaintBoundary');

  final ui.Image image = await boundary!.toImage(pixelRatio: pixelRatio);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  final List<int> bytes = byteData!.buffer.asUint8List();

  final File latestFile = File(path)..createSync(recursive: true);
  final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(
    DateTime.now().toUtc(),
  );
  final String timestampedPath = path.endsWith('.png')
      ? path.replaceFirst(RegExp(r'\.png$'), '_$timestamp.png')
      : '${path}_$timestamp.png';
  final File timestampedFile = File(timestampedPath);

  await timestampedFile.writeAsBytes(bytes, flush: true);
  await latestFile.writeAsBytes(bytes, flush: true);
  image.dispose();

  debugPrint(
    '[QA] Saved screenshot to ${timestampedFile.path} (latest: ${latestFile.path})',
  );
}
