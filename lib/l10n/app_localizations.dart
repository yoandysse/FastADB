import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @navDevices.
  ///
  /// In en, this message translates to:
  /// **'My Devices'**
  String get navDevices;

  /// No description provided for @navUsb.
  ///
  /// In en, this message translates to:
  /// **'USB Detected'**
  String get navUsb;

  /// No description provided for @navShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get navShortcuts;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get statusReconnecting;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'No network'**
  String get statusError;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get actionConnect;

  /// No description provided for @actionDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get actionDisconnect;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get actionVerify;

  /// No description provided for @actionBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse...'**
  String get actionBrowse;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Devices'**
  String get devicesTitle;

  /// No description provided for @devicesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 device} other{{count} devices}}'**
  String devicesCount(int count);

  /// No description provided for @devicesNewDevice.
  ///
  /// In en, this message translates to:
  /// **'New Device'**
  String get devicesNewDevice;

  /// No description provided for @devicesSectionWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi / TCP-IP'**
  String get devicesSectionWifi;

  /// No description provided for @devicesSectionUsb.
  ///
  /// In en, this message translates to:
  /// **'USB / TCP-IP'**
  String get devicesSectionUsb;

  /// No description provided for @devicesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved devices'**
  String get devicesEmptyTitle;

  /// No description provided for @devicesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a WiFi device to get started'**
  String get devicesEmptySubtitle;

  /// No description provided for @devicesAddDevice.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get devicesAddDevice;

  /// No description provided for @devicesGlobalShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Global Quick Actions'**
  String get devicesGlobalShortcuts;

  /// No description provided for @devicesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete device'**
  String get devicesDeleteTitle;

  /// No description provided for @devicesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{alias}\"?'**
  String devicesDeleteConfirm(String alias);

  /// No description provided for @devicesTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String devicesTimeAgo(String time);

  /// No description provided for @usbTitle.
  ///
  /// In en, this message translates to:
  /// **'Detected Devices'**
  String get usbTitle;

  /// No description provided for @usbRefresh.
  ///
  /// In en, this message translates to:
  /// **'Updates every 5s'**
  String get usbRefresh;

  /// No description provided for @usbSectionUsb.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get usbSectionUsb;

  /// No description provided for @usbSectionWifi.
  ///
  /// In en, this message translates to:
  /// **'WiFi / TCP-IP detected'**
  String get usbSectionWifi;

  /// No description provided for @usbWifiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Active ADB connections from outside the app'**
  String get usbWifiSubtitle;

  /// No description provided for @usbUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get usbUnauthorized;

  /// No description provided for @usbActivateWifi.
  ///
  /// In en, this message translates to:
  /// **'Enable WiFi ADB'**
  String get usbActivateWifi;

  /// No description provided for @usbSaveDevice.
  ///
  /// In en, this message translates to:
  /// **'Save device'**
  String get usbSaveDevice;

  /// No description provided for @usbAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get usbAlreadySaved;

  /// No description provided for @usbEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No devices detected'**
  String get usbEmptyTitle;

  /// No description provided for @usbEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a USB device or enable ADB WiFi'**
  String get usbEmptySubtitle;

  /// No description provided for @usbEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-detects every 5 seconds'**
  String get usbEmptyHint;

  /// No description provided for @usbAdbNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configure ADB path in Settings first.'**
  String get usbAdbNotConfigured;

  /// No description provided for @usbActivateWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable WiFi ADB'**
  String get usbActivateWifiTitle;

  /// No description provided for @usbActivateWifiDevice.
  ///
  /// In en, this message translates to:
  /// **'Device: {name}'**
  String usbActivateWifiDevice(String name);

  /// No description provided for @usbActivateWifiIpLabel.
  ///
  /// In en, this message translates to:
  /// **'Device IP address'**
  String get usbActivateWifiIpLabel;

  /// No description provided for @usbActivateWifiConfirm.
  ///
  /// In en, this message translates to:
  /// **'Connect & Save'**
  String get usbActivateWifiConfirm;

  /// No description provided for @usbSaveWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'Save WiFi Device'**
  String get usbSaveWifiTitle;

  /// No description provided for @usbSaveWifiNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get usbSaveWifiNameLabel;

  /// No description provided for @shortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get shortcutsTitle;

  /// No description provided for @shortcutsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No quick actions configured'**
  String get shortcutsEmptyTitle;

  /// No description provided for @shortcutsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create fast ADB commands for your devices'**
  String get shortcutsEmptySubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsToolsSection.
  ///
  /// In en, this message translates to:
  /// **'External Tools'**
  String get settingsToolsSection;

  /// No description provided for @settingsToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure the paths for ADB and scrcpy installed on your system.'**
  String get settingsToolsSubtitle;

  /// No description provided for @settingsAdbName.
  ///
  /// In en, this message translates to:
  /// **'Android Debug Bridge (ADB)'**
  String get settingsAdbName;

  /// No description provided for @settingsAdbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Android debugging tool'**
  String get settingsAdbSubtitle;

  /// No description provided for @settingsScrcpyName.
  ///
  /// In en, this message translates to:
  /// **'scrcpy'**
  String get settingsScrcpyName;

  /// No description provided for @settingsScrcpySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Android screen mirror'**
  String get settingsScrcpySubtitle;

  /// No description provided for @settingsWindowsNote.
  ///
  /// In en, this message translates to:
  /// **'Windows: visit github.com/Genymobile/scrcpy to install scrcpy. The app does not include scrcpy internally.'**
  String get settingsWindowsNote;

  /// No description provided for @settingsStatusDetected.
  ///
  /// In en, this message translates to:
  /// **'● Detected · {version}'**
  String settingsStatusDetected(String version);

  /// No description provided for @settingsStatusNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'● Not configured'**
  String get settingsStatusNotConfigured;

  /// No description provided for @settingsStatusUnverified.
  ///
  /// In en, this message translates to:
  /// **'● Unverified'**
  String get settingsStatusUnverified;

  /// No description provided for @settingsGeneralSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralSection;

  /// No description provided for @settingsAutoReconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect on startup'**
  String get settingsAutoReconnectTitle;

  /// No description provided for @settingsAutoReconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try to reconnect WiFi devices when the app starts'**
  String get settingsAutoReconnectSubtitle;

  /// No description provided for @settingsStartMinimizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Start minimized'**
  String get settingsStartMinimizedTitle;

  /// No description provided for @settingsStartMinimizedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App starts in background without a visible window'**
  String get settingsStartMinimizedSubtitle;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeSystemSub.
  ///
  /// In en, this message translates to:
  /// **'Follow OS mode'**
  String get settingsThemeSystemSub;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDarkSub.
  ///
  /// In en, this message translates to:
  /// **'Always dark mode'**
  String get settingsThemeDarkSub;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeLightSub.
  ///
  /// In en, this message translates to:
  /// **'Always light mode'**
  String get settingsThemeLightSub;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLangAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsLangAuto;

  /// No description provided for @settingsLangAutoSub.
  ///
  /// In en, this message translates to:
  /// **'Follow system language'**
  String get settingsLangAutoSub;

  /// No description provided for @settingsLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEn;

  /// No description provided for @settingsLangEnSub.
  ///
  /// In en, this message translates to:
  /// **'Always in English'**
  String get settingsLangEnSub;

  /// No description provided for @settingsLangEs.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settingsLangEs;

  /// No description provided for @settingsLangEsSub.
  ///
  /// In en, this message translates to:
  /// **'Siempre en español'**
  String get settingsLangEsSub;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'ADB connection manager for Android — Windows, macOS and Linux'**
  String get aboutDescription;

  /// No description provided for @modalAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get modalAddTitle;

  /// No description provided for @modalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Device'**
  String get modalEditTitle;

  /// No description provided for @modalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure a new ADB connection'**
  String get modalSubtitle;

  /// No description provided for @modalConnectionType.
  ///
  /// In en, this message translates to:
  /// **'Connection type'**
  String get modalConnectionType;

  /// No description provided for @modalWifiTitle.
  ///
  /// In en, this message translates to:
  /// **'WiFi / TCP-IP'**
  String get modalWifiTitle;

  /// No description provided for @modalWifiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wireless connection via IP and port'**
  String get modalWifiSubtitle;

  /// No description provided for @modalUsbTitle.
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get modalUsbTitle;

  /// No description provided for @modalUsbSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic device detection'**
  String get modalUsbSubtitle;

  /// No description provided for @modalAliasLabel.
  ///
  /// In en, this message translates to:
  /// **'Device alias'**
  String get modalAliasLabel;

  /// No description provided for @modalAliasHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pixel 7 — Office'**
  String get modalAliasHint;

  /// No description provided for @modalIpPortLabel.
  ///
  /// In en, this message translates to:
  /// **'IP Address and Port'**
  String get modalIpPortLabel;

  /// No description provided for @modalAutoReconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect'**
  String get modalAutoReconnectTitle;

  /// No description provided for @modalAutoReconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try to reconnect on app start'**
  String get modalAutoReconnectSubtitle;

  /// No description provided for @modalShortcutsLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick actions for this device'**
  String get modalShortcutsLabel;

  /// No description provided for @modalSaveDevice.
  ///
  /// In en, this message translates to:
  /// **'Save Device'**
  String get modalSaveDevice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
