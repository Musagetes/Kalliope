
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

package Kalliope::Keyword;

use strict ('vars');
use Carp;
use Kalliope::DB;
use Kalliope::Person;
use Kalliope::Poem;

my $dbh = Kalliope::DB->connect;

sub new {
    my ($class,%arg) = @_;
    my $sql;
    $sql = 'id = "'.$arg{'id'}.'"' if defined $arg{'id'};
    $sql = 'ord = "'.$arg{'ord'}.'"' if defined $arg{'ord'};
     my $sth = $dbh->prepare("SELECT * FROM keywords WHERE $sql");
    $sth->execute();
    my $obj = $sth->fetchrow_hashref;
    bless $obj,$class;
    return $obj;
}

sub id {
    return $_[0]->{'id'};
}

sub content {
    return $_[0]->{'beskrivelse'};
}
sub ord {
    return $_[0]->{'ord'};
}
sub title {
    return $_[0]->{'titel'};
}

sub sortString {
    return $_[0]->title;
}

sub clickableTitle {
    my ($self,$lang) = @_;
    return '<A CLASS=green HREF="keyword.cgi?keywordid='.$self->id.'&sprog='.$lang.'">'.$self->title.'</A>';
}

sub linksToKeywords {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT keywords.id  FROM keywords,keywords_relation WHERE keywords_relation.otherid = ? AND keywords_relation.othertype = 'keyword' AND keywords_relation.keywordid = keywords.id ORDER BY keywords.titel");
    $sth->execute($self->id);
    my @list;
    while (my $id = $sth->fetchrow_array) {
         push @list, new Kalliope::Keyword(id => $id);
    }
    return @list;
}

sub linksToPersons {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT keywordid FROM keywords_relation WHERE otherid = ? AND othertype = 'person'");
    $sth->execute($self->id);
    my @list;
    while (my $id = $sth->fetchrow_array) {
         push @list, new Kalliope::Person(fid => $id);
    }
    return @list;
}

sub linksToPoems {
    my ($self,$limit,$LA) = @_;
    my $sth = $dbh->prepare("SELECT DISTINCT d.did FROM digte as d,keywords_relation as k, vaerker as v, fnavne as f, digthits as h WHERE keywordid = ? AND othertype = 'digt' AND otherid = d.did AND v.vid = d.vid AND f.fid = d.fid AND f.sprog = ? AND h.longdid = d.longdid ORDER BY hits DESC ".($limit eq 'all' ? '' : 'LIMIT 5'));
    $sth->execute($self->id,$LA);
    my @list;
    while (my $id = $sth->fetchrow_array) {
         push @list, new Kalliope::Poem(did => $id);
    }
    return @list; 
}

sub smallIcon {
    return '<IMG WIDTH=32 HEIGHT=32 BORDER=0 SRC="gfx/sundial_40.GIF">';
}

1;
