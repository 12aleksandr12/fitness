// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get login => 'Войти';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get loginFailed => 'Неверный email или пароль';

  @override
  String get schedule => 'Расписание';

  @override
  String get cabinet => 'Кабинет';

  @override
  String get clients => 'Клиенты';

  @override
  String get roles => 'Роли';

  @override
  String get book => 'Записаться';

  @override
  String get cancel => 'Отменить';

  @override
  String get checkIn => 'Пришёл';

  @override
  String get logout => 'Выйти';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get dismiss => 'Отмена';

  @override
  String get retry => 'Повторить';

  @override
  String get language => 'Язык';

  @override
  String get languageTitle => 'Язык приложения';

  @override
  String get createRole => 'Создать роль';

  @override
  String get profilePage => 'Личная страница';

  @override
  String remainingVisits(int count) {
    return 'Остаток визитов: $count';
  }

  @override
  String get myBookings => 'Мои записи';

  @override
  String get balanceHistory => 'История баланса';

  @override
  String get sessionFallback => 'Занятие';

  @override
  String get newSession => 'Новое занятие';

  @override
  String get editSession => 'Изменить занятие';

  @override
  String get scheduleLoadFailed => 'Не удалось загрузить расписание';

  @override
  String trainerLabel(String name) {
    return 'Тренер: $name';
  }

  @override
  String get sessionTitle => 'Занятие';

  @override
  String get noClassTypes => 'Нет типов занятий';

  @override
  String get classType => 'Тип';

  @override
  String get date => 'Дата';

  @override
  String get startTime => 'Начало';

  @override
  String get durationMin => 'Длительность, мин';

  @override
  String get room => 'Зал';

  @override
  String get capacity => 'Вместимость';

  @override
  String bookedCount(int count) {
    return 'Записано: $count';
  }

  @override
  String get checkSessionFields => 'Проверьте тип, длительность и вместимость';

  @override
  String capacityBelowBooked(int count) {
    return 'Вместимость меньше числа записанных ($count)';
  }

  @override
  String get capacityBelowBookedShort => 'Вместимость меньше числа записанных';

  @override
  String get deleteSessionTitle => 'Удалить занятие?';

  @override
  String get deleteSessionMessage =>
      'Слот пропадёт из расписания. Сначала снимите все записи.';

  @override
  String get sessionHasBookings => 'Сначала отмените записи на это занятие';

  @override
  String get invalidSessionRange => 'Окончание должно быть позже начала';

  @override
  String get classTypeNotFound => 'Тип занятия не найден';

  @override
  String get saveFailed => 'Не удалось сохранить';

  @override
  String get profile => 'Профиль';

  @override
  String get member => 'Участник';

  @override
  String get noData => 'Нет данных';

  @override
  String get choosePhoto => 'Выбрать фото';

  @override
  String get deletePhoto => 'Удалить фото';

  @override
  String get deletePhotoTitle => 'Удалить фото?';

  @override
  String get deletePhotoMessage => 'Фото пропадёт из профиля.';

  @override
  String get name => 'Имя';

  @override
  String get phone => 'Телефон';

  @override
  String get phoneOptional => 'Телефон (необязательно)';

  @override
  String get about => 'О себе';

  @override
  String get aboutOptional => 'О себе (необязательно)';

  @override
  String get saved => 'Сохранено';

  @override
  String get loadProfileFailed => 'Не удалось загрузить профиль';

  @override
  String get photoTooLarge => 'Файл больше 512 КБ. Выберите фото меньше.';

  @override
  String get photoType => 'Нужен JPEG, PNG или WebP до 512 КБ';

  @override
  String get deletePhotoFailed => 'Не удалось удалить фото';

  @override
  String get grantVisits => 'Начислить 8 визитов';

  @override
  String get visitsGranted => 'Начислено 8 визитов';

  @override
  String get adjustNote => 'Начисление';

  @override
  String get newRole => 'Новая роль';

  @override
  String rolePermissions(String name) {
    return 'Права: $name';
  }

  @override
  String get roleName => 'Название';

  @override
  String get deleteRoleTitle => 'Удалить роль?';

  @override
  String deleteRoleMessage(String name) {
    return 'Роль «$name» будет удалена.';
  }

  @override
  String get defaultRoleName => 'Ресепшен';

  @override
  String get sessionLog => 'Журнал занятия';

  @override
  String get sessionLogEmpty => 'Пока нет записей';

  @override
  String logBooked(String actor, String target) {
    return '$actor записался: $target';
  }

  @override
  String logCancelled(String actor, String target) {
    return '$actor отменил запись: $target';
  }

  @override
  String logCancelledOther(String actor, String target) {
    return '$actor снял с занятия: $target';
  }

  @override
  String logCheckedIn(String actor, String target) {
    return '$actor отметил визит: $target';
  }

  @override
  String get cancelOtherTitle => 'Снять с занятия?';

  @override
  String cancelOtherMessage(String name) {
    return '$name будет снят с этого занятия.';
  }
}
