// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Word Imposter';

  @override
  String get appNameWord => 'WORD';

  @override
  String get appNameImposter => 'IMPOSTER';

  @override
  String get splashTagline => 'jeu de mots pour soirées';

  @override
  String get homeTagline => 'Trouvez l\'imposteur parmi vos amis';

  @override
  String get homeOffline => 'HORS LIGNE';

  @override
  String get homeOnlineComingSoon => 'EN LIGNE · BIENTÔT';

  @override
  String get homeHowToPlay => 'COMMENT JOUER';

  @override
  String get howToPlayTitle => 'COMMENT JOUER';

  @override
  String get rule1 =>
      'Tout le monde reçoit le même mot secret — sauf l\'imposteur.';

  @override
  String get rule2 => 'Décrivez le mot sans jamais le prononcer.';

  @override
  String get rule3 =>
      'Repérez celui qui ne connaît pas le mot, puis votez pour l\'éliminer.';

  @override
  String get rule4 => 'L\'imposteur a droit à une dernière supposition.';

  @override
  String get gotIt => 'COMPRIS';

  @override
  String get playersTitle => 'JOUEURS';

  @override
  String get addPlayers => 'Ajouter des joueurs';

  @override
  String get playerNameHint => 'Nom du joueur';

  @override
  String get addPlayerButton => 'AJOUTER';

  @override
  String get nameAlreadyAdded => 'Ce nom existe déjà';

  @override
  String maximumPlayers(int count) {
    return 'Maximum $count joueurs';
  }

  @override
  String addPlayersToStart(int min, int max) {
    return 'Ajoutez $min à $max joueurs pour commencer';
  }

  @override
  String get pickCategoryButton => 'CHOISIR UNE CATÉGORIE';

  @override
  String addPlayersMinButton(int count) {
    return 'AJOUTER $count+ JOUEURS';
  }

  @override
  String get categoryTitle => 'CATÉGORIE';

  @override
  String get pickWordCategory => 'Choisissez une catégorie';

  @override
  String get couldNotLoadCategories => 'Impossible de charger les catégories';

  @override
  String get tryAgain => 'RÉESSAYER';

  @override
  String get categoryFood => 'Nourriture';

  @override
  String get categoryAnimals => 'Animaux';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryMovies => 'Films';

  @override
  String get categoryPlaces => 'Lieux';

  @override
  String get categoryJobs => 'Métiers';

  @override
  String get categoryObjects => 'Objets';

  @override
  String get categoryGames => 'Jeux';

  @override
  String get categoryCelebrities => 'Célébrités';

  @override
  String get categoryRandom => 'Aléatoire';

  @override
  String get secretRoleTitle => 'RÔLE SECRET';

  @override
  String get passThePhone => 'PASSE LE TÉLÉPHONE';

  @override
  String get noPeeking => 'Pas de regard indiscret sur le prochain joueur';

  @override
  String get passPhoneTo => 'Passe le téléphone à';

  @override
  String get imReady => 'JE SUIS PRÊT';

  @override
  String get startDiscussion => 'LANCER LA DISCUSSION';

  @override
  String get yourSecretWordIs => 'TON MOT SECRET EST';

  @override
  String get dontSayTheWord => 'Ne prononce pas le mot';

  @override
  String get youAreTheImposter => 'TU ES\nL\'IMPOSTEUR';

  @override
  String get blendInDontGetCaught =>
      'Fonds-toi dans la masse. Ne te fais pas prendre.';

  @override
  String get discussTitle => 'DISCUSSION';

  @override
  String get discuss => 'DISCUTEZ !';

  @override
  String get figureOutWhosImp => 'Trouvez qui ne connaît pas le mot';

  @override
  String get startVoting => 'LANCER LE VOTE';

  @override
  String get votingTitle => 'VOTE';

  @override
  String get whoIsTheImposter => 'Qui est l\'imposteur ?';

  @override
  String get voteInSecret => 'Votez en secret';

  @override
  String get tapAPlayerToVote => 'Touchez un joueur pour voter';

  @override
  String get change => 'CHANGER';

  @override
  String voteForName(String name) {
    return 'VOTER POUR $name';
  }

  @override
  String get votesTitle => 'RÉSULTATS';

  @override
  String get itsATie => 'ÉGALITÉ !';

  @override
  String get noOneVotedOut => 'Personne n\'est éliminé';

  @override
  String get mostSuspected => 'Le plus suspecté';

  @override
  String get revealTheImposter => 'RÉVÉLER L\'IMPOSTEUR';

  @override
  String get imposterTitle => 'IMPOSTEUR';

  @override
  String get theImposterWas => 'L\'IMPOSTEUR ÉTAIT';

  @override
  String get finalGuessHint =>
      'L\'imposteur a droit à une dernière supposition';

  @override
  String get finalChance => 'DERNIÈRE CHANCE';

  @override
  String get outcomeCrewCaught => 'L\'équipe a attrapé l\'imposteur !';

  @override
  String get outcomeTieGotAway => 'Égalité — l\'imposteur s\'est échappé !';

  @override
  String get outcomeFooledEveryone => 'L\'imposteur a trompé tout le monde !';

  @override
  String get pickSecretWord => 'Trouve le mot secret';

  @override
  String get crewWins => 'L\'ÉQUIPE GAGNE !';

  @override
  String get imposterWins => 'L\'IMPOSTEUR GAGNE !';

  @override
  String get subtitleAlmostMadeIt =>
      'L\'imposteur a failli réussir… mais l\'équipe l\'a attrapé !';

  @override
  String get subtitleCaughtMissed =>
      'L\'imposteur a été attrapé et a raté le mot !';

  @override
  String get subtitleGuessedWord => 'L\'imposteur a deviné le mot !';

  @override
  String get subtitleEscaped => 'L\'imposteur a échappé au vote !';

  @override
  String get theWordWas => 'LE MOT ÉTAIT';

  @override
  String get guessedIt => 'L\'imposteur l\'a deviné !';

  @override
  String get didntGuessIt => 'L\'imposteur ne l\'a pas deviné';

  @override
  String get pointsCrewPlusOne => 'Chaque membre de l\'équipe +1';

  @override
  String get pointsImposterPlusOne => 'Imposteur +1';

  @override
  String get pointsImposterPlusTwo => 'Imposteur +2';

  @override
  String get detailCaughtMissed => 'Attrapé mais a raté le mot';

  @override
  String get detailDiscoveredGuessed => 'Découvert mais a deviné le mot';

  @override
  String get detailSurvived => 'A survécu au vote';

  @override
  String get seeScoreboard => 'VOIR LE CLASSEMENT';

  @override
  String get scoresTitle => 'SCORES';

  @override
  String get playAgain => 'REJOUER';

  @override
  String get homeButton => 'ACCUEIL';

  @override
  String get language => 'Langue';
}
