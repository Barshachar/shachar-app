import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
      onScreenshot: (name, bytes, [args]) async {
        final targetDir = Platform.environment['QA_SCREENSHOT_DIR'] ??
            'build/integration_test_screenshots';
        final directory = Directory(targetDir);
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final file = File('${directory.path}/$name.png');
        file.writeAsBytesSync(bytes);
        return true;
      },
    );
