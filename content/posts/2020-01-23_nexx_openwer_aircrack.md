Title: Usar aircrack en NEXX con OpenWrt
Category: Sistemas
Status: draft

**1-** Base

* Router usado: [`NEXX WT3020`](https://wikidevi.com/wiki/Nexx_WT3020)
* Instalación de OpenWrt: [OpenWrt](https://openwrt.org/toh/nexx/wt3020)

**2-** Instalación paquetes necesarios

```console
$ ssh root@192.168.8.1
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install aircrack-ng airmon-ng kmod-usb-storage kmod-fs-ext4 kmod-usb-storage-extras block-mount kmod-scsi-core screen reaver
```
Esto instala `aircrack`, `reaver`, los paquetes para montar memorias usb y la utilidad `screen`.

Hoy por hoy, `reaver` y sobre todo su utilidad `wash` no funciona con la
librería `libpcap` que trae `OpenWrt` (la `1.9.1-1` en el momento de escribir esto),
por ello puede hacer falta hacerla un downgrade:

```console
$ cd /tmp
/tmp $ wget http://www.revolucionsocial.com/wp-content/uploads/2017/02/libpcap_1.3.0-1_ramips_24kec.ipk_.zip
/tmp $ unzip libpcap_1.3.0-1_ramips_24kec.ipk_.zip
/tmp $ scp ./libpcap_1.3.0-1_ramips_24kec.ipk root@192.168.8.1:/tmp/
/tmp $ ssh root@192.168.8.1
root@OpenWrt:~# opkg remove libpcap --force-depends
root@OpenWrt:~# opkg install /tmp/libpcap_1.3.0-1_ramips_24kec.ipk --force-downgrade
```


**3-** Montar usb

Algunos tutoriales hace directamente [`extroot`](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)
(mover el `root-fs` al usb),
pero como con el espacio interno de `NEXX` hemos conseguido instalar
todo lo que queríamos (aunque por los pelos) nosotros solo usaremos
el pendrive para dar más memoria en forma de `swap` y más espacio
para guardar los paquetes capturados por `aircrack`.

Para ello habremos particionado previamente nuestro pendrive
en dos particiones `ext4`.

```console
root@OpenWrt:~# mkdir /mnt/usb
root@OpenWrt:~# touch /mnt/usb/NO_MOUNT
root@OpenWrt:~# mkswap /dev/sda1
root@OpenWrt:~# swapon /dev/sda1
root@OpenWrt:~# mount -t ext4 /dev/sda2 /mnt/usb -o rw,async
```

**4-** Poner interfaz en mono monitor

```console
root@OpenWrt:~# iw phy phy0 interface add mon0 type monitor
root@OpenWrt:~# ifconfig mon0 up
```

**5-** Capturar paquetes

```console
root@OpenWrt:~# screen
root@OpenWrt:~# airodump-ng --ivs --write capture --beacons mon0
^Ctrl+A+D
root@OpenWrt:~# exit
```

`screen` se usa para poder abandonar el terminal sin peder el trabajo en curso.

**6-** Recoger los datos

```console
$ ssh root@192.168.8.1
root@OpenWrt:~# screen -ls
There is a screen on:
	1614.pts-0.OpenWrt	(Detached)
1 Socket in /tmp/screens/S-root.
root@OpenWrt:~# screen -r 1614
^Ctrl+C
root@OpenWrt:~# exit
root@OpenWrt:~# swapoff /dev/sda1
root@OpenWrt:~# umount /mnt/usb
root@OpenWrt:~# exit
```

Sacamos el pendrive y nos lo llevamos a un ordenador más potente donde analizar
los datos

**7-** Analizar los datos

```console
$ aircrack-ng capture-01.ivs
```

<hr/>

**Fuentes**: [openwrt.org - usb.storage](https://openwrt.org/es/doc/howto/usb.storage),
[openwrt.org - aircrack-ng](https://openwrt.org/docs/guide-user/network/wifi/wireless-tool/aircrack-ng), [linuxize.com - screen](https://linuxize.com/post/how-to-use-linux-screen/), [www.revolucionsocial.com](http://www.revolucionsocial.com/reaver-wps-fork-t6x-en-amper-26555-con-openwrt/)
