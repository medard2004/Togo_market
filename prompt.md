🎯 Objectif

Refondre complètement la logique des notifications afin qu’elles soient correctement catégorisées, bien redirigées et cohérentes avec l’architecture Boutique vs Particulier du projet.

🧩 Problème actuel

Le système de notifications est mal géré :

tout est mélangé,
les notifications particulier sont parfois traitées comme des notifications boutique,
les redirections sont incorrectes,
certaines notifications ouvrent le mauvais écran,
les détails commande/boutique/particulier sont confondus.

Je veux une logique propre, claire et fiable.

⚠️ Très important

L’application possède deux contextes totalement indépendants :

Compte particulier
Boutique

La logique des notifications doit absolument respecter cette séparation.

Aucune confusion ne doit exister.

1. Séparer clairement les types de notifications

Je veux une vraie catégorisation des notifications.

Exemples de types :

Notifications particulier
nouveau message particulier,
commande particulier,
mise à jour commande particulier,
statut commande particulier.
Notifications boutique
nouveau message boutique,
nouvelle commande boutique,
commande boutique mise à jour,
activité boutique.

Je veux que chaque notification sache clairement :

dans quel contexte elle appartient

et

où elle doit rediriger.

2. Corriger complètement les redirections

Aujourd’hui les redirections sont mal gérées.

Je veux une logique intelligente et fiable.

Cas 1 : Notification message boutique

Exemple :

Quelqu’un écrit à ma boutique.

Quand je clique :

➡️ ouvrir directement :

Messagerie boutique → bonne conversation

Et jamais la messagerie particulier.

Cas 2 : Notification message particulier

Quand quelqu’un écrit à mon compte particulier :

➡️ ouvrir :

Messagerie particulier → bonne discussion

Jamais boutique.

Cas 3 : Nouvelle commande boutique

Quand quelqu’un commande dans ma boutique :

Quand je clique :

➡️ ouvrir directement :

Détail exact de la commande boutique concernée

Je ne veux pas juste ouvrir :

❌ liste commandes

Je veux le détail exact.

Cas 4 : Commande particulier

Même logique :

➡️ ouvrir :

détail exact de la commande particulier

Et jamais détail boutique.

Cas 5 : Statut commande modifié

Exemple :

Commande acceptée ou livrée.

Quand utilisateur clique :

➡️ ouvrir directement :

le détail exact de cette commande

dans le bon contexte.

Cas 6 : Notification produit

Si notification liée à un produit :

➡️ redirection vers le bon détail produit.

Très important :

Produit boutique

→ détail produit boutique

Produit particulier

→ détail produit particulier

Je veux supprimer toute confusion actuelle.

3. Identifier le contexte avant navigation

Avant toute redirection, je veux que le système vérifie intelligemment :

type notification,
contexte (boutique ou particulier),
conversation concernée,
commande concernée,
produit concerné.

Puis redirige vers le bon écran.

Je veux une logique centralisée et propre.

4. Distinction visuelle

Je veux aussi une différence visible entre :

notifications boutique

et

notifications particulier

Afin qu’on comprenne immédiatement le contexte.

5. Lecture notification

Quand je clique sur une notification :

✅ marquer automatiquement comme lue

et mettre à jour :

badge compteur,
page notifications,
état global.

📦 Résultat attendu

Je veux un système de notifications :

✅ propre
✅ non confus
✅ boutique ≠ particulier
✅ bonnes redirections
✅ détail commande correct
✅ détail produit correct
✅ messagerie correcte
✅ fiable et cohérent partout dans l’application.