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
- Los scripts del sistema a `/usr/local/libexec/switch-turbo-boost-plasmoid/`, incluido `get-cpu-vendor.sh`
- La politica PolicyKit a `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`

### 3. Reiniciar Plasma si el widget no aparece

```bash
kquitapp6 plasmashell && kstart6 plasmashell
```

### 4. Agregar el plasmoide al panel

1. Clic derecho sobre el panel de Plasma.
2. Seleccionar **Agregar o administrar widgets**.
3. Buscar **Switch Turbo Boost**.
4. Arrastrarlo al panel.

## Probar funcionamiento

Consultar estado:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Detectar fabricante:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-vendor.sh
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

Si el widget seguia cargado en el panel, reinicie Plasma:

```bash
kquitapp6 plasmashell && kstart6 plasmashell
```
