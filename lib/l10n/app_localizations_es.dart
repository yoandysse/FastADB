// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navDevices => 'Mis Dispositivos';

  @override
  String get navUsb => 'USB Detectados';

  @override
  String get navShortcuts => 'Accesos Rápidos';

  @override
  String get navSettings => 'Configuración';

  @override
  String get statusConnected => 'Conectado';

  @override
  String get statusReconnecting => 'Reconectando...';

  @override
  String get statusOffline => 'Sin conexión';

  @override
  String get statusError => 'Sin red';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionConnect => 'Conectar';

  @override
  String get actionDisconnect => 'Desconectar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionVerify => 'Verificar';

  @override
  String get actionBrowse => 'Explorar...';

  @override
  String get shortcutsRunning => 'Ejecutando...';

  @override
  String get shortcutsCompleted => 'Completado';

  @override
  String get shortcutsFailed => 'Error';

  @override
  String get shortcutsNoOutput => '(sin salida)';

  @override
  String get devicesTitle => 'Mis Dispositivos';

  @override
  String devicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get devicesNewDevice => 'Nuevo Dispositivo';

  @override
  String get devicesSectionWifi => 'WiFi / TCP-IP';

  @override
  String get devicesSectionUsb => 'USB / TCP-IP';

  @override
  String get devicesEmptyTitle => 'Sin dispositivos guardados';

  @override
  String get devicesEmptySubtitle => 'Agrega un dispositivo WiFi para comenzar';

  @override
  String get devicesAddDevice => 'Agregar Dispositivo';

  @override
  String get devicesGlobalShortcuts => 'Accesos Rápidos Globales';

  @override
  String get devicesShortcutHint =>
      'Selecciona un dispositivo primero, o toca un acceso para elegir';

  @override
  String get devicesNoConnected => 'No hay dispositivos conectados';

  @override
  String get devicesSelectDevice => 'Selecciona el dispositivo';

  @override
  String get devicesDeleteTitle => 'Eliminar dispositivo';

  @override
  String devicesDeleteConfirm(String alias) {
    return '¿Eliminar \"$alias\"?';
  }

  @override
  String devicesTimeAgo(String time) {
    return 'Hace $time';
  }

  @override
  String get usbTitle => 'Dispositivos Detectados';

  @override
  String usbDeviceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos',
      one: '1 dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get usbRefresh => 'Actualiza cada 5s';

  @override
  String get usbSectionUsb => 'USB';

  @override
  String get usbSectionWifi => 'WiFi / TCP-IP detectados';

  @override
  String get usbWifiSubtitle => 'Conexiones ADB activas desde fuera de la app';

  @override
  String get usbUnknownDevice => 'Dispositivo desconocido';

  @override
  String get usbUnauthorized => 'Sin autorizar';

  @override
  String get usbActivateWifi => 'Activar WiFi ADB';

  @override
  String get usbSaveDevice => 'Guardar dispositivo';

  @override
  String get usbAlreadySaved => 'Ya guardado';

  @override
  String get usbEmptyTitle => 'Sin dispositivos detectados';

  @override
  String get usbEmptySubtitle =>
      'Conecta un dispositivo por USB o activa ADB WiFi';

  @override
  String get usbEmptyHint => 'Se detecta automáticamente cada 5 segundos';

  @override
  String get usbAdbNotConfigured =>
      'Configura la ruta de ADB en Configuración primero.';

  @override
  String get usbActivateWifiTitle => 'Activar WiFi ADB';

  @override
  String usbActivateWifiDevice(String name) {
    return 'Dispositivo: $name';
  }

  @override
  String get usbActivateWifiIpLabel => 'Dirección IP del dispositivo';

  @override
  String get usbActivateWifiConfirm => 'Conectar y Guardar';

  @override
  String get usbSaveWifiTitle => 'Guardar dispositivo WiFi';

  @override
  String get usbSaveWifiNameLabel => 'Nombre del dispositivo';

  @override
  String get shortcutsTitle => 'Accesos Rápidos';

  @override
  String get shortcutsNew => 'Nuevo acceso';

  @override
  String get shortcutsSectionGlobal => 'Globales';

  @override
  String get shortcutsSectionDevice => 'Por dispositivo';

  @override
  String get shortcutsDeviceHint =>
      'Usa %DEVICE% en el comando para reemplazarlo con el serial del dispositivo activo.';

  @override
  String get shortcutsDeleteTitle => 'Eliminar acceso rápido';

  @override
  String shortcutsDeleteConfirm(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get shortcutsCopyCmd => 'Copiar comando';

  @override
  String get shortcutsCreate => 'Crear acceso rápido';

  @override
  String get shortcutsEmptyTitle => 'Sin accesos rápidos configurados';

  @override
  String get shortcutsEmptySubtitle =>
      'Crea comandos ADB rápidos para tus dispositivos';

  @override
  String get shortcutsModalCreateTitle => 'Nuevo acceso rápido';

  @override
  String get shortcutsModalEditTitle => 'Editar acceso rápido';

  @override
  String get shortcutsModalNameLabel => 'Nombre';

  @override
  String get shortcutsModalNameHint => 'ej. Abrir Shell';

  @override
  String get shortcutsModalNameRequired => 'El nombre es requerido';

  @override
  String get shortcutsModalCmdLabel => 'Comando';

  @override
  String get shortcutsModalCmdRequired => 'El comando es requerido';

  @override
  String get shortcutsModalCmdHint =>
      'Usa %DEVICE% para el serial del dispositivo activo';

  @override
  String get shortcutsModalIconLabel => 'Ícono';

  @override
  String get shortcutsModalGlobalTitle => 'Global';

  @override
  String get shortcutsModalGlobalSubtitle =>
      'Aparece en la barra de acciones de todos los dispositivos';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsToolsSection => 'Herramientas Externas';

  @override
  String get settingsToolsSubtitle =>
      'Configura las rutas de ADB y scrcpy instaladas en tu sistema.';

  @override
  String get settingsAdbName => 'Android Debug Bridge (ADB)';

  @override
  String get settingsAdbSubtitle => 'Herramienta de depuración Android';

  @override
  String get settingsScrcpyName => 'scrcpy';

  @override
  String get settingsScrcpySubtitle => 'Espejo de pantalla Android';

  @override
  String get settingsWindowsNote =>
      'Windows: visita github.com/Genymobile/scrcpy para instalar scrcpy. La app no incluye scrcpy internamente.';

  @override
  String get settingsAutoDetect => 'Auto-detectar';

  @override
  String settingsStatusDetected(String version) {
    return '● Detectado · $version';
  }

  @override
  String get settingsStatusNotConfigured => '● No configurado';

  @override
  String get settingsStatusUnverified => '● Sin verificar';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsAutoReconnectTitle => 'Reconexión automática al inicio';

  @override
  String get settingsAutoReconnectSubtitle =>
      'Intentar reconectar dispositivos WiFi al iniciar la app';

  @override
  String get settingsStartMinimizedTitle => 'Iniciar minimizado';

  @override
  String get settingsStartMinimizedSubtitle =>
      'La app inicia en segundo plano sin ventana visible';

  @override
  String get settingsAppearanceSection => 'Apariencia';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeSystemSub => 'Sigue el modo del SO';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeDarkSub => 'Siempre modo oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeLightSub => 'Siempre modo claro';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get settingsLangAuto => 'Sistema';

  @override
  String get settingsLangAutoSub => 'Idioma del SO';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsLangEnSub => 'Inglés';

  @override
  String get settingsLangEs => 'Español';

  @override
  String get settingsLangEsSub => 'Español';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutDescription =>
      'Gestor de conexiones ADB para Android — Windows, macOS y Linux';

  @override
  String get modalAddTitle => 'Agregar Dispositivo';

  @override
  String get modalEditTitle => 'Editar Dispositivo';

  @override
  String get modalSubtitle => 'Configura una nueva conexión ADB';

  @override
  String get modalConnectionType => 'Tipo de conexión';

  @override
  String get modalWifiTitle => 'WiFi / TCP-IP';

  @override
  String get modalWifiSubtitle => 'Conexión inalámbrica por IP y puerto';

  @override
  String get modalUsbTitle => 'USB';

  @override
  String get modalUsbSubtitle => 'Detección automática de dispositivos';

  @override
  String get modalAliasLabel => 'Alias del dispositivo';

  @override
  String get modalAliasHint => 'ej. Pixel 7 — Oficina';

  @override
  String get modalIpPortLabel => 'Dirección IP y Puerto';

  @override
  String get modalAutoReconnectTitle => 'Reconexión automática';

  @override
  String get modalAutoReconnectSubtitle =>
      'Intentar reconectar al iniciar la app';

  @override
  String get modalShortcutsLabel => 'Accesos rápidos para este dispositivo';

  @override
  String get modalSaveDevice => 'Guardar Dispositivo';
}
