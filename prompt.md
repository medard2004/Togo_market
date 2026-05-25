🎯 Objectif
Revoir complètement la logique de la messagerie afin d’avoir une architecture propre, scalable et strictement séparée entre **messagerie particulier** et **messagerie boutique**.

🧩 Contexte métier (très important)
L’application possède **deux messageries totalement indépendantes** :

1. **Messagerie particulier**

* liée au compte utilisateur personnel,
* utilisée uniquement pour les **annonces particulières** (produits publiés comme particulier).

2. **Messagerie boutique**

* liée à une boutique,
* utilisée uniquement pour les **produits de boutique**.

⚠️ Règle absolue :
Les deux messageries ne doivent **jamais se mélanger**.

Un message destiné à la boutique ne doit **jamais** apparaître dans la messagerie particulier.
Un message particulier ne doit **jamais** apparaître dans la boutique.

---

## Logique métier attendue

### Cas 1 : Produit particulier

Si un utilisateur publie une annonce particulière :

**Produit particulier → conversation particulier uniquement**

Exemple :
User A publie un iPhone comme particulier.
User B clique sur discuter.

Résultat attendu :

* conversation créée dans la **messagerie particulier de A**,
* conversation visible chez B dans sa messagerie particulier,
* jamais dans une boutique.

---

### Cas 2 : Produit boutique

Si un produit appartient à une boutique :

**Produit boutique → conversation boutique uniquement**

Exemple :
User A possède Boutique X.
User B discute à propos d’un produit de Boutique X.

Résultat attendu :

* message reçu dans la **messagerie de Boutique X**,
* jamais dans la messagerie particulier de A.

Dans le chat :

* afficher **nom + logo de la boutique**,
* pas le profil personnel du propriétaire.

---

### Cas 3 : Utilisateur qui achète dans sa propre boutique

Cas très important.

Un utilisateur **peut acheter dans sa propre boutique**.

Exemple :
User A possède Boutique X.
User A achète un produit de Boutique X.

Le système doit considérer :

**User A (particulier)** ≠ **Boutique X**

Même si le propriétaire est le même.

Résultat attendu :

* création d’une conversation entre :
  **Messagerie particulier de User A** ↔ **Messagerie boutique de Boutique X**
* la boutique traite ce message comme n’importe quel client,
* le particulier voit la boutique comme un vendeur normal.

⚠️ Le système ne doit jamais détecter cela comme “message à soi-même” et bloquer ou fusionner la discussion.

---

### Cas 4 : Conversations séparées obligatoires

Aucune fusion entre particulier et boutique.

Exemple :

User A a :

* une annonce particulière
* une boutique

User B discute :

Produit particulier → conversation particulier
Produit boutique → conversation boutique

Même si le propriétaire est le même :
➡️ **2 conversations totalement séparées**

---

## Architecture attendue (important)

Je veux une architecture **scalable**, pensée pour plusieurs boutiques dans le futur.

Le système ne doit **jamais** reposer uniquement sur `user_id`.

Je veux une logique orientée **entity messaging**.

Exemple recommandé :

### Conversation

* id
* conversation_type (`personal`, `shop`)
* sender_entity_type (`user`, `shop`)
* sender_entity_id
* receiver_entity_type (`user`, `shop`)
* receiver_entity_id
* related_product_id (nullable)
* related_shop_id (nullable)

### Message

* conversation_id
* sender_entity_type
* sender_entity_id
* content
* media
* timestamps

Ainsi :

User ↔ User
User ↔ Shop
Shop ↔ User

fonctionnent proprement sans ambiguïté.

---

## Ouverture des discussions (UX attendue)

Je veux une ouverture de discussion **instantanée et fluide** :

* si conversation existe → ouvrir immédiatement,
* sinon → créer puis ouvrir sans délai visible.

Le header doit afficher la bonne identité :

### Conversation boutique

* logo boutique
* nom boutique

### Conversation particulier

* photo profil utilisateur
* nom utilisateur

Jamais de fallback générique type **“Utilisateur”** si les données existent.

---

📦 Livrable
Refonte complète de la logique de messagerie avec séparation stricte particulier/boutique, architecture scalable, conversations fiables, ouverture fluide et aucune confusion entre les contextes.
