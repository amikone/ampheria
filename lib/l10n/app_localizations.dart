import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get loginWithApple;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your emails to confirm your account'**
  String get verifyEmail;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found.'**
  String get profileNotFound;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noDescription;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @closeProfile.
  ///
  /// In en, this message translates to:
  /// **'Close profile'**
  String get closeProfile;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @notSpecifiedFeminine.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecifiedFeminine;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get ageYears;

  /// No description provided for @unknownAge.
  ///
  /// In en, this message translates to:
  /// **'Unknown age'**
  String get unknownAge;

  /// No description provided for @reportProfile.
  ///
  /// In en, this message translates to:
  /// **'Report this profile'**
  String get reportProfile;

  /// No description provided for @reportReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please indicate the reason for your report:'**
  String get reportReasonPrompt;

  /// No description provided for @reportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Fake profile, behavior...'**
  String get reportReasonHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @profileReportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'The profile has been reported.'**
  String get profileReportedSuccess;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get navPeople;

  /// No description provided for @navLike.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get navLike;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get navHealth;

  /// No description provided for @incompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Profile'**
  String get incompleteProfileTitle;

  /// No description provided for @incompleteProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to unlock all features and meet great people.'**
  String get incompleteProfileDesc;

  /// No description provided for @completeMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete my profile'**
  String get completeMyProfile;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get genericError;

  /// No description provided for @phoneBannedError.
  ///
  /// In en, this message translates to:
  /// **'This phone number is banned from the platform.'**
  String get phoneBannedError;

  /// No description provided for @phoneCheckError.
  ///
  /// In en, this message translates to:
  /// **'Error verifying the phone number.'**
  String get phoneCheckError;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the required fields to continue.'**
  String get fillRequiredFields;

  /// No description provided for @phoneAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already linked to another account.'**
  String get phoneAlreadyInUse;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get to know you'**
  String get step1Title;

  /// No description provided for @step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get step1Subtitle;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your first name'**
  String get firstNameHint;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'A bit more about you'**
  String get step2Title;

  /// No description provided for @step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to sign up.'**
  String get step2Subtitle;

  /// No description provided for @birthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDateHint;

  /// No description provided for @yourGender.
  ///
  /// In en, this message translates to:
  /// **'Your gender'**
  String get yourGender;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get step3Title;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'To meet people around you.'**
  String get step3Subtitle;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Your city'**
  String get cityHint;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get step4Title;

  /// No description provided for @step4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — you can add it later.'**
  String get step4Subtitle;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @savedFormat.
  ///
  /// In en, this message translates to:
  /// **'Saved format:'**
  String get savedFormat;

  /// No description provided for @countryFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFrance;

  /// No description provided for @countryBelgium.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get countryBelgium;

  /// No description provided for @countrySwitzerland.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get countrySwitzerland;

  /// No description provided for @countryLuxembourg.
  ///
  /// In en, this message translates to:
  /// **'Luxembourg'**
  String get countryLuxembourg;

  /// No description provided for @countryCanada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get countryCanada;

  /// No description provided for @countryUSA.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUSA;

  /// No description provided for @countryUK.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryUK;

  /// No description provided for @countryGermany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get countryGermany;

  /// No description provided for @countrySpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get countrySpain;

  /// No description provided for @countryItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get countryItaly;

  /// No description provided for @countryPortugal.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get countryPortugal;

  /// No description provided for @countryMorocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get countryMorocco;

  /// No description provided for @countryAlgeria.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get countryAlgeria;

  /// No description provided for @countryTunisia.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get countryTunisia;

  /// No description provided for @maxPhotosError.
  ///
  /// In en, this message translates to:
  /// **'You cannot have more than 8 photos.'**
  String get maxPhotosError;

  /// No description provided for @imageTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'Image exceeds 2 MB'**
  String get imageTooLargeError;

  /// No description provided for @imageAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image added!'**
  String get imageAddedSuccess;

  /// No description provided for @photoDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeletedSuccess;

  /// No description provided for @photoDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting:'**
  String get photoDeleteError;

  /// No description provided for @tagAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding tag:'**
  String get tagAddError;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters required'**
  String get passwordMinLengthError;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDoNotMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchError;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get validate;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action is irreversible and your phone number will be blocked from future registrations.'**
  String get deleteAccountWarning;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been permanently deleted.'**
  String get accountDeletedSuccess;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @aboutMeTitle.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get aboutMeTitle;

  /// No description provided for @aboutMeHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself...'**
  String get aboutMeHint;

  /// No description provided for @myPassionsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Passions'**
  String get myPassionsTitle;

  /// No description provided for @passionsDescription.
  ///
  /// In en, this message translates to:
  /// **'The algorithm uses your passions to find the best profiles for you.'**
  String get passionsDescription;

  /// No description provided for @followersCount.
  ///
  /// In en, this message translates to:
  /// **'follower(s)'**
  String get followersCount;

  /// No description provided for @passionsHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Climbing, Korean cinema...'**
  String get passionsHint;

  /// No description provided for @myPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'My photos'**
  String get myPhotosTitle;

  /// No description provided for @datingPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dating preferences'**
  String get datingPreferencesTitle;

  /// No description provided for @myOrientationLabel.
  ///
  /// In en, this message translates to:
  /// **'My sexual orientation'**
  String get myOrientationLabel;

  /// No description provided for @displayedOnPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Displayed on your public profile'**
  String get displayedOnPublicProfile;

  /// No description provided for @iWantToMeetLabel.
  ///
  /// In en, this message translates to:
  /// **'I want to meet'**
  String get iWantToMeetLabel;

  /// No description provided for @usedByAlgorithmForProfiles.
  ///
  /// In en, this message translates to:
  /// **'Used by the algorithm to show you profiles'**
  String get usedByAlgorithmForProfiles;

  /// No description provided for @ageRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get ageRangeLabel;

  /// No description provided for @maxDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum distance'**
  String get maxDistanceLabel;

  /// No description provided for @applySuggestionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Apply suggestion:'**
  String get applySuggestionPrompt;

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get distanceKm;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPending;

  /// No description provided for @verificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Your account has not been validated yet. We verify accounts as quickly as possible to prevent bots. This should take about 24 hours. Feel free to complete your profile to speed up the process.'**
  String get verificationDescription;

  /// No description provided for @noMoreProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noMoreProfilesTitle;

  /// No description provided for @noMoreProfilesDesc.
  ///
  /// In en, this message translates to:
  /// **'Come back later to discover new people in your area.'**
  String get noMoreProfilesDesc;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get searchAgain;

  /// No description provided for @swipeLike.
  ///
  /// In en, this message translates to:
  /// **'LIKE'**
  String get swipeLike;

  /// No description provided for @swipeNope.
  ///
  /// In en, this message translates to:
  /// **'NOPE'**
  String get swipeNope;

  /// No description provided for @likeRejected.
  ///
  /// In en, this message translates to:
  /// **'❌ Like rejected'**
  String get likeRejected;

  /// No description provided for @likeBackSuccess.
  ///
  /// In en, this message translates to:
  /// **'💖 You liked this person back'**
  String get likeBackSuccess;

  /// No description provided for @receivedLikesTitle.
  ///
  /// In en, this message translates to:
  /// **'Received Likes'**
  String get receivedLikesTitle;

  /// No description provided for @noLikesYet.
  ///
  /// In en, this message translates to:
  /// **'No likes yet 😢'**
  String get noLikesYet;

  /// No description provided for @donationThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your donation! ❤️'**
  String get donationThanks;

  /// No description provided for @chooseAmount.
  ///
  /// In en, this message translates to:
  /// **'Choose an amount'**
  String get chooseAmount;

  /// No description provided for @supportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support! ❤️'**
  String get supportThanks;

  /// No description provided for @supportAmikone.
  ///
  /// In en, this message translates to:
  /// **'Support Amikone ❤️'**
  String get supportAmikone;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @goalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Goal: '**
  String get goalPrefix;

  /// No description provided for @paymentServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The payment service is currently unavailable.'**
  String get paymentServiceUnavailable;

  /// No description provided for @supportAction.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportAction;

  /// No description provided for @matchDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Match successfully deleted.'**
  String get matchDeletedSuccess;

  /// No description provided for @matchDeleteErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the match. Please try again.'**
  String get matchDeleteErrorRetry;

  /// No description provided for @myChatsTitle.
  ///
  /// In en, this message translates to:
  /// **'My chats'**
  String get myChatsTitle;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no conversations yet'**
  String get noConversationsYet;

  /// No description provided for @deleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get deleteMessageTitle;

  /// No description provided for @irreversibleAction.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.'**
  String get irreversibleAction;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this match?'**
  String get deleteMatchTitle;

  /// No description provided for @deleteMatchWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. You will no longer be able to chat with this person.'**
  String get deleteMatchWarning;

  /// No description provided for @matchDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting the match.'**
  String get matchDeleteError;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @deleteMatchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete match'**
  String get deleteMatchTooltip;
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
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
