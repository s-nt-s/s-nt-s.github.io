Title: Usar el correo para esquivar proxy
Date: 2014-05-15 18:04
Category: Programación
Slug: usar-el-correo-para-esquivar-proxy


**Problema 1**: Necesitamos descargar o copiar unos archivos en un
equipo con puertos usb capados, sin lectora de cds y conectado a una red
cuyo proxy impone una cuota máxima de descarga e impide entrar en según
que dominios.

**Solución 1**: Buscar algún dominio de correo electrónico que figure
como excepción del proxy, para mandarse los archivos a ese correo e
irlos bajándolos

**Problema 2**: Subir los correos a mano es tedioso y dependemos de la
cuota del correo, si esta es menor de lo que necesitamos tendremos que
hacer el proceso en varias tandas y eso puede suponer hacer varios
viajes entre nuestro equipo libre (desde el que mandamos archivos) y el
equipo enjaulado (el del proxy)

**Solución 2**: Automatizar la subida de archivos al correo sin
necesidad de enviar - o autoenviar - un mail, simplemente dejamos en un
solo paso el archivo en una carpeta imap del servidor de correo.

**1-** Preparar en nuestro equipo libre los archivos

Creamos un zip por volúmenes según el tamaño máximo permitido por la
cuenta de correo que vamos a usar

```console
pi@bot ~ $ zip -r -s 40m -0 -Pmailzip /tmp/mail.zip /data
```

El parámetro -Pmailzip define "mailzip" como contraseña del zip
resultante, con esto evitamos que el servidor rechace el mail por alguno
de sus contenidos (por ejemplo, un ejecutable).

**2-** Creamos el script y su archivo de configuración en nuestro equipo
libre (`mail.pl`)

```perl
#!/usr/bin/perl -w
use Mail::IMAPClient;
use MIME::Lite;
use Cwd 'abs_path';

local $| = 1;

my $imap;
my $quota;
my %cfg;
my $seg=1; #seguimiento

sub save {
    my($file,$txt,$total,$count) = @_;
    my $name=$file;
    $name=~ s/^.+\///;
    if ($total==1) {print "Subiendo $name ... ";}
    else {print "Subiendo $count de $total: $name ... ";}
    my $msg = MIME::Lite->new(
            From    =>'up@bot.com',
            To      =>'down@bot.com',
            Subject =>'Up [' .$count . '/' . $total . ']: ' . $name,
            Type    =>'multipart/mixed'
    );
    if ($txt) {
        $msg->attach(Type => 'TEXT', Data => $txt);
    }
    $msg->attach(
            Type        =>'application/zip',
            Path        => $file,
            Filename    => $name,
            Disposition => 'attachment'
    );
    my $id=imap()->append_string(imap()->Folder(),$msg->as_string);
    print "OK\n";
}

sub space {
    my ($file) = @_;
    my $size=((-s $file)/1024);
    my $free=$quota-imap()->quota_usage();
    return if ($size<$free);
    if ($seg) {
        print "Esperando a que el usuario libere " . int(($size-$free)/1024 + 0.99) . "MB del servidor... ";
        while ($size>($quota-imap()->quota_usage())) {sleep(10);}
        print "OK\n";
    } else {
        print "Pulse enter para purgar ". imap()->Folder() . " ...";
        <STDIN>;
        purge();
    }
}

sub purge {
    my @dvs=imap()->messages  or die "Could not messages: $@\n";
    foreach my $dv (@dvs){imap()->delete_message($dv);}
    imap()->expunge(imap()->Folder());
}

sub setCfg {
    my $fl=$_[0];
    if (! $fl) {
        $fl=$0;
        $fl=~ s/^.+\/|\..+$//g;
        $fl= $ENV{"HOME"} . "/." . $fl . ".cnf";
    }
    open (CFG, $fl) or die "No se pueo abrir el fichero e configuracion: $fl\n" . $@;
    %cfg=();
    while (my $line=<CFG>) {
        $line=~ s/^\s+|\s+$|\s+#.*$//g;
        next if (substr($line, 0, 1) eq "#");
        (my $k,my $v) = split /\s*=\s*/, $line;
        $cfg{$k} = $v;
    }
    close(CFG);
}

sub imap {
    if (!$imap || $imap->IsUnconnected) {
        if (! %cfg) {setCfg()};
        print "Conectando a $cfg{User}/$cfg{Folder} ... " ;
        $imap = Mail::IMAPClient->new(%cfg) || die "\n$@\n";
        $imap->select($imap->Folder());
        print "OK\n";
    }
    return $imap;
}

my $purge=0;
my @files=();
foreach my $a (@ARGV) {
    if ($a eq "--key") {$seg=0;}
    elsif ($a eq "--purge") {$purge=1;}
    next unless (-f $a);
    if ($a =~ /.+\.z(ip|\d+)$/) {push (@files, abs_path($a));}
    elsif ($a =~ /.+\.cnf$/) {setCfg($a);}
}

my $t=scalar (@files);

die "Debe pasar una lista de ficheros zip\n" unless $t>0;

if ($purge) {purge();}

$quota=imap()->quota()-(1024*5);
my $free=($quota-$imap->quota_usage());

my $aux;
my $max=0;
foreach my $f (@files){
    $aux=(-s $f)/1024;
    die "El fichero $f [" . int(($aux/1024) + 0.99) . "MB] ocupa más de lo que el servidor puede almacenar [". int($quota/1024) . "MB]\n" unless $aux<$quota;
    if ($aux>$max) {$max=$aux};
}
die "Necesita liberar al menos " . int(($max/1024) + 0.99) . "MB antes de empezar\n" if ($max>$free);

my $c=1;
my $m=join(" ",@ARGV);

foreach my $f (@files){
    space($f);
    save($f,$m,$t,$c++);
}

if ($imap && $imap->IsConnected) {
    $imap->disconnect or die "Could not disconnect: $@\n";
}
```

