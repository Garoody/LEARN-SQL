--TODO ETAPE 3 : Extension et types (DCL)=> à exécuter avec les rôle Postgres
-- on prépare les outils modernes de postgres SQL 18+

--Extension pour les UUID_v7 , la recherche textuelle et le JSONB
CREATE EXTENSION IF NOT EXISTS "citext";
--Texte insensible à la case  (email, pseudo, titre)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
--  Recherche floue (Trigram) pour le moteur de recherche
CREATE EXTENSION IF NOT EXISTS "btree_gin";
-- Indexation performante pour les types standards.

-- Création de types ENUM (Enumerations)

CREATE TYPE role_enum AS ENUM(
    'admin',
    'customer',
    'super_admin'
);

CREATE TYPE auth_provider_enum AS ENUM(
    'local',
    'google',
    'azure',
    'apple'
);

CREATE TYPE content_type_enum AS ENUM(
    'Livre',
    'Podcast',
    'Article',
    'Video',
     'Note'
);

COMMENT ON TYPE role_enum IS 'Rôles des utilisateurs pour la gestion des droites Access Controle Level (ACL)'