import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ary.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ary'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WHO\'S SUS'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'party word game'**
  String get splashTagline;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Find the imposter among your friends'**
  String get homeTagline;

  /// No description provided for @homeOffline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get homeOffline;

  /// No description provided for @homeOnline.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get homeOnline;

  /// No description provided for @homeHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get homeHowToPlay;

  /// No description provided for @howToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'HOW TO PLAY'**
  String get howToPlayTitle;

  /// No description provided for @rule1.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets the same secret word — except the imposter.'**
  String get rule1;

  /// No description provided for @rule2.
  ///
  /// In en, this message translates to:
  /// **'Describe the word without ever saying it.'**
  String get rule2;

  /// No description provided for @rule3.
  ///
  /// In en, this message translates to:
  /// **'Spot who doesn’t know the word, then vote them out.'**
  String get rule3;

  /// No description provided for @rule4.
  ///
  /// In en, this message translates to:
  /// **'The imposter gets one final guess.'**
  String get rule4;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// No description provided for @playersTitle.
  ///
  /// In en, this message translates to:
  /// **'PLAYERS'**
  String get playersTitle;

  /// No description provided for @addPlayers.
  ///
  /// In en, this message translates to:
  /// **'Add players'**
  String get addPlayers;

  /// No description provided for @playerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerNameHint;

  /// No description provided for @addPlayerButton.
  ///
  /// In en, this message translates to:
  /// **'ADD PLAYER'**
  String get addPlayerButton;

  /// No description provided for @nameAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Name already added'**
  String get nameAlreadyAdded;

  /// Shown when trying to add more than the maximum number of players.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} players'**
  String maximumPlayers(int count);

  /// Empty-state hint on the player setup screen.
  ///
  /// In en, this message translates to:
  /// **'Add {min}–{max} players to start'**
  String addPlayersToStart(int min, int max);

  /// No description provided for @pickCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'PICK CATEGORY'**
  String get pickCategoryButton;

  /// Primary button label while below the minimum player count.
  ///
  /// In en, this message translates to:
  /// **'ADD {count}+ PLAYERS'**
  String addPlayersMinButton(int count);

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get categoryTitle;

  /// No description provided for @pickWordCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a word category'**
  String get pickWordCategory;

  /// No description provided for @couldNotLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load categories'**
  String get couldNotLoadCategories;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get tryAgain;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get categoryAnimals;

  /// No description provided for @categorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get categorySports;

  /// No description provided for @categoryMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get categoryMovies;

  /// No description provided for @categoryPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get categoryPlaces;

  /// No description provided for @categoryJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get categoryJobs;

  /// No description provided for @categoryObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get categoryObjects;

  /// No description provided for @categoryGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get categoryGames;

  /// No description provided for @categoryCelebrities.
  ///
  /// In en, this message translates to:
  /// **'Celebrities'**
  String get categoryCelebrities;

  /// No description provided for @categoryRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get categoryRandom;

  /// No description provided for @secretRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'SECRET ROLE'**
  String get secretRoleTitle;

  /// No description provided for @passThePhone.
  ///
  /// In en, this message translates to:
  /// **'PASS THE PHONE'**
  String get passThePhone;

  /// No description provided for @noPeeking.
  ///
  /// In en, this message translates to:
  /// **'No peeking at the next player'**
  String get noPeeking;

  /// No description provided for @passPhoneTo.
  ///
  /// In en, this message translates to:
  /// **'Pass the phone to'**
  String get passPhoneTo;

  /// No description provided for @imReady.
  ///
  /// In en, this message translates to:
  /// **'I\'M READY'**
  String get imReady;

  /// No description provided for @startDiscussion.
  ///
  /// In en, this message translates to:
  /// **'START THE DISCUSSION'**
  String get startDiscussion;

  /// No description provided for @yourSecretWordIs.
  ///
  /// In en, this message translates to:
  /// **'YOUR SECRET WORD IS'**
  String get yourSecretWordIs;

  /// No description provided for @dontSayTheWord.
  ///
  /// In en, this message translates to:
  /// **'Don\'t say the word'**
  String get dontSayTheWord;

  /// No description provided for @youAreTheImposter.
  ///
  /// In en, this message translates to:
  /// **'YOU ARE THE\nIMPOSTER'**
  String get youAreTheImposter;

  /// No description provided for @blendInDontGetCaught.
  ///
  /// In en, this message translates to:
  /// **'Blend in. Don\'t get caught.'**
  String get blendInDontGetCaught;

  /// No description provided for @discussTitle.
  ///
  /// In en, this message translates to:
  /// **'DISCUSS'**
  String get discussTitle;

  /// No description provided for @discuss.
  ///
  /// In en, this message translates to:
  /// **'DISCUSS!'**
  String get discuss;

  /// No description provided for @figureOutWhosImp.
  ///
  /// In en, this message translates to:
  /// **'Figure out who doesn\'t know the word'**
  String get figureOutWhosImp;

  /// No description provided for @startVoting.
  ///
  /// In en, this message translates to:
  /// **'START VOTING'**
  String get startVoting;

  /// No description provided for @votingTitle.
  ///
  /// In en, this message translates to:
  /// **'VOTING'**
  String get votingTitle;

  /// No description provided for @whoIsTheImposter.
  ///
  /// In en, this message translates to:
  /// **'Who is the imposter?'**
  String get whoIsTheImposter;

  /// No description provided for @voteInSecret.
  ///
  /// In en, this message translates to:
  /// **'Vote in secret'**
  String get voteInSecret;

  /// No description provided for @tapAPlayerToVote.
  ///
  /// In en, this message translates to:
  /// **'Tap a player to vote'**
  String get tapAPlayerToVote;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get change;

  /// Confirmation button for a vote targeting a specific player.
  ///
  /// In en, this message translates to:
  /// **'VOTE FOR {name}'**
  String voteForName(String name);

  /// No description provided for @votesTitle.
  ///
  /// In en, this message translates to:
  /// **'VOTES'**
  String get votesTitle;

  /// No description provided for @itsATie.
  ///
  /// In en, this message translates to:
  /// **'IT\'S A TIE!'**
  String get itsATie;

  /// No description provided for @noOneVotedOut.
  ///
  /// In en, this message translates to:
  /// **'No one gets voted out'**
  String get noOneVotedOut;

  /// No description provided for @mostSuspected.
  ///
  /// In en, this message translates to:
  /// **'Most suspected'**
  String get mostSuspected;

  /// No description provided for @revealTheImposter.
  ///
  /// In en, this message translates to:
  /// **'REVEAL THE IMPOSTER'**
  String get revealTheImposter;

  /// No description provided for @imposterTitle.
  ///
  /// In en, this message translates to:
  /// **'IMPOSTER'**
  String get imposterTitle;

  /// No description provided for @theImposterWas.
  ///
  /// In en, this message translates to:
  /// **'THE IMPOSTER WAS'**
  String get theImposterWas;

  /// No description provided for @finalGuessHint.
  ///
  /// In en, this message translates to:
  /// **'The imposter gets one final guess'**
  String get finalGuessHint;

  /// No description provided for @finalChance.
  ///
  /// In en, this message translates to:
  /// **'FINAL CHANCE'**
  String get finalChance;

  /// No description provided for @outcomeCrewCaught.
  ///
  /// In en, this message translates to:
  /// **'The crew caught the imposter!'**
  String get outcomeCrewCaught;

  /// No description provided for @outcomeTieGotAway.
  ///
  /// In en, this message translates to:
  /// **'The vote was a tie — the imposter got away!'**
  String get outcomeTieGotAway;

  /// No description provided for @outcomeFooledEveryone.
  ///
  /// In en, this message translates to:
  /// **'The imposter fooled everyone!'**
  String get outcomeFooledEveryone;

  /// No description provided for @pickSecretWord.
  ///
  /// In en, this message translates to:
  /// **'Pick the secret word'**
  String get pickSecretWord;

  /// No description provided for @crewWins.
  ///
  /// In en, this message translates to:
  /// **'CREW WINS!'**
  String get crewWins;

  /// No description provided for @imposterWins.
  ///
  /// In en, this message translates to:
  /// **'IMPOSTER WINS!'**
  String get imposterWins;

  /// No description provided for @subtitleAlmostMadeIt.
  ///
  /// In en, this message translates to:
  /// **'The imposter almost made it… but the crew caught them!'**
  String get subtitleAlmostMadeIt;

  /// No description provided for @subtitleCaughtMissed.
  ///
  /// In en, this message translates to:
  /// **'The imposter was caught and missed the word!'**
  String get subtitleCaughtMissed;

  /// No description provided for @subtitleGuessedWord.
  ///
  /// In en, this message translates to:
  /// **'The imposter guessed the word!'**
  String get subtitleGuessedWord;

  /// No description provided for @subtitleEscaped.
  ///
  /// In en, this message translates to:
  /// **'The imposter escaped the vote!'**
  String get subtitleEscaped;

  /// No description provided for @theWordWas.
  ///
  /// In en, this message translates to:
  /// **'THE WORD WAS'**
  String get theWordWas;

  /// No description provided for @guessedIt.
  ///
  /// In en, this message translates to:
  /// **'The imposter guessed it!'**
  String get guessedIt;

  /// No description provided for @didntGuessIt.
  ///
  /// In en, this message translates to:
  /// **'The imposter didn\'t guess it'**
  String get didntGuessIt;

  /// No description provided for @pointsCrewPlusOne.
  ///
  /// In en, this message translates to:
  /// **'Every crew member +1'**
  String get pointsCrewPlusOne;

  /// No description provided for @pointsImposterPlusOne.
  ///
  /// In en, this message translates to:
  /// **'Imposter +1'**
  String get pointsImposterPlusOne;

  /// No description provided for @pointsImposterPlusTwo.
  ///
  /// In en, this message translates to:
  /// **'Imposter +2'**
  String get pointsImposterPlusTwo;

  /// No description provided for @detailCaughtMissed.
  ///
  /// In en, this message translates to:
  /// **'Imposter was caught and missed the word'**
  String get detailCaughtMissed;

  /// No description provided for @detailDiscoveredGuessed.
  ///
  /// In en, this message translates to:
  /// **'Discovered but guessed the word'**
  String get detailDiscoveredGuessed;

  /// No description provided for @detailSurvived.
  ///
  /// In en, this message translates to:
  /// **'Survived the vote'**
  String get detailSurvived;

  /// No description provided for @seeScoreboard.
  ///
  /// In en, this message translates to:
  /// **'SEE SCOREBOARD'**
  String get seeScoreboard;

  /// No description provided for @scoresTitle.
  ///
  /// In en, this message translates to:
  /// **'SCORES'**
  String get scoresTitle;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  /// No description provided for @homeButton.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get homeButton;

  /// No description provided for @onlineConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get onlineConnecting;

  /// No description provided for @onlineFailedConnect.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect. Please try again.'**
  String get onlineFailedConnect;

  /// No description provided for @onlineWaitConnecting.
  ///
  /// In en, this message translates to:
  /// **'Please wait, connecting...'**
  String get onlineWaitConnecting;

  /// No description provided for @onlineTagline.
  ///
  /// In en, this message translates to:
  /// **'Play with friends anywhere!'**
  String get onlineTagline;

  /// No description provided for @onlineCreateGame.
  ///
  /// In en, this message translates to:
  /// **'CREATE GAME'**
  String get onlineCreateGame;

  /// No description provided for @onlineJoinGame.
  ///
  /// In en, this message translates to:
  /// **'JOIN GAME'**
  String get onlineJoinGame;

  /// No description provided for @onlineMenuHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a room and share the code, or join an existing room with a 6-character code.'**
  String get onlineMenuHelp;

  /// No description provided for @onlineEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get onlineEnterName;

  /// No description provided for @onlineRoomCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Room code must be 6 characters'**
  String get onlineRoomCodeLength;

  /// Shown when creating a room fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to create room: {error}'**
  String onlineCreateFailed(String error);

  /// Shown when joining a room fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to join room: {error}'**
  String onlineJoinFailed(String error);

  /// Shown when leaving a room fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave room: {error}'**
  String onlineLeaveFailed(String error);

  /// Shown when starting an online game fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to start game: {error}'**
  String onlineStartFailed(String error);

  /// No description provided for @onlineStartNewGame.
  ///
  /// In en, this message translates to:
  /// **'Start a new game'**
  String get onlineStartNewGame;

  /// No description provided for @onlineJoinExistingGame.
  ///
  /// In en, this message translates to:
  /// **'Join an existing game'**
  String get onlineJoinExistingGame;

  /// No description provided for @onlineYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onlineYourNameHint;

  /// No description provided for @onlineRoomCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Room code (e.g., A3X9K2)'**
  String get onlineRoomCodeHint;

  /// No description provided for @onlineCreateRoom.
  ///
  /// In en, this message translates to:
  /// **'CREATE ROOM'**
  String get onlineCreateRoom;

  /// No description provided for @onlineJoinRoom.
  ///
  /// In en, this message translates to:
  /// **'JOIN ROOM'**
  String get onlineJoinRoom;

  /// No description provided for @onlineCreateRoomHelp.
  ///
  /// In en, this message translates to:
  /// **'You will be the host and get a room code to share with others.'**
  String get onlineCreateRoomHelp;

  /// No description provided for @onlineJoinRoomHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character room code from the host.'**
  String get onlineJoinRoomHelp;

  /// No description provided for @lobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'LOBBY'**
  String get lobbyTitle;

  /// No description provided for @onlineFailedLoadPlayers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load players'**
  String get onlineFailedLoadPlayers;

  /// No description provided for @onlineDisconnected.
  ///
  /// In en, this message translates to:
  /// **'You have been disconnected from the room'**
  String get onlineDisconnected;

  /// No description provided for @onlineRoomClosed.
  ///
  /// In en, this message translates to:
  /// **'Room was closed by host'**
  String get onlineRoomClosed;

  /// No description provided for @onlineCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Room code copied to clipboard!'**
  String get onlineCodeCopied;

  /// No description provided for @onlineNotLobby.
  ///
  /// In en, this message translates to:
  /// **'Room is no longer in lobby state'**
  String get onlineNotLobby;

  /// No description provided for @onlineNeedPlayers.
  ///
  /// In en, this message translates to:
  /// **'Need at least 4 players to start'**
  String get onlineNeedPlayers;

  /// No description provided for @roomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'ROOM CODE'**
  String get roomCodeLabel;

  /// No description provided for @onlineTapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get onlineTapToCopy;

  /// No description provided for @playersLabel.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersLabel;

  /// No description provided for @hostLabel.
  ///
  /// In en, this message translates to:
  /// **'HOST'**
  String get hostLabel;

  /// No description provided for @onlineStartGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get onlineStartGame;

  /// No description provided for @onlineWaitingHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for host to start the game...'**
  String get onlineWaitingHost;

  /// No description provided for @winnerTitle.
  ///
  /// In en, this message translates to:
  /// **'WINNER'**
  String get winnerTitle;

  /// No description provided for @onlineGameTitle.
  ///
  /// In en, this message translates to:
  /// **'GAME'**
  String get onlineGameTitle;

  /// No description provided for @onlineWaitingForHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for host...'**
  String get onlineWaitingForHost;

  /// No description provided for @onlineHostSelecting.
  ///
  /// In en, this message translates to:
  /// **'Host is selecting category...'**
  String get onlineHostSelecting;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get ready;

  /// No description provided for @onlineNoOneTie.
  ///
  /// In en, this message translates to:
  /// **'No one (tie)'**
  String get onlineNoOneTie;

  /// No description provided for @onlineUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get onlineUnknown;

  /// No description provided for @onlineShowWinner.
  ///
  /// In en, this message translates to:
  /// **'SHOW WINNER'**
  String get onlineShowWinner;

  /// No description provided for @onlineWaitingImposterGuess.
  ///
  /// In en, this message translates to:
  /// **'Waiting for imposter guess...'**
  String get onlineWaitingImposterGuess;

  /// No description provided for @onlineGuessSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Guess submitted.'**
  String get onlineGuessSubmitted;

  /// No description provided for @onlineFinalizeRound.
  ///
  /// In en, this message translates to:
  /// **'FINALIZE ROUND'**
  String get onlineFinalizeRound;

  /// No description provided for @onlineNextRound.
  ///
  /// In en, this message translates to:
  /// **'NEXT ROUND'**
  String get onlineNextRound;

  /// No description provided for @onlineError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onlineError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'GAME SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get settingsPlayers;

  /// No description provided for @settingsPlayersHint.
  ///
  /// In en, this message translates to:
  /// **'Number of players in the game'**
  String get settingsPlayersHint;

  /// No description provided for @settingsImposters.
  ///
  /// In en, this message translates to:
  /// **'Imposters'**
  String get settingsImposters;

  /// No description provided for @settingsImpostersHint.
  ///
  /// In en, this message translates to:
  /// **'Number of imposters among the players'**
  String get settingsImpostersHint;

  /// No description provided for @settingsDiscussionTime.
  ///
  /// In en, this message translates to:
  /// **'Discussion time'**
  String get settingsDiscussionTime;

  /// No description provided for @settingsVotingTime.
  ///
  /// In en, this message translates to:
  /// **'Voting time'**
  String get settingsVotingTime;

  /// No description provided for @settingsAnonymousVoting.
  ///
  /// In en, this message translates to:
  /// **'Anonymous voting'**
  String get settingsAnonymousVoting;

  /// No description provided for @settingsAnonymousVotingHelp.
  ///
  /// In en, this message translates to:
  /// **'Hide who voted for whom'**
  String get settingsAnonymousVotingHelp;

  /// No description provided for @settingsImposterClue.
  ///
  /// In en, this message translates to:
  /// **'Imposter clue'**
  String get settingsImposterClue;

  /// No description provided for @settingsImposterClueHelp.
  ///
  /// In en, this message translates to:
  /// **'Crew members get a hint about the imposter'**
  String get settingsImposterClueHelp;

  /// No description provided for @settingsOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get settingsOff;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE SETTINGS'**
  String get settingsSave;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get settingsClose;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// Shown when saving game settings fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings: {error}'**
  String settingsSaveFailed(String error);

  /// No description provided for @settingsHostControls.
  ///
  /// In en, this message translates to:
  /// **'Host controls the settings'**
  String get settingsHostControls;

  /// No description provided for @settingsHostControlsHelp.
  ///
  /// In en, this message translates to:
  /// **'Only the host can change these before the game starts'**
  String get settingsHostControlsHelp;

  /// No description provided for @settingsPlayersAdded.
  ///
  /// In en, this message translates to:
  /// **'Players added'**
  String get settingsPlayersAdded;

  /// A duration in seconds, e.g. 30s.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String settingsSeconds(int count);

  /// A duration in whole minutes, e.g. 1m.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String settingsMinutes(int count);

  /// A duration with minutes and seconds, e.g. 1m 30s.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String settingsMinSec(int minutes, int seconds);

  /// The supported player count range.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} players'**
  String settingsPlayersRange(int min, int max);

  /// No description provided for @settingsImpostersUnsupported.
  ///
  /// In en, this message translates to:
  /// **'2-imposter games are not supported yet'**
  String get settingsImpostersUnsupported;

  /// Shown when the player count cannot host two imposters.
  ///
  /// In en, this message translates to:
  /// **'Need at least {count} players for 2 imposters'**
  String settingsImpostersNeedPlayers(int count);

  /// No description provided for @settingsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid settings. Check the options and try again.'**
  String get settingsInvalid;

  /// Start button label while the room has not filled to the configured player count.
  ///
  /// In en, this message translates to:
  /// **'WAITING FOR {current}/{expected} PLAYERS'**
  String onlineWaitingForPlayers(int current, int expected);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ary', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ary':
      return AppLocalizationsAry();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
