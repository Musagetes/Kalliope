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

package Kalliope::Web;
use DBI;
use URI::Escape;
use Exporter ();
use Kalliope::DB ();

sub kheaderHTML {
    $ENV{REQUEST_URI} =~ /([^\/]*)$/;
    $request_uri = $1;

#unless (defined($wheretolinklanguage)) {
#    $0 =~ /\/([^\/]*)$/;
#    $wheretolinklanguage = 'none';
#}

$kpagetitel=$_[0];
$LA = ( $_[1] || 'dk') unless (defined($LA));
$wheretolinklanguage = $_[2] || 'none';

#do 'kstdhead.ovs';

$0 =~ /([^\/]*)$/;
$file = $1;

if ($file eq 'forfatter') {
   $urlparams = 'sprog='.$LA.'&type=forfatter&fhandle='.$fhandle;
} elsif ($file eq 'hpage.pl') {
    chop $titel;
    $urlparams = 'sprog='.$LA.'&type=hpage&titel='.uri_escape($titel);
} elsif ($file eq 'keyword.cgi') {
    $urlparams = 'sprog='.$LA.'&type=hpage&titel='.uri_escape('N�gleord');
} elsif ($file eq 'kvaerker.pl') {
    $urlparams = 'sprog='.$LA.'&type=kvaerker';
} elsif ($file eq 'flistaz.pl' || $file eq 'flist19.pl' || $file eq 'flistpics.pl' || $file eq 'flistpop.pl' || $file eq 'flistflittige.pl') {
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
#print $ekstrametakeywords;
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
print '<TD WIDTH="100%">';
};

sub kfooterHTML {
	print "</TD></TR></TABLE>";
	print "</BODY></HTML>";
};

#######################################
#
# Standard box 
#

sub makeBox {
    my ($title,$width,$align,$content,$endButton) = @_;
    my $HTML;
    $HTML .= '<TABLE WIDTH="'.$width.'" ALIGN="center" BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD ALIGN=right>';
    if ($title) {
	$HTML .= '<DIV STYLE="position: relative; top: 16px; left: -10px;">';
	$HTML .= '<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD BGCOLOR=black>';
	$HTML .= '<TABLE ALIGN=center WIDTH="100%" CELLSPACING=0 CELLPADDING=2 BORDER=0><TR><TD CLASS="boxheaderlayer" BGCOLOR="#7394ad" BACKGROUND="gfx/pap.gif" >';
	$HTML .= $title;
	$HTML .= "</TD></TR></TABLE>";
	$HTML .= "</TD></TR></TABLE>";
	$HTML .= '</DIV>';
    }
    $HTML .= '</TD></TR><TR><TD VALIGN=top BGCOLOR=black>';
    $HTML .= '<TABLE WIDTH="100%" ALIGN=center CELLSPACING=0 CELLPADDING=15 BORDER=0>';
    $HTML .= '<TR><TD '.($align ? 'ALIGN="'.$align.'"' : '').' BGCOLOR="#e0e0e0" BACKGROUND="gfx/lightpap.gif">';
    $HTML .= $content;
    $HTML .= endbox($endButton);
    return $HTML;
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
    my $sub = shift;
    my $HTML;
    if ($sub) {
	$HTML = "</TD></TR></TABLE>";
	$HTML .= "</TD></TR><TR><TD>";
	$HTML .= '<DIV STYLE="position: relative; top: -10px; left: 10px;">';
	$HTML .= '<TABLE BORDER=0 CELLPADDING=1 CELLSPACING=0><TR><TD BGCOLOR=black>';
	$HTML .= '<TABLE WIDTH="100%" CELLSPACING=0 CELLPADDING=2 BORDER=0><TR><TD CLASS="boxheaderlayer" BGCOLOR="#7394ad" BACKGROUND="gfx/pap.gif" >';
	$HTML .= $sub;
	$HTML .= "</TD></TR></TABLE>";
	$HTML .= "</TD></TR></TABLE>";
	$HTML .= '</DIV>';
	$HTML .= '</TD></TR></TABLE>';
    } else {
	$HTML .= "</TD></TR></TABLE>";
	$HTML .= "</TD></TR></TABLE>";
    }
    return $HTML;
}

sub doubleColumn {
    my $ptr = $_[0];
    my $HTML;
    my @blocks = @$ptr;
    my $total;
    my $subtotal = 0;
    my $columnchanged = 0;

    map { $total += $_->{'count'}+2 } grep {$_->{'count'}} @blocks;

    $HTML .= '<TABLE WIDTH="100%" CELLPADDING=0><TR><TD VALIGN=top>';
    foreach $b (@blocks) {
        next unless ($b->{'count'});
	if (!$columnchanged && $subtotal > $total/2) {
	    $columnchanged = 1;
	    $HTML .= '</TD><TD WIDHT=1 VALIGN=top BGCOLOR=black>';
	    $HTML .= '<IMG SRC="gfx/trans1x1.gif" BORDER=0 ALT=""></TD>';
	    $HTML .= '<TD WIDHT=10 VALIGN=top>';
	    $HTML .= '<IMG SRC="gfx/trans1x1.gif" WIDTH=10 BORDER=0 ALT=""></TD>';
	    $HTML .= '<TD VALIGN=top>';
	}
        $subtotal += $b->{'count'}+2;
	$HTML .= $b->{'head'};
	$HTML .= $b->{'body'}."<BR>";
    }
    $HTML .= '</TD></TR></TABLE>';
    return $HTML;
}

sub insertThumb {
    my $h = shift;
    my ($tx,$ty) = imgsize ($h->{'thumbfile'});
    my $border = defined $h->{border} ? $h->{border} : 2;
    my $html = '';
    if ($h->{destfile}) {
	my ($dx,$dy) = imgsize ($h->{'destfile'});
	$html .= '<A HREF="javascript:{}" onclick=\'window.open("picfull.pl?imgfile='.uri_escape($h->{destfile}).'","popup","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizeable=no,width='.$dx.',height='.$dy.'")\'>';
    } elsif ($h->{url}) {
	$html .= qq|<A HREF="$h->{url}">|;
    }
    $html .= qq|<IMG WIDTH=$tx HEIGHT=$ty ALT="$h->{alt}" SRC="$h->{thumbfile}" BORDER=$border></A>|;
    return $html;
}

sub imgsize {
    my $filename = shift;
    open(IDE,"./jpeggeometry $filename|");
    my ($kaj) = <IDE>;
    close (IDE);
    $kaj =~ /(.*)x(.*)/;
    return ($1,$2);
}


1;
