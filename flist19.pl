#!/usr/bin/perl

#Udskriv forfatterne sorteret efter efternavn.
do 'kstdhead.pl';
$LA = $ARGV[0];

do 'flist.ovs';

$0 =~ /\/([^\/]*)$/;
$wheretolinklanguage = $1.'?';


&kheaderHTML('Digtere');

#do 'flist.ovs';

#&kcenterpageheader($ovs2{$LA});


@liste = ();


#Indled kasse til selve teksten
beginwhitebox("Digtere efter f�de�r","","left");

#Indl�s alle navnene
open (IN, "data.$LA/fnavne.txt");
while (<IN>) {
    chop($_);chop($_);
    s/\\//g;
    ($fhandle,$ffornavn,$fefternavn,$ffoedt,$fdoed) = split(/=/);
    push(@liste,"$ffoedt%$fefternavn%$ffornavn%$fhandle%$fdoed") if ($ffoedt);
}
close(IN);

#Udskriv navnene
$last = 0;
$notfirstukendt = 0;
$blocks = ();
$bi = -1;

foreach (sort @liste) {
	@f = split(/%/);
	if ($f[0]-$last >= 25) {
		$last=$f[0]-$f[0]%25;
		$last2=$last+24;
		print "<BR><DIV CLASS=listeoverskrifter>$last-$last2</DIV><BR>";
	}
	if ( ($f[0] eq "?") && ($notfirstukendt == 0) ) {
		print "<BR><SPAN DIV=listeoverskrifter>Ukendt f�de�r</DIV><BR>\n";
		$notfirstukendt=1;
	}
	print "<A HREF=\"fvaerker.pl?".$f[3]."?$LA\">";
	print $f[2]." ".$f[1].' <FONT COLOR="#808080">('.$f[0]."-".$f[4].")</FONT></A><BR>";

}

# Udenfor kategori (dvs. folkeviser, o.l.)
$sth = $dbh->prepare("SELECT * FROM fnavne WHERE sprog=? AND foedt='' ORDER BY fornavn");
$sth->execute($LA);
if ($sth->rows) {
    print "<BR><DIV CLASS=listeoverskrifter>Ukendt digter</DIV><BR>";
    while ($f = $sth->fetchrow_hashref) {
	print '<A HREF="fvaerker.pl?'.$f->{'fhandle'}.'?'.$LA.'">';
	print $f->{'fornavn'}.'</A><BR>';
    }
}



endbox();

&kfooterHTML;
