// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get welcome => 'ようこそ';

  @override
  String get signInToContinue => 'ログインして続行';

  @override
  String get or => 'または';

  @override
  String error(Object error) {
    return 'エラー: $error';
  }

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get signIn => 'ログイン';

  @override
  String get signUp => 'サインアップ';

  @override
  String get noAccount => 'アカウントをお持ちでないですか？登録';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？ログイン';

  @override
  String get loginWithGoogle => 'Googleでログイン';

  @override
  String get loginWithApple => 'Appleでログイン';

  @override
  String get verifyEmail => 'メールを確認してアカウントを承認してください';

  @override
  String get profileNotFound => 'プロフィールが見つかりません。';

  @override
  String get about => '概要';

  @override
  String get noDescription => '説明がありません。';

  @override
  String get interests => '興味・関心';

  @override
  String get closeProfile => 'プロフィールを閉じる';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => 'その他';

  @override
  String get notSpecified => '指定なし';

  @override
  String get notSpecifiedFeminine => '指定なし';

  @override
  String get ageYears => '歳';

  @override
  String get unknownAge => '年齢不明';

  @override
  String get reportProfile => 'このプロフィールを通報する';

  @override
  String get reportReasonPrompt => '通報の理由を教えてください:';

  @override
  String get reportReasonHint => '偽のプロフィール、迷惑行為...';

  @override
  String get cancel => 'キャンセル';

  @override
  String get report => '通報する';

  @override
  String get userNotLoggedIn => 'ログインしていません';

  @override
  String get profileReportedSuccess => 'プロフィールを通報しました。';

  @override
  String get defaultUserName => 'ユーザー';

  @override
  String get navPeople => '出会い';

  @override
  String get navLike => 'いいね';

  @override
  String get navChat => 'チャット';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get navHealth => 'ヘルス';

  @override
  String get incompleteProfileTitle => 'プロフィールが未完成です';

  @override
  String get incompleteProfileDesc =>
      'すべての機能のロックを解除し、素敵な出会いを見つけるためにプロフィールを完成させましょう。';

  @override
  String get completeMyProfile => 'プロフィールを完成させる';

  @override
  String get genericError => 'エラーが発生しました。';

  @override
  String get phoneBannedError => 'この電話番号はプラットフォームからブロックされています。';

  @override
  String get phoneCheckError => '電話番号の確認中にエラーが発生しました。';

  @override
  String get fillRequiredFields => '続行するには必須項目を入力してください。';

  @override
  String get phoneAlreadyInUse => 'この番号はすでに別のアカウントにリンクされています。';

  @override
  String get step1Title => 'あなたについて教えてください';

  @override
  String get step1Subtitle => 'お呼びする名前を教えてください。';

  @override
  String get firstNameHint => '下の名前';

  @override
  String get step2Title => 'もう少し詳しく教えてください';

  @override
  String get step2Subtitle => '登録には18歳以上である必要があります。';

  @override
  String get birthDateHint => '生年月日';

  @override
  String get yourGender => 'あなたの性別';

  @override
  String get step3Title => 'どこにいますか？';

  @override
  String get step3Subtitle => '近くの人と出会うために。';

  @override
  String get cityHint => '市区町村';

  @override
  String get step4Title => 'あなたの電話番号';

  @override
  String get step4Subtitle => '任意 — 後で追加することもできます。';

  @override
  String get finish => '完了';

  @override
  String get continueAction => '続行';

  @override
  String get savedFormat => '保存された形式：';

  @override
  String get countryFrance => 'フランス';

  @override
  String get countryBelgium => 'ベルギー';

  @override
  String get countrySwitzerland => 'スイス';

  @override
  String get countryLuxembourg => 'ルクセンブルク';

  @override
  String get countryCanada => 'カナダ';

  @override
  String get countryUSA => 'アメリカ';

  @override
  String get countryUK => 'イギリス';

  @override
  String get countryGermany => 'ドイツ';

  @override
  String get countrySpain => 'スペイン';

  @override
  String get countryItaly => 'イタリア';

  @override
  String get countryPortugal => 'ポルトガル';

  @override
  String get countryMorocco => 'モロッコ';

  @override
  String get countryAlgeria => 'アルジェリア';

  @override
  String get countryTunisia => 'チュニジア';

  @override
  String get maxPhotosError => '写真は8枚までしか追加できません。';

  @override
  String get imageTooLargeError => '画像のサイズが2MBを超えています';

  @override
  String get imageAddedSuccess => '画像を追加しました！';

  @override
  String get photoDeletedSuccess => '写真を削除しました';

  @override
  String get photoDeleteError => '削除エラー：';

  @override
  String get tagAddError => 'タグの追加エラー：';

  @override
  String get changePasswordTitle => 'パスワードを変更する';

  @override
  String get newPasswordLabel => '新しいパスワード';

  @override
  String get passwordMinLengthError => '6文字以上で入力してください';

  @override
  String get confirmPasswordLabel => '確認';

  @override
  String get passwordsDoNotMatchError => 'パスワードが一致しません';

  @override
  String get validate => '確認する';

  @override
  String get passwordUpdatedSuccess => 'パスワードを更新しました！';

  @override
  String get deleteAccountTitle => 'アカウントを削除';

  @override
  String get deleteAccountWarning =>
      'アカウントを完全に削除してもよろしいですか？この操作は取り消すことができず、電話番号は今後の登録でブロックされます。';

  @override
  String get accountDeletedSuccess => 'アカウントは完全に削除されました。';

  @override
  String get confirm => '確定';

  @override
  String get aboutMeTitle => '自己紹介';

  @override
  String get aboutMeHint => '自分について教えてください...';

  @override
  String get myPassionsTitle => '興味・関心';

  @override
  String get passionsDescription => 'アルゴリズムはあなたの興味を使って最適なプロフィールを見つけます。';

  @override
  String get followersCount => '人のフォロワー';

  @override
  String get passionsHint => '例：ボルダリング、韓国映画...';

  @override
  String get myPhotosTitle => 'マイ写真';

  @override
  String get datingPreferencesTitle => 'デートの希望';

  @override
  String get myOrientationLabel => '性的指向';

  @override
  String get displayedOnPublicProfile => '公開プロフィールに表示されます';

  @override
  String get iWantToMeetLabel => '出会いたい人';

  @override
  String get usedByAlgorithmForProfiles => 'プロフィールを表示するためにアルゴリズムが使用します';

  @override
  String get ageRangeLabel => '年齢層';

  @override
  String get maxDistanceLabel => '最大距離';

  @override
  String get applySuggestionPrompt => '提案を適用：';

  @override
  String get ignore => '無視する';

  @override
  String get apply => '適用する';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get deleteMyAccount => 'アカウントを削除';

  @override
  String get logout => 'ログアウト';

  @override
  String get distanceKm => 'km';

  @override
  String get viewProfile => 'プロフィールを見る';

  @override
  String get verificationPending => '審査中';

  @override
  String get verificationDescription =>
      'あなたのアカウントはまだ承認されていません。ボットを防ぐため、アカウントの審査をできるだけ早く行っています。これには約24時間かかります。プロフィールを完成させると、手続きがスムーズになります。';

  @override
  String get noMoreProfilesTitle => 'すべて見終わりました！';

  @override
  String get noMoreProfilesDesc => '後でまた来て、近くの新しい人を見つけてください。';

  @override
  String get searchAgain => '再検索する';

  @override
  String get swipeLike => 'LIKE';

  @override
  String get swipeNope => 'NOPE';

  @override
  String get likeRejected => '❌ いいねを拒否しました';

  @override
  String get likeBackSuccess => '💖 この人にいいねを返しました';

  @override
  String get receivedLikesTitle => 'もらったいいね';

  @override
  String get noLikesYet => 'まだいいねがありません 😢';

  @override
  String get donationThanks => '寄付していただきありがとうございます！❤️';

  @override
  String get chooseAmount => '金額を選択';

  @override
  String get supportThanks => 'サポートありがとうございます！❤️';

  @override
  String get supportAmikone => 'Amikoneを支援する ❤️';

  @override
  String get collected => '集まった金額';

  @override
  String get goal => '目標';

  @override
  String get goalPrefix => '目標：';

  @override
  String get paymentServiceUnavailable => '現在、支払いサービスは利用できません。';

  @override
  String get supportAction => '支援する';

  @override
  String get matchDeletedSuccess => 'マッチが正常に削除されました。';

  @override
  String get matchDeleteErrorRetry => 'マッチを削除できませんでした。もう一度お試しください。';

  @override
  String get myChatsTitle => 'マイチャット';

  @override
  String get noConversationsYet => 'まだ会話がありません';

  @override
  String get deleteMessageTitle => 'このメッセージを削除しますか？';

  @override
  String get irreversibleAction => 'この操作は元に戻せません。';

  @override
  String get delete => '削除';

  @override
  String get deleteMatchTitle => 'このマッチを削除しますか？';

  @override
  String get deleteMatchWarning => 'この操作は元に戻せません。今後この人とはチャットできなくなります。';

  @override
  String get matchDeleteError => 'マッチの削除中にエラーが発生しました。';

  @override
  String get me => '自分';

  @override
  String get deleteMatchTooltip => 'マッチを削除';

  @override
  String get serverPickerTitle => 'サーバーを選択';

  @override
  String get availableServersGithub => '利用可能なサーバー (GitHub)';

  @override
  String get addServerManually => '手動で追加';

  @override
  String get addServerDesc => 'URLとPublishable Keyを入力';

  @override
  String get addServerDialogTitle => 'サーバーを追加';

  @override
  String get serverNameLabel => '名前';

  @override
  String get serverUrlLabel => 'URL (https://...)';

  @override
  String get serverKeyLabel => 'Publishable Key';

  @override
  String get addAndSelect => '追加して選択';

  @override
  String get manualServerDesc => '手動で追加されたサーバー';

  @override
  String connectedToServer(Object name) {
    return '$name に接続しました';
  }

  @override
  String get myIdentityTitle => '私のアイデンティティ';

  @override
  String get myGenderLabel => '私の性別';

  @override
  String get myGenderSubtitle => '自分をどのように定義しますか？';

  @override
  String get myOrientationSubtitle => '公開プロフィールに表示されます';

  @override
  String get whoIWantToMeet => '会いたい人';

  @override
  String get whoIWantToMeetSubtitle => 'アルゴリズムがプロフィールを提案するために使用されます';

  @override
  String get identityGenre => '性別';

  @override
  String get identityOrientation => '性的指向';

  @override
  String get identitySeeking => '探している人';

  @override
  String get everyone => '全員';
}
