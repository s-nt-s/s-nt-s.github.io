Title: Usar un dominio Freemon en GitHub Pages
Category: Web
Tags: freemon, github, dns

Suponiendo que tu usuario GitHub se llama `user` y por
lo tanto el dominio que te da GitHub sea
`user.github.io` y tu quieras usar `user.com`
los pasos a seguir serían:

1. Registrarse en [freenom.com](https://www.freenom.com)
2. Crear el dominio `example.com` ([Services -> Register a New Domain](https://my.freenom.com/domains.php) -> ...)
3. Una vez creado, ir a la configuración del dominio ([Services -> My Domains](https://my.freenom.com/clientarea.php?action=domains) -> `example.com` -> Manage Domain)
4. Seleccionar Management Tools -> Nameservers -> Use default nameservers (Freenom Nameservers)
5. Ir a Manage Freenom DNS y añadimos las siguientes lineas:
    * Type=A, Target=185.199.108.153
    * Type=A, Target=185.199.109.153
    * Type=A, Target=185.199.110.153
    * Type=A, Target=185.199.111.153
    * NAME=www, Type=CNAME, Target=user.github.io
6. Ir a las settings del proyecto GitHub github.com/user/user.github.io/settings
7. Escribir `user.com` en Options -> GitHub Pages -> Custom domain
6. Pulsar `Save`
7. Si se desea, marcar `Enforce HTTPS` cuando este disponible

**Bonus 1**: Si usas `Pelican`, acuérdate de consultar el `Tip #2` de
[docs.getpelican.com](https://docs.getpelican.com/en/3.6.3/tips.html#extra-tips)
para que no se pierda la configuración.  
**Bonus 2**: Si no quieres que el cambio afecte a todos tus proyectos
[consulta este issue](https://github.com/isaacs/github/issues/547#issuecomment-694671575).  
**Bonus 3**: Si estas fuera de USA y [freenom.com](https://www.freenom.com) falla siempre
en el último del paso del registro de dominio prueba a [cambiar la dirección de tu perfil
de usuario por una de USA](https://www.fakeaddressgenerator.com/usa_address_generator)
y [acceder a traves de VPN con una ip de USA](https://chrome.google.com/webstore/detail/hola-free-vpn-proxy-unblo/gkojfkhlekighikafcpjkiklfbnlmeio).

**Fuentes**: [docs.github.com](https://docs.github.com/es/free-pro-team@latest/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site),
[stackoverflow.com](https://stackoverflow.com/a/49963795/5204002), [reddit.com/r/freenom](https://www.reddit.com/r/freenom/comments/gegiy4/i_cant_register_free_domains_with_freenom/)
