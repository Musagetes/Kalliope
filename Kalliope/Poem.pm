
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

package Kalliope::Poem;

use strict ('vars');
use Carp;
use Kalliope::DB;
use Kalliope::Keyword;
use Kalliope::Person;
use Kalliope::Work;
use Kalliope::Strings;
use Kalliope::Quality;
use Kalliope::Poem::Bible;

my $dbh = Kalliope::DB->connect;

sub new {
    my ($class,%arg) = @_;
    my $sql;
    $sql = 'longdid = "'.$arg{'longdid'}.'"' if defined $arg{'longdid'};
    $sql = 'did = '.$arg{'did'} if defined $arg{'did'};
    $sql = 'did = '.$arg{'id'} if defined $arg{'id'};
    confess "Need some kind of id to initialize a new poem\n" unless $sql;
    my $sth = $dbh->prepare("SELECT did,fid,vid,longdid,titel,underoverskrift,foerstelinie,layouttype,pics,quality FROM digte WHERE $sql");
    $sth->execute();
    return undef unless $sth->rows;

    my $obj = $sth->fetchrow_hashref;
    
    $class = 'Kalliope::Poem::Bible' if $obj->{'longdid'} =~ /^(bibel|bible)/;
    bless $obj,$class;
    
    $obj->{'quality_obj'} = new Kalliope::Quality($obj->{'quality'});
    return $obj;
}

# Class method
sub exist {
    my $fhandle = shift;
    my $sth = $dbh->prepare("SELECT longdid FROM digte WHERE longdid = ?");
    $sth->execute($fhandle);
    return $sth->rows;
}

sub did {
    return $_[0]->{'did'};
}

sub longdid {
    return $_[0]->{'longdid'};
}

sub isProse {
    return shift->{'layouttype'} eq 'prosa' ? 1 : 0;
}

sub title {
    return $_[0]->{'titel'};
}

sub sortString {
    return $_[0]->title;
}

sub subtitle {
    $_[0]->{'underoverskrift'} =~ s/\n/<BR>/g;
    return $_[0]->{'underoverskrift'};
}

sub subtitleAsHTML {
    my $self = shift;
    $self->{'underoverskrift'} = $self->extractFootnotes($self->{'underoverskrift'});
    my $subtitle = $self->{'underoverskrift'};
    $subtitle =~ s/\n/<br>/g;
    return $subtitle;
}

sub firstline {
    return $_[0]->{'title'};
}

sub quality {
    return shift->{'quality_obj'};
}

sub pics {
   my $self = shift;
   my $pics = $self->{'pics'};
   my @pics = split ;
   my @result;
   my $fhandle = $self->author->fhandle;
   foreach my $line (split /\$\$\$/,$pics) {
      my ($url,$desc) = split /%/,$line;
      push @result,{ thumbfile => 'fdirs/'.$fhandle.'/_'.$url,
                     destfile =>  'fdirs/'.$fhandle.'/'.$url,
                     description => $desc };
   }	     
   return @result;
}

sub hasPics {
   return shift->{'pics'} ? 1 : 0;
}

sub extractFootnotes {
    my ($self,$content) = @_;
    my @footnotes = $self->{'footnotes'} ? @{$self->{'footnotes'}} : ();
    my $num = $#footnotes >= 0 ? $#footnotes + 2 : 1;
    while ($content =~ s/<footnote>(.*?)<\/footnote>/<footmark id="footnote$num"\/>/mi) {
       push @{$self->{'footnotes'}},$1;
       $num++;
    }
    return $content;
}

sub footnotes {
    my $self = shift;
    return $self->{'footnotes'} ? @{$self->{'footnotes'}} : ();
}

sub content {
    my $self = shift;
    unless (defined $self->{'content'}) {
	my $sth = $dbh->prepare("SELECT indhold,noter FROM digte WHERE did = ?");
	$sth->execute($self->did);
	my $data = $sth->fetchrow_hashref;
	$self->{'indhold'} = $data->{'indhold'};
	$self->{'noter'} = $data->{'noter'};
        $self->{'type'} = $data->{'type'};
	$self->{'indhold'} = $self->extractFootnotes($self->{'indhold'});
    }
#    if ($self->{'layouttype'} eq 'prosa') {
    if (1) {
        my @indhold;
	foreach my $line (split /\n/,$self->{'indhold'}) {
	    $line =~ s/^(\s+)/_nbsp($1)/e;
            push @indhold,"$line\n";
        }
        $self->{'indhold'} = join "",@indhold;
    } else {
	$self->{'indhold'} =~ s/ /&nbsp;/;
    }
    $self->{'indhold'} =~ s/<w>/<span class="wide">/gi;
    $self->{'indhold'} =~ s/<\/w>/<\/span>/gi;
    $self->{'indhold'} =~ s/<sc>/<span style="font-variant: small-caps">/g;
    $self->{'indhold'} =~ s/<\/sc>/<\/span>/g;
    $self->{'indhold'} =~ s/<wrap>/<div style="white-space: normal">/gi;
    $self->{'indhold'} =~ s/<\/wrap>/<\/div>/gi;

    $self->{'indhold'} =~ s/\n/<BR>\n/g;
    $self->{'indhold'} =~ s/,,/&bdquo;/g;
    $self->{'indhold'} =~ s/''/&ldquo;/g;
    return $self->{'indhold'}; 
}

sub contentForSearch {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT indhold FROM digte WHERE did = ?");
    $sth->execute($self->did);
    my $data = $self->subtitle."\n";
    $data .= $sth->fetchrow_array;
    return Kalliope::Strings::stripHTML($data);
}

