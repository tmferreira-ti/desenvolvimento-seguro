#!/bin/bash

# ============================================================
# Preparação silenciosa do laboratório
# Metasploitable3 Linux
#
# - Não altera shares existentes
# - Apenas adiciona [arquivos], se ainda não existir
# - Não imprime informações na tela
# ============================================================

if [ "$EUID" -ne 0 ]; then
    exit 1
fi

SMB_CONF="/etc/samba/smb.conf"
SHARE_DIR="/srv/smb-aula"

# ------------------------------------------------------------
# Usuários do laboratório
# ------------------------------------------------------------

id ana.silva >/dev/null 2>&1 || \
    useradd -m -s /bin/bash -c "Ana Silva" ana.silva

id bruno.souza >/dev/null 2>&1 || \
    useradd -m -s /bin/bash -c "Bruno Souza" bruno.souza

id carla.oliveira >/dev/null 2>&1 || \
    useradd -m -s /bin/bash -c "Carla Oliveira" carla.oliveira

id diego.santos >/dev/null 2>&1 || \
    useradd -m -s /bin/bash -c "Diego Santos" diego.santos


# ------------------------------------------------------------
# Senhas
#
# Três usuários continuam usando o padrão inicial.
# Um deles alterou a senha.
# ------------------------------------------------------------

echo 'ana.silva:Fatec000042' | chpasswd
echo 'bruno.souza:Fatec000137' | chpasswd
echo 'carla.oliveira:Fatec000284' | chpasswd
echo 'diego.santos:Mudou@Senha2026' | chpasswd


# ------------------------------------------------------------
# Diretório compartilhado
# ------------------------------------------------------------

mkdir -p "$SHARE_DIR"
chmod 755 "$SHARE_DIR"


# ------------------------------------------------------------
# Lista de funcionários
# Somente nomes.
# ------------------------------------------------------------

cat > "$SHARE_DIR/lista_funcionarios.csv" << 'EOF'
nome
Ana Silva
Bruno Souza
Carla Oliveira
Diego Santos
EOF


# ------------------------------------------------------------
# Política de criação de contas
# ------------------------------------------------------------

cat > "$SHARE_DIR/politica_contas.txt" << 'EOF'
============================================================
          PROCEDIMENTO DE CRIAÇÃO DE CONTAS
============================================================

Departamento de Tecnologia da Informação


1. PADRÃO DE LOGIN

As contas dos funcionários devem seguir o padrão:

primeiro_nome.ultimo_sobrenome


Exemplo:

Nome:
Joao da Silva

Login:
joao.silva



2. SENHA INICIAL

A senha inicial das novas contas deverá seguir o padrão:

Fatec + número de matrícula

O número de matrícula possui exatamente 6 dígitos.

Formato:

FatecXXXXXX

Onde XXXXXX representa o número da matrícula.


3. PRIMEIRO ACESSO

A senha inicial é temporária e deverá ser alterada pelo
funcionário após o primeiro acesso.


============================================================
Departamento de Tecnologia da Informação
============================================================
EOF


# ------------------------------------------------------------
# Arquivos adicionais
# ------------------------------------------------------------

cat > "$SHARE_DIR/README.txt" << 'EOF'
DIRETÓRIO DE ARQUIVOS

Este compartilhamento contém documentos de consulta
destinados aos funcionários.

Consulte os documentos disponíveis conforme necessário.
EOF


cat > "$SHARE_DIR/aviso.txt" << 'EOF'
AVISO

Os procedimentos para criação e primeiro acesso às contas
corporativas foram atualizados.

Consulte a documentação disponível neste diretório.
EOF


chmod 644 "$SHARE_DIR"/*.txt
chmod 644 "$SHARE_DIR"/*.csv


# ------------------------------------------------------------
# Backup preventivo
# ------------------------------------------------------------

if [ ! -f "${SMB_CONF}.backup-aula" ]; then
    cp "$SMB_CONF" "${SMB_CONF}.backup-aula"
fi


# ------------------------------------------------------------
# Adiciona SOMENTE o novo compartilhamento.
# Não modifica [public], [print$] ou qualquer outro.
# ------------------------------------------------------------

if ! grep -q '^\[arquivos\]' "$SMB_CONF"; then

    cat >> "$SMB_CONF" << EOF

[arquivos]
    comment = Arquivos para Consulta
    path = $SHARE_DIR
    browseable = yes
    guest ok = yes
    public = yes
    read only = yes

EOF

fi


# ------------------------------------------------------------
# Validação
# ------------------------------------------------------------

testparm -s >/dev/null 2>&1 || exit 1


# ------------------------------------------------------------
# Reiniciar Samba
# ------------------------------------------------------------

service smbd restart >/dev/null 2>&1

exit 0