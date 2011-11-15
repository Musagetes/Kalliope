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

use Kalliope();
use Kalliope::Poem();
use Kalliope::Page();
use Kalliope::Timeline();
use Kalliope::Server();
use Kalliope::DB;
use CGI ();
use strict;

my $dbh = Kalliope::DB::connect();

Kalliope::Server::newHit();

my @randomPagesTitles = ('Digtarkiv'); 

my $rnd = int rand($#randomPagesTitles+1);

my $showAllNews = CGI::param('showall') && CGI::param('showall') eq 'yes' ? 1 : 0;

my @crumbs = (['Velkommen','']);

my $page = new Kalliope::Page (
		title => 'Kalliope',
		subtitle => $randomPagesTitles[$rnd],
#		rss_feed_url => 'news-feed.cgi',
#		rss_feed_title => 'Seneste nyheder',
		frontpage => 1,
		nosubmenu => 1,
		crumbs => \@crumbs,
		changelangurl => 'poets.cgi?list=az&amp;sprog=XX',
           );

$page->addBox (
                coloumn => 0,
                content => &latestNews($showAllNews),
                end => $showAllNews ? '' : qq|<a class="more" href="index.cgi?showall=yes">L�s gamle nyheder...</a>| );

if (my $dayToday = &dayToday()) {
    $page->addBox ( title => "Dagen idag",
	    coloumn => 1,
	    content => $dayToday,
	    end => '<A class="more" HREF="today.cgi">V�lg anden dato...</A>');
}

my ($sonnetText,$sonnetEnd) = &sonnet;
$page->addBox ( title => "Sonetten p� pletten",
	coloumn => 1,
	content => $sonnetText,
	end => $sonnetEnd);
$page->print();

#
# Nyheder --------------------------------------------------------------
#

sub latestNews {
    my $showAllNews = shift;
    my $HTML;
    my $where = $showAllNews ? "" : "WHERE active = 1";
    my $sth = $dbh->prepare("SELECT entry FROM news $where ORDER BY orderby");
    $sth->execute;
    while (my ($line) = $sth->fetchrow_array) {
	print STDERR $line;
        $HTML .= qq|<p align="justify">$line</p>|;
    }
    return $HTML;
}

#
# Dagen idag ------------------------------------------------------------
#

sub dayToday {
    return Kalliope::Timeline::getEventsGivenMonthAndDayAsHTML();
}

#
# Sonnetten p� pletten --------------------------------------------------
#

sub sonnet {
    my ($HTML,$END);
    my $dbh = Kalliope::DB->connect;
    my $sth = $dbh->prepare("SELECT d.longdid FROM textxkeyword t, digte d WHERE t.keyword = 'sonnet' AND t.longdid = d.longdid AND d.lang = 'dk' ORDER BY RANDOM() LIMIT 1");
    $sth->execute();
    my ($longdid) = $sth->fetchrow_array;
    return ('','') unless $longdid;
    my $poem = new Kalliope::Poem(longdid => $longdid);
    $HTML .= '<small>'.$poem->content(layout => 'plainpoem').'</small>';
    my $poet = $poem->author;
    $HTML .= '<br><div style="text-align:right"><i><small>'.$poet->name.'</small></i></div>';
    my $title = $poet->name.': �'.$poem->linkTitle.'�';
    $END = qq|<A class="more" TITLE="$title" HREF="digt.pl?longdid=|.$poem->longdid.qq|">G� til digtet...</A>|;
    return ($HTML,$END);
}
