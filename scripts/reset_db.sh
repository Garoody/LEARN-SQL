#!/usr/bin/env sh

# ============================================
# 🐼 MEMORIA - Script de réinitialisation DB
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo -e "${RED}❌ Fichier .env introuvable !${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  ATTENTION : Cette action va SUPPRIMER toutes les données !${NC}"
read -p "Êtes-vous sûr ? (tapez 'RESET' pour confirmer) : " -r
echo

if [[ $REPLY != "RESET" ]]; then
    echo -e "${GREEN}✓ Annulation${NC}"
    exit 0
fi

# Execute a SQL file with the current database credentials
# Usage: execute_sql file.sql
#
execute_sql() {
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$1" -q
}

echo -e "${RED}🗑️  Suppression des tables...${NC}"
execute_sql "database/migrations/09_drop_all_tables.sql"

echo -e "${RED}🗑️  Suppression des types...${NC}"
execute_sql "database/migrations/10_drop_all_types.sql"

echo -e "${GREEN}✓ Base de données réinitialisée${NC}\n"

read -p "Voulez-vous recréer la structure ? (o/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Oo]$ ]]; then
    ./scripts/init_db.sh
fi
