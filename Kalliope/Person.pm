
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

package Kalliope::Person;

use strict ('vars');
use Carp;
use Kalliope::DB ();
use Kalliope::Work ();
use Kalliope::Page ();
use Kalliope::Sort ();
use Kalliope ();

my $dbh = Kalliope::DB->connect;

# Class method
sub exist {
    my $fhandle = shift;
    my $sth = $dbh->prepare("SELECT fhandle FROM fnavne WHERE fhandle = ?");
    $sth->execute($fhandle);
    return $sth->rows;
}

sub fhandle {
    return shift->{'fhandle'};
}

sub fid {
    return shift->{'fid'};
}

sub hasPoems {
    return shift->{'vers'};
}

sub hasWorks {
    return shift->{'workslist'} || '' ne '';
}

sub lang {
    return shift->{'sprog'};
}

sub thumbURI {
    my $self = shift;
    return $self->{'thumb'} ? 'fdirs/'.$self->fhandle.'/thumb.jpg' : '';
}

sub icon {
    my $self = shift;
    return -e 'fdirs/'.$self->fhandle.'/frame.gif' ?
               'fdirs/'.$self->fhandle.'/frame.gif' :
	       'gfx/frames/poet-red.gif';
}

sub hasBio {
    return $_[0]->{'bio'};
}

sub bio {
   my $self = shift;
   my $sth = $dbh->prepare("SELECT biotext FROM fnavne WHERE fhandle = ?");
   $sth->execute($self->fhandle);
   my $bio = $sth->fetchrow_array || '';
   $bio =~ s/<BR>/<BR>&nbsp;&nbsp;&nbsp;&nbsp;/gi;
   Kalliope::buildhrefs(\$bio);
   return $bio;
}

sub getDetailsAsHTML {
    return shift->{'detaljer'} || '';
}

sub lifespan {
   my $self = shift;
   return '' if ($self->isUnknownPoet);
   my $born = $self->yearBorn;
   my $dead = $self->yearDead;
   $dead = 'Ukendt �r' if $dead eq '?';
   if (substr($born,0,2) eq substr($dead,0,2)) {
       $dead = substr($dead,2);
   }
   $born = 'Ukendt �r' if $born eq '?';
   return '(Ukendt levetid)' if $born eq $dead;
   return "($born-$dead)";
}

sub yearBorn {
   return $_[0]->{'foedt'};
}

sub yearDead {
   return $_[0]->{'doed'};
}

sub isUnknownPoet {
   my $self = shift;
   return !($self->yearDead && $self->yearBorn);
}

sub sortString {
   return $_[0]->reversedName;
}

sub name {
   return $_[0]->fornavn.' '.$_[0]->efternavn;
}

sub fornavn {
   return shift->{'fornavn'} || '';
}

sub efternavn {
   return shift->{'efternavn'} || '';
}

sub reversedName {
    my $result = $_[0]->efternavn;
    $result .= $_[0]->fornavn eq '' ? '' : ',&nbsp;'.$_[0]->fornavn;
    return $result;
}

sub bioURI {
    return 'ffront.cgi?fhandle='.$_[0]->fhandle;
}

sub worksURI {
    return 'fvaerker.pl?'.$_[0]->fhandle;
}

sub clickableTitle {
    return $_[0]->clickableNameGreen;
}

sub smallIcon {
     return '<IMG alt="" BORDER=0 HEIGHT=32 WIDTH=32 SRC="gfx/icons/poet-h48.gif">';
}

sub clickableNameBlack {
   my $self = shift;
   return '<A CLASS=black HREF="'.$self->bioURI.'">'.$self->name.'</A>';
}

sub clickableNameGreen {
   my $self = shift;
   return '<A CLASS=green HREF="'.$self->bioURI.'">'.$self->name.'</A>';
}

sub poemCount {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT count(*) FROM digte WHERE fid = ? AND layouttype = 'digt' AND afsnit = 0");
    $sth->execute($self->fid);
    my ($count) = $sth->fetchrow_array;
    return $count;
}

sub concurrentPersons {

}

sub getType {
    return shift->{'type'};
}

sub getCrumbs {
    my ($self,%args) = @_;
    my @crumbs;
    if ($self->getType eq 'person') {
	push @crumbs,['Personer','persons.cgi?list=az'];
    } else {
	push @crumbs,['Digtere','poets.cgi?list=az&amp;sprog='.$self->lang];
    }
    if ($args{'front'}) {
        push @crumbs,[$self->name,''];
    } else {
        push @crumbs,[$self->name,'ffront.cgi?fhandle='.$self->fhandle];
    }
    return @crumbs;
}

sub allVids {
    my $self = shift;
    my $workslist = $self->{'workslist'} || '';
    my @vids = split /,/,$workslist;
    return \@vids;
}

sub allWorks {
    my $self = shift;
    my $fhandle = $self->fhandle;
    my @result;
    map { push @result, new Kalliope::Work('vid' => "$fhandle/$_") } @{$self->allVids};
    return @result;
}

sub poeticalWorks {
    my $self = shift;
    my @works = $self->allWorks();
    my @result;
    foreach my $work (@works) {
	if (!$work->isProse) {
	    push @result, $work;
	}
    }
    return @result;
}

