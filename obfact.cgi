#!/usr/bin/perl -w

#  Udskriver Kalliopes forside: Nyheder, Dagen idag, Sonnetten p� pletten.
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

use Kalliope::Page();
use Kalliope::DB();

$dbh = Kalliope::DB::connect();
my $sth;

my @crumbs = (['Velkommen',''],
	      ['S�rt','']);

my $page = new Kalliope::Page (
		title => 'Kalliope - s�re facts',
                pagegroup => 'welcome',
		crumbs => \@crumbs,
		changelangurl => 'poets.cgi?list=az&sprog=XX',
                page => 'news'
           );


$HTML = '<h3>S�re facts</h3><ul>';

$val = getVal("SELECT count(*) FROM digte WHERE layouttype = 'digt' AND afsnit != 1");
$val2 = getVal("select count(*) from digte where noter != ''");
$HTML .= "<li>Af Kalliopes $val digte har $val2 en note.";

$val2 = getVal("select id from keywords where ord = 'sonnet'");
$val3 = getVal("select count(*) from keywords_relation where keywordid = $val2 and othertype = 'digt'");
$prc = sprintf("%.0d",($val3/$val)*100);
$HTML .= "<li>Der findes $val3 sonetter i Kalliope, hvilket er $prc% af alle digte.";

$val = getVal("select count(*) from xrefs");
$HTML .= "<li>$val digte har en henvisning til et andet digt.";

$antalpoets = getVal("SELECT count(*) FROM fnavne");
$val2 = getVal("SELECT count(*) FROM fnavne where vers = 1");
$HTML .= "<li>Af de $antalpoets digtere i Kalliope, kan man l�se digte hos de $val2 af dem.";

$val = getVal("select sum(pics) from fnavne");
$HTML .= "<li>Der findes $val portr�tter i Kalliope.";

$val = getVal("SELECT count(*) FROM fnavne where bio != ''");
$HTML .= "<li>Der findes $val biografier i Kalliope.";

$se = getVal("SELECT count(*) FROM fnavne where sprog = 'se'");
$dk = getVal("SELECT count(*) FROM fnavne where sprog = 'dk'");
$no = getVal("SELECT count(*) FROM fnavne where sprog = 'no'");
$uk = getVal("SELECT count(*) FROM fnavne where sprog = 'uk'");
$us = getVal("SELECT count(*) FROM fnavne where sprog = 'us'");
$de = getVal("SELECT count(*) FROM fnavne where sprog = 'de'");
$fr = getVal("SELECT count(*) FROM fnavne where sprog = 'fr'");
$it = getVal("SELECT count(*) FROM fnavne where sprog = 'it'");
$HTML .= "<li>Af de $antalpoets digtere i Kalliope, er de $dk danske, $se svenske, $no norske, $uk engelske, $us amerikanske, $fr franske, $it italienske og $de tyske.";


$val = getVal("select count(*) from vaerker where status = 'complete'");
$val2 = getVal("select count(*) from vaerker");
$val3 = getVal("select count(*) from vaerker where findes = 1");
$HTML .= "<li>Af de $val2 v�rker som Kalliope kender til, har $val3 indhold og  $val er komplette.";

$val = sprintf ("%.0d",getVal("select avg(doed-foedt) from fnavne"));
$HTML .= "<li>Digterne blev i gennemsnit $val �r gamle.";

$HTML .= '</ul>';

$page->addBox( content => $HTML );
$page->print();


sub getVal {
    my ($sql,@arg) = shift;
    my $sth = $dbh->prepare($sql);
    $sth->execute(@arg);
    my ($val) = $sth->fetchrow_array();
    return $val;
}


    