`.up.cnf`:

```
Server    = imap.cep.correos.es
Port      = 993
User      = BARTOLO.PIROLO.57658Z@correos.es
Password  = 123456
Peek      = 1
Uid       = 1
Ssl       = 1
Folder    = dv
```

dv (el valor del campo "Folder") es el nombre de la carpeta que hemos
creado en nuestra cuenta de correo para servir a este propósito, de
manera que nuestros mails "esquiva-proxy" no se mezclen con nuestro
correo normal.

**3-** Arrancamos el script

El script ira subiendo un volumen detrás de otro hasta llenar la cuenta
de correo y esperará a que nosotros, desde el equipo enjaulado y tras
haber descargado los adjuntos, liberemos espacio para continuar
automáticamente.

```console
pi@bot ~ $ ./mail.pl /tmp/mail.z*
Conectando a BARTOLO.PIROLO.57658Z@correos.es/dv ... OK
Subiendo 1 de 4: mail.z01 ... OK
Subiendo 2 de 4: mail.z02 ... OK
Esperando a que el usuario libere 20MB del servidor... OK
Subiendo 3 de 4: mail.z03 ... OK
Subiendo 4 de 4: mail.zip ... OK
```

Nuestro correo antes de empezar el proceso tenia 100MB libres. En el
primer paso el script llena 40MB, en el segundo llena otros 40MB, en el
tercer paso ve que necesita al menos otros 20MB para subir el tercer
paquete así que para hasta que estén disponibles. Mientras tanto
nosotros, desde el equipo enjaulado, descargamos los dos primeros
adjuntos y borramos los dos correos. Finalmente el script ve que vuelve
a haber espacio y continua con la carga hasta finalizar.

**4-** Ampliación

Hacer un script que pasándole una url descargue el contenido enlazado,
lo comprima en los volúmenes deseados y lo deje en nuestro correo, de
manera que aún surgiendo una necesidad imprevista ya estando en frente
del equipo enjaulado podamos con un móvil y un cliente ssh (o algún
servicio web creado para la ocasión) hacernos fácilmente con los
archivos que pudiéramos necesitar en un momento dado y que no son
accesibles a través del proxy.

**5-** Apéndice

El script puede ser ejecutado con el parámetro --key para que en vez de
esperar a que se libere espacio lo que haga es pedirnos que pulsemos
enter cuando hayamos acabado de descargar el fichero y así él mismo se
encargue de liberar el espacio. Esto puede ser útil cuando lanzamos el
script desde el movil (vía ssh, por ejemplo) y nos es más rápido pedirle
al script que borre él los mails que hacerlo nosotros a mano desde la
interfaz de nuestro correo electrónico.

También admite el parámetro --purge para eliminar todo lo que haya en la
carpeta de intercambio (dv) antes de empezar a subir el primer volumen.
Útil para cuando sabemos que puede haber quedado algo de un anterior
envío.
