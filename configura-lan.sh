#!/usr/bin/env bash
set -Eeuo pipefail

CONEXAO="LAN"
INTERFACE="eth1"
ENDERECO="192.168.10.10/24"

if [[ ${EUID} -ne 0 ]]; then
    echo "Erro: execute este script como root (sudo $0)." >&2
    exit 1
fi

for comando in nmcli systemctl ip; do
    if ! command -v "$comando" >/dev/null 2>&1; then
        echo "Erro: comando obrigatório não encontrado: $comando" >&2
        exit 1
    fi
done

if ! ip link show dev "$INTERFACE" >/dev/null 2>&1; then
    echo "Erro: a interface $INTERFACE não existe nesta VM." >&2
    exit 1
fi

# Cria o perfil quando necessário. UUID e MAC são gerados/mantidos pela VM.
if ! nmcli connection show "$CONEXAO" >/dev/null 2>&1; then
    nmcli connection add \
        type ethernet \
        ifname "$INTERFACE" \
        con-name "$CONEXAO"
fi

# ipv4.addresses substitui a lista inteira, removendo endereços anteriores do
# perfil. Os campos vazios evitam herdar gateway e DNS de uma configuração velha.
nmcli connection modify "$CONEXAO" \
    connection.interface-name "$INTERFACE" \
    connection.autoconnect yes \
    connection.autoconnect-priority 100 \
    802-3-ethernet.mac-address "" \
    ipv4.method manual \
    ipv4.addresses "$ENDERECO" \
    ipv4.gateway "" \
    ipv4.dns "" \
    ipv4.routes "" \
    ipv4.never-default no \
    ipv6.method auto

# Reinicia o serviço solicitado e ativa imediatamente o perfil correto.
systemctl restart NetworkManager
nmcli device disconnect "$INTERFACE" >/dev/null 2>&1 || true
nmcli connection up "$CONEXAO" ifname "$INTERFACE"

# Confirma que não restou outro IPv4 global na interface.
mapfile -t ipv4_atuais < <(ip -4 -o addr show dev "$INTERFACE" scope global | awk '{print $4}')
if [[ ${#ipv4_atuais[@]} -ne 1 || ${ipv4_atuais[0]} != "$ENDERECO" ]]; then
    echo "Erro: a configuração final de $INTERFACE não corresponde a $ENDERECO." >&2
    printf 'Endereços encontrados: %s\n' "${ipv4_atuais[*]:-(nenhum)}" >&2
    exit 1
fi

echo "Configuração aplicada: $INTERFACE = $ENDERECO (perfil $CONEXAO)."