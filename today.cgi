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


use strict;
use CGI qw/:standard/;
use Kalliope::Timeline;
use Kalliope::Date;

my (undef,undef,undef,$dayNow,$monthNow,undef,undef,undef,undef)=localtime(time);
$monthNow++;

my $month = CGI::param('month') || $monthNow;
my $day = CGI::param('day') || $dayNow;

my @monthNames = Kalliope::Date::getMonthNamesLong;

my $title = $month ? "Begivenheder $day. ".lc $monthNames[$month-1] : "Begivenheder idag";
my $HTML = Kalliope::Timeline::getEventsGivenMonthAndDayAsHTML($month,$day);
unless ($HTML) {
    $HTML = '<i>Ingen begivenheder registreret.</i>';
}

my @crumbs = ([$title,'']);

my $page = new Kalliope::Page ( title => $title,
               pagegroup => 'welcome',
	       page => 'today',
	       crumbs => \@crumbs ); 

$page->addBox( width => '75%',
               title => $title,
               content => $HTML );

#
# FORM for selecting date
#

my $selectHTML = '<FORM>';
$selectHTML .= '<SELECT NAME="day">';
foreach my $d (1..31) {
    my $selected = $d == $day ? 'SELECTED' : '';
    $selectHTML .= qq|<OPTION VALUE="$d" $selected>$d</OPTION>|;
}
$selectHTML .= '</SELECT>';

$selectHTML .= '<SELECT NAME="month">';
my $i = 1;
foreach my $m (@monthNames) {
    my $selected = $i == $month ? 'SELECTED' : '';
    $selectHTML .= qq|<OPTION VALUE="$i" $selected>$m</OPTION>|;
    $i++;
}
$selectHTML .= '</SELECT>';

$selectHTML .= '<INPUT TYPE="submit" VALUE=" S�g ">';
$selectHTML .= '</FORM>';

$page->addBox( width => '75%',
	title => 'V�lg anden dato',
               content => $selectHTML );

$page->print;


