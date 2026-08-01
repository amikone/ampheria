// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get welcome => '환영합니다';

  @override
  String get signInToContinue => '계속하려면 로그인하세요';

  @override
  String get or => '또는';

  @override
  String error(Object error) {
    return '오류: $error';
  }

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get signIn => '로그인';

  @override
  String get signUp => '가입하기';

  @override
  String get noAccount => '계정이 없으신가요? 가입하기';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요? 로그인';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get loginWithApple => 'Apple로 로그인';

  @override
  String get verifyEmail => '이메일을 확인하여 계정을 인증해주세요';

  @override
  String get profileNotFound => '프로필을 찾을 수 없습니다.';

  @override
  String get about => '소개';

  @override
  String get noDescription => '설명이 없습니다.';

  @override
  String get interests => '관심사';

  @override
  String get closeProfile => '프로필 닫기';

  @override
  String get genderMale => '남성';

  @override
  String get genderFemale => '여성';

  @override
  String get genderOther => '기타';

  @override
  String get notSpecified => '지정되지 않음';

  @override
  String get notSpecifiedFeminine => '지정되지 않음';

  @override
  String get ageYears => '세';

  @override
  String get unknownAge => '나이 알 수 없음';

  @override
  String get reportProfile => '이 프로필 신고하기';

  @override
  String get reportReasonPrompt => '신고 사유를 입력해주세요:';

  @override
  String get reportReasonHint => '가짜 프로필, 부적절한 행동...';

  @override
  String get cancel => '취소';

  @override
  String get report => '신고하기';

  @override
  String get userNotLoggedIn => '로그인되지 않은 사용자';

  @override
  String get profileReportedSuccess => '프로필이 신고되었습니다.';

  @override
  String get defaultUserName => '사용자';

  @override
  String get navPeople => '둘러보기';

  @override
  String get navLike => '좋아요';

  @override
  String get navChat => '채팅';

  @override
  String get navProfile => '프로필';

  @override
  String get navHealth => '건강';

  @override
  String get incompleteProfileTitle => '미완성 프로필';

  @override
  String get incompleteProfileDesc => '모든 기능을 잠금 해제하고 멋진 사람들을 만나려면 프로필을 완성하세요.';

  @override
  String get completeMyProfile => '내 프로필 완성하기';

  @override
  String get genericError => '오류가 발생했습니다.';

  @override
  String get phoneBannedError => '이 전화번호는 플랫폼에서 차단되었습니다.';

  @override
  String get phoneCheckError => '번호 확인 중 오류가 발생했습니다.';

  @override
  String get fillRequiredFields => '계속하려면 필수 항목을 입력해주세요.';

  @override
  String get phoneAlreadyInUse => '이 번호는 이미 다른 계정에 연결되어 있습니다.';

  @override
  String get step1Title => '알아가기';

  @override
  String get step1Subtitle => '어떻게 불러드릴까요?';

  @override
  String get firstNameHint => '이름';

  @override
  String get step2Title => '조금 더 알려주세요';

  @override
  String get step2Subtitle => '가입하려면 만 18세 이상이어야 합니다.';

  @override
  String get birthDateHint => '생년월일';

  @override
  String get yourGender => '성별';

  @override
  String get step3Title => '어디에 계신가요?';

  @override
  String get step3Subtitle => '주변 사람들을 만나기 위해 필요합니다.';

  @override
  String get cityHint => '거주 도시';

  @override
  String get step4Title => '전화번호';

  @override
  String get step4Subtitle => '선택 사항 — 나중에 추가할 수 있습니다.';

  @override
  String get finish => '완료';

  @override
  String get continueAction => '계속';

  @override
  String get savedFormat => '저장된 형식:';

  @override
  String get countryFrance => '프랑스';

  @override
  String get countryBelgium => '벨기에';

  @override
  String get countrySwitzerland => '스위스';

  @override
  String get countryLuxembourg => '룩셈부르크';

  @override
  String get countryCanada => '캐나다';

  @override
  String get countryUSA => '미국';

  @override
  String get countryUK => '영국';

  @override
  String get countryGermany => '독일';

  @override
  String get countrySpain => '스페인';

  @override
  String get countryItaly => '이탈리아';

  @override
  String get countryPortugal => '포르투갈';

  @override
  String get countryMorocco => '모로코';

  @override
  String get countryAlgeria => '알제리';

  @override
  String get countryTunisia => '튀니지';

  @override
  String get maxPhotosError => '사진은 8장까지만 올릴 수 있습니다.';

  @override
  String get imageTooLargeError => '이미지가 2MB를 초과합니다';

  @override
  String get imageAddedSuccess => '이미지가 추가되었습니다!';

  @override
  String get photoDeletedSuccess => '사진이 삭제되었습니다';

  @override
  String get photoDeleteError => '삭제 중 오류 발생:';

  @override
  String get tagAddError => '태그 추가 중 오류 발생:';

  @override
  String get changePasswordTitle => '비밀번호 변경';

  @override
  String get newPasswordLabel => '새 비밀번호';

  @override
  String get passwordMinLengthError => '최소 6자 이상이어야 합니다';

  @override
  String get confirmPasswordLabel => '확인';

  @override
  String get passwordsDoNotMatchError => '비밀번호가 일치하지 않습니다';

  @override
  String get validate => '확인';

  @override
  String get passwordUpdatedSuccess => '비밀번호가 업데이트되었습니다!';

  @override
  String get deleteAccountTitle => '계정 삭제';

  @override
  String get deleteAccountWarning =>
      '계정을 영구적으로 삭제하시겠습니까? 이 작업은 되돌릴 수 없으며 전화번호는 향후 가입이 차단됩니다.';

  @override
  String get accountDeletedSuccess => '계정이 영구적으로 삭제되었습니다.';

  @override
  String get confirm => '확인';

  @override
  String get aboutMeTitle => '자기소개';

  @override
  String get aboutMeHint => '자신에 대해 조금 이야기해주세요...';

  @override
  String get myPassionsTitle => '나의 관심사';

  @override
  String get passionsDescription => '알고리즘이 당신의 관심사를 바탕으로 가장 잘 맞는 프로필을 찾아줍니다.';

  @override
  String get followersCount => '명의 팔로워';

  @override
  String get passionsHint => '예: 클라이밍, 한국 영화...';

  @override
  String get myPhotosTitle => '내 사진';

  @override
  String get datingPreferencesTitle => '데이트 선호도';

  @override
  String get myOrientationLabel => '나의 성적 지향';

  @override
  String get displayedOnPublicProfile => '공개 프로필에 표시됩니다';

  @override
  String get iWantToMeetLabel => '만나고 싶은 사람';

  @override
  String get usedByAlgorithmForProfiles => '알고리즘이 프로필을 추천하는 데 사용됩니다';

  @override
  String get ageRangeLabel => '연령대';

  @override
  String get maxDistanceLabel => '최대 거리';

  @override
  String get applySuggestionPrompt => '제안 적용:';

  @override
  String get ignore => '무시';

  @override
  String get apply => '적용';

  @override
  String get profileTitle => '프로필';

  @override
  String get deleteMyAccount => '내 계정 삭제';

  @override
  String get logout => '로그아웃';

  @override
  String get distanceKm => 'km';

  @override
  String get viewProfile => '프로필 보기';

  @override
  String get verificationPending => '검토 중';

  @override
  String get verificationDescription =>
      '계정이 아직 승인되지 않았습니다. 봇을 방지하기 위해 가능한 한 빨리 계정을 확인합니다. 이 과정은 약 24시간이 소요됩니다. 처리를 앞당기려면 프로필을 완성해주세요.';

  @override
  String get noMoreProfilesTitle => '모두 확인했습니다!';

  @override
  String get noMoreProfilesDesc => '나중에 다시 방문하여 주변의 새로운 사람들을 찾아보세요.';

  @override
  String get searchAgain => '다시 검색';

  @override
  String get swipeLike => 'LIKE';

  @override
  String get swipeNope => 'NOPE';

  @override
  String get likeRejected => '❌ 좋아요를 거절했습니다';

  @override
  String get likeBackSuccess => '💖 이 사람에게 좋아요를 보냈습니다';

  @override
  String get receivedLikesTitle => '받은 좋아요';

  @override
  String get noLikesYet => '아직 좋아요가 없습니다 😢';

  @override
  String get donationThanks => '기부해 주셔서 감사합니다! ❤️';

  @override
  String get chooseAmount => '금액 선택';

  @override
  String get supportThanks => '지원해 주셔서 감사합니다! ❤️';

  @override
  String get supportAmikone => 'Amikone 후원하기 ❤️';

  @override
  String get collected => '모금액';

  @override
  String get goal => '목표';

  @override
  String get goalPrefix => '목표: ';

  @override
  String get paymentServiceUnavailable => '현재 결제 서비스를 이용할 수 없습니다.';

  @override
  String get supportAction => '후원하기';

  @override
  String get matchDeletedSuccess => '매치가 성공적으로 삭제되었습니다.';

  @override
  String get matchDeleteErrorRetry => '매치를 삭제할 수 없습니다. 다시 시도해주세요.';

  @override
  String get myChatsTitle => '내 채팅';

  @override
  String get noConversationsYet => '아직 대화가 없습니다';

  @override
  String get deleteMessageTitle => '이 메시지를 삭제하시겠습니까?';

  @override
  String get irreversibleAction => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get delete => '삭제';

  @override
  String get deleteMatchTitle => '이 매치를 삭제하시겠습니까?';

  @override
  String get deleteMatchWarning => '이 작업은 되돌릴 수 없습니다. 더 이상 이 사람과 채팅할 수 없습니다.';

  @override
  String get matchDeleteError => '매치 삭제 중 오류가 발생했습니다.';

  @override
  String get me => '나';

  @override
  String get deleteMatchTooltip => '매치 삭제';

  @override
  String get serverPickerTitle => '서버 선택';

  @override
  String get availableServersGithub => '사용 가능한 서버 (GitHub)';

  @override
  String get addServerManually => '수동으로 추가';

  @override
  String get addServerDesc => 'URL 및 Publishable Key 입력';

  @override
  String get addServerDialogTitle => '서버 추가';

  @override
  String get serverNameLabel => '이름';

  @override
  String get serverUrlLabel => 'URL (https://...)';

  @override
  String get serverKeyLabel => 'Publishable Key';

  @override
  String get addAndSelect => '추가 및 선택';

  @override
  String get manualServerDesc => '수동으로 추가된 서버';

  @override
  String connectedToServer(Object name) {
    return '$name에 연결됨';
  }

  @override
  String get myIdentityTitle => '나의 정체성';

  @override
  String get myGenderLabel => '나의 성별';

  @override
  String get myGenderSubtitle => '자신을 어떻게 정의하시나요?';

  @override
  String get myOrientationSubtitle => '공개 프로필에 표시됩니다';

  @override
  String get whoIWantToMeet => '내가 만나고 싶은 사람';

  @override
  String get whoIWantToMeetSubtitle => '알고리즘이 프로필을 추천하는 데 사용됩니다';

  @override
  String get identityGenre => '성별';

  @override
  String get identityOrientation => '성적 지향';

  @override
  String get identitySeeking => '찾고 있는 사람';

  @override
  String get everyone => '모두';
}
