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

package Kalliope::Page;

use Kalliope::Web ();
use Kalliope::Page::Print();
use Kalliope::Forum ();
use CGI::Cookie ();
use strict;

sub new {
    my ($class,%args) = @_;

    if (defined $args{'printer'} && $args{'printer'} == 1) {
	$class = 'Kalliope::Page::Print';
    }
    
    my $self = bless {}, $class;

    $self->{'pagegroupchoosen'} = '';

    foreach my $key (keys %args) {
        $self->{$key} = $args{$key};
    }
    $self->{'lang'} = $args{'lang'} || 'dk';
    $self->{'pagegroup'} = $args{'pagegroup'} || '';
    $self->{'page'} = $args{'page'} || '';
    $self->{'thumb'} = $args{'thumb'};
    $self->{'icon'} = $args{'icon'} || 'poet-red';
    $self->{'title'} = $args{'title'};
    $self->{'subtitle'} = $args{'subtitle'} || '';
    $self->{'nosubmenu'} = $args{'nosubmenu'} || 0;
    $self->{'columns'} = [];

    if ($self->{'setcookies'}) {
        $self->_setCookies(%{$self->{'setcookies'}});
    }

    if ($args{'changelangurl'}) {
        $self->{'changelangurl'} = $args{'changelangurl'};
    } elsif ($self->{'poet'}) {
	$self->{'changelangurl'} = 'poets.cgi?list=az&amp;sprog=XX';
    } else {
	$ENV{REQUEST_URI} =~ /([^\/]*)$/;
	$self->{'changelangurl'} = $1;
    }
    return $self;
}

sub _setCookies {
    my ($self,%vals) = @_;
    my @cookies;

    foreach my $name (keys %vals) {
        my $cookie = new CGI::Cookie(-expires => '+3M',
	                             -name => $name,
	                             -value => $vals{$name});
	push @cookies,$cookie;			     
    }
    $self->{'cookies'} = \@cookies;
    return @cookies;
}

sub _printCookies {
    my $self = shift;
    my $output;
    return '' unless $self->{'cookies'};
    foreach my $cookie (@{$self->{'cookies'}}) {
        $output .= "Set-Cookie: $cookie\n";
    }
    return $output;
}

sub newAuthor {
    my ($class,%args) = @_;
    my $poet = $args{'poet'};
    my $group = $poet->getType ne 'person' ? 'persons' : 'poets';
    my $page = new Kalliope::Page(pagegroupchoosen => $group, 
                                  title => $poet->name,
				  subtitle => $args{'subtitle'},
                                  lang => $poet->lang,  %args);
    return $page;
}

sub lang {
    return shift->{'lang'};
}

sub addHTML {
    my ($self,$HTML,%args) = @_;
    my $coloumn = $args{'coloumn'} || 0;
    @{$self->{'coloumns'}}[$coloumn] .= $HTML;
}

sub thumbIMG {
    my $self = shift;
    my ($src,$alt,$href) = ('','','');
    if ($self->{'poet'} && $self->{'poet'}->thumbURI) {
        my $poet = $self->{'poet'};
        $src = $poet->thumbURI;
	$alt = 'Tilbage til hovedmenuen for '.$poet->name;
	$href = 'ffront.cgi?fhandle='.$poet->fhandle;
    } elsif ($self->{'thumb'}) {
        $src = $self->{'thumb'};
    }
    my $img = qq|<IMG BORDER=0 ALT="$alt" HEIGHT=70 SRC="$src">| if $src;
    my $a = qq|<A HREF="$href" TITLE="$alt">$img</A>| if $href; 
    return $a || $img || '';
}

sub pageIcon {
    my $self = shift;
    if ($self->{'poet'}) {
        return $self->{'poet'}->icon;
    } else {
        return "gfx/frames/$$self{'icon'}.gif";
    }
}

sub titleAsHTML {
    my $self = shift;
    my $title;
    my $subtitle;
    if ($self->{'poet'}) {
        $title = $self->{'poet'}->name;
        $subtitle = $self->{'subtitle'};
#$subtitle = $self->{'poet'}->lifespan;
    } else {
        $title = $self->{'title'};
        $subtitle = $self->{'subtitle'};
    }
    my $result = $title;
    $result .= qq|<br><span class="subtitle">$subtitle</span>| if $subtitle;
    return $result;
}

