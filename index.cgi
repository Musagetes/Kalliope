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
use CGI ();
use strict;

Kalliope::Server::newHit();

my @randomPagesTitles = ('Digtarkiv'); 

my $rnd = int rand($#randomPagesTitles+1);

my $showAllNews = CGI::param('showall') && CGI::param('showall') eq 'yes' ? 1 : 0;

my @crumbs = (['Velkommen','']);

my $page = new Kalliope::Page (
		title => 'Kalliope - '.$randomPagesTitles[$rnd],
                pagegroup => 'welcome',
		frontpage => 1,
		crumbs => \@crumbs,
		changelangurl => 'poets.cgi?list=az&sprog=XX',
                page => 'news'
           );

$page->addBox ( title => "Sidste nyheder",
                width => '100%',
                coloumn => 0,
                content => &latestNews($showAllNews),
                end => qq|<A HREF="index.cgi?showall=yes"><IMG VALIGN=center BORDER=0 HEIGHT=16 WIDTH=16  SRC="gfx/rightarrow.gif" ALT="Vis gamle nyheder"></A>| );

if (my $dayToday = &dayToday()) {
    $page->addBox ( title => "Dagen idag",
	    width => '100%',
	    coloumn => 1,
	    content => $dayToday,
	    end => '<A HREF="today.cgi"><IMG  HEIGHT=16 WIDTH=16 VALIGN=center BORDER=0 SRC="gfx/rightarrow.gif" ALT="V�lg dato"></A>');
}

my ($sonnetText,$sonnetEnd) = &sonnet;
$page->addBox ( title => "Sonetten p� pletten",
	coloumn => 1,
	width => '100%',
	content => $sonnetText,
	end => $sonnetEnd);
$page->print();

#
# Nyheder --------------------------------------------------------------
#

sub latestNews {
    my $showAllNews = shift;
    my $HTML;
    open (NEWS,"data/news.html");
    foreach my $line (<NEWS>) {
	Kalliope::buildhrefs(\$line);
	if ($showAllNews) {
	    $line =~ s/^\#//;
	    $HTML .= qq|<p align="justify">$line</p>|;
	} elsif ($line =~ /^[^#]/) {
	    $HTML .= qq|<p align="justify">$line</p>|;
	} else {
            last;
        }
    }
    close (NEWS);
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
    my $sth = $dbh->prepare("SELECT otherid FROM keywords_relation,keywords,digte WHERE keywords.ord = 'sonnet' AND keywords_relation.keywordid = keywords.id AND keywords_relation.othertype = 'digt' AND otherid = digte.did AND digte.lang = 'dk' ORDER BY RAND() LIMIT 1");
    $sth->execute();
    my ($did) = $sth->fetchrow_array;
    return ('','') unless $did;
    my $poem = new Kalliope::Poem(did => $did);
    $HTML .= '<SMALL>'.$poem->content(layout => 'plainpoem').'</SMALL>';
    $HTML =~ s/ /&nbsp;/g;
    my $poet = $poem->author;
    $HTML .= '<br><div style="text-align:right"><i><small>'.$poet->name.'</small></i></div>';
    my $title = $poet->name.': �'.$poem->title.'�';
    $END = qq|<A TITLE="$title" HREF="digt.pl?longdid=|.$poem->longdid.qq|"><IMG VALIGN=center BORDER=0 HEIGHT=16 WIDTH=16 SRC="gfx/rightarrow.gif" ALT="$title"></A>|;
    return ($HTML,$END);
}
