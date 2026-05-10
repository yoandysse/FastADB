// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDevices => 'My Devices';

  @override
  String get navUsb => 'USB Detected';

  @override
  String get navShortcuts => 'Quick Actions';

  @override
  String get navSettings => 'Settings';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusReconnecting => 'Reconnecting...';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusError => 'No network';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionConnect => 'Connect';

  @override
  String get actionDisconnect => 'Disconnect';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionVerify => 'Verify';

  @override
  String get actionBrowse => 'Browse...';

  @override
  String get devicesTitle => 'My Devices';

  @override
  String devicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String get devicesNewDevice => 'New Device';

  @override
  String get devicesSectionWifi => 'WiFi / TCP-IP';

  @override
  String get devicesSectionUsb => 'USB / TCP-IP';

  @override
  String get devicesEmptyTitle => 'No saved devices';

  @override
  String get devicesEmptySubtitle => 'Add a WiFi device to get started';

  @override
  String get devicesAddDevice => 'Add Device';

  @override
  String get devicesGlobalShortcuts => 'Global Quick Actions';

  @override
  String get devicesDeleteTitle => 'Delete device';

  @override
  String devicesDeleteConfirm(String alias) {
    return 'Delete \"$alias\"?';
  }

  @override
  String devicesTimeAgo(String time) {
    return '$time ago';
  }

  @override
  String get usbTitle => 'Detected Devices';

  @override
  String get usbRefresh => 'Updates every 5s';

  @override
  String get usbSectionUsb => 'USB';

  @override
  String get usbSectionWifi => 'WiFi / TCP-IP detected';

  @override
  String get usbWifiSubtitle => 'Active ADB connections from outside the app';

  @override
  String get usbUnauthorized => 'Unauthorized';

  @override
  String get usbActivateWifi => 'Enable WiFi ADB';

  @override
  String get usbSaveDevice => 'Save device';

  @override
  String get usbAlreadySaved => 'Already saved';

  @override
  String get usbEmptyTitle => 'No devices detected';

  @override
  String get usbEmptySubtitle => 'Connect a USB device or enable ADB WiFi';

  @override
  String get usbEmptyHint => 'Auto-detects every 5 seconds';

  @override
  String get usbAdbNotConfigured => 'Configure ADB path in Settings first.';

  @override
  String get usbActivateWifiTitle => 'Enable WiFi ADB';

  @override
  String usbActivateWifiDevice(String name) {
    return 'Device: $name';
  }

  @override
  String get usbActivateWifiIpLabel => 'Device IP address';

  @override
  String get usbActivateWifiConfirm => 'Connect & Save';

  @override
  String get usbSaveWifiTitle => 'Save WiFi Device';

  @override
  String get usbSaveWifiNameLabel => 'Device name';

  @override
  String get shortcutsTitle => 'Quick Actions';

  @override
  String get shortcutsEmptyTitle => 'No quick actions configured';

  @override
  String get shortcutsEmptySubtitle =>
      'Create fast ADB commands for your devices';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsToolsSection => 'External Tools';

  @override
  String get settingsToolsSubtitle =>
      'Configure the paths for ADB and scrcpy installed on your system.';

  @override
  String get settingsAdbName => 'Android Debug Bridge (ADB)';

  @override
  String get settingsAdbSubtitle => 'Android debugging tool';

  @override
  String get settingsScrcpyName => 'scrcpy';

  @override
  String get settingsScrcpySubtitle => 'Android screen mirror';

  @override
  String get settingsWindowsNote =>
      'Windows: visit github.com/Genymobile/scrcpy to install scrcpy. The app does not include scrcpy internally.';

  @override
  String settingsStatusDetected(String version) {
    return '● Detected · $version';
  }

  @override
  String get settingsStatusNotConfigured => '● Not configured';

  @override
  String get settingsStatusUnverified => '● Unverified';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsAutoReconnectTitle => 'Auto-reconnect on startup';

  @override
  String get settingsAutoReconnectSubtitle =>
      'Try to reconnect WiFi devices when the app starts';

  @override
  String get settingsStartMinimizedTitle => 'Start minimized';

  @override
  String get settingsStartMinimizedSubtitle =>
      'App starts in background without a visible window';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeSystemSub => 'Follow OS mode';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeDarkSub => 'Always dark mode';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeLightSub => 'Always light mode';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLangAuto => 'Automatic';

  @override
  String get settingsLangAutoSub => 'Follow system language';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnSub => 'Always in English';

  @override
  String get settingsLangEs => 'Español';

  @override
  String get settingsLangEsSub => 'Siempre en español';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDescription =>
      'ADB connection manager for Android — Windows, macOS and Linux';

  @override
  String get modalAddTitle => 'Add Device';

  @override
  String get modalEditTitle => 'Edit Device';

  @override
  String get modalSubtitle => 'Configure a new ADB connection';

  @override
  String get modalConnectionType => 'Connection type';

  @override
  String get modalWifiTitle => 'WiFi / TCP-IP';

  @override
  String get modalWifiSubtitle => 'Wireless connection via IP and port';

  @override
  String get modalUsbTitle => 'USB';

  @override
  String get modalUsbSubtitle => 'Automatic device detection';

  @override
  String get modalAliasLabel => 'Device alias';

  @override
  String get modalAliasHint => 'e.g. Pixel 7 — Office';

  @override
  String get modalIpPortLabel => 'IP Address and Port';

  @override
  String get modalAutoReconnectTitle => 'Auto-reconnect';

  @override
  String get modalAutoReconnectSubtitle => 'Try to reconnect on app start';

  @override
  String get modalShortcutsLabel => 'Quick actions for this device';

  @override
  String get modalSaveDevice => 'Save Device';
}
