
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

package Kalliope::Timeline;

use Kalliope;
use Kalliope::Date;
use Kalliope::DB;

sub getEventsGivenMonthAndDay {
    my ($month,$day) = @_;

    my $dbh = Kalliope::DB::connect();
    my $sth = $dbh->prepare("SELECT * FROM timeline WHERE type = 'event' AND month = ? AND day = ?");
    $sth->execute($month,$day);
    my %result;
    while (my $h = $sth->fetchrow_hashref) {
        $result{$$h{'year'}} = $$h{'description'};
    }
    return %result;
}

sub getEventsGivenMonthAndDayAsHTML {
    my ($month,$day) = @_;
    unless ($month && $day) {
	(undef,undef,undef,$day,$month,undef,undef,undef,undef)=localtime(time);
	$month++;
    }
    my %events = Kalliope::Timeline::getEventsGivenMonthAndDay($month,$day);

    my $HTML;
    foreach my $year (sort keys %events) {
        my $text = $events{$year};
	Kalliope::buildhrefs(\$text);
	$HTML .= qq|<TR><TD CLASS="blue" VALIGN="top">$year</TD><TD>$text</TD></TR>|;
    }
    $HTML = qq|<TABLE>$HTML</TABLE>| if $HTML;

    return $HTML;
}

sub getHistoryInTimeSpan {
    my ($beginYear,$endYear) = @_;

    my $dbh = Kalliope::DB::connect();
    my $sth = $dbh->prepare("SELECT * FROM timeline WHERE type = 'event' AND eventtype = 'history' AND year > ? AND year < ?");
    $sth->execute($beginYear,$endYear);
    my @result;
    while (my $h = $sth->fetchrow_hashref) {
        push @result,{year => $$h{'year'},
	              descr => $$h{'description'}}
    }
    return @result;
}

sub getEventsInYear {
    my $year = shift;
    my $dbh = Kalliope::DB::connect();
    my $sth = $dbh->prepare("SELECT * FROM timeline WHERE type = 'event' AND year = ?");
    $sth->execute($year);
    my @result;
    while (my $h = $sth->fetchrow_hashref) {
        push @result,{year => $$h{'year'},
	              descr => $$h{'description'}}
    }
    return @result;

}

1;
