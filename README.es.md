<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

[English](README.md) | [Español](README.es.md) | [Português](README.pt.md)

# Switch Turbo Boost Plasmoid

Plasmoide liviano para el entorno de escritorio KDE Plasma 6. Muestra el estado de Turbo Boost en el panel y permite activarlo o desactivarlo con autenticacion de PolicyKit.

Este proyecto es complementario a Switch Turbo Monitor. No reemplaza ni reescribe la aplicacion principal; solo cubre el interruptor de Turbo Boost.

## Caracteristicas

- Interfaz QML para Plasma 6.
- Icono compacto en el panel.
- Menu flotante con estado, descripcion y control ON/OFF.
- Indicador verde cuando Turbo Boost esta ON.
- Indicador gris cuando Turbo Boost esta OFF.
- Iconos locales de procesador basados en Papirus Icon Theme.
- Texto AMD, Intel o CPU detectada segun el procesador.
- Nombre del modelo de CPU debajo del fabricante detectado cuando esta disponible.
- Lectura al cargar, despues de cambiar el estado, cada 15 segundos y desde el boton Refrescar del menu flotante.
- Configuracion de icono del panel, icono del procesador automatico o personalizado, idioma y tamano del menu flotante.
- Apariencia automatica segun el tema de Plasma, con opcion de colores personalizados.
- Scripts externos Bash para consultar y modificar `/sys`.
- Script externo Bash para detectar fabricante de CPU desde `/proc/cpuinfo`.
- Cambios con `pkexec` y politica PolicyKit dedicada.
- No usa `sudo` dentro de QML.

## Compatibilidad

- Entorno de escritorio KDE Plasma 6.
- Sesion Plasma en Wayland o X11.
- Linux con PolicyKit y `pkexec`.
- CPU/kernel con alguno de estos controles:
  - `/sys/devices/system/cpu/cpufreq/boost`
  - `/sys/devices/system/cpu/intel_pstate/no_turbo`

## Capturas

| Menu flotante | Selector de widgets |
| --- | --- |
| ![Menu flotante de Switch Turbo Boost](Images/00.png) | ![Switch Turbo Boost en el selector de widgets](Images/01.png) |

| Preferencias | Acerca de |
| --- | --- |
| ![Preferencias de Switch Turbo Boost](Images/02.png) | ![Pagina Acerca de Switch Turbo Boost](Images/03.png) |

| Atajos de teclado |
| --- |
| ![Atajos de teclado de Switch Turbo Boost](Images/04.png) |

Las capturas del proyecto estan en `Images/`. No forman parte del paquete instalable del plasmoide; se incluyen para documentacion del repositorio.

## Estructura

```text
switch-turbo-boost-plasmoid/
├── package/metadata.json
├── package/contents/config/main.xml
├── package/contents/config/config.qml
├── package/contents/ui/main.qml
├── package/contents/ui/TurboSwitch.qml
├── package/contents/ui/config/ConfigGeneral.qml
├── package/contents/images/
│   ├── kfoldersync.svg
│   ├── turbo-chip.svg
│   ├── vendor-amd.svg
│   ├── vendor-cpu.svg
│   └── vendor-intel.svg
├── Images/
│   ├── 00.png
│   ├── 01.png
│   ├── 02.png
│   ├── 03.png
│   └── 04.png
├── scripts/
│   ├── get-cpu-info.sh
│   ├── get-cpu-vendor.sh
│   ├── get-turbo-status.sh
│   ├── set-turbo-on.sh
│   └── set-turbo-off.sh
├── policykit/
│   └── org.punchisoft.switchturbo.policy
├── LICENSES/
│   └── GPL-3.0-or-later.txt
├── build-plasmoid.sh
├── uninstall.sh
├── INSTALL.md
├── INSTALL.es.md
├── INSTALL.pt.md
├── README.md
├── README.es.md
├── README.pt.md
└── install.sh
```

## Instalacion

Para una guia paso a paso, consulte `INSTALL.es.md`.