sub titleForWindow {
    my $self = shift;
    if ($self->{'frontpage'}) {
        return 'Kalliope';
    } elsif ($self->{'extrawindowtitle'}) {
        return $self->{'extrawindowtitle'}.' - '.$self->{'title'}.' - Kalliope';

    } else {
        return $self->{'title'}.' - Kalliope'
    }
}


sub setColoumnWidths {
    my ($self,@widths) = @_;
    $self->{'coloumnwidths'} = \@widths;
}

sub getColoumnWidths {
    my $self = shift; 
    if ($self->{'poet'} && !$self->{'coloumnwidths'}) {
        return ('200','100%','200');
    }
    return $self->{'coloumnwidths'} ? @{$self->{'coloumnwidths'}} : ('100%');
}

sub _constructBreadcrumbs {
    my $self = shift;
    return '' unless $self->{'crumbs'};
    my @crumbs = (
                ['&nbsp;&nbsp;Kalliope','index.cgi'],
                @{$self->{'crumbs'}});
    my @blocks;
    foreach my $item (@crumbs) {
       if ($$item[1]) {
          push @blocks,qq|<A HREF="$$item[1]">$$item[0]</A>|;
       } else {
          push @blocks,$$item[0];
       }
    }
    return join ' >> ',@blocks;
}

sub addBox {
    my ($self,%args) = @_;

    my $bggfx = (defined $args{'theme'} && $args{'theme'} eq 'dark') ? 'pap.gif' : 'lightpap.gif';
    $bggfx = 'notepap.jpg' if defined  $args{'theme'} && $args{'theme'} eq 'note';
    my $align =  $args{align} ? $args{align} : 'left';
    my $width;
    if ($args{width} && $args{width} ne '100%') {
	$width = qq|WIDTH="$args{width}"|;
    } else {
	$width = '';
    }
    my $theme = $args{'theme'} || 'normal';

    my $HTML;
    $HTML .= qq|\n<div class="box$theme" $width style="text-align: $align">|;
    if ($args{title}) {
	$HTML .= qq|<div class="listeoverskrifter">$args{title}</div><br>|;
    }
    $HTML .= $args{content};
    if ($args{end}) {
	$HTML .= $args{end};
    }
    $HTML .= "</div><br><br>\n";
    $self->addHTML($HTML, %args);
}

