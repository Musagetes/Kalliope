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

use CGI ();
use Kalliope::Person;
use Kalliope::Page;
use Kalliope::Poem;
use Kalliope::Search;
use Kalliope::DB;
use URI::Escape;
use strict;

my $dbh = Kalliope::DB->connect;

my $search = new Kalliope::Search(lang => CGI::param('sprog') || '',
                                  type => CGI::param('type') || '',
                                  offset => CGI::param('offset') || 0,
				  needle => CGI::param('needle') || '',
				  keyword => CGI::param('keyword') || '');

$search->log;

my @crumbs = ([$search->pageTitle,'']);

my $page = new Kalliope::Page (
		title => $search->pageTitle,
                pagegroup => 'search',
                lang => $search->lang,
                page => '',
                thumb => 'gfx/icons/search-h70.gif',
                crumbs => \@crumbs );

if ($search->hasSearchBox) {
    $page->addBox( width => '80%',
	           content => $search->searchBoxHTML);
}


my $starttid = time;
$page->addBox( width => '80%',
	content => $search->getHTML,
	end => "Tid i sekunder: ".(time-$starttid) );

if (CGI::param('needle') =~ /^prut/) {
    my ($antal) = CGI::param('needle') =~ /^prut(\d+)/;
    $antal = $antal > 0 ? $antal : 10;
    $page->addHTML(&getEasterJS(int $antal));
}

$page->print();


sub getEasterJS {
    my $NUM = shift;
return <<"EOF";
<SCRIPT>
for (i=1;i<=$NUM;i++) {
   document.write('<DIV ID=div'+i+' STYLE="position:absolute"><IMG SRC="gfx/icons/poet-w64.gif"></DIV>');

}

mainx1=0;mainx2=10;mainy1=20;mainy2=1;
mainaddx1=5; mainaddx2=-7; mainaddy1=-5; mainaddy2=9;
addx1 = 47; addx2 = 59; addy1 = 42; addy2 = -57;

sinusTable = new Array(1024);

layerObjs = new Array($NUM);

function doFrame() {
   tempx1 = mainx1 = ( mainx1 + mainaddx1 ) & 1023;
   tempx2 = mainx2 = ( mainx2 + mainaddx2 ) & 1023;
   tempy1 = mainy1 = ( mainy1 + mainaddy1 ) & 1023;
   tempy2 = mainy2 = ( mainy2 + mainaddy2 ) & 1023;
   for (i=0;i<$NUM;i++) {
      tempx1 = (tempx1 + addx1 ) &1023;
      tempx2 = (tempx2 + addx2 ) &1023;
      tempy1 = (tempy1 + addy1 ) &1023;
      tempy2 = (tempy2 + addy2 ) &1023;

      layerObjs[i].left = sinusTable[tempx1]+sinusTable[tempx2];
      layerObjs[i].top = sinusTable[tempy1]+sinusTable[tempy2];
   }
   setTimeout("doFrame()",20);
}

for (i=0; i<$NUM; i++) {
    if (document.all) {
	layerObjs[i] = document.all('div'+(i+1)).style;
   } else if (document.layers) {
       layerObjs[i] = document.layers['div'+(i+1)];
   } else {
       layerObjs[i] = document.getElementById('div'+(i+1)).style;

   }
}

for(i=0;i<1024;i++) {
   sinusTable[i] = Math.floor(150*Math.sin(2*Math.PI*(i/1024)))+150;
}

doFrame();

</SCRIPT>
</BODY></HTML>
EOF

}
