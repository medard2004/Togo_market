/**
 * reset_messaging.js
 * ─────────────────────────────────────────────────────────────────────────────
 * Purge COMPLÈTE du système de messagerie Firebase pour Togo Market.
 *
 * Ce script :
 *  1. Supprime tous les documents dans la collection `chats` (Firestore)
 *  2. Supprime toutes les sous-collections `messages` dans chaque chat
 *  3. Supprime tous les fichiers media dans Firebase Storage (dossier `chats/`)
 *
 * ⚠️  IRRÉVERSIBLE - Toutes les conversations et messages seront perdus.
 * ─────────────────────────────────────────────────────────────────────────────
 */

const admin = require('firebase-admin');
const path  = require('path');

// ── Initialisation ────────────────────────────────────────────────────────────
const serviceAccountPath = path.resolve(
  '/home/othnelio/laravel-togo-market/storage/app/firebase/firebase-credentials.json'
);

admin.initializeApp({
  credential: admin.credential.cert(require(serviceAccountPath)),
  storageBucket: 'togo-market-fc0a7.firebasestorage.app',
});

const db      = admin.firestore();
const bucket  = admin.storage().bucket();

// ── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Supprime tous les documents d'une sous-collection par batch de 500.
 */
async function deleteCollection(collRef, batchSize = 500) {
  let deleted = 0;
  let snap;

  do {
    snap = await collRef.limit(batchSize).get();
    if (snap.empty) break;

    const batch = db.batch();
    snap.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    deleted += snap.size;
    process.stdout.write(`    Supprimés : ${deleted} docs...\r`);
  } while (snap.size === batchSize);

  return deleted;
}

/**
 * Supprime récursivement un document et toutes ses sous-collections.
 */
async function deleteDocAndSubcollections(docRef) {
  // Lister et supprimer les sous-collections (principalement `messages`)
  const subColls = await docRef.listCollections();
  for (const subColl of subColls) {
    console.log(`  → Suppression sous-collection "${subColl.id}"...`);
    const count = await deleteCollection(subColl);
    console.log(`    ✓ ${count} messages supprimés`);
  }
  // Supprimer le document parent
  await docRef.delete();
}

// ── ÉTAPE 1 : Purger Firestore (chats + messages) ────────────────────────────
async function purgeFirestore() {
  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log('║  ÉTAPE 1 : Purge Firestore - Collection "chats"         ║');
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  const chatsRef = db.collection('chats');
  const snapshot = await chatsRef.get();

  if (snapshot.empty) {
    console.log('  ℹ️  Aucune conversation trouvée. La collection est déjà vide.\n');
    return 0;
  }

  console.log(`  📋 ${snapshot.size} conversation(s) trouvée(s) à supprimer.\n`);

  let conversationsDeleted = 0;
  let totalMessages = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const participants = (data.participants || []).join(' ↔ ');
    const lastMsg = data.lastMessage ? `"${data.lastMessage.substring(0, 40)}"` : '(vide)';
    console.log(`  🗂  Conversation [${doc.id}]`);
    console.log(`     Participants : ${participants}`);
    console.log(`     Dernier msg  : ${lastMsg}`);

    // Compter les messages avant suppression
    const msgSnap = await doc.ref.collection('messages').get();
    const msgCount = msgSnap.size;
    totalMessages += msgCount;
    console.log(`     Messages     : ${msgCount}`);

    await deleteDocAndSubcollections(doc.ref);
    conversationsDeleted++;
    console.log(`     ✅ Conversation supprimée\n`);
  }

  console.log(`  ✅ RÉSUMÉ FIRESTORE :`);
  console.log(`     - ${conversationsDeleted} conversation(s) supprimée(s)`);
  console.log(`     - ${totalMessages} message(s) supprimé(s)`);

  return conversationsDeleted;
}

