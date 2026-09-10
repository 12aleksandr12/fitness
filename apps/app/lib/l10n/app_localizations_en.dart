// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitness';

  @override
  String get login => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginFailed => 'Wrong email or password';

  @override
  String get schedule => 'Schedule';

  @override
  String get cabinet => 'Home';

  @override
  String get clients => 'Clients';

  @override
  String get roles => 'Roles';

  @override
  String get book => 'Book';

  @override
  String get cancel => 'Cancel booking';

  @override
  String get checkIn => 'Checked in';

  @override
  String get logout => 'Log out';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get dismiss => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get language => 'Language';

  @override
  String get languageTitle => 'App language';

  @override
  String get createRole => 'Create role';

  @override
  String get profilePage => 'Your page';

  @override
  String remainingVisits(int count) {
    return 'Visits left: $count';
  }

  @override
  String get myBookings => 'My bookings';

  @override
  String get noUpcomingBookings => 'No upcoming bookings';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get balanceHistory => 'Balance history';

  @override
  String get sessionFallback => 'Class';

  @override
  String get newSession => 'New class';

  @override
  String get editSession => 'Edit class';

  @override
  String get scheduleLoadFailed => 'Could not load the schedule';

  @override
  String trainerLabel(String name) {
    return 'Trainer: $name';
  }

  @override
  String get sessionTitle => 'Class';

  @override
  String get noClassTypes => 'No class types';

  @override
  String get classType => 'Type';

  @override
  String get trainer => 'Trainer';

  @override
  String get noTrainer => 'No trainer';

  @override
  String get trainerNotFound => 'This person is not in the studio';

  @override
  String get date => 'Date';

  @override
  String get startTime => 'Start';

  @override
  String get durationMin => 'Duration, min';

  @override
  String get room => 'Room';

  @override
  String get capacity => 'Capacity';

  @override
  String bookedCount(int count) {
    return 'Booked: $count';
  }

  @override
  String get checkSessionFields => 'Check type, duration and capacity';

  @override
  String capacityBelowBooked(int count) {
    return 'Capacity is below booked spots ($count)';
  }

  @override
  String get capacityBelowBookedShort => 'Capacity is below booked spots';

  @override
  String get deleteSessionTitle => 'Delete this class?';

  @override
  String get deleteSessionMessage =>
      'The slot will leave the schedule. Cancel all bookings first.';

  @override
  String get sessionHasBookings => 'Cancel bookings for this class first';

  @override
  String get invalidSessionRange => 'End time must be after start';

  @override
  String get classTypeNotFound => 'Class type not found';

  @override
  String get saveFailed => 'Could not save';

  @override
  String get profile => 'Profile';

  @override
  String get member => 'Member';

  @override
  String get noData => 'No data';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get deletePhotoTitle => 'Delete photo?';

  @override
  String get deletePhotoMessage =>
      'The photo will be removed from the profile.';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get about => 'About';

  @override
  String get aboutOptional => 'About (optional)';

  @override
  String get saved => 'Saved';

  @override
  String get loadProfileFailed => 'Could not load the profile';

  @override
  String get photoTooLarge =>
      'File is larger than 512 KB. Choose a smaller photo.';

  @override
  String get photoType => 'Use JPEG, PNG or WebP up to 512 KB';

  @override
  String get deletePhotoFailed => 'Could not delete the photo';

  @override
  String get grantVisits => 'Add 8 visits';

  @override
  String get visitsGranted => 'Added 8 visits';

  @override
  String get adjustNote => 'Credit';

  @override
  String get newRole => 'New role';

  @override
  String rolePermissions(String name) {
    return 'Permissions: $name';
  }

  @override
  String get roleName => 'Name';

  @override
  String get deleteRoleTitle => 'Delete this role?';

  @override
  String deleteRoleMessage(String name) {
    return 'The role “$name” will be deleted.';
  }

  @override
  String get defaultRoleName => 'Reception';

  @override
  String get sessionLog => 'Booking history';

  @override
  String get sessionLogEmpty => 'No entries yet';

  @override
  String logBookedSelf(String name) {
    return '$name booked';
  }

  @override
  String logCancelledSelf(String name) {
    return '$name cancelled';
  }

  @override
  String logCheckedInSelf(String name) {
    return '$name — visit marked';
  }

  @override
  String logBooked(String actor, String target) {
    return '$actor booked: $target';
  }

  @override
  String logCancelledOther(String actor, String target) {
    return '$actor removed: $target';
  }

  @override
  String logCheckedIn(String actor, String target) {
    return '$actor checked in: $target';
  }

  @override
  String get cancelOtherTitle => 'Remove from class?';

  @override
  String cancelOtherMessage(String name) {
    return '$name will be removed from this class.';
  }

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get register => 'Register';

  @override
  String get registerHint => 'You need the token from the invite email.';

  @override
  String get inviteToken => 'Invite token';

  @override
  String get confirmPassword => 'Password again';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get checkRegisterFields => 'Enter the token and a name';

  @override
  String get registerFailed => 'Could not register';

  @override
  String get invalidInvite => 'This invite is invalid or already used';

  @override
  String get emailTaken => 'This email is already registered';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get inviteUser => 'Invite';

  @override
  String get inviteSent => 'Invite sent. Token:';

  @override
  String get copyToken => 'Copy token';

  @override
  String get role => 'Role';

  @override
  String get noRoles => 'No roles';

  @override
  String get cancelTooLate => 'Too late to cancel — inside the studio window';

  @override
  String get notCancellable =>
      'This booking cannot be cancelled (already checked in)';

  @override
  String get cancelFailed => 'Could not remove from the class';

  @override
  String get permGroupSchedule => 'Schedule';

  @override
  String get permGroupBooking => 'Booking';

  @override
  String get permGroupClients => 'Clients';

  @override
  String get permGroupLedger => 'Balance';

  @override
  String get permGroupRoles => 'Roles';

  @override
  String get rolesLoadFailed => 'Could not load roles';

  @override
  String get lastManageRoles =>
      'The studio must keep at least one manage_roles grant';

  @override
  String get roleInUse => 'This role is assigned to users';

  @override
  String get createRoleNeedPermission => 'Select at least one permission';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get youAreBooked => 'You\'re booked';

  @override
  String get noSpots => 'No spots';

  @override
  String occupancyRatio(int booked, int capacity) {
    return '$booked/$capacity';
  }
}
