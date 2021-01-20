Title: Usar git con diferentes usuarios
Category: Programación
Tags: git, github, ssh

**Situación**:

Tienes que trabajar en dos proyectos: `project1` y `project2`.
Los dos están en el el mismo servidor (por ejemplo, `GitHub`)
pero en cada uno vas a hacer commits con un usuario diferente:
`user1` y `user2` respectivamente.

Además, el acceso para interactuar con el servidor (`clone`, `pull`,
`push`) también requiere usuarios diferentes.

**2 problemas**:

1. Acceso al repositorio remoto: Tener que conectarte al mismo servidor remoto con dos identidades
distintas requiere "desdoblar" de alguna manera la referencia al servidor
para poder tener dos configuraciones distintas para él
2. No confundir usuarios: Usar en el mismo equipo dos identidades puede provocar que sin darte
cuenta hagas commit en un repositorio con el usuario equivocado

## ¿Cómo acceder al repositorio remoto?

Para solucionar el primer problema usaremos autenticación por `SSH`
y crearemos dos configuraciones distintas en `.ssh/config` para
acceder al servidor.

**1**- Generar las `claves SSH`

```console
$ ssh-keygen -t rsa -b 4096 -C "user1@example.com"
Generating public/private rsa key pair.
Enter a file in which to save the key (/home/you/.ssh/id_rsa): /home/you/.ssh/user1
Enter passphrase (empty for no passphrase): [Type a passphrase]
Enter same passphrase again: [Type passphrase again]

$ ssh-keygen -t rsa -b 4096 -C "user2@example.com"
Generating public/private rsa key pair.
Enter a file in which to save the key (/home/you/.ssh/id_rsa): /home/you/.ssh/user2
Enter passphrase (empty for no passphrase): [Type a passphrase]
Enter same passphrase again: [Type passphrase again]
```

Y las añadimos a `GitHub` siguiendo los
[pasos indicados en su manual](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/).

**2**- Configurar `SSH`

Suponiendo que `user1` es el usuario que queremos usar por defecto
editamos `.ssh/config` de la siguiente manera:

```
Host github.com
HostName github.com
User git
IdentityFile ~/.ssh/user1

Host github-user2
HostName github.com
User git
IdentityFile ~/.ssh/user2
```

**3**- Configurar los repositorios

La clave esta en clonar cada repositorio con el `host ssh` adecuado.

```console
$ git clone git@github.com:user-random/project1.git
$ git clone git@github-user2:user-random/project2.git
```

De manera que en `project1` tendremos un proyecto que accede al
servidor con el usuario `user1` y en `project2` tendremos un proyecto
que accede al servidor con el usuario `user2`.

**Bonus**: Por comodidad, también podemos configurar `git` para usar `ssh` en vez de `https`

Como hemos dicho que `user1` va a ser nuestro usuario por defecto y
en `GitHub` es más habitual clonar usando `https`, podemos configurar
`git` para que transforme las urls directamente a `ssh` de esta manera:

```console
$ git config --global url.ssh://git@github.com/.insteadOf https://github.com/
```

Esto hará que hacer:

```console
$ git clone https://github.com/user-random/project1
```

sea equivalente a hacer:

```console
$ git clone git@github.com:user-random/project1.git
```

y como en `.ssh/config` la entrada para `github.com` es la de `user1`,
se usara su clave para el acceso.

## ¿Cómo hacer commit con distinto usuario?

Manualmente podemos ir a cada repositorio y definir una configuración local:

```console
$ cd project1
project2/ $ git config --local user.name user1
project2/ $ git config --local user.email user1@example.com
$ cd ..
$ cd project2
project2/ $ git config --local user.name user2
project2/ $ git config --local user.email user2@example.com
```

pero si con el tiempo vamos a ir teniendo más y más proyectos
para cada uno de los usuarios debemos automatizar esto
para evitar errores.

Hay varias alternativas:

### Obligar a usar la configuración local

