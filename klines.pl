#!/usr/bin/perl

#  Udskriver alle titel-linier for alle forfattere.
#
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

use CGI qw(:standard);
use Kalliope::Page;
use Kalliope::Date;
use Kalliope::DB;
use Kalliope::Sort;
use Kalliope;
use strict;
use utf8;

my $dbh = Kalliope::DB->connect;

my $mode = url_param('mode') || 0;
my $forbogstav = url_param('forbogstav') || 'a';
my $country = Kalliope::Internationalization::country();

my $title = (_('Ordnet efter førstelinie'),_('Ordnet efter digttitel'),_('Mest populære'))[$mode];
my $page = ('poem1stlines','poemtitles','poempopular')[$mode];
my $HTML;

my @crumbs;
push @crumbs,[_('Digte'),"poemsfront.cgi?cn=$country"];
push @crumbs,[$title,''];
push @crumbs,[$forbogstav,''] unless $mode == 2;

my $page = new Kalliope::Page (
	title => _('Digte'),
	titleLink => "poemsfront.cgi?cn=$country",
	subtitle => $title,
	pagegroup => 'poemlist',
	page => $page,
        countrySelector => 1,
	icon => 'poem-turkis',
        lang => $country,
	crumbs => \@crumbs );

my $sth;
if ($mode == 1) {
    $sth = $dbh->prepare("SELECT tititel as titel,d.fhandle,d.longdid,fornavn,efternavn FROM digte as d, fnavne as f, forbogstaver as b WHERE b.forbogstav = ? AND b.type = ? AND b.country = ? AND b.longdid = d.longdid AND d.fhandle = f.fhandle ");
} elsif ($mode == 0) {
    $sth = $dbh->prepare("SELECT foerstelinie,d.fhandle,d.longdid,fornavn,efternavn FROM digte as d, fnavne as f, forbogstaver as b WHERE b.forbogstav = ? AND b.type = ? AND b.country = ? AND b.longdid = d.longdid AND d.fhandle = f.fhandle");
} elsif ($mode == 2) {
    goto POPU;
}

my @f;
$sth->execute($forbogstav, $mode ? 't' : 'f', $country);
unless ($sth->rows) {
    $HTML .= _("Vælg begyndelsesbogstav nedenfor");
} else {
    while (my $f = $sth->fetchrow_hashref) { 
	$f->{'sort'} = $mode ? $f->{'titel'} : $f->{'foerstelinie'};
        push @f,$f;
    }
    foreach my $f (sort { Kalliope::Sort::sort($a,$b) } @f) {
	next unless $f->{'sort'};
	my $tekst = $mode ? $f->{'titel'} : $f->{'foerstelinie'};
	$HTML .= '<p class="digtliste"><A HREF="digt.pl?longdid='.$f->{'longdid'}.'">';
	$HTML .= $tekst;
	$HTML .= '</A><FONT COLOR="#808080"> (';
	$HTML .= $f->{'fornavn'}.' '.$f->{'efternavn'};
	$HTML .= ")</FONT></p>\n";
    }
}

# Bogstav menuen
$sth = $dbh->prepare("SELECT DISTINCT forbogstav FROM forbogstaver WHERE type = ? AND country = ?" );
$sth->execute($mode ? 't': 'f', $country);

my $i = 0;
@f = ();
while ($f[$i] = $sth->fetchrow_hashref) { 
    $f[$i]->{'sort'} = $f[$i]->{'forbogstav'};
    $f[$i]->{'sort'} =~ s/Å/Aa/;
    $i++;
}
my $minimenu = '<small>'._("Vælg begyndelsesbogstav:").'</small><br><br>';
foreach my  $f (sort { Kalliope::Sort::sort($a,$b) } @f) { 
    my $letter = $f->{'forbogstav'};
    my $class = ($letter eq $forbogstav) ? 'framed' : '';
    my $letterForDisplay = $letter eq '.' ? 'Tegn' : $letter;
    $minimenu .= qq|<A CLASS="$class" TITLE="|._("Digte som begynder med %s",$letter).qq|" HREF="klines.pl?mode=$mode&forbogstav=$letter&cn=$country">|;
    $minimenu .= qq|$letterForDisplay</A> |; 
}

$page->addBox ( width=> '80%',
	       coloumn => 0,
                content => $HTML );

$page->addBox( width => 200,
	       coloumn => 1,
	       content => $minimenu);
$page->print;
exit 1;

POPU:

$sth = $dbh->prepare("SELECT fornavn, efternavn, fnavne.fhandle, digte.longdid, digte.linktitel as titel, hits, lasttime FROM digthits,fnavne,digte WHERE digthits.longdid = digte.longdid AND digte.fhandle = fnavne.fhandle AND fnavne.land = ? ORDER BY hits DESC LIMIT 20");
$sth->execute($country);

my $printed;
$HTML = '<TABLE CLASS="oversigt" WIDTH="100%" CELLSPACING=0>';
$HTML .= '<TR><TH>&nbsp;</TH><TH ALIGN="left">'._("Titel").'</TH><TH ALIGN="right">'._("Hits").'</TH><TH ALIGN="right">'._("Senest").'</TH><TR>';
my $i = 0;
while (my $f = $sth->fetchrow_hashref) {
    $printed++;
    my $class = $i++ % 2 ? '' : ' CLASS="darker" ';
    $HTML .= "<TR $class><TD ALIGN=right>$printed.</TD>";
    $HTML .= '<TD><A HREF="digt.pl?longdid='.$f->{'longdid'}.'">'.$f->{titel}.'</A>';
    $HTML .=  '<FONT COLOR="#808080"> ('.$f->{'fornavn'}.' '.$f->{'efternavn'}.')</FONT>';
    $HTML .= '</TD><TD ALIGN="right">';
    $HTML .= $f->{'hits'};
    $HTML .= '</TD><TD ALIGN="right">';
    $HTML .= Kalliope::Date::shortDate($f->{'lasttime'});
    $HTML .= "</TD></TR>";
}
$HTML .= "</TABLE>";

$page->addBox ( width => '80%',
                content => $HTML ); 
$page->print;
