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

use CGI (':standard');
use Kalliope::Person;
use Kalliope::Page;
use strict;

my $fhandle = url_param('fhandle');
my $poet = new Kalliope::Person(fhandle => $fhandle);

#
# Breadcrumbs -------------------------------------------------------------
#

my @crumbs = $poet->getCrumbs;
push @crumbs,['Biografi',''];

my $page = newAuthor Kalliope::Page ( poet => $poet, 
                                      page => 'bio',
				      printer => url_param('printer') || 0,
                                      crumbs => \@crumbs );

#
# Biografi ----------------------------------------------
#
$page->addBox( title => $poet->name.'s biografi',
               width => '80%',
               coloumn => 1,
	       printer => 1,
	       align => 'justify',
	       end => qq|<a title="Udskriftsvenlig udgave" href="biografi.cgi?fhandle=$fhandle&printer=1"><img src="gfx/print.gif" border=0></a>|,
	       content => $poet->bio || '<IMG ALIGN="left" SRC="gfx/excl.gif">Der er endnu ikke forfattet en biografi for '.$poet->name );

$page->print;