Para evitar que en un proyecto de `user2` usemos la identidad
de `user1` sin querer por no haber definido la configuración
local, podemos obligar a que sea un requisito haciendo:

```console
git config --global --add user.useConfigOnly true
git config --global --unset-all user.email
git config --global --unset-all user.name
```

### Una carpeta por usuario

Si tenemos todos los proyectos de `user1` en `~/wks1` y
todos los proyectos de `user2` en `~/wks2` podemos añadir
en `~/.gitconfig` las lineas:

```
[includeIf "gitdir:~/wks1/"]
    path = ~/wks1/.gitconfig
[includeIf "gitdir:~/wks/"]
    path = ~/wks2/.gitconfig
```

y escribir `~/wks1/.gitconfig` con el contenido:

```
[user]
name = user1
email = user1@example.com
```

y `~/wks1/.gitconfig` con el contenido:

```
[user]
name = user2
email = user2@example.com
```

### Crear un hook para git clone

En realidad no existe `hook` para `clone`, pero podemos usar el `hook`
`post-checkout` que se ejecuta tras un `checkout`, lo cual siempre
sucede cuando se hace `clone` (a no ser que se use el argumento `--no-checkout`).

Para ello hacemos:

```console
$ mkdir -p ~/.git/hooks
$ git config --global core.hooksPath ~/.git/hooks
$ touch ~/.git/hooks/post-checkout
```
y en `~/.git/hooks/post-checkout` ponemos este script:

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-
import git
import ConfigParser
import os
import sys

repo = git.Repo(os.getcwd())

# Don't do anything if an identity is already configured in this
# repo's .git/config
config = repo.config_reader(config_level = 'repository')
try:
  # The value of user.email is non-empty, stop here
  if config.get_value('user', 'email'):
    sys.exit(0)
except (ConfigParser.NoSectionError, ConfigParser.NoOptionError):
  # Section or option does not exist, continue
  pass
origin = repo.remote('origin')
if not origin:
  print('** Failed to detect remote origin, identity not updated! **')
  sys.exit(0)
email = None
user = None
# This is where you adjust the code to fit your needs
if '/user1/' in origin.url:
  user = "user2"
  email = 'user2@example.com'
elif '/user2/' in origin.url:
  user = "user1"
  email = 'user1@example.com'
if email:
  # Write the option to .git/config
  config = repo.config_writer()
  config.set_value('user', user)
  config.set_value('email', email)
  config.release()
  print('User identity for this repository set to %s <%s>' % (user, email))
```

# ¿Y si aún así metes la pata?

Si a pesar de todo ya has hecho un commit con el usuario erróneo
puedes reescribir el autor de los commits con el siguiente
script:

```bash
#!/bin/sh

git filter-branch --env-filter '
OLD_EMAIL="user2@example.com"
CORRECT_NAME="user1"
CORRECT_EMAIL="user1@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

adecuando las variables `OLD_EMAIL`, `CORRECT_NAME` y `CORRECT_EMAIL`
a tu caso.

Y luego fuerza el cambio con `git push --force --tags origin HEAD:master`

Pero ten en cuento que esto reescribe el histórico y puedes
romper un montón de ramas.

Fuentes:
[medium.com/@therajanmaurya](https://medium.com/@therajanmaurya/git-push-pull-with-two-different-account-and-two-different-user-on-same-machine-a85f9ee7ec61),
[collectiveidea.com](https://collectiveidea.com/blog/archives/2016/04/04/multiple-personalities-in-git),
[dvratil.cz](https://www.dvratil.cz/2015/12/git-trick-628-automatically-set-commit-author-based-on-repo-url/),
[blog.sleeplessbeastie.eu](https://blog.sleeplessbeastie.eu/2020/05/04/how-to-share-git-hooks-between-multiple-repositories/),
[stackoverflow.com](https://stackoverflow.com/a/750182),
[stackoverflow.com](https://stackoverflow.com/a/36296990/5204002)
