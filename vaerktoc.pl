#!/usr/bin/perl -w

#  Indholdsfortegnelse for et v�rk.
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

use CGI qw(:standard);
use Kalliope::Person ();
use Kalliope::DB ();
use Kalliope::Work ();
use Kalliope::Page ();

my $dbh = Kalliope::DB->connect;

my $fhandle = url_param('fhandle');
my $vhandle = url_param('vhandle');

my $poet = new Kalliope::Person ( fhandle => $fhandle);
my $work = new Kalliope::Work ( longvid => $vhandle, fhandle => $fhandle );

my @crumbs;
push @crumbs,['Digtere','poets.cgi?list=az&sprog='.$poet->lang];
push @crumbs,[$poet->name,'ffront.cgi?fhandle='.$poet->fhandle];
push @crumbs,['V�rker','fvaerker.pl?fhandle='.$poet->fhandle];
push @crumbs,[$work->titleWithYear,'vaerktoc.pl?fhandle='.$poet->fhandle.'&vhandle='.$work->vhandle];

my $page = newAuthor Kalliope::Page ( poet => $poet, crumbs => \@crumbs );

my ($vtitel,$vaar,$vid,$noter) = $dbh->selectrow_array("SELECT titel, aar, vid,noter FROM vaerker WHERE vhandle = '$vhandle' AND fhandle = '$fhandle'");

$page->addBox( width => '100%',
               coloumn => 0,
               title => 'V�rker',
               content => &completeWorks($poet,$work)
              );

$page->addBox( width => '80%',
               coloumn => 1,
               content => '<SPAN CLASS=digtoverskrift><I>'.$vtitel."</I> ".(($vaar ne '?')?"($vaar)":'').'</SPAN>'
              );

$page->addBox( width => '80%',
               coloumn => 1,
               title => 'Indhold',
               content => &tableOfContent($work),
               end => qq|<A TITLE="Tilbage til oversigten over v�rker" HREF="fvaerker.pl?fhandle=$fhandle"><IMG VALIGN=center ALIGN=left SRC="gfx/leftarrow.gif" BORDER=0 ALT="Tilbage til oversigten over v�rker"></A>|
              );

if ($work->notes) {
    $page->addBox( width => '100%',
	           coloumn => 2,
                   title => 'Noter',
                   content => &notes($work) );
}

$page->addBox( width => '100%',
	       coloumn => 2,
               align => 'center',
       	       title => 'Formater',
	       content => &otherFormats($poet,$work) );
$page->setColoumnWidths(0,'100%',0);
$page->print;

#
# Generate boxes
#

sub completeWorks {
    my ($poet,$work) = @_;
    $sth = $dbh->prepare("SELECT vhandle,titel,aar,findes FROM vaerker WHERE fhandle=? AND type='v' ORDER BY aar");
    $sth->execute($fhandle);
    while(my $d = $sth->fetchrow_hashref) {
	$HTML .= '<P STYLE="font-size: 12px">';
	if ($d->{'findes'}) {
	    $HTML .= '<A HREF="vaerktoc.pl?fhandle='.$fhandle."&vhandle=".$d->{'vhandle'}.'">';
	} else {
	    $HTML .= '<FONT COLOR="#808080">';
	}
	$aar = ($d->{'aar'} eq "\?") ? '' : '('.$d->{'aar'}.')';
	$myTitel = '<I>'.$d->{'titel'}.'</I> '.$aar;
	$myTitel = b($myTitel) if $d->{'vhandle'} eq $vhandle;
	$HTML .= $myTitel;

	if ($d->{'findes'}) {
	    $HTML .= '</A>';
	} else {
	    $HTML .= '</FONT>';
	}
    }
    return $HTML;
}

sub notes {
    my $work = shift;
    my $HTML;
    my $noter = $work->notes;
    $noter =~ s/<A /<A CLASS=green /g;
    my @noter = split /\n/,$noter;
    foreach (@noter) {
	next unless $_;
	$HTML .= '<IMG WIDTH=48 HEIGHT=48 SRC="gfx/clip.gif" BORDER=0 ALT="Note til �'.$work->title.'�">';
	$HTML .= $_."<BR><BR>";
    }
    return $HTML;
}

sub tableOfContent {
    my $work = shift;
    my $HTML;
    my $sth = $dbh->prepare("SELECT longdid,titel,afsnit,did FROM digte WHERE vid=? ORDER BY vaerkpos");
    $sth->execute($work->vid);
    while(my $d = $sth->fetchrow_hashref) {
	if ($d->{'afsnit'} && !($d->{'titel'} =~ /^\s*$/)) {
	    $HTML .= "<BR><FONT SIZE=+1><I>".$d->{'titel'}."</I></FONT><BR>\n";
	} else {
	    $HTML .= "&nbsp;" x 4;
	    $HTML .= "<A HREF=\"digt.pl?longdid=".$d->{'longdid'}.'">';
	    $HTML .= $d->{'titel'}."</A><BR>\n";
	}
    }
    $sth->finish;
    return $HTML;
}

sub otherFormats {
    my ($poet,$work) = @_;
    my $HTML;
    $HTML .=  '<A TARGET="_top" HREF="downloadvaerk.pl?fhandle='.$poet->fhandle.'&vhandle='.$work->longvid.'&mode=XML"><IMG HEIGHT=48 WIDTH=48 SRC="gfx/floppy.gif" BORDER=0 ALT="�'.$work->title.'� i XML format"></A><BR>XML<BR>';
    $HTML .= '<A TARGET="_top" HREF="downloadvaerk.pl?fhandle='.$poet->fhandle.'&vhandle='.$work->longvid.'&mode=Printer"><IMG HEIGHT=48 WIDTH=48 SRC="gfx/floppy.gif" BORDER=0 ALT="�'.$work->title.'� i printervenligt format"></A><BR>Printer venligt<BR>';
    return $HTML;
}
