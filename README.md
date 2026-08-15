# Who's Sus

A social deduction party game for phones. Everyone knows the secret word —
except the imposter. Describe the word, figure out who's lying, then vote them
out before they guess the word and get away.

## The Rules and How to Play
- Choose one of the word categories (Food, Animals, Celebrities, ...)
- Each player receives the same secret word/name, except the imposter
- One by one, everyone says a word related to the secret word without saying it
    - Example: The secret word is Dwayne Johnson. Valid clues would be "Actor", "Wrestling", "Male"
- The group discusses as long as they like
- Then everyone votes on who they think did not know the word
- The accused player gets one final guess at the word — if they know it, the
  crew wins; if they escape the vote, the imposter wins

## Modes
- **Offline** — pass the phone around your group in a single-device session.
- **Online** — create a room or join one with a code and play with friends on
  their own devices (Firebase Auth anonymous sign-in + Cloud Firestore).

## Tech
- Flutter (Dart), Firebase Auth, Cloud Firestore, Firestore security rules.
- Localized in English, French, Arabic, and Moroccan Darija.
