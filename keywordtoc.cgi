#!/usr/bin/perl -w

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

use CGI qw /:standard/;
use Kalliope;
use Web;
use strict;
do 'kstdhead.pl';

my $LA = url_param('sprog');

&kheaderHTML("Kalliope - N�gleord",$LA);

&kcenterpageheader("N�gleord");

my @blocks= ();
my $idx;
my $sth = $dbh->prepare("SELECT id,titel FROM keywords ORDER BY titel");
$sth->execute ();
while (my $h = $sth->fetchrow_hashref) {
    $idx = (ord lc substr($h->{'titel'},0,1)) - ord('a');
    $blocks[$idx]->{'head'} = '<DIV CLASS=listeoverskrifter>'.uc (chr $idx + ord('a')).'</DIV><BR>';
    $blocks[$idx]->{'count'}++;
    $blocks[$idx]->{'body'} .= '<A HREF="keyword.cgi?keywordid='.$h->{'id'}.'&sprog='.$LA.'">'.$h->{'titel'}.'</A><BR>';
}
beginwhitebox('N�gleord',"75%","left");
Kalliope::doublecolumn(\@blocks);
endbox();

&kfooterHTML;