### Instalador

Use `install.sh` como entrada unica de instalacion:

| Script | Que hace | Cuando usarlo |
| --- | --- | --- |
| `install.sh` | Instalador principal con opciones para instalacion completa, solo plasmoide o solo backend. | Recomendado para usuarios finales. |
| `uninstall.sh` | Elimina el plasmoide local, los helpers del sistema y la politica PolicyKit. | Para desinstalar completamente el proyecto. |
| `build-plasmoid.sh` | Genera `switch-turbo-boost.plasmoid` desde `package/`. | Solo para instalacion visual desde un archivo local. |

### Referencia de comandos

| Comando | Que hace |
| --- | --- |
| `chmod +x install.sh` | Da permiso de ejecucion al instalador principal. |
| `./install.sh --help` | Muestra todas las opciones del instalador. |
| `./install.sh` | Ejecuta la instalacion completa predeterminada. |
| `./install.sh --full --language es` | Instala la interfaz del plasmoide y el backend privilegiado, usando espanol como idioma predeterminado de la interfaz. |
| `./install.sh --plasmoid-only --language pt` | Instala solo la interfaz local del plasmoide. |
| `./install.sh --backend-only` | Instala solo los helpers privilegiados y la politica PolicyKit. Util despues de una instalacion visual `.plasmoid` o despues de cancelar la autenticacion del backend. |
| `./install.sh --full --reload-plasma` | Instala todo y recarga Plasma Shell despues de instalar. |
| `./install.sh --no-reload-plasma` | Instala sin preguntar si debe recargar Plasma Shell. |
| `chmod +x build-plasmoid.sh && ./build-plasmoid.sh` | Genera `switch-turbo-boost.plasmoid` para instalacion visual desde KDE Plasma. |
| `chmod +x uninstall.sh` | Da permiso de ejecucion al desinstalador. |
| `./uninstall.sh --help` | Muestra todas las opciones del desinstalador. |
| `./uninstall.sh --language es --reload-plasma` | Desinstala el plasmoide, helpers y politica, y luego recarga Plasma Shell. |

### Descargar desde Git

```bash
git clone https://github.com/PunchiSoft/switch-turbo-boost-plasmoid.git
cd switch-turbo-boost-plasmoid
```

### Instalacion visual desde KDE Plasma

Esta opcion genera un archivo `.plasmoid` instalable desde la interfaz grafica de KDE Plasma:

```bash
chmod +x build-plasmoid.sh
./build-plasmoid.sh
```

Luego:

1. Abrir Plasma.
2. Agregar elementos graficos.
3. Instalar elemento grafico desde archivo local.
4. Seleccionar `switch-turbo-boost.plasmoid`.

El archivo `switch-turbo-boost.plasmoid` se genera desde el contenido de `package/`, por lo que `metadata.json` queda en la raiz del paquete y no se incluye la carpeta `package/` dentro del zip.

**Advertencia:** la instalacion visual solo instala la interfaz del plasmoid. Para que el boton ON/OFF funcione con permisos del sistema, instale tambien el backend:

```bash
chmod +x install.sh
./install.sh --backend-only
```

### Instalacion completa por script

Desde esta carpeta:

```bash
chmod +x install.sh
./install.sh
```

Durante la instalacion del plasmoide se puede elegir el idioma de la interfaz. Tambien puede indicarse explicitamente:

```bash
./install.sh --language es
./install.sh --language en
./install.sh --language pt
./install.sh --language auto
```

El instalador tambien permite elegir que parte instalar:

```bash
./install.sh --full --language es
./install.sh --plasmoid-only --language pt
./install.sh --backend-only
```

Para recargar Plasma Shell automaticamente despues de instalar o actualizar la interfaz, agregue:

```bash
./install.sh --full --language es --reload-plasma
./install.sh --plasmoid-only --reload-plasma
```

`install.sh` instala directamente desde `package/`; no genera `switch-turbo-boost.plasmoid`. Use `build-plasmoid.sh` solo para la instalacion visual desde archivo local.

