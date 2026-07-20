// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get welcome => '欢迎';

  @override
  String get signInToContinue => '请登录以继续';

  @override
  String get or => '或';

  @override
  String error(Object error) {
    return '错误：$error';
  }

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get noAccount => '没有账号？注册';

  @override
  String get alreadyHaveAccount => '已有账号？登录';

  @override
  String get loginWithGoogle => '使用Google登录';

  @override
  String get loginWithApple => '使用Apple登录';

  @override
  String get verifyEmail => '请查看您的电子邮件以确认您的账号';

  @override
  String get profileNotFound => '找不到个人资料。';

  @override
  String get about => '关于';

  @override
  String get noDescription => '暂无描述。';

  @override
  String get interests => '兴趣';

  @override
  String get closeProfile => '关闭个人资料';

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get genderOther => '其他';

  @override
  String get notSpecified => '未指定';

  @override
  String get notSpecifiedFeminine => '未指定';

  @override
  String get ageYears => '岁';

  @override
  String get unknownAge => '年龄未知';

  @override
  String get reportProfile => '举报此个人资料';

  @override
  String get reportReasonPrompt => '请说明举报原因：';

  @override
  String get reportReasonHint => '虚假资料、不当行为...';

  @override
  String get cancel => '取消';

  @override
  String get report => '举报';

  @override
  String get userNotLoggedIn => '用户未登录';

  @override
  String get profileReportedSuccess => '个人资料已举报。';

  @override
  String get defaultUserName => '用户';

  @override
  String get navPeople => '缘分';

  @override
  String get navLike => '喜欢';

  @override
  String get navChat => '聊天';

  @override
  String get navProfile => '个人资料';

  @override
  String get navHealth => '健康';

  @override
  String get incompleteProfileTitle => '资料不完整';

  @override
  String get incompleteProfileDesc => '完善您的个人资料以解锁所有功能并结识新朋友。';

  @override
  String get completeMyProfile => '完善我的资料';

  @override
  String get genericError => '发生错误。';

  @override
  String get phoneBannedError => '此手机号码已被平台封禁。';

  @override
  String get phoneCheckError => '验证号码时出错。';

  @override
  String get fillRequiredFields => '请填写必填字段以继续。';

  @override
  String get phoneAlreadyInUse => '此号码已绑定到其他账号。';

  @override
  String get step1Title => '让我们认识一下';

  @override
  String get step1Subtitle => '我们该怎么称呼您？';

  @override
  String get firstNameHint => '您的名字';

  @override
  String get step2Title => '了解更多关于您';

  @override
  String get step2Subtitle => '您必须年满18岁才能注册。';

  @override
  String get birthDateHint => '出生日期';

  @override
  String get yourGender => '您的性别';

  @override
  String get step3Title => '您在哪里？';

  @override
  String get step3Subtitle => '为了结识您周围的人。';

  @override
  String get cityHint => '您的城市';

  @override
  String get step4Title => '您的号码';

  @override
  String get step4Subtitle => '可选 — 您可以稍后添加。';

  @override
  String get finish => '完成';

  @override
  String get continueAction => '继续';

  @override
  String get savedFormat => '保存格式：';

  @override
  String get countryFrance => '法国';

  @override
  String get countryBelgium => '比利时';

  @override
  String get countrySwitzerland => '瑞士';

  @override
  String get countryLuxembourg => '卢森堡';

  @override
  String get countryCanada => '加拿大';

  @override
  String get countryUSA => '美国';

  @override
  String get countryUK => '英国';

  @override
  String get countryGermany => '德国';

  @override
  String get countrySpain => '西班牙';

  @override
  String get countryItaly => '意大利';

  @override
  String get countryPortugal => '葡萄牙';

  @override
  String get countryMorocco => '摩洛哥';

  @override
  String get countryAlgeria => '阿尔及利亚';

  @override
  String get countryTunisia => '突尼斯';

  @override
  String get maxPhotosError => '您最多只能上传8张照片。';

  @override
  String get imageTooLargeError => '图片超过 2 MB';

  @override
  String get imageAddedSuccess => '图片已添加！';

  @override
  String get photoDeletedSuccess => '照片已删除';

  @override
  String get photoDeleteError => '删除时出错：';

  @override
  String get tagAddError => '添加标签时出错：';

  @override
  String get changePasswordTitle => '修改密码';

  @override
  String get newPasswordLabel => '新密码';

  @override
  String get passwordMinLengthError => '至少需要6个字符';

  @override
  String get confirmPasswordLabel => '确认';

  @override
  String get passwordsDoNotMatchError => '密码不匹配';

  @override
  String get validate => '提交';

  @override
  String get passwordUpdatedSuccess => '密码已更新！';

  @override
  String get deleteAccountTitle => '删除账号';

  @override
  String get deleteAccountWarning =>
      '您确定要永久删除您的账号吗？此操作不可逆，您的手机号码将被封禁，无法用于以后的注册。';

  @override
  String get accountDeletedSuccess => '您的账号已被永久删除。';

  @override
  String get confirm => '确认';

  @override
  String get aboutMeTitle => '关于我';

  @override
  String get aboutMeHint => '介绍一下你自己...';

  @override
  String get myPassionsTitle => '我的爱好';

  @override
  String get passionsDescription => '算法会根据您的爱好为您匹配最合适的个人资料。';

  @override
  String get followersCount => '人关注';

  @override
  String get passionsHint => '例如：攀岩，韩国电影...';

  @override
  String get myPhotosTitle => '我的照片';

  @override
  String get datingPreferencesTitle => '交友偏好';

  @override
  String get myOrientationLabel => '我的性取向';

  @override
  String get displayedOnPublicProfile => '显示在您的公开资料上';

  @override
  String get iWantToMeetLabel => '我想认识';

  @override
  String get usedByAlgorithmForProfiles => '算法将以此为您推荐个人资料';

  @override
  String get ageRangeLabel => '年龄范围';

  @override
  String get maxDistanceLabel => '最大距离';

  @override
  String get applySuggestionPrompt => '应用建议：';

  @override
  String get ignore => '忽略';

  @override
  String get apply => '应用';

  @override
  String get profileTitle => '个人资料';

  @override
  String get deleteMyAccount => '删除我的账号';

  @override
  String get logout => '退出登录';

  @override
  String get distanceKm => '公里';

  @override
  String get viewProfile => '查看资料';

  @override
  String get verificationPending => '审核中';

  @override
  String get verificationDescription =>
      '您的账号尚未通过验证。我们会尽快审核账号以防止机器人。这大约需要24小时。请完善您的个人资料以加快审核速度。';

  @override
  String get noMoreProfilesTitle => '您已看完所有推荐！';

  @override
  String get noMoreProfilesDesc => '请稍后再来看看附近的新朋友。';

  @override
  String get searchAgain => '重新搜索';

  @override
  String get swipeLike => '喜欢';

  @override
  String get swipeNope => '拒绝';

  @override
  String get likeRejected => '❌ 拒绝喜欢';

  @override
  String get likeBackSuccess => '💖 您也喜欢了这个人';

  @override
  String get receivedLikesTitle => '收到的喜欢';

  @override
  String get noLikesYet => '暂时没有收到喜欢 😢';

  @override
  String get donationThanks => '感谢您的捐赠！❤️';

  @override
  String get chooseAmount => '选择金额';

  @override
  String get supportThanks => '感谢您的支持！❤️';

  @override
  String get supportAmikone => '支持Amikone ❤️';

  @override
  String get collected => '已筹集';

  @override
  String get goal => '目标';

  @override
  String get goalPrefix => '目标：';

  @override
  String get paymentServiceUnavailable => '支付服务暂时不可用。';

  @override
  String get supportAction => '支持';

  @override
  String get matchDeletedSuccess => '匹配已成功删除。';

  @override
  String get matchDeleteErrorRetry => '无法删除匹配。请重试。';

  @override
  String get myChatsTitle => '我的聊天';

  @override
  String get noConversationsYet => '您暂时没有对话';

  @override
  String get deleteMessageTitle => '删除此消息？';

  @override
  String get irreversibleAction => '此操作不可逆。';

  @override
  String get delete => '删除';

  @override
  String get deleteMatchTitle => '删除此匹配？';

  @override
  String get deleteMatchWarning => '此操作不可逆。您将无法再与此人聊天。';

  @override
  String get matchDeleteError => '删除匹配时出错。';

  @override
  String get me => '我';

  @override
  String get deleteMatchTooltip => '删除匹配';
}
