#!/usr/bin/env sh

# ============================================
# 🐼 MEMORIA - Script d'initialisation DB
# ============================================

set -e  # Arrêt en cas d'erreur

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Chargement des variables d'environnement
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}❌ Fichier .env introuvable !${NC}"
    exit 1
fi

echo -e "${GREEN}🐼 Memoria - Initialisation de la base de données${NC}\n"

# Fonction d'exécution SQL
# Execute a SQL file with a description
#
# Args:
#   $1: The SQL file to execute
#   $2: A description of the SQL file
#
# Returns:
#   0 if the SQL file executes successfully
#   1 if there is an error executing the SQL file
execute_sql() {
    local file=$1
    local description=$2

    echo -e "${YELLOW}➜${NC} $description"

    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -f "$file" -q

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} OK\n"
    else
        echo -e "${RED}✗${NC} ERREUR\n"
        exit 1
    fi
}

# Fonction pour se connecter à memoria_db_dev
# Execute a SQL file with a description
#
# Args:
#   $1: The SQL file to execute
#   $2: A description of the SQL file
#
# Returns:
#   0 if the SQL file executes successfully
#   1 if there is an error executing the SQL file
execute_sql_app() {
    local file=$1
    local description=$2

    echo -e "${YELLOW}➜${NC} $description"

    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file" -q

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} OK\n"
    else
        echo -e "${RED}✗${NC} ERREUR\n"
        exit 1
    fi
}

# ============================================
# Étapes d'exécution
# ============================================

echo -e "${GREEN}📦 Phase 1 : Configuration${NC}"
execute_sql "database/migrations/00_add_database_config.sql" "Création base de données"
execute_sql "database/migrations/01_add_security_role.sql" "Création rôle applicatif"

echo -e "${GREEN}🔧 Phase 2 : Extensions & Types${NC}"
execute_sql_app "database/migrations/02_add_extensions.sql" "Installation extensions"
execute_sql_app "database/migrations/02_add_types.sql" "Création types personalisés"

echo -e "${GREEN}🛠️ Phase 3 : Triggers${NC}"
execute_sql_app "database/triggers/01_add_trigger_set_timestamp.sql" "Création fonction trigger"

echo -e "${GREEN}🗄️ Phase 4 : Tables${NC}"
execute_sql_app "database/migrations/03_add_users_table.sql" "Table users"
execute_sql_app "database/migrations/04_add_tags_table.sql" "Table tags"
execute_sql_app "database/migrations/05_add_items_table.sql" "Table items"
execute_sql_app "database/migrations/06_add_shares_table.sql" "Table shares"
execute_sql_app "database/migrations/07_add_item_tags_table_pivot.sql" "Table item_tags"
execute_sql_app "database/migrations/08_add_app_events_table.sql" "Table app_events"

echo -e "${GREEN}🌱 Phase 5 : Données de test${NC}"
read -p "Voulez-vous insérer les données de test ? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    execute_sql_app "database/seeders/01_add_users_seeders.sql" "Utilisateurs de test"
    execute_sql_app "database/seeders/02_add_tags_seeders.sql" "Tags de test"
fi

echo -e "${GREEN}✅ Base de données initialisée avec succès !${NC}"
echo -e "\n📊 Connexion : psql -h $DB_HOST -p $DB_PORT -U $DB_APP_USER -d $DB_NAME"