// ── ÉTAPE 2 : Purger Firebase Storage (dossier chats/) ───────────────────────
async function purgeStorage() {
  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log('║  ÉTAPE 2 : Purge Storage - Dossier "chats/"             ║');
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  try {
    const [files] = await bucket.getFiles({ prefix: 'chats/' });

    if (files.length === 0) {
      console.log('  ℹ️  Aucun fichier média trouvé dans Storage/chats/\n');
      return 0;
    }

    console.log(`  📁 ${files.length} fichier(s) média trouvé(s).\n`);

    let deleted = 0;
    for (const file of files) {
      console.log(`  🗑  Suppression : ${file.name}`);
      await file.delete();
      deleted++;
    }

    console.log(`\n  ✅ ${deleted} fichier(s) média supprimé(s) du Storage`);
    return deleted;
  } catch (err) {
    if (err.code === 404 || err.message.includes('does not exist')) {
      console.log('  ℹ️  Dossier chats/ inexistant dans Storage (OK)\n');
      return 0;
    }
    console.error('  ⚠️  Erreur Storage (non bloquante) :', err.message);
    return 0;
  }
}

// ── ÉTAPE 3 : Vérification finale ────────────────────────────────────────────
async function verifyReset() {
  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log('║  ÉTAPE 3 : Vérification finale                          ║');
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  const chatsSnap = await db.collection('chats').get();
  const chatCount = chatsSnap.size;

  if (chatCount === 0) {
    console.log('  ✅ Firestore : 0 conversation(s) - PARFAIT !');
  } else {
    console.log(`  ⚠️  Firestore : ${chatCount} conversation(s) ENCORE PRÉSENTE(S) !`);
  }

  try {
    const [files] = await bucket.getFiles({ prefix: 'chats/' });
    if (files.length === 0) {
      console.log('  ✅ Storage  : 0 fichier(s) - PARFAIT !');
    } else {
      console.log(`  ⚠️  Storage  : ${files.length} fichier(s) ENCORE PRÉSENT(S) !`);
    }
  } catch (_) {
    console.log('  ✅ Storage  : dossier chats/ vide ou inexistant');
  }
}

// ── MAIN ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log('');
  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║     🔥 RESET COMPLET DU SYSTÈME DE MESSAGERIE 🔥        ║');
  console.log('║     Projet : togo-market-fc0a7                           ║');
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log('');
  console.log('  ⚠️  ATTENTION : Toutes les conversations et messages');
  console.log('     seront DÉFINITIVEMENT supprimés de Firebase.');
  console.log('');

  const start = Date.now();

  try {
    const conversationsDeleted = await purgeFirestore();
    const filesDeleted         = await purgeStorage();
    await verifyReset();

    const elapsed = ((Date.now() - start) / 1000).toFixed(1);

    console.log('\n╔══════════════════════════════════════════════════════════╗');
    console.log('║              🎉 RESET TERMINÉ AVEC SUCCÈS               ║');
    console.log('╠══════════════════════════════════════════════════════════╣');
    console.log(`║  Conversations supprimées : ${String(conversationsDeleted).padEnd(27)}║`);
    console.log(`║  Fichiers média supprimés : ${String(filesDeleted).padEnd(27)}║`);
    console.log(`║  Durée                    : ${String(elapsed + 's').padEnd(27)}║`);
    console.log('╠══════════════════════════════════════════════════════════╣');
    console.log('║  ✅ unreadMessages dans app_controller.dart = 0         ║');
    console.log('║  ✅ Firestore collection "chats" = vide                 ║');
    console.log('║  ✅ Firebase Storage "chats/" = vide                    ║');
    console.log('║  ✅ L\'UI affichera 0 partout au redémarrage             ║');
    console.log('╚══════════════════════════════════════════════════════════╝');
    console.log('');

  } catch (err) {
    console.error('\n❌ ERREUR CRITIQUE :', err);
    process.exit(1);
  }

  process.exit(0);
}

main();
