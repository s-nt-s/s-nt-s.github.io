#!/usr/bin/perl
use WWW::Mechanize;
use DBI;
#http://www.stratos.me/2009/05/writing-a-simple-web-crawler-in-perl/

my $host = "127.0.0.1";
my $database = "spider";
my $username = "spider";
my $password = "spider";

$cnt = DBI->connect("dbi:mysql:$database;$host", $username, $password);

sub init {
	my($cnt) = @_;
    	#$cnt->do("delete from urls;");
	#$cnt->do("delete from data;");
	#$cnt->do("delete from seen;");
    	#$cnt->do("ALTER TABLE urls AUTO_INCREMENT = 1;");
	#$cnt->do("ALTER TABLE data AUTO_INCREMENT = 1;");

	#$cnt->do("INSERT INTO urls(url) VALUES('http://actasmadrid.tomalaplaza.net/');");
	#$cnt->do("INSERT INTO urls(url) VALUES('http://madrid.tomalaplaza.net/');");
	#$cnt->do("INSERT INTO urls(url) VALUES('http://madrid.tomalosbarrios.net/');");
#    	$cnt->do("UPDATE urls SET visited = 0 WHERE visited=2 or visited=3;");
}
sub getTxt {
	my $mech=@_[0];
	my $rst=undef;
	eval {
	if ($mech->content_type() eq "application/pdf") {
		$mech->save_content("/tmp/spider.pdf");
		system("pdftotext /tmp/spider.pdf /tmp/spider.txt");
		open(FILE, "/tmp/spider.txt") or return undef;
		local $/;
		$rst = <FILE>;
		close (FILE);
		unlink("/tmp/spider.txt");
		unlink("/tmp/spider.pdf");
	} elsif ($mech->content_type() eq "application/msword") {
                $mech->save_content("/tmp/spider.doc");
		$rst=qx(catdoc /tmp/spider.doc);
		unlink("/tmp/spider.doc");
	} elsif ($mech->content_type() eq "application/rtf") {
                $mech->save_content("/tmp/spider.rtf");
                $rst=qx(catdoc /tmp/spider.rtf);
                unlink("/tmp/spider.rtf");
        }
	};
	warn $@ if $@;
	return $rst;
}
sub get_url {
	my($cnt,$lastId,$vis) = @_;
	if ($lastId && $vis) {$cnt->do("UPDATE urls SET visited = " . $vis . " WHERE id = " . $lastId . ";");}
	my $stm = $cnt->prepare("SELECT id,url FROM urls WHERE visited = 0 and " . 
"(url like \"%tomalosbarrios%\" or url like \"%tomalaplaza%\") and url not like \"%propongo.tomalaplaza.net%\" and url not like \"%stamariadelaalameda.tomalosbarrios.net%\" LIMIT 1;");
#"url not like \"%tomalosbarrios%\" and " .
#"url not like \"%ruralesenredadxs%\" and url not like \"%tomalatierra%\" and url not like \"%.15m.cc%\" and url not like \"%www.15mmalaga.cc%\" LIMIT 1;");
	$stm->execute();
	my @results=$stm->fetchrow_array();
	if (scalar @results != 2) {return undef;}
    	return @results;
}
sub get_rdr {
	my $mech = WWW::Mechanize->new(autocheck => 0);
	$mech->ssl_opts( 'verify_hostname' => 0 );
	$mech->timeout(30);
	$mech->agent_alias('Windows IE 6');
	my $res=$mech->get(@_[0]);
	my $l;
	my $u;
	my $e=0;
        while (($mech->uri()->host() =~ /^(t\.co|dft\.ba|cli\.gs|v\.gd|nw\.fi)$/) && $res->is_success) {
		if ($mech->uri()->host() eq "v.gd") {
			$l = $mech->find_link(tag => 'a' , class => 'biglink' );
		} elsif ($mech->uri()->host() eq "nw.fi") {
			$l = $mech->find_link(tag => 'a' , class => 'shorturl' );
		} else {
			$l = $mech->find_link(tag => 'a');
		}
		$u=$l->url_abs();
		return if (!($l) || !($l->url()) || !($l->url() =~ /^http/) || no_dom($u->host()) || no_url($u));
		if (!($u->host() =~ /.{2,4}\..{1,2}/) && length($u->as_string)<=255) {
			return $u->canonical();
		}
		return if (($e++)>10);
		$res=$mech->get($u->as_string);
        }
	return if (
		!$res->is_success || 
		no_dom($mech->uri()->host()) || 
		no_url($mech->uri()) ||
		( ($mech->is_html() || ($mech->content_type() eq "text/html")) && !$mech->content() )
	);
	return $mech->uri()->canonical();
}