sub proseWorks {
    my $self = shift;
    my @works = $self->allWorks();
    my @result;
    foreach my $work (@works) {
	if ($work->isProse) {
	    push @result, $work;
	}
    }
    return @result;
}

sub hasHenvisninger {
    my $self = shift;
    return $self->{'hashenvisninger'} && $self->{'hashenvisninger'} > 0;
}

sub menu {
    my $self = shift;
    my $page = shift;
    my $poetName = $self->name;
    my %menuStruct = (
       vaerker => { url => 'fvaerker.pl?', 
                    title => 'V�rker', 
                    desc => "${poetName}s samlede poetiske v�rker",
                    status => $self->hasWorks },
       titlelines => { url => 'flines.pl?mode=1&amp;', 
                    title => 'Digttitler', 
                    desc => "Vis titler p� alle digte",
                    status => $self->hasPoems },
       firstlines => { url => 'flines.pl?mode=0&amp;', 
                    title => 'F�rstelinier', 
                    desc => "Vis f�rstelinier for samtlige digte",
                    status => $self->hasPoems },
       search     => { url => 'fsearch.cgi?', 
                    title => 'S�gning', 
                    desc => "S�g i ".$poetName."s v�rker",
                    status => $self->hasPoems },
       popular => { url => 'fpop.pl?', 
                    title => 'Popul�re', 
                    desc => "Top-10 over mest l�ste $poetName digte i Kalliope",
                    status => $self->hasPoems },
       prosa     => { url => 'fvaerker.pl?mode=prosa&amp;', 
                    title => 'Prosa', 
	            desc => qq|${poetName}s prosatekster|,
                    status => $self->{'prosa'} },
       pics      => { url => 'fpics.pl?', 
                    title => 'Portr�tter', 
                    desc => "Portr�tgalleri for $poetName",
                    status => $self->{'pics'} },
       bio       => { url => 'biografi.cgi?', 
                    title => 'Biografi', 
                    desc => qq|En kortfattet introduktion til ${poetName}s liv og v�rk|,
                    status => 1 },
       samtidige => { url => 'samtidige.cgi?', 
                    title => 'Samtid', 
                    desc => qq|Digtere som udgav v�rker i ${poetName}s levetid|,
                    status => !$self->isUnknownPoet && $self->yearBorn ne '?'},
       henvisninger => { url => 'henvisninger.cgi?', 
                    title => 'Henvisninger', 
                    desc => 'Oversigt over tekster, som henviser til '.$poetName.'s tekster',
                    status => $self->hasHenvisninger},
       links     => { url => 'flinks.pl?', 
                    title => 'Links', 
                    desc => 'Henvisninger til andre steder p� internettet, som har relevant information om '.$poetName,
                    status => $self->{'links'} },
       bibliografi => { url => 'fsekundaer.pl?', 
                    title => 'Bibliografi', 
                    desc => $poetName.'s bibliografi',
		    status => $self->{'primaer'} || $self->{'sekundaer'} } );
    my @keys = qw/vaerker titlelines firstlines search popular prosa pics bio samtidige henvisninger links bibliografi/;
    my $HTML;
    my @itemsHTML;
    foreach my $key (@keys) {
	print STDERR "$key fucked" unless $menuStruct{$key};
        my %item = %{$menuStruct{$key}};
        my $url = $item{url}.'fhandle='.$self->fhandle;
        my $title = $key eq $page->{'page'} ?
                    '<b>'.$item{'title'}.'</b>' :
                    $item{'title'};
        push @itemsHTML, qq|<A CLASS="submenu" TITLE="$item{desc}" HREF="$url">$title</A>| if $item{status};
    }
#$HTML = join ' <span class="lifespan">&#149;</span> ',@itemsHTML;
    $HTML = join ' <span class="lifespan">&bull;</span> ',@itemsHTML;
    return $HTML;
}

sub getSearchResultEntry {
    my ($self,$escapedNeedle,@needle) = @_;
    my $content = $self->name;

    foreach my $ne (@needle) {
	$content=~ s/($ne)/\n$1\t/gi;
    }
    $content =~ s/\n/<B>/g;
    $content =~ s/\t/<\/B>/g;
    
    my $HTML = '<IMG ALT="Digter" ALIGN="right" SRC="gfx/icons/poet-h48.gif">';
    $HTML .= '<A CLASS=blue HREF="ffront.cgi?fhandle='.$self->fhandle.qq|">|.$content.qq|</A><BR>|;
    $HTML .= '<SPAN STYLE="color: #a0a0a0">'.$self->lifespan."</SPAN><BR><BR>";
    return $HTML;
}

sub getBiblioEntry {
    my ($self,$bibid) = @_;
    my $sth = $dbh->prepare("SELECT entry FROM biblio WHERE fhandle = ? AND bibid = ?");
    $sth->execute($self->fhandle,$bibid);
    my ($entry) = $sth->fetchrow_array;
    return $entry;
}

sub getBiblioEntryAsString {
    my ($self,$bibid) = @_;
    my $entry = $self->getBiblioEntry($bibid);
    print STDERR "Entry for bibid $bibid doesn't exist!\n" unless $entry;
    $entry =~ s/<.*?>//g;
    return $entry;
    
}

1;

