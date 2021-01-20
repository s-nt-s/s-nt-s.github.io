Title: Predeterminar VLC como reproductor en Linux Mint 15
Date: 2013-10-03 20:00
Category: Escritorio
Tags: Linux
Slug: predeterminar-vlc-como-reproductor-en-linux-mint-15

**Problema**: "System Settings -&gt; Applications & Removable Media" no
funciona

![appdef]({static}/images/appdef.png)

**Solución**: Editar /usr/share/applications/defaults.list y repmlazar
"totem" por "vlc"

```console
user@bot ~ $ gksudo gedit /usr/share/applications/defaults.list
```

Buscar -&gt; Remplazar -&gt; Remplazar todo

![default]({static}/images/default.png)
