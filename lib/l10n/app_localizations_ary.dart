// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Moroccan Arabic (`ary`).
class AppLocalizationsAry extends AppLocalizations {
  AppLocalizationsAry([String locale = 'ary']) : super(locale);

  @override
  String get appName => 'WHO\'S SUS';

  @override
  String get splashTagline => 'لعبة الكلمات دي السهرات';

  @override
  String get homeTagline => 'لقّي المحتال بين صحابك';

  @override
  String get homeOffline => 'بلا إنترنات';

  @override
  String get homeOnline => 'أونلاين';

  @override
  String get homeHowToPlay => 'كيفاش تلعب';

  @override
  String get howToPlayTitle => 'كيفاش تلعب';

  @override
  String get rule1 => 'كل واحد كياخد نفس الكلمة السرية — غير المحتال.';

  @override
  String get rule2 => 'وصّف الكلمة بلا ما تڭولها.';

  @override
  String get rule3 => 'لقّي شكون ما عارفش الكلمة، ومن بعد صوّت عليه.';

  @override
  String get rule4 => 'المحتال عندو شانس أخيرة يخمّن.';

  @override
  String get gotIt => 'واخا';

  @override
  String get playersTitle => 'اللاعبين';

  @override
  String get addPlayers => 'زيد اللاعبين';

  @override
  String get playerNameHint => 'سمية اللاعب';

  @override
  String get addPlayerButton => 'زيد';

  @override
  String get nameAlreadyAdded => 'هاد الاسم مزاد قبل';

  @override
  String maximumPlayers(int count) {
    return 'أقصى حد $count لاعبين';
  }

  @override
  String addPlayersToStart(int min, int max) {
    return 'زيد بين $min و $max لاعبين باش تبداو';
  }

  @override
  String get pickCategoryButton => 'خيّر الفئة';

  @override
  String addPlayersMinButton(int count) {
    return 'زيد $count+ لاعبين';
  }

  @override
  String get categoryTitle => 'الفئة';

  @override
  String get pickWordCategory => 'خيّر فئة الكلمات';

  @override
  String get couldNotLoadCategories => 'ما تّحمّلوش الفئات';

  @override
  String get tryAgain => 'عاود جرب';

  @override
  String get categoryFood => 'ماكلة';

  @override
  String get categoryAnimals => 'حيوانات';

  @override
  String get categorySports => 'رياضة';

  @override
  String get categoryMovies => 'أفلام';

  @override
  String get categoryPlaces => 'بلايص';

  @override
  String get categoryJobs => 'مهن';

  @override
  String get categoryObjects => 'حوايج';

  @override
  String get categoryGames => 'لعب';

  @override
  String get categoryCelebrities => 'مشاهير';

  @override
  String get categoryRandom => 'عشوائي';

  @override
  String get secretRoleTitle => 'الدور السري';

  @override
  String get passThePhone => 'دّوز التليفون';

  @override
  String get noPeeking => 'ما تنظّرش للاعب التالي';

  @override
  String get passPhoneTo => 'دّوز التليفون لـ';

  @override
  String get imReady => 'أنا جاهز';

  @override
  String get startDiscussion => 'بدا المناقشة';

  @override
  String get yourSecretWordIs => 'الكلمة السرية ديالك هي';

  @override
  String get dontSayTheWord => 'ما تڭولش الكلمة';

  @override
  String get youAreTheImposter => 'نتا هو المحتال';

  @override
  String get blendInDontGetCaught => 'موّه فيهم، ما يكتاشو عليك';

  @override
  String get discussTitle => 'مناقشة';

  @override
  String get discuss => 'ناقشو!';

  @override
  String get figureOutWhosImp => 'لقّيو شكون ما عارفش الكلمة';

  @override
  String get startVoting => 'بدا التصويت';

  @override
  String get votingTitle => 'تصويت';

  @override
  String get whoIsTheImposter => 'شكون هو المحتال؟';

  @override
  String get voteInSecret => 'صوّت ف الخفا';

  @override
  String get tapAPlayerToVote => 'مسّ لاعب باش تصوّت';

  @override
  String get change => 'بدّل';

  @override
  String voteForName(String name) {
    return 'صوّت على $name';
  }

  @override
  String get votesTitle => 'النتايج';

  @override
  String get itsATie => 'تساوي!';

  @override
  String get noOneVotedOut => 'ما كيتقصى حتى واحد';

  @override
  String get mostSuspected => 'الأكثر مشكوك فيهم';

  @override
  String get revealTheImposter => 'كشّف المحتال';

