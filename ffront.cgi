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

use Kalliope;
use CGI (':standard');
use Kalliope::Person;
use Kalliope::Page;
use strict;

my $dbh = Kalliope::DB->connect;
my $fhandle = url_param('fhandle');
my $poet = new Kalliope::Person(fhandle => $fhandle);

#
# Breadcrumbs -------------------------------------------------------------
#

my @crumbs;
push @crumbs,['Digtere','poets.cgi?list=az&sprog='.$poet->lang];
push @crumbs,[$poet->name,'ffront.cgi?fhandle='.$poet->fhandle];

my $page = newAuthor Kalliope::Page ( poet => $poet, crumbs => \@crumbs );

#
# Hovedmenu for digter ----------------------------------------------
#

my $poetName = $poet->name;

my $HTML;
my %menuStruct = (
	vaerker => { url => 'fvaerker.pl?', 
	title => 'V�rker', 
	status => $poet->{'vaerker'},
        desc => "${poetName}s samlede poetiske v�rker",
        icon => 'gfx/books_40.GIF'
                    },
	titlelines => { url => 'flines.pl?mode=1&', 
	title => 'Digttitler', 
	status => $poet->{'vers'}, 
        desc => "Vis titler p� alle digte",
        icon => 'gfx/open_book_40.GIF'
                    },
	firstlines => { url => 'flines.pl?mode=0&', 
	title => 'F�rstelinier', 
	status => $poet->{'vers'},
        desc => "Vis f�rstelinier for samtlige digte",
        icon => 'gfx/open_book_40.GIF'
                    },
	popular => { url => 'fpop.pl?', 
	title => 'Popul�re digte', 
	status => $poet->{'vers'},
        desc => "Top-10 over mest l�ste $poetName digte i Kalliope",
        icon => 'gfx/heart.gif'
                    },
	prosa     => { url => 'fprosa.pl?', 
	title => 'Prosa', 
	status => $poet->{'prosa'},
        icon => 'gfx/books_40.GIF'
                    },
	pics      => { url => 'fpics.pl?', 
	title => 'Portr�tter', 
	status => $poet->{'pics'},
        icon => 'gfx/staffeli_40.GIF',
        desc => 'Se giraffen'
                    },
	bio       => { url => 'biografi.cgi?', 
	title => 'Biografi', 
	status => $poet->{'bio'},
        desc => qq|En kortfattet introduktion til ${poetName}s liv og v�rk|,
        icon => 'gfx/poet_40.GIF'
                    },
	samtidige => { url => 'samtidige.cgi?', 
	title => 'Samtidige', 
	status => 1,
        desc => qq|Digtere som udgav v�rker i ${poetName}s levetid|,
        icon => 'gfx/poet_40.GIF'
                    },
	links     => { url => 'flinks.pl?', 
	title => 'Links', 
	status => $poet->{'links'}, 
        desc => 'Henvisninger til andre steder p� internettet, som har relevant information om '.$poetName,
        icon => 'gfx/ikon09.gif'
                    },
        sekundaer => { url => 'fsekundaer.pl?', 
        title => 'Sekund�rlitteratur', 
        status => $poet->{'sekundaer'},
        desc => 'Henvisninger til sekund�rlitteratur om '.$poetName,
        icon => 'gfx/poet_40.GIF'
                    } );

my @keys = qw/vaerker titlelines firstlines popular prosa pics bio samtidige links sekundaer/;

my @activeItems = grep {$_->{status} } map {$menuStruct{$_} } (keys %menuStruct);
my $itemsNum = $#activeItems+1;

$HTML = '<TABLE WIDTH="100%"><TR><TD CLASS="ffront" VALIGN="top" WIDTH="50%">';

my $i = 0;
foreach my $key (@keys) {
    my %item = %{$menuStruct{$key}};
    my $url = $item{url}.'fhandle='.$poet->fhandle;
    if ($item{status}) {
	$HTML .= qq|<TABLE CELLPADDING=2 CELLSPACING=0><TR><TD VALIGN="top" ROWSPAN=2><IMG HEIGHT=40 BORDER=0 SRC="$item{icon}"></TD>|;
	$HTML .= qq|<TD CLASS="ffronttitle"><A HREF="$url">$item{title}</A><TD></TR>|;
        $HTML .= qq|<TR><TD CLASS="ffrontdesc">$item{desc}</TD></TR></TABLE>|;
	$HTML .= '</TD><TD CLASS="ffront" VALIGN="top" WIDTH="50%">' if (++$i == int $itemsNum/2);
    }
}
$HTML .= '</TD></TR></TABLE>';

$page->addBox( width => '80%',
	coloumn => 1,
	content => $HTML );

$page->print;

