Title: Montando este blog (wordpress)
Date: 2013-10-03 08:51
Category: Web
Tags: Suffusion, Wordpress
Slug: montando-este-blog-wordpress

**NOTA:** Esto es de cuando el blog estaba en wordpress.

**1-** Poner Wordpress en español

-   Editar wp-config.php y cambiar define('WPLANG', ''); por
    define('WPLANG', 'es\_ES');
-   Dashboard -&gt; Updates

**2-** Instalar y activar estos plugins y temas:

-   Plugins -&gt; Añadir nuevo: [Custom
    sidebars](http://wordpress.org/plugins/custom-sidebars/)
-   Plugins -&gt; Añadir nuevo: [Jetpack por
    WordPress.com](http://wordpress.org/extend/plugins/jetpack/)
-   Plugins -&gt; Añadir nuevo: [Ultimate Tag Cloud
    Widget](https://www.0x539.se/wordpress/ultimate-tag-cloud-widget/)
-   Plugins -&gt; Añadir
    nuevo: [WP-PageNavi](https://wordpress.org/plugins/wp-pagenavi/)
-   Plugins -&gt; Añadir nuevo: [Crayon Syntax
    Highlighter](https://wordpress.org/plugins/crayon-syntax-highlighter/)
-   Apariencia -&gt; Temas -&gt; Instalar temas:
    [Suffusion](http://wordpress.org/themes/suffusion)

**3-** Cambiar ajustes básicos

-   Apariencia -&gt; Fondo -&gt; Color de fondo: \#66cdaa
-   Ajustes -&gt; General -&gt; Título del sitio: Blog de apuntes
-   Ajustes -&gt; General -&gt; Descripción corta -&gt; mejor aquí que
    en un txt perdido
-   Ajustes -&gt; General -&gt; Formato de Fecha: 03/10/2013
-   Ajustes -&gt; General -&gt; Formato de Hora: 16:30
-   Ajustes -&gt; General -&gt; La semana comienza el: Lunes
-   Ajustes -&gt; Comentarios -&gt; Desactivar "Activar los comentarios
    anidados hasta 5 niveles"
-   Ajustes -&gt; Enlaces permanentes -&gt; Estructura personalizada:
    /%post\_id%
-   Ajustes -&gt; Medios -&gt; Desactivar "Organizar mis archivos
    subidos en carpetas basadas en mes y año"
-   Ajustes -&gt; PageNavi -&gt; Texto para el Número de Páginas, Texto
    para la Página Anterior, Texto para la Página Siguiente: *lo dejamos
    en blanco*
-   Ajustes -&gt; PageNavi -&gt; Texto para la Primera página: 1
-   Ajustes -&gt; PageNavi -&gt; Texto para la Última Página:
    %TOTAL\_PAGES%
-   Ajustes -&gt; PageNavi -&gt; Número de Páginas a Mostrar: 20
-   Ajustes -&gt; PageNavi -&gt; Números Grandes en la Paginación: 0
-   Ajustes -&gt; PageNavi -&gt; Mostrar Numeros Grandes que sean
    Multiplos de: 0

**4-** Configurar Suffusion \[Apariencia -&gt; Suffusion options\]

-   Typography -&gt; Body Fonts -&gt; Deafult or custom font styles:
    Custom styles
-   Typography -&gt; Body Fonts -&gt; Link color: 008080
-   Other Graphical Elements -&gt; Header -&gt; Description / Sub-Header
    Alignment: Left
-   Other Graphical Elements -&gt; Header -&gt; Description / Sub-Header
    Vertical Alignment, relative to header: Below the header text
-   Back-end -&gt; Custom includes -&gt; First Additional Stylesheet
    link: http://apuntes.pusku.com/my/css.css

**5-** Configurar Ultimate tag Cloud \[Apariencia -&gt; Widgets -&gt;
Sidebar 1\]

-   Data -&gt; Order by: Count (reverse order)
-   Data -&gt; Post max age -&gt; 90
-   Basic Apparence -&gt; Title: Temas recientes
-   Basic Apparence -&gt; Tag Size: from 12px to 12px
-   Basic Apparence -&gt; Max tag: 4
-   Advance Apparence -&gt; Tag separator -&gt; Separator: - (tres
    espacios antes del guión y uno después)

**6-** Crear listado de entradas

-   Páginas -&gt; Añadir nueva -&gt; Título: entradas
-   Atributos de página -&gt; Plantilla: Page of Post

**7-** Creando página principal

-   Páginas -&gt; Añadir nueva -&gt; Título: inicio
-   Páginas -&gt; Atributos de página -&gt; Plantilla: Custom Layout
    (darle a guardar antes de continuar)
-   Páginas -&gt; Additional Options for Suffusion -&gt; Marcar "No
    enlazar a esta página en la barra de navegación"
-   Páginas -&gt; Additional Options for Suffusion -&gt; Marcar "Do not
    display the page title"
-   Páginas -&gt; Additional Options for Suffusion -&gt; Custom Template
    -&gt; Number of colums: 1, 2, 1, 3, 2 consecutivamente
-   Ajustes -&gt; Lectura -&gt; Página frontal muestra -&gt; Una página
    estática -&gt;Página inicial: inicio

**8-** Configurar página de inicio \[Apariencia -&gt; Widgets\]

-   Custom Layout Widget Area 1 &lt;- La dejamos vacía para usarla
    esporádicamente (avisos y cosas así)
-   Custom Layout Widget Area 2 -&gt; Un "Query post" por cada categoría
    con:
    -   Titulo: Ultimas &lt;&lt;categoría&gt;&gt;
    -   Select category to show: &lt;&lt;categoría&gt;&gt;
-   Custom Layout Widget Area 2 -&gt; Widget Texto: &lt;center&gt;&lt;a
    href="entradas"&gt;ver todas las entradas en orden cronológico
    &lt;/a&gt;&lt;/center&gt;

**9-** Crear lenguaje y tema Terminal para Crayon

`wp-content/uploads/crayon-syntax-highlighter/themes/terminal-plain/terminal-plain.css`

```css
.crayon-theme-terminal-plain {
	border-width: 1px !important;
	border-style: solid !important;
	text-shadow: none !important;
	background: #000000 !important;
	border-radius: 5px 5px 0 0;
	border-color: grey;
	opacity: 0.9;
}
.crayon-theme-terminal-plain-inline {
	border-width: 1px !important;
	border-color: #000000 !important;
	border-style: solid !important;
	background: #000103 !important;
}
.crayon-theme-terminal-plain .crayon-table {
	margin: 6px !important;
}
.crayon-theme-terminal-plain .crayon-table .crayon-nums {
	background: #000000 !important;
	color: #000000 !important;
	border-right-width: 1px !important;
	border-right-color: #ffffff !important;
}
.crayon-theme-terminal-plain *::selection {
	background: transparent !important;
}
.crayon-theme-terminal-plain .crayon-code *::selection {
	background: #ddeeff !important;
	color: #316ba5 !important;
}
.crayon-theme-terminal-plain .crayon-striped-line {
	background: #000000 !important;
}
.crayon-theme-terminal-plain .crayon-striped-num {
	background: #000000 !important;
	color: #000000 !important;
}
.crayon-theme-terminal-plain .crayon-marked-line {
	background: #3b3b3b !important;
	border-width: 1px !important;
	border-color: #3a3a47 !important;
}
.crayon-theme-terminal-plain .crayon-marked-num {
	color: #000000 !important;
	background: #000000 !important;
	border-width: 1px !important;
	border-color: #000000 !important;
}
.crayon-theme-terminal-plain .crayon-marked-line.crayon-striped-line {
	background: #3b3b3b !important;
}
.crayon-theme-terminal-plain .crayon-marked-num.crayon-striped-num {
	background: #000000 !important;
	color: #000000 !important;
}
.crayon-theme-terminal-plain .crayon-marked-line.crayon-top {
	border-top-style: solid !important;
}
.crayon-theme-terminal-plain .crayon-marked-num.crayon-top {
	border-top-style: solid !important;
}
.crayon-theme-terminal-plain .crayon-marked-line.crayon-bottom {
	border-bottom-style: solid !important;
}
.crayon-theme-terminal-plain .crayon-marked-num.crayon-bottom {
	border-bottom-style: solid !important;
}
.crayon-theme-terminal-plain .crayon-info {
	background: #faf9d7 !important;
	border-bottom-width: 1px !important;
	border-bottom-color: #b1af5e !important;
	border-bottom-style: solid !important;
	color: #7e7d34 !important;
}
.crayon-theme-terminal-plain .crayon-toolbar {
	border-bottom-width: 1px !important;
	border-bottom-color: #2e2e2e !important;
	border-bottom-style: solid !important;
	background-color:grey;
	text-align: center !important;
}
.crayon-theme-terminal-plain .crayon-toolbar > div {
	float: left !important;
}
.crayon-theme-terminal-plain .crayon-toolbar .crayon-tools {
	float: right !important;
	right: 5px;
	top: 0;
}
.crayon-theme-terminal-plain .crayon-tools:before {
	content: "- + x";
}
.crayon-theme-terminal-plain .crayon-title {
	float: none;
	padding-bottom: 1px;
	padding-top: 1px;
}
.crayon-theme-terminal-plain .crayon-title:before {
	content: "bash - Terminal";
}
.crayon-theme-terminal-plain .crayon-language {
	color: #494949 !important;
}
.crayon-theme-terminal-plain .crayon-tools .crayon-button {
	display:none;
}
.crayon-theme-terminal-plain .crayon-button:hover {
	background-color: #bcbcbc !important;
	color: #666;
}
.crayon-theme-terminal-plain .crayon-button.crayon-pressed:hover {
	background-color: #bcbcbc !important;
	color: #666;
}
.crayon-theme-terminal-plain .crayon-button.crayon-pressed {
	background-color: #626262 !important;
	color: #FFF;
}
.crayon-theme-terminal-plain .crayon-button.crayon-pressed:active {
	background-color: #626262 !important;
	color: #FFF;
}
.crayon-theme-terminal-plain .crayon-button:active {
	background-color: #bcbcbc !important;
	color: #FFF;
}
.crayon-theme-terminal-plain .crayon-pre {
	color: #ffffff !important;
}
.crayon-theme-terminal-plain .crayon-nums-content {
	display:none;
}
.crayon-theme-terminal-plain td.crayon-code > div.crayon-pre * {
	font-family: "Droid Sans Mono","Consolas",monospace !important;
	line-height: 1.5em !important;
	font-size: 13px !important
}
.crayon-theme-terminal-plain .crayon-toolbar .crayon-language {
	display:none;
}
.crayon-theme-terminal-plain .crayon-pre .crayon-prompt {
	color: #00ff00 !important;
	font-weight: bold !important;
}
.crayon-theme-terminal-plain .crayon-pre .crayon-prompt + .crayon-path, .crayon-theme-terminal-plain .crayon-pre .crayon-prompt + .crayon-h + .crayon-path {
	color: #3366ff; !important;
	font-weight: bold !important;
}
```

`wp-content/uploads/crayon-syntax-highlighter/langs/terminal/terminal.txt`:

```
### VOID LANGUAGE ###

#   ELEMENT_NAME [optional-css-class] REGULAR_EXPRESSION

    NAME                
    VERSION             1.0.0

    STATEMENT   [prompt]	^([a-z]+@[a-z]+)
    ENTITY		[path]		((~|\/[^\$ ]+|\/) \$)
```

Ir a Ajustes --&gt; Crayon --&gt; Languages --&gt; Mostrar lenguajes

**10-** Cambiar algunos comportamientos por defecto

-   Deshabilitar el autoembebido de contenidos multimedia: Ver
    [wpengineer.com/2487](http://wpengineer.com/2487/disable-oembed-wordpress/)
-   Evitar remplazar -- por `—`{.string}: Ver
    [www.jorisvandijk.com/2014/04/08/disable-auto-formatting-of-dashes-in-wordpress](http://www.jorisvandijk.com/2014/04/08/disable-auto-formatting-of-dashes-in-wordpress/)

El resultado es este plugin:

`wp-content/plugins/no-embeds-no-dash/no-embeds-no-dash.php`:

```php
<?php
remove_filter('the_content', array( $GLOBALS['wp_embed'], 'autoembed' ), 8 );
remove_filter('the_content', 'wptexturize');
remove_filter('the_excerpt', 'wptexturize');
remove_filter('comment_text', 'wptexturize');
remove_filter('the_title', 'wptexturize');
```
