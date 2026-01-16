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

### 🔍 Exercice 1.4 : Diagnostic Technique (Performance & Erreurs)

**Le besoin métier :** L'application doit nous alerter quand une requête est trop lente ou qu'une erreur survient. Toutes ces traces sont stockées dans la table `app_events`. Pour optimiser l'application, nous devons extraire les données techniques qui sont "enfermées" dans le format JSONB.

- **Fichier :** `04_get_events_warnings.sql`
- **Objectif :** Lister tous les avertissements pour analyser les performances. Tu dois récupérer le message principal, la durée (en ms) et la requête SQL concernée.
- **Détails techniques :**
  - Filtre sur la sévérité `'warning'`.
  - Les informations de performance sont dans la colonne JSONB `metadata`.
  - Tu dois extraire les clés `duration_ms` et `query`.
- **Aide :** Utilise l'opérateur `->>` pour transformer la donnée JSON en texte exploitable dans tes colonnes.

### 💡 Note pour l'équipe :

C'est un exercice très important. En production, le format **JSONB** est le meilleur allié de Nodejs pour stocker des données flexibles (logs, préférences, options de paiement), mais il demande de savoir utiliser ces opérateurs fléchés (`->>`) pour que le SQL reste puissant.

### 💡 Un conseil pour la suite

Ne cherche pas à faire des requêtes parfaites du premier coup. L'important est de comprendre que **la base de données est le cœur de ton application**. Si tu sais extraire la donnée, tu sauras l'afficher en React sans difficulté.

**À toi de jouer ! Une fois que tes fichiers sont créés et testés, on passera aux jointures pour lier les utilisateurs à leurs pépites.**
