Title: Recordar comandos
Date: 2014-07-10 16:09
Category: Sistemas
Slug: recordar-comandos


**Problema 1**: Tenemos que volver a usar algún comando o fichero pero
no conseguimos recordarlo

**Solución 1**: Pulsar en <span title=" &amp;#8593; ">↑</span> para
mirar en el histórico de comandos usados

**Problema 2**: Es un rollo y hay mucha morralla

**Solución 2**: Hacer un script que analice el histórico y nos saque la
información más relevante

**1-** Configurar histórico (`~/.bashrc`)

```
...
#No guardar en el histórico duplicados consecutivos
HISTCONTROL=ignoredups
#No guardar en el histórico comandos sencillos de uso habitual
HISTIGNORE="pwd:ls:ls -lah:date:cd"
...
```

**2-** Crear script (`/usr/local/bin/uso`)

```perl
#!/usr/bin/perl -w
use Cwd 'abs_path';

my ($hst,$tp,$icm,$filter)=(undef,-1,0,0);
while(@ARGV) {
    $_=shift(@ARGV);
    if ($_ =~ /\d+/) {
        $tp=$_;
    } elsif ($_ eq "-c") {
        $icm=1;
    } elsif (-f $_) {
        $hst=$_;
    } else {
        $filter=$_;
    }
}
if ($tp==-1) {$tp=($filter?5:10);}
if (!$hst) {
    $hst="$ENV{HOME}/.bash_history";
}
my $home= abs_path($hst);
$home =~ s/\/[^\/]+$/\//;

sub report_top {
    my( $top_count, %hash ) = @_;
    my @top_commands  = sort { $hash{$b} <=> $hash{$a} } keys %hash;
    my $max_width = length $hash{$top_commands[0]};
    while( my( $i, $value ) = each @top_commands ) {
        last if $i >= $top_count && $top_count>0;
        #printf '%*d %s' . "\n", $max_width, $hash{$top_commands[$i]}, $top_commands[$i];
        print $top_commands[$i] . "\n";
    }
}
sub gFile {
    my $r=shift;
    if (-f $r) {
        return abs_path($r);
    } 
    my $p=index($r,"/");
    if ($p==0) {
        return $r;
    }
    if (-f ($home . $r)) {
        return abs_path(($home . $r));
    }
    if ($p>0) {
        $r=`sudo test -e $r && sudo readlink -f $r || echo 0`;
        chomp($r);
        return $r;
    }
    return undef;
}

open (HISTORY, "<", $hst)  or die "Cannot open $hst: $!";

my $b;
my $cmd;
my @fls;
my %files;
my %cmds;
while ($cmd=<HISTORY>) {
    chomp($cmd);
    $cmd =~ s/  +/ /g;
    $cmd =~ s/(^ +| +$)//g;
    $cmd =~ s/^sudo +//;
    next if length($cmd)<5 || index($cmd," ")<1 || $cmd =~ /(whereis|kill|cd|ls|su|uso) / || ($filter && index($cmd,$filter)==-1);
    $b=($cmd =~ /^(nano|tail|head|cat) /);
    if (!$icm && $b) {
        @fls=split(/ /,$cmd);
        shift(@fls);
        foreach my $fl (@fls) {
            if (index($fl,"/")==0 && $files{$fl}) {$files{$fl}++}
            elsif (($fl=gFile($fl)) && index($fl,$home)!=0) {$files{$fl}++;}
        }
        next;
    }
    if ($icm && !$b) {
        $cmds{$cmd}++;
    }
}
close(HISTORY);

if (keys(%files)) {report_top($tp,%files);}
if (keys(%cmds)) {report_top($tp,%cmds);}
```

**3-** Parámetros

-   por defecto muestra los ficheros más usados
-   con -c muestra los comando más usados
-   parsea el fichero que se le pase, y por defecto el .bash\_history
    del usuario que ejecuta el script
-   si se le pasa una palabra sera usada para filtrar los resultados
-   si se le pasa un número se usara como tope máximo de resultados a
    mostrar (siendo 0 = todos)
-   por defecto se mostraran 5 elementos si se esta filtrando y 10 en
    caso contrario

**4-** Ejemplos de uso (nunca mejor dicho, jeje)

```console
pi@bot ~ $ uso
/var/log/prosody/prosody.log
/usr/local/bin/hf
/usr/local/bin/cmd
/var/log/prosody/prosody.err
/usr/lib/prosody/modules/mod_takenote.lua
/usr/local/bin/atajo
/usr/bin/prosody
/home/bot/HAL/riddim/plugins/hashtag.lua
/root/.centerim/config
/etc/hosts
pi@bot ~ $ uso -c
/etc/init.d/prosody restart
history | hf
atajo prosody
atajo note
cmd a
chmod +x /usr/local/bin/hf
/bin/bash -i -c history
/usr/local/bin/dwn
lua HAL/riddim/init.lua
hg clone http://code.matthewwild.co.uk/verse/ verse
pi@bot ~ $ uso 2
/var/log/prosody/prosody.log
/usr/local/bin/hf
pi@bot ~ $ uso prosody
/var/log/prosody/prosody.log
/var/log/prosody/prosody.err
/usr/lib/prosody/modules/mod_takenote.lua
/usr/bin/prosody
/var/log/prosody/prosody.not
pi@bot ~ $ sudo uso /home/bot/.bash_history -c lua 1
lua riddim/init.lua
```

**4-** Apéndice

`.bash_history` no se actualiza en tiempo real así que si necesitamos que
nuestro script analice hasta el últimisimo comando ejecutado debemos
forzar antes una actualización mediante el comando:

```console
pi@bot ~ $ history -a
```

No integramos la llamada a "history -a" dentro de nuestro script porque
necesita ser ejecutado directamente por el usuario para garantizar que
se actualice su `.bash_history`

Fuente:
[www.learning-perl.com](http://www.learning-perl.com/2013/02/learning-perl-challenge-popular-history-answer/)
