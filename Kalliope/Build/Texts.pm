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

package Kalliope::Build::Texts;
    
use XML::Twig;
use Kalliope::DB;
use Kalliope::Date;
use strict;

my $dbh = Kalliope::DB::connect();
my $sthGroup = $dbh->prepare("INSERT INTO digte (did,longdid,fhandle,parentdid,linktitel,toptitel,toctitel,tititel,foerstelinie,indhold,vaerkpos,vid,type,underoverskrift,lang,createtime,quality) VALUES (nextval('seq_digte_vid'),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
my $sthseqval = $dbh->prepare("SELECT currval('seq_digte_vid')");
my $sthnote = $dbh->prepare("INSERT INTO textnotes (longdid,note,orderby,vid) VALUES (?,?,?,?)");
my $sthpicture = $dbh->prepare("INSERT INTO textpictures (longdid,caption,url,orderby) VALUES (?,?,?,?)");
my $sthkeyword = $dbh->prepare("INSERT INTO textxkeyword (longdid,keyword) VALUES (?,?)");
my $sthclean = $dbh->prepare("DELETE FROM digte WHERE vid = ?");
my $orderby;

sub clean {
    my ($fhandle,$vhandle) = @_;
    $sthclean->execute("$fhandle/$vhandle");
}

sub insert {
    my $sthselect = $dbh->prepare("SELECT fhandle,vhandle,vid,lang FROM vaerker WHERE dirty = 1");
    $sthselect->execute;
    my $sthupdate = $dbh->prepare("UPDATE vaerker SET dirty = 0 WHERE fhandle = ? AND vhandle = ?");
    my $orderby = 0;
    while (my ($fhandle,$vhandle,$vid,$lang) = $sthselect->fetchrow_array) {
	clean($fhandle,$vhandle);
	my $filename  = "../fdirs/$fhandle/$vhandle.xml";
	print "           Inserting body $filename\n";
	my $twig = new XML::Twig(keep_encoding => 1,
		                 keep_spaces_in => ['body']);
	$twig->parsefile($filename);
	my $kalliopework = $twig->root;
	if ($kalliopework->first_child('workbody')) {
	    _insertGroup($fhandle,$vid,$lang,undef,$kalliopework->first_child('workbody')->children);
	}
	$sthupdate->execute($fhandle,$vhandle);
    }
}

sub _insertGroup {
    my ($fhandle,$vid,$lang,$parent,@nodes) = @_;
    foreach my $node (@nodes) {
 	my $head = $node->first_child('head');
	my $linktitle = $head->first_child('linktitle') ? $head->first_child('linktitle')->text : undef;
	my $toctitle = $head->first_child('toctitle') ? $head->first_child('toctitle')->sprint(1): undef;
	my $toptitle = $head->first_child('title') ? $head->first_child('title')->text : undef;
	$linktitle = $toptitle;
	my $indextitle = $head->first_child('indextitle') ? $head->first_child('indextitle')->text : undef;
	my $quality = $head->first_child('quality') ? $head->first_child('quality')->text : undef;
	my $longdid = $node->id;
	my $subtitle;
	if ($head->first_child('subtitle')) {
	    if ($head->first_child('subtitle')->first_child('line')) {
	        my @lines;
		foreach my $line ($head->first_child('subtitle')->children) {
		    push @lines,$line->text;
		}
		$subtitle = join "\n",@lines;
	    } else {
		$subtitle = $head->first_child('subtitle')->text;
	    }
	}

	my $type = $node->tag;
	if ($type eq 'section' || $type eq 'group') {
	    $sthGroup->execute($longdid,$fhandle,$parent,$linktitle,$toptitle,$toctitle,$indextitle,'','',$orderby++,$vid,$type,$subtitle,$lang,_createtime($longdid),$quality);
	    doDepends($head,$longdid,$vid);
	    $sthseqval->execute();
	    my ($newparent) = $sthseqval->fetchrow_array;
	    _insertGroup($fhandle,$vid,$lang,$newparent,$node->first_child('content')->children);
	} else {
	    my $longdid = $node->id;
 	    my $body = $node->first_child('body');
 	    my $firstline = $head->first_child('firstline') ? $head->first_child('firstline')->text : '';
	    $sthGroup->execute($longdid,$fhandle,$parent,$linktitle,$toptitle,$toctitle,$indextitle,$firstline,$body->xml_string,$orderby++,$vid,$type,$subtitle,$lang,_createtime($longdid),$quality);
	    doDepends($head,$longdid,$vid);
	}

    }
}

	sub doDepends {
	    my ($head,$longdid,$vid) = @_;
	if ($head->first_child('notes')) {
	   my $i = 1;
           foreach my $note ($head->first_child('notes')->children('note')) {
   	       $sthnote->execute($longdid,$note->xml_string,$i++,$vid);
  	   }
	}
	if ($head->first_child('pictures')) {
	   my $i = 1;
           foreach my $pic ($head->first_child('pictures')->children('picture')) {
	       my $src = $pic->{'att'}->{'src'};
   	       $sthpicture->execute($longdid,$pic->xml_string,$src,$i++);
  	   }
	}
	if ($head->first_child('keywords')) {
           foreach my $key (split ',',$head->first_child('keywords')->text) {
   	       $sthkeyword->execute($longdid,$key);
  	   }
	}

	}

sub create {
    $dbh->do(q/DROP SEQUENCE seq_digte_vid/);
    $dbh->do(q/CREATE SEQUENCE seq_digte_vid INCREMENT 1 START 1/);
    $dbh->do("DROP TABLE digte CASCADE");
    $dbh->do(q(CREATE TABLE digte ( 
              did int NOT NULL PRIMARY KEY, 
	      parentdid int REFERENCES digte(did),
              longdid varchar(40),
              fhandle VARCHAR(20) NOT NULL REFERENCES fnavne(fhandle),
              vid VARCHAR(80) NOT NULL REFERENCES vaerker(vid),
              vaerkpos INT,
              toctitel text,
	      tititel text,
	      toptitel text,
	      linktitel text,
              foerstelinie text,
              underoverskrift text,
              indhold text,
	      type varchar(10), -- enum('poem','prose','group','section'),
	      quality varchar(50), --set('korrektur1','korrektur2','korrektur3', 'kilde','side'),
              layouttype char(5) default 'digt', -- enum('prosa','digt') default 'digt',
	      createtime INT NOT NULL,
	      lang char(2))
	      ));
 $dbh->do(q/CREATE INDEX digte_longdid ON digte(longdid)/);
 $dbh->do(q/CREATE INDEX digte_fhandle ON digte(fhandle)/);
 $dbh->do(q/CREATE INDEX digte_lang ON digte(lang)/);
 $dbh->do(q/CREATE INDEX digte_type ON digte(type)/);
 $dbh->do(q/CREATE INDEX digte_createtime ON digte(createtime)/);
 $dbh->do(q/CREATE INDEX digte_vid ON digte(vid)/);
   $dbh->do(q/GRANT SELECT ON TABLE digte TO "www-data"/);


    $dbh->do("DROP TABLE textnotes");
    $dbh->do(q(
	CREATE TABLE textnotes ( 
              longdid varchar(40) NOT NULL,-- REFERENCES digte(longdid),
	      note text NOT NULL,
              vid VARCHAR(80) NOT NULL REFERENCES vaerker(vid),
	      orderby int NOT NULL)
	    ));
   $dbh->do(q/CREATE INDEX textnotes_longdid ON textnotes(longdid)/);
   $dbh->do(q/GRANT SELECT ON TABLE textnotes TO "www-data"/);

    $dbh->do("DROP TABLE textpictures");
    $dbh->do(q(
	CREATE TABLE textpictures ( 
              longdid varchar(40) NOT NULL,-- REFERENCES digte(longdid),
	      caption text,
	      url varchar(200) NOT NULL,
	      orderby int NOT NULL)
	    ));
   $dbh->do(q/CREATE INDEX textpictures_longdid ON textpictures(longdid)/);
   $dbh->do(q/GRANT SELECT ON TABLE textpictures TO "www-data"/);

    $dbh->do("DROP TABLE textxkeyword");
    $dbh->do(q(
	CREATE TABLE textxkeyword ( 
              longdid varchar(40) NOT NULL,-- REFERENCES digte(longdid),
	      keyword varchar(100) NOT NULL -- REFERENCES keywords(ord)
	    )
	    ));
   $dbh->do(q/CREATE INDEX textxkeyword_longdid ON textxkeyword(longdid)/);
   $dbh->do(q/CREATE INDEX textxkeyword_keyword ON textxkeyword(keyword)/);
   $dbh->do(q/GRANT SELECT ON TABLE textxkeyword TO "www-data"/);

}

sub _createtime {
    my $longdid = shift;
    my ($year,$mon,$day) = $longdid =~ /(\d\d\d\d)(\d\d)(\d\d)/;
    my $time = POSIX::mktime(0,0,2,$day,$mon-1,$year-1900) || 0;
    return $time;
}

1;
