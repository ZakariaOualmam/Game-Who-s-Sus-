// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'WHO\'S SUS';

  @override
  String get splashTagline => 'jeu de mots pour soirées';

  @override
  String get homeTagline => 'Trouvez l\'imposteur parmi vos amis';

  @override
  String get homeOffline => 'HORS LIGNE';

  @override
  String get homeOnline => 'EN LIGNE';

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
  String get onlineConnecting => 'Connexion...';

  @override
  String get onlineFailedConnect =>
      'Échec de la connexion. Veuillez réessayer.';

  @override
  String get onlineWaitConnecting => 'Veuillez patienter, connexion...';

  @override
  String get onlineTagline => 'Jouez avec vos amis où que vous soyez !';

  @override
  String get onlineCreateGame => 'CRÉER UNE PARTIE';

  @override
  String get onlineJoinGame => 'REJOINDRE UNE PARTIE';

  @override
  String get onlineMenuHelp =>
      'Créez une partie et partagez le code, ou rejoignez une partie existante avec un code à 6 caractères.';

  @override
  String get onlineEnterName => 'Veuillez saisir votre nom';

  @override
  String get onlineRoomCodeLength =>
      'Le code de la partie doit comporter 6 caractères';

  @override
  String onlineCreateFailed(String error) {
    return 'Échec de la création de la partie : $error';
  }

  @override
  String onlineJoinFailed(String error) {
    return 'Échec de la jonction à la partie : $error';
  }

  @override
  String onlineLeaveFailed(String error) {
    return 'Échec de la sortie de la partie : $error';
  }

  @override
  String onlineStartFailed(String error) {
    return 'Échec du lancement de la partie : $error';
  }

  @override
  String get onlineStartNewGame => 'Lancer une nouvelle partie';

  @override
  String get onlineJoinExistingGame => 'Rejoindre une partie existante';

  @override
  String get onlineYourNameHint => 'Votre nom';

  @override
  String get onlineRoomCodeHint => 'Code de la partie (ex. : A3X9K2)';

  @override
  String get onlineCreateRoom => 'CRÉER LA PARTIE';

  @override
  String get onlineJoinRoom => 'REJOINDRE';

  @override
  String get onlineCreateRoomHelp =>
      'Vous serez l\'hôte et recevrez un code à partager avec les autres.';

  @override
  String get onlineJoinRoomHelp =>
      'Saisissez le code à 6 caractères de l\'hôte.';

  @override
  String get lobbyTitle => 'SALON';

  @override
  String get onlineFailedLoadPlayers => 'Échec du chargement des joueurs';

  @override
  String get onlineDisconnected => 'Vous avez été déconnecté de la partie';

  @override
  String get onlineRoomClosed => 'La partie a été fermée par l\'hôte';

  @override
  String get onlineCodeCopied => 'Code copié dans le presse-papiers !';

  @override
  String get onlineNotLobby => 'La partie n\'est plus en état de salon';

  @override
  String get onlineNeedPlayers => 'Il faut au moins 4 joueurs pour commencer';

  @override
  String get roomCodeLabel => 'CODE DE LA PARTIE';

  @override
  String get onlineTapToCopy => 'Touchez pour copier';

  @override
  String get playersLabel => 'Joueurs';

  @override
  String get hostLabel => 'HÔTE';

  @override
  String get onlineStartGame => 'LANCER LA PARTIE';

  @override
  String get onlineWaitingHost =>
      'En attente de l\'hôte pour lancer la partie...';

  @override
  String get winnerTitle => 'GAGNANT';

  @override
  String get onlineGameTitle => 'PARTIE';

  @override
  String get onlineWaitingForHost => 'En attente de l\'hôte...';

  @override
  String get onlineHostSelecting => 'L\'hôte choisit une catégorie...';

  @override
  String get ready => 'PRÊT';

  @override
  String get onlineNoOneTie => 'Personne (égalité)';

  @override
  String get onlineUnknown => 'Inconnu';

  @override
  String get onlineShowWinner => 'MONTRER LE GAGNANT';

  @override
  String get onlineWaitingImposterGuess =>
      'En attente de la supposition de l\'imposteur...';

  @override
  String get onlineGuessSubmitted => 'Supposition envoyée.';

  @override
  String get onlineFinalizeRound => 'TERMINER LE MANCHE';

  @override
  String get onlineNextRound => 'MANCHE SUIVANTE';

  @override
  String get onlineError => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get settingsTitle => 'PARAMÈTRES DU JEU';

  @override
  String get settingsPlayers => 'Joueurs';

  @override
  String get settingsPlayersHint => 'Nombre de joueurs dans la partie';

  @override
  String get settingsImposters => 'Imposteurs';

  @override
  String get settingsImpostersHint => 'Nombre d\'imposteurs parmi les joueurs';

  @override
  String get settingsDiscussionTime => 'Temps de discussion';

  @override
  String get settingsVotingTime => 'Temps de vote';

  @override
  String get settingsAnonymousVoting => 'Vote anonyme';

  @override
  String get settingsAnonymousVotingHelp => 'Masquer qui a voté pour qui';

  @override
  String get settingsImposterClue => 'Indice sur l\'imposteur';

  @override
  String get settingsImposterClueHelp =>
      'L\'équipage reçoit un indice sur l\'imposteur';

  @override
  String get settingsOn => 'ACTIVÉ';

  @override
  String get settingsOff => 'DÉSACTIVÉ';

  @override
  String get settingsSave => 'ENREGISTRER';

  @override
  String get settingsClose => 'FERMER';

  @override
  String get settingsSaved => 'Paramètres enregistrés';

  @override
  String settingsSaveFailed(String error) {
    return 'Échec de l\'enregistrement des paramètres : $error';
  }

  @override
  String get settingsHostControls => 'L\'hôte contrôle les paramètres';

  @override
  String get settingsHostControlsHelp =>
      'Seul l\'hôte peut les modifier avant le début de la partie';

  @override
  String get settingsPlayersAdded => 'Joueurs ajoutés';

  @override
  String settingsSeconds(int count) {
    return '$count s';
  }

  @override
  String settingsMinutes(int count) {
    return '$count min';
  }

  @override
  String settingsMinSec(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String settingsPlayersRange(int min, int max) {
    return '$min–$max joueurs';
  }

  @override
  String get settingsImpostersUnsupported =>
      'Les parties à 2 imposteurs ne sont pas encore prises en charge';

  @override
  String settingsImpostersNeedPlayers(int count) {
    return 'Il faut au moins $count joueurs pour 2 imposteurs';
  }

  @override
  String get settingsInvalid =>
      'Paramètres invalides. Vérifiez les options et réessayez.';

  @override
  String onlineWaitingForPlayers(int current, int expected) {
    return 'EN ATTENTE DE $current/$expected JOUEURS';
  }

  @override
  String get timeLeft => 'Temps restant';

  @override
  String get language => 'Langue';
}