sub print {
    my $self = shift;
    my $titleForWindow = $self->titleForWindow;
    print $self->_printCookies();
    print "Content-type: text/html\n\n";
    print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">';
    print <<"EOF";
<HTML><HEAD><TITLE>$titleForWindow</TITLE>
<LINK REL="Shortcut Icon" HREF="http://www.kalliope.org/favicon.ico">
<LINK REL=STYLESHEET TYPE="text/css" HREF="kalliope.css">
<META HTTP-EQUIV="Content-Type" content="text/html; charset=iso-8859-1">
<META name="description" content="Stort arkiv for �ldre digtning">
<META name="keywords" content="digte, lyrik, litteratur, litteraturhistorie, digtere, digtarkiv, etext, e-text, elektronisk tekst, kalliope, kalliope.org, www.kalliope.org">
<SCRIPT TYPE="text/javascript">
function openTimeContext(year) {
     window.open('timecontext.cgi?center='+year,'Timecontext','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=400,height=300');
     return false;
}
</SCRIPT>
</HEAD>
<!--<BODY LINK="#000000" VLINK="#000000" ALINK="#000000" LEFTMARGIN=0 TOPMARGIN=0 MARGINHEIGHT=0 MARGINWIDTH=0>-->
<BODY LINK="#000000" VLINK="#000000" ALINK="#000000">

EOF
 
    print '<center><br>';
    print '<div class="body">';
    print '<TABLE WIDTH="770" BORDER="0" CELLSPACING="0" CELLPADDING="0">';
    
    if (my $crumbs = $self->_constructBreadcrumbs) {
        print '<tr><td colspan="3" class="breadcrumbs">';
	print $crumbs;
	print '</td></tr>';
    }

    # Head BACKGROUND="gfx/frames/top.png"
    print '<TR><TD HEIGHT="164" COLSPAN="3" VALIGN="top">';
    print '<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0"><TR>';
    print '<TD ROWSPAN="3" valign="top"><IMG ALT="" SRC="'.$self->pageIcon.'" HEIGHT="164" WIDTH="139"></TD>';
    print '<TD colspan="5" HEIGHT="32" WIDTH="100%" CLASS="top"><img alt="" src="gfx/trans1x1.gif" height="72" width="1"></TD>';
    print '</tr>';
    
    if ($self->{'nosubmenu'}) {
	print q|<tr><td class="submenu" colspan="5"><img alt="" src="gfx/frames/small-menu-blank.gif"></td></tr>|;   
    } else {
	print q|<tr>|;
	print q|<td width="100%" height="1" class="submenu"></td>|;   
	print '<td class="submenu"><img alt="" src="gfx/frames/small-menu-left.gif"></td>';
	print qq|<td class="submenu" style="background: url('gfx/frames/small-menu-middle.gif')" nowrap>|;
	print $self->_navigationSub;
	print '</td>';
	print '<td class="submenu"><img alt="" src="gfx/frames/small-menu-right.gif"></td>';
	print q|<td class="submenu"></td>|;
	print '</tr>';

    }
    print '<tr><td colspan="5" height="74" class="maintitle">'.$self->titleAsHTML.'</td></tr>';   
    print '</table>';
    
    print '</TD></TR>';

    # Body
    print '<tr>';
    print '<td valign="top" colspan="2" class="navigation"><IMG ALT="" SRC="gfx/trans1x1.gif" WIDTH="138" HEIGHT="40">';
    print $self->_navigationMain;
    print '</td>';
    print '<td class="paper" valign="top">';
    print qq|<TABLE WIDTH="100%" CELLPADDING="5"><TR>\n\n|;
    my @widths = $self->getColoumnWidths;
    my $count = 0;
    foreach my $colHTML (@{$self->{'coloumns'}}) {
        $colHTML = $colHTML || '';
	my $style = ++$count == 3 ? qq|style="width: 250px; border-left: 3px dotted #808080"| : '';
        my $width = shift @widths;
	if ($width) {
	       print qq|<TD VALIGN="top" $style WIDTH="$width">$colHTML</TD>\n|;
        } else {
	    print qq|<TD $style VALIGN="top">$colHTML</TD>\n|;
        }
    }
    print '</TR></TABLE>';
    print '</TD>';
    print '</TR>';

    # Foot
    print '<TR><TD CLASS="footer" COLSPAN="3" HEIGHT="40" ALIGN="right" VALIGN="middle">';

    print '<FORM METHOD="get" ACTION="ksearch.cgi">';
    print '<TABLE WIDTH="100%" CELLSPACING="0" CELLPADDING="0">';
    print '<TR>';
    print '<td nowrap style="padding-left: 20px; text-align: left;">';
    print '<b>S�g:</b> <INPUT CLASS="search" NAME="needle"><INPUT TYPE="hidden" NAME="sprog" VALUE="'.$self->lang.'"><INPUT TYPE="hidden" NAME="type" VALUE="free">';
    print '</td>';
    print '<TD VALIGN="middle" ALIGN="right" NOWRAP STYLE="padding-right: 20px">';
    print $self->langSelector;
    print '</TD></TR>';
    print '</TABLE>';
    print '</form>';

    print '</TD></TR>';
    
    print '</TABLE></div></center></BODY></HTML>';
}

#
# Private ------------------------------------------------------
#

sub langSelector {
    my $self = shift;
    my $selfLang = $self->lang; 
    my $HTML;
    my %titles = ( dk => 'danske',
                   uk => 'britiske',
                   us => 'amerikanske',
		   de => 'tyske',
		   fr => 'franske',
		   it => 'italienske',
		   se => 'svenske',
		   no => 'norske' );
    my $url = $self->{'changelangurl'};
    foreach my $lang ('dk','uk','de','fr','se','no','it','us') {
       my $refURL = $url;
       $refURL =~ s/sprog=../sprog=$lang/;
       my $img = $lang eq $selfLang ? "${lang}select.gif" : "$lang.gif";
       my $alt = $lang eq $selfLang ? 'Du befinder dig i den '.$titles{$lang}.' samling.' : 'Skift til den '.$titles{$lang}.' samling.';
       $HTML .= qq|<A TITLE="$alt" HREF="$refURL"><IMG ALT="$alt" BORDER=0 SRC="gfx/flags/$img"></A>|;
#       $HTML .= '<BR>' if $lang eq 'de';
    }
    return $HTML;
}

