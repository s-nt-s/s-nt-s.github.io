Title: Multimedia en Raspbian desde el terminal
Date: 2013-10-27 23:12
Category: Sistemas
Tags: Linux, Raspberry Pi
Slug: multimedia-en-raspbian


**A) Vídeo**

**1-** Script para lanzar omxplayer con nuestras opciones habituales

```console
pi@bot ~ $ sudo touch /usr/local/bin/play
pi@bot ~ $ sudo chmod 777 /usr/local/bin/play
pi@bot ~ $ sudo nano /usr/local/bin/play
```

```bash
#!/bin/bash

seg=0
sub=""
vid=""
OPTS=""
while (( $# ))
do
        case $1 in
        -s )
                seg=$(($2+$seg))
                shift
        ;;
        -m )
                seg=$((($2 * 60)+$seg))
                shift
        ;;
        -*)
                OPTS="$OPTS $1"
        ;;
        *)
                ext="${2##*.}"
                if [ "$ext" == "srt" ]; then
                        sub="$1"
                else
                        vid="$1"
                fi
        ;;
        esac
        shift
done

if [ "$vid" == "" ] || [ ! -f "$vid" ]; then
        echo "Debe pasar un video como parámetro"
        exit 1
fi

if [ $seg -eq 0 ]; then
        seg=""
else
        seg="--pos ${seg}"
fi
if [ "$sub" == "" ]; then
        sub="${vid%%.*}.srt"
fi
if [ -f  "$sub" ]; then
        sub="--subtitles $sub"
else
        sub=""
fi

# Cambiar opcion local por hdmi si se quiere usar la salida de audio digital
omxplayer -o local --blank --vol -300 ${seg} ${OPTS} ${vid} ${sub}
```

Ejemplos de uso:

```console
pi@bot ~ $ play video.avi
pi@bot ~ $ play video.avi sub.srt
pi@bot ~ $ play -s 10 -m 2 video.avi
```

2- Crear script para buscar vídeos en youtube y meneame, y reproducir
medios online

```console
pi@bot ~ $ sudo apt-get install youtube-dl
...
pi@bot ~ $ sudo youtube-dl -U
...
pi@bot ~ $ sudo touch /usr/local/bin/ytb
pi@bot ~ $ sudo chmod 777 /usr/local/bin/ytb
pi@bot ~ $ sudo nano /usr/local/bin/ytb
```

