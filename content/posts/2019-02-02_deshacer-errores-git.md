Title: Deshacer errores en Git
Tags: git
Category: Programación
Status: draft

Chiquirecopilatorio de comandos útiles para cuando metes la pata
usando `Git`

## Deshacer un `push`

Listamos los dos últimos `commit`:

```console
$ git rebase -i HEAD~2
```

Seleccionamos el segundo y lo borramos.

Forzamos el cambio en la rama `master` o aquella en la que queramos
hacer la corrección:

```console
git push origin +master --force
```

Fuente: [stackoverflow.com](https://stackoverflow.com/questions/448919/how-can-i-remove-a-commit-on-github)
