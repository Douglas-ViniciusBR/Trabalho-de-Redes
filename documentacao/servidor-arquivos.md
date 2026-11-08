# Módulo M3 — Servidor de Arquivos Centralizado (Samba)

## 1. Visão geral

Servidor de arquivos com **Samba 4** na LAN (`10.0.2.0/24`), IP estático `10.0.2.10`, nome `SRV-ARQUIVOS`.
Serve armazenamento compartilhado aos usuários e recebe os backups automáticos do PostgreSQL.

Escolha do Samba (em vez de NFS): interoperabilidade com estações Windows e Linux e autenticação por usuário/grupo.

## 2. Instalação e provisionamento

```bash
sudo ./samba/provisionar_servidor_arquivos.sh   # Integrante 3: Samba, pastas, smb.conf, serviço
sudo SENHA_INICIAL='...' ./usuarios/setup_usuarios_permissoes.sh   # Integrante 4: usuários, permissões, quotas
```

O primeiro script instala o Samba, cria as pastas, aplica o `samba/smb.conf` e habilita o `smbd`.
O IP estático é configurado com `samba/netplan-servidor-arquivos.yaml` (`sudo netplan apply`).

## 3. Estrutura de diretórios e compartilhamentos

| Compartilhamento | Caminho no servidor | Modo | Quem acessa | Descrição |
|---|---|---|---|---|
| `[publico]` | `/srv/samba/compartilhado/publico` | `2775` | Qualquer cliente da LAN (convidado) | Arquivos de uso geral |
| `[projetos]` | `/srv/samba/compartilhado/projetos` | `2770` + ACL | `@devs`, `@diretoria` | Trabalho colaborativo |
| `[backups]` | `/srv/samba/compartilhado/backups` | `2770` | `@backup_mgr` | Destino dos `.tar.gz` do PostgreSQL |

## 4. Configuração do serviço (`smb.conf`)

| Parâmetro | Função |
|---|---|
| `interfaces` + `bind interfaces only` | Escuta somente na interface da LAN (`10.0.2.10`) |
| `hosts allow` / `hosts deny = ALL` | Aceita só a LAN (`10.0.2.0/24`) e o servidor DB (`10.0.3.10`, para o backup) |
| `server min protocol = SMB2` | Desativa SMB1 (inseguro) |
| `disable netbios = yes` | Não usa o NetBIOS legado (nmbd desativado) |
| `map to guest = Bad User` | Convidado só funciona no share `[publico]` |
| `valid users = @grupo` | Restringe cada share aos grupos POSIX autorizados |
| `create mask` / `directory mask` | Arquivos novos sem acesso para "outros" (exceto `publico`) |

O controle de acesso combina duas camadas: o Samba (`valid users`) e as permissões POSIX/ACL do sistema de arquivos (ver `usuarios-permissoes.md`).

## 5. Acesso pela rede LAN

- Clientes e servidor de arquivos estão na **mesma sub-rede** (LAN), então o tráfego não passa pelo firewall.
- Portas usadas: `445/TCP` (SMB) e `139/TCP`.
- O backup vem do servidor DB (zona DB, `10.0.3.10`) e **atravessa o firewall**: é preciso uma regra DB → `10.0.2.10` na porta usada pelo envio (SSH/SCP `22` ou SMB `445`). Essa regra é do firewall (Integrante 1) e deve ser combinada com o Integrante 5.

## 6. Testes

Os testes de leitura, escrita e restrição estão em [`testes-acesso.md`](testes-acesso.md).
