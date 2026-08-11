// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Word Imposter';

  @override
  String get appNameWord => 'WORD';

  @override
  String get appNameImposter => 'IMPOSTER';

  @override
  String get splashTagline => 'لعبة كلمات للحفلات';

  @override
  String get homeTagline => 'اعثر على المحتال بين أصدقائك';

  @override
  String get homeOffline => 'دون اتصال';

  @override
  String get homeOnlineComingSoon => 'عبر الإنترنت · قريبًا';

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
  String get language => 'اللغة';
}
