
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

package Kalliope::Search::Author;
@ISA = qw/ Kalliope::Search /;

use Kalliope::DB;
use URI::Escape;
use strict;

my $dbh = Kalliope::DB->connect;

sub pageTitle {
    my $needle = shift->{'needle'};
    return "S�gning efter �$needle�"
}

sub hasSearchBox {
    return 1;
}

sub poet {
    return shift->{'poet'};
}

sub searchBoxHTML {
    my $self = shift;
    my $needle = $self->needle;
    my $fhandle = $self->poet->fhandle;
    return qq|<FORM METHOD="get" ACTION="fsearch.cgi"><INPUT NAME="needle" VALUE="$needle"><INPUT TYPE="hidden" NAME="fhandle" VALUE="$fhandle"></FORM>|;
}

sub count {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT count(*) FROM haystack WHERE (MATCH titel,hay AGAINST (?) > 0) AND fid = ?");
    $sth->execute($self->needle,$self->poet->fid);
    my ($hits) = $sth->fetchrow_array;
    $self->{'hits'} = $hits;
    return $hits;
}

sub needle {
    return shift->{'needle'};
}

sub splitNeedle {
    my $needle2 = shift->needle;
    $needle2 =~ s/^\s+//;
    $needle2 =~ s/\s+$//;
    $needle2 =~ s/[^a-zA-Z������ ]//g;
    return split /\s+/,$needle2;
}

sub escapedNeedle {
    return uri_escape(shift->needle);
}


sub result {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT id,id_class, MATCH titel,hay AGAINST (?) AS quality FROM haystack WHERE (MATCH titel,hay AGAINST (?) > 0) AND fid = ? ORDER BY quality DESC LIMIT ?,10");
    $sth->execute($self->needle,$self->needle,$self->poet->fid,$self->firstNumShowing);

    print STDERR "Antal:".$sth->rows;
    my @matches;
    while (my $d = $sth->fetchrow_hashref)  {
	push @matches,[$$d{'id'},$$d{'id_class'},$$d{'quality'}];
    }
    $sth->finish();

    return @matches;
}

sub getExtraURLParam {
    my $self = shift;
    return 'needle='.uri_escape($self->needle).'&fhandle='.$self->poet->fhandle;
}

sub scriptName {
    return 'fsearch.cgi';
}

sub log {
    my $self = shift;
    my $remotehost = CGI::remote_host();
    open (FIL,">>../stat/searches.log");
    print FIL localtime()."\$\$".$remotehost."\$\$".$self->needle."\$\$\n";
    close FIL;
}

