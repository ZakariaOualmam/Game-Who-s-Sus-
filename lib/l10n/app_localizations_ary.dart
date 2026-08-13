// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Moroccan Arabic (`ary`).
class AppLocalizationsAry extends AppLocalizations {
  AppLocalizationsAry([String locale = 'ary']) : super(locale);

  @override
  String get appName => 'Word Imposter';

  @override
  String get appNameWord => 'WORD';

  @override
  String get appNameImposter => 'IMPOSTER';

  @override
  String get splashTagline => 'لعبة الكلمات دي السهرات';

  @override
  String get homeTagline => 'لقّي المحتال بين صحابك';

  @override
  String get homeOffline => 'بلا إنترنات';

  @override
  String get homeOnline => 'أونلاين';

  @override
  String get homeOnlineComingSoon => 'أونلاين · قريب';

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
  String get language => 'اللغة';
}
