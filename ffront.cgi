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
use Kalliope::Web;
use strict;

my $dbh = Kalliope::DB->connect;
my $fhandle = url_param('fhandle');
my $poet = Kalliope::PersonHome::findByFhandle($fhandle);

#
# Breadcrumbs -------------------------------------------------------------
#

my @crumbs = $poet->getCrumbs(front => 1);

my $page = newAuthor Kalliope::Page (
	                page => 'forside',
			subtitle => $poet->lifespan,
		        nosubmenu => 1,
                  	poet => $poet,
		       	crumbs => \@crumbs );


#
# Hovedmenu for digter ----------------------------------------------
#

my $poetName = $poet->name;
my $HTML;

my @menuStruct = (
      { url => 'fvaerker.pl?', 
	title => 'V�rker', 
	status => $poet->hasWorks,
        desc => "${poetName}s samlede poetiske v�rker",
        icon => 'gfx/icons/works-h48.gif'
                    },{
        url => 'flines.pl?mode=1&', 
	title => 'Digttitler', 
	status => $poet->hasPoems, 
        desc => "Vis titler p� alle digte",
        icon => 'gfx/icons/poem-h48.gif'
                    },{
	url => 'flines.pl?mode=0&', 
	title => 'F�rstelinier', 
	status => $poet->hasPoems,
        desc => "Vis f�rstelinier for samtlige digte",
        icon => 'gfx/icons/poem-h48.gif'
                    },{
	url => 'fsearch.cgi?', 
	title => 'S�gning', 
	status => $poet->hasPoems,
        desc => "S�g i ".$poetName."s tekster",
        icon => 'gfx/icons/search-h48.gif'
                    },{
	url => 'fpop.pl?', 
	title => 'Popul�re digte', 
	status => $poet->hasPoems,
        desc => "Top-10 over mest l�ste $poetName digte i Kalliope",
        icon => 'gfx/icons/pop-h48.gif'
                    },{
	url => 'fvaerker.pl?mode=prosa&', 
	title => 'Prosa', 
	desc => qq|${poetName}s prosatekster|,
	status => $poet->{'prosa'},
        icon => 'gfx/icons/works-h48.gif'
                    },{
	url => 'fpics.pl?', 
	title => 'Portr�tter', 
	status => $poet->{'pics'},
        icon => 'gfx/icons/portrait-h48.gif',
        desc => "Portr�tgalleri for $poetName"
                    },{
	url => 'biografi.cgi?', 
	title => 'Biografi', 
	status => 1,
        desc => qq|En kortfattet introduktion til ${poetName}s liv og v�rk|,
        icon => 'gfx/icons/biography-h48.gif'
                    },{
	url => 'samtidige.cgi?', 
	title => 'Samtid', 
	status => !$poet->isUnknownPoet && $poet->yearBorn ne '?',
        desc => qq|Digtere som udgav v�rker i ${poetName}s levetid|,
        icon => 'gfx/icons/biography-h48.gif'
                    },{
	url => 'henvisninger.cgi?', 
	title => 'Henvisninger', 
	status => $poet->hasHenvisninger, 
        desc => 'Oversigt over tekster som henviser til '.$poetName.'s tekster',
        icon => 'gfx/icons/links-h48.gif'
                    },{
	url => 'flinks.pl?', 
	title => 'Links', 
	status => $poet->{'links'}, 
        desc => 'Henvisninger til andre steder p� internettet, som har relevant information om '.$poetName,
        icon => 'gfx/icons/links-h48.gif'
                    },{
        url => 'fsekundaer.pl?', 
        title => 'Bibliografi', 
        status => $poet->{'primaer'} || $poet->{'sekundaer'},
        desc => $poetName.'s bibliografi',
        icon => 'gfx/icons/secondary-h48.gif'
                    } );

map {$_->{'url'} = $_->{'url'}.'fhandle='.$poet->fhandle} @menuStruct;

$page->addFrontMenu(@menuStruct);

$page->print;