```perl
#!/usr/bin/perl -w
use XML::Simple;
use LWP::Simple;
use HTML::Entities;
use utf8;                # en este programa hay caracteres escritos en utf8
use open OUT => ':utf8'; # la salida del programa será en utf8
use open ':std';         # la salida STDOUT (el print()) también será en utf8

# Cambiar opcion local por hdmi si se quiere usar la salida de audio digital
my $omx="omxplayer -o local --blank --vol -300";

my $fuente=0;
my $respuesta=0;
my $suerte=0;

sub ask{
        local $| = 1; # activate autoflush to immediately show the prompt
        print "¿Reproducir / Descargar? (r/d): ";
        chomp($respuesta = <STDIN>);
        $respuesta=lc($respuesta);
        return ($respuesta eq "r") || ($respuesta eq "d");
}
sub play {
        my ($url,$cmd) = @_;
        if ($respuesta eq "d") {
                $cmd = "youtube-dl --continue --no-overwrites --restrict-filenames --sub-lang es,en -o '~/Download/%(title)s-%(extractor)s_%(id)s.%(ext)s' " . $url . " --exec '" . $omx . " {}'";
        } else {
                $url =`youtube-dl --max-quality 35 -g "$url"`;
                $url =~ s/^\s+|\s+$//g;
                return if (!$url);
                $cmd= ($omx . " \"" . $url . "\"");
        }
        #print $cmd . "\n";
        exec($cmd) if $suerte == 1;
        system($cmd);
}
sub spc {
        my ($txt) = @_;
        $txt =~ s/\s\s+/ /g;
        $txt =~ s/\.\.+/\./g;
        $txt =~ s/  +/ /g;
        $txt =~ s/^ +| +$//g;
        return $txt;
}

sub cln {
        my ($link,$title,$des) = @_;
        $link=~ s/\&.*//;
        $title = spc($title);
        return ($link,$title) if (!$des);
        $des=decode_entities($des);
        $des =~ s/^.+\/><p>|<\/p>.+$//g;
        $des =~ s/<[^>]+>/ /g;
        $des = spc($des);
        if ($fuente == 0) {
                $des =~ s/^\Q$title\E\s*//ig;
                $des =~ s/\.? *From: .+ Views:[ \d ]+ ratings Time: (\d+:\d+(:\d+)?) .+$//;
                $des =~ s/^ +| +$//g;
                $title= $1 . " - " . $title if ($1);
        }
        return ($link,$title,$des);
}

die "Ha de pasar como mínimo un parametro" unless $#ARGV >=0;

my $url=undef;
my $filtro=undef;
my $lk="link";

while(@ARGV && $ARGV[0] =~ m/^-/) {
        $_=shift(@ARGV);
        if ($_ eq "-m" ) {
                $fuente=1;
        } elsif ($_ eq "-s") {
                $suerte=1;
        } elsif ($_ eq "-d") {
                $respuesta="d";
        }
}
if ($#ARGV == 0 && $ARGV[0] =~ m/^https?:\/\//) {
        $suerte=1;
        play($ARGV[0]);
        die;
}

if ($fuente == 1) {
        $lk="meneame:url";
        if (@ARGV) {
                $url="https://www.meneame.net/rss/search?w=links&p=title&s=published&q=" . join("+",@ARGV);
        } else {
                $url="https://www.meneame.net/rss?q=youtube&w=links&p=url&s=published&h=&o=date";
        }
} else {
        $url="http://gdata.youtube.com/feeds/base/videos?v=2&alt=rss&q=" . join("+",@ARGV);
}

my $content = get($url);
my $xml =XMLin($content, ForceArray => ['item']);

my @r = @{ $xml->{channel}->{item} };

if ($fuente == 1) {
        @r = grep {
                $_->{'meneame:comments'} > 20 &&
                $_->{'meneame:url'} =~/(youtube|vimeo)\.com|youtu\.be/;
        } @r;
}

print "No hay resultados\n" and exit unless (@r);

my $count=0;

foreach my $ult (@r) {
        print "\n" if $count++;
        my ($l,$t,$d) = cln($ult->{$lk}, $ult->{title}, $ult->{description});
        print (($t . "\n" . $d . "\n" . $l . "\n")  =~ s/\n\n+/\n/gr);
        play($l) if $suerte || ask();
}
```

Ejemplos de uso:

```console
pi@bot ~ $ ytb show must go on
04:15 - Queen - 'The Show Must Go On' (Music Video)
The official 'The Show Must Go On' music video. Taken from Queen - 'Innuendo'
http://www.youtube.com/watch?v=4ADh8Fs3YdU
¿Reproducir / Descargar? (r/d): r
Video codec omx-h264 width 352 height 264 profile 66 fps 24.941999
Audio codec aac channels 2 samplerate 44100 bitspersample 16
Subtitle count: 0, state: off, index: 1, delay: 0
V:PortSettingsChanged: 352x264@24.94 interlace:0 deinterlace:0 par:1.00 layer:0
have a nice day ;)
pi@bot ~ $ ytb http://www.youtube.com/watch?v=1hiasK3oE3k
Video codec omx-h264 width 640 height 360 profile 578 fps 25.000000
Audio codec aac channels 2 samplerate 44100 bitspersample 16
Subtitle count: 0, state: off, index: 1, delay: 0
V:PortSettingsChanged: 640x360@25.00 interlace:0 deinterlace:0 par:1.00 layer:0
Stopped at: 00:00:03
have a nice day ;)
pi@bot~ $ ytb -d http://www.youtube.com/watch?v=4ADh8Fs3YdU
[youtube] Setting language
[youtube] Confirming age
[youtube] 4ADh8Fs3YdU: Downloading webpage
[youtube] 4ADh8Fs3YdU: Downloading video info webpage
[youtube] 4ADh8Fs3YdU: Extracting video information
[youtube] 4ADh8Fs3YdU: Encrypted signatures detected.
[youtube] 4ADh8Fs3YdU: Downloading js player vflzDhHvc
[download] Destination: /home/pi/Download/Queen_-_The_Show_Must_Go_On_Music_Video-youtube_4ADh8Fs3YdU.mp4
[download] 100% of 13.13MiB in 00:07
[exec] Executing command: omxplayer -o local --blank --vol -300 '/home/pi/Download/Queen_-_The_Show_Must_Go_On_Music_Video-youtube_4ADh8Fs3YdU.mp4'
Video codec omx-h264 width 352 height 264 profile 66 fps 24.941999
Audio codec aac channels 2 samplerate 44100 bitspersample 16
Subtitle count: 0, state: off, index: 1, delay: 0
V:PortSettingsChanged: 352x264@24.94 interlace:0 deinterlace:0 par:1.00 layer:0
Stopped at: 00:00:01
have a nice day ;)
pi@bot ~ $ ytb -m
Marine sobrevive a un disparo en la cabeza gracias a su casco de kevlar
Vídeo de como un marine sobrevive a un disparo en la cabeza de un francotirador talibán. El disparo se produce en el 0:45.
https://www.youtube.com/watch?v=gBjUv_T9CYU
¿Reproducir / Descargar? (r/d):

Joan March financió a Franco porque en la República solo podía hacer negocios desde la cárcel
"Joan March, los Negocios de la Guerra" es el primer documental que se realiza sobre este personaje misterioso y secreto conocido popularmente como "el banquero de Franco".
https://www.youtube.com/watch?v=K92g9DU2JqM
¿Reproducir / Descargar? (r/d):
```

