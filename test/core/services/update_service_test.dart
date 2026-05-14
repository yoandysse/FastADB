import 'package:fastadb/core/services/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateService', () {
    test('normalizes release tags', () {
      expect(UpdateService.normalizeVersion('v0.1.0-beta.6+6'), '0.1.0-beta.6');
      expect(UpdateService.normalizeVersion('0.2.0'), '0.2.0');
    });

    test('compares beta versions numerically', () {
      expect(
        UpdateService.compareVersions('0.1.0-beta.6', '0.1.0-beta.5'),
        greaterThan(0),
      );
      expect(
        UpdateService.compareVersions('0.1.0-beta.5', '0.1.0-beta.6'),
        lessThan(0),
      );
    });

    test('treats stable release as newer than prerelease', () {
      expect(
        UpdateService.compareVersions('0.1.0', '0.1.0-beta.9'),
        greaterThan(0),
      );
    });
  });
}
