# Testes de Compartilhamento e Controle de Acesso (M3)

Executados a partir de um cliente na LAN (`10.0.2.0/24`) contra o servidor `10.0.2.10`.
Usuários de teste: `ana` (devs), `carla` (diretoria), `backup_user` (backup_mgr).

## 1. Listagem dos compartilhamentos

```bash
smbclient -L 10.0.2.10 -N
```
Esperado: aparecem `publico`, `projetos` e `backups`.

## 2. Pasta pública (`publico`) — convidado

```bash
echo "teste" > teste.txt
smbclient //10.0.2.10/publico -N -c "put teste.txt; ls"
```
Esperado: envio concluído e arquivo listado.

## 3. Pasta de projetos (`projetos`)

| Teste | Comando | Esperado |
|---|---|---|
| `ana` (devs) grava | `smbclient //10.0.2.10/projetos -U ana -c "put teste.txt; ls"` | Sucesso |
| `carla` (diretoria) lê e grava | `smbclient //10.0.2.10/projetos -U carla -c "ls; put teste.txt carla.txt"` | Sucesso |
| Convidado tenta acessar | `smbclient //10.0.2.10/projetos -N -c "ls"` | `NT_STATUS_ACCESS_DENIED` |
| `backup_user` tenta acessar | `smbclient //10.0.2.10/projetos -U backup_user -c "ls"` | `NT_STATUS_ACCESS_DENIED` |

## 4. Pasta de backups (`backups`)

| Teste | Comando | Esperado |
|---|---|---|
| `backup_user` grava | `smbclient //10.0.2.10/backups -U backup_user -c "put teste.txt; ls"` | Sucesso |
| `ana` tenta acessar | `smbclient //10.0.2.10/backups -U ana -c "ls"` | `NT_STATUS_ACCESS_DENIED` |

## 5. Mapeamento de pasta (demonstração)

Windows:
```
net use Z: \\10.0.2.10\projetos /user:ana
```
Linux:
```bash
sudo mount -t cifs //10.0.2.10/projetos /mnt/projetos -o username=ana,vers=3.0
```

## 6. Quotas

O teste de estouro de quota (`Disk quota exceeded`) está em `usuarios/testes_acesso.sh` e documentado em `usuarios-permissoes.md`.

## 7. Verificação no servidor

```bash
sudo systemctl status smbd
sudo ss -tlnp | grep -E ':139|:445'
sudo testparm -s
sudo smbstatus
```
