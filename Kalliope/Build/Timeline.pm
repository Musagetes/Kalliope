
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


package Kalliope::Build::Timeline;

use Kalliope::DB;
use Kalliope::Date;
use XML::Twig;
use strict;

my $dbh = Kalliope::DB::connect();
my $sth = $dbh->prepare("INSERT INTO timeline (year,month,day,description,type,eventtype,url,otherid) VALUES (?,?,?,?,?,?,?,?)");

sub build {
    my %persons = @_;
    &create();
    
    # Parse data/events.txt ---------------------------------------

    my $twig = new XML::Twig(keep_encoding => 1);
    $twig->parsefile('../data/events.xml');
    foreach my $event ($twig->root->children('entry')) {
	my $html = $event->first_child('html')->text;
	my $date = $event->{'att'}->{'date'};
	my $type = $event->{'att'}->{'type'};
	my ($y,$m,$d) = (0,0,0);
	if ($date =~ /(\d+)-(\d+)-(\d+)/) {
	    ($y,$m,$d) = ($1,$2,$3);
	} else {
	    $y = $date;
	}
	if ($type eq 'image') {
	    my $src = $event->first_child('src')->text;
	    $sth->execute($y,$m,$d,$html,'picture','history',$src,'');
	} else {
	    $sth->execute($y,$m,$d,$html,'event','history','','');
	}
    }

    # Get published books data ---------------------------------

    my $sthget = $dbh->prepare("SELECT vhandle,f.fhandle,f.fornavn,f.efternavn,v.titel,v.aar FROM fnavne as f,vaerker as v WHERE f.fid = v.fid AND aar != '?'");
    $sthget->execute();

    while (my $h = $sthget->fetchrow_hashref) {
	my $descr = "$$h{fornavn} $$h{efternavn}: <A V=$$h{fhandle}/$$h{vhandle}><I>$$h{titel}</I> ($$h{aar})</A>";
	$sth->execute($$h{aar},0,0,$descr,'event','publish','','');
    }

    # Get author born/dead data --------------------------------
    
    foreach my $k (keys %persons) {
        my $p = $persons{$k};
	my ($y,$m,$d) = Kalliope::Date::splitDate($$p{'bornfull'});
	my $descr = "<A F=$$p{fhandle}>$$p{firstname} $$p{lastname}</A> f�dt";
	$descr .= ', '.$$p{'bornplace'} if $$p{'bornplace'};
	$descr .= '.';
	$sth->execute($y,$m,$d,$descr,'event','born','','');

	my ($y,$m,$d) = Kalliope::Date::splitDate($$p{'deadfull'});
	my $descr = "<A F=$$p{fhandle}>$$p{firstname} $$p{lastname}</A> d�d";
	$descr .= ', '.$$p{'deadplace'} if $$p{'deadplace'};
	$descr .= '.';
	$sth->execute($y,$m,$d,$descr,'event','dead','','');
    }

    # Get persons local events.txt data ----------------------------
    foreach my $k (keys %persons) {
	my $file = "../fdirs/$k/events.xml";
	next unless -e $file;

	my $twig = new XML::Twig(keep_encoding => 1);
	$twig->parsefile($file);
	foreach my $event ($twig->root->children('entry')) {
	    my $html = $event->first_child('html')->text;
	    my $date = $event->{'att'}->{'date'};
	    my $type = $event->{'att'}->{'type'};
	    my ($y,$m,$d) = (0,0,0);
	    if ($date =~ /(\d+)-(\d+)-(\d+)/) {
		($y,$m,$d) = ($1,$2,$3);
	    } else {
		$y = $date;
	    }
	    if ($type eq 'image') {
		my $src = $event->first_child('src')->text;
		$sth->execute($y,$m,$d,$html,'picture','personal',$src,$k);
	    } else {
		$sth->execute($y,$m,$d,$html,'event','personal','',$k);
	    }
	}
    }


    $sthget = $dbh->prepare("SELECT fhandle,fornavn,efternavn,foedt,doed FROM fnavne WHERE foedt != '?'");
    $sthget->execute();

    while (my $h = $sthget->fetchrow_hashref) {
    }

}

sub create {
    $dbh->do("DROP TABLE IF EXISTS timeline");
    $dbh->do("CREATE TABLE timeline ( 
	id int UNSIGNED PRIMARY KEY NOT NULL auto_increment,
    year int,
    month int,
    day int,
    description text,
    type enum ('event','picture'),
    eventtype enum ('history','born','dead','publish','personal'),
    url text,
    otherid varchar(50),
    UNIQUE(id),
    KEY(year) )");
}
