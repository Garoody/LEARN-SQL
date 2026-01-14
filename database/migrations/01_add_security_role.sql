-- ============================================================================
-- TODO ÉTAPE 2 (DCL) : SÉCURISATION ET RÔLES (à exécuter avec le rôle postgres)
-- ============================================================================

-- Création du rôle applicatif avec droits restreints (jamais se connecter avec postgres !)
CREATE ROLE app_memoria WITH LOGIN PASSWORD 'unpandarouxquidort';

-- On donne les accès à ce rôle sur la base de données
GRANT ALL PRIVILEGES ON DATABASE memoria_db_dev TO app_memoria;


-- On se connecter à la base de données memoria_db_dev