  @override
  String get imposterTitle => 'محتال';

  @override
  String get theImposterWas => 'المحتال كان هو';

  @override
  String get finalGuessHint => 'المحتال عندو شانس أخيرة يخمّن';

  @override
  String get finalChance => 'الشانس الأخيرة';

  @override
  String get outcomeCrewCaught => 'قبضو على المحتال!';

  @override
  String get outcomeTieGotAway => 'تساوي — هرب المحتال!';

  @override
  String get outcomeFooledEveryone => 'المحتال غشّ الجميع!';

  @override
  String get pickSecretWord => 'خيّر الكلمة السرية';

  @override
  String get crewWins => 'الفريق ربح!';

  @override
  String get imposterWins => 'المحتال ربح!';

  @override
  String get subtitleAlmostMadeIt => 'كاد يربح المحتال… ولكن قبضو عليه!';

  @override
  String get subtitleCaughtMissed => 'اتقبط المحتال وغّلط ف الكلمة!';

  @override
  String get subtitleGuessedWord => 'المحتال عرف الكلمة!';

  @override
  String get subtitleEscaped => 'المحتال هرب من التصويت!';

  @override
  String get theWordWas => 'الكلمة كانت';

  @override
  String get guessedIt => 'عرفها المحتال!';

  @override
  String get didntGuessIt => 'المحتال ما عرفهاش';

  @override
  String get pointsCrewPlusOne => 'كل واحد ف الفريق +1';

  @override
  String get pointsImposterPlusOne => 'المحتال +1';

  @override
  String get pointsImposterPlusTwo => 'المحتال +2';

  @override
  String get detailCaughtMissed => 'اتقبط ولكن غلّط ف الكلمة';

  @override
  String get detailDiscoveredGuessed => 'تكتشف ولكن عرف الكلمة';

  @override
  String get detailSurvived => 'نجا من التصويت';

  @override
  String get seeScoreboard => 'شوف الترتيب';

  @override
  String get scoresTitle => 'النقاط';

  @override
  String get playAgain => 'عاود العب';

  @override
  String get homeButton => 'الرئيسية';

  @override
  String get onlineConnecting => 'كيتّصل...';

  @override
  String get onlineFailedConnect => 'ما تّصلش. عاود جرب.';

  @override
  String get onlineWaitConnecting => 'صبر شوية، كيتّصل...';

  @override
  String get onlineTagline => 'العب مع صحابك فين ما كانو!';

  @override
  String get onlineCreateGame => 'صاوب لعبة';

  @override
  String get onlineJoinGame => 'دخل للعبة';

  @override
  String get onlineMenuHelp =>
      'صاوب رووم وشارك الكود، ولا دخل لرووم موجود بكود ديال 6 حروف.';

  @override
  String get onlineEnterName => 'عافاك دخل سمية ديالك';

  @override
  String get onlineRoomCodeLength => 'كود الرووم خاصو يكون 6 حروف';

  @override
  String onlineCreateFailed(String error) {
    return 'ما تّصاوبش الرووم: $error';
  }

  @override
  String onlineJoinFailed(String error) {
    return 'ما دخلتيش للرووم: $error';
  }

  @override
  String onlineLeaveFailed(String error) {
    return 'ما خرجتيش من الرووم: $error';
  }

  @override
  String onlineStartFailed(String error) {
    return 'ما بداتش اللعبة: $error';
  }

  @override
  String get onlineStartNewGame => 'بدا لعبة جديدة';

  @override
  String get onlineJoinExistingGame => 'دخل للعبة موجودة';

  @override
  String get onlineYourNameHint => 'سمية ديالك';

  @override
  String get onlineRoomCodeHint => 'كود الرووم (مثال: A3X9K2)';

  @override
  String get onlineCreateRoom => 'صاوب الرووم';

  @override
  String get onlineJoinRoom => 'دخل';

  @override
  String get onlineCreateRoomHelp =>
      'غادي تكون المضيف وغادي تاخد كود الرووم باش تشاركو مع الآخرين.';

  @override
  String get onlineJoinRoomHelp => 'دخل كود الرووم ديال 6 حروف من المضيف.';

  @override
  String get lobbyTitle => 'الرووم';

  @override
  String get onlineFailedLoadPlayers => 'ما تّحمّلوش اللاعبين';

  @override
  String get onlineDisconnected => 'تقطّعت عليك العلاقة مع الرووم';

  @override
  String get onlineRoomClosed => 'المضيف سد الرووم';

  @override
  String get onlineCodeCopied => 'تّنسخ كود الرووم!';

