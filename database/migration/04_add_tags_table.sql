--TODO ETAPE 5 : Création de table index et commentaire (DDL)
-- 5.2 Table Tags
-- Relation Merise : users(1,N) -- (1,1) tags ( un tag appartient à un utilisateur)

DROP TABLE IF EXISTS tags;

CREATE TABLE IF NOT EXISTS tags (
    id_tag UUID PRIMARY KEY,
    tag_name VARCHAR(50) NOt NULL,
    user_id UUID NOT NULL REFERENCES users (id_user) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT unique_user_tag UNIQUE (user_id, tag_name) -- Un user ne peut pas avoir deux fois le même tag
);

-- Indexation
CREATE INDEX idx_tags_settings ON tags (user_id);

--Documentation

COMMENT ON TABLE tags IS 'Mots-clés personnalisés créer par les utilisateurs pour classer leur items';

--Application du trigger
CREATE TRIGGER set_timestamp_tags BEFORE UPDATE ON tags  FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamps();