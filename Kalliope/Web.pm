#!/usr/bin/perl

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

package Kalliope::Web;

use URI::Escape;
use Image::Size;

sub doubleColumn {
    my $ptr = $_[0];
    my $HTML;
    my @blocks = @$ptr;
    my $total;
    my $subtotal = 0;
    my $columnchanged = 0;

    map { $_->{'count'} += 3 } @blocks;
    map { $total += $_->{'count'} } grep {$_->{'count'}} @blocks;

    my ($left,$right) = (0,0);
    my $minI;
    my $minDiff = $total;
    for ($i = 0; $i <= $#blocks; $i++) {
	$right = $total - $left;
	if (abs ($right-$left) <= $minDiff ) {
            $minDiff = abs ($right-$left);
	    $minI = $i;
	}
        $left += $blocks[$i]->{'count'};
    }
    
    $HTML .= '<TABLE WIDTH="100%" CELLSPACING=0 CELLPADDING=0><TR><TD WIDTH="50%" VALIGN=top><DIV STYLE="padding: 10px">';
    $i = 0;
    foreach $b (@blocks) {
        next unless ($b->{'count'});
	if ($i == $minI && $total > 8) {
	    $columnchanged = 1;
	    $HTML .= '</DIV></TD><TD WIDTH=1 VALIGN=top BGCOLOR="#808080">';
	    $HTML .= '<IMG ALT="" SRC="gfx/trans1x1.gif" BORDER=0 ALT=""></TD>';
	    $HTML .= '<TD WIDTH=10 VALIGN=top>';
	    $HTML .= '<IMG ALT="" SRC="gfx/trans1x1.gif" WIDTH=10 BORDER=0></TD>';
	    $HTML .= '<TD WIDTH="50%" VALIGN=top>';
	    $HTML .= '<DIV STYLE="padding: 10px">';
	}
        $subtotal += $b->{'count'};
	$HTML .= $b->{'head'} || '';
	$HTML .= ($b->{'body'} || '')."<BR>\n";
	$i++;
    }
    $HTML .= '</DIV></TD></TR></TABLE>';
    return $HTML;
}

sub frontMenu {
    my @menuStruct = @_;
    my @activeItems = grep { $_->{'status'} } @menuStruct;
    my $itemsNum = $#activeItems+1;

    my $HTML = '<br><TABLE WIDTH="100%"><TR><TD CLASS="ffront" VALIGN="top" WIDTH="50%">';
    $HTML .= '<TABLE CELLPADDING=2 CELLSPACING=0>';

    my $i = 0;
    foreach my $str (@activeItems) {
	my %item = %{$str};
	my $url = $item{url};
	if ($item{status}) {
	    $HTML .= qq|<TR><TD VALIGN="top" ROWSPAN=2><A HREF="$url"><IMG HEIGHT=48 BORDER=0 SRC="$item{icon}" ALT=""></A></TD>|;
	    $HTML .= qq|<TD CLASS="ffronttitle"><A HREF="$url">$item{title}</A><TD></TR>|;
	    $HTML .= qq|<TR><TD VALIGN="top" CLASS="ffrontdesc">$item{desc}</TD></TR>|;
	    $HTML .= qq|<tr><td></td></tr>|;
	    $HTML .= '</TABLE></TD><TD CLASS="ffront" VALIGN="top" WIDTH="50%"><TABLE CELLPADDING=2 CELLSPACING=0>' if (++$i == int (($itemsNum + 1 )/2 ));
	}
    }
    $HTML .= '</TABLE></TD></TR></TABLE>';
    return $HTML;
}

sub tabbedView {
    my ($selectedId,$body,@tabs) = @_;
    my $HTML;

    # Render tabs
    $HTML = "";
    foreach my $tab (@tabs) {
	$HTML .= qq|<a title="$$tab{'title'}" href="$$tab{'url'}">|;
	$HTML .= $$tab{'id'} eq $selectedId ? "<b>$$tab{'text'}</b>" : $$tab{'text'};
	$HTML .= '</a>.';
    }
    $HTML =~ s/\.$//;

    $HTML .= '<br>'.$body;
    return $HTML;
}

sub insertThumb {
    my $h = shift;
    $h->{'alt'} = '' unless $h->{'alt'};
    my ($tx,$ty) = imagesize ($h->{'thumbfile'});
    my $border = defined $h->{border} ? $h->{border} : 2;
    my $html = '';
    if ($h->{destfile}) {
	my ($dx,$dy) = imagesize ($h->{'destfile'});
	my $winy = $dy+20 < 600 ? $dy+20 : 600;
	my $winx = $dx+30 < 800 ? $dx+30 : 800;
	$html .= qq|<A TITLE="$$h{alt}" HREF="javascript:{}" onclick='window.open("picfull.pl?imgfile=|.uri_escape($h->{destfile}).qq|&x=$dx&y=$dy","popup","toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=$winx,height=$winy")'>|;
    } elsif ($h->{url}) {
	$html .= qq|<A HREF="$h->{url}">|;
    }
    $html .= qq|<IMG WIDTH=$tx HEIGHT=$ty ALT="$h->{alt}" SRC="$h->{thumbfile}" BORDER=$border></A>|;
    return $html;
}

sub imagesize {
    return imgsize(shift);
}


sub linkParse {
    my $text = shift;
    $text =~ s/(\S+)/_linkParse($1)/mge;
    return $text;
}

sub _linkParse {
    my $word = shift;
    if ($word =~ /^www\.\S/i) {
        return '<A class="green" target="farawayontheoutside" href="http://'.$word.'">'.$word.'</A>';
    } elsif ($word =~ /^(http|https|news|ftp):\/\//i) {
        return '<A class="green" target="farawayontheoutside" href="'.$word.'">'.$word.'</A>';
    }
    return $word;
}


1;
