# Módulo M3 — Servidor de Arquivos Centralizado (Samba)

## Visão Geral
Servidor de arquivos configurado com Samba na sub-rede LAN (`10.0.2.0/24`) para fornecer armazenamento compartilhado e servir como ponto de recepção dos backups automáticos do banco de dados PostgreSQL.

---

## Estrutura de Diretórios e Compartilhamentos

Abaixo estão detalhados os diretórios criados no servidor e as respetivas políticas de acesso:

| Compartilhamento | Caminho no Servidor | Permissões | Controle de Acesso | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| `[publico]` | `/compartilhado/publico` | `775` | Leitura e escrita livre (Guest/LAN) | Arquivos de uso geral para a equipe. |
| `[projetos]` | `/compartilhado/projetos` | `770` | Restrito (`@devs`, `@admin`) | Espaço de trabalho colaborativo para desenvolvimento[cite: 1]. |
| `[backups]` | `/compartilhado/backups` | `700` | Restrito (`backup_user`, `@admin`) | Destino seguro para os arquivos `.tar.gz` gerados pelo script de backup[cite: 1]. |

---

## Configuração do Serviço (`smb.conf`)
O arquivo de configuração principal (`/etc/samba/smb.conf`) foi ajustado para garantir o isolamento adequado na rede local e o mapeamento correto dos grupos POSIX.

---

## Procedimentos de Teste e Validação

Para validar o funcionamento do servidor de arquivos a partir de um cliente na LAN (`10.0.2.0/24`)[cite: 1]:

1. **Testar listagem de compartilhamentos:**
   ```bash
   smbclient -L IP_DO_SERVIDOR_DE_ARQUIVOS -U%

   ## Testes de Validação e Controle de Acesso

Para comprovar o isolamento e o cumprimento da política de privilégio mínimo, foram realizados os seguintes testes de acesso na rede LAN (`10.0.2.0/24`):