El instalador copia el paquete QML en:

```text
~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/
```

Tambien instala, mediante `pkexec`, los helpers en:

```text
/usr/local/libexec/switch-turbo-boost-plasmoid/
```

y la politica PolicyKit en:

```text
/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy
```

Al iniciar, `install.sh` avisa cuando el modo seleccionado incluye el backend privilegiado y explica que PolicyKit pedira la contrasena de administrador. Si se cancela la autenticacion durante una instalacion completa, la interfaz local del plasmoide puede quedar instalada, pero el boton ON/OFF no funcionara hasta instalar el backend:

```bash
./install.sh --backend-only
```

Despues agregue **Switch Turbo Boost** al panel desde el selector de widgets de Plasma. Si no aparece inmediatamente, consulte la seccion **Recargar Plasma Shell**.

## Recargar Plasma Shell

Despues de instalar o actualizar el plasmoid puede ser necesario recargar Plasma Shell para que KDE detecte cambios en el widget.

En una terminal interactiva, el instalador pregunta al final si desea recargar Plasma Shell. Puede forzarlo con `--reload-plasma` o evitar la pregunta con `--no-reload-plasma`; internamente intenta usar `kquitapp6` con `kstart6` o `kstart`, y si no estan disponibles usa `plasmashell --replace`.

### Opcion 1 - Cerrar sesion e iniciar sesion nuevamente

Cerrar sesion y volver a iniciar sesion es la forma mas segura de recargar completamente Plasma sin depender de comandos de terminal.

Esta opcion es recomendada para usuarios que no quieran usar terminal.

### Opcion 2 - Usar kquitapp6 + kstart

Esta opcion fue probada en Fedora KDE Plasma 6. Reinicia Plasma Shell sin cerrar toda la sesion:

```bash
kquitapp6 plasmashell
kstart plasmashell
```

### Opcion 3 - Usar nohup con plasmashell --replace

Use esta alternativa si `kstart` no esta disponible. `nohup` evita que Plasma quede ligado a la terminal:

```bash
kquitapp6 plasmashell
nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
```

No todos los sistemas KDE incluyen los mismos comandos. Si `kstart` no existe, use la alternativa con `nohup` o cierre sesion.

## Pruebas manuales

Consultar estado:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Activar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-on.sh
```

Desactivar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-off.sh
```

## Seguridad

El QML no escribe directamente en `/sys` ni ejecuta `sudo`. Las acciones de cambio llaman a `pkexec` sobre scripts instalados en una ruta fija bajo `/usr/local/libexec`. PolicyKit limita la autorizacion a esos ejecutables concretos.

La lectura del estado no requiere privilegios. La escritura si requiere autenticacion administrativa porque modifica controles del kernel.

## Desinstalacion

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Tambien puede elegir el idioma de los mensajes y pedir que el script recargue Plasma Shell despues de eliminar el widget:

```bash
./uninstall.sh --language es --reload-plasma
./uninstall.sh --help
```

Durante la limpieza del sistema, PolicyKit solicitara autenticacion de administrador antes de eliminar los helpers y la politica.
Si se cancela la autenticacion, la interfaz local del plasmoide puede quedar eliminada, pero los helpers del sistema y la politica PolicyKit pueden seguir instalados.

## Licencia

Copyright 2026 Punchisoft.

Distribuido bajo GPL-3.0-or-later. Consulte `LICENSES/GPL-3.0-or-later.txt`.

Los iconos de procesador en `package/contents/images/` estan basados en Papirus Icon Theme de Papirus Development Team:

- Fuente: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
- Licencia: GPL-3.0-only, consulte `LICENSES/GPL-3.0-only.txt` y los archivos `.license` junto a cada SVG.

## Advertencia

Cambiar Turbo Boost puede afectar rendimiento, consumo energetico, temperatura y ruido del equipo. Use este plasmoide solo si comprende el efecto esperado en su hardware.
