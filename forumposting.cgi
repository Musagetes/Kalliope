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
use Kalliope::Page::Popup;
use Kalliope::Forum::Post;
use Kalliope::Forum;
use Kalliope::Tree;
use CGI qw(:standard);
use strict;

my $page = new Kalliope::Page (
		title => 'Forum',
		thumb => 'gfx/evolution-192.png',
                pagegroup => 'forum');

my $id = url_param('id');

unless ($id) {
    $page->print;
    exit;
}

my $post = Kalliope::Forum::Post::newFromId ($id);

#
# Show message -----------------------------------------------------
#

my $HTML = '<TABLE WIDTH="100%">';
my $email = $post->fromEmail;
my $from = $post->from;
$from = $email ? qq|<A HREF="mailto:$email">$from</A>| : $from;
$HTML .= '<TR><TH CLASS="forumheads" ALIGN="right">Fra:</TH><TD CLASS="forumheads" WIDTH="100%">'.$from.'</TD></TR>';
$HTML .= '<TR><TH  CLASS="forumheads" ALIGN="right">Emne:</TH><TD  CLASS="forumheads"WIDTH="100%">'.$post->subject.'</TD></TR>';
$HTML .= '<TR><TH  CLASS="forumheads" ALIGN="right">Dato:</TH><TD  CLASS="forumheads"WIDHT="100%">'.$post->dateForDisplay.'</TD></TR>';
$HTML .= '</TABLE>';

$page->addBox (width => '90%',
               theme => 'dark',
               content => $HTML);

$HTML = $post->contentAsHTML;
$HTML .= qq|<HR><INPUT onClick="composer('reply',$id);" TITLE="" CLASS="button" TYPE="submit" VALUE=" Svar p� indl�g ">|;

$page->addBox (width => '90%',
               content => $HTML);

#
# Javascript ----------------------------------------------------
#

my $JS.= <<"EOF";
<SCRIPT LANGUAGE="JavaScript1.3">
function gotoPosting(postingid) {
    document.location = 'forumposting.cgi?id='+postingid;
    return false;
}

function composer(mode,id) {
    window.open('forumcompose.cgi?mode='+mode+'&parentid='+id,'compose','toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizeable=no,width=400,height=500'); 
    return false;
}
</SCRIPT>
EOF
$page->addHTML ($JS);

#
# Thread ------------------------------------------
#

my $tree = new Kalliope::Tree('tree','gfx/tree',3,('Emne',("&nbsp;"x6).'Fra','&nbsp;Dato'));
my %translate;
$translate{0} = 0;
my $showing = $post;
my @posts = Kalliope::Forum::getPostsInThread($post->threadId);
foreach my $post (@posts) {
    my $class = $showing->id == $post->id ? 'sel' : 'unsel';
    my $from = ("&nbsp;"x5).qq|<SPAN CLASS="$class" >&nbsp;|.$post->from.'&nbsp;</SPAN>';
    my $date = qq|<SPAN CLASS="$class">&nbsp;|.$post->dateForDisplay.'&nbsp;</SPAN>';
    my $subj = qq|<A CLASS="$class" HREF="javascript:{}" onClick="return gotoPosting(|.$post->id.');">&nbsp;'.$post->subject.qq|&nbsp;</A>|;
    $translate{$post->id} = $tree->addNode($translate{$post->parent},1,($subj,$from,$date));
}
$HTML = $tree->getSimpleHTML().$tree->getJavaScript();

$page->addBox (width => '90%',
               title => 'Tr�d',
               content => $HTML);




$page->print;


