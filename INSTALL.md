<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

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
| `install-plasmoid.sh` | Copia solo la interfaz del plasmoide desde `package/` a `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`. | Use este script despues de cambiar QML, iconos, idioma, textos, configuracion o `metadata.json`. |
| `install-backend.sh` | Copia los helpers de `scripts/` a `/usr/local/libexec/switch-turbo-boost-plasmoid/` e instala la politica PolicyKit en `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`. | Use este script despues de cambiar los helpers Bash o la politica PolicyKit. Solicita permisos con `pkexec`. |
| `install.sh` | Ejecuta primero `install-plasmoid.sh` y luego `install-backend.sh`. | Use este script para una instalacion completa o cuando quiera actualizar todo de una vez. |
| `uninstall.sh` | Elimina el plasmoide local, los helpers del sistema y la politica PolicyKit. | Use este script para desinstalar completamente el proyecto. |

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
chmod +x install-backend.sh scripts/*.sh
./install-backend.sh
```

Durante este paso se solicitara autenticacion de administrador mediante PolicyKit.

## Instalacion completa por script

### 1. Dar permisos de ejecucion

```bash
chmod +x install.sh install-plasmoid.sh install-backend.sh scripts/*.sh
```

### 2. Ejecutar el instalador

```bash
./install.sh
```

Durante este paso se solicitara autenticacion de administrador mediante PolicyKit.

El instalador copia:

- El plasmoide a `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`
- Los scripts del sistema a `/usr/local/libexec/switch-turbo-boost-plasmoid/`, incluidos `get-cpu-info.sh` y `get-cpu-vendor.sh`
- La politica PolicyKit a `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`

### 3. Recargar Plasma Shell

Despues de instalar o actualizar el plasmoid puede ser necesario recargar Plasma Shell para que KDE detecte cambios en el widget.

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

Si el widget seguia cargado en el panel, consulte la seccion **Recargar Plasma Shell**.
