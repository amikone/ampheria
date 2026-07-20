// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get or => 'OR';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get noAccount => 'Don\'t have an account? Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get loginWithApple => 'Login with Apple';

  @override
  String get verifyEmail => 'Check your emails to confirm your account';

  @override
  String get profileNotFound => 'Profile not found.';

  @override
  String get about => 'About';

  @override
  String get noDescription => 'No description.';

  @override
  String get interests => 'Interests';

  @override
  String get closeProfile => 'Close profile';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get notSpecifiedFeminine => 'Not specified';

  @override
  String get ageYears => 'years';

  @override
  String get unknownAge => 'Unknown age';

  @override
  String get reportProfile => 'Report this profile';

  @override
  String get reportReasonPrompt =>
      'Please indicate the reason for your report:';

  @override
  String get reportReasonHint => 'Fake profile, behavior...';

  @override
  String get cancel => 'Cancel';

  @override
  String get report => 'Report';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get profileReportedSuccess => 'The profile has been reported.';

  @override
  String get defaultUserName => 'User';

  @override
  String get navPeople => 'People';

  @override
  String get navLike => 'Likes';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navHealth => 'Health';

  @override
  String get incompleteProfileTitle => 'Incomplete Profile';

  @override
  String get incompleteProfileDesc =>
      'Complete your profile to unlock all features and meet great people.';

  @override
  String get completeMyProfile => 'Complete my profile';

  @override
  String get genericError => 'An error occurred.';

  @override
  String get phoneBannedError =>
      'This phone number is banned from the platform.';

  @override
  String get phoneCheckError => 'Error verifying the phone number.';

  @override
  String get fillRequiredFields =>
      'Please fill in the required fields to continue.';

  @override
  String get phoneAlreadyInUse =>
      'This phone number is already linked to another account.';

  @override
  String get step1Title => 'Let\'s get to know you';

  @override
  String get step1Subtitle => 'What should we call you?';

  @override
  String get firstNameHint => 'Your first name';

  @override
  String get step2Title => 'A bit more about you';

  @override
  String get step2Subtitle => 'You must be at least 18 years old to sign up.';

  @override
  String get birthDateHint => 'Date of birth';

  @override
  String get yourGender => 'Your gender';

  @override
  String get step3Title => 'Where are you?';

  @override
  String get step3Subtitle => 'To meet people around you.';

  @override
  String get cityHint => 'Your city';

  @override
  String get step4Title => 'Your phone number';

  @override
  String get step4Subtitle => 'Optional — you can add it later.';

  @override
  String get finish => 'Finish';

  @override
  String get continueAction => 'Continue';

  @override
  String get savedFormat => 'Saved format:';

  @override
  String get countryFrance => 'France';

  @override
  String get countryBelgium => 'Belgium';

  @override
  String get countrySwitzerland => 'Switzerland';

  @override
  String get countryLuxembourg => 'Luxembourg';

  @override
  String get countryCanada => 'Canada';

  @override
  String get countryUSA => 'United States';

  @override
  String get countryUK => 'United Kingdom';

  @override
  String get countryGermany => 'Germany';

  @override
  String get countrySpain => 'Spain';

  @override
  String get countryItaly => 'Italy';

  @override
  String get countryPortugal => 'Portugal';

  @override
  String get countryMorocco => 'Morocco';

  @override
  String get countryAlgeria => 'Algeria';

  @override
  String get countryTunisia => 'Tunisia';

  @override
  String get maxPhotosError => 'You cannot have more than 8 photos.';

  @override
  String get imageTooLargeError => 'Image exceeds 2 MB';

  @override
  String get imageAddedSuccess => 'Image added!';

  @override
  String get photoDeletedSuccess => 'Photo deleted';

  @override
  String get photoDeleteError => 'Error deleting:';

  @override
  String get tagAddError => 'Error adding tag:';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get passwordMinLengthError => 'At least 6 characters required';

  @override
  String get confirmPasswordLabel => 'Confirm';

  @override
  String get passwordsDoNotMatchError => 'Passwords do not match';

  @override
  String get validate => 'Submit';

  @override
  String get passwordUpdatedSuccess => 'Password updated!';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'Are you sure you want to permanently delete your account? This action is irreversible and your phone number will be blocked from future registrations.';

  @override
  String get accountDeletedSuccess =>
      'Your account has been permanently deleted.';

  @override
  String get confirm => 'Confirm';

  @override
  String get aboutMeTitle => 'About me';

  @override
  String get aboutMeHint => 'Tell us a bit about yourself...';

  @override
  String get myPassionsTitle => 'My Passions';

  @override
  String get passionsDescription =>
      'The algorithm uses your passions to find the best profiles for you.';

  @override
  String get followersCount => 'follower(s)';

  @override
  String get passionsHint => 'E.g.: Climbing, Korean cinema...';

  @override
  String get myPhotosTitle => 'My photos';

  @override
  String get datingPreferencesTitle => 'Dating preferences';

  @override
  String get myOrientationLabel => 'My sexual orientation';

  @override
  String get displayedOnPublicProfile => 'Displayed on your public profile';

  @override
  String get iWantToMeetLabel => 'I want to meet';

  @override
  String get usedByAlgorithmForProfiles =>
      'Used by the algorithm to show you profiles';

  @override
  String get ageRangeLabel => 'Age range';

  @override
  String get maxDistanceLabel => 'Maximum distance';

  @override
  String get applySuggestionPrompt => 'Apply suggestion:';

  @override
  String get ignore => 'Ignore';

  @override
  String get apply => 'Apply';

  @override
  String get profileTitle => 'Profile';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get logout => 'Log out';

  @override
  String get distanceKm => 'km';

  @override
  String get viewProfile => 'View profile';

  @override
  String get verificationPending => 'Verification pending';

  @override
  String get verificationDescription =>
      'Your account has not been validated yet. We verify accounts as quickly as possible to prevent bots. This should take about 24 hours. Feel free to complete your profile to speed up the process.';

  @override
  String get noMoreProfilesTitle => 'You\'re all caught up!';

  @override
  String get noMoreProfilesDesc =>
      'Come back later to discover new people in your area.';

  @override
  String get searchAgain => 'Search again';

  @override
  String get swipeLike => 'LIKE';

  @override
  String get swipeNope => 'NOPE';

  @override
  String get likeRejected => '❌ Like rejected';

  @override
  String get likeBackSuccess => '💖 You liked this person back';

  @override
  String get receivedLikesTitle => 'Received Likes';

  @override
  String get noLikesYet => 'No likes yet 😢';

  @override
  String get donationThanks => 'Thank you for your donation! ❤️';

  @override
  String get chooseAmount => 'Choose an amount';

  @override
  String get supportThanks => 'Thank you for your support! ❤️';

  @override
  String get supportAmikone => 'Support Amikone ❤️';

  @override
  String get collected => 'Collected';

  @override
  String get goal => 'Goal';

  @override
  String get goalPrefix => 'Goal: ';

  @override
  String get paymentServiceUnavailable =>
      'The payment service is currently unavailable.';

  @override
  String get supportAction => 'Support';

  @override
  String get matchDeletedSuccess => 'Match successfully deleted.';

  @override
  String get matchDeleteErrorRetry =>
      'Unable to delete the match. Please try again.';

  @override
  String get myChatsTitle => 'My chats';

  @override
  String get noConversationsYet => 'You have no conversations yet';

  @override
  String get deleteMessageTitle => 'Delete this message?';

  @override
  String get irreversibleAction => 'This action is irreversible.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteMatchTitle => 'Delete this match?';

  @override
  String get deleteMatchWarning =>
      'This action is irreversible. You will no longer be able to chat with this person.';

  @override
  String get matchDeleteError => 'Error deleting the match.';

  @override
  String get me => 'Me';

  @override
  String get deleteMatchTooltip => 'Delete match';
}
