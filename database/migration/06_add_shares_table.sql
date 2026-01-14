--TODO ETAPE 5 : Création de table index et commentaire (DDL)
-- 5.1 Table users
-- Relation Merise : Entité indépendante

DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
    id_user UUID DEFAULT uuidv7 () PRIMARY KEY,
    email CITEXT UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    pseudo CITEXT UNIQUE NOT NULL,
    role_name role_enum NOT NULL DEFAULT 'customer',
    auth_provider auth_provider_enum NOT NULL DEFAULT 'local',
    settings_user JSONB NOT NULL DEFAULT '{}',
    gdpr_consent BOOLEAN NOT NULL DEFAULT FALSE,
    gdpr_consent_date TIMESTAMPTZ,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- Indexation JSONB (Recherche rapide dans les réglages utilisateur)
CREATE INDEX idx_users_settings ON users USING gin (settings_user);

--Documentation

COMMENT ON TABLE users IS 'Stocke les informations d indentification et les préférences des utilisateurs (RGPD inclus)';

COMMENT ON COLUMN users.settings_user IS 'Stockage flexible JSONB pour les préférences UI/UX';

--Application du trigger
CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON users  FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamps();