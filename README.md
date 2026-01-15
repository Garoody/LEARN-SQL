# 🐼 Memoria - Ton Deuxième Cerveau

**Memoria** est un coffre-fort numérique personnel permettant de capturer, organiser et pérenniser tes pépites de savoir (extraits de livres, podcasts, articles, notes).

---

## 🛠 Technologie & Architecture

- **Backend :** Node.js / Express.js
- **Frontend :** React
- **Database :** PostgreSQL 16+
- **Stockage Images :** Externe (Cloudinary / Supabase Storage)

---

## 📁 Structure du Projet SQL

```text
learn-sql
├─ scripts/                  # Scripts d'automatisation (Bash)
├─ database/
│  ├─ migrations/            # Structure (DDL) : Tables, Types, Config
│  ├─ seeders/               # Données de test (DML)
│  ├─ triggers/              # Automatismes (ex: updated_at)
│  └─ views/                 # Vues métier pour le Frontend
├─ docs/                     # Documentation et Aide-mémoire SQL
└─ .env                      # Configuration (non versionné)
```

---

## 🚀 Getting Started (Base de données)

### 1. Pré-requis

- Avoir **PostgreSQL** installé et en cours d'exécution.
- Avoir les droits administrateur (`postgres`) pour la création initiale.

### 2. Configuration environnementale

Copie le fichier d'exemple et ajuste tes accès si nécessaire :

```bash
cp env.example .env
```

Édite le `.env` :

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres       # Ton super-utilisateur local
DB_PASSWORD=ton_pass   # Ton mot de passe admin
DB_NAME=memoria_db_dev
DB_APP_USER=app_memoria
DB_APP_PASSWORD=unpandarouxquidort
```

### 3. Initialisation automatique

Nous utilisons des scripts automatisés pour gagner du temps et éviter les erreurs manuelles.

**Rendre les scripts exécutables (à faire une fois) :**

```bash
chmod +x scripts/*.sh
```

**Lancer l'installation complète :**

```bash
./scripts/init_db.sh
```

_Le script va créer la base, l'utilisateur applicatif, les types, les tables, les triggers et te proposera d'insérer les données de test (Seeders)._

### 4. Réinitialisation (Reset)

Si tu souhaites repartir de zéro :

```bash
./scripts/reset_db.sh
```

_(Attention : demande confirmation en tapant `RESET`)_

---

## 📊 Accès à la base de données

Pour te connecter manuellement en ligne de commande avec le rôle de l'application :

```bash
psql -h localhost -U app_memoria -d memoria_db_dev
```

---

## 💡 Notes de conception (Principe KISS)

- **Sécurité :** Tous les IDs sont des `UUID` pour éviter l'énumération de données.
- **Légalité :** Nous ne stockons pas de fichiers médias lourds/sous copyright, uniquement des métadonnées et des notes textuelles personnelles.
- **RGPD :** Suppression en cascade activée. Si l'utilisateur supprime son compte, toutes ses données associées disparaissent.
- **Vues :** Utilise les vues situées dans `database/views/` pour récupérer des données formatées (ex: `v_items_with_tags`) afin d'alléger le code du Backend.
