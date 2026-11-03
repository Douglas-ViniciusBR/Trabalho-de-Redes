# Firewall

O firewall foi configurado utilizando o nftables no servidor Ubuntu Server.

Ele controla a comunicação entre as redes WAN, DMZ, LAN e DB, permitindo apenas os acessos necessários para o funcionamento da infraestrutura.

## Interfaces de rede

| Interface | Rede | Endereço |
|---|---|---|
| enp0s3 | WAN | DHCP |
| enp0s8 | DMZ | 10.0.1.1 |
| enp0s9 | LAN | 10.0.2.1 |
| enp0s10 | DB | 10.0.3.1 |

## Regras iniciais

- O tráfego é bloqueado por padrão nas cadeias de entrada e encaminhamento.
- Conexões já estabelecidas são permitidas.
- O acesso SSH está liberado temporariamente para facilitar a administração.
- A LAN possui acesso à internet.
- O servidor Web poderá acessar o PostgreSQL pela porta 5432.
- O NAT permite o compartilhamento da conexão com a internet pela LAN.

## Situação atual

A configuração inicial foi criada e passou pela verificação de sintaxe. Ainda faltam implementar e testar todas as regras de comunicação exigidas pelo projeto.

O firewall ainda não foi ativado com essa configuração.
