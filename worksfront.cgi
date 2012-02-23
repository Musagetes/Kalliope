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

my $country = CGI::url_param('cn') || 'dk';

my @crumbs;
push @crumbs,[_('V�rker'),''];

my $page = new Kalliope::Page (
	title => _('V�rker'),
	lang => $country,
	crumbs => \@crumbs,
        pagegroup => 'worklist',
	nosubmenu => 1,
	icon => 'works-green',
        page => 'worksfront'); 

$page->addFrontMenu(&front($country));
$page->print;


sub front {
    my ($country) = @_;

    my @menuStruct = ({ 
        url => "kvaerker.pl?mode=titel&cn=$country", 
	    title => _('V�rker efter titel'), 
	    status => 1,
        desc => _("V�rker ordnet efter titel"),
        icon => 'gfx/icons/works-w96.png'
    },{
        url => "kvaerker.pl?mode=aar&cn=$country", 
	    title => _('V�rker efter �r'), 
	    status => 1,
        desc => _("V�rker ordnet efter udgivelses�r"),
        icon => 'gfx/icons/works-w96.png'
    },{
        url => "kvaerker.pl?mode=digter&cn=$country", 
	    title => _('V�rker efter digter'), 
	    status => 1,
        desc => _("V�rker grupperet efter digter"),
        icon => 'gfx/icons/works-w96.png'
    },{
        url => "kvaerker.pl?mode=pop&cn=$country", 
	    title => _('Mest popul�re v�rker'), 
	    status => 1,
        desc => _("De mest l�ste v�rker i Kalliope"),
        icon => 'gfx/icons/pop-w96.png'
    });

    return @menuStruct;
}
