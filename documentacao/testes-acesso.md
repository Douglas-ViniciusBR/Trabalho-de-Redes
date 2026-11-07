### 1. Teste de Acesso Público (`/compartilhado/publico`)
* **Cenário:** Usuário anônimo ou qualquer máquina da LAN tentando ler e escrever.
* **Comando:**
  ```bash
  smbclient //10.0.2.24/publico -U% -c "put teste.txt; ls"