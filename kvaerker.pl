#!/usr/bin/perl -w

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

use Kalliope;
use CGI qw(:standard);
use Kalliope::Page();
use Kalliope::Sort();
use Kalliope::Date ();
use strict;

my $mode = url_param('mode') || 'titel';
my $LA = url_param('sprog') || 'dk';
my $limit = url_param('limit') || '10';

my %crumbTitle = ('aar'    => 'efter �r',
                  'titel'  => 'efter titel',
		  'digter' => 'efter figter',
		  'pop'    => 'mest popul�re' );

my %pageTitle =  ('aar'    => 'V�rker efter �r',
                  'titel'  => 'V�rker efter titel',
		  'digter' => 'V�rker efter digter',
		  'pop'    => 'Mest popul�re v�rker' );

my @crumbs;
push @crumbs,['V�rker',''];
push @crumbs,[$crumbTitle{$mode},''];

my $page = new Kalliope::Page (
		title => $pageTitle{$mode},
                lang => $LA,
		crumbs => \@crumbs,
                thumb => 'gfx/icons/works-h70.gif',
                pagegroup => 'worklist',
                page => "kvaerker$mode" );

my $dbh = Kalliope::DB->connect;


if ($mode eq 'titel') {
    my $HTML;
    my $sth = $dbh->prepare("SELECT fornavn,efternavn,fnavne.fhandle,vhandle,titel,aar,findes FROM fnavne,vaerker WHERE sprog=? AND vaerker.fid = fnavne.fid");
    $sth->execute($LA);

    my ($i,$et,$to,@f);
    $i = 0;
    while ($f[$i] = $sth->fetchrow_hashref) {
	if ($LA eq 'dk' && $f[$i]->{'titel'} =~ /^Den |^Det |^Af /) {
	    $f[$i]->{'titel'} =~ /^([^ ]+) (.*)/;
	    $et = $1;
	    $to = $2;
	    $f[$i]->{'titel'} = $to.", ".$et;
	} elsif ($LA eq 'uk' && $f[$i]->{'titel'} =~ /^The /) {
	    $f[$i]->{'titel'} =~ /^([^ ]+) (.*)/;
	    $et = $1;
	    $to = $2;
	    $f[$i]->{'titel'} = $to.", ".$et;
	} elsif ($LA eq 'fr' && $f[$i]->{'titel'} =~ /^La |^Les /) {
	    $f[$i]->{'titel'} =~ /^([^ ]+) (.*)/;
	    $et = $1;
	    $to = $2;
	    $f[$i]->{'titel'} = $to.", ".$et;
	}
	$f[$i]->{'sort'} = $f[$i]->{'titel'};
	$i++;
    };

    # Udskriv titler p� vaerker
    my ($new,$last) = ('','');
    foreach my $f (sort { Kalliope::Sort::sort($a,$b) } @f) {
	next if ( $f->{'aar'} && $f->{'aar'} eq "?");
	next unless $f->{'titel'};
	$f->{'sort'} =~ s/Aa/�/g;
	$new = Kalliope::Sort::myuc(substr($f->{'sort'},0,1));
	if ($new ne $last) {
	    $last = $new;
	    $HTML .= "<BR><DIV CLASS=listeoverskrifter>$new</DIV><BR>\n";
	}
	unless ($f->{'findes'}) {
	    $HTML .= "<I>".$f->{'titel'}."</I> (".$f->{'aar'}.") - ".$f->{'fornavn'}." ".$f->{'efternavn'}."<BR>\n";
	} else {
	    $HTML .= '<A CLASS=green HREF="vaerktoc.pl?fhandle='.$f->{'fhandle'}.'&vhandle='.$f->{'vhandle'}.'">';
	    $HTML .= "<I>".$f->{'titel'}."</I></A> (".$f->{'aar'}.") - ".$f->{'fornavn'}." ".$f->{'efternavn'}."<BR>\n";

	}
    }

    $HTML .= "<BR><BR><I>Denne oversigt indeholder kun v�rker som har et faktisk udgivelses�r</I><BR>\n";
    $page->addBox( title => "V�rker efter titel",
                   width => '80%',
                   content => $HTML );
    $page->print;

} elsif ($mode eq 'aar') {

    my $sth = $dbh->prepare("SELECT v.*,f.fornavn,f.efternavn FROM vaerker AS v, fnavne AS f WHERE f.fid = v.fid AND v.lang = ? AND v.aar != '?' ORDER BY v.aar ASC");
    $sth->execute($LA);

    my $HTML = '<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0>';
    #Udskriv titler p� vaerker
    my ($last,$last2,$last3); 
    while (my $v = $sth->fetchrow_hashref) {
        my $vaerkaar = $v->{'aar'};
	if (int $vaerkaar - int $last >= 10) {
	    $last = $vaerkaar - $vaerkaar%10;
	    $last2 = $last+9;
	    $HTML .= "<TR><TD COLSPAN=2><BR><DIV CLASS=listeoverskrifter>$last-$last2</DIV><BR></TD></TR>";
	}

        my $liVal = $vaerkaar != $last3 ? "$vaerkaar" : '';
	$last3 = $vaerkaar;
        $HTML .= qq|<TR><TD NOWRAP>$liVal</TD>|;
	$HTML .= '<TD>&nbsp;<A HREF="fvaerker.pl?fhandle='.$$v{fhandle}.'">'.$$v{fornavn}.' '.$$v{efternavn}.'</A>: ';
	if ($$v{findes} == 0) {
	    $HTML .= "<I>$$v{titel}</I><BR>";
	} else {
	    $HTML .= qq|<A CLASS=green HREF="vaerktoc.pl?fhandle=$$v{fhandle}&vhandle=$$v{vhandle}">|;
	    $HTML .= "<I>$$v{titel}</I></A><BR>";
	}
	$HTML .= '</TD></TR>';
    }
    $HTML .= '</TABLE>';

    $HTML .= "<BR><BR><I>Denne oversigt indeholder kun v�rker som har et faktisk udgivelses�r</I><BR>\n";
    $page->addBox( title => "V�rker efter �r",
                   width => '80%',
                   content => $HTML );
    $page->print;

} elsif ($mode eq 'digter') {
    my $HTML;
    my $sth = $dbh->prepare("SELECT CONCAT(efternavn,', ',fornavn) as navn, fornavn, efternavn, fhandle,fid FROM fnavne WHERE sprog = ? AND vers = 1");
    my $sthvaerker = $dbh->prepare("SELECT vhandle,titel,aar,findes FROM vaerker WHERE fid = ? ORDER BY aar");
    $sth->execute($LA);
    my @f;
    while (my $f = $sth->fetchrow_hashref) {
	$f->{'sort'} = $f->{'efternavn'}.$f->{'fornavn'};
	push @f,$f;
    };

    my $last = "";
    my ($new,$html,$f,$v,$aar);
    foreach $f (sort { Kalliope::Sort::sort($a,$b) } @f) {
	$f->{'sort'} =~ s/Aa/�/g;
	$new = substr($f->{'sort'},0,1);
	if ($new ne $last) {
	    $last = $new;
	    $HTML .= "<BR><DIV CLASS=listeoverskrifter>$new</DIV><BR>\n";
	}
	$sthvaerker->execute($f->{fid});
	if ($sthvaerker->rows) {
            $HTML .= '<SPAN CLASS="listeblue">&#149;</SPAN> ';
	    $f->{'navn'} =~ s/^, // if $f->{'navn'};
	    $HTML .= $f->{navn}."<BR>";
	    $html = '<DIV STYLE="padding:0 0 0 20">';
	    while ($v = $sthvaerker->fetchrow_hashref) {
		next if ($v->{'titel'} eq '');
		$aar = ($v->{aar} ne '?') ? "($v->{aar})" : '';
		unless ($v->{'findes'}) {
		    $html .= "<I>".$v->{'titel'}."</I> $aar, ";
		} else {
		    $html .='<A CLASS=green HREF="vaerktoc.pl?fhandle='.$f->{'fhandle'}.'&vhandle='.$v->{'vhandle'}.'">';
		    $html .= "<I>".$v->{'titel'}."</I> $aar</A>, ";
		}
	    }
	    $html =~ s/, $//;
	    $html .= '</DIV>';
	    $HTML .= $html;
	}
    }

    $page->addBox( title => "V�rker efter digter",
                   width => '80%',
                   content => $HTML );
    $page->print;

} elsif ($mode eq 'pop') {
    my $HTML;
    my $sth = $dbh->prepare("SELECT fornavn, efternavn, v.titel as vtitel, vhandle, aar, f.fhandle, sum(hits) as hits, max(lasttime) as lasttime FROM digthits as dh,digte as d,fnavne as f, vaerker as v WHERE dh.longdid = d.longdid AND d.fid = f.fid AND d.vid = v.vid AND f.sprog=? GROUP BY v.vid ORDER BY hits DESC ".(defined($limit) ? 'LIMIT '.$limit : ''));
    $sth->execute($LA);
    my $i = 1;
    my $total;
    my $aar;
    $HTML .= '<TABLE CLASS="oversigt" width="100%" CELLSPACING=0>';
    $HTML .= '<TR><TH>&nbsp;</TH><TH ALIGN="left">Titel</TH><TH ALIGN="right">Hits</TH><TH ALIGN="right">Senest</TH></TR>';
    while (my $h = $sth->fetchrow_hashref) {
	$aar = $h->{'aar'} ne '?' ? ' ('.$h->{'aar'}.')' : '';
	$HTML .= '<TR><TD>'.($i++).'.</TD>';
	$HTML .= '<TD>'.$h->{fornavn}.' '.$h->{efternavn}.': <A CLASS=green HREF="vaerktoc.pl?fhandle='.$h->{fhandle}.'&vhandle='.$h->{vhandle}.'"><I>'.$h->{vtitel}.'</I>'.$aar.'</A></TD>';
	$HTML .= '<TD ALIGN=right>'.$h->{'hits'}.'</TD>';
	$HTML .= '<TD ALIGN=right>'.Kalliope::Date::shortDate($h->{'lasttime'}).'</TD>';
	$total += $h->{'hits'};
    }
    my $endHTML = '';

    if (defined($limit)) {
        $HTML .= '</TABLE>';
        $endHTML = '<A HREF="kvaerker.pl?mode=pop&sprog='.$LA.'"><IMG VALIGN=center BORDER=0 SRC="gfx/rightarrow.gif" ALT="Hele listen"></A>';
    } else {
        $HTML .= "<TR><TD></TD><TD><B>Total</B></TD><TD ALIGN=right>$total</TD><TD></TD></TR>";
        $HTML .= '</TABLE>';
    }
    $page->addBox( title => "Mest popul�re v�rker",
	           width => '90%',
	           content => $HTML,
	           end => $endHTML );
    $page->print;
}

