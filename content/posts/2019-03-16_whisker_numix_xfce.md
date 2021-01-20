Title: Whisker menu en XFCE con Numix
Tags: whisker, xfce, numix, Linux, !css
Category: Escritorio

**Problema**: En `xfce` con el tema `numix` instalado
el menú `whisker` se sigue viendo con colores claros
a diferencia del resto del panel

**Solución**: Depende de si estamos usando `gtk 2` o `gtk 3`.

## Solución para `gtk 2`

Añadir al fichero `~/.gtkrc-2.0` las siguientes lineas:

```
style "whisker-menu-numix-dark-theme"
{
base[NORMAL] = "#2B2B2B"
base[ACTIVE] = "#D64937"
text[NORMAL] = "#ccc"
text[ACTIVE] = "#fff"
bg[NORMAL] = "#2B2B2B"
bg[ACTIVE] = "#D64937"
bg[PRELIGHT] = "#D64937"
fg[NORMAL] = "#ccc"
fg[ACTIVE] = "#fff"
fg[PRELIGHT] = "#fff"
}
widget "whiskermenu-window*" style "whisker-menu-numix-dark-theme"
```

## Solución para `gtk 3`

**Opción a)**: Definir el `tema oscuro` como `tema por defecto` añadiendo al
fichero `~/.config/gtk-3.0/settings.ini` las siguientes lineas:

```
[Settings]
gtk-application-prefer-dark-theme = true
```

Pero esto tiene como desventaja que puede volver oscuras otras aplicaciones
menos preparadas para ello y que por lo tanto se verán peor.

**Opción b)**: Editar los estilos de `whisker` añadiendo al fichero
`~/.config/gtk-3.0/gtk.css` las lineas:

```css
#whiskermenu-window * {
  border: 0;
  outline: none;
}

#whiskermenu-window {
  background-color: #444;
  color: #ccc;
}

#whiskermenu-window entry {
  background-color: #555;
  color: #eee;
}

#whiskermenu-window button {
  background-color: #444;
  color: #ccc;
}

#whiskermenu-window treeview {
  background-color: #3e3e3e;
  color: #ccc;
}

#whiskermenu-window button:focus,
#whiskermenu-window button:hover,
#whiskermenu-window treeview:selected,
#whiskermenu-window treeview:hover
{
  background-color: #D64937;
  color: #fff;
}
```

**Fuentes**: [mysudo - wordpress](https://mysudo.wordpress.com/2015/04/25/xfce-und-numix-whisker-menu-dark-theme/), [numixproject - github](https://github.com/numixproject/numix-gtk-theme/issues/666)
