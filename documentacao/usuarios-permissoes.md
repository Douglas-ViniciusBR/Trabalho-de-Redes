# Módulo M3 — Usuários, Permissões e Quotas

Responsável: Integrante 4 (usuários, grupos POSIX, permissões e quotas).
Scripts em [`usuarios/`](../usuarios/).

## 1. Grupos e usuários

| Grupo | Finalidade | Usuários de exemplo |
|---|---|---|
| `devs` | Equipe de desenvolvimento | ana, bruno |
| `diretoria` | Gestão | carla |
| `backup_mgr` | Recebe os backups do PostgreSQL | backup_user |

Os nomes dos grupos são os mesmos usados em `samba/smb.conf` (`valid users = @devs, @diretoria` etc.).

## 2. Permissões dos diretórios

| Diretório | Dono:Grupo | Modo | Acesso |
|---|---|---|---|
| `/srv/samba/compartilhado/publico` | nobody:nogroup | `2775` | Livre (convidado) |
| `/srv/samba/compartilhado/projetos` | root:devs | `2770` + ACL | `devs` e `diretoria` (rwx); demais sem acesso |
| `/srv/samba/compartilhado/backups` | root:backup_mgr | `2770` | Somente `backup_mgr` |

- O bit **setgid** (`2xxx`) faz arquivos novos herdarem o grupo da pasta.
- A **ACL** (`setfacl`) dá acesso à `diretoria` em `projetos` sem misturá-la ao grupo `devs`; a ACL *default* garante a herança.

## 3. Quotas de disco

Habilitadas com `usrquota,grpquota` no `/etc/fstab` (pacote `quota`).

| Alvo | Soft | Hard |
|---|---|---|
| Usuário comum | 500 MB | 600 MB |
| `backup_user` | 5 GB | 6 GB |
| Grupo `devs` | 2 GB | 2,5 GB |
| Grupo `diretoria` | 1 GB | 1,25 GB |
| Grupo `backup_mgr` | 10 GB | 12 GB |

Como as pastas usam setgid, os arquivos novos pertencem ao grupo da pasta e contam na quota do grupo.

Tolerância (grace period) de 7 dias após passar do limite *soft*.
Comandos úteis: `repquota -s /`, `repquota -gs /`, `quota -u -s <usuario>`, `edquota -u <usuario>`.

## 4. SOP — Adição de novos usuários

```bash
sudo ./usuarios/adicionar_usuario.sh <usuario> <grupo> [soft_KB] [hard_KB]
# ex.: sudo ./usuarios/adicionar_usuario.sh daniel devs
```

O script cria o usuário Linux, define a senha Linux e Samba (`smbpasswd -a`), aplica a quota e mostra `id` e `quota` ao final.
Para remover: `sudo smbpasswd -x <usuario> && sudo userdel -r <usuario>`.

## 5. Testes realizados

Executar `sudo ./usuarios/testes_acesso.sh` e anexar a saída/prints ao relatório.

| # | Teste | Resultado esperado |
|---|---|---|
| 1 | `ana` (devs) cria arquivo em `projetos` | Permitido |
| 2 | `carla` (diretoria) cria/lê arquivo em `projetos` | Permitido (ACL) |
| 3 | `ana` lista `backups` | **Permission denied** |
| 4 | `backup_user` lista `projetos` | **Permission denied** |
| 5 | Qualquer usuário escreve em `publico` | Permitido |
| 6 | `bruno` grava 700 MB com `dd` | **Disk quota exceeded** em ~600 MB |

Teste via rede (a partir de um cliente na LAN):

```bash
smbclient //10.0.2.10/projetos -U ana -c "put teste.txt; ls"
smbclient //10.0.2.10/backups  -U ana -c "ls"     # NT_STATUS_ACCESS_DENIED
```