sub menuStructs {
    my $self = shift;
    my $lang = $self->lang;

    my %menuStructs = (
         'welcome' => {'menuTitle' => '',
                       'url' => 'index.cgi',
                       'pages' => ['news']
                       },
         'om'       => {'menuTitle' => '',
                        'url' => 'index.cgi',
                       'pages' => ['about','tak','musen']
 	               },
         'poets'    => {menuTitle => 'Digtere',
                       url => 'poetsfront.cgi?sprog='.$lang,
		       icon => 'gfx/frames/menu-digtere.gif',
                       'pages' => ['poetsbyname','poetsbyyear','poetsbypic',
		                   'poetsbyflittige','poetsbypop']
                       },
         'worklist' => {menuTitle => 'V�rker',
                       url => "worksfront.cgi?sprog=$lang",
		       icon => 'gfx/frames/menu-vaerker.gif',
                       pages => ['kvaerkertitel','kvaerkeraar','kvaerkerdigter',
                                 'kvaerkerpop']
                       },
         'poemlist' => {menuTitle => 'Digte',
		       icon => 'gfx/frames/menu-digte.gif',
                       url => "poemsfront.cgi?sprog=$lang",
                       pages => ['poemtitles','poem1stlines','poempopular','latest']
                       },
         'history' => {menuTitle => 'Baggrund',
		       icon => 'gfx/frames/menu-meta.gif',
                       url => 'metafront.cgi?sprog='.$lang,
                       pages => ['keywordtoc','dict','persons']
                       },
#         'forum' =>    {menuTitle => 'Forum',
#                       url => 'forumindex.cgi',
#		       icon => 'gfx/icons/forum-w64.gif',
#                       pages => ['forumindex']
#                       },
         'forumindex' => {menuTitle => 'Oversigt',
                       url => 'forumindex.cgi'
                       },
         'poemtitles' =>{menuTitle => 'Digttitler',
                       url => 'klines.pl?mode=1&forbogstav=A&sprog='.$lang
                       },
         'poem1stlines' => {menuTitle => 'F�rstelinier',
                       url => 'klines.pl?mode=0&forbogstav=A&sprog='.$lang
                       },
         'poempopular' => {menuTitle => 'Popul�re',
                       url => 'klines.pl?mode=2&sprog='.$lang
                       },
         'news' =>     {menuTitle => 'Nyheder',
                       url => 'index.cgi'
                       },
         'about' =>    {menuTitle => 'Om',
                       url => 'kabout.pl?page=about'
                       },
         'tak' =>      {menuTitle => 'Tak',
                       url => 'kabout.pl?page=tak'
                       },
         'musen' =>     {menuTitle => 'Musen',
                       url => 'kabout.pl?page=musen'
                       },
         'stats' =>    {menuTitle => 'Statistik',
                       url => 'kstats.pl'
                       },
         'latest' =>    {menuTitle => 'Tilf�jelser',
                         url => 'latest.cgi'
                       },
         'poetsbyname' => {menuTitle => 'Digtere efter navn',
                           url => 'poets.cgi?list=az&sprog='.$lang
                       },
         'poetsbyyear' => {menuTitle => 'Digtere efter �r',
                           url => 'poets.cgi?list=19&sprog='.$lang
                       },
         'poetsbypic' => {menuTitle => 'Digtere efter udseende',
                           url => 'poets.cgi?list=pics&sprog='.$lang
                       },
         'poetsbyflittige' => {menuTitle => 'Flittigste digtere',
                           url => 'poets.cgi?list=flittige&sprog='.$lang
                       },
         'poetsbypop'    => {menuTitle => 'Mest popul�re digtere',
                             url => 'poets.cgi?list=pop&sprog='.$lang
                       },
         'kvaerkertitel' => {menuTitle => 'V�rker efter titel',
                           url => 'kvaerker.pl?mode=titel&sprog='.$lang
                       },
         'kvaerkerdigter' => {menuTitle => 'V�rker efter digter',
                           url => 'kvaerker.pl?mode=digter&sprog='.$lang
                       },
         'kvaerkeraar' => {menuTitle => 'V�rker efter �r',
                           url => 'kvaerker.pl?mode=aar&sprog='.$lang
                       },
         'kvaerkerpop' => {menuTitle => 'Mest popul�re v�rker',
                           url => 'kvaerker.pl?mode=pop&sprog='.$lang
                       },
         'keywordtoc' => {menuTitle => 'N�gleord',
                           url => 'keywordtoc.cgi?sprog='.$lang
                       },
         'dict' => {menuTitle => 'Ordbog',
                           url => 'dict.cgi'
                       },
         'persons' => {menuTitle => 'Biografier',
                           url => 'persons.cgi?list=az',
                       'pages' => ['personsbyname','personsbyyear','personsbypic']
                       },
         'personsbyname' => {menuTitle => 'Personer efter navn',
                           url => 'persons.cgi?list=az&sprog='.$lang
                       },
         'personsbyyear' => {menuTitle => 'Personer efter �r',
                           url => 'persons.cgi?list=19&sprog='.$lang
                       },
         'personsbypic' => {menuTitle => 'Personer efter udseende',
                           url => 'persons.cgi?list=pics&sprog='.$lang
                       },
         'timeline' => {menuTitle => 'Tidslinie',
                           url => 'timeline.cgi&sprog='.$lang
                       }
          );

    # Special topmenu for forum
    if ($self->{'pagegroup'} eq 'forum') {
	my $antalFora = Kalliope::Forum::getNumberOfForas;
	my @temp;
	foreach my $i (0..$antalFora-1) {
	    my $forum = new Kalliope::Forum($i);
	    $menuStructs{"forum$i"} = { menuTitle => $forum->getTitle,
		                        url => 'forum.cgi?forumid='.$i };
		push @temp,"forum$i";
	}
	$menuStructs{'forum'}->{'pages'} = \@temp;
    }
    
    return %menuStructs;
}