  @override
  String get onlineNotLobby => 'الرووم ما بقاش ف حالة الاستقبال';

  @override
  String get onlineNeedPlayers => 'خاص 4 لاعبين على الأقل باش تبداو';

  @override
  String get roomCodeLabel => 'كود الرووم';

  @override
  String get onlineTapToCopy => 'مسّ باش تنسخ';

  @override
  String get playersLabel => 'اللاعبين';

  @override
  String get hostLabel => 'المضيف';

  @override
  String get onlineStartGame => 'بدا اللعبة';

  @override
  String get onlineWaitingHost => 'كنسناو المضيف يبدا اللعبة...';

  @override
  String get winnerTitle => 'الرابح';

  @override
  String get onlineGameTitle => 'اللعبة';

  @override
  String get onlineWaitingForHost => 'كنسناو المضيف...';

  @override
  String get onlineHostSelecting => 'المضيف كيختار الفئة...';

  @override
  String get ready => 'جاهز';

  @override
  String get onlineNoOneTie => 'حتى واحد (تساوي)';

  @override
  String get onlineUnknown => 'مجهول';

  @override
  String get onlineShowWinner => 'ورّي الرابح';

  @override
  String get onlineWaitingImposterGuess => 'كنسناو المحتال يخمّن...';

  @override
  String get onlineGuessSubmitted => 'تّصيفط التخمين.';

  @override
  String get onlineFinalizeRound => 'سالي الدور';

  @override
  String get onlineNextRound => 'الدور الجاي';

  @override
  String get onlineError => 'وقع شي مشكل. عاود جرب.';

  @override
  String get settingsTitle => 'الإعدادات ديال اللعبة';

  @override
  String get settingsPlayers => 'اللاعبين';

  @override
  String get settingsPlayersHint => 'شحال من لاعب ف اللعبة';

  @override
  String get settingsImposters => 'المحتالين';

  @override
  String get settingsImpostersHint => 'شحال من محتال بين اللاعبين';

  @override
  String get settingsDiscussionTime => 'الوقت ديال المناقشة';

  @override
  String get settingsVotingTime => 'الوقت ديال التصويت';

  @override
  String get settingsAnonymousVoting => 'تصويت سري';

  @override
  String get settingsAnonymousVotingHelp => 'خبّي شكون صوّت لشكون';

  @override
  String get settingsImposterClue => 'تلميح على المحتال';

  @override
  String get settingsImposterClueHelp => 'الطاقم كياخد تلميح على المحتال';

  @override
  String get settingsOn => 'مفعّل';

  @override
  String get settingsOff => 'معطّل';

  @override
  String get settingsSave => 'حفض الإعدادات';

  @override
  String get settingsClose => 'سد';

  @override
  String get settingsSaved => 'تّحفضات الإعدادات';

  @override
  String settingsSaveFailed(String error) {
    return 'ما تّحفضاتش الإعدادات: $error';
  }

  @override
  String get settingsHostControls => 'المضيف هو لي كيتحكم ف الإعدادات';

  @override
  String get settingsHostControlsHelp =>
      'المضيف بوحدو لي يقدر يبدلهم قبل ما تبدا اللعبة';

  @override
  String get settingsPlayersAdded => 'اللاعبين المضافين';

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
  String get settingsImpostersUnsupported =>
      'الألعاب ب 2 محتالين مزيانين ماشي مدعومين حتى هادي';

  @override
  String settingsImpostersNeedPlayers(int count) {
    return 'خاص $count لاعبين على الأقل ل 2 محتالين';
  }

  @override
  String get settingsInvalid => 'إعدادات غالطة. تآكد من الخيارات وعاود جرب.';

  @override
  String onlineWaitingForPlayers(int current, int expected) {
    return 'كنسناو $current/$expected لاعبين';
  }

  @override
  String get timeLeft => 'الوقت الباقي';

  @override
  String get chatSend => 'صيفط';

  @override
  String get chatInputHint => 'كتب رسالة...';

  @override
  String get chatEmpty => 'ما كاين حتى رسالة';

  @override
  String get chatEmptyHint => 'بدا النقاش التحت';

  @override
  String get chatSendFailed => 'ما تبعاتش الرسالة';

  @override
  String get chatMessageTooLong => 'الرسالة طويلة بزاف (200 حرف كحد أقصى)';

  @override
  String chatMessageLength(int current, int max) {
    return '$current/$max';
  }

  @override
  String discussionPlayers(int count) {
    return '$count لاعبين كيتناقشو';
  }

  @override
  String get language => 'اللغة';
}
