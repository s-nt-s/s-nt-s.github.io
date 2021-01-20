Title: Elipsis en los textos del escritorio Cinnamon 1.8
Date: 2013-10-03 19:17
Category: Escritorio
Tags: Cinnamon, Linux
Slug: elipsis-en-los-textos-del-escritorio-cinnamon

**Problema**: El nombre de los ficheros ubicados en el escritorio sale
completo (ocupando varias lineas cuando es necesario) y queremos que
nunca sobrepase más de una linea, es decir, que abrevie los nombres y
solo los muestre completos cuando seleccionas el archivo en cuestión.

**Solución**: Redefinir la elipsis a un máximo de una linea.

1.  Instalar dconf-tools
2.  Ejecutar dconf-editor

```console
user@bot ~ $ sudo apt-get install dconf-tools
... ... ... ...
user@bot ~ $ dconf-editor
```

3.  org -&gt; nemo -&gt; desktop: text-ellipsis-limit: 1

![deconf]({static}/images/deconf.png)

4.  Reiniciar
