import 'dart:io';

const _pkg = 'package:mimo_flutter_sdk_community/src/';

/// Denied cross-module imports.
/// Key = source module, Value = set of modules it must NOT import.
const _denied = {
  'errors': {'client', 'services', 'models', 'transport', 'utils'},
  'transport': {'client', 'services', 'models', 'utils', 'errors'},
  'utils': {'client', 'services', 'models', 'transport'},
  'models': {'client', 'services', 'transport', 'errors'},
};

final _importRe = RegExp(r"import\s+'package:mimo_flutter_sdk_community/src/([^']+)'");

void main() {
  final srcDir = Directory('lib/src');
  var violations = 0;

  for (final file in srcDir.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;

    final relative = file.path.replaceFirst(RegExp(r'.*lib/src/'), '');
    final module = relative.split('/').first;

    final denied = _denied[module];
    if (denied == null || denied.isEmpty) continue;

    for (final line in file.readAsLinesSync()) {
      final match = _importRe.firstMatch(line);
      if (match == null) continue;

      final targetModule = match.group(1)!.split('/').first;
      if (denied.contains(targetModule)) {
        violations++;
        stderr.writeln(
          'VIOLATION: $relative imports $targetModule/ (denied for $module/)',
        );
      }
    }
  }

  if (violations > 0) {
    stderr.writeln('\n$violations architecture violation(s) found.');
    exit(violations > 255 ? 255 : violations);
  }

  print('Architecture check passed. 0 violations.');
}
