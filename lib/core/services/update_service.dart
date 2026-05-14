import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../config/app_info.dart';
import '../models/app_update.dart';

class UpdateService {
  static const _releasesUrl =
      'https://api.github.com/repos/yoandysse/FastADB/releases';

  final HttpClient _client;

  UpdateService({HttpClient? client}) : _client = client ?? HttpClient();

  Future<AppUpdate?> checkForUpdate() async {
    final request = await _client
        .getUrl(Uri.parse(_releasesUrl))
        .timeout(const Duration(seconds: 8));
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set(HttpHeaders.userAgentHeader, 'FastADB Update Checker');

    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    final body = await response.transform(utf8.decoder).join();
    final releases = jsonDecode(body);
    if (releases is! List) return null;

    for (final item in releases) {
      if (item is! Map<String, dynamic>) continue;
      if (item['draft'] == true) continue;

      final tagName = item['tag_name']?.toString();
      final releaseUrl = item['html_url']?.toString();
      if (tagName == null || releaseUrl == null) continue;

      final version = normalizeVersion(tagName);
      if (compareVersions(version, AppInfo.version) <= 0) continue;

      return AppUpdate(
        version: version,
        tagName: tagName,
        releaseUrl: releaseUrl,
        downloadUrl: _platformAssetUrl(item['assets']),
      );
    }

    return null;
  }

  Future<bool> openUpdate(AppUpdate update) async {
    final url = update.downloadUrl ?? update.releaseUrl;
    try {
      if (Platform.isMacOS) {
        await Process.start('open', [url], mode: ProcessStartMode.detached);
      } else if (Platform.isWindows) {
        await Process.start('cmd', [
          '/c',
          'start',
          '',
          url,
        ], mode: ProcessStartMode.detached);
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', [url], mode: ProcessStartMode.detached);
      } else {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  String? _platformAssetUrl(Object? assets) {
    if (assets is! List) return null;

    final platformToken = switch (Platform.operatingSystem) {
      'macos' => 'macos',
      'windows' => 'windows',
      'linux' => 'linux',
      _ => '',
    };
    if (platformToken.isEmpty) return null;

    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final name = asset['name']?.toString().toLowerCase() ?? '';
      if (!name.contains(platformToken)) continue;
      return asset['browser_download_url']?.toString();
    }

    return null;
  }

  static String normalizeVersion(String value) {
    return value.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first;
  }

  static int compareVersions(String left, String right) {
    final a = _ParsedVersion.parse(left);
    final b = _ParsedVersion.parse(right);
    return a.compareTo(b);
  }
}

class _ParsedVersion implements Comparable<_ParsedVersion> {
  final int major;
  final int minor;
  final int patch;
  final String? prereleaseLabel;
  final int? prereleaseNumber;

  const _ParsedVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.prereleaseLabel,
    this.prereleaseNumber,
  });

  factory _ParsedVersion.parse(String value) {
    final normalized = UpdateService.normalizeVersion(value);
    final segments = normalized.split('-');
    final core = segments.first.split('.');
    final prerelease = segments.length > 1 ? segments.sublist(1).join('-') : '';
    final prereleaseParts = prerelease.split('.');

    return _ParsedVersion(
      major: _parseInt(core, 0),
      minor: _parseInt(core, 1),
      patch: _parseInt(core, 2),
      prereleaseLabel: prerelease.isEmpty ? null : prereleaseParts.first,
      prereleaseNumber: prereleaseParts.length > 1
          ? int.tryParse(prereleaseParts[1])
          : null,
    );
  }

  static int _parseInt(List<String> values, int index) {
    if (index >= values.length) return 0;
    return int.tryParse(values[index]) ?? 0;
  }

  @override
  int compareTo(_ParsedVersion other) {
    final majorCompare = major.compareTo(other.major);
    if (majorCompare != 0) return majorCompare;

    final minorCompare = minor.compareTo(other.minor);
    if (minorCompare != 0) return minorCompare;

    final patchCompare = patch.compareTo(other.patch);
    if (patchCompare != 0) return patchCompare;

    if (prereleaseLabel == null && other.prereleaseLabel != null) return 1;
    if (prereleaseLabel != null && other.prereleaseLabel == null) return -1;
    if (prereleaseLabel == null && other.prereleaseLabel == null) return 0;

    final labelCompare = prereleaseLabel!.compareTo(other.prereleaseLabel!);
    if (labelCompare != 0) return labelCompare;

    return (prereleaseNumber ?? 0).compareTo(other.prereleaseNumber ?? 0);
  }
}
