🎯 Objectif
Refondre complètement le système de notifications afin qu’il soit fiable, fonctionnel, clair visuellement et intelligent selon le contexte Boutique ou Particulier.

🧩 Contexte
Le système actuel de notifications n’est pas suffisamment fiable/cohérent. Je veux une vraie gestion de notifications fonctionnelle dans toute l’application.

Je veux un système propre, fluide et cohérent avec la logique Boutique vs Particulier déjà présente dans le projet.

1. Notifications fonctionnelles avec Toast Notification

Je veux que les notifications fonctionnent réellement et utilisent un système de toast notification moderne.

Quand une notification arrive :

afficher un toast propre et visible,
design moderne, professionnel et discret,
animation fluide,
non intrusif.

Le toast doit fonctionner même si l’utilisateur est déjà dans l’application.

Je veux un comportement intelligent selon le contexte.

Exemples :

Nouveau message particulier

Toast :
Nouveau message reçu de Jean

Nouveau message boutique

Toast :
Nouvelle conversation boutique – Fashion Shop

Nouvelle commande boutique

Toast :
Nouvelle commande reçue dans votre boutique

Commande acceptée

Toast :
Votre commande a été acceptée

2. Distinction visible Boutique vs Particulier

Je veux une différence visuelle claire entre les notifications destinées :

à la boutique

et

au particulier

Je veux qu’on puisse identifier immédiatement le contexte.

Exemples de distinction possibles :

Notifications boutique
badge spécifique,
icon boutique/store,
style visuel différent,
label clair type : Boutique
Notifications particulier
icon utilisateur/message,
style propre au compte personnel,
label type : Personnel

Je veux quelque chose de visible et intuitif.

3. Redirection intelligente des notifications

Quand on clique sur une notification :

Je veux une redirection directe vers le bon écran, sans navigation intermédiaire inutile.

Cas : commande boutique

Exemple :

Quelqu’un passe une commande dans une boutique.

Le propriétaire reçoit une notification :

Nouvelle commande reçue

Quand il clique :

➡️ redirection directe vers le détail exact de cette commande dans la boutique.

Pas juste vers la liste des commandes.

Cas : commande particulier

➡️ redirection vers le détail de commande particulier.

Cas : message boutique

➡️ ouvrir directement :

Messagerie boutique → bonne conversation

Cas : message particulier

➡️ ouvrir directement :

Messagerie particulier → bonne conversation

Cas : validation commande

Quand une boutique accepte une commande :

L’acheteur reçoit une notification.

Quand il clique :

➡️ redirection directe vers le détail exact de la commande concernée.

4. Notifications de messages (Boutique + Particulier)

Je veux de vraies notifications quand un message est reçu.

Messagerie particulier
notification message reçue.
Messagerie boutique
notification message reçue.

Même si l’utilisateur n’est pas actuellement dans la discussion.

⚠️ Important :

Ne pas notifier inutilement si l’utilisateur est déjà dans cette conversation ouverte.

Je veux une logique intelligente.

5. Badge du nombre de notifications non lues

Je veux afficher le nombre de notifications non lues sur l’icône notification de l’écran d’accueil.

Exemple :

🔔 3

Le compteur doit :

✅ se mettre à jour automatiquement,
✅ diminuer lorsqu’une notification est lue,
✅ disparaître quand tout est lu.

Je veux un comportement temps réel ou refresh intelligent.

6. Marquer automatiquement comme lu

Quand une notification arrive et que l’utilisateur clique directement dessus :

➡️ elle doit être automatiquement marquée comme lue.

Le système doit :

retirer le badge non lu,
mettre à jour l’état dans la page notifications,
synchroniser correctement partout.

Je ne veux plus de notifications déjà ouvertes qui restent non lues.

Résultat attendu

Je veux un système de notifications :

✅ totalement fonctionnel
✅ toast moderne
✅ distinction boutique/personnel visible
✅ redirection intelligente vers le bon écran
✅ notifications messages fonctionnelles
✅ badge compteur non lu sur accueil
✅ lecture automatique après ouverture
✅ cohérent avec toute la logique Boutique vs Particulier du projet.