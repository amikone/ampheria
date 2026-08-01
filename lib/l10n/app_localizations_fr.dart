// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get or => 'OU';

  @override
  String error(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get noAccount => 'Pas de compte ? S\'inscrire';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get loginWithGoogle => 'Se connecter avec Google';

  @override
  String get loginWithApple => 'Se connecter avec Apple';

  @override
  String get verifyEmail => 'Vérifiez vos emails pour confirmer votre compte';

  @override
  String get profileNotFound => 'Profil introuvable.';

  @override
  String get about => 'À propos';

  @override
  String get noDescription => 'Aucune description.';

  @override
  String get interests => 'Intérêts';

  @override
  String get closeProfile => 'Fermer le profil';

  @override
  String get genderMale => 'Homme';

  @override
  String get genderFemale => 'Femme';

  @override
  String get genderOther => 'Autre';

  @override
  String get notSpecified => 'Non précisé';

  @override
  String get notSpecifiedFeminine => 'Non précisée';

  @override
  String get ageYears => 'ans';

  @override
  String get unknownAge => 'Âge inconnu';

  @override
  String get reportProfile => 'Signaler ce profil';

  @override
  String get reportReasonPrompt =>
      'Veuillez indiquer la raison de votre signalement :';

  @override
  String get reportReasonHint => 'Faux profil, comportement...';

  @override
  String get cancel => 'Annuler';

  @override
  String get report => 'Signaler';

  @override
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get profileReportedSuccess => 'Le profil a été signalé.';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get navPeople => 'Rencontres';

  @override
  String get navLike => 'Likes';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get navHealth => 'Santé';

  @override
  String get incompleteProfileTitle => 'Profil Incomplet';

  @override
  String get incompleteProfileDesc =>
      'Complétez votre profil pour débloquer toutes les fonctionnalités et faire de belles rencontres.';

  @override
  String get completeMyProfile => 'Compléter mon profil';

  @override
  String get genericError => 'Une erreur est survenue.';

  @override
  String get phoneBannedError =>
      'Ce numéro de téléphone est banni de la plateforme.';

  @override
  String get phoneCheckError => 'Erreur lors de la vérification du numéro.';

  @override
  String get fillRequiredFields =>
      'Veuillez remplir les champs requis pour continuer.';

  @override
  String get phoneAlreadyInUse =>
      'Ce numéro est déjà rattaché à un autre compte.';

  @override
  String get step1Title => 'Faisons connaissance';

  @override
  String get step1Subtitle => 'Comment doit-on vous appeler ?';

  @override
  String get firstNameHint => 'Votre prénom';

  @override
  String get step2Title => 'Un peu plus sur vous';

  @override
  String get step2Subtitle => 'Il faut avoir au moins 18 ans pour s\'inscrire.';

  @override
  String get birthDateHint => 'Date de naissance';

  @override
  String get yourGender => 'Votre genre';

  @override
  String get step3Title => 'Où êtes-vous ?';

  @override
  String get step3Subtitle => 'Pour rencontrer des personnes autour de vous.';

  @override
  String get cityHint => 'Votre ville';

  @override
  String get step4Title => 'Votre numéro';

  @override
  String get step4Subtitle =>
      'Optionnel — vous pourrez le renseigner plus tard.';

  @override
  String get finish => 'Terminer';

  @override
  String get continueAction => 'Continuer';

  @override
  String get savedFormat => 'Format enregistré :';

  @override
  String get countryFrance => 'France';

  @override
  String get countryBelgium => 'Belgique';

  @override
  String get countrySwitzerland => 'Suisse';

  @override
  String get countryLuxembourg => 'Luxembourg';

  @override
  String get countryCanada => 'Canada';

  @override
  String get countryUSA => 'États-Unis';

  @override
  String get countryUK => 'Royaume-Uni';

  @override
  String get countryGermany => 'Allemagne';

  @override
  String get countrySpain => 'Espagne';

  @override
  String get countryItaly => 'Italie';

  @override
  String get countryPortugal => 'Portugal';

  @override
  String get countryMorocco => 'Maroc';

  @override
  String get countryAlgeria => 'Algérie';

  @override
  String get countryTunisia => 'Tunisie';

  @override
  String get maxPhotosError => 'Vous ne pouvez pas avoir plus de 8 photos.';

  @override
  String get imageTooLargeError => 'L\'image dépasse 2 Mo';

  @override
  String get imageAddedSuccess => 'Image ajoutée !';

  @override
  String get photoDeletedSuccess => 'Photo supprimée';

  @override
  String get photoDeleteError => 'Erreur lors de la suppression :';

  @override
  String get tagAddError => 'Erreur lors de l\'ajout du tag :';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get passwordMinLengthError => 'Au moins 6 caractères requis';

  @override
  String get confirmPasswordLabel => 'Confirmer';

  @override
  String get passwordsDoNotMatchError => 'Les mots de passe diffèrent';

  @override
  String get validate => 'Valider';

  @override
  String get passwordUpdatedSuccess => 'Mot de passe mis à jour !';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountWarning =>
      'Es-tu sûr de vouloir supprimer définitivement ton compte ? Cette action est irréversible et ton numéro de téléphone sera bloqué pour de futures inscriptions.';

  @override
  String get accountDeletedSuccess =>
      'Ton compte a été définitivement supprimé.';

  @override
  String get confirm => 'Confirmer';

  @override
  String get aboutMeTitle => 'À propos de moi';

  @override
  String get aboutMeHint => 'Parle un peu de toi...';

  @override
  String get myPassionsTitle => 'Mes Passions';

  @override
  String get passionsDescription =>
      'L\'algorithme utilise tes passions pour te trouver les meilleurs profils.';

  @override
  String get followersCount => 'adepte(s)';

  @override
  String get passionsHint => 'Ex: Escalade, Cinéma coréen...';

  @override
  String get myPhotosTitle => 'Mes photos';

  @override
  String get datingPreferencesTitle => 'Préférences de rencontre';

  @override
  String get myOrientationLabel => 'Mon orientation sexuelle';

  @override
  String get displayedOnPublicProfile => 'Affiché sur ton profil public';

  @override
  String get iWantToMeetLabel => 'Je souhaite rencontrer';

  @override
  String get usedByAlgorithmForProfiles =>
      'Utilisé par l\'algorithme pour te montrer des profils';

  @override
  String get ageRangeLabel => 'Tranche d\'âge';

  @override
  String get maxDistanceLabel => 'Distance maximale';

  @override
  String get applySuggestionPrompt => 'Appliquer la suggestion :';

  @override
  String get ignore => 'Ignorer';

  @override
  String get apply => 'Appliquer';

  @override
  String get profileTitle => 'Profil';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get distanceKm => 'km';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get verificationPending => 'Vérification en cours';

  @override
  String get verificationDescription =>
      'Ton compte n’a pas encore été validé. Nous vérifions les comptes au plus vite afin d’éviter les bots. Cela devrait prendre environ 24 heures. N’hésite pas à bien compléter ton profil pour accélérer le processus.';

  @override
  String get noMoreProfilesTitle => 'Tu as fait le tour !';

  @override
  String get noMoreProfilesDesc =>
      'Reviens plus tard pour découvrir de nouvelles personnes dans ton secteur.';

  @override
  String get searchAgain => 'Chercher à nouveau';

  @override
  String get swipeLike => 'LIKE';

  @override
  String get swipeNope => 'NOPE';

  @override
  String get likeRejected => '❌ Like refusé';

  @override
  String get likeBackSuccess => '💖 Vous avez liké cette personne';

  @override
  String get receivedLikesTitle => 'Likes reçus';

  @override
  String get noLikesYet => 'Aucun like pour le moment 😢';

  @override
  String get donationThanks => 'Merci pour votre don ! ❤️';

  @override
  String get chooseAmount => 'Choisir un montant';

  @override
  String get supportThanks => 'Merci pour votre soutien ! ❤️';

  @override
  String get supportAmikone => 'Soutenir Amikone ❤️';

  @override
  String get collected => 'Collectés';

  @override
  String get goal => 'Objectif';

  @override
  String get goalPrefix => 'Objectif : ';

  @override
  String get paymentServiceUnavailable =>
      'Le service de paiement n\'est pas disponible pour le moment.';

  @override
  String get supportAction => 'Soutenir';

  @override
  String get matchDeletedSuccess => 'Match supprimé avec succès.';

  @override
  String get matchDeleteErrorRetry =>
      'Impossible de supprimer le match. Veuillez réessayer.';

  @override
  String get myChatsTitle => 'Mes chats';

  @override
  String get noConversationsYet =>
      'Tu n\'as aucune conversation pour le moment';

  @override
  String get deleteMessageTitle => 'Supprimer ce message ?';

  @override
  String get irreversibleAction => 'Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteMatchTitle => 'Supprimer ce match ?';

  @override
  String get deleteMatchWarning =>
      'Cette action est irréversible. Vous ne pourrez plus discuter avec cette personne.';

  @override
  String get matchDeleteError => 'Erreur lors de la suppression du match.';

  @override
  String get me => 'Moi';

  @override
  String get deleteMatchTooltip => 'Supprimer le match';

  @override
  String get serverPickerTitle => 'Choisir un serveur';

  @override
  String get availableServersGithub => 'Serveurs Disponibles (GitHub)';

  @override
  String get addServerManually => 'Ajouter manuellement';

  @override
  String get addServerDesc => 'Saisir URL et Publishable Key';

  @override
  String get addServerDialogTitle => 'Ajouter un serveur';

  @override
  String get serverNameLabel => 'Nom';

  @override
  String get serverUrlLabel => 'URL (https://...)';

  @override
  String get serverKeyLabel => 'Publishable Key';

  @override
  String get addAndSelect => 'Ajouter et Sélectionner';

  @override
  String get manualServerDesc => 'Serveur ajouté manuellement';

  @override
  String connectedToServer(Object name) {
    return 'Connecté à $name';
  }

  @override
  String get myIdentityTitle => 'Mon Identité';

  @override
  String get myGenderLabel => 'Mon Genre';

  @override
  String get myGenderSubtitle => 'Comment vous définissez-vous ?';

  @override
  String get myOrientationSubtitle => 'Sera affiché sur votre profil public';

  @override
  String get whoIWantToMeet => 'Qui je souhaite rencontrer';

  @override
  String get whoIWantToMeetSubtitle =>
      'Utilisé par l\'algorithme pour vous proposer des profils';

  @override
  String get identityGenre => 'Genre';

  @override
  String get identityOrientation => 'Orientation';

  @override
  String get identitySeeking => 'Je cherche';

  @override
  String get everyone => 'Tout le monde';
}
