<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

[English](README.md) | [Español](README.es.md) | [Português](README.pt.md)

# Switch Turbo Boost Plasmoid

Plasmoide leve para o ambiente de desktop KDE Plasma 6. Mostra o estado do Turbo Boost no painel e permite ativar ou desativar com autenticacao do PolicyKit.

Este projeto complementa o Switch Turbo Monitor. Ele nao substitui nem reescreve o aplicativo principal; apenas oferece o interruptor de Turbo Boost.

## Recursos

- Interface QML para Plasma 6.
- Icone compacto no painel.
- Menu flutuante com estado, descricao e controle ON/OFF.
- Indicador verde quando o Turbo Boost esta ON.
- Indicador cinza quando o Turbo Boost esta OFF.
- Icones locais de processador baseados no Papirus Icon Theme.
- Texto AMD, Intel ou CPU detectado conforme o processador.
- Nome do modelo da CPU abaixo do fabricante detectado quando disponivel.
- Leitura ao carregar, depois de alterar o estado e a cada 15 segundos.
- Configuracao de icone do painel, icone do processador automatico ou personalizado, idioma e tamanho do menu flutuante.
- Aparencia automatica conforme o tema do Plasma, com opcao de cores personalizadas.
- Scripts Bash externos para consultar e modificar `/sys`.
- Script Bash externo para detectar o fabricante da CPU em `/proc/cpuinfo`.
- Alteracoes com `pkexec` e politica PolicyKit dedicada.
- Nao usa `sudo` dentro do QML.

## Compatibilidade

- Ambiente de desktop KDE Plasma 6.
- Sessao Plasma em Wayland ou X11.
- Linux com PolicyKit e `pkexec`.
- CPU/kernel com algum destes controles:
  - `/sys/devices/system/cpu/cpufreq/boost`
  - `/sys/devices/system/cpu/intel_pstate/no_turbo`

## Capturas

| Menu flutuante | Seletor de widgets |
| --- | --- |
| ![Menu flutuante do Switch Turbo Boost](Images/00.png) | ![Switch Turbo Boost no seletor de widgets](Images/01.png) |

| Preferencias | Sobre |
| --- | --- |
| ![Preferencias do Switch Turbo Boost](Images/02.png) | ![Pagina Sobre do Switch Turbo Boost](Images/03.png) |

| Atalhos de teclado |
| --- |
| ![Atalhos de teclado do Switch Turbo Boost](Images/04.png) |

As capturas do projeto estao em `Images/`. Elas nao fazem parte do pacote instalavel do plasmoide; sao incluidas para a documentacao do repositorio.

## Instalacao

Para um guia passo a passo, consulte `INSTALL.pt.md`.

### Instalador

Use `install.sh` como entrada unica de instalacao:

| Script | O que faz | Quando usar |
| --- | --- | --- |
| `install.sh` | Instalador principal com opcoes para instalacao completa, apenas plasmoide ou apenas backend. | Recomendado para usuarios finais. |
| `uninstall.sh` | Remove o plasmoide local, os helpers do sistema e a politica PolicyKit. | Para desinstalar completamente o projeto. |
| `build-plasmoid.sh` | Gera `switch-turbo-boost.plasmoid` a partir de `package/`. | Apenas para instalacao visual a partir de arquivo local. |

### Referencia de comandos

| Comando | O que faz |
| --- | --- |
| `chmod +x install.sh` | Da permissao de execucao ao instalador principal. |
| `./install.sh --help` | Mostra todas as opcoes do instalador. |
| `./install.sh` | Executa a instalacao completa padrao. |
| `./install.sh --full --language pt` | Instala a interface do plasmoide e o backend privilegiado, usando portugues como idioma padrao da interface. |
| `./install.sh --plasmoid-only --language es` | Instala apenas a interface local do plasmoide. |
| `./install.sh --backend-only` | Instala apenas os helpers privilegiados e a politica PolicyKit. Util depois de uma instalacao visual `.plasmoid` ou depois de cancelar a autenticacao do backend. |
| `./install.sh --full --reload-plasma` | Instala tudo e recarrega o Plasma Shell depois da instalacao. |
| `./install.sh --no-reload-plasma` | Instala sem perguntar se deve recarregar o Plasma Shell. |
| `chmod +x build-plasmoid.sh && ./build-plasmoid.sh` | Gera `switch-turbo-boost.plasmoid` para instalacao visual pelo KDE Plasma. |
| `chmod +x uninstall.sh` | Da permissao de execucao ao desinstalador. |
| `./uninstall.sh --help` | Mostra todas as opcoes do desinstalador. |
| `./uninstall.sh --language pt --reload-plasma` | Desinstala o plasmoide, helpers e politica, e depois recarrega o Plasma Shell. |

### Baixar pelo Git

