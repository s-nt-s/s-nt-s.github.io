Title: Permitir contraseñas simples en Linux Mint 15
Date: 2013-10-03 21:26
Category: Sistemas
Tags: Linux
Slug: permitir-contrasenas-simples


**Problema**: Nos cansa tener que definir contraseñas de 8 caracteres
para nuestros usuarios

**Solución**: Editar /etc/pam.d/common-password para permitir
contraseñas simples

1.  Editar como administrador /etc/pam.d/common-password
2.  Buscar una linea que empiece por `password` y contenga
    `pam_unix.so`
3.  Borrar la palabra obscure y añadir `nullok min_len=3`

```console
user@mint ~ $ gksudo gedit /etc/pam.d/common-password
```

Antes:

```
...
# here are the per-package modules (the "Primary" block)
password    [success=2 default=ignore]  pam_unix.so obscure sha512
password    [success=1 default=ignore]  pam_winbind.so use_authtok
...
```

Después:

```
...
# here are the per-package modules (the "Primary" block)
password    [success=2 default=ignore]  pam_unix.so nullok minlen=3 sha512
password    [success=1 default=ignore]  pam_winbind.so use_authtok
...
```

Reiniciar

```console
user@mint ~ $ passwd
Cambiando la contraseña de user.
(actual) contraseña de UNIX: ********
Introduzca la nueva contraseña de UNIX: ***
Vuelva a escribir la nueva contraseña de UNIX: ***
passwd: contraseña actualizada correctamente
```