**Notas**:

-   Si no se contesta nada (pulsar enter sin más) se muestra el próximo
    resultado
-   Si se contesta *d* descarga el video por completo antes de
    reproducir, y si ya estaba descargado usa la copia local
-   Si se llama al comando con el modificador *-m* hace la búsqueda
    sobre meneame.net
-   Si se llama al comando con el modificador *-s* reproduce
    directamente el primer resultado sin preguntar
-   Si se le pasa una url reproduce directamente ese vídeo

**B) Imágenes**

```console
pi@bot ~ $ apt-get install fbi
...
pi@bot ~ $ fbi -a *.jpg
```

**C) Musica**

```console
pi@bot ~ $ sudo apt-get install moc
...
pi@bot ~ $ cd .moc
pi@bot ~/.moc $ cp /usr/share/doc/moc/examples/config.example.gz .
pi@bot ~/.moc $ gzip -d config.example.gz
pi@bot ~/.moc $ mv config.example config
pi@bot ~/.moc $ nano config
```

```
...
Allow24bitOutput        = yes
...
```

```console
pi@bot ~ $ mocp
```

Si no se oye el audio y se quiere usar la salida analogía jack probar
con:

```console
pi@bot ~ $ amixer cset numid=3 1
```

Si el control del volumen por defecto no funciona probar lo siguiente:

```
...
ExecCommand1  = "amixer set PCM 100- > /dev/null" #decrementa 1%
ExecCommand2  = "amixer set PCM 100+ > /dev/null" #incrementa 1%
ExecCommand3  = "amixer set PCM 1000- > /dev/null" #decrementa 10%
ExecCommand4  = "amixer set PCM 1000+ > /dev/null" #incrementa 10%
ExecCommand9  = "amixer cset numid=1 -- 80% > /dev/null" #pone el audio al 80%
ExecCommand10 = "amixer cset numid=1 -- 0% > /dev/null" #pone el audio al 0%
...
```

y usa F1, F2, F3, F4, F9 y F10 para gestionar el volumen.

**BONUS**: Problema con las eñes y tildes en los subtitulos al usar
omxplayer

Comprobamos el tipo de fichero y si es ISO-8859 lo convertimos a utf-8
con iconv

```console
pi@bot ~ $ file sub_ori.srt
sub_ori.srt: ISO-8859 text, with CRLF line terminators
pi@bot ~ $ iconv --from-code=iso-8859-1 --to-code=utf-8 sub_ori.srt -o sub_fix.srt
```

Fuentes: [diverteka](http://www.diverteka.com/?p=899),
[hackingthesystem4fun.blogspot.com.es](http://hackingthesystem4fun.blogspot.com.es/2012/04/ver-imagenes-sin-x-en-una-tty.html),
 [jeffskinnerbox.wordpress.com](http://jeffskinnerbox.wordpress.com/2012/11/15/getting-audio-out-working-on-the-raspberry-pi/), [v1.corenominal.org](http://v1.corenominal.org/howto-setup-moc-music-on-console/),
[www.raspberrypi.org](http://www.raspberrypi.org/forums/viewtopic.php?f=76&t=47711)
