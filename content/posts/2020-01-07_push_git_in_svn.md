Title: Push GIT in SVN
Tags: git, svn
Category: Programación

**Problema**: Trabajamos en `git` pero queremos tener una copia de `master` en
un repositiorio `svn`

**Solución**: Crear en local una rama que servira exclusivamente para mezclar
con `master` y hacer commit en `svn` via `git svn`

## Detalle

Lo que vamos a hacer es crear una rama git llamada `svnsync` que estará
vinculada a nuestro repositorio `svn` mediante la extensión `git svn`.

A diferencia de otros manuales donde presuponen que tu `svn` tiene una
[organización estandar](https://tortoisesvn.net/docs/release/TortoiseSVN_es/tsvn-repository.html#tsvn-repository-layout),
yo vinculare directamente con el `trunk` obviando cualquier distribución para
que no haga falta preocuparse de este punto.

Esto lo puedo hacer porque solo nos interesa tener una especie de `backup` en `svn`,
si quisiéramos algo más versátil y complejo deberíamos cuidar la organización del repositorio
y configurar nuestra rama `git` y la extensión `git svn` teniéndola en cuenta.

Para el tutorial supondremos que el repositorio `git` esta en `git@github.com:my-user/my-repo.git`
y el `trunk` del `svn` esta en `https://my-svn-server.com/my-repos/trunk/my-repo`

## Prerequisitos

```console
$ sudo apt-get install git git-svn
$ git clone git@github.com:my-user/my-repo.git
$ cd my-repo
```

## Configuración

**1-** Creamos la rama:

```console
my-repo $ git branch --no-track svnsync
my-repo $ git branch
* master
  svnsync
```

**2-** Creamos la vinculación con `svn`

```console
my-repo $ git checkout svnsync
my-repo $ git svn init --trunk https://my-svn-server.com/my-repos/trunk/my-repo
my-repo $ git svn fetch
W: Ignoring error from SVN, path probably does not exist: (160013): El sistema de archivos no tiene el ítem: File not found: revision 100, path '/trunk/my-repo'
W: Do not be alarmed at the above message git-svn is just searching aggressively for old history.
This may take a while on large repositories
r292 = a9b53777212970a509d9bd3f7fbe18e0cedf01fd (refs/remotes/origin/trunk)
my-repo $ git reset --hard remotes/origin/trunk
HEAD está ahora en a9b5377 git-svn-id: https://my-svn-server.com/my-repos/trunk/my-repo@292 08dc7427-57a1-459d-80c6-e9e8415cd7c7
```

**3-** Mezclamos `master` en `svnsync`

```console
my-repo $ git checkout master
my-repo $ git pull origin master
my-repo $ git checkout svnsync
my-repo $ git svn rebase
my-repo $ git merge -X theirs --allow-unrelated-histories master
my-repo $ git commit
my-repo $ git svn dcommit
```

Podemos crear un script con los anteriores comandos para automatizar el proceso:

```bash
#!/bin/bash
set -e
# Comprobar que svnsync y master existen
git show-branch svnsync master
# Ir a master y actualizarlo
git checkout master
git pull origin master
# Ir a svnsync
git checkout svnsync
# Revertirlo a su última versión consolidada
git svn rebase
# Mezclar master en svnsync
git merge -X theirs --allow-unrelated-histories master
# Hacer commit local en git
git commit
# Subir cambios al svn
git svn dcommit
```

**Z-** Deshacer todo (si necesitas repetir el proceso desde cero y te esta dando problemas)

**Z.a)** Borrar rama `svnsync`

```console
my-repo $ git checkout master
my-repo $ git branch -D svnsync
```

**Z.b)** Borrar del .git/config las lineas:

```
[svn-remote "svn"]
	url = https://my-svn-server.com/my-repos
	fetch = trunk/my-repo:refs/remotes/origin/trunk
```

**Z.c)** Borrar histórico `svn`

```console
my-repo $ sudo rm -R .git/svn
```

**Z.d)** Si esto no funciona, no queda más remedio que empezar verdaderamente desde 0 (acuérdate de salvar tus cambios antes):

```console
my-repo $ cd ..
$ sudo rm -R my-repo
$ git clone git@github.com:my-user/my-repo.git
$ cd my-repo
```

**Fuentes**: [ben.lobaugh.net](https://ben.lobaugh.net/blog/147853/creating-a-two-way-sync-between-a-github-repository-and-subversion),
[blog.justincarmony.com](https://blog.justincarmony.com/2011/02/21/using-git-with-subversion),
[stackoverflow.com](https://stackoverflow.com/questions/14585692/how-to-use-git-svn-to-checkout-only-trunk-and-not-branches-and-tags)
