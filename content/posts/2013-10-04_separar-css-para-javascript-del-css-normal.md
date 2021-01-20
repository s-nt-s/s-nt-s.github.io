Title: Separar css para javascript del css normal
Date: 2013-10-04 08:05
Category: Web
Tags: Css, JavaScript
Slug: separar-css-para-javascript-del-css-normal


**Situación**: Tenemos componentes que se han de mostrar de una manera u
otra dependiendo de si hay javascript o no

**Ejemplos típicos**:

-   Un menú que se despliega con javascript, por lo tanto si no hay js
    ha de aparecer ya desplegado para que se pueda usar
-   Un botón que da funcionalidad con javascript, por lo tanto si no hay
    js no tiene sentido que aparezca
-   Un link que  da funcionalidad necesaria cuando no hay javascript,
    por lo tanto si hay js no es necesario que aparezca

**Solución tradicional**:

-   El menú se pinta desplegado y luego un método javascript lo colapsa
-   El botón no viene en el html si no que se añade posteriormente por
    medio de javascript
-   Se pinta el link y posteriormente se elimina por javascript

**Problema**: Si el explorador o la conexión es un poco lenta o la web
es muy pesada podemos ver como los componentes aparecen y desaparecen
delante de nuestras narices

**Solución elegante**: Tener separado un css para uso general y un css
para uso con javascript que solo estará disponible cuando haya js de
manera que la página se renderice como queremos a la primera

`css/main.css`:

```css
.displayIfJS{display:none;}
```

`css/javascript.css`:

```css
.hiddenIfJS{display:none;}
.displayIfJS{display:inline !important}
```

```html
<html>
<head>
    <link href="css/main.css" rel="stylesheet" media="screen" type="text/css" />
    <script type="text/javascript">
    // <![CDATA[
        document.write('<link media="screen" href="css/javascript.css" rel="stylesheet" type="text/css"/>');
    // ]]>
    </script>
</head>
<body>
    <input class="displayIfJS" onclick="do()" type="button" name="Bóton JS" />
    <a class="hiddenIfJS" href="#do">Link sin JS</a>
</body>
</head>
```

El caso del menú desplegable es similar, simplemente la clase o clases
que lo muestran colapsado estaría en javascript.css