sub _navigationMain {
    my $self = shift;
    my @topMenuItems = ('welcome','poets','worklist','poemlist', 'history','forum');
    my %menuStructs = $self->menuStructs;
    my $HTML = '<BR>';

    # Pagegroups
    foreach my $key (@topMenuItems) {
        my $struct = $menuStructs{$key};
        my ($title,$url,$icon) = ($struct->{'menuTitle'},
                                  $struct->{'url'},$struct->{'icon'});
	next unless $icon;			  
	$HTML .= qq|<A TITLE="$title" HREF="$url">|;
	$HTML .= qq|<IMG ALT="$title" BORDER=0 SRC="$icon">|;
        if ($key ne $self->{'pagegroup'} && $key ne $self->{'pagegroupchoosen'}) {
#	    $HTML .= $title;
	} else {
#            $HTML .= "<B>$title</B>";
	}
	$HTML .= '</A><br>';
    }
    return $HTML;
}

sub _navigationSub {
    my $self = shift;
    my %menuStructs = $self->menuStructs;
    my $HTML;
    my @itemsHTML;
    
    # Pages
    my $struct = $menuStructs{$self->{'pagegroup'}};
    foreach my $key (@{$struct->{'pages'}}) {
        my $struct = $menuStructs{$key};
        my ($title,$url) = ($struct->{'menuTitle'},
                           $struct->{'url'});
        if ($key ne $self->{'page'}) {
	    push @itemsHTML, qq|<A CLASS="submenu" HREF="$url">$title</A>|;
	} else {
            push @itemsHTML, qq|<A CLASS="submenu" HREF="$url"><B>$title</B></A>|;
	}
    }
    $HTML = join ' <span class="lifespan">&bull;</span> ',@itemsHTML;
    #$HTML = join ' <span class="lifespan">&#149;</span> ',@itemsHTML;
    # Author menu
    if ($self->{'poet'}) {
       $HTML .= $self->{'poet'}->menu($self);
    }
    return $HTML;
}

sub notFound {
    my $message = shift;
    $message = $message || qq|Hovsa! Der gik det galt! Siden kunne ikke findes.<BR><BR>Send en mail til <A HREF="mailto:jesper\@kalliope.org">jesper\@kalliope.org</A>, hvis du mener, at jeg har lavet en fejl.|;
    my $HTML;
    my $picNo = int rand(10) + 1;
    my $page = new Kalliope::Page ('title' => 'Hovsa!', nosubmenu => 1);
    $page->addBox(content => qq|<CENTER><IMG BORDER=2 SRC="gfx/notfound/$picNo.jpg" ALIGN="center"></CENTER><BR><BR>$message|);
    $page->print;
    exit;
}

1;
