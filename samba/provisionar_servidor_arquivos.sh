#!/usr/bin/env bash
# =============================================================================
# Integrante 3 - Provisionamento do Servidor de Arquivos (Samba)
# Instala o Samba, cria as pastas, aplica o smb.conf do repositório e sobe o serviço.
# Grupos, usuários, permissões finais e quotas ficam no script do Integrante 4:
#   usuarios/setup_usuarios_permissoes.sh  (rodar DEPOIS deste)
# Uso: sudo ./provisionar_servidor_arquivos.sh
# =============================================================================
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="/srv/samba/compartilhado"

[[ $EUID -eq 0 ]] || { echo "Execute como root (sudo)."; exit 1; }
[[ -f "$DIR/smb.conf" ]] || { echo "smb.conf não encontrado em $DIR"; exit 1; }

echo "[1/5] Instalando Samba..."
apt-get update -qq
apt-get install -y -qq samba smbclient >/dev/null

echo "[2/5] Criando estrutura de diretórios..."
mkdir -p "$BASE"/{publico,projetos,backups}
chmod 755 /srv/samba "$BASE"
chown nobody:nogroup "$BASE/publico"; chmod 2775 "$BASE/publico"
# projetos e backups recebem dono/grupo/permissão finais no script do Integrante 4
chmod 2770 "$BASE/projetos" "$BASE/backups"

echo "[3/5] Aplicando smb.conf..."
[[ -f /etc/samba/smb.conf && ! -f /etc/samba/smb.conf.orig ]] && cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
install -m 644 "$DIR/smb.conf" /etc/samba/smb.conf
testparm -s >/dev/null

echo "[4/5] Habilitando serviço..."
systemctl disable --now nmbd 2>/dev/null || true   # NetBIOS legado não é usado
systemctl enable --now smbd
systemctl restart smbd

echo "[5/5] Verificação:"
systemctl is-active smbd
ss -tlnp | grep -E ':139|:445' || echo "ATENÇÃO: smbd não está escutando em 139/445."
smbclient -L 127.0.0.1 -N 2>/dev/null | sed -n '1,12p' || true
echo; echo "Pronto. Agora rode usuarios/setup_usuarios_permissoes.sh (Integrante 4)."
