#!/usr/bin/env bash
# Executar no servidor PostgreSQL como a conta autorizada pg_backup.
set -Eeuo pipefail
umask 077
trap 'rc=$?; echo "Erro na geração (código $rc)." >&2; exit "$rc"' ERR

[[ $# == 0 ]] || { echo 'Uso: gerar_backup.sh' >&2; exit 1; }
trabalho=$(mktemp -d "${TMPDIR:-/var/tmp}/empresa-gerar.XXXXXXXX")
limpar() {
    rm -f -- "$trabalho/database.dump" "$trabalho/pacote.tar.gz"
    rmdir -- "$trabalho"
}
trap limpar EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

# Socket local e papel explícito; nunca solicitar ou guardar senha no script.
unset PGHOST PGHOSTADDR PGSERVICE PGSERVICEFILE PGDATABASE PGUSER PGPASSWORD PGOPTIONS
export PGCONNECT_TIMEOUT=10
echo 'Exportando empresa_db...' >&2
pg_dump --no-password --host=/var/run/postgresql --port=5432 \
    --username=pg_backup --dbname=empresa_db --format=custom --compress=0 \
    --lock-wait-timeout=30s --file="$trabalho/database.dump"
[[ -s $trabalho/database.dump ]]

# Preparar o pacote inteiro antes de transmitir; stdout contém somente bytes.
tar --format=ustar -czf "$trabalho/pacote.tar.gz" -C "$trabalho" database.dump
gzip -t -- "$trabalho/pacote.tar.gz"
echo 'Pacote gerado; transmitindo.' >&2
cat -- "$trabalho/pacote.tar.gz"