sub _nbsp {
    return '&nbsp;'x(length shift);
}

sub notes {
    my $self = shift;
    unless (defined $self->{'indhold'}) {
        $self->content;
    }
    return $self->{'noter'}; 
}

sub keywords {
    my $self = shift;
    my @keywords;
    my $sth = $dbh->prepare("SELECT keywordid FROM keywords_relation WHERE keywords_relation.otherid = ? AND keywords_relation.othertype = 'digt'");
    $sth->execute($self->did);
    while (my $id = $sth->fetchrow_array) {
       push @keywords,new Kalliope::Keyword(id => $id);
    }
    return @keywords;
}

sub xrefsTo {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT fromid FROM xrefs WHERE toid = ?");
    $sth->execute($self->longdid);

    my @result;
    while (my $longdid = $sth->fetchrow_array) {
        push @result, new Kalliope::Poem(longdid => $longdid);
    }
    return @result;
}

sub updateHitCounter {
    my $self = shift;
    my $longdid = $self->longdid;
    my $sth = $dbh->prepare("SELECT hits FROM digthits WHERE longdid=?");
    $sth->execute($longdid);
    if ($sth->rows) {
	my ($hits) = $sth->fetchrow_array;
	$sth = $dbh->prepare("UPDATE digthits SET hits=?, lasttime=? WHERE longdid = ?");
	$sth->execute(++$hits,time(),$longdid);
    } else {
	$sth = $dbh->prepare("INSERT INTO digthits (hits,lasttime,longdid) VALUES (?,?,?)");
	$sth->execute(1,time(),$longdid);
    }
}

sub fid {
    return $_[0]->{'fid'};
}

sub clickableTitle {
    my ($self) = @_;
    return $self->author->name.': <A CLASS=green HREF="digt.pl?longdid='.$self->longdid.'">�'.$self->title.'�</A> - '.$self->work->title.' '.$self->work->parenthesizedYear;
}

sub clickableTitleSimple {
    my ($self) = @_;
    return '<A CLASS=green HREF="digt.pl?longdid='.$self->longdid.'">�'.$self->title.'�</A>';
}

sub smallIcon {
    return '<IMG HEIGHT=48 BORDER=0 SRC="gfx/icons/poem-h48.gif">';
}


sub author {
    my $self = shift;
    return $self->{'cache_author'} if $self->{'cache_author'};
    $self->{'cache_author'} = new Kalliope::Person('fid' => $self->fid);
    return  $self->{'cache_author'};
}

sub vid {
    return $_[0]->{'vid'};
}

sub work {
    my $self = shift;
    return $self->{'cache'}->{'work'} if defined $self->{'cache'}->{'work'};
    $self->{'cache'}->{'work'} = new Kalliope::Work('vid' => $self->vid); 
    return $self->{'cache'}->{'work'};
}

sub getSearchResultEntry {
    my ($self,$escapedNeedle,@needle) = @_;

    use locale;
    use POSIX qw(locale_h);
    setlocale(LC_CTYPE, "da_DK.ISO_8859-1");

    $escapedNeedle = $escapedNeedle || '';
    my $content = $self->contentForSearch();
    my $work = $self->work;
    my $author = $self->author;
    my $poemTitle = $self->title;

    my $match = '';
    my $slash = '<SPAN STYLE="color: #a0a0a0">//</SPAN>';
    foreach my $ne (@needle) {
	my ($a,$b,$c) = $content =~ /(.{0,30})($ne)(.{0,30})/si;
	$a =~ s/\n+/ $slash /g;
	$c =~ s/\n+/ $slash /g;
	$match .= "...$a<b>$b</b>$c...<BR>" if $b;
	$poemTitle =~ s/($ne)/\n$1\t/gi;
    }
    $poemTitle =~ s/\n/<B>/g;
    $poemTitle =~ s/\t/<\/B>/g;
    
    my $HTML .= '<IMG ALT="Digt" ALIGN="right" SRC="gfx/icons/poem-h48.gif">';
    $HTML .= '<A CLASS=blue HREF="digt.pl?longdid='.$self->longdid.qq|&needle=$escapedNeedle#offset">|.$poemTitle.qq|</A><BR>|;
    $HTML .= qq|$match|;
    $HTML .= '<SPAN STYLE="color: green">'.$author->name.'</SPAN>: <SPAN STYLE="color: #a0a0a0"><I>'.$work->title."</I> ".$work->parenthesizedYear."</SPAN><BR><BR>";
    return $HTML;
}

sub addToKeyPool {
    my ($self,$newKeys) = @_;
    my @keypool = $self->getKeyPool;
    my @newKeys = split /[ ,.;]+/,$newKeys;
    my %uniq;
    map { $uniq{$_} = 1 } (@keypool,@newKeys);
    my $keyString = join '; ', sort (keys %uniq);

    my $dbh = Kalliope::DB->connect;
    if ($#keypool >= 0) {
	my $sth = $dbh->prepare("UPDATE digte_keywords SET keywords = ? WHERE longdid = ?");
	$sth->execute($keyString,$self->longdid);
    } else {
	my $sth = $dbh->prepare("INSERT INTO digte_keywords (longdid,keywords,lang) VALUES (?,?,?)");
	$sth->execute($self->longdid,$keyString,$self->author->lang);
    }
}

sub getKeyPool {
    my $self = shift;
    my $dbh = Kalliope::DB->connect;
    my $sth = $dbh->prepare("SELECT keywords FROM digte_keywords WHERE longdid = ?");
    $sth->execute($self->longdid);
    my $string = $sth->fetchrow_array;
    my @result = split '; ',$string;
    return @result;
}

1;
