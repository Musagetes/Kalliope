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

package Kalliope::Page::Print;
@ISA = 'Kalliope::Page';

use strict;

sub addBox {
    my ($self,%args) = @_;

    if ($args{'printer'} != 1) {
	return;
    }

    my $HTML;

    $HTML .= "<h2>".$args{'title'}."</h2>";
    $HTML .= $args{content};
    $self->addHTML($HTML, %args);
}

sub print {
    my $self = shift;
    my $titleForWindow = $self->titleForWindow;
    my $today = Kalliope::Date::longDate(time);
    my $requestURI = $ENV{'HTTP_HOST'}.$ENV{'REQUEST_URI'};

    print $self->_printCookies();
    print "Content-type: text/html\n\n";
    print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">';
    print <<"EOF";
<HTML><HEAD><TITLE>$titleForWindow</TITLE>
<LINK REL="Shortcut Icon" HREF="http://www.kalliope.org/favicon.ico">
<LINK REL=STYLESHEET TYPE="text/css" HREF="print.css">
<META HTTP-EQUIV="Content-Type" content="text/html; charset=iso-8859-1">
<META name="description" content="Stort arkiv for �ldre digtning">
<META name="keywords" content="digte, lyrik, litteratur, litteraturhistorie, digtere, digtarkiv, etext, e-text, elektronisk tekst, kalliope, kalliope.org, www.kalliope.org">
<SCRIPT TYPE="text/javascript">
function openTimeContext(year) {
     window.open('timecontext.cgi?center='+year,'Timecontext','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=400,height=300');
     return false;
}
</SCRIPT>
</HEAD>
<BODY>
<table width="100%"><tr><td width="100%">
<hr noshade size="1">
</td><td>
<h2>www.kalliope.org</h2>
</td><td>
<a href="javascript:{history.go(-1)}"><img align="right" src="gfx/icons/poet-h48.gif" border=0></a>
</td></tr></table>
EOF

    foreach my $colHTML (@{$self->{'coloumns'}}) {
	print $colHTML;
    }

print <<"EOF2";
<hr noshade size="1">
<small>Udskrift af <tt>$requestURI</tt> foretaget $today. Denne tekst m� frit redistribueres.</small>
</body></table>
EOF2

}

1;
