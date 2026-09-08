// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get login => 'Увійти';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get loginFailed => 'Неправильний email або пароль';

  @override
  String get schedule => 'Розклад';

  @override
  String get cabinet => 'Кабінет';

  @override
  String get clients => 'Клієнти';

  @override
  String get roles => 'Ролі';

  @override
  String get book => 'Записатися';

  @override
  String get cancel => 'Скасувати';

  @override
  String get checkIn => 'Прийшов';

  @override
  String get logout => 'Вийти';

  @override
  String get save => 'Зберегти';

  @override
  String get delete => 'Видалити';

  @override
  String get dismiss => 'Скасувати';

  @override
  String get retry => 'Повторити';

  @override
  String get language => 'Мова';

  @override
  String get languageTitle => 'Мова застосунку';

  @override
  String get createRole => 'Створити роль';

  @override
  String get profilePage => 'Особиста сторінка';

  @override
  String remainingVisits(int count) {
    return 'Залишок візитів: $count';
  }

  @override
  String get myBookings => 'Мої записи';

  @override
  String get balanceHistory => 'Історія балансу';

  @override
  String get sessionFallback => 'Заняття';

  @override
  String get newSession => 'Нове заняття';

  @override
  String get editSession => 'Змінити заняття';

  @override
  String get scheduleLoadFailed => 'Не вдалося завантажити розклад';

  @override
  String trainerLabel(String name) {
    return 'Тренер: $name';
  }

  @override
  String get sessionTitle => 'Заняття';

  @override
  String get noClassTypes => 'Немає типів занять';

  @override
  String get classType => 'Тип';

  @override
  String get date => 'Дата';

  @override
  String get startTime => 'Початок';

  @override
  String get durationMin => 'Тривалість, хв';

  @override
  String get room => 'Зала';

  @override
  String get capacity => 'Місткість';

  @override
  String bookedCount(int count) {
    return 'Записано: $count';
  }

  @override
  String get checkSessionFields => 'Перевірте тип, тривалість і місткість';

  @override
  String capacityBelowBooked(int count) {
    return 'Місткість менша за кількість записаних ($count)';
  }

  @override
  String get capacityBelowBookedShort =>
      'Місткість менша за кількість записаних';

  @override
  String get deleteSessionTitle => 'Видалити заняття?';

  @override
  String get deleteSessionMessage =>
      'Слот зникне з розкладу. Спочатку зніміть усі записи.';

  @override
  String get sessionHasBookings => 'Спочатку скасуйте записи на це заняття';

  @override
  String get invalidSessionRange => 'Завершення має бути пізніше за початок';

  @override
  String get classTypeNotFound => 'Тип заняття не знайдено';

  @override
  String get saveFailed => 'Не вдалося зберегти';

  @override
  String get profile => 'Профіль';

  @override
  String get member => 'Учасник';

  @override
  String get noData => 'Немає даних';

  @override
  String get choosePhoto => 'Вибрати фото';

  @override
  String get deletePhoto => 'Видалити фото';

  @override
  String get deletePhotoTitle => 'Видалити фото?';

  @override
  String get deletePhotoMessage => 'Фото зникне з профілю.';

  @override
  String get name => 'Ім’я';

  @override
  String get phone => 'Телефон';

  @override
  String get phoneOptional => 'Телефон (необов’язково)';

  @override
  String get about => 'Про себе';

  @override
  String get aboutOptional => 'Про себе (необов’язково)';

  @override
  String get saved => 'Збережено';

  @override
  String get loadProfileFailed => 'Не вдалося завантажити профіль';

  @override
  String get photoTooLarge => 'Файл більший за 512 КБ. Виберіть менше фото.';

  @override
  String get photoType => 'Потрібен JPEG, PNG або WebP до 512 КБ';

  @override
  String get deletePhotoFailed => 'Не вдалося видалити фото';

  @override
  String get grantVisits => 'Нарахувати 8 візитів';

  @override
  String get visitsGranted => 'Нараховано 8 візитів';

  @override
  String get adjustNote => 'Нарахування';

  @override
  String get newRole => 'Нова роль';

  @override
  String rolePermissions(String name) {
    return 'Права: $name';
  }

  @override
  String get roleName => 'Назва';

  @override
  String get deleteRoleTitle => 'Видалити роль?';

  @override
  String deleteRoleMessage(String name) {
    return 'Роль «$name» буде видалено.';
  }

  @override
  String get defaultRoleName => 'Ресепшен';

  @override
  String get sessionLog => 'Журнал заняття';

  @override
  String get sessionLogEmpty => 'Поки немає записів';

  @override
  String logBooked(String actor, String target) {
    return '$actor записався: $target';
  }

  @override
  String logCancelled(String actor, String target) {
    return '$actor скасував запис: $target';
  }

  @override
  String logCancelledOther(String actor, String target) {
    return '$actor зняв із заняття: $target';
  }

  @override
  String logCheckedIn(String actor, String target) {
    return '$actor відмітив візит: $target';
  }

  @override
  String get cancelOtherTitle => 'Зняти із заняття?';

  @override
  String cancelOtherMessage(String name) {
    return '$name буде знято з цього заняття.';
  }
}
