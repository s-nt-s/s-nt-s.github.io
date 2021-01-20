Title: Actualizar gedit en Linux Mint 17 para programar
Date: 2014-09-11 10:27
Category: Escritorio
Tags: Linux
Slug: actualizar-gedit-en-linux-mint-17-para-programar

**Problema**: Queremos usar los plugins de gedit pero nuestro Linux Mint
viene con una versión anterior de gedit que es incompatible con los
plugins del repositorio

```console
mint@bot ~ $ sudo apt-get install gedit-plugins
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias
Leyendo la información de estado... Hecho
No se pudieron instalar algunos paquetes. Esto puede significar que
usted pidió una situación imposible o, si está usando la distribución
inestable, que algunos paquetes necesarios no han sido creados o han
sido movidos fuera de Incoming.
La siguiente información puede ayudar a resolver la situación:
Los siguientes paquetes tienen dependencias incumplidas:
gedit-plugins : Depende: libgucharmap7 (>= 1:2.24.0) pero no es instalable
E: No se pudieron corregir los problemas, usted ha retenido paquetes rotos.
```

**Solución**: Actualizar gedit

**1**- Eliminamos el antiguo gedit e instalamos el nuevo

```console
mint@bot ~ $ sudo apt purge gedit gedit-common
...
Los siguientes paquetes se ELIMINARÁN:
gedit* gedit-common*
...
mint@bot ~ $ sudo apt install gedit/trusty gedit-common/trusty
...
Versión seleccionada «3.10.4-0ubuntu4» (Ubuntu:14.04/trusty [amd64]) para «gedit»
Versión seleccionada «3.10.4-0ubuntu4» (Ubuntu:14.04/trusty [all]) para «gedit-common»
Paquetes sugeridos:
gedit-plugins
Se instalarán los siguientes paquetes NUEVOS:
gedit gedit-common
0 actualizados, 2 se instalarán, 0 para eliminar y 1 no actualizados.
...
```

**2**- Instalar plugins

```console
mint@bot ~ $ sudo apt install gedit-plugins/trusty
...
Versión seleccionada «3.10.1-1ubuntu2» (Ubuntu:14.04/trusty [amd64]) para «gedit-plugins»
Se instalarán los siguientes paquetes extras:
gir1.2-gucharmap-2.90 gir1.2-zeitgeist-2.0
Paquetes sugeridos:
zeitgeist-datahub
Se instalarán los siguientes paquetes NUEVOS:
gedit-plugins gir1.2-gucharmap-2.90 gir1.2-zeitgeist-2.0
0 actualizados, 3 se instalarán, 0 para eliminar y 1 no actualizados.
...
```

**3-** Instalar Gmate

```console
mint@bot ~ $ sudo apt-add-repository ppa:ubuntu-on-rails/ppa
...
mint@bot ~ $ sudo apt-get update
...
mint@bot ~ $ sudo apt-get install gedit-gmate
...
Se instalarán los siguientes paquetes NUEVOS:
gedit-gmate
0 actualizados, 1 se instalarán, 0 para eliminar y 1 no actualizados.
...
```

**4-** Configurar gedit

Editar -&gt; Preferencias -&gt; Ver:

-   Mostrar los número de línea
-   Resaltar la línea actual
-   Resaltar parejas de corchetes

Editar -&gt; Preferencias -&gt; Editor:

-   Anchura del tabular: 4
-   Activar sangría automática

Editar -&gt; Preferencias -&gt; Tipografías y colores:

-   Monokai

Editar -&gt; Preferencias -&gt; Complementos:

-   Buscar/Remplazar avanzado
-   Cambiar capitalización
-   Completar paréntesis
-   Find in Files
-   Panel del examinador de archivos
-   Recortes
-   Smart Highlighting
-   Snap Open
-   Tamaño del texto
-   White Space Terminator
-   Zen Coding

Fuentes:
[forums.linuxmint.com,](http://forums.linuxmint.com/viewtopic.php?f=47&t=168938)
[blog.desdelinux.net](http://blog.desdelinux.net/gedit-para-programadores/)
y
[blog.jorgeivanmeza.com](http://blog.jorgeivanmeza.com/2012/03/instalacion-de-gmate-para-gedit-en-gnulinux-ubuntu/)
