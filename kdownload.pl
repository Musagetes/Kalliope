#!/usr/bin/perl

#  Copyright (C) 1999-2001 Jesper Christensen 
#
#  This script is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this script; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#  Author: Jesper Christensen <jesper@kalliope.org>
#
#  $Id$

do 'kstdhead.pl';

@ARGV = split(/\?/,$ARGV[0]);
chomp($ARGV[0]);
$LA = $ARGV[0];

&kheaderHTML("Kalliope - Download",$LA);

beginwhitebox("Filer","","center");

print "<TABLE CELLPADDING=10><TR><TD ALIGN=center>";
print "<A HREF=\"../../download/kalliope-cgi.tar.gz\">";
print "<IMG SRC=\"../../html/kalliope/gfx/floppy.gif\" BORDER=0></A><BR>";
print "kalliope-cgi.tar.gz<BR>";
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
 $atime,$mtime,$ctime,$blksize,$blocks)
    = stat("../../download/kalliope-cgi.tar.gz");
print "(".&sizeinmegs($size)."MB)</TD>";

print "<TD ALIGN=center>";
print "<A HREF=\"../../download/kalliope-gfx.tar.gz\">";
print "<IMG SRC=\"../../html/kalliope/gfx/floppy.gif\" BORDER=0></A><BR>";
print "kalliope-gfx.tar.gz<BR>";
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
 $atime,$mtime,$ctime,$blksize,$blocks)
    = stat("../../download/kalliope-gfx.tar.gz");
print "(".&sizeinmegs($size)."MB)</TD><TR></TABLE>";

endbox();

print "<BR>";

print "<table align=center border=0 cellpadding=1 cellspacing=0 width=\"75%\"><tr width=\"100%\" ><td bgcolor=#000000>";
print "<TABLE align=center cellspacing=0 cellpadding=15 border=0 bgcolor=ffffff BORDER=5 WIDTH=\"100%\"><TR width=\"100%\" >\n";
print "<TD>";

print <<EOT;
<H1>Vejledning</H1>
Maskineriet bag Kalliope, nemlig koden og al data er frit tilg�ngelig og kan downloades ovenfor. Filerne vil altid indeholde de nyeste �ndringer. Kalliope er programmeret i <A CLASS=green HREF="http://www.perl.com/">Perl</A> og udviklet under operativsystemet <A CLASS=green HREF="http://www.linux.org/">Linux</A>, og afvikles fra en Linux box som k�rer <A CLASS=green HREF="http://www.apache.org/">Apache</A> webserveren.
<BR><BR>
F�lgende er en kort vejledning i hvordan man kan s�tte Kalliope p� en Linux eller anden UNIX computer med en webserver og Perl fortolkeren installeret. Denne distribution af Kalliope best�r af to dele, koden og data samlet i filen <B>kalliope-cgi.tar.gz</B> samt grafikken samlet i filen <B>kalliope-gfx.tar.gz</B>. Udpak tar-arkiverne i dit <B>~/public_html/</B> dir. Opret to tomme dirs med navnene <B>~/public_html/cgi/stat/</B> og <B>~/public_html/cgi/gaestebog/</B> som alle (deriblandt webserveren) har execute og write permissions til. Webserveren skal vide, at filer med <B>.pl</B> extensions er gyldige CGI scripts og at disse m� udf�res fra dit public_html dir. P� min �ske konfigureres dette i Apaches <B>/etc/httpd/conf/access.conf</B>. Dette burde v�re alt, hvad der skal til. 
<BR><BR>
Man burde kunne k�re Kalliope under en webserver til andre operativsystemer, s�som Microsofts berygtede produkter, men det kr�ver nok nogle f� �ndringer hist og her og alle vegne. 
<BR><BR>
Jeg yder <I>ingen</I> support p� Kalliopes kode, og filerne indeholder ikke yderligere vejledning.
<BR><BR><BR>
<H1>GNU Public License</H1>
Kalliopes kildetekst er omfattet af <A CLASS=green HREF="kabout.pl?licence.html?dk">GNU Public License</A>. Dette betyder i korte tr�k, at man m� bruge kildeteksten til hvad man �nsker og at man m� udvikle videre p� Kalliope, s� l�nge at man ogs� selv lader eens �ndringer v�re frit tilg�ngelige samt omfattet af GNU Public License. Man m� endda ogs� tjene penge p� produkter baseret p� Kalliope, s� l�nge kildeteksten forbliver frit tilg�ngelig.

EOT

print "</TD></TR></TABLE>";
print "</td></tr></table>";

&kfooterHTML;

# Tager et tal og smider antal megs tilbage med en decimal.
sub sizeinmegs {
    local($tal)=$_[0] / (1024*1024);
    $tal = sprintf ("%.1f",$tal);
}

