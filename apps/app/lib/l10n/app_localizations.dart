import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Fitness'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @loginFailed.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get loginFailed;

  /// No description provided for @schedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get schedule;

  /// No description provided for @cabinet.
  ///
  /// In ru, this message translates to:
  /// **'Кабинет'**
  String get cabinet;

  /// No description provided for @clients.
  ///
  /// In ru, this message translates to:
  /// **'Клиенты'**
  String get clients;

  /// No description provided for @roles.
  ///
  /// In ru, this message translates to:
  /// **'Роли'**
  String get roles;

  /// No description provided for @book.
  ///
  /// In ru, this message translates to:
  /// **'Записаться'**
  String get book;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get cancel;

  /// No description provided for @checkIn.
  ///
  /// In ru, this message translates to:
  /// **'Пришёл'**
  String get checkIn;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @dismiss.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get dismiss;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get languageTitle;

  /// No description provided for @createRole.
  ///
  /// In ru, this message translates to:
  /// **'Создать роль'**
  String get createRole;

  /// No description provided for @profilePage.
  ///
  /// In ru, this message translates to:
  /// **'Личная страница'**
  String get profilePage;

  /// No description provided for @remainingVisits.
  ///
  /// In ru, this message translates to:
  /// **'Остаток визитов: {count}'**
  String remainingVisits(int count);

  /// No description provided for @myBookings.
  ///
  /// In ru, this message translates to:
  /// **'Мои записи'**
  String get myBookings;

  /// No description provided for @noUpcomingBookings.
  ///
  /// In ru, this message translates to:
  /// **'Нет предстоящих записей'**
  String get noUpcomingBookings;

  /// No description provided for @statusBooked.
  ///
  /// In ru, this message translates to:
  /// **'Записан'**
  String get statusBooked;

  /// No description provided for @statusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get statusCancelled;

  /// No description provided for @balanceHistory.
  ///
  /// In ru, this message translates to:
  /// **'История баланса'**
  String get balanceHistory;

  /// No description provided for @sessionFallback.
  ///
  /// In ru, this message translates to:
  /// **'Занятие'**
  String get sessionFallback;

  /// No description provided for @newSession.
  ///
  /// In ru, this message translates to:
  /// **'Новое занятие'**
  String get newSession;

  /// No description provided for @editSession.
  ///
  /// In ru, this message translates to:
  /// **'Изменить занятие'**
  String get editSession;

  /// No description provided for @scheduleLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить расписание'**
  String get scheduleLoadFailed;

  /// No description provided for @trainerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тренер: {name}'**
  String trainerLabel(String name);

  /// No description provided for @sessionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Занятие'**
  String get sessionTitle;

  /// No description provided for @noClassTypes.
  ///
  /// In ru, this message translates to:
  /// **'Нет типов занятий'**
  String get noClassTypes;

  /// No description provided for @classType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get classType;

  /// No description provided for @trainer.
  ///
  /// In ru, this message translates to:
  /// **'Тренер'**
  String get trainer;

  /// No description provided for @noTrainer.
  ///
  /// In ru, this message translates to:
  /// **'Без тренера'**
  String get noTrainer;

  /// No description provided for @trainerNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Этого человека нет в студии'**
  String get trainerNotFound;

  /// No description provided for @date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @startTime.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get startTime;

  /// No description provided for @durationMin.
  ///
  /// In ru, this message translates to:
  /// **'Длительность, мин'**
  String get durationMin;

  /// No description provided for @room.
  ///
  /// In ru, this message translates to:
  /// **'Зал'**
  String get room;

  /// No description provided for @capacity.
  ///
  /// In ru, this message translates to:
  /// **'Вместимость'**
  String get capacity;

  /// No description provided for @bookedCount.
  ///
  /// In ru, this message translates to:
  /// **'Записано: {count}'**
  String bookedCount(int count);

  /// No description provided for @checkSessionFields.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте тип, длительность и вместимость'**
  String get checkSessionFields;

  /// No description provided for @capacityBelowBooked.
  ///
  /// In ru, this message translates to:
  /// **'Вместимость меньше числа записанных ({count})'**
  String capacityBelowBooked(int count);

  /// No description provided for @capacityBelowBookedShort.
  ///
  /// In ru, this message translates to:
  /// **'Вместимость меньше числа записанных'**
  String get capacityBelowBookedShort;

  /// No description provided for @deleteSessionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить занятие?'**
  String get deleteSessionTitle;

  /// No description provided for @deleteSessionMessage.
  ///
  /// In ru, this message translates to:
  /// **'Слот пропадёт из расписания. Сначала снимите все записи.'**
  String get deleteSessionMessage;

  /// No description provided for @sessionHasBookings.
  ///
  /// In ru, this message translates to:
  /// **'Сначала отмените записи на это занятие'**
  String get sessionHasBookings;

  /// No description provided for @invalidSessionRange.
  ///
  /// In ru, this message translates to:
  /// **'Окончание должно быть позже начала'**
  String get invalidSessionRange;

  /// No description provided for @classTypeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Тип занятия не найден'**
  String get classTypeNotFound;

  /// No description provided for @saveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить'**
  String get saveFailed;

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @member.
  ///
  /// In ru, this message translates to:
  /// **'Участник'**
  String get member;

  /// No description provided for @noData.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных'**
  String get noData;

  /// No description provided for @choosePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать фото'**
  String get choosePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото'**
  String get deletePhoto;

  /// No description provided for @deletePhotoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото?'**
  String get deletePhotoTitle;

  /// No description provided for @deletePhotoMessage.
  ///
  /// In ru, this message translates to:
  /// **'Фото пропадёт из профиля.'**
  String get deletePhotoMessage;

  /// No description provided for @name.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// No description provided for @phoneOptional.
  ///
  /// In ru, this message translates to:
  /// **'Телефон (необязательно)'**
  String get phoneOptional;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О себе'**
  String get about;

  /// No description provided for @aboutOptional.
  ///
  /// In ru, this message translates to:
  /// **'О себе (необязательно)'**
  String get aboutOptional;

  /// No description provided for @saved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get saved;

  /// No description provided for @loadProfileFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить профиль'**
  String get loadProfileFailed;

  /// No description provided for @photoTooLarge.
  ///
  /// In ru, this message translates to:
  /// **'Файл больше 512 КБ. Выберите фото меньше.'**
  String get photoTooLarge;

  /// No description provided for @photoType.
  ///
  /// In ru, this message translates to:
  /// **'Нужен JPEG, PNG или WebP до 512 КБ'**
  String get photoType;

  /// No description provided for @deletePhotoFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить фото'**
  String get deletePhotoFailed;

  /// No description provided for @grantVisits.
  ///
  /// In ru, this message translates to:
  /// **'Начислить 8 визитов'**
  String get grantVisits;

  /// No description provided for @visitsGranted.
  ///
  /// In ru, this message translates to:
  /// **'Начислено 8 визитов'**
  String get visitsGranted;

  /// No description provided for @adjustNote.
  ///
  /// In ru, this message translates to:
  /// **'Начисление'**
  String get adjustNote;

  /// No description provided for @newRole.
  ///
  /// In ru, this message translates to:
  /// **'Новая роль'**
  String get newRole;

  /// No description provided for @rolePermissions.
  ///
  /// In ru, this message translates to:
  /// **'Права: {name}'**
  String rolePermissions(String name);

  /// No description provided for @roleName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get roleName;

  /// No description provided for @deleteRoleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить роль?'**
  String get deleteRoleTitle;

  /// No description provided for @deleteRoleMessage.
  ///
  /// In ru, this message translates to:
  /// **'Роль «{name}» будет удалена.'**
  String deleteRoleMessage(String name);

  /// No description provided for @defaultRoleName.
  ///
  /// In ru, this message translates to:
  /// **'Ресепшен'**
  String get defaultRoleName;

  /// No description provided for @sessionLog.
  ///
  /// In ru, this message translates to:
  /// **'История записи'**
  String get sessionLog;

  /// No description provided for @sessionLogEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет записей'**
  String get sessionLogEmpty;

  /// No description provided for @logBookedSelf.
  ///
  /// In ru, this message translates to:
  /// **'{name}: запись'**
  String logBookedSelf(String name);

  /// No description provided for @logCancelledSelf.
  ///
  /// In ru, this message translates to:
  /// **'{name}: отмена записи'**
  String logCancelledSelf(String name);

  /// No description provided for @logCheckedInSelf.
  ///
  /// In ru, this message translates to:
  /// **'{name}: визит отмечен'**
  String logCheckedInSelf(String name);

  /// No description provided for @logBooked.
  ///
  /// In ru, this message translates to:
  /// **'{actor}: запись для {target}'**
  String logBooked(String actor, String target);

  /// No description provided for @logCancelledOther.
  ///
  /// In ru, this message translates to:
  /// **'{actor}: снятие {target}'**
  String logCancelledOther(String actor, String target);

  /// No description provided for @logCheckedIn.
  ///
  /// In ru, this message translates to:
  /// **'{actor} отметил визит: {target}'**
  String logCheckedIn(String actor, String target);

  /// No description provided for @cancelOtherTitle.
  ///
  /// In ru, this message translates to:
  /// **'Снять с занятия?'**
  String get cancelOtherTitle;

  /// No description provided for @cancelOtherMessage.
  ///
  /// In ru, this message translates to:
  /// **'{name} будет снят с этого занятия.'**
  String cancelOtherMessage(String name);

  /// No description provided for @commentOptional.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий (необязательно)'**
  String get commentOptional;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get register;

  /// No description provided for @registerHint.
  ///
  /// In ru, this message translates to:
  /// **'Нужен токен из письма-приглашения.'**
  String get registerHint;

  /// No description provided for @inviteToken.
  ///
  /// In ru, this message translates to:
  /// **'Токен приглашения'**
  String get inviteToken;

  /// No description provided for @confirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль ещё раз'**
  String get confirmPassword;

  /// No description provided for @passwordsMismatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsMismatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In ru, this message translates to:
  /// **'Пароль — минимум 8 символов'**
  String get passwordMinLength;

  /// No description provided for @checkRegisterFields.
  ///
  /// In ru, this message translates to:
  /// **'Заполните токен и имя'**
  String get checkRegisterFields;

  /// No description provided for @registerFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось зарегистрироваться'**
  String get registerFailed;

  /// No description provided for @invalidInvite.
  ///
  /// In ru, this message translates to:
  /// **'Приглашение недействительно или уже использовано'**
  String get invalidInvite;

  /// No description provided for @emailTaken.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован'**
  String get emailTaken;

  /// No description provided for @backToLogin.
  ///
  /// In ru, this message translates to:
  /// **'Ко входу'**
  String get backToLogin;

  /// No description provided for @inviteUser.
  ///
  /// In ru, this message translates to:
  /// **'Пригласить'**
  String get inviteUser;

  /// No description provided for @inviteSent.
  ///
  /// In ru, this message translates to:
  /// **'Приглашение отправлено. Токен:'**
  String get inviteSent;

  /// No description provided for @copyToken.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать токен'**
  String get copyToken;

  /// No description provided for @role.
  ///
  /// In ru, this message translates to:
  /// **'Роль'**
  String get role;

  /// No description provided for @noRoles.
  ///
  /// In ru, this message translates to:
  /// **'Нет ролей'**
  String get noRoles;

  /// No description provided for @cancelTooLate.
  ///
  /// In ru, this message translates to:
  /// **'Уже поздно отменять — меньше окна отмены студии'**
  String get cancelTooLate;

  /// No description provided for @notCancellable.
  ///
  /// In ru, this message translates to:
  /// **'Эту запись нельзя отменить (уже отмечен визит)'**
  String get notCancellable;

  /// No description provided for @cancelFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось снять с занятия'**
  String get cancelFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'ru',
        'uk'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
