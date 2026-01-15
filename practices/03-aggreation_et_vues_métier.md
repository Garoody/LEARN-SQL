Voici la version consolidée de la Phase 3. On garde l'approche **KISS** : on prépare le terrain pour ton API Node.js et ton Frontend React en simplifiant l'accès aux données.

# 🎓 Memoria SQL Challenge - Phase 3 : Agrégation et Vues Métier

Bravo pour avoir dompté les jointures ! Maintenant, on va apprendre à transformer ces données brutes en structures que ton Frontend **React** va adorer. On va aussi simplifier la vie de ton futur code **Express** en créant des "raccourcis" SQL nommés **Vues**.

### Pourquoi l'agrégation et les vues ?

Dans Memoria, tu ne veux pas que ton API reçoive 5 lignes pour la même pépite (une ligne par tag). Tu veux **une seule ligne** avec tous les tags groupés. C'est l'agrégation. Les **Vues**, elles, permettent de sauvegarder des requêtes complexes pour les appeler comme des tables simples.

### Tes instructions :

1. Crée les fichiers dans `database/queries/` ou `database/views/`.
2. Utilise bien les noms de colonnes de tes seeders réels : `tag_name`, `id_item`, `id_user`, etc.
3. Teste chaque requête pour vérifier que le format JSON est bien lisible.

---

### 🔍 Exercice 3.1 : La Vue "Dashboard" (Le Raccourci)

**Le besoin métier :** Tu vas souvent avoir besoin d'afficher la liste globale des pépites avec leurs auteurs pour l'admin.

- **Fichier :** `database/views/01_dashboard_view.sql`
- **Objectif :** Créer une vue nommée `v_dashboard_items`.
- **Requête :**
  ```sql
  CREATE OR REPLACE VIEW v_dashboard_items AS
  SELECT u.pseudo, i.title, i.content_type
  FROM users u
  JOIN items i ON u.id_user = i.user_id;
  ```
- **Test :** `SELECT * FROM v_dashboard_items;`

---

### 🔍 Exercice 3.2 : Le Payload JSON (Prêt pour React)

**Le besoin métier :** Ton API doit renvoyer une pépite avec ses tags sous forme de tableau. `JSON_AGG` est la fonction magique de PostgreSQL pour faire ça.

- **Fichier :** `database/queries/09_items_with_tags_json.sql`
- **Objectif :** Afficher le titre de la pépite et un tableau JSON nommé `tags_list` contenant tous les `tag_name` associés.
- **Aide :** Tu dois joindre `items`, `item_tags` et `tags`, puis utiliser `GROUP BY i.id_item`.
- **Résultat attendu :** `"Les principes SOLID" | ["JavaScript", "Clean Code"]`

---

### 🔍 Exercice 3.3 : Le Top 3 des Tags (Data Visualisation)

**Le besoin métier :** Afficher sur le profil utilisateur les 3 thématiques (tags) les plus utilisées pour un petit graphique.

- **Fichier :** `database/queries/10_top_tags.sql`
- **Objectif :** Lister les noms de tags et le nombre de fois qu'ils sont utilisés, triés du plus grand au plus petit (limité à 3).

---

### 🔍 Exercice 3.4 : Sécurité et Isolation (Le filtre "User")

**Le besoin métier :** Règle d'or : Sophie ne doit jamais voir les pépites de Marc.

- **Fichier :** `database/queries/11_private_pépites.sql`
- **Objectif :** Récupérer tous les titres de pépites et leurs tags, mais uniquement pour l'utilisateur ayant le pseudo 'Sophie'.

---

### 🔍 Exercice 3.5 : La Vue "Pépites Orphelines" (Nettoyage)

**Le besoin métier :** Identifier les pépites qui n'ont **aucun tag** pour suggérer à l'utilisateur de les ranger.

- **Fichier :** `database/views/02_orphan_items_view.sql`
- **Nom de la vue :** `v_orphan_items`
- **Indice :** Tu auras besoin d'un `LEFT JOIN` entre `items` et `item_tags`, en cherchant là où la correspondance est `NULL`.

---

### 🔍 Exercice 3.6 : La Vue "Sécurité & Partage"

**Le besoin métier :** Une vue simple qui liste les pépites partagées et avec qui (préparation de la future fonctionnalité "Social").

- **Fichier :** `database/views/03_shared_items_view.sql`
- **Nom de la vue :** `v_shared_access`
- **Objectif :** Afficher le titre de la pépite (`title`), l'email du propriétaire (`owner_email`) et l'email de l'invité (`guest_email`).

---

### 🔍 Exercice 3.7 : La Vue "Top Utilisateurs" (High Level)

**Le besoin métier :** Un tableau de bord admin pour voir l'activité globale (volume de pépites et de tags créés).

- **Fichier :** `database/views/04_user_activity_summary_view.sql`
- **Nom de la vue :** `v_user_activity_metrics`
- **Indice :** C'est un exercice avancé ! Utilise `COUNT(DISTINCT i.id_item)` et `COUNT(DISTINCT t.id_tag)` pour éviter que les jointures ne faussent tes calculs.

---

### 💡 Le conseil de l'assistant

Quand tu utiliseras `JSON_AGG`, si une pépite n'a pas de tag, PostgreSQL pourrait te renvoyer `[null]`. Pour ton frontend React, c'est mieux d'avoir un tableau vide `[]`. Utilise :
`COALESCE(JSON_AGG(t.tag_name) FILTER (WHERE t.tag_name IS NOT NULL), '[]')`

**Prêt à transformer Memoria en une base de données professionnelle ? À toi de jouer !**
