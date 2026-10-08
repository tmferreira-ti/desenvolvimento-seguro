#!/usr/bin/env bash
set -e

DEST_DIR="/var/www/html/fatecseg"
TAR_URL="https://github.com/tmferreira-ti/desenvolvimento-seguro/raw/refs/heads/main/fatecseg.tar.gz"
TEMP_TAR="/tmp/fatecseg.tar.gz"
DB_USER="root"
DB_PASS=""

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   FatecSeg Corp - Deploy e Configuração Automática   ${NC}"
echo -e "${BLUE}======================================================${NC}"

# 1. Limpar e recriar diretório
echo -e "\n${YELLOW}[1/5] Limpando diretório ${DEST_DIR}...${NC}"
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
echo -e "${GREEN}[✓] Diretório preparado.${NC}"

# 2. Download do pacote
echo -e "\n${YELLOW}[2/5] Baixando pacote do GitHub...${NC}"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$TAR_URL" -o "$TEMP_TAR"
elif command -v wget >/dev/null 2>&1; then
    wget -q --show-progress "$TAR_URL" -O "$TEMP_TAR"
else
    echo -e "${RED}[X] Erro: curl ou wget não encontrado.${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Download concluído.${NC}"

# 3. Extrair arquivos
echo -e "\n${YELLOW}[3/5] Extraindo arquivos em ${DEST_DIR}...${NC}"
tar -xzf "$TEMP_TAR" -C "$DEST_DIR"
rm -f "$TEMP_TAR"
echo -e "${GREEN}[✓] Arquivos extraídos com sucesso.${NC}"

# 4. Ajustar permissões
echo -e "\n${YELLOW}[4/5] Ajustando permissões para o servidor web...${NC}"
chown -R www-data:www-data "$DEST_DIR" 2>/dev/null || true
chmod -R 755 "$DEST_DIR"
echo -e "${GREEN}[✓] Permissões configuradas.${NC}"

# 5. Configurar banco de dados
echo -e "\n${YELLOW}[5/5] Configurando e populando o banco de dados...${NC}"
DB_OK=false

if command -v mysql >/dev/null 2>&1 || command -v mariadb >/dev/null 2>&1; then
    MYSQL_BIN=$(command -v mysql || command -v mariadb)
    echo -e "Executando ${DEST_DIR}/database.sql..."
    
    if [ -z "$DB_PASS" ]; then
        if $MYSQL_BIN -u "$DB_USER" < "$DEST_DIR/database.sql" 2>/dev/null; then
            DB_OK=true
        elif sudo $MYSQL_BIN < "$DEST_DIR/database.sql" 2>/dev/null; then
            DB_OK=true
        fi
    else
        if $MYSQL_BIN -u "$DB_USER" -p"$DB_PASS" < "$DEST_DIR/database.sql" 2>/dev/null; then
            DB_OK=true
        fi
    fi
fi

if [ "$DB_OK" = false ] && command -v php >/dev/null 2>&1; then
    echo -e "Executando setup_db.php via PHP CLI..."
    if php "$DEST_DIR/setup_db.php" >/dev/null 2>&1; then
        DB_OK=true
    fi
fi

if [ "$DB_OK" = true ]; then
    echo -e "${GREEN}[✓] Banco de dados criado e populado com 12 usuários!${NC}"
else
    echo -e "${YELLOW}[!] Finalize a configuração pelo navegador: http://localhost/fatecseg/setup_db.php${NC}"
fi

IP_LOCAL=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")
if [ -z "$IP_LOCAL" ]; then IP_LOCAL="localhost"; fi

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}   Deploy concluído com sucesso!                      ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Acesse o portal:"
echo -e " -> http://${IP_LOCAL}/fatecseg/"
echo -e " -> http://localhost/fatecseg/"
echo -e " -> Login: http://${IP_LOCAL}/fatecseg/index.php?page=pages/login.php"
echo -e "======================================================\n"
