// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcome => 'Bienvenido';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get or => 'O';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get noAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get loginWithGoogle => 'Iniciar sesión con Google';

  @override
  String get loginWithApple => 'Iniciar sesión con Apple';

  @override
  String get verifyEmail => 'Revisa tus correos para confirmar tu cuenta';

  @override
  String get profileNotFound => 'Perfil no encontrado.';

  @override
  String get about => 'Acerca de';

  @override
  String get noDescription => 'Sin descripción.';

  @override
  String get interests => 'Intereses';

  @override
  String get closeProfile => 'Cerrar perfil';

  @override
  String get genderMale => 'Hombre';

  @override
  String get genderFemale => 'Mujer';

  @override
  String get genderOther => 'Otro';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get notSpecifiedFeminine => 'No especificada';

  @override
  String get ageYears => 'años';

  @override
  String get unknownAge => 'Edad desconocida';

  @override
  String get reportProfile => 'Reportar este perfil';

  @override
  String get reportReasonPrompt => 'Por favor, indica el motivo de tu reporte:';

  @override
  String get reportReasonHint => 'Perfil falso, comportamiento...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get report => 'Reportar';

  @override
  String get userNotLoggedIn => 'Usuario no conectado';

  @override
  String get profileReportedSuccess => 'El perfil ha sido reportado.';

  @override
  String get defaultUserName => 'Usuario';

  @override
  String get navPeople => 'Descubrir';

  @override
  String get navLike => 'Me gusta';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navHealth => 'Salud';

  @override
  String get incompleteProfileTitle => 'Perfil incompleto';

  @override
  String get incompleteProfileDesc =>
      'Completa tu perfil para desbloquear todas las funciones y conocer gente genial.';

  @override
  String get completeMyProfile => 'Completar mi perfil';

  @override
  String get genericError => 'Ha ocurrido un error.';

  @override
  String get phoneBannedError =>
      'Este número de teléfono está bloqueado en la plataforma.';

  @override
  String get phoneCheckError => 'Error al verificar el número.';

  @override
  String get fillRequiredFields =>
      'Por favor, completa los campos requeridos para continuar.';

  @override
  String get phoneAlreadyInUse =>
      'Este número ya está vinculado a otra cuenta.';

  @override
  String get step1Title => 'Conozcámonos';

  @override
  String get step1Subtitle => '¿Cómo deberíamos llamarte?';

  @override
  String get firstNameHint => 'Tu nombre';

  @override
  String get step2Title => 'Un poco más sobre ti';

  @override
  String get step2Subtitle => 'Debes tener al menos 18 años para registrarte.';

  @override
  String get birthDateHint => 'Fecha de nacimiento';

  @override
  String get yourGender => 'Tu género';

  @override
  String get step3Title => '¿Dónde estás?';

  @override
  String get step3Subtitle => 'Para conocer gente a tu alrededor.';

  @override
  String get cityHint => 'Tu ciudad';

  @override
  String get step4Title => 'Tu número';

  @override
  String get step4Subtitle => 'Opcional — puedes agregarlo más tarde.';

  @override
  String get finish => 'Terminar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get savedFormat => 'Formato guardado:';

  @override
  String get countryFrance => 'Francia';

  @override
  String get countryBelgium => 'Bélgica';

  @override
  String get countrySwitzerland => 'Suiza';

  @override
  String get countryLuxembourg => 'Luxemburgo';

  @override
  String get countryCanada => 'Canadá';

  @override
  String get countryUSA => 'Estados Unidos';

  @override
  String get countryUK => 'Reino Unido';

  @override
  String get countryGermany => 'Alemania';

  @override
  String get countrySpain => 'España';

  @override
  String get countryItaly => 'Italia';

  @override
  String get countryPortugal => 'Portugal';

  @override
  String get countryMorocco => 'Marruecos';

  @override
  String get countryAlgeria => 'Argelia';

  @override
  String get countryTunisia => 'Túnez';

  @override
  String get maxPhotosError => 'No puedes tener más de 8 fotos.';

  @override
  String get imageTooLargeError => 'La imagen supera los 2 MB';

  @override
  String get imageAddedSuccess => '¡Imagen añadida!';

  @override
  String get photoDeletedSuccess => 'Foto eliminada';

  @override
  String get photoDeleteError => 'Error al eliminar:';

  @override
  String get tagAddError => 'Error al añadir etiqueta:';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get passwordMinLengthError => 'Se requieren al menos 6 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar';

  @override
  String get passwordsDoNotMatchError => 'Las contraseñas no coinciden';

  @override
  String get validate => 'Validar';

  @override
  String get passwordUpdatedSuccess => '¡Contraseña actualizada!';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountWarning =>
      '¿Estás seguro de que quieres eliminar tu cuenta permanentemente? Esta acción es irreversible y tu número de teléfono será bloqueado para futuros registros.';

  @override
  String get accountDeletedSuccess =>
      'Tu cuenta ha sido eliminada permanentemente.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get aboutMeTitle => 'Acerca de mí';

  @override
  String get aboutMeHint => 'Cuéntanos un poco sobre ti...';

  @override
  String get myPassionsTitle => 'Mis pasiones';

  @override
  String get passionsDescription =>
      'El algoritmo usa tus pasiones para encontrarte los mejores perfiles.';

  @override
  String get followersCount => 'seguidor(es)';

  @override
  String get passionsHint => 'Ej.: Escalada, Cine coreano...';

  @override
  String get myPhotosTitle => 'Mis fotos';

  @override
  String get datingPreferencesTitle => 'Preferencias de citas';

  @override
  String get myOrientationLabel => 'Mi orientación sexual';

  @override
  String get displayedOnPublicProfile => 'Mostrado en tu perfil público';

  @override
  String get iWantToMeetLabel => 'Quiero conocer a';

  @override
  String get usedByAlgorithmForProfiles =>
      'Usado por el algoritmo para mostrarte perfiles';

  @override
  String get ageRangeLabel => 'Rango de edad';

  @override
  String get maxDistanceLabel => 'Distancia máxima';

  @override
  String get applySuggestionPrompt => 'Aplicar sugerencia:';

  @override
  String get ignore => 'Ignorar';

  @override
  String get apply => 'Aplicar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get deleteMyAccount => 'Eliminar mi cuenta';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get distanceKm => 'km';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get verificationPending => 'Verificación pendiente';

  @override
  String get verificationDescription =>
      'Tu cuenta aún no ha sido validada. Verificamos las cuentas lo más rápido posible para evitar bots. Esto debería tomar unas 24 horas. No dudes en completar tu perfil para acelerar el proceso.';

  @override
  String get noMoreProfilesTitle => '¡Estás al día!';

  @override
  String get noMoreProfilesDesc =>
      'Vuelve más tarde para descubrir gente nueva en tu área.';

  @override
  String get searchAgain => 'Buscar de nuevo';

  @override
  String get swipeLike => 'LIKE';

  @override
  String get swipeNope => 'NOPE';

  @override
  String get likeRejected => '❌ Like rechazado';

  @override
  String get likeBackSuccess => '💖 Le has dado like a esta persona';

  @override
  String get receivedLikesTitle => 'Likes recibidos';

  @override
  String get noLikesYet => 'Aún no hay likes 😢';

  @override
  String get donationThanks => '¡Gracias por tu donación! ❤️';

  @override
  String get chooseAmount => 'Elige una cantidad';

  @override
  String get supportThanks => '¡Gracias por tu apoyo! ❤️';

  @override
  String get supportAmikone => 'Apoyar a Amikone ❤️';

  @override
  String get collected => 'Recaudado';

  @override
  String get goal => 'Objetivo';

  @override
  String get goalPrefix => 'Objetivo: ';

  @override
  String get paymentServiceUnavailable =>
      'El servicio de pago no está disponible en este momento.';

  @override
  String get supportAction => 'Apoyar';

  @override
  String get matchDeletedSuccess => 'Match eliminado con éxito.';

  @override
  String get matchDeleteErrorRetry =>
      'No se pudo eliminar el match. Por favor, inténtalo de nuevo.';

  @override
  String get myChatsTitle => 'Mis chats';

  @override
  String get noConversationsYet => 'Aún no tienes conversaciones';

  @override
  String get deleteMessageTitle => '¿Eliminar este mensaje?';

  @override
  String get irreversibleAction => 'Esta acción es irreversible.';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteMatchTitle => '¿Eliminar este match?';

  @override
  String get deleteMatchWarning =>
      'Esta acción es irreversible. Ya no podrás chatear con esta persona.';

  @override
  String get matchDeleteError => 'Error al eliminar el match.';

  @override
  String get me => 'Yo';

  @override
  String get deleteMatchTooltip => 'Eliminar match';

  @override
  String get serverPickerTitle => 'Elegir un servidor';

  @override
  String get availableServersGithub => 'Servidores Disponibles (GitHub)';

  @override
  String get addServerManually => 'Añadir manualmente';

  @override
  String get addServerDesc => 'Ingresar URL y Publishable Key';

  @override
  String get addServerDialogTitle => 'Añadir un servidor';

  @override
  String get serverNameLabel => 'Nombre';

  @override
  String get serverUrlLabel => 'URL (https://...)';

  @override
  String get serverKeyLabel => 'Publishable Key';

  @override
  String get addAndSelect => 'Añadir y Seleccionar';

  @override
  String get manualServerDesc => 'Servidor añadido manualmente';

  @override
  String connectedToServer(Object name) {
    return 'Conectado a $name';
  }

  @override
  String get myIdentityTitle => 'Mi Identidad';

  @override
  String get myGenderLabel => 'Mi Género';

  @override
  String get myGenderSubtitle => '¿Cómo te defines?';

  @override
  String get myOrientationSubtitle => 'Se mostrará en tu perfil público';

  @override
  String get whoIWantToMeet => 'A quién quiero conocer';

  @override
  String get whoIWantToMeetSubtitle =>
      'Utilizado por el algoritmo para sugerir perfiles';

  @override
  String get identityGenre => 'Género';

  @override
  String get identityOrientation => 'Orientación';

  @override
  String get identitySeeking => 'Buscando';

  @override
  String get everyone => 'Todos';
}