```bash
git clone https://github.com/PunchiSoft/switch-turbo-boost-plasmoid.git
cd switch-turbo-boost-plasmoid
```

### Instalacao Visual pelo KDE Plasma

Esta opcao gera um arquivo `.plasmoid` instalavel pela interface grafica do KDE Plasma:

```bash
chmod +x build-plasmoid.sh
./build-plasmoid.sh
```

Depois:

1. Abra o Plasma.
2. Adicione widgets.
3. Instale widget a partir de arquivo local.
4. Selecione `switch-turbo-boost.plasmoid`.

**Aviso:** a instalacao visual instala apenas a interface do plasmoide. Para que o botao ON/OFF funcione com permissoes do sistema, instale tambem o backend:

```bash
chmod +x install.sh
./install.sh --backend-only
```

### Instalacao Completa por Script

Nesta pasta:

```bash
chmod +x install.sh
./install.sh
```

Durante a instalacao do plasmoide, voce pode escolher o idioma da interface. Tambem pode indicar explicitamente:

```bash
./install.sh --language pt
./install.sh --language es
./install.sh --language en
./install.sh --language auto
```

O instalador tambem permite escolher qual parte instalar:

```bash
./install.sh --full --language pt
./install.sh --plasmoid-only --language es
./install.sh --backend-only
```

Para recarregar o Plasma Shell automaticamente depois de instalar ou atualizar a interface, adicione:

```bash
./install.sh --full --language pt --reload-plasma
./install.sh --plasmoid-only --reload-plasma
```

`install.sh` instala diretamente a partir de `package/`; ele nao gera `switch-turbo-boost.plasmoid`. Use `build-plasmoid.sh` apenas para a instalacao visual a partir de arquivo local.

O instalador copia o pacote QML para:

```text
~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/
```

Tambem instala, via `pkexec`, os helpers em:

```text
/usr/local/libexec/switch-turbo-boost-plasmoid/
```

e a politica PolicyKit em:

```text
/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy
```

Ao iniciar, `install.sh` avisa quando o modo selecionado inclui o backend privilegiado e explica que o PolicyKit solicitara a senha de administrador. Se a autenticacao for cancelada durante uma instalacao completa, a interface local do plasmoide pode ficar instalada, mas o botao ON/OFF nao funcionara ate instalar o backend:

```bash
./install.sh --backend-only
```

Depois adicione **Switch Turbo Boost** ao painel pelo seletor de widgets do Plasma.

## Recarregar Plasma Shell

Depois de instalar ou atualizar o plasmoide, talvez seja necessario recarregar o Plasma Shell para que o KDE detecte as mudancas.

Em um terminal interativo, o instalador pergunta no final se voce deseja recarregar o Plasma Shell. Voce pode forcar isso com `--reload-plasma` ou evitar a pergunta com `--no-reload-plasma`; internamente ele tenta usar `kquitapp6` com `kstart6` ou `kstart`, e usa `plasmashell --replace` como alternativa quando necessario.

```bash
kquitapp6 plasmashell
kstart plasmashell
```

Se `kstart` nao estiver disponivel:

```bash
kquitapp6 plasmashell
nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
```

## Testes Manuais

Consultar estado:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Ativar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-on.sh
```

Desativar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-off.sh
```

## Seguranca

O QML nao escreve diretamente em `/sys` nem executa `sudo`. As acoes de mudanca chamam `pkexec` sobre scripts instalados em um caminho fixo sob `/usr/local/libexec`. O PolicyKit limita a autorizacao a esses executaveis especificos.

A leitura do estado nao requer privilegios. A escrita requer autenticacao administrativa porque modifica controles do kernel.

## Desinstalacao

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Tambem e possivel escolher o idioma das mensagens e pedir que o script recarregue o Plasma Shell depois de remover o widget:

```bash
./uninstall.sh --language pt --reload-plasma
./uninstall.sh --help
```

Durante a limpeza do sistema, o PolicyKit solicitara autenticacao de administrador antes de remover os helpers e a politica.
Se a autenticacao for cancelada, a interface local do plasmoide pode ja ter sido removida, mas os helpers do sistema e a politica PolicyKit podem continuar instalados.

## Licenca

Copyright 2026 Punchisoft.

Distribuido sob GPL-3.0-or-later. Consulte `LICENSES/GPL-3.0-or-later.txt`.

Os icones de processador em `package/contents/images/` sao baseados no Papirus Icon Theme da Papirus Development Team:

- Fonte: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
- Licenca: GPL-3.0-only, consulte `LICENSES/GPL-3.0-only.txt` e os arquivos `.license` junto de cada SVG.

## Aviso

Alterar o Turbo Boost pode afetar desempenho, consumo de energia, temperatura e ruido do equipamento. Use este plasmoide apenas se voce entende o efeito esperado no seu hardware.
