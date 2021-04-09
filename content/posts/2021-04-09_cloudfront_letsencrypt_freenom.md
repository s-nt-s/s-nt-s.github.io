Title: AWS CloudFront con LetsEncrypt y Freemon
Category: Web
Tags: freemon, LetsEncrypt, AWS, CloudFront, dns

1. Registrarse en [freenom.com](https://www.freenom.com)
2. Crear el dominio `example.ml` ([Services -> Register a New Domain](https://my.freenom.com/domains.php) -> ...)
3. Ir a [AWS Route53](https://console.aws.amazon.com/route53/v2/home#Dashboard) -> `Create hosted zone`:
    * Domain name: example.ml
4. Copiamos los valores `ns-*` de la columna `Value/Route traffic to`
5. En [freenom.com](https://www.freenom.com) seleccionamos nuestro dominio y vamos a `Manage Tools -> Nameserver`
6. Seleccionamos `Use custom nameservers (enter below)` y rellenamos los campos `Nameserver` con los valores `ns-*` anteriormente copiados
7. En [dnschecker.org/#NS](https://www.dnschecker.org/#NS) podemos validar el resultado pasados unos minutos
8. Solicitar el certificado a letsencrypt:
    * `certbot certonly --manual --preferred-challenges=dns --email your@email-address.com --agree-tos --config-dir ./config --logs-dir ./logs --work-dir ./workdir -d example.ml -d *.example.ml`
    * Esto imprimirá una regla DNS que debemos crear
9. Volvemos a [AWS Route53](https://console.aws.amazon.com/route53/v2/home#Dashboard) y pulsamos en `Create record`:
    * Name Record: `_acme-challenge`
    * Record type: TXT
    * Value: *dato proporcionado en el paso anterior* (cadena alfanumerica)
10. Vamos a [AWS Certificate Manager](https://console.aws.amazon.com/acm/home) (en zona us-east-1 para poder usarlo en CloudFront)y pulsamos en `Import a certificate`:
    * Certificate body = contenido de `config/live/example.ml/cert.pem`
    * Certificate private key = contenido de `config/live/example.ml/privkey.pem`
    * Certificate chain = contenido de `config/live/example.ml/chain.pem`
11. Vamos a [CloudFront](https://console.aws.amazon.com/cloudfront/home?region=us-east-1#distributions:) y editamos la distribución:
    * Alternate Domain Names (CNAMEs) = example.ml
    * SSL Certificate -> Custom SSL Certificate: seleccionamos el certificado anteriormente importado
12. Volvemos a [AWS Route53](https://console.aws.amazon.com/route53/v2/home#Dashboard) y seleccionamos la zona creada anteriormente
13. Pulsamos en `Create record`:
    * Marcar el check `Alias`
    * Routing policy = Simple routing
    * Record type = A – Routes traffic to an IPv4 address and some AWS resources
    * Route traffic to = Alias to CloudFront distribution
    * Region = US East (N. Virginia)
    * CloudFront = seleccionamos nuestro CloudFront

**Bonus**: Si estas fuera de USA y [freenom.com](https://www.freenom.com) falla siempre
en el último del paso del registro de dominio prueba a [cambiar la dirección de tu perfil
de usuario por una de USA](https://www.fakeaddressgenerator.com/usa_address_generator)
y [acceder a traves de VPN con una ip de USA](https://chrome.google.com/webstore/detail/hola-free-vpn-proxy-unblo/gkojfkhlekighikafcpjkiklfbnlmeio).

**Fuentes**: [itnext.io](https://itnext.io/using-letsencrypt-ssl-certificates-in-aws-certificate-manager-c2bc3c6ae10), [medium.com/200-response](https://medium.com/200-response/como-crear-una-p%C3%A1gina-est%C3%A1tica-usando-aws-y-freenom-casi-completamente-gratis-parte-2-manos-a-la-48b9b6f45074), [medium.com/analytics-vidhya](https://medium.com/analytics-vidhya/tutorial-how-to-deploy-an-angular-app-with-a-free-domain-and-ssl-to-aws-s3-and-cloudfront-d0143de53d2d), [reddit.com/r/freenom](https://www.reddit.com/r/freenom/comments/gegiy4/i_cant_register_free_domains_with_freenom/)
