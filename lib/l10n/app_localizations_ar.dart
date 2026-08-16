// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'WHO\'S SUS';

  @override
  String get splashTagline => 'لعبة كلمات للحفلات';

  @override
  String get homeTagline => 'اعثر على المحتال بين أصدقائك';

  @override
  String get homeOffline => 'دون اتصال';

  @override
  String get homeOnline => 'عبر الإنترنت';

  @override
  String get homeHowToPlay => 'كيف تلعب';

  @override
  String get howToPlayTitle => 'كيف تلعب';

  @override
  String get rule1 => 'يحصل الجميع على الكلمة السرية نفسها — باستثناء المحتال.';

  @override
  String get rule2 => 'صِف الكلمة دون أن تنطقها أبدًا.';

  @override
  String get rule3 => 'اكتشف من لا يعرف الكلمة، ثم صوّت لإقصائه.';

  @override
  String get rule4 => 'للمحتال فرصة أخيرة للتخمين.';

  @override
  String get gotIt => 'فهمت';

  @override
  String get playersTitle => 'اللاعبون';

  @override
  String get addPlayers => 'أضف لاعبين';

  @override
  String get playerNameHint => 'اسم اللاعب';

  @override
  String get addPlayerButton => 'إضافة';

  @override
  String get nameAlreadyAdded => 'هذا الاسم مضاف بالفعل';

  @override
  String maximumPlayers(int count) {
    return 'الحد الأقصى $count لاعبين';
  }

  @override
  String addPlayersToStart(int min, int max) {
    return 'أضف $min إلى $max لاعبين للبدء';
  }

  @override
  String get pickCategoryButton => 'اختر الفئة';

  @override
  String addPlayersMinButton(int count) {
    return 'أضف $count+ لاعبين';
  }

  @override
  String get categoryTitle => 'الفئة';

  @override
  String get pickWordCategory => 'اختر فئة الكلمات';

  @override
  String get couldNotLoadCategories => 'تعذّر تحميل الفئات';

  @override
  String get tryAgain => 'أعد المحاولة';

  @override
  String get categoryFood => 'طعام';

  @override
  String get categoryAnimals => 'حيوانات';

  @override
  String get categorySports => 'رياضة';

  @override
  String get categoryMovies => 'أفلام';

  @override
  String get categoryPlaces => 'أماكن';

  @override
  String get categoryJobs => 'مهن';

  @override
  String get categoryObjects => 'أشياء';

  @override
  String get categoryGames => 'ألعاب';

  @override
  String get categoryCelebrities => 'مشاهير';

  @override
  String get categoryRandom => 'عشوائي';

  @override
  String get secretRoleTitle => 'الدور السري';

  @override
  String get passThePhone => 'مرّر الهاتف';

  @override
  String get noPeeking => 'ممنوع النظر إلى اللاعب التالي';

  @override
  String get passPhoneTo => 'مرّر الهاتف إلى';

  @override
  String get imReady => 'أنا جاهز';

  @override
  String get startDiscussion => 'ابدأ النقاش';

  @override
  String get yourSecretWordIs => 'كلمتك السرية هي';

  @override
  String get dontSayTheWord => 'لا تقل الكلمة';

  @override
  String get youAreTheImposter => 'أنت المحتال';

  @override
  String get blendInDontGetCaught => 'اندمج ولا تنكشف';

  @override
  String get discussTitle => 'نقاش';

  @override
  String get discuss => 'ناقشوا!';

  @override
  String get figureOutWhosImp => 'اكتشفوا من لا يعرف الكلمة';

  @override
  String get startVoting => 'ابدأ التصويت';

  @override
  String get votingTitle => 'تصويت';

  @override
  String get whoIsTheImposter => 'من هو المحتال؟';

  @override
  String get voteInSecret => 'صوّت في سرية';

  @override
  String get tapAPlayerToVote => 'المس لاعبًا للتصويت';

  @override
  String get change => 'تغيير';

  @override
  String voteForName(String name) {
    return 'صوّت على $name';
  }

  @override
  String get votesTitle => 'النتائج';

  @override
  String get itsATie => 'تعادل!';

  @override
  String get noOneVotedOut => 'لن يُقصى أحد';

  @override
  String get mostSuspected => 'الأكثر اشتباهًا';

  @override
  String get revealTheImposter => 'اكشف المحتال';

  @override
  String get imposterTitle => 'محتال';

  @override
  String get theImposterWas => 'المحتال كان';

  @override
  String get finalGuessHint => 'للمحتال فرصة أخيرة للتخمين';

  @override
  String get finalChance => 'الفرصة الأخيرة';

  @override
  String get outcomeCrewCaught => 'أمسك الفريق بالمحتال!';

  @override
  String get outcomeTieGotAway => 'تعادل — هرب المحتال!';

  @override
  String get outcomeFooledEveryone => 'خدع المحتال الجميع!';

  @override
  String get pickSecretWord => 'اختر الكلمة السرية';

  @override
  String get crewWins => 'فاز الفريق!';

  @override
  String get imposterWins => 'فاز المحتال!';

  @override
  String get subtitleAlmostMadeIt => 'كاد المحتال أن ينجح… لكن الفريق أمسك به!';

  @override
  String get subtitleCaughtMissed => 'تم القبض على المحتال وأخطأ الكلمة!';

  @override
  String get subtitleGuessedWord => 'خمّن المحتال الكلمة!';

  @override
  String get subtitleEscaped => 'نجا المحتال من التصويت!';

  @override
  String get theWordWas => 'الكلمة كانت';

  @override
  String get guessedIt => 'خمّنها المحتال!';

  @override
  String get didntGuessIt => 'لم يخمّنها المحتال';

  @override
  String get pointsCrewPlusOne => 'كل عضو في الفريق +1';

  @override
  String get pointsImposterPlusOne => 'المحتال +1';

  @override
  String get pointsImposterPlusTwo => 'المحتال +2';

  @override
  String get detailCaughtMissed => 'أُمسك لكنه أخطأ الكلمة';

  @override
  String get detailDiscoveredGuessed => 'اكتُشف لكنه خمّن الكلمة';

  @override
  String get detailSurvived => 'نجا من التصويت';

  @override
  String get seeScoreboard => 'اعرض النتائج';

  @override
  String get scoresTitle => 'النقاط';

  @override
  String get playAgain => 'العب مجددًا';

  @override
  String get homeButton => 'الرئيسية';

  @override
  String get onlineConnecting => 'جارٍ الاتصال...';

  @override
  String get onlineFailedConnect => 'تعذّر الاتصال. حاول مرة أخرى.';

  @override
  String get onlineWaitConnecting => 'انتظر، جارٍ الاتصال...';

  @override
  String get onlineTagline => 'العب مع أصدقائك في أي مكان!';

  @override
  String get onlineCreateGame => 'إنشاء لعبة';

  @override
  String get onlineJoinGame => 'الانضمام إلى لعبة';

  @override
  String get onlineMenuHelp =>
      'أنشئ غرفة وشارك الرمز، أو انضم إلى غرفة موجودة برمز من 6 خانات.';

  @override
  String get onlineEnterName => 'يرجى إدخال اسمك';

  @override
  String get onlineRoomCodeLength => 'يجب أن يتكوّن رمز الغرفة من 6 خانات';

  @override
  String onlineCreateFailed(String error) {
    return 'تعذّر إنشاء الغرفة: $error';
  }

  @override
  String onlineJoinFailed(String error) {
    return 'تعذّر الانضمام إلى الغرفة: $error';
  }

  @override
  String onlineLeaveFailed(String error) {
    return 'تعذّر مغادرة الغرفة: $error';
  }

  @override
  String onlineStartFailed(String error) {
    return 'تعذّر بدء اللعبة: $error';
  }

  @override
  String get onlineStartNewGame => 'ابدأ لعبة جديدة';

  @override
  String get onlineJoinExistingGame => 'انضم إلى لعبة موجودة';

  @override
  String get onlineYourNameHint => 'اسمك';

  @override
  String get onlineRoomCodeHint => 'رمز الغرفة (مثال: A3X9K2)';

  @override
  String get onlineCreateRoom => 'إنشاء الغرفة';

  @override
  String get onlineJoinRoom => 'الانضمام';

  @override
  String get onlineCreateRoomHelp =>
      'ستكون المضيف وستحصل على رمز غرفة لمشاركته مع الآخرين.';

  @override
  String get onlineJoinRoomHelp =>
      'أدخل رمز الغرفة من 6 خانات الذي يقدمه المضيف.';

  @override
  String get lobbyTitle => 'الغرفة';

  @override
  String get onlineFailedLoadPlayers => 'تعذّر تحميل اللاعبين';

  @override
  String get onlineDisconnected => 'انقطع اتصالك بالغرفة';

  @override
  String get onlineRoomClosed => 'أغلق المضيف الغرفة';

  @override
  String get onlineCodeCopied => 'تم نسخ رمز الغرفة!';

  @override
  String get onlineNotLobby => 'الغرفة لم تعد في وضع الاستقبال';

  @override
  String get onlineNeedPlayers => 'يلزم 4 لاعبين على الأقل للبدء';

  @override
  String get roomCodeLabel => 'رمز الغرفة';

  @override
  String get onlineTapToCopy => 'المس للنسخ';

  @override
  String get playersLabel => 'اللاعبون';

  @override
  String get hostLabel => 'المضيف';

  @override
  String get onlineStartGame => 'ابدأ اللعبة';

  @override
  String get onlineWaitingHost => 'في انتظار المضيف لبدء اللعبة...';

  @override
  String get winnerTitle => 'الفائز';

  @override
  String get onlineGameTitle => 'اللعبة';

  @override
  String get onlineWaitingForHost => 'في انتظار المضيف...';

  @override
  String get onlineHostSelecting => 'المضيف يختار الفئة...';

  @override
  String get ready => 'جاهز';

  @override
  String get onlineNoOneTie => 'لا أحد (تعادل)';

  @override
  String get onlineUnknown => 'غير معروف';

  @override
  String get onlineShowWinner => 'إظهار الفائز';

  @override
  String get onlineWaitingImposterGuess => 'في انتظار تخمين المحتال...';

  @override
  String get onlineGuessSubmitted => 'تم إرسال التخمين.';

  @override
  String get onlineFinalizeRound => 'إنهاء الجولة';

  @override
  String get onlineNextRound => 'الجولة التالية';

  @override
  String get onlineError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get settingsTitle => 'إعدادات اللعبة';

  @override
  String get settingsPlayers => 'اللاعبون';

  @override
  String get settingsPlayersHint => 'عدد اللاعبين في اللعبة';

  @override
  String get settingsImposters => 'المحتالون';

  @override
  String get settingsImpostersHint => 'عدد المحتالين بين اللاعبين';

  @override
  String get settingsDiscussionTime => 'وقت النقاش';

  @override
  String get settingsVotingTime => 'وقت التصويت';

  @override
  String get settingsAnonymousVoting => 'تصويت سري';

  @override
  String get settingsAnonymousVotingHelp => 'إخفاء من صوّت لمن';

  @override
  String get settingsImposterClue => 'تلميح عن المحتال';

  @override
  String get settingsImposterClueHelp => 'يحصل الفريق على تلميح عن المحتال';

  @override
  String get settingsOn => 'مفعّل';

  @override
  String get settingsOff => 'معطّل';

  @override
  String get settingsSave => 'حفظ الإعدادات';

  @override
  String get settingsClose => 'إغلاق';

  @override
  String get settingsSaved => 'تم حفظ الإعدادات';

  @override
  String settingsSaveFailed(String error) {
    return 'تعذّر حفظ الإعدادات: $error';
  }

  @override
  String get settingsHostControls => 'المضيف يتحكم في الإعدادات';

  @override
  String get settingsHostControlsHelp =>
      'يمكن للمضيف فقط تغييرها قبل بدء اللعبة';

  @override
  String get settingsPlayersAdded => 'اللاعبون المضافون';

  @override
  String settingsSeconds(int count) {
    return '$count ث';
  }

  @override
  String settingsMinutes(int count) {
    return '$count د';
  }

  @override
  String settingsMinSec(int minutes, int seconds) {
    return '$minutes د $seconds ث';
  }

  @override
  String settingsPlayersRange(int min, int max) {
    return '$min–$max لاعبين';
  }

  @override
  String get settingsImpostersUnsupported => 'ألعاب المحتالين 2 غير مدعومة بعد';

  @override
  String settingsImpostersNeedPlayers(int count) {
    return 'يلزم $count لاعبين على الأقل لمحتالين';
  }

  @override
  String get settingsInvalid =>
      'إعدادات غير صالحة. تحقق من الخيارات وحاول مجددًا.';

  @override
  String onlineWaitingForPlayers(int current, int expected) {
    return 'في انتظار $current/$expected لاعبين';
  }

  @override
  String get timeLeft => 'الوقت المتبقي';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatInputHint => 'اكتب رسالة...';

  @override
  String get chatEmpty => 'لا توجد رسائل بعد';

  @override
  String get chatEmptyHint => 'ابدأ النقاش بالأسفل';

  @override
  String get chatSendFailed => 'تعذّر إرسال الرسالة';

  @override
  String get chatMessageTooLong => 'الرسالة طويلة جدًا (200 حرف كحد أقصى)';

  @override
  String chatMessageLength(int current, int max) {
    return '$current/$max';
  }

  @override
  String discussionPlayers(int count) {
    return '$count لاعبين يناقشون';
  }

  @override
  String get voiceTitle => 'المحادثة الصوتية';

  @override
  String get voiceHoldToTalk => 'اضغط مع الاستمرار للتحدث';

  @override
  String get voiceReleaseToStop => 'ارفع إصبعك للإيقاف';

  @override
  String get voiceTalking => 'جارٍ التحدث...';

  @override
  String get voiceSpaceHint => 'اضغط مسافة للتحدث';

  @override
  String get voiceSpeaking => 'يتحدث';

  @override
  String get voiceMuted => 'كتم';

  @override
  String get voiceConnecting => 'جارٍ الاتصال...';

  @override
  String get voiceReconnecting => 'جارٍ إعادة الاتصال...';

  @override
  String get voiceDisconnected => 'انقطع الصوت';

  @override
  String get voiceNotConnected => 'غير متصل';

  @override
  String get voicePermissionRequired =>
      'إذن الميكروفون مطلوب للمحادثة الصوتية.';

  @override
  String get voiceMicUnavailable => 'الميكروفون غير متاح.';

  @override
  String get voiceConnectionFailed =>
      'فشل الاتصال الصوتي. يمكنك متابعة الدردشة النصية.';

  @override
  String get voiceNotConfigured =>
      'المحادثة الصوتية غير متاحة الآن. يمكنك متابعة الدردشة النصية.';

  @override
  String get voiceAllowMicrophone => 'السماح بالميكروفون';

  @override
  String get voiceContinueWithoutVoice => 'المتابعة بدون صوت';

  @override
  String get voiceRetry => 'إعادة المحاولة';

  @override
  String get language => 'اللغة';
}
