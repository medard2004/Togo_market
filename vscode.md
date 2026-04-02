# Togo_Market - Référence technique

## 1. Contexte général
Application marketplace mobile (Flutter) :
- Consultation produits
- Recherche / filtres
- Création boutique par vendeurs
- CRUD produits, images, variantes, stock (minimal)
- Chat client ↔ vendeur
- Commandes panier / validation
- Favoris
- Notifications
- Multi-rôles : client, vendeur, admin
- Paiement : à livraison + possibilité Flooz/TMoney + preuve (capture chat)
- Livraison ou retrait en boutique géré par vendeur via chat

## 2. Valeurs métier ajoutées
- `commande` réserve produit → `reserved`
- vendeur confirme : oui→`sold`, non→`active`
- `vendeur = commande` (une commande par vendeur par absence de market-place inter-vendeurs)

## 3. Tables principales et dossiers de migration
- `users`, `roles`, `boutiques`, `produits`, `categories`, `produit_variantes`, `images_produits`, `commandes`, `commande_articles`, `paiements`, `messages`, `favoris`, `notifications`, `locations`.

## 4. Relations clés
- 1:N : vendeur→boutiques, boutique→produits, produit→images, commande→articles, commande→paiements
- N:N : produit↔categorie
- polymorph : notifications, images (multitype)

## 5. API recommandée
- `api/auth/*`, `api/users`, `api/boutiques`, `api/produits`, `api/commandes`, `api/messages`, `api/favoris`, `api/notifications`, `api/paiements`, `api/locations`.

## 6. 