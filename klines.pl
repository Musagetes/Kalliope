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

my $dbh = Kalliope::DB->connect;

my $mode = url_param('mode') || 0;
my $forbogstav = url_param('forbogstav') || 'a';
my $LA = url_param('sprog') || 'dk';

my $title = ('F�rstelinier','Digttitler','Popul�re')[$mode];
my $page = ('poem1stlines','poemtitles','poempopular')[$mode];
my $HTML;

my @crumbs;
push @crumbs,['Digte',''];
push @crumbs,[$title,''];
push @crumbs,[$forbogstav,''] unless $mode == 2;

my $page = new Kalliope::Page (
	title => $title,
	pagegroup => 'poemlist',
	page => $page,
        lang => $LA,
	thumb => 'gfx/open_book_100.GIF',
	crumbs => \@crumbs );

my $sth;
if ($mode == 1) {
    $sth = $dbh->prepare("SELECT titel,fhandle,longdid,fornavn,efternavn FROM digte D, fnavne F, forbogstaver B WHERE B.forbogstav = ? AND B.type = ? AND B.sprog = ? AND B.did = D.did AND D.fid = F.fid");
} elsif ($mode == 0) {
    $sth = $dbh->prepare("SELECT foerstelinie,fhandle,longdid,fornavn,efternavn FROM digte D, fnavne F, forbogstaver B WHERE B.forbogstav = ? AND B.type = ? AND B.sprog = ? AND B.did = D.did AND D.fid = F.fid");
} elsif ($mode == 2) {
    goto POPU;
}

my @f;
$sth->execute($forbogstav,$mode?'t':'f',$LA);
unless ($sth->rows) {
    $HTML .= "V�lg begyndelsesbogstav nedenfor";
} else {
    while (my $f = $sth->fetchrow_hashref) { 
	$f->{'sort'} = $mode ? $f->{'titel'} : $f->{'foerstelinie'};
        push @f,$f;
    }
    foreach my $f (sort { Kalliope::Sort::sort($a,$b) } @f) {
	next unless $f->{'sort'};
	my $tekst = $mode ? $f->{'titel'} : $f->{'foerstelinie'};
	$HTML .= '<A HREF="digt.pl?longdid='.$f->{'longdid'}.'">';
	$HTML .= $tekst;
	$HTML .= '</A><FONT COLOR="#808080"> (';
	$HTML .= $f->{'fornavn'}.' '.$f->{'efternavn'};
	$HTML .= ")</FONT><BR>\n";
    }
}

# Bogstav menuen
$sth = $dbh->prepare("SELECT DISTINCT forbogstav FROM forbogstaver WHERE type = ? AND sprog = ?" );
$sth->execute($mode?'t':'f',$LA);

my $i = 0;
@f = ();
while ($f[$i] = $sth->fetchrow_hashref) { 
    $f[$i]->{'sort'} = $f[$i]->{'forbogstav'};
    $f[$i]->{'sort'} =~ s/�/Aa/;
    $i++;
}
my $minimenu;
foreach my  $f (sort { Kalliope::Sort::sort($a,$b) } @f) { 
    my $letter = $f->{'forbogstav'};
    my $class = ($letter eq $forbogstav) ? 'green' : '';
    $minimenu .= qq|<A CLASS="$class" TITLE="Digte som begynder med $letter" HREF="klines.pl?mode=$mode&forbogstav=$letter&sprog=$LA">|;
    $minimenu .= qq| $letter</A>|; 
}

$page->addBox ( width=> '80%',
                title => $minimenu,
                content => $HTML );
$page->print;
exit 1;

POPU:

$sth = $dbh->prepare("SELECT fornavn, efternavn, fnavne.fhandle, digte.longdid, titel, hits, lasttime FROM digthits,fnavne,digte WHERE digthits.longdid = digte.longdid AND digte.fid = fnavne.fid AND fnavne.sprog=? ORDER BY hits DESC LIMIT 20");
$sth->execute($LA);

my $printed;
$HTML = '<TABLE CLASS="oversigt" WIDTH="100%" CELLSPACING=0>';
$HTML .= '<TR><TH>&nbsp;</TH><TH ALIGN="left">Titel</TH><TH ALIGN="right">Hits</TH><TH ALIGN="right">Senest</TH><TR>';
while (my $f = $sth->fetchrow_hashref) {
    $printed++;
    $HTML .= "<TR><TD ALIGN=right>$printed.</TD>";
    $HTML .= '<TD><A HREF="digt.pl?longdid='.$f->{'longdid'}.'">'.$f->{titel}.'</A>';
    $HTML .=  '<FONT COLOR="#808080"> ('.$f->{'fornavn'}.' '.$f->{'efternavn'}.')</FONT>';
    $HTML .= '</TD><TD ALIGN="right">';
    $HTML .= $f->{'hits'};
    $HTML .= '</TD><TD ALIGN="right">';
    $HTML .= Kalliope::Date::shortDate($f->{'lasttime'});
    $HTML .= "</TD></TR>";
}
$HTML .= "</TABLE>";

$page->addBox ( title => 'Mest popul�re digte',
                width => '80%',
                content => $HTML ); 
$page->print;
