class AppUpdate {
  final String version;
  final String tagName;
  final String releaseUrl;
  final String? downloadUrl;

  const AppUpdate({
    required this.version,
    required this.tagName,
    required this.releaseUrl,
    this.downloadUrl,
  });
}
