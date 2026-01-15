# 🎓 Memoria SQL Challenge - Phase 2 : Connecter les Points (Jointures)

Dans la phase précédente, on regardait chaque table de manière isolée. Mais dans **Memoria**, la donnée a de la valeur parce qu'elle est connectée : une pépite appartient à un utilisateur, elle possède plusieurs tags, et chaque action génère un log lié à un compte.

### Pourquoi les jointures ?

On ne stocke pas le nom de l'utilisateur dans la table `items`, on stocke seulement son `user_id`. Pourquoi ? Pour éviter la redondance (principe **DRY** : Don't Repeat Yourself). Si l'utilisateur change de pseudo, on n'a qu'une seule case à modifier. Les jointures servent à "réunir" ces informations au moment où on en a besoin.

### Tes instructions :

1. Crée les fichiers dans `database/queries/`.
2. Utilise bien les noms de colonnes de tes seeders (`id_item`, `id_tag`, `id_user`, `content_type`, etc.).
3. Teste chaque requête. Si elle retourne un tableau vide, c'est peut-être une erreur de minuscule/majuscule dans tes filtres !

---

### 🔍 Exercice 2.1 : L'Auteur des Pépites

**Le besoin métier :** Sur le futur tableau de bord "Admin", on veut voir la liste de toutes les pépites présentes sur le serveur, avec le nom de leur créateur.

- **Fichier :** `05_items_with_authors.sql`
- **Objectif :** Afficher le titre de la pépite (`title`), son type (`content_type`) et le `pseudo` de l'utilisateur qui l'a créée.
- **Aide :** Tu dois lier `items` et `users`. Le point commun est la colonne `user_id` dans `items` qui correspond à `id_user` dans `users`.
- **Documentation :** Regarde comment fonctionne `INNER JOIN`.

---

### 🔍 Exercice 2.2 : Audit Complet des Événements (Le cas du NULL)

**Le besoin métier :** On veut un journal d'activité. Certains événements sont liés à un utilisateur (ex: `user.login`), d'autres sont purement système (ex: `system.startup`) et n'ont pas de `user_id` (ils sont `NULL`). On veut voir **tous** les logs, et si un utilisateur est lié, afficher son email.

- **Fichier :** `06_full_audit_logs.sql`
- **Objectif :** Lister le `message` de l'événement et l' `email` de l'utilisateur.
- **Aide :** Si tu utilises un `INNER JOIN`, les logs système (sans utilisateur) vont disparaître ! Tu as besoin d'une jointure qui garde toutes les lignes de la table de gauche (`app_events`).
- **Documentation :** Cherche la différence entre `INNER JOIN` et `LEFT JOIN`.

---

### 🔍 Exercice 2.3 : Statistiques Utilisateurs

**Le besoin métier :** Pour savoir si l'application est utilisée, on veut savoir combien de pépites chaque utilisateur a enregistré.

- **Fichier :** `07_user_stats_count.sql`
- **Objectif :** Afficher le `pseudo` et le nombre total de pépites par utilisateur.
- **Aide :** Tu vas devoir joindre les tables, puis utiliser une fonction d'agrégation pour compter.
- **Documentation :** Utilise `COUNT(*)` et n'oublie pas la clause `GROUP BY` sur le pseudo, sinon SQL va faire la tête !

---

### 🔍 Exercice 2.4 : La Toile des Tags (Le Triple Saut 🤸)

**Le besoin métier :** Un utilisateur veut voir ses pépites filtrées par tags. C'est le cœur de l'organisation dans Memoria. Mais problème : les pépites et les tags sont liés par une table "pivot" (`item_tags`).

- **Fichier :** `08_items_by_tags.sql`
- **Objectif :** Afficher le titre de la pépite (`title`) et le nom du tag associé (`name`).
- **Aide :** C'est une relation "Many-to-Many". Tu dois partir de `items`, passer par `item_tags` (pour faire le pont), et finir dans `tags`.
- **Lien :**
  1. `items.id_item` = `item_tags.id_item`
  2. `item_tags.id_tag` = `tags.id_tag`
- **Documentation :** On peut enchaîner plusieurs `JOIN` à la suite dans la même requête.

---

### 💡 Un dernier conseil technique

Pour cet exercice 2.4, utilise des **alias** pour tes tables pour ne pas te perdre.
Exemple : `FROM items AS i JOIN item_tags AS it ON i.id_item = it.item_id`. C'est plus court et beaucoup plus lisible.

**Bonne chance pour cette montée en puissance ! Une fois terminé, tu auras compris 80% du SQL nécessaire pour ton API Node.js.**
