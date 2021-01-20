Title: Reiniciar repositorio Git
Category: Programación
Tags: git
body_class: ulcompact

**Problema**: El repositorio ocupa mucho (gigas) aunque el código
representa solo un puñado de megas.

**Solución**: Reiniciar el repositorio Git y olvidarse de la historia pasada.

## Detalle

En ocasiones nuestro repositorio Git ha crecido enormemente,
cuenta con una muy larga historia de commits e incluso puede
que en ellos estén envueltos grandes ficheros que ni siquiera
usamos ya, provocando que nuestro proyecto ocupe gigas aunque
el código solo sume unos cuantos megas.

En una situación así puede interesar hacer borrón y cuenta nueva,
sobre todo si lo anterior lo podemos considerar un prototipo
o versión ya finalizado, listo para ser tageado y olvidarse de él.

## Pasos

**1-** Asegurarse de estar sincronizado y en master

```console
$ git branch
* master
$ git status
En la rama master
Tu rama está actualizada con 'origin/master'.

nada para hacer commit, el árbol de trabajo está limpio
```

**2-** Creamos el tag para que no se pierda nada

```console
$ git tag -a -m "Ultima versión antes de reiniciar repositorio" v1
$ git push origin v1
```

**3-** Crear una nueva rama desde 0

```console
$ git checkout --orphan nuevo_comienzo
Cambiado a nueva rama 'nuevo_comienzo'
$ git add -A
$ git commit -am "nuevo_comienzo"
$ git status
En la rama nuevo_comienzo
nada para hacer commit, el árbol de trabajo está limpio
$ git branch
  master
* nuevo_comienzo
```

**4-** Sustituir master con nuevo_comienzo

```console
$ git branch -D master # Elimina 'master' original
$ git branch -m master # Renombra 'nuevo_comienzo' a 'master'
$ git push -f origin master # Sube los cambios
```
**5-** Limpiar todo lo que ha quedado huérfano

```console
$ git gc --aggressive --prune=all
```

**Fuentes**: [medium.com/@sangeethkumar.tvm.kpm](https://medium.com/@sangeethkumar.tvm.kpm/cleaning-up-a-git-repo-for-reducing-the-repository-size-d11fa496ba48),
[stackoverflow.com](https://stackoverflow.com/questions/13716658/how-to-delete-all-commit-history-in-github)
