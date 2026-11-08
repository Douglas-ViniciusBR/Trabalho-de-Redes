#!/usr/bin/env bash
# Testes de restrição de acesso e quotas (rodar NO servidor de arquivos).
# Uso: sudo ./testes_acesso.sh   -> gera saída para colar/printar no relatório
BASE="/srv/samba/compartilhado"
MNT="$(df --output=target "$BASE" | tail -1)"
ok(){ echo "  [OK]   $1"; }
fail(){ echo "  [FALHA] $1"; }
# espera sucesso
deve_passar(){ local u="$1"; shift; if sudo -u "$u" bash -c "$*" >/dev/null 2>&1; then ok "$u: $*"; else fail "$u: $* (era para funcionar)"; fi; }
# espera negação
deve_negar(){ local u="$1"; shift; if sudo -u "$u" bash -c "$*" >/dev/null 2>&1; then fail "$u: $* (era para ser negado)"; else ok "$u negado: $*"; fi; }

echo "== 1. Usuários e grupos =="; id ana; id carla; id backup_user
echo; echo "== 2. Permissões dos diretórios =="; ls -ld "$BASE"/*; getfacl -p "$BASE/projetos" 2>/dev/null
echo; echo "== 3. Leitura/escrita permitidas =="
deve_passar ana         "touch $BASE/projetos/t_ana.txt"
deve_passar carla       "touch $BASE/projetos/t_carla.txt"
deve_passar ana         "cat $BASE/projetos/t_carla.txt"
deve_passar backup_user "touch $BASE/backups/t_bkp.txt"
deve_passar bruno       "touch $BASE/publico/t_pub.txt"
echo; echo "== 4. Acessos que devem ser NEGADOS =="
deve_negar ana   "ls $BASE/backups"
deve_negar carla "touch $BASE/backups/x.txt"
deve_negar backup_user "ls $BASE/projetos"
echo; echo "== 5. Quota: estourar o limite hard de 'bruno' =="
sudo -u bruno dd if=/dev/zero of="$BASE/projetos/estouro.bin" bs=1M count=700 2>&1 | tail -2
echo "(esperado: 'Disk quota exceeded' perto de 600 MB)"
echo; quota -u -s bruno
echo; echo "== 6. Relatório geral de quotas =="; repquota -s "$MNT"; repquota -gs "$MNT"
echo; echo "Limpando arquivos de teste..."
rm -f "$BASE"/projetos/t_*.txt "$BASE"/projetos/estouro.bin "$BASE"/backups/t_bkp.txt "$BASE"/publico/t_pub.txt
