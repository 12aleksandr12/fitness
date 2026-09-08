// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get login => 'Anmelden';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get loginFailed => 'Falsche E-Mail oder Passwort';

  @override
  String get schedule => 'Stundenplan';

  @override
  String get cabinet => 'Konto';

  @override
  String get clients => 'Kunden';

  @override
  String get roles => 'Rollen';

  @override
  String get book => 'Buchen';

  @override
  String get cancel => 'Buchung stornieren';

  @override
  String get checkIn => 'Anwesend';

  @override
  String get logout => 'Abmelden';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get dismiss => 'Abbrechen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get language => 'Sprache';

  @override
  String get languageTitle => 'App-Sprache';

  @override
  String get createRole => 'Rolle erstellen';

  @override
  String get profilePage => 'Persönliche Seite';

  @override
  String remainingVisits(int count) {
    return 'Verbleibende Besuche: $count';
  }

  @override
  String get myBookings => 'Meine Buchungen';

  @override
  String get noUpcomingBookings => 'Keine anstehenden Buchungen';

  @override
  String get statusBooked => 'Gebucht';

  @override
  String get statusCancelled => 'Storniert';

  @override
  String get balanceHistory => 'Kontostand-Verlauf';

  @override
  String get sessionFallback => 'Kurs';

  @override
  String get newSession => 'Neuer Kurs';

  @override
  String get editSession => 'Kurs bearbeiten';

  @override
  String get scheduleLoadFailed => 'Stundenplan konnte nicht geladen werden';

  @override
  String trainerLabel(String name) {
    return 'Trainer: $name';
  }

  @override
  String get sessionTitle => 'Kurs';

  @override
  String get noClassTypes => 'Keine Kurstypen';

  @override
  String get classType => 'Typ';

  @override
  String get trainer => 'Trainer';

  @override
  String get noTrainer => 'Kein Trainer';

  @override
  String get trainerNotFound => 'Diese Person ist nicht im Studio';

  @override
  String get date => 'Datum';

  @override
  String get startTime => 'Beginn';

  @override
  String get durationMin => 'Dauer, Min.';

  @override
  String get room => 'Raum';

  @override
  String get capacity => 'Kapazität';

  @override
  String bookedCount(int count) {
    return 'Gebucht: $count';
  }

  @override
  String get checkSessionFields => 'Typ, Dauer und Kapazität prüfen';

  @override
  String capacityBelowBooked(int count) {
    return 'Kapazität liegt unter den Buchungen ($count)';
  }

  @override
  String get capacityBelowBookedShort => 'Kapazität liegt unter den Buchungen';

  @override
  String get deleteSessionTitle => 'Kurs löschen?';

  @override
  String get deleteSessionMessage =>
      'Der Slot verschwindet aus dem Plan. Zuerst alle Buchungen stornieren.';

  @override
  String get sessionHasBookings =>
      'Zuerst die Buchungen für diesen Kurs stornieren';

  @override
  String get invalidSessionRange => 'Das Ende muss nach dem Beginn liegen';

  @override
  String get classTypeNotFound => 'Kurstyp nicht gefunden';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get profile => 'Profil';

  @override
  String get member => 'Mitglied';

  @override
  String get noData => 'Keine Daten';

  @override
  String get choosePhoto => 'Foto wählen';

  @override
  String get deletePhoto => 'Foto löschen';

  @override
  String get deletePhotoTitle => 'Foto löschen?';

  @override
  String get deletePhotoMessage => 'Das Foto wird aus dem Profil entfernt.';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Telefon';

  @override
  String get phoneOptional => 'Telefon (optional)';

  @override
  String get about => 'Über mich';

  @override
  String get aboutOptional => 'Über mich (optional)';

  @override
  String get saved => 'Gespeichert';

  @override
  String get loadProfileFailed => 'Profil konnte nicht geladen werden';

  @override
  String get photoTooLarge =>
      'Datei größer als 512 KB. Bitte ein kleineres Foto wählen.';

  @override
  String get photoType => 'JPEG, PNG oder WebP bis 512 KB';

  @override
  String get deletePhotoFailed => 'Foto konnte nicht gelöscht werden';

  @override
  String get grantVisits => '8 Besuche gutschreiben';

  @override
  String get visitsGranted => '8 Besuche gutgeschrieben';

  @override
  String get adjustNote => 'Gutschrift';

  @override
  String get newRole => 'Neue Rolle';

  @override
  String rolePermissions(String name) {
    return 'Rechte: $name';
  }

  @override
  String get roleName => 'Name';

  @override
  String get deleteRoleTitle => 'Rolle löschen?';

  @override
  String deleteRoleMessage(String name) {
    return 'Die Rolle „$name“ wird gelöscht.';
  }

  @override
  String get defaultRoleName => 'Empfang';

  @override
  String get sessionLog => 'Buchungsverlauf';

  @override
  String get sessionLogEmpty => 'Noch keine Einträge';

  @override
  String logBookedSelf(String name) {
    return '$name hat gebucht';
  }

  @override
  String logCancelledSelf(String name) {
    return '$name hat storniert';
  }

  @override
  String logCheckedInSelf(String name) {
    return '$name — Visit markiert';
  }

  @override
  String logBooked(String actor, String target) {
    return '$actor hat gebucht: $target';
  }

  @override
  String logCancelledOther(String actor, String target) {
    return '$actor hat abgemeldet: $target';
  }

  @override
  String logCheckedIn(String actor, String target) {
    return '$actor hat eingecheckt: $target';
  }

  @override
  String get cancelOtherTitle => 'Vom Kurs abmelden?';

  @override
  String cancelOtherMessage(String name) {
    return '$name wird von diesem Kurs abgemeldet.';
  }

  @override
  String get commentOptional => 'Kommentar (optional)';

  @override
  String get register => 'Registrierung';

  @override
  String get registerHint => 'Sie brauchen den Token aus der Einladungsmail.';

  @override
  String get inviteToken => 'Einladungstoken';

  @override
  String get confirmPassword => 'Passwort wiederholen';

  @override
  String get passwordsMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordMinLength => 'Passwort mindestens 8 Zeichen';

  @override
  String get checkRegisterFields => 'Token und Name ausfüllen';

  @override
  String get registerFailed => 'Registrierung fehlgeschlagen';

  @override
  String get invalidInvite => 'Einladung ungültig oder bereits verwendet';

  @override
  String get emailTaken => 'Diese E-Mail ist bereits registriert';

  @override
  String get backToLogin => 'Zur Anmeldung';

  @override
  String get inviteUser => 'Einladen';

  @override
  String get inviteSent => 'Einladung gesendet. Token:';

  @override
  String get copyToken => 'Token kopieren';

  @override
  String get role => 'Rolle';

  @override
  String get noRoles => 'Keine Rollen';

  @override
  String get cancelTooLate =>
      'Zu spät zum Stornieren — innerhalb der Studiofrist';

  @override
  String get notCancellable =>
      'Diese Buchung kann nicht storniert werden (bereits eingecheckt)';

  @override
  String get cancelFailed => 'Abmeldung vom Kurs fehlgeschlagen';
}
