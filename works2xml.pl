#!/usr/bin/perl

#  Konverterer fra den gamle .txt format til v�rker til det
#  nye XML format.
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

use Kalliope::DB;
use CGI qw(:standard);
use Kalliope::Poem ();

my $dbh = Kalliope::DB->connect;

my $sth = $dbh->prepare("SELECT fhandle,vhandle FROM vaerker WHERE findes = 1");
$sth->execute;
while (my $h = $sth->fetchrow_hashref) {
#    convert($h->{'fhandle'},$h->{'vhandle'});
    convert('oehlenschlaeger','1803');
    last;
}


sub convert {
    my ($fhandle,$vhandle) = @_;

    open(FILE,">fdirs/$fhandle/$vhandle.xml");

    my ($vtitel,$vaar,$vhandle,$fid,$vid,$vnoter) = $dbh->selectrow_array("SELECT titel,aar,vhandle,fid,vid,noter,type FROM vaerker WHERE vhandle = '$vhandle' AND fhandle = '$fhandle'");
    my ($ffornavn,$fefternavn,$ffoedt,$fdoed) = $dbh->selectrow_array("SELECT fornavn,efternavn,foedt,doed FROM fnavne WHERE fhandle = '$fhandle'");
    my $sth = $dbh->prepare("SELECT * FROM digte WHERE vid=? AND fid=?");
    $sth->execute($vid,$fid);

    print FILE <<'EOS';
<?xml version="1.0" encoding="ISO-8859-1"?>
EOS
    print FILE "<book>\n";
    print FILE "<head>\n";
    print FILE "<title>".$vtitel."</title>\n";
    print FILE "   <date>".$vaar."</date>\n";
    foreach my $sub (split "\n",$vnoter) {
	print FILE "   <note>".$sub."</note>\n" if $sub;
    }
    print FILE "</head>\n\n";
    print FILE "<content>\n";
    while($d = $sth->fetchrow_hashref) {
	if ($d->{afsnit}) {
	    print FILE "<section><title>".$d->{titel}."</title></section>\n";
	} else {
	    $d->{indhold} =~ s/\n+$/\n/;
	    print FILE '<poem id="'.$d->{longdid}."\">\n";
	    print FILE "   <title>".$d->{titel}."</title>\n";
	    print FILE "   <toc-title>".$d->{toctitel}."</toc-title>\n" if $d->{'toctitel'} && $d->{'toctitel'} ne $d->{'titel'};
	    foreach my $sub (split "\n",$d->{underoverskrift}) {
		print FILE "   <subtitle>$sub</subtitle>\n";
	    }
	    print FILE "   <firstline>".$d->{foerstelinie}."</firstline>\n" if $d->{foerstelinie};
	    $d->{noter} =~ s/<BR>/\n/gi;
	    $d->{noter} = join "\n", map {"<p>$_</p>"} split /\n/,$d->{noter};
            print FILE "<content>\n";
            print FILE $d->{indhold};    
	    print FILE "\n</content>\n</poem>\n\n";
	}
    }
    print FILE "</content>\n</book>\n";
    close (FILE);
}

