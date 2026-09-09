// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get loginFailed => 'E-mail ou mot de passe incorrect';

  @override
  String get schedule => 'Planning';

  @override
  String get cabinet => 'Espace';

  @override
  String get clients => 'Clients';

  @override
  String get roles => 'Rôles';

  @override
  String get book => 'Réserver';

  @override
  String get cancel => 'Annuler la réservation';

  @override
  String get checkIn => 'Présent';

  @override
  String get logout => 'Déconnexion';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get dismiss => 'Annuler';

  @override
  String get retry => 'Réessayer';

  @override
  String get language => 'Langue';

  @override
  String get languageTitle => 'Langue de l’application';

  @override
  String get createRole => 'Créer un rôle';

  @override
  String get profilePage => 'Page personnelle';

  @override
  String remainingVisits(int count) {
    return 'Visites restantes : $count';
  }

  @override
  String get myBookings => 'Mes réservations';

  @override
  String get noUpcomingBookings => 'Aucune réservation à venir';

  @override
  String get statusBooked => 'Réservé';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get balanceHistory => 'Historique du solde';

  @override
  String get sessionFallback => 'Cours';

  @override
  String get newSession => 'Nouveau cours';

  @override
  String get editSession => 'Modifier le cours';

  @override
  String get scheduleLoadFailed => 'Impossible de charger le planning';

  @override
  String trainerLabel(String name) {
    return 'Coach : $name';
  }

  @override
  String get sessionTitle => 'Cours';

  @override
  String get noClassTypes => 'Aucun type de cours';

  @override
  String get classType => 'Type';

  @override
  String get trainer => 'Coach';

  @override
  String get noTrainer => 'Sans coach';

  @override
  String get trainerNotFound => 'Cette personne n’est pas dans le studio';

  @override
  String get date => 'Date';

  @override
  String get startTime => 'Début';

  @override
  String get durationMin => 'Durée, min';

  @override
  String get room => 'Salle';

  @override
  String get capacity => 'Capacité';

  @override
  String bookedCount(int count) {
    return 'Réservés : $count';
  }

  @override
  String get checkSessionFields => 'Vérifiez le type, la durée et la capacité';

  @override
  String capacityBelowBooked(int count) {
    return 'La capacité est inférieure aux réservations ($count)';
  }

  @override
  String get capacityBelowBookedShort =>
      'La capacité est inférieure aux réservations';

  @override
  String get deleteSessionTitle => 'Supprimer ce cours ?';

  @override
  String get deleteSessionMessage =>
      'Le créneau quittera le planning. Annulez d’abord toutes les réservations.';

  @override
  String get sessionHasBookings =>
      'Annulez d’abord les réservations de ce cours';

  @override
  String get invalidSessionRange => 'La fin doit être après le début';

  @override
  String get classTypeNotFound => 'Type de cours introuvable';

  @override
  String get saveFailed => 'Enregistrement impossible';

  @override
  String get profile => 'Profil';

  @override
  String get member => 'Membre';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get choosePhoto => 'Choisir une photo';

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get deletePhotoTitle => 'Supprimer la photo ?';

  @override
  String get deletePhotoMessage => 'La photo disparaîtra du profil.';

  @override
  String get name => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneOptional => 'Téléphone (facultatif)';

  @override
  String get about => 'À propos';

  @override
  String get aboutOptional => 'À propos (facultatif)';

  @override
  String get saved => 'Enregistré';

  @override
  String get loadProfileFailed => 'Impossible de charger le profil';

  @override
  String get photoTooLarge =>
      'Fichier de plus de 512 Ko. Choisissez une photo plus petite.';

  @override
  String get photoType => 'JPEG, PNG ou WebP jusqu’à 512 Ko';

  @override
  String get deletePhotoFailed => 'Impossible de supprimer la photo';

  @override
  String get grantVisits => 'Ajouter 8 visites';

  @override
  String get visitsGranted => '8 visites ajoutées';

  @override
  String get adjustNote => 'Crédit';

  @override
  String get newRole => 'Nouveau rôle';

  @override
  String rolePermissions(String name) {
    return 'Droits : $name';
  }

  @override
  String get roleName => 'Nom';

  @override
  String get deleteRoleTitle => 'Supprimer ce rôle ?';

  @override
  String deleteRoleMessage(String name) {
    return 'Le rôle « $name » sera supprimé.';
  }

  @override
  String get defaultRoleName => 'Accueil';

  @override
  String get sessionLog => 'Historique des inscriptions';

  @override
  String get sessionLogEmpty => 'Pas encore d’entrées';

  @override
  String logBookedSelf(String name) {
    return '$name s’est inscrit';
  }

  @override
  String logCancelledSelf(String name) {
    return '$name a annulé';
  }

  @override
  String logCheckedInSelf(String name) {
    return '$name — visite pointée';
  }

  @override
  String logBooked(String actor, String target) {
    return '$actor a inscrit : $target';
  }

  @override
  String logCancelledOther(String actor, String target) {
    return '$actor a retiré : $target';
  }

  @override
  String logCheckedIn(String actor, String target) {
    return '$actor a pointé : $target';
  }

  @override
  String get cancelOtherTitle => 'Retirer du cours ?';

  @override
  String cancelOtherMessage(String name) {
    return '$name sera retiré de ce cours.';
  }

  @override
  String get commentOptional => 'Commentaire (facultatif)';

  @override
  String get register => 'Inscription';

  @override
  String get registerHint => 'Il faut le jeton de l’e-mail d’invitation.';

  @override
  String get inviteToken => 'Jeton d’invitation';

  @override
  String get confirmPassword => 'Mot de passe encore';

  @override
  String get passwordsMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordMinLength => 'Mot de passe : 8 caractères minimum';

  @override
  String get checkRegisterFields => 'Saisissez le jeton et le nom';

  @override
  String get registerFailed => 'Inscription impossible';

  @override
  String get invalidInvite => 'Invitation invalide ou déjà utilisée';

  @override
  String get emailTaken => 'Cet e-mail est déjà inscrit';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get inviteUser => 'Inviter';

  @override
  String get inviteSent => 'Invitation envoyée. Jeton :';

  @override
  String get copyToken => 'Copier le jeton';

  @override
  String get role => 'Rôle';

  @override
  String get noRoles => 'Aucun rôle';

  @override
  String get cancelTooLate =>
      'Trop tard pour annuler — dans le délai du studio';

  @override
  String get notCancellable =>
      'Cette réservation ne peut pas être annulée (déjà pointée)';

  @override
  String get cancelFailed => 'Impossible de retirer du cours';

  @override
  String get permGroupSchedule => 'Planning';

  @override
  String get permGroupBooking => 'Réservation';

  @override
  String get permGroupClients => 'Clients';

  @override
  String get permGroupLedger => 'Solde';

  @override
  String get permGroupRoles => 'Rôles';

  @override
  String get rolesLoadFailed => 'Impossible de charger les rôles';

  @override
  String get lastManageRoles =>
      'Le studio doit garder au moins un droit de gestion des rôles';

  @override
  String get roleInUse => 'Ce rôle est attribué à des utilisateurs';

  @override
  String get createRoleNeedPermission => 'Cochez au moins un droit';
}
