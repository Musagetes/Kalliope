#!/usr/bin/perl

#Udskriver alle titel-linier for alle forfattere.
use CGI qw (:html :standard);
use Kalliope;

do 'kstdhead.pl';
do 'dk_sort.pl';

$mode = url_param('mode');
$forbogstav = url_param('forbogstav');
$LA = url_param('sprog');

#@ARGV = split(/\?/,$ARGV[0]);
#chop $ARGV[0];
#chop $ARGV[1];
#($mode,$forbogstav,$LA) = @ARGV;

$0 =~ /\/([^\/]*)$/;
$wheretolinklanguage = $1.'?mode='.$mode.'&forbogstav='.$forbogstav.'&sprog=';
&kheaderHTML('Digte',$LA);

if ($mode==1) {
    $sth = $dbh->prepare("SELECT titel,fhandle,longdid,fornavn,efternavn FROM digte D, fnavne F, forbogstaver B WHERE B.forbogstav = ? AND B.type = ? AND B.sprog = ? AND B.did = D.did AND D.fid = F.fid");
} elsif ($mode==0) {
    $sth = $dbh->prepare("SELECT foerstelinie,fhandle,longdid,fornavn,efternavn FROM digte D, fnavne F, forbogstaver B WHERE B.forbogstav = ? AND B.type = ? AND B.sprog = ? AND B.did = D.did AND D.fid = F.fid");
} elsif ($mode ==2) {
    goto POPU;
}

beginwhitebox("","","");
$sth->execute($forbogstav,$mode?'t':'f',$LA);
unless ($sth->rows) {
    print "V�lg begyndelsesbogstav nedenfor";
} else {
    $i=0;
    while ($f[$i] = $sth->fetchrow_hashref) { 
	$f[$i]->{sort} = $mode ? $f[$i]->{titel} : $f[$i]->{foerstelinie};
	$i++; 
    }
    foreach $f (sort dk_sort2 @f) {
	next unless $f->{'sort'};
	$tekst = $mode ? $f->{'titel'} : $f->{'foerstelinie'};
	print '<A HREF="digt.pl?'.$f->{'fhandle'}.'?'.$f->{'longdid'}."?$LA\">";
	print $tekst;
	print '</A><FONT COLOR="#808080"> (';
	print $f->{'fornavn'}.' '.$f->{'efternavn'};
	print ")</FONT><BR>\n";
    }
}

# Bogstav menuen
$sth = $dbh->prepare("SELECT DISTINCT forbogstav FROM forbogstaver WHERE type = ? AND sprog = ?" );
$sth->execute($mode?'t':'f',$LA);

$i=0;
@f = ();
while ($f[$i] = $sth->fetchrow_hashref) { 
    $f[$i]->{'sort'} = $f[$i]->{'forbogstav'};
    $f[$i]->{'sort'} =~ s/�/Aa/;
    $i++;
}
foreach $f (sort dk_sort2 @f) { 
    $color = ($f->{'forbogstav'} eq $forbogstav)?'red':'black';
    $minimenu .= '<A HREF="klines.pl?mode='.$mode.'&forbogstav='.$f->{'forbogstav'}.'&sprog='.$LA.'">';
    $minimenu .= '<FONT COLOR='.$color.'>'; 
    $minimenu .= $f->{'forbogstav'};
    $minimenu .= '</FONT></A> ';
}
endbox($minimenu);
&kfooterHTML;
exit 1;


POPU:
beginwhitebox("Mest popul�re digte","","");
    # Mest popul�re digt
    $sth = $dbh->prepare("SELECT fornavn, efternavn, fnavne.fhandle, digte.longdid, titel, hits, lasttime FROM digthits,fnavne,digte WHERE digthits.longdid = digte.longdid AND digte.fid = fnavne.fid AND fnavne.sprog=? ORDER BY hits DESC LIMIT 20");
    $sth->execute($LA);
    #Print tabellen
    print "<TABLE>";
    print "<TR><TH></TH><TH>Titel</TH><TH>Hits</TH><TH>Senest</TH><TR>\n";
    while ($f = $sth->fetchrow_hashref) {
	$printed++;
	print "<TR><TD ALIGN=right>$printed.</TD>";
	print '<TD><A HREF="digt.pl?'.$f->{'fhandle'}.'?'.$f->{'longdid'}.'?'.$LA.'">'.$f->{titel}.'</A>';
        print  '<FONT COLOR="#808080"> ('.$f->{'fornavn'}.' '.$f->{'efternavn'}.')</FONT>';
	print '</TD><TD ALIGN="right">';
	print $f->{'hits'};
	print '</TD><TD ALIGN="right">';
	print Kalliope::shortdate($f->{'lasttime'});
	print "</TD></TR>";
    }
    print "</TABLE>";
 
endbox();
&kfooterHTML;
