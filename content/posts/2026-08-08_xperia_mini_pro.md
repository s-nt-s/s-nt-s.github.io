Title: Actualizar Sony Ericsson Xperia Mini Pro
Category: Sistemas 
Tags: Android
Status: draft

## Estado inicial

* PC: Linux mint 21.3 xfce
* Movil: Sony Ericsson Xperia Mini Pro
* Número de modelo: SK17i
* Version de Android: 4.0.4
* Versión de Kernel: 2.6.32.9-perf BuildUser@BuildHost #1
* Número de compilación: 4.1.B.0.587
* [Número de etiqueta tras la batería](https://android.scenebeta.com/archivos/android/Captura3TutorialDesbloquearBootloaderXperiaX8X10MiniX10MiniPro.png): 11W44

## Recursos necesarios

* Tarjeta SD (utilizo una SDGC Philips A1 V10 de 32GB)
* Imagen lineage-14.1:
    * [lineage-14.1-20170514-UNOFFICIAL-LegacyXperia-mango.zip](https://mega.nz/folder/bt0VzQDA#6OD6YFjCKYUkX6GRhNOBDg/file/CsEQwSzT) via [mega.nz](https://mega.nz/folder/bt0VzQDA#6OD6YFjCKYUkX6GRhNOBDg/folder/mlcgQD7I)
    * ~~[archive.org -> lineage-14.1-20170514-UNOFFICIAL-LegacyXperia-mango.zip](https://archive.org/download/LegacyXperia_SEMC_2011/lineage-14.1-20170514-UNOFFICIAL-LegacyXperia-mango.zip) via [archive.org](https://archive.org/details/LegacyXperia_SEMC_2011)~~ (no funciona según [xda-developers.com](https://forum.xda-developers.com/t/installing-lineage-os-14-on-xperia-mini-pro.3559424/post-85851293))
* `adb` y `fastboot` (antes `android-tools-adb` y `android-tools-fastboot` según [xda-developers.com](https://forum.xda-developers.com/t/installing-lineage-os-14-on-xperia-mini-pro.3559424/post-80979763))

## Prerrequisitos

### Instalar adb y fastboot

```console
$ sudo apt install adb fastboot
```

### Determinar si va a ser posible todo esto

En el móvil:

1. Activar las opciones de desarrollo:
    * en android 2.3 `Ajustes -> Aplicaciones -> Desarrollo -> Depuración USB`
    * en android 4 o superior:
        * Ir a `Ajustes -> Acerca del teléfono`
        * Pulsar 7 veces sobre `Número de compilación`
        * Activar `Ajustes -> Opciones de desarrollo -> Depuración USB`
2. [Verificar que se puede desbloquear el bootloader](https://developer.sony.com/open-source/aosp-on-xperia-open-devices/get-started/unlock-bootloader/how-to-unlock-bootloader/):
    * Marcar `*#*#7378423#*#*`
    * Ir a `Service info" -> Configuration -> Rooting Status`
    * En `Bootloader unlock allowed` debe poner `Yes` (si no, ver el *anexo 1*)
3. Acceder al bootloader:
    * Encender el móvil
    * Conectarlo al ordenador via usb
    * Ejecutar los siguientes comandos

```console
$ adb devices
* daemon not running; starting now at tcp:5037
* daemon started successfully
List of devices attached
BX902QUGBW    device

$ adb reboot bootloader

$ fastboot devices
BX902QUGBW&ZLP    fastboot
```

Si no funciona el paso 3, el paso 2 dice que el bootlader no es desbloqueable
y no ha habido suerte con *el anexo 1* entonces no hay nada que hacer. Aborta misión.

En caso contrario continuar.

### Formatear SD

```console
# Formatear SD con una única partición en formato ext4
$ sudo umount /dev/mmcblk0*
$ sudo mkfs -t fat -n SK17I /dev/mmcblk0
$ sudo umount /dev/mmcblk0
```

Si más adelante falla, probar con fat32.

## 1. Desbloquear bootloader

1. En el móvil:
    * Marcar `*#*#7378423#*#*`
    * Ir a `Service info" -> Configuration`
    * Anotar el código `IMEI`, ej 358212341608576
2. Ir a [developer.sony.com/open-source/aosp-on-xperia-open-devices/get-started/unlock-bootloader](https://developer.sony.com/open-source/aosp-on-xperia-open-devices/get-started/unlock-bootloader#unlock-code)
3. Seleccionar Xperia Mini Pro
4. Rellenar el campo `IMEI` y pulsar `submit`
5. Copiar el código de desbloqueo, ej: 056B1123J8211D12
6. Conectar el móvil por usb
7. Desde el pc:

```console
# Resetear el móvil en modo bootloader
$ adb devices && adb reboot bootloader && sleep 10 && fastboot devices

# Desbloquear el bootloader (hay que poner 0x seguido del código copiado en el paso 5)
$ fastboot oem unlock 0x056B1123J8211D12
(bootloader) Unlock phone requested
(bootloader) Erasing block 0x00002200
(bootloader) Erasing block 0x00005400
(bootloader) Erasing block 0x00007600
(bootloader) Erasing block 0x00002300
(bootloader) Erasing block 0x00004300
(bootloader) Erasing block 0x00002300
(bootloader) Erasing block 0x00007800
(bootloader) Erasing block 0x00002300
(bootloader) Erasing block 0x00003400
(bootloader) Erasing block 0x00005400
(bootloader) Erasing block 0x00006400
(bootloader) Erasing block 0x00007600
(bootloader) Erasing block 0x00008600
OKAY [  3.982s]
Finished. Total time: 3.982s
```

## 2. Flashear el móvil

```console
# Descomprimir lineage-*.zip (en el pc, no en la sd)
$ unzip lineage-14.1-20170514-UNOFFICIAL-LegacyXperia-mango.zip
$ cd lineage-14.1-20170514-UNOFFICIAL-LegacyXperia-mango

# Conectar el móvil por usb y resetearlo en modo bootloader (se pondrá el led en azul)
$ adb devices && adb reboot bootloader && sleep 10 && fastboot devices

# Alternativa:
# 1. apagar totalmente el móvil
# 2. Conectar el cable usb al móvil
# 3. Mantener pulsado el botón de subir volumen
# 4. Conectar el cable usb al pc

# Flashear boot.img
$ fastboot flash boot boot.img
Sending 'boot' (7424 KB) (bootloader) USB download speed was 3801088kB/s
OKAY [  0.838s]
Writing 'boot'           (bootloader) Download buffer format: boot IMG
(bootloader) Flash of partition 'boot' requested
(bootloader) S1 partID 0x00000003, block 0x00000280-0x000002e3
(bootloader) Erase operation complete, 0 bad blocks encountered
(bootloader) Flashing...
(bootloader) Flash operation complete
OKAY [  1.447s]
Finished. Total time: 2.302s

# Reiniciar el móvil
$ fastboot reboot
Rebooting                                          OKAY [  0.001s]
Finished. Total time: 0.051s
```

Cuando aparezca el logo de `Sony Xperia` pulsar la tecla de bajar volumen
para entrar en `Recovery mode` y seguir estos pasos:

1. Seleccionar `Wipe / Limpiar`
2. Pulsar en `Format Data` y responder `yes`
3. Volver a la pantalla anterior
4. Deslizar para accionar
5. Volver atrás y entrar en `Advance Wipe / Limpieza avanzada`
6. Seleccionar `System / Sistema`
7. Deslizar para accionar
8. Conectar por usb
9. Volver a la pantalla inicial
10. Entrar en `Advanced / Avanzado -> ADB Sideload / Carga archivo por ADB`
11. Deslizar para accionar
12. Desde el pc:

```
# Instalar la rom
$ adb sideload lineage-14.1-20170514-UNOFFICIAL-LegacyXperia-mango.zip
```

13. Pulsar en `Reboot / Reiniciar` ignorando cualquier `warning`

## 3. Configuración inicial

1. Seleccionar Español de España
2. Empecemos
3. Insertar SIM card: Saltar
5. Configurar wifi
9. Aceptar
10. Ir a `Ajustes -> Información del teléfono`
11. Pulsar 7 veces sobre `Número de compilación`
12. Activar `Ajustes -> Opciones de desarrollo -> Depuración USB`
13. Activar:
    * Pantalla activa
    * Acceso administrativo: Aplicaciones y ADB
    * Depuración en android

## 4. Configuración

```
# Poner un fondo de pantalla negro
convert -size 1x1 xc:black black_pixel.png
adb push black_pixel.png /sdcard/
adb shell am start -a android.intent.action.ATTACH_DATA -c android.intent.category.DEFAULT -d "file:///sdcard/black_pixel.png" -t "image/*" -e mimeType "image/*"

# Nombre dispositivo
adb shell settings put global device_name sk17i

# Orientación escritorio
adb shell settings put secure user_rotation 0

# Quitar la notificación de depuración usb
adb shell settings put global adb_notify 0

# Permitir orígenes desconocidos para instalar apps
adb shell settings put secure install_non_market_apps 1

# Quitar animaciones
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb shell settings put system transition_animation_scale 0
adb shell settings put system window_animation_scale 0

# Mejorar rendimiento
adb shell settings put global always_finish_activities 0
adb shell settings put global limit_background_processes 0
adb shell settings put global heads_up_notifications_enabled 0
adb shell settings put system screensaver_enabled 0
adb shell settings put system screen_brightness_mode 0

# Mantener encendido cuando esta enchufado
adb shell settings put global stay_on_while_plugged_in 3

# Tiempo hasta apagar pantalla
adb shell settings put system screen_off_timeout 120000

# Quitar vibración y sonido al pulsar botones
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put secure vibrate_on 0
adb shell settings put secure virtual_keyboard_vibrate 0

# Desactivar el escaneo Wi-Fi permanente
adb shell settings put global wifi_scan_always_enabled 0

# Desactivar el escaneo Bluetooth
adb shell settings put global ble_scan_always_enabled 0

# Reducir el registro (logcat)
adb shell logcat -G 256K

# Dejar solo un escritorio
adb shell
su
sqlite3 /data/user/0/com.cyanogenmod.trebuchet/databases/launcher.db

DELETE FROM favorites;
DELETE FROM workspaceScreens WHERE _id != 0;
VACUUM;
.quit

am force-stop com.cyanogenmod.trebuchet
```

## 5. Instalar Aplicaciones básicas

```
sudo apt install fdroidcl
fdroidcl update
fdroidcl install \
    net.osmand.plus \
    eu.siacs.conversations \
    org.schabi.newpipe \
    at.bitfire.davdroid \
    com.cookiegames.smartcookie \
    com.termoneplus \
    fr.neamar.kiss \
    ws.xsoh.etar \
    com.fsck.k9 \
    net.gsantner.markor \
    org.koreader.launcher.fdroid \
    de.markusfisch.android.binaryeye \
    com.kunzisoft.keepass.libre

# https://github.com/AdAway/AdAway/releases/tag/v4.3.6
wget -q https://github.com/AdAway/AdAway/releases/download/v4.3.6/AdAway-4.3.6-200726.apk
adb install AdAway-4.3.6-200726.apk

# https://github.com/equeim/tremotesf-android/releases/tag/2.10.2
wget -q https://github.com/equeim/tremotesf-android/releases/download/2.10.2/app-fdroid-release.apk
adb install app-fdroid-release.apk

# https://github.com/spacecowboy/Feeder/releases/tag/2.10.2
wget -q https://github.com/spacecowboy/Feeder/releases/download/2.10.2/app-fdroid-release.apk
adb install app-fdroid-release.apk

# https://github.com/s-nt-s/vx-connectbot/releases/tag/1.8.0-30
wget -q "https://github.com/s-nt-s/vx-connectbot/releases/download/1.8.0-30/VX-ConnectBot-1.8.0.apk"
adb install VX-ConnectBot-1.8.0.apk
```

## 6. Deshabilitar aplicaciones

```
adb shell pm uninstall --user 0 org.legacyxperia.center
adb shell pm uninstall --user 0 org.cyanogenmod.audiofx
adb shell pm uninstall --user 0 org.cyanogenmod.cmaudio.service
adb shell pm uninstall --user 0 com.android.dreams.basic
adb shell pm uninstall --user 0 com.android.dreams.phototable
adb shell pm uninstall --user 0 com.android.printspooler
adb shell pm uninstall --user 0 com.android.printservice.recommendation
adb shell pm uninstall --user 0 org.cyanogenmod.weatherservice
adb shell pm uninstall --user 0 org.cyanogenmod.weather.provider
adb shell pm uninstall --user 0 com.cyanogenmod.lockclock
adb shell pm uninstall --user 0 com.cyanogenmod.setupwizard
adb shell pm uninstall --user 0 com.android.cts.ctsshim
adb shell pm uninstall --user 0 com.android.cts.priv.ctsshim
adb shell pm uninstall --user 0 com.android.egg
adb shell pm uninstall --user 0 com.android.bookmarkprovider
adb shell pm uninstall --user 0 com.android.htmlviewer
adb shell pm uninstall --user 0 com.android.onetimeinitializer
adb shell pm uninstall --user 0 com.cyanogenmod.trebuchet
adb shell pm uninstall --user 0 com.android.calendar
adb shell pm uninstall --user 0 com.android.email

# Finalmente no se elimina porque para conseguir
# autorización oauth funciona mejor que Smart Cookie Web
# adb shell pm uninstall --user 0 org.lineageos.jelly
```

## Anexos

### Anexo 1: ¿Qué hacer si el bootloader no es desbloqueable?

Si el valor de [`Bootloader unlock allowed`](https://developer.sony.com/open-source/aosp-on-xperia-open-devices/get-started/unlock-bootloader/how-to-unlock-bootloader/) 
es distinto de `Yes`:

1. Instala omnius via [Omnius_for_SE.zip](https://omnius-server.com/Omnius/Omnius_for_SE.zip)
2. Pide una licencia en [kaijousuru discord](https://kaijousuru.com/discord)
3. Ve a la carpeta donde se ha instalado omnius he instala los drives que necesites
4. Sigue los pasos del [tutorial 3 de htcmania](https://www.htcmania.com/showthread.php?t=323099)

### Anexo 2: Rootear móvil

Si no hemos podido flashear el móvil, podemos rootearlo como premio de consolación:

1. [Descargar errot](https://www.eroot.net/) para pc
2. Conectar móvil por usb
3. Arrancar eroot con wine
4. Pulsar root y esperar

Cuando haya terminado el móvil tendrá una nueva aplicación
llamada `Superusuario`

### Anexo 3: ¿Y las GApps?

El mero hecho de instalar los servicios de Google minimos provoca
tal consumo de recursos que convierte el telefono en practicamente
inusable. No recomiendo en absoluto hacerlo.

Aún así, si quieres hacerlo tienes que tener en cuenta que el móvil
no tiene espacio ni siquiera para la versión `opengapps 7.1-pico`
y además necesitaras remplazar el teclado por defecto `Android Keyboard (AOSP)` porque no funciona correctamente
(ver [bug](https://android-review.googlesource.com/c/platform/packages/inputmethods/LatinIME/+/469478) y [stackoverflow](https://stackoverflow.com/a/45905581)), por lo tanto
tendras que modificar `open_gapps-arm-7.1-pico-20220215.zip` de la siguiente manera:

1. Descarga `open_gapps-arm-7.1-pico-20220215.zip` de [opengapps](https://opengapps.org/)
2. Descarga `open_gapps-arm-7.1-stock-20220215.zip` de [opengapps](https://opengapps.org/)
3. Descomprime ambos zips
4. Copia `open_gapps-arm-7.1-stock-20220215/GApps/keyboardgoogle-arm.tar.lz` a `open_gapps-arm-7.1-pico-20220215/GApps/`
5. En `open_gapps-arm-7.1-pico-20220215/app_densities.txt` añade la linea `GApps/keyboardgoogle-arm/nodpi/`
6. En `open_gapps-arm-7.1-pico-20220215/app_sizes.txt` añade la linea `keyboardgoogle-arm    nodpi    61292`
7. En `open_gapps-arm-7.1-pico-20220215/installer.sh` añade las siguientes lineas al inicio:

```
cat <<EOT >> /data/gapps-config.txt
Include

CalSync                 # Install Google Calendar Sync (if Google Calendar is being installed)
DialerFramework         # Install Dialer Framework (Android 6.0+)
PackageInstallerGoogle  # Install Package Installer (Android 6.0 only & Android 8.0+)
KeyboardGoogle          # Necesario porque Android Keyboard (AOSP) no funciona

(LegacyXperiaCenter)
CMAccount               # Remove CM Account
CMAudioFX               # Remove CM AudioFX
CMMusic                 # Remove CM Music
CMBugReport             # Remove CM Bug Report
CMSetupWizard           # Remove CM Setup Wizard (see Notes for CMSetupWizard)
CMUpdater               # Remove CM Updater
CMWallpapers            # Remove CM Wallpapers
CMWeatherProvider       # Remove CM Weather Underground
DashClock               # Remove DashClock Widget (found in certain ROMs)
Hexo                    # Remove Hexo Libre CM Theme
LRecorder               # Remove LineageOS Recorder
LSetupWizard            # Remove LineageOS Setup Wizard
LUpdater                # Remove LineageOS Updater
LiveWallpapers          # Remove Stock Live Wallpapers
Studio                  # Remove Stock Movie Studio
(Gello)                 # CM WebBrowser
(BasicDreams)           # Basic Dreams Wallpaper
(Galaxy)                # Galaxy (also known as BlackHole) Wallpaper
(Hexo)                  # Hexo Libre Theme
(HoloSpiral)            # Holo Spiral Wallpaper
(NoiseField)            # Noise Field Wallpaper
(Phasebeam)             # Phasebeam Wallpaper
(PhotoPhase)            # Photo Phase Wallpaper
(PhotoTable)            # Photo Table Wallpaper
(LiveWallpapers)        # Stock Live Wallpapers
EOT
```

y comprime el resultado en un nuevo zip.

Luego en el paso *2. Flashear el móvil" antes de pulsar en `Reboot / Reiniciar`
tienes que volver a `Advanced / Avanzado -> ADB Sideload / Carga archivo por ADB`
y hacer:

```
# Instalar opengapps (modificadas)
$ adb sideload open_gapps-arm-7.1-pico-20220215.zip
```