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
  String get remainingVisits => 'Остаток визитов';

  @override
  String get createRole => 'Создать роль';

  @override
  String get save => 'Сохранить';
}
