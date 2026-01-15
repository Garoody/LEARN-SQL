-- ============================================================================
-- MEMORIA - Base de données principale
-- Version: 1.0.0
-- Date: 2026-01-08
-- Description: Coffre-fort numérique personnel (Deuxième Cerveau)
-- ============================================================================

-- ============================================================================
-- TODO ÉTAPE 1 (DCL/DDL) : CRÉATION DE LA BASE DE DONNÉES (à exécuter avec le rôle postgres)
-- ============================================================================

-- Création de la base avec support UTF8 complet

CREATE DATABASE memoria_db_dev WITH ENCODING = 'UTF8';

COMMENT ON DATABASE memoria_db_dev IS 'Base de données principales du projet Memoria - Coffre-fort numérique';

-- ============================================================================
-- TODO ÉTAPE 2 (DCL) : SÉCURISATION ET RÔLES (à exécuter avec le rôle postgres)
-- ============================================================================

-- Création du rôle applicatif avec droits restreints (jamais se connecter avec postgres !)
CREATE ROLE app_memoria WITH LOGIN PASSWORD 'unpandarouxquidort';

-- On donne les accès à ce rôle sur la base de données
GRANT ALL PRIVILEGES ON DATABASE memoria_db_dev TO app_memoria;

-- On se connecter à la base de données memoria_db_dev

-- ============================================================================
--  TODO ÉTAPE 3-A : EXTENSIONS (à exécuter avec le rôle postgres)
-- ============================================================================

-- Extensions modernes PostgreSQL
CREATE EXTENSION IF NOT EXISTS "citext";
-- Texte insensible à la casse (email, pseudo, titre)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
-- Recherche floue (Trigram) pour le moteur de recherche
CREATE EXTENSION IF NOT EXISTS "btree_gin";
-- Indexation performante pour les types standards.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Fonctions crypto (optionnel)

-- ============================================================================
-- TODO ÉTAPE 3-B : TYPES ÉNUMÉRÉS (ENUM) (à exécuter avec le rôle postgres)
-- ============================================================================

-- ! Important : Si vous ajoutez une nouvelle valeur dans un type,il faut le supprimer et le recréer !

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

-- Rôles utilisateurs (Access Control Level)
CREATE TYPE role_enum AS ENUM(
    'admin',         -- Gestion des utilisateurs et des droits
    'customer',      -- Utilisateur normal
    'super_admin'    -- Gestion des droits système
);

COMMENT ON TYPE role_enum IS 'Rôles des utilisateurs pour la gestion des droits Access Controle Level (ACL)';

-- Fournisseurs d'authentification
CREATE TYPE auth_provider_enum AS ENUM(
    'local',        -- Authentification locale
    'google',       -- Authentification Google
    'azure',        -- Authentification Azure
    'apple'         -- Authentification Apple
);

COMMENT ON TYPE auth_provider_enum IS 'Fournisseur d authentification';

-- Types de contenu des pépites
CREATE TYPE content_type_enum AS ENUM(
    'Livre',
    'Podcast',
    'Article',
    'Video',
    'Note'
);

COMMENT ON TYPE content_type_enum IS 'Types de contenu';

-- Catégories d'événements (analytics & logs)
CREATE TYPE event_category_enum AS ENUM (
    'analytics',   -- Événements métier (login, création item...)
    'audit',       -- Audit trail (modification compte, suppression...)
    'monitoring',  -- Health checks, performance
    'gdpr'         -- Événements RGPD (export, suppression, consentement...)
);

COMMENT ON TYPE event_category_enum IS 'Catégories principales des événements système';

-- Niveaux de sévérité (pour les logs)
CREATE TYPE severity_enum AS ENUM (
    'info',        -- Information normale
    'warning',     -- Avertissement (ex: tentative de login échouée)
    'error',       -- Erreur récupérable (ex: validation échouée)
    'critical'     -- Erreur critique (ex: base de données inaccessible)
);

-- ============================================================================
--  TODO ÉTAPE 4 : FONCTION TRIGGER : Mise à jour automatique de updated_at

-- Pour ne plus jamais oublier de mettre à jour la colonne updated_at
-- Fonction trigger_set_timestamp a utiliser sur les tables avec une colonne updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;

$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION trigger_set_timestamp () IS 'Met à jour automatiquement la colonne updated_at lors d une modification de ligne';

COMMENT ON TYPE severity_enum IS 'Niveaux de gravité pour les événements de type monitoring/audit';

-- ============================================================================
-- TODO ÉTAPE 5.1 : TABLE 1 -> USERS (Utilisateurs) (DDL)

-- Relation Merise : Entité indépendante
-- ============================================================================

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

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
    created_at TIMESTAMPTZ NOT NUll DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT chk_email_is_valid CHECK ( -- Contraintes métier
        email ~ '^[^@]+@[^@.]+\.[^@]+$'
    )
);

-- Indexation JSONB (Recherche rapide dans les réglages utilisateur)
CREATE INDEX idx_users_settings ON users USING gin (settings_user);

-- Documentation
COMMENT ON
TABLE users IS 'Stocke les informations d identification et les préférences des utilisateurs (RGPD compliant)';

COMMENT ON COLUMN users.settings_user IS 'Préférences utilisateur en JSONB : {"theme": "dark", "language": "fr", "notifications": true}';

COMMENT ON COLUMN users.gdpr_consent IS 'Consentement RGPD obligatoire pour créer un compte';

COMMENT ON COLUMN users.gdpr_consent_date IS 'Date et heure précises du consentement RGPD';

-- Application du trigger
CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

-- ============================================================================
-- TODO ÉTAPE 5.2 : TABLE 2 -> TAGS (Catégories personnalisées) (DDL)

-- Relation Merise : users (1,N) --- (1,1) tags (un tag appartient à un utilisateur)
-- ============================================================================

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

CREATE TABLE IF NOT EXISTS tags (
    id_tag UUID DEFAULT uuidv7 () PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL,
    user_id UUID NOT NULL REFERENCES users (id_user) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NUll DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT unique_user_tag UNIQUE (user_id, tag_name) -- Un utilisateur ne peut pas avoir deux fois le même tag
);

-- Index pour requêtes par utilisateur (liste de ses tags)
CREATE INDEX idx_tags_user ON tags (user_id);

-- Index pour recherche floue sur les noms de tags
CREATE INDEX idx_tags_name_trgm ON tags USING gin (tag_name gin_trgm_ops);

-- Documentation
COMMENT ON
TABLE tags IS 'Mots-clés personnalisés créés par les utilisateurs pour organiser leurs pépites';

COMMENT ON COLUMN tags.tag_name IS 'Nom du tag (insensible à la casse via CITEXT)';

-- Application du trigger
CREATE TRIGGER set_timestamp_tags BEFORE UPDATE ON tags FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

