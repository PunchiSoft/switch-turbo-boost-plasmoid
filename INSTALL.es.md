<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

[English](INSTALL.md) | [Español](INSTALL.es.md) | [Português](INSTALL.pt.md)

# Instalacion de Switch Turbo Boost Plasmoid

Guia rapida para instalar el plasmoide en el entorno de escritorio KDE Plasma 6.

## 1. Descargar el proyecto

Desde Git:

```bash
git clone https://github.com/PunchiSoft/switch-turbo-boost-plasmoid.git
cd switch-turbo-boost-plasmoid
```

Si ya tiene el codigo descargado localmente:

```bash
cd switch-turbo-boost-plasmoid
```

## Que hace cada script

| Script | Que instala o elimina | Uso recomendado |
| --- | --- | --- |
| `install.sh` | Instalador principal. Puede instalar todo, solo el plasmoide o solo el backend. | Uso recomendado para usuarios finales. |
| `uninstall.sh` | Elimina el plasmoide local, los helpers del sistema y la politica PolicyKit. | Use este script para desinstalar completamente el proyecto. |
| `build-plasmoid.sh` | Genera `switch-turbo-boost.plasmoid`. | Use este script solo para instalacion visual desde archivo local. |

## Instalacion visual desde KDE Plasma

Esta opcion instala solo la interfaz del plasmoid desde un archivo local.

### 1. Generar el archivo .plasmoid

```bash
chmod +x build-plasmoid.sh
./build-plasmoid.sh
```

Esto crea `switch-turbo-boost.plasmoid` desde la carpeta `package/`. El archivo contiene `metadata.json` en la raiz del paquete y no incluye la carpeta `package/` dentro del zip.

### 2. Instalar desde Plasma

1. Abrir Plasma.
2. Agregar elementos graficos.
3. Instalar elemento grafico desde archivo local.
4. Seleccionar `switch-turbo-boost.plasmoid`.

**Advertencia:** la instalacion visual solo instala la interfaz del plasmoid. Para que el boton ON/OFF funcione con permisos del sistema, ejecute tambien:

```bash
chmod +x install.sh
./install.sh --backend-only
```

Al iniciar, el instalador avisa cuando el modo seleccionado incluye el backend privilegiado. Durante ese paso de backend se solicitara autenticacion de administrador mediante PolicyKit.

Si se cancela la autenticacion durante una instalacion completa, la interfaz local del plasmoide puede quedar instalada, pero el boton ON/OFF no funcionara hasta instalar el backend con `./install.sh --backend-only`.

## Instalacion completa por script

### 1. Dar permisos de ejecucion

```bash
chmod +x install.sh
```

### 2. Ejecutar el instalador

```bash
./install.sh
```

Durante la instalacion del plasmoide se puede elegir el idioma de la interfaz. Tambien puede indicarse explicitamente:

```bash
./install.sh --language es
./install.sh --language en
./install.sh --language pt
./install.sh --language auto
```

Tambien puede elegir que parte instalar:

```bash
./install.sh --full --language es
./install.sh --plasmoid-only --language pt
./install.sh --backend-only
./install.sh --mode backend
```

Para recargar Plasma Shell automaticamente despues de instalar o actualizar la interfaz:

```bash
./install.sh --full --language es --reload-plasma
./install.sh --plasmoid-only --reload-plasma
```

Durante este paso se solicitara autenticacion de administrador mediante PolicyKit.

`install.sh` instala directamente desde la carpeta `package/`; no genera el archivo `switch-turbo-boost.plasmoid`. Use `build-plasmoid.sh` solo cuando quiera instalar desde un archivo local mediante la interfaz grafica de Plasma.

El instalador copia:

- El plasmoide a `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`
- Los scripts del sistema a `/usr/local/libexec/switch-turbo-boost-plasmoid/`, incluidos `get-cpu-info.sh` y `get-cpu-vendor.sh`
- La politica PolicyKit a `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`

### 3. Recargar Plasma Shell

Despues de instalar o actualizar el plasmoid puede ser necesario recargar Plasma Shell para que KDE detecte cambios en el widget.

En una terminal interactiva, el instalador pregunta al final si desea recargar Plasma Shell. Puede forzarlo con `--reload-plasma` o evitar la pregunta con `--no-reload-plasma`; internamente intenta usar `kquitapp6` con `kstart6` o `kstart`, y si no estan disponibles usa `plasmashell --replace`.

#### Opcion 1 - Cerrar sesion e iniciar sesion nuevamente

Cerrar sesion y volver a iniciar sesion es la forma mas segura de recargar completamente Plasma sin depender de comandos de terminal.

Esta opcion es recomendada para usuarios que no quieran usar terminal.

#### Opcion 2 - Usar kquitapp6 + kstart

Esta opcion fue probada en Fedora KDE Plasma 6. Reinicia Plasma Shell sin cerrar toda la sesion:

```bash
kquitapp6 plasmashell
kstart plasmashell
```

#### Opcion 3 - Usar nohup con plasmashell --replace

Use esta alternativa si `kstart` no esta disponible. `nohup` evita que Plasma quede ligado a la terminal:

```bash
kquitapp6 plasmashell
nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
```

No todos los sistemas KDE incluyen los mismos comandos. Si `kstart` no existe, use la alternativa con `nohup` o cierre sesion.

### 4. Agregar el plasmoide al panel

1. Clic derecho sobre el panel de Plasma.
2. Seleccionar **Agregar o administrar widgets**.
3. Buscar **Switch Turbo Boost**.
4. Arrastrarlo al panel.

## Configuracion

Desde la configuracion del plasmoide se puede ajustar:

- Icono mostrado en el panel.
- Icono del procesador mostrado en el menu flotante, con opciones automaticas, AMD, Intel, CPU, chip o un icono personalizado del sistema.
- Idioma de la interfaz.
- Apariencia del menu flotante: tema automatico y colores personalizados.
- Ancho y alto preferidos del menu flotante.

## Probar funcionamiento

Consultar estado:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Detectar fabricante:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-vendor.sh
```

Detectar fabricante y modelo:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-info.sh
```

Activar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-on.sh
```

Desactivar Turbo Boost:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-off.sh
```

## Desinstalacion

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Idioma y recarga de Plasma opcionales:

```bash
./uninstall.sh --language es --reload-plasma
./uninstall.sh --help
```

Durante la limpieza del sistema, PolicyKit solicitara autenticacion de administrador antes de eliminar los helpers y la politica.
Si se cancela la autenticacion, la interfaz local del plasmoide puede quedar eliminada, pero los helpers del sistema y la politica PolicyKit pueden seguir instalados.
