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
use Kalliope;
use Kalliope::Page ();
use Kalliope::Web ();
use CGI ();

my $LA = CGI::url_param('sprog') || 'dk';

my @crumbs;
push @crumbs,[_('Baggrund'),''];

my $page = new Kalliope::Page (
		title => _('Baggrund'),
		lang => $LA,
		crumbs => \@crumbs,
		nosubmenu => 1,
                pagegroup => 'history',
		icon => 'keywords-blue',
                page => 'historyfront'); 

$page->addFrontMenu(&front($LA));
$page->print;


sub front {
    my ($LA) = @_;
    my $accept_language = Kalliope::Internationalization::http_accept_language();


    my @menuStruct = ({ 
        url => "keywordtoc.cgi?sprog=$LA", 
	    title => _('N�gleord'), 
	    status => $accept_language eq 'da',
        desc => _("Litteraturhistoriske skitser og forklaringer af litter�re begreber."),
        icon => 'gfx/icons/keywords-w96.png'
    },{
        url => "dict.cgi", 
	    title => _('Ordbog'), 
	    status => $accept_language eq 'da', 
        desc => _("Forklaringer til sv�re eller us�dvanlige ord som man st�der p� i de �ldre digte."),
        icon => 'gfx/icons/keywords-w96.png'
    },{
	    url => "persons.cgi?list=az", 
	    title => _('Personer'), 
	    status => $accept_language eq 'da',
        desc => _("Litter�rt interessante personer som ikke har skrevet lyrik."),
        icon => 'gfx/icons/portrait-w96.png',
    },{
	    url => "kabout.pl?page=about", 
	    title => _('Om Kalliope'), 
	    status => 1,
        desc => _("Om websitet Kalliope."),
        icon => 'gfx/icons/portrait-w96.png',
    });

    return @menuStruct;
}
