##############################################################################
# kheaderHTML
#
# Udskriv header HTML for alle Kalliope siderne. Ie. den venstre bar.
##############################################################################
use DBI;
use URI::Escape;

do 'dbconnect.pl';

$ENV{REQUEST_URI} =~ /([^\/]*)$/;
$request_uri = $1;

#$dbh = DBI->connect("DBI:mysql:kalliope:localhost", "httpd", "" ) or print STDERR ("Connect fejl: $DBI::errstr");
#if ($dbh eq "") { die "Error!"; };


sub kheaderHTML {

unless (defined($wheretolinklanguage)) {
#    $0 =~ /\/([^\/]*)$/;
    $wheretolinklanguage = 'none';
}

$kpagetitel=$_[0];
$LA = ( $_[1] || 'dk') unless (defined($LA));

#do 'kstdhead.ovs';

$0 =~ /([^\/]*)$/;
$file = $1;

if ($file eq 'forfatter') {
   $urlparams = 'sprog='.$LA.'&type=forfatter&fhandle='.$fhandle;
} elsif ($file eq 'hpage.pl') {
    chop $titel;
    $urlparams = 'sprog='.$LA.'&type=hpage&titel='.uri_escape($titel);
} elsif ($file eq 'keyword.cgi' || $file eq 'keywordtoc.cgi' || $file eq 'timeline.cgi') {
    $urlparams = 'sprog='.$LA.'&type=hpage&titel='.uri_escape('N�gleord');
} elsif ($file eq 'kvaerker.pl') {
    $urlparams = 'sprog='.$LA.'&type=kvaerker';
} elsif ($file eq 'flistaz.pl' || $file eq 'flist19.pl' || $file eq 'flistpics.pl' || $file eq 'flistpop.pl' || $file eq 'flistflittige.pl' || $file eq 'flistbios.cgi') {
    $urlparams = 'sprog='.$LA.'&type=flist';
}  elsif ($file eq 'klines.pl') {
    $urlparams = 'sprog='.$LA.'&type=lines';
} elsif ($file eq 'ksearchform.pl' || $file eq 'ksearchresult.pl') {
    $urlparams = 'sprog='.$LA.'&type=search';
} elsif ($file eq 'kstats.pl') {
    $urlparams = 'sprog='.$LA.'&type=stats';
} elsif ($file eq 'kfront.pl' || $file eq 'kabout.pl' || $file eq
'gaestebogvis.pl' || $file eq 'gaestebogedit.pl' || $file eq
'gaestebogsubmit.pl' || $file eq 'kdagenidag.pl') {
    $urlparams = 'sprog='.$LA.'&type=forside';
} elsif ($file eq 'kabout.pl') {
    $urlparams = 'sprog='.$LA.'&type=om';
} else {
    $urlparams = 'sprog='.$LA.'&type=normal&titel='.uri_escape($_[0]);
}

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">';
print "<HTML><HEAD><TITLE>$kpagetitel</TITLE>";
print '<LINK REL=STYLESHEET TYPE="text/css" HREF="kalliope.css">';
print '<META name="description" content="Stort arkiv for �ldre digtning">';
print '<META name="keywords" content="digte, lyrik, litteratur, litteraturhistorie, digtere, digtarkiv, etext, elektronisk tekst, kalliope, kalliope.org, www.kalliope.org">';
print $ekstrametakeywords;
print "</HEAD>\n";
print '<BODY LINK="#000000" VLINK="#000000" ALINK="#000000">';
print <<"EOJ";
<SCRIPT LANGUAGE="Javascript">
  if (!top.IamOK) {
     top.location.href = 'index.cgi?innerframe=' + escape ('$request_uri');
  } else {
     if (this.focus) {
        this.focus();
     }
     if (top.leftframe.changesprog) {
     top.leftframe.changesprog("$LA")
     top.leftframe.changelanguageurl("$wheretolinklanguage")
     }
     myRe = /$urlparams\$/;
     if (!myRe.test(top.topframe.location.href))
     top.topframe.location="topframe.cgi?$urlparams";
  }
</SCRIPT>
EOJ

print '<TABLE CELLPADDING=15 CELLSPACING=0 HEIGHT="100%" BORDER=0 WIDTH="100%">';
print "<TR>";
print "<TD ALIGN=\"center\" VALIGN=\"top\">";

goto kaj;
#
# Language selector
#

beginbluebox ("Sprog","100%","center");
print "<TABLE CELLPADDING=4 ><TR>";

$col1 = $col2 = $col3 = $col4 = '';

$col1 = 'BGCOLOR="#c0c0ff"' if ($LA eq 'dk');
$col2 = 'BGCOLOR="#c0c0ff"' if ($LA eq 'uk');
$col3 = 'BGCOLOR="#c0c0ff"' if ($LA eq 'fr');
$col4 = 'BGCOLOR="#c0c0ff"' if ($LA eq 'de');

print '<TD '.$col1.'><A HREF="'.$wheretolinklanguage.'?dk"><IMG BORDER=0 SRC="../../html/kalliope/gfx/flags/dk.gif"></A></TD>';
print '<TD '.$col2.'><A HREF="'.$wheretolinklanguage.'?uk"><IMG BORDER=0 SRC="../../html/kalliope/gfx/flags/uk.gif"></A></TD>';
print "</TR><TR>";
print '<TD '.$col3.'><A HREF="'.$wheretolinklanguage.'?fr"><IMG BORDER=0 SRC="../../html/kalliope/gfx/flags/fr.gif"></A></TD>';
print '<TD '.$col4.'><A HREF="'.$wheretolinklanguage.'?de"><IMG BORDER=0 SRC="../../html/kalliope/gfx/flags/de.gif"></A></TD>';

print "</TR></TABLE>";
endbox();

kaj:
#Lad n�ste HTML ryge ind i den brede midterste spalte.
print "</TD>";
print '<TD WIDTH="100%">';
#print "<FONT FACE=\"Georgia, Times\" SIZE=3>\n";
};



