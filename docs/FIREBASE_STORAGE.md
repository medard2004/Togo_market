# Firebase Storage — configuration console (obligatoire)

Le code app + Laravel gère les **custom tokens**, mais **Firebase Console** doit aussi être configurée.  
Sans cela, l’upload échoue souvent avec `firebase_storage/object-not-found` (fichier jamais créé car refusé par les règles).

## Projet

| Élément | Valeur |
|--------|--------|
| Project ID | `togo-market-fc0a7` |
| Bucket | `togo-market-fc0a7.firebasestorage.app` |

---

## Checklist console Firebase

### 1. Activer Storage

1. [Console Firebase](https://console.firebase.google.com/) → projet **togo-market-fc0a7**
2. **Build** → **Storage**
3. Si demandé : **Get started** → mode **Production** (pas seulement les règles de test expirées)
4. Choisir la région (ex. `europe-west1`) et valider

### 2. Déployer les règles Storage (critique)

Les règles du repo ne s’appliquent **pas** tant qu’elles ne sont pas publiées.

**Option A — CLI (recommandé)**

```bash
cd /home/othnelio/Togo_market
npm install -g firebase-tools   # si besoin
firebase login
firebase deploy --only storage
```

**Option B — Coller dans la console**

1. **Storage** → onglet **Rules**
2. Remplacer par le contenu de [`storage.rules`](../storage.rules)
3. **Publish**

Règle attendue : seuls les participants du chat (`id1_id2`) peuvent lire/écrire sous `chats/{chatId}/...`.

### 3. Authentication

1. **Build** → **Authentication** → **Get started** (si pas encore fait)
2. Aucun fournisseur (Google, etc.) n’est obligatoire pour les **custom tokens** émis par Laravel
3. Vérifier que l’API **Identity Toolkit** est activée dans [Google Cloud Console](https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=togo-market-fc0a7) pour ce projet

### 4. Compte de service (backend Laravel)

Le fichier `laravel-togo-market/storage/app/firebase/firebase-credentials.json` doit être le JSON du compte de service Firebase avec au minimum :

- rôle **Firebase Admin SDK Administrator** ou permissions pour créer des custom tokens et utiliser FCM

### 5. Vérification après un envoi d’image

| Où | Attendu |
|----|---------|
| Logs Flutter | `FirebaseAuthBridge: connecté uid=19` (votre id) |
| Logs Flutter | `ChatService.uploadMedia: Upload réussi` |
| Console → Storage → Files | Fichier sous `chats/19_xx/image/...` |
| Si échec | Souvent `permission-denied` ou `object-not-found` = règles non déployées ou pas connecté à Firebase Auth |

### 6. App Check (si activé)

Si **App Check** est forcé sur Storage sans enregistrer l’app Android, les uploads échouent.  
**Build** → **App Check** → désactiver l’application forcée sur Storage en dev, ou configurer le provider debug.

---

## API backend

`GET /api/auth/firebase-token` (Sanctum)

- Sans paramètre : UID = `user.id`
- `?acting_as=boutique` : UID = `boutique.id` (mode vendeur)

Après modification du `.env` ou de `config/services.php` :

```bash
cd laravel-togo-market && php artisan config:clear
```

---

## Règles temporaires (debug uniquement)

Pour tester **5 minutes** si le problème vient bien des règles :

```
match /chats/{allPaths=**} {
  allow read, write: if request.auth != null;
}
```

Publier, retester l’upload, puis remettre les règles strictes de `storage.rules`.
