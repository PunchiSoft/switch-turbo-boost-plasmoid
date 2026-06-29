<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

[English](INSTALL.md) | [Español](INSTALL.es.md) | [Português](INSTALL.pt.md)

# Instalacao do Switch Turbo Boost Plasmoid

Guia rapido para instalar o plasmoide no ambiente de desktop KDE Plasma 6.

## 1. Baixar o Projeto

Pelo Git:

```bash
git clone https://github.com/PunchiSoft/switch-turbo-boost-plasmoid.git
cd switch-turbo-boost-plasmoid
```

Se voce ja tem o codigo localmente:

```bash
cd switch-turbo-boost-plasmoid
```

## O Que Cada Script Faz

| Script | O que instala ou remove | Uso recomendado |
| --- | --- | --- |
| `install.sh` | Instalador principal. Pode instalar tudo, apenas o plasmoide ou apenas o backend. | Recomendado para usuarios finais. |
| `uninstall.sh` | Remove o plasmoide local, os helpers do sistema e a politica PolicyKit. | Use para desinstalar completamente o projeto. |
| `build-plasmoid.sh` | Gera `switch-turbo-boost.plasmoid`. | Use apenas para instalacao visual a partir de arquivo local. |

## Instalacao Visual pelo KDE Plasma

Esta opcao instala apenas a interface do plasmoide a partir de um arquivo local.

### 1. Gerar o Arquivo .plasmoid

```bash
chmod +x build-plasmoid.sh
./build-plasmoid.sh
```

Isso cria `switch-turbo-boost.plasmoid` a partir da pasta `package/`. O arquivo contem `metadata.json` na raiz do pacote e nao inclui a pasta `package/` dentro do zip.

### 2. Instalar pelo Plasma

1. Abra o Plasma.
2. Adicione widgets.
3. Instale widget a partir de arquivo local.
4. Selecione `switch-turbo-boost.plasmoid`.

**Aviso:** a instalacao visual instala apenas a interface do plasmoide. Para que o botao ON/OFF funcione com permissoes do sistema, execute tambem:

```bash
chmod +x install.sh
./install.sh --backend-only
```

Durante este passo, o PolicyKit solicitara autenticacao de administrador.

## Instalacao Completa por Script

### 1. Dar Permissao de Execucao

```bash
chmod +x install.sh
```

### 2. Executar o Instalador

```bash
./install.sh
```

Durante a instalacao do plasmoide, escolha o idioma da interface quando solicitado. Tambem e possivel passar o idioma explicitamente:

```bash
./install.sh --language pt
./install.sh --language es
./install.sh --language en
./install.sh --language auto
```

Tambem e possivel escolher qual parte instalar:

```bash
./install.sh --full --language pt
./install.sh --plasmoid-only --language es
./install.sh --backend-only
./install.sh --mode backend
```

Para recarregar o Plasma Shell automaticamente depois de instalar ou atualizar a interface:

```bash
./install.sh --full --language pt --reload-plasma
./install.sh --plasmoid-only --reload-plasma
```

Ao iniciar, o instalador avisa quando o modo selecionado inclui o backend privilegiado. Durante essa etapa de backend, o PolicyKit solicitara autenticacao de administrador.

Se a autenticacao for cancelada durante uma instalacao completa, a interface local do plasmoide pode ja estar instalada, mas o botao ON/OFF nao funcionara ate instalar o backend com `./install.sh --backend-only`.

`install.sh` instala diretamente a partir da pasta `package/`; ele nao gera o arquivo `switch-turbo-boost.plasmoid`. Use `build-plasmoid.sh` apenas quando quiser instalar a partir de um arquivo local pela interface grafica do Plasma.

O instalador copia:

- O plasmoide para `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`
- Os scripts do sistema para `/usr/local/libexec/switch-turbo-boost-plasmoid/`, incluindo `get-cpu-info.sh` e `get-cpu-vendor.sh`
- A politica PolicyKit para `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`

### 3. Recarregar Plasma Shell

Depois de instalar ou atualizar o plasmoide, talvez seja necessario recarregar o Plasma Shell para que o KDE detecte as mudancas.

Em um terminal interativo, o instalador pergunta no final se voce deseja recarregar o Plasma Shell. Voce pode forcar isso com `--reload-plasma` ou evitar a pergunta com `--no-reload-plasma`; internamente ele tenta usar `kquitapp6` com `kstart6` ou `kstart`, e usa `plasmashell --replace` como alternativa quando necessario.

#### Opcao 1 - Encerrar Sessao e Entrar Novamente

Encerrar a sessao e entrar novamente e a forma mais segura de recarregar completamente o Plasma sem depender de comandos no terminal.

Esta opcao e recomendada para usuarios que nao querem usar o terminal.

#### Opcao 2 - Usar kquitapp6 + kstart

Esta opcao foi testada no Fedora KDE Plasma 6. Ela reinicia o Plasma Shell sem fechar toda a sessao:

```bash
kquitapp6 plasmashell
kstart plasmashell
```

#### Opcao 3 - Usar nohup com plasmashell --replace

Use esta alternativa se `kstart` nao estiver disponivel. `nohup` evita que o Plasma fique preso ao terminal:

```bash
kquitapp6 plasmashell
nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
```

Nem todos os sistemas KDE incluem os mesmos comandos. Se `kstart` nao existir, use a alternativa com `nohup` ou encerre a sessao.

### 4. Adicionar o Plasmoide ao Painel

1. Clique com o botao direito no painel do Plasma.
2. Selecione **Adicionar ou gerenciar widgets**.
3. Procure **Switch Turbo Boost**.
4. Arraste para o painel.

## Configuracao

Nas configuracoes do plasmoide, voce pode ajustar:

- Icone mostrado no painel.
- Icone do processador mostrado no menu flutuante, com opcoes automaticas, AMD, Intel, CPU, chip ou um icone personalizado do sistema.
- Idioma da interface.
- Aparencia do menu flutuante: tema automatico e cores personalizadas.
- Largura e altura preferidas do menu flutuante.

## Testar Funcionamento

Consultar estado:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Detectar fabricante:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-vendor.sh
```

Detectar fabricante e modelo:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-info.sh
```

Ativar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-on.sh
```

Desativar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-off.sh
```

## Desinstalacao

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Idioma e recarga do Plasma opcionais:

```bash
./uninstall.sh --language pt --reload-plasma
./uninstall.sh --help
```

Durante a limpeza do sistema, o PolicyKit solicitara autenticacao de administrador antes de remover os helpers e a politica.
Se a autenticacao for cancelada, a interface local do plasmoide pode ja ter sido removida, mas os helpers do sistema e a politica PolicyKit podem continuar instalados.
