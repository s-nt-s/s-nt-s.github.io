Title: Instalación desatendida con NOOBS en Raspberry Pi
Date: 2013-10-13 19:15
Category: Sistemas
Tags: NOOBS, Raspberry Pi
Slug: instalacion-desatendida-con-noobs-en-raspberry-pi


**1-** Formatear tarjeta

Para ello podemos instalar gparted

```console
user@bot ~ $ sudo apt-get -y install gparted
...
user@bot ~ $ sudo gparted
```

a.  Elegir en el desplegable de la esquina superior derecha nuestra
    tarjeta
b.  Dispositivo -&gt; Crear tabla de particiones
c.  Partición -Nueva
d.  Seleccionar sistema de ficheros fat32

![gparted]({static}/images/gparted.png)

**2-** Preparar NOOBS

Descomprimimos NOOBS en nuestra SD, entramos en el directorio "os" y
borramos todas las carpetas menos la del sistema opearivo que nos
interesa (por ejemplo "Raspbian").

Entramos en la carpeta que hemos dejado y si hay un fichero llamado
`flavours.json` lo editamos de manera que en él solo quede una opción.

`flavours.json` ANTES:

```json
{
  "flavours": [
    {
      "name": "Raspbian - Boot to Scratch",
      "description": "A version of Raspbian that boots straight into Scratch"
    },
    {
      "name": "Raspbian",
      "description": "A Debian wheezy port, optimised for the Raspberry Pi"
    }  
  ]
}
```

`flavours.json` DESPUES:


```json
{
  "flavours": [
    {
      "name": "Raspbian",
      "description": "A Debian wheezy port, optimised for the Raspberry Pi"
    }  
  ]
}
```

**3-** Arrancamos la Rasberry Pi con la tarjeta

La instalación se hará del tirón sin necesidad de nuestra
interactuación.