sub set_url {
	return if (no_url(@_[1]) || no_dom(@_[1]->host()));
	my $u = @_[1]->canonical();
	if (length($u->as_string)>255 || ($u->host() ne "n-1.cc" && $u->host() =~ /.{2,4}\..{1,2}/ && $u->path =~ /^\/[^\/\.]{3,}+$/)) {
		$u=get_rdr($u->as_string);
		return if (!$u || !$u->as_string);
		if (length($u->as_string)>255) {$u->fragment(undef);}
		return if (length($u->as_string)>255);
	}
	if (index($u->as_string,"#!")<8 || ($u->host() eq "foro.tomalosbarrios.net")) {$u->fragment(undef);}
	if ($u->host() =~ /docs\.google\./i && $u->path =~ /^\/(file|drawings|document)\/d\/.+\/edit\/?$/i && !($u->as_string =~ /authkey=/i)) {
		$u->query(undef);
	}
	if ($u->host() eq "foro.tomalosbarrios.net") {
		my %qr=$u->query_form();
		for(keys(%qr)) {
			delete($qr{$_}) unless ($_ eq "f" || $_ eq "t"  || $_ eq "p" || $_ eq "start");
		};
		$u->query_form(%qr);
	}
        eval {
                if ($u->path =~ /^\/201[1-4]\/(0[1-9]|10|11|12)\/([012][0-9]|30|31)\//) {
			$u->query(undef);
			$u->fragment(undef);
		}
        };
	my $url=$u->as_string;
	$url =~ s/^https?:\/\/(https?)\.?\/\//$1:\/\//;
	$url =~ s/#!?$//;
	my $cnt = @_[0];
	my $stm = $cnt->prepare("SELECT id FROM urls WHERE url = \"" . $url . "\";");
	$stm->execute();
	my @results=$stm->fetchrow_array();
	if (scalar @results == 0) {$cnt->do("INSERT INTO urls(url,visited) VALUES(\"". $url ."\",0);");}
	else {$cnt->do("UPDATE urls SET urls.seen=urls.seen+1 where id = " . @results[0]);}
}
sub set_mail {
	my $mail = @_[2];
	return if (index($mail,".")<3 || index($mail,"@")<2 || index($mail,"..")>=0);
	my $cnt = @_[0];
	my $url = @_[1];
	my $ori = @_[3];
	$mail =~ s/^\s*(%20|amp;)\s*|\s*(%20|amp;)\s*$//gi;
	$mail=lc($mail);
	return if (index($mail,"calendar.google.com")>0);
	set_data($cnt,$url,$mail,$ori);
}
sub set_tlf {
	my $cnt = @_[0];
	my $url = @_[1];
	my $tlf = @_[2];
	my $ori = @_[3];
	set_data($cnt,$url,$tlf,$ori);
}
sub set_data {
	my $dat= @_[2];
	$dat =~ s/^\s+|\s+$//g;
	return if (length($dat)>100);
	my $cnt= @_[0];
	my $url= @_[1];
	my $ori= @_[3];
	if ($ori) {$ori =~ s/^\s+|\s+$//g;}
	my $stm = $cnt->prepare("SELECT id FROM data WHERE datum = '" . $dat . "';");
	$stm->execute();
	my @results=$stm->fetchrow_array();
	my $id=$results[0];
	if (undef == $id) {
		$cnt->do("INSERT INTO data(datum) VALUES(\"". $dat ."\")");
		$id=$cnt->last_insert_id(undef, undef, undef, undef);
	}
	$stm = $cnt->prepare("SELECT datum FROM seen WHERE url = '" . $url . "' AND datum = '" . $id . "';");
	$stm->execute();
	@results=$stm->fetchrow_array();
	return if  (scalar @results == 1);
	if ($dat eq $ori || $ori eq '' || undef == $ori) {$cnt->do("INSERT INTO seen(url,datum) VALUES('" . $url . "', '" . $id . "');");}
	else  {$cnt->do("INSERT INTO seen(url,datum,ori) VALUES('" . $url . "', '" . $id . "',\"" . $ori . "\");");}
}

sub redr {
	my($cnt,$uri,$url,$id) = @_;
	return if ($uri->as_string eq $url);
        $uri = $uri->canonical();
	if (index($uri->as_string,"#!")<8) {$uri->fragment(undef);}
	return if ($uri->as_string eq $url);
	if (no_url($uri) || no_dom($uri->host())) {
		$cnt->do("DELETE FROM urls where id= " . $id . ";");
		return 1;
	}
	
	if (length($uri->as_string)>255) {return 0;}

	my $stm = $cnt->prepare("SELECT id FROM urls WHERE url = \"" . $uri->as_string . "\"");
	$stm->execute();
	my @results=$stm->fetchrow_array();
	if (scalar @results == 0) {
		$cnt->do("UPDATE urls SET url=\"" . $uri->as_string . "\" where id= " . $id . ";");
		return 0;
	}

	my $id2=@results[0];
	$stm = $cnt->prepare("SELECT seen FROM urls WHERE id= " . $id . ";");
        $stm->execute();
        @results=$stm->fetchrow_array();
	$cnt->do("UPDATE urls SET urls.seen=urls.seen+1+" . @results[0] . " where id = " . $id2 . ";");
	$cnt->do("DELETE FROM urls where id= " . $id . ";");
	return 1;
}

sub no_url {
	my $u= @_[0];
	if (!($u->scheme =~ /^(http|ftp)s?$/i)) {return 1;}
        my $q;
        eval {
                $q=$u->query;
        };
        if ($@) {
                $q=$u->equery;
        };
        my $p;
        eval {
                $p=$u->path;
        };
        if ($@) {
                $p=$u->epath;
        };
        return 
	((!$p || $p eq "/") && !$q) || 
        $p =~ /\.(mp3|bmp|gif|jpe?g|zip|rar|msi|exe|js|css|ico|png|xml|wmv|vlc|tif|svg|rss|ogg|m3u|lst|swf|pptx?|ical|atom)$/i ||
        $p =~ /(\/share-post\.g|\/wp-login\.php|\/login\.php|error\.php|feed\.php|wp-signup\.php|rss-xml\.php|api\.php)$/i ||
	$p =~ /\/(feeds?\/|embed|xmlrpc|pad\/create|wlwmanifest)/i || 
	$q =~ /action=edit|feed=|replytocom=|=https?%3A%2F%2F|=https?:\/\/|custom-css|action=rsd|showComment=/i || 
        $q =~ /^(pfstyle=wp|openidserver=1|share=|shared=email&msg=fail|utm_source=|utm_medium=)/i ||
        $q =~ /&(preview=true|pfstyle=wp)$/i ||
        $u->path_query =~ /(\/feed|=rss)$/ ||
	$u->path_query =~ /sharer\.php\?u=|load.php\?debug=/i ||
        $u->as_string =~ /\.google\.(es|com).*[\?&]q=|accounts\.google\.com\/servicelogin/i ||
        $u->as_string =~ /^https?:\/\/n-1\.cc.+\bview=.*/i ||
	$u->as_string =~ /\/wiki.*\/index\.php\?title=/i || 
	(
		($u->host() eq "goo.gl" || $u->host() eq "g.co") && $p =~ /^\/(maps|photos)\//
	) || 
	(
		$u->host() eq "n-1.cc" && $p=~ /^\/photos\//
	) || 
	(
		$u->host() eq "twitter.com" && $p=~ /^\/intent\//
	) ||
	(
		$u->host() eq "foro.tomalosbarrios.net" && !($p=~ /^\/(viewtopic|viewforum)\.php/)
	)
	;
}
sub is_lst {
        my $u= @_[0];
        my $q;
        eval {
                $q=$u->query;
        };
        if ($@) {
                $q=$u->equery;
        };
        my $p;
        eval {
                $p=$u->path;
        };
        if ($@) {
                $p=$u->epath;
        };
        return
        $p =~ /\/page\/\d+\/?$/i ||
        $p =~ /^\/(author|tag|type)\/[^\/]+\/?$/i ||
        $p =~ /^\/20\d{2}\/[0-3]\d\/$/ ||
        $p =~ /^\/category\// ||
        $p =~ /^\/search\/label\/.+/i ||
        $p =~ /^\/20\d+_\d+_\d+_archive\.html/i ||
        $q =~ /^(tag|cat|author|paged|autor)=/i ||
        $q =~ /^m=20\d{4}/i;
}

sub no_dom {
	my $h=@_[0];
	return index($h,".")<1 || 
	$h =~ /(vimeo|twitter|youtube|maps\.google|translate\.google|news.google|s\d+\.wp\.com|\.gravatar\.com|draft\.blogger\.com|printfriendly\.com|feedburner|youtu\.be|googleapis|pipes\.yahoo|picasaweb\.google|wikipedia|bambuser|livestream|feeds\.wordpress\.|feedproxy)/i || 
	$h =~ /^(off\.st|j\.gs|www\.blogger\.com|www\.lamarea\.com|www\.publico\.es|www\.rtve\.es|www\.20minutos\.es|www\.elmundo\.es|elpais\.com|www\.kaosenlared\.net|www\.eldiario\.es|www\.diagonalperiodico\.net|www\.lavozdegalicia\.es|madrilonia\.org|www\.abc\.es|periodismohumano\.com|www\.filmaffinity\.com|www\.europapress\.es|www\.diariosur\.es|www\.meneame\.net|www\.intereconomia\.com|ubuntovod\.ru|myanimelist\.net|www\.malagahoy\.es|www\.larazon\.es|www\.ivoox\.com|www\.change\.org|blogs\.publico\.es|www\.clarin\.com|www\.adn\.es|www\.tercerainformacion\.es|twitpic\.com|actuable\.es|www\.laopiniondemalaga\.es|www\.rebelion\.org|www\.ustream\.tv|www\.amazon\.com|www\.elconfidencial\.com|www\.lasexta\.com|www\.mediafire\.com|www\.nodo50\.org|noticias\.lainformacion\.com|fotograccion\.org|www\.cadenaser\.com|www\.cuartopoder\.es|www\.boe\.es|www\.lavanguardia\.com|www\.portalparados\.es|asociacionprensaalmeria\.kactoo\.com|ecodiario\.eleconomista\.es|www\.elplural\.com|www\.elperiodico\.com|www\.menorca\.info|actualidad\.rt\.com|hi\.baidu\.com|primetopia\.co\.uk|turske-serije\.net|www\.yelp\.com|imgur\.com|identi\.ca)$/ ||
	$h =~ /\.elpais.com$/;
}

my @links;
my @rst;
my $url;
my $id;
my $mail;
my $is1;
my $iurl;
my $tlf;
my $aux;
my $ori;
my $content;
my $text;
my $vis;
my $host;
my $b;

my $ct=0;
my $error=-200;

init($cnt);

while(@rst=get_url($cnt,$id,$vis)){
	$id=$rst[0];
	$url=$rst[1];
	$vis=1;

	my $mech = WWW::Mechanize->new(autocheck => 0);
	$mech->ssl_opts( 'verify_hostname' => 0 );
	$mech->timeout(30);
	$mech->agent_alias('Windows IE 6');
	$mech->show_progress(1);
	my $res=$mech->get($url);

	next if (redr($cnt,$mech->uri(),$url,$id));
	if (!$res->is_success) {
		$vis=2;
		if (($error++)>50) {
			if (error<302) {sleep(300);}
			else {die("Demasiados errores seguidos");}
		}
		next;
	}

	$error=0;

	$host=$mech->uri()->host();

	$is1=($host =~ /(asamblea|marea|tomal[ao]|15m|ruralesenredadxs|pah|stopdeshaucios|agitamadrid)/);

	if (is_lst($mech->uri())) {
		$vis=4;
		if ($is1) {
			@links = $mech->find_all_links(tag => 'a', url_regex => qr/^[^#].+/, text_regex => qr/.+/);
			foreach $link (@links) {if (index($link->url_abs()->as_string,$host)>0) {set_url($cnt,$link->url_abs());}}
		}
		next;
	}

	if ($mech->is_html() || ($mech->content_type() eq "text/html")) {
		$content = $mech->content();
		if ($is1 && $content) {
			$aux=0;
			while (($aux<2) && ($content=~ /<h[123]\s+class="(posttitle|post-title|entry-title)/g)) {$aux++}
			if ($aux==1) {
				$content=~ s/^.+<h[123]\s+class="(posttitle|post-title|entry-title)//s;
			} elsif ($aux==2) {
				$vis=5;
				@links = $mech->find_all_links(tag => 'a', url_regex => qr/^[^#].+/, text_regex => qr/.+/);
				foreach $link (@links) {if (index($link->url_abs()->as_string,$host)>0) {set_url($cnt,$link->url_abs());}}
				next;
			}
		}
		$content=~ s/<\?(b|strong|em|i)( [^>]+)?>//gi;
		$text=$mech->text();
	} else {
		$content=getTxt($mech);
		$text=undef;
	}

	if (!$content) {
		$vis=3;
                next;
	}

	while($content =~ /([\+A-Z0-9._%-]+)(@|\s+at\s+|\s+arroba\s+|\s*\(\s*arroba\s*\)\s*|\s*%40\s*)([A-Z0-9.-]+)\.([A-Z]{2,4})/gi){
		next if($4 eq "jpg" || $4 eq "pdf");
		$mail=lc($1 . "@" . $3 . "." . $4);
		set_mail($cnt,$id,$mail,$&);
	}
	while($content =~ /([^>]{0,5})(\+ *)?(\d[\d ]{8,})([^<]{0,5})/gi){
		next if ((length($1)>2 && index($1," ")<0) || (length($4)>2 && index($4," ")<0));
		$ori=$2 . $3;
		$tlf=$2 . $3;
		$tlf=~ s/ +//g;
		$aux=length($tlf);
		if (
			(($aux==9 && ($tlf=~/^[\+967]/)) || ($aux>9 && ($tlf=~/^(\+|00)/))) &&
			(!$text || index($text,$ori)>0 || index($text,$tlf)>0)
		) {
			set_tlf($cnt,$id,$tlf,$ori);
		}
	}

	$b = ($mech->uri()->as_string =~ /\/mailman\/pipermail\//);

	@links = $mech->find_all_links(tag_regex => qr/^(a|i?frame|area)$/, url_regex => qr/^[^#].+/, text_regex => qr/.+/);
	foreach $link (@links) {
		$iurl=$link->url();
		if($iurl =~ /mailto:([^\?]+).*/i){
			$mail=$1;
			$ori=$&;
			$mail=~ s/%40/@/;
			set_mail($cnt,$id,$mail,$ori);
			next;
		}
		if($iurl =~ /tel:([^\?]+).*/i){
			$tlf=$1;
			$ori=$&;
			$tlf=~ s/\s+//g;
			set_mail($cnt,$id,$tlf,$ori);
			next;
		}
		if($iurl =~ /([A-Z0-9._%-]+)(@|%40)([A-Z0-9.-]+\.[A-Z]+)/i) {
                        set_mail($cnt,$id,$2 . "@" . $4,$2 . $3 . $4);
                        next;
		}
		if($b && $link->tag() eq "a" && 
$link->text() =~ /([\+A-Z0-9._%-]+) (en|at) ([A-Z0-9.-]+)\.([A-Z]{2,4})/i) {
        	        $mail=lc($1 . "@" . $3 . "." . $4);
                	set_mail($cnt,$id,$mail,$&);
		}
		if ($is1) {set_url($cnt,$link->url_abs());}
	}
}