##################################################################################
# ffooterHTML
#
# Udskriv footer HTML for alle Kalliope siderne, ie. ikke forfattersiderne.
##################################################################################
sub kfooterHTML {
	print "</TD></TR></TABLE>";
#	print "<BR><FONT COLOR=#2020d0>Copyright &copy; 1999 <A CLASS=blue HREF=\"mailto:jesper\@kalliope.org\">Jesper Christensen</A></FONT>";
	print "</BODY></HTML>";
};

####
# Udskriver overskriften for midter afsnit
#

sub kcenterpageheader {
    return;
    print "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\"><tr><td bgcolor=#000000>";
    print "<TABLE align=center cellspacing=0 cellpadding=15 border=0 bgcolor=#e0e0f0 BORDER=5 WIDTH=\"100%\"><TR>";
    print "<TD WIDTH=\"100%\" BORDER=0 VALIGN=center align=center>";
    print "<FONT SIZE=24><I>".$_[0]."</I></FONT>";
    print "</TD></TR></TABLE>";
    print "</td></tr></table><BR>";
}

#######################################
#
# Standard box 
#

sub beginbluebox {
    beginwhitebox(@_);
}

sub beginwhitebox {
    my ($title,$width,$align) = @_;
    my $WIDTH = $width ? qq|WIDTH="$width"| : '';
    print qq|<TABLE $WIDTH ALIGN="center" BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD ALIGN=right>|;
    if ($title) {
	print '<DIV STYLE="position: relative; top: 16px; left: -10px;">';
	print '<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD BGCOLOR=black>';
	print '<TABLE ALIGN=center WIDTH="100%" CELLSPACING=0 CELLPADDING=2 BORDER=0><TR><TD CLASS="boxheaderlayer" BGCOLOR="#7394ad" BACKGROUND="gfx/pap.gif" >';
	print $title;
	print "</TD></TR></TABLE>";
	print "</TD></TR></TABLE>";
	print '</DIV>';
    }
    print '</TD></TR><TR><TD VALIGN=top BGCOLOR=black>';
    print '<TABLE WIDTH="100%" ALIGN=center CELLSPACING=0 CELLPADDING=15 BORDER=0>';
    print '<TR><TD '.($align ? 'ALIGN="'.$align.'"' : '').' BGCOLOR="#e0e0e0" BACKGROUND="gfx/lightpap.gif">';
}

sub beginnotebox {
    my ($title,$width,$align) = @_;
    beginwhitebox('Noter',$width,$align);
    return 1;
}

sub begindarkbluebox {
	print '<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD BGCOLOR=black>';
	print '<TABLE  ALIGN=center WIDTH="100%" CELLSPACING=0 CELLPADDING=5 BORDER=0><TR><TD CLASS="darkblue">';

}

sub enddarkbluebox {
    &endbox();
}

sub endbox {
    if (defined($_[0])) {
	print "</TD></TR></TABLE>";
	print "</TD></TR><TR><TD>";
	print '<DIV STYLE="position: relative; top: -10px; left: 10px;">';
	print '<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD BGCOLOR=black>';
	print '<TABLE WIDTH="100%" CELLSPACING=0 CELLPADDING=2 BORDER=0><TR><TD CLASS="boxheaderlayer" BGCOLOR="#7394ad" BACKGROUND="gfx/pap.gif" >';
	print $_[0];
	print "</TD></TR></TABLE>";
	print "</TD></TR></TABLE>";
	print '</DIV>';
	print '</TD></TR></TABLE>';
    } else {
	print "</TD></TR></TABLE>";
	print "</TD></TR></TABLE>";
    }
}

1;