-- ============================================================================
-- TODO ÉTAPE 5.3 : TABLE 3 -> ITEMS (Les pépites - Cœur de l'application) (DDL)

-- Relation Merise : users (1,N) --- (1,1) items (un item appartient à un utilisateur)
-- ============================================================================

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

CREATE TABLE IF NOT EXISTS items (
    id_item UUID DEFAULT uuidv7 () PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users (id_user) ON DELETE CASCADE,
    content_type content_type_enum NOT NULL,
    title CITEXT NOT NULL,
    slug CITEXT NOT NULL,
    content TEXT NOT NULL,
    source_author VARCHAR(50) NOT NULL DEFAULT 'N.C',
    thumbnail_url VARCHAR(255),
    metadata JSONB NOT NULL DEFAULT '{}', -- Recherche puissante ici
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT unique_user_item_title UNIQUE (user_id, title), -- Un user ne peut pas avoir deux fois le même titre
    CONSTRAINT unique_user_item_slug UNIQUE (user_id, slug) -- Le slug doit être unique par utilisateur
);

-- Index GIN pour recherche floue sur le titre (Trigram)
CREATE INDEX idx_items_title_trgm ON items USING gin (title gin_trgm_ops);

-- Index GIN pour recherche dans les métadonnées JSONB
CREATE INDEX idx_items_metadata ON items USING gin (metadata);

-- Index composite pour filtrer par utilisateur + type
CREATE INDEX idx_items_user_type ON items (user_id, content_type);

-- Index pour recherche par utilisateur (requête la plus fréquente)
CREATE INDEX idx_items_user ON items (user_id);

-- Documentation
COMMENT ON
TABLE items IS 'Le cœur du coffre-fort : stocke les pépites (notes, citations, résumés, liens)';

COMMENT ON COLUMN items.content IS 'Contenu textuel de la pépite (résumé, citation, notes personnelles)';

COMMENT ON COLUMN items.slug IS 'Version URL-friendly du titre pour le SEO et les routes';

COMMENT ON COLUMN items.thumbnail_url IS 'URL de l image stockée sur service externe (Cloudinary/Supabase)';

COMMENT ON COLUMN items.metadata IS 'Métadonnées flexibles en JSONB : {"isbn": "xxx", source_url": "xxx", "duration": "45min", "channel": "xxx", "coordinates": {...}}';

-- Application du trigger
CREATE TRIGGER set_timestamp_items BEFORE UPDATE ON items FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

-- ============================================================================
-- TODO ÉTAPE 5.4 : TABLE 4 -> SHARES (Partages de pépites) (DDL)

-- Relation Merise : items (1,1) --- (0,N) shares (un item appartient à un utilisateur)
-- ============================================================================

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

CREATE TABLE IF NOT EXISTS shares (
    id_share UUID DEFAULT uuidv7 () PRIMARY KEY,
    item_id UUID NOT NULL REFERENCES items (id_item) ON DELETE CASCADE,
    recipient_email CITEXT,
    share_token VARCHAR(255) UNIQUE NOT NULL,
    access_config JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- Index pour recherche par item (liste des partages d'une pépite)
CREATE INDEX idx_shares_item ON shares (item_id);

-- Documentation
COMMENT ON
TABLE shares IS 'Gère les partages temporaires ou permanents des pépites via un token unique';

COMMENT ON COLUMN shares.recipient_email IS 'Email de l invité (optionnel pour partage public)';

COMMENT ON COLUMN shares.share_token IS 'Token sécurisé généré côté backend (crypto.randomBytes)';

COMMENT ON COLUMN shares.access_config IS 'Configuration flexible du partage :
{
  "level": "read",
  "allow_download": false,
  "expiration": "2026-01-31T23:59:59Z",
  "password": "$2b$10$hash...",
  "max_views": 10,
  "view_count": 0
}';

-- Application du trigger
CREATE TRIGGER set_timestamp_shares BEFORE UPDATE ON shares FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

-- ============================================================================
-- TODO ÉTAPE 5.5 : TABLE 5 -> ITEM_TAGS (Table de liaison/pivot Many-to-Many) (DDL)

-- Relation Merise : items (0,N) --- (0,N) tags
-- ============================================================================

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

CREATE TABLE IF NOT EXISTS item_tags (
    id_tag UUID REFERENCES tags (id_tag) ON DELETE CASCADE,
    id_item UUID REFERENCES items (id_item) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_tag, id_item) -- Clé primaire composite (un item ne peut avoir le même tag qu'une seule fois)
);

-- Index pour requêtes inverses (tous les items d'un tag)
CREATE INDEX idx_item_tags_tag ON item_tags (id_tag);

-- Documentation
COMMENT ON
TABLE item_tags IS 'Table de liaison gérant la relation Many-to-Many entre Items et Tags';
-- Application du trigger

-- ============================================================================
-- TODO ÉTAPE 5.6 : TABLE 6 -> APP_EVENTS (Analytics, Logs, Monitoring, RGPD) (DDL)

-- Relation Merise : events (0,1) --- (1,N) users (Un événement peut être lié à 0 ou 1 utilisateur)
-- ============================================================================

-- Forcer l'encodage client
SET CLIENT_ENCODING TO 'UTF8';

CREATE TABLE IF NOT EXISTS app_events (
    id_event UUID DEFAULT uuidv7 () PRIMARY KEY,
    user_id UUID REFERENCES users (id_user) ON DELETE SET NULL, -- Nullable pour événements système
    event_category event_category_enum NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    severity severity_enum DEFAULT 'info',
    message TEXT,
    metadata JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index composite pour filtrer par catégorie + date (requête la plus courante)
CREATE INDEX idx_events_category_date ON app_events (
    event_category,
    created_at DESC
);

-- Index pour recherche par utilisateur
CREATE INDEX idx_events_user ON app_events (user_id)
WHERE
    user_id IS NOT NULL;

-- Index GIN pour recherche dans metadata
CREATE INDEX idx_events_metadata ON app_events USING gin (metadata);

-- Index pour les événements critiques (alerte monitoring)
CREATE INDEX idx_events_critical ON app_events (severity, created_at DESC)
WHERE
    severity = 'critical';

-- Documentation
COMMENT ON
TABLE app_events IS 'Table unifiée pour analytics, audit, monitoring et événements RGPD';

COMMENT ON COLUMN app_events.event_type IS 'Type précis avec convention : [domaine].[action] (ex: user.login, item.created, gdpr.export)';

COMMENT ON COLUMN app_events.severity IS 'Niveau de gravité (utile pour filtrer les alertes monitoring)';

COMMENT ON COLUMN app_events.message IS 'Message lisible pour les humains (logs, dashboards)';

COMMENT ON COLUMN app_events.metadata IS 'Contexte flexible en JSONB :
{
  "ip": "192.168.1.1",
  "user_agent": "Mozilla/5.0...",
  "item_id": "uuid...",
  "error_stack": "...",
  "duration_ms": 234
}';

-- ============================================================================
-- SUPPRESSION DE TOUTES LES TABLES DE LA BASE DE DONNEES

-- Ajoutez ici les tables que vous souhaitez supprimer de la base de données
-- ============================================================================

DROP TABLE IF EXISTS item_tags CASCADE;

DROP TABLE IF EXISTS shares CASCADE;

DROP TABLE IF EXISTS items CASCADE;

DROP TABLE IF EXISTS tags CASCADE;

DROP TABLE IF EXISTS app_events CASCADE;

DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- SUPPRESSION DE TOUTES LES TYPES DE LA BASE DE DONNEES

-- Ajoutez ici les types que vous souhaitez supprimer de la base de données
-- ============================================================================

DROP TYPE IF EXISTS role_enum CASCADE;

DROP TYPE IF EXISTS auth_provider_enum CASCADE;

DROP TYPE IF EXISTS content_type_enum CASCADE;

DROP TYPE IF EXISTS event_category_enum CASCADE;

DROP TYPE IF EXISTS severity_enum CASCADE;
