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
  String get navUsb => 'Detected Devices';

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
  String get actionClose => 'Close';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionCreate => 'Create';

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
  String get updateChecking => 'Checking for updates...';

  @override
  String get updateUpToDate => 'You are on the latest version';

  @override
  String updateAvailableShort(String version) {
    return 'New $version';
  }

  @override
  String get updateAction => 'Update';

  @override
  String get updateCheckAction => 'Check update';

  @override
  String get updateCheckFailed => 'Could not check for updates';

  @override
  String get updateOpenFailed => 'Could not open the update.';

  @override
  String get shortcutsRunning => 'Running...';

  @override
  String get shortcutsCompleted => 'Completed';

  @override
  String get shortcutsFailed => 'Failed';

  @override
  String get shortcutsNoOutput => '(no output)';

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
  String get devicesShortcutHint =>
      'Select a device first, or tap a shortcut to choose';

  @override
  String get devicesNoConnected => 'No connected devices';

  @override
  String get devicesSelectDevice => 'Select a device';

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
  String usbDeviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devices',
      one: '1 device',
    );
    return '$_temp0';
  }

  @override
  String get usbRefresh => 'Updates every 5s';

  @override
  String get usbSectionUsb => 'USB';

  @override
  String get usbSectionWifi => 'WiFi / TCP-IP detected';

  @override
  String get usbWifiSubtitle => 'Active ADB connections from outside the app';

  @override
  String get usbUnknownDevice => 'Unknown device';

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
  String get shortcutsNew => 'New action';

  @override
  String get shortcutsSectionGlobal => 'Global';

  @override
  String get shortcutsSectionDevice => 'Per device';

  @override
  String get shortcutsDeviceHint =>
      'Use %DEVICE% in the command to replace it with the active device serial.';

  @override
  String get shortcutsDeleteTitle => 'Delete quick action';

  @override
  String shortcutsDeleteConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get shortcutsCopyCmd => 'Copy command';

  @override
  String get shortcutsCreate => 'Create quick action';

  @override
  String get shortcutsEmptyTitle => 'No quick actions configured';

  @override
  String get shortcutsEmptySubtitle =>
      'Create fast ADB commands for your devices';

  @override
  String get shortcutsModalCreateTitle => 'New quick action';

  @override
  String get shortcutsModalEditTitle => 'Edit quick action';

  @override
  String get shortcutsModalNameLabel => 'Name';

  @override
  String get shortcutsModalNameHint => 'e.g. Open Shell';

  @override
  String get shortcutsModalNameRequired => 'Name is required';

  @override
  String get shortcutsModalCmdLabel => 'Command';

  @override
  String get shortcutsModalCmdRequired => 'Command is required';

  @override
  String get shortcutsModalCmdHint =>
      'Use %DEVICE% for the active device serial';

  @override
  String get shortcutsModalIconLabel => 'Icon';

  @override
  String get shortcutsModalGlobalTitle => 'Global';

  @override
  String get shortcutsModalGlobalSubtitle =>
      'Appears in the action bar of all devices';

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
  String get settingsAutoDetect => 'Auto-detect';

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
  String get settingsLangAuto => 'System';

  @override
  String get settingsLangAutoSub => 'Follows OS language';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnSub => 'English';

  @override
  String get settingsLangEs => 'Español';

  @override
  String get settingsLangEsSub => 'Spanish';

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
