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
use Kalliope::Page ();
use Kalliope::Web ();
use CGI ();

my $LA = CGI::url_param('sprog') || 'dk';

my @crumbs;
push @crumbs,['V�rker',''];

my $page = new Kalliope::Page (
		title => 'V�rker',
		lang => $LA,
		crumbs => \@crumbs,
        pagegroup => 'worklist',
		nosubmenu => 1,
		icon => 'works-green',
        page => 'worksfront'); 

$page->addFrontMenu(&front($LA));
$page->print;


sub front {
    my ($LA) = @_;

    my @menuStruct = ({ 
        url => "kvaerker.pl?mode=titel&sprog=$LA", 
	    title => 'V�rker efter titel', 
	    status => 1,
        desc => "V�rker ordnet efter titel",
        icon => 'gfx/icons/works-w96.png'
    },{
        url => "kvaerker.pl?mode=aar&sprog=$LA", 
	    title => 'V�rker efter �r', 
	    status => 1,
        desc => "V�rker ordnet efter udgivelses�r",
        icon => 'gfx/icons/works-w96.png'
    },{
        url => "kvaerker.pl?mode=digter&sprog=$LA", 
	    title => 'V�rker efter digter', 
	    status => 1,
        desc => "V�rker grupperet efter digter",
        icon => 'gfx/icons/works-w96.png'
    },{
        url => "kvaerker.pl?mode=pop&sprog=$LA", 
	    title => 'Mest popul�re v�rker', 
	    status => 1,
        desc => "De mest l�ste v�rker i Kalliope",
        icon => 'gfx/icons/pop-w96.png'
    });

    return @menuStruct;
}
