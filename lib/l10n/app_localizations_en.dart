// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Word Imposter';

  @override
  String get appNameWord => 'WORD';

  @override
  String get appNameImposter => 'IMPOSTER';

  @override
  String get splashTagline => 'party word game';

  @override
  String get homeTagline => 'Find the imposter among your friends';

  @override
  String get homeOffline => 'OFFLINE';

  @override
  String get homeOnline => 'ONLINE';

  @override
  String get homeOnlineComingSoon => 'ONLINE  ·  COMING SOON';

  @override
  String get homeHowToPlay => 'HOW TO PLAY';

  @override
  String get howToPlayTitle => 'HOW TO PLAY';

  @override
  String get rule1 =>
      'Everyone gets the same secret word — except the imposter.';

  @override
  String get rule2 => 'Describe the word without ever saying it.';

  @override
  String get rule3 => 'Spot who doesn’t know the word, then vote them out.';

  @override
  String get rule4 => 'The imposter gets one final guess.';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get playersTitle => 'PLAYERS';

  @override
  String get addPlayers => 'Add players';

  @override
  String get playerNameHint => 'Player name';

  @override
  String get addPlayerButton => 'ADD PLAYER';

  @override
  String get nameAlreadyAdded => 'Name already added';

  @override
  String maximumPlayers(int count) {
    return 'Maximum $count players';
  }

  @override
  String addPlayersToStart(int min, int max) {
    return 'Add $min–$max players to start';
  }

  @override
  String get pickCategoryButton => 'PICK CATEGORY';

  @override
  String addPlayersMinButton(int count) {
    return 'ADD $count+ PLAYERS';
  }

  @override
  String get categoryTitle => 'CATEGORY';

  @override
  String get pickWordCategory => 'Pick a word category';

  @override
  String get couldNotLoadCategories => 'Couldn\'t load categories';

  @override
  String get tryAgain => 'TRY AGAIN';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryAnimals => 'Animals';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryMovies => 'Movies';

  @override
  String get categoryPlaces => 'Places';

  @override
  String get categoryJobs => 'Jobs';

  @override
  String get categoryObjects => 'Objects';

  @override
  String get categoryGames => 'Games';

  @override
  String get categoryCelebrities => 'Celebrities';

  @override
  String get categoryRandom => 'Random';

  @override
  String get secretRoleTitle => 'SECRET ROLE';

  @override
  String get passThePhone => 'PASS THE PHONE';

  @override
  String get noPeeking => 'No peeking at the next player';

  @override
  String get passPhoneTo => 'Pass the phone to';

  @override
  String get imReady => 'I\'M READY';

  @override
  String get startDiscussion => 'START THE DISCUSSION';

  @override
  String get yourSecretWordIs => 'YOUR SECRET WORD IS';

  @override
  String get dontSayTheWord => 'Don\'t say the word';

  @override
  String get youAreTheImposter => 'YOU ARE THE\nIMPOSTER';

  @override
  String get blendInDontGetCaught => 'Blend in. Don\'t get caught.';

  @override
  String get discussTitle => 'DISCUSS';

  @override
  String get discuss => 'DISCUSS!';

  @override
  String get figureOutWhosImp => 'Figure out who doesn\'t know the word';

  @override
  String get startVoting => 'START VOTING';

  @override
  String get votingTitle => 'VOTING';

  @override
  String get whoIsTheImposter => 'Who is the imposter?';

  @override
  String get voteInSecret => 'Vote in secret';

  @override
  String get tapAPlayerToVote => 'Tap a player to vote';

  @override
  String get change => 'CHANGE';

  @override
  String voteForName(String name) {
    return 'VOTE FOR $name';
  }

  @override
  String get votesTitle => 'VOTES';

  @override
  String get itsATie => 'IT\'S A TIE!';

  @override
  String get noOneVotedOut => 'No one gets voted out';

  @override
  String get mostSuspected => 'Most suspected';

  @override
  String get revealTheImposter => 'REVEAL THE IMPOSTER';

  @override
  String get imposterTitle => 'IMPOSTER';

  @override
  String get theImposterWas => 'THE IMPOSTER WAS';

  @override
  String get finalGuessHint => 'The imposter gets one final guess';

  @override
  String get finalChance => 'FINAL CHANCE';

  @override
  String get outcomeCrewCaught => 'The crew caught the imposter!';

  @override
  String get outcomeTieGotAway => 'The vote was a tie — the imposter got away!';

  @override
  String get outcomeFooledEveryone => 'The imposter fooled everyone!';

  @override
  String get pickSecretWord => 'Pick the secret word';

  @override
  String get crewWins => 'CREW WINS!';

  @override
  String get imposterWins => 'IMPOSTER WINS!';

  @override
  String get subtitleAlmostMadeIt =>
      'The imposter almost made it… but the crew caught them!';

  @override
  String get subtitleCaughtMissed =>
      'The imposter was caught and missed the word!';

  @override
  String get subtitleGuessedWord => 'The imposter guessed the word!';

  @override
  String get subtitleEscaped => 'The imposter escaped the vote!';

  @override
  String get theWordWas => 'THE WORD WAS';

  @override
  String get guessedIt => 'The imposter guessed it!';

  @override
  String get didntGuessIt => 'The imposter didn\'t guess it';

  @override
  String get pointsCrewPlusOne => 'Every crew member +1';

  @override
  String get pointsImposterPlusOne => 'Imposter +1';

  @override
  String get pointsImposterPlusTwo => 'Imposter +2';

  @override
  String get detailCaughtMissed => 'Imposter was caught and missed the word';

  @override
  String get detailDiscoveredGuessed => 'Discovered but guessed the word';

  @override
  String get detailSurvived => 'Survived the vote';

  @override
  String get seeScoreboard => 'SEE SCOREBOARD';

  @override
  String get scoresTitle => 'SCORES';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get homeButton => 'HOME';

  @override
  String get language => 'Language';
}
