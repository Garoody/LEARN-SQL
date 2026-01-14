```
learn-sql
├─ .env														# Ensemble des variables d'environnement pour le bon fonctionnement de l'application(ne pas versionner)
├─ .gitignore		
├─ complete-sql.md
├─ database
│  ├─ migrations  											# Tout le code SQL pour créer la base données et les tables
│  │  ├─ 00_add_database_config.sql
│  │  ├─ 01_add_security_role.sql
│  │  ├─ 02_add_extensions.sql
│  │  ├─ 02_add_types.sql
│  │  ├─ 03_add_users_table.sql
│  │  ├─ 04_add_tags_table.sql
│  │  ├─ 05_add_items_table.sql
│  │  ├─ 06_add_shares_table.sql
│  │  ├─ 07_add_item_tags_table_pivot.sql
│  │  ├─ 08_add_app_events_table.sql
│  │  ├─ 09_drop_all_tables.sql
│  │  └─ 10_drop_all_types.sql
│  ├─ seeders 												 # Tout le code pour peupler les tables de la base de données
│  │  ├─ 01_add_users_seeders.sql
│  │  └─ 02_add_tags_seeders.sql
│  ├─ triggers												 # Fonctions customs pour les tables de la base de données
│  │  └─ 01_add_trigger_set_timestamp.sql
│  └─ views												 # Création de vue pour l'affiche frontend
├─ docs
│  ├─ guide-sql.md
│  └─ img
│     ├─ commands-sql.png
│     └─ postgresql-cheat-sheet-a4.pdf
├─ exemple.env												# Exemple Ensemble des variables d'environnement pour le bon fonctionnement de l'application(doit être versionné)
├─ README.md
└─ scripts													# Ensemble des scripts d'automatisation pour l'application
   ├─ init_db.sh
   └─ reset_db.sh

```