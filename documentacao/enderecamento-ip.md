# Plano de Endereçamento IP

## 1. Objetivo

Este documento apresenta o planejamento dos endereços IP utilizados na infraestrutura de rede do projeto.

A rede será dividida em três zonas: DMZ, LAN e DB. Cada zona terá sua própria faixa de endereços IP, permitindo organizar os equipamentos e controlar a comunicação entre eles.

## 2. Redes utilizadas

| Zona | Rede | Máscara |
|---|---|---|
| WAN | Obtido via DHCP | 255.255.255.0 |
| DMZ | 10.0.1.0/24 | 255.255.255.0 |
| LAN | 10.0.2.0/24 | 255.255.255.0 |
| DB | 10.0.3.0/24 | 255.255.255.0 |

## 3. Endereços do Firewall

O Firewall será responsável pela comunicação entre as redes.

| Interface | Zona | Endereço IP |
|---|---|---|
| enp0s3 | WAN | Obtido via DHCP |
| enp0s8 | DMZ | 10.0.1.1 |
| enp0s9 | LAN | 10.0.2.1 |
| enp0s10 | DB | 10.0.3.1 |

## 4. Endereços planejados para os servidores

Os endereços abaixo representam o planejamento inicial dos servidores.

| Equipamento | Zona | Endereço IP |
|---|---|---|
| Servidor Web (Nginx) | DMZ | 10.0.1.10 |
| Servidor de Arquivos (Samba) | LAN | 10.0.2.10 |
| Servidor PostgreSQL | DB | 10.0.3.10 |

## 5. Configuração de DHCP

A rede LAN utilizará DHCP para distribuir automaticamente endereços IP às estações de trabalho.

Faixa planejada para distribuição:

- Início: 10.0.2.100
- Fim: 10.0.2.200
- Gateway: 10.0.2.1

Os endereços dos servidores serão configurados como estáticos, evitando conflitos com a distribuição automática.

## 6. Gateways das redes

Cada zona utilizará a interface correspondente do Firewall como gateway padrão.

| Zona | Gateway |
|---|---|
| DMZ | 10.0.1.1 |
| LAN | 10.0.2.1 |
| DB | 10.0.3.1 |

## 7. Observações

- O Firewall utiliza Ubuntu Server.
- O roteamento entre as redes será controlado pelo Firewall.
- A comunicação entre as zonas será limitada por regras de segurança.
- Os endereços dos servidores poderão ser ajustados durante a implantação.
- A configuração do serviço DNS será documentada durante sua implementação.
