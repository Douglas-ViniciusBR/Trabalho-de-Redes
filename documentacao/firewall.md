# Firewall e Arquitetura de Segurança

O firewall foi configurado utilizando o `nftables` no servidor Ubuntu Server. Ele controla a comunicação entre as redes WAN, DMZ, LAN e DB, aplicando o princípio de menor privilégio e permitindo apenas os acessos estritamente necessários para o funcionamento da infraestrutura.

## Interfaces de rede

| Interface | Rede | Endereço |
|---|---|---|
| enp0s3 | WAN | DHCP |
| enp0s8 | DMZ | 10.0.1.1 |
| enp0s9 | LAN | 10.0.2.1 |
| enp0s10 | DB | 10.0.3.1 |

## Regras e Políticas de Segurança

- O tráfego é bloqueado por padrão nas cadeias de entrada e encaminhamento (política `DROP`).
- Conexões já estabelecidas e relacionadas (`established, related`) são permitidas para garantir o fluxo de respostas legítimas.
- O acesso SSH é mantido para a administração segura a partir da LAN.
- O NAT está configurado para permitir o compartilhamento da conexão com a internet pela LAN.

## Matriz de Conectividade

| Zona de Origem | Zona de Destino | Porta / Protocolo | Ação | Finalidade / Justificativa |
| :--- | :--- | :--- | :--- | :--- |
| **WAN** | **DMZ (Web)** | 80/443 TCP | **PERMITIR** | Tráfego público HTTP/HTTPS destinado ao Nginx. |
| **DMZ (Web)** | **DB (PostgreSQL)** | 5432 TCP | **PERMITIR** | Conexão estrita da aplicação Flask para consulta ao PostgreSQL. |
| **LAN (Admin)** | **Todas as Zonas** | 22 TCP | **PERMITIR** | Gerenciamento administrativo seguro via SSH. |
| **DMZ / WAN** | **DB (PostgreSQL)** | Todas as outras | **BLOQUEAR** | Isolamento total do banco de dados contra acessos diretos externos. |

## Situação Atual e Validação

A configuração de regras no `nftables` foi aplicada, testada e validada, garantindo o isolamento correto entre as zonas DMZ, LAN e Banco de Dados (DB), impedindo tráfegos não autorizados e cumprindo os requisitos de segurança do projeto.