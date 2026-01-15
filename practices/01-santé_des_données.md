# 🎓 Memoria SQL Challenge - Phase 1 : La Santé des Données

Bienvenue dans le moteur de Memoria. Avant de construire les écrans en React ou les routes en Node.js, tu dois savoir parler à la base de données. Ton outil de prédilection sera le langage **SQL**.

### Pourquoi fait-on cela maintenant ?

Dans Memoria, on ne veut pas de données "sales" ou inutiles. On veut s’assurer que ce que les utilisateurs enregistrent est cohérent. Comme nous utilisons du **JSONB** (un format flexible pour stocker des détails variables), il faut apprendre à "fouiller" à l'intérieur.

### Tes instructions :

1.  Ouvre ton éditeur de code.
2.  Dans le dossier `database/queries/`, crée les fichiers demandés ci-dessous.
3.  Écris ta requête SQL dans chaque fichier.
4.  Teste-la sur ton interface PostgreSQL (VsCode, DBeaver ou pgAdmin).

---

### 🔍 Exercice 1.1 : Le Listing de Sécurité

**Le besoin métier :** En tant qu'administrateur, tu dois pouvoir vérifier en un coup d'œil les derniers inscrits et t'assurer qu'ils ont bien tous un rôle assigné.

- **Fichier :** `01_get_recent_users.sql`
- **Objectif :** Afficher le `pseudo`, l' `email` et le `role_name` de tout le monde.
- **Aide :** On veut les nouveaux en haut de la liste. Cherche comment trier les résultats par date de création du plus récent au plus ancien.
- **Documentation :** Regarde du côté de `ORDER BY` et du mot-clé `DESC`.

---

### 🔍 Exercice 1.2 : Les Pépites à "Nettoyer"

**Le besoin métier :** Memoria sert à stocker du savoir. Si un utilisateur crée une fiche avec seulement 3 mots, elle n'est pas très utile. On veut identifier ces fiches "trop courtes" pour proposer à l'utilisateur de les enrichir.

- **Fichier :** `02_find_short_items.sql`
- **Objectif :** Trouver le titre et le type de contenu de toutes les pépites dont le `content` fait moins de 20 caractères.
- **Aide :** Il existe une fonction SQL qui permet de compter la longueur d'une chaîne de texte.
- **Documentation :** Cherche la fonction `LENGTH()` sur Google pour PostgreSQL.

---

### 🔍 Exercice 1.3 : Le Détecteur d'URLs (Le défi JSONB 🛠️)

**Le besoin métier :** C'est ici que ça devient sérieux. Dans Memoria, on n'a pas de colonne `source_url`. Pour être flexible, on range l'URL dans un "sac" appelé `metadata` (de type JSONB).
Si un utilisateur dit enregistrer une "Vidéo", on s'attend à ce que l'URL à l'intérieur de `metadata` contienne "youtube" ou "vimeo".

- **Fichier :** `03_check_video_sources.sql`
- **Objectif :** Lister les titres des pépites de type 'Vidéo' dont l'URL ne contient **pas** le mot "youtube".
- **Aide :** Pour lire dans un champ JSONB en PostgreSQL, on utilise l'opérateur "flèche" : `->>`. Cela permet d'extraire une valeur comme si c'était du texte normal.
  - _Exemple :_ `metadata->>'mon_champ'`
- **Documentation :** Cherche "PostgreSQL JSONB operators" et l'opérateur `NOT LIKE`.

---

### 🔍 Exercice 1.4 : Diagnostic Technique

**Le besoin métier :** Avant même d'avoir un écran, on doit savoir si l'application rencontre des problèmes. On utilise pour cela une table de logs : `app_events`.

- **Fichier :** `04_get_critical_logs.sql`
- **Objectif :** Récupérer la date de l'événement et le message technique (caché lui aussi dans un champ JSONB nommé `event_data`) pour toutes les erreurs marquées comme 'critical'.
- **Aide :** Tu vas devoir extraire la clé `'message'` qui se trouve à l'intérieur de `event_data`.
- **Documentation :** Utilise la même logique que pour l'exercice précédent avec l'opérateur `->>`.

---

### 💡 Un conseil pour la suite

Ne cherche pas à faire des requêtes parfaites du premier coup. L'important est de comprendre que **la base de données est le cœur de ton application**. Si tu sais extraire la donnée, tu sauras l'afficher en React sans difficulté.

**À toi de jouer ! Une fois que tes fichiers sont créés et testés, on passera aux jointures pour lier les utilisateurs à leurs pépites.**
