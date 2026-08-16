/**
 * Cloud Functions for WHO'S SUS.
 *
 * `getVoiceToken` mints short-lived LiveKit join tokens for the realtime
 * voice chat. Tokens are signed with the LiveKit API secret, so the secret
 * only ever lives server-side — never in the Flutter app.
 *
 * Deployment prerequisites (see the project README / final report):
 *   1. A LiveKit server (LiveKit Cloud or self-hosted).
 *   2. Env vars for the functions:
 *        firebase functions:secrets:set LIVEKIT_API_KEY
 *        firebase functions:secrets:set LIVEKIT_API_SECRET
 *        firebase functions:secrets:set LIVEKIT_URL   # e.g. wss://xxx.livekit.cloud
 *   3. firebase deploy --only functions
 */
const functions = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { AccessToken } = require('livekit-server-sdk');

admin.initializeApp();

const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY;
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET;
const LIVEKIT_URL = process.env.LIVEKIT_URL;

exports.getVoiceToken = functions.onCall(
  {
    enforceAppCheck: false,
    timeoutSeconds: 30,
    memory: '256MiB',
  },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new functions.HttpsError('unauthenticated', 'You must be signed in.');
    }

    const roomId = request.data?.roomId;
    if (typeof roomId !== 'string' || roomId.length === 0 || roomId.length > 64) {
      throw new functions.HttpsError('invalid-argument', 'A valid roomId is required.');
    }

    if (!LIVEKIT_API_KEY || !LIVEKIT_API_SECRET || !LIVEKIT_URL) {
      throw new functions.HttpsError('failed-precondition', 'Voice chat is not configured.');
    }

    // The caller must be a member of the room, and voice is only allowed while
    // the room is in the discussion phase. This mirrors the client-side rules
    // so the token cannot be used outside its intended context.
    const db = admin.firestore();
    const roomRef = db.collection('rooms').doc(roomId);
    const [roomSnap, playerSnap] = await Promise.all([
      roomRef.get(),
      roomRef.collection('players').doc(uid).get(),
    ]);

    if (!roomSnap.exists || !playerSnap.exists) {
      throw new functions.HttpsError('permission-denied', 'You are not a member of this room.');
    }

    if (roomSnap.get('game_phase') !== 'discussion') {
      throw new functions.HttpsError('failed-precondition', 'Voice chat is only available during the discussion phase.');
    }

    const playerName = playerSnap.get('player_name') || '';
    const roomName = `room-${roomId}`;

    const token = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
      identity: uid,
      name: playerName,
      ttl: '10m',
    });
    token.addGrant({
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
    });

    return {
      url: LIVEKIT_URL,
      token: await token.toJwt(),
    };
  },
);
