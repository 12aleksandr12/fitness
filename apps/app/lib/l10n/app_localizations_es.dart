// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get login => 'Entrar';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get loginFailed => 'Correo o contraseña incorrectos';

  @override
  String get schedule => 'Horario';

  @override
  String get cabinet => 'Cuenta';

  @override
  String get clients => 'Clientes';

  @override
  String get roles => 'Roles';

  @override
  String get book => 'Reservar';

  @override
  String get cancel => 'Cancelar reserva';

  @override
  String get checkIn => 'Asistió';

  @override
  String get logout => 'Salir';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get dismiss => 'Cancelar';

  @override
  String get retry => 'Reintentar';

  @override
  String get language => 'Idioma';

  @override
  String get languageTitle => 'Idioma de la app';

  @override
  String get createRole => 'Crear rol';

  @override
  String get profilePage => 'Página personal';

  @override
  String remainingVisits(int count) {
    return 'Visitas restantes: $count';
  }

  @override
  String get myBookings => 'Mis reservas';

  @override
  String get balanceHistory => 'Historial del saldo';

  @override
  String get sessionFallback => 'Clase';

  @override
  String get newSession => 'Nueva clase';

  @override
  String get editSession => 'Editar clase';

  @override
  String get scheduleLoadFailed => 'No se pudo cargar el horario';

  @override
  String trainerLabel(String name) {
    return 'Entrenador: $name';
  }

  @override
  String get sessionTitle => 'Clase';

  @override
  String get noClassTypes => 'No hay tipos de clase';

  @override
  String get classType => 'Tipo';

  @override
  String get date => 'Fecha';

  @override
  String get startTime => 'Inicio';

  @override
  String get durationMin => 'Duración, min';

  @override
  String get room => 'Sala';

  @override
  String get capacity => 'Capacidad';

  @override
  String bookedCount(int count) {
    return 'Reservados: $count';
  }

  @override
  String get checkSessionFields => 'Revisa tipo, duración y capacidad';

  @override
  String capacityBelowBooked(int count) {
    return 'La capacidad es menor que las reservas ($count)';
  }

  @override
  String get capacityBelowBookedShort =>
      'La capacidad es menor que las reservas';

  @override
  String get deleteSessionTitle => '¿Eliminar la clase?';

  @override
  String get deleteSessionMessage =>
      'El hueco desaparecerá del horario. Cancela antes todas las reservas.';

  @override
  String get sessionHasBookings => 'Cancela primero las reservas de esta clase';

  @override
  String get invalidSessionRange => 'El final debe ser posterior al inicio';

  @override
  String get classTypeNotFound => 'Tipo de clase no encontrado';

  @override
  String get saveFailed => 'No se pudo guardar';

  @override
  String get profile => 'Perfil';

  @override
  String get member => 'Participante';

  @override
  String get noData => 'Sin datos';

  @override
  String get choosePhoto => 'Elegir foto';

  @override
  String get deletePhoto => 'Eliminar foto';

  @override
  String get deletePhotoTitle => '¿Eliminar la foto?';

  @override
  String get deletePhotoMessage => 'La foto desaparecerá del perfil.';

  @override
  String get name => 'Nombre';

  @override
  String get phone => 'Teléfono';

  @override
  String get phoneOptional => 'Teléfono (opcional)';

  @override
  String get about => 'Sobre mí';

  @override
  String get aboutOptional => 'Sobre mí (opcional)';

  @override
  String get saved => 'Guardado';

  @override
  String get loadProfileFailed => 'No se pudo cargar el perfil';

  @override
  String get photoTooLarge =>
      'El archivo supera 512 KB. Elige una foto más pequeña.';

  @override
  String get photoType => 'Usa JPEG, PNG o WebP de hasta 512 KB';

  @override
  String get deletePhotoFailed => 'No se pudo eliminar la foto';

  @override
  String get grantVisits => 'Añadir 8 visitas';

  @override
  String get visitsGranted => 'Se añadieron 8 visitas';

  @override
  String get adjustNote => 'Abono';

  @override
  String get newRole => 'Nuevo rol';

  @override
  String rolePermissions(String name) {
    return 'Permisos: $name';
  }

  @override
  String get roleName => 'Nombre';

  @override
  String get deleteRoleTitle => '¿Eliminar el rol?';

  @override
  String deleteRoleMessage(String name) {
    return 'El rol «$name» se eliminará.';
  }

  @override
  String get defaultRoleName => 'Recepción';

  @override
  String get sessionLog => 'Registro de la clase';

  @override
  String get sessionLogEmpty => 'Aún no hay entradas';

  @override
  String logBooked(String actor, String target) {
    return '$actor reservó: $target';
  }

  @override
  String logCancelled(String actor, String target) {
    return '$actor canceló: $target';
  }

  @override
  String logCancelledOther(String actor, String target) {
    return '$actor quitó: $target';
  }

  @override
  String logCheckedIn(String actor, String target) {
    return '$actor registró: $target';
  }

  @override
  String get cancelOtherTitle => '¿Quitar de la clase?';

  @override
  String cancelOtherMessage(String name) {
    return '$name será quitado de esta clase.';
  }
}
