#!/usr/bin/perl -w

use CGI ();
use URI::Escape();
use strict;

my $imgfile = CGI::param('imgfile');
my $x = CGI::param('x');
my $y = CGI::param('y');
my $HTML;

print "Content-type: text/html\n\n";
print <<"EOF"
<HTML>
<HEAD>
<STYLE>
body {
    background-color: black;
    color: white;
    font-size: 12px;
    font-family: Arial, Helvetica;
}

A:link, A:visited, A:active {
         text-decoration: none; 
	 color: white;
}
</STYLE>
<SCRIPT>
function zoom(val) {
    var x = ($x * val) / 100;
    var y = ($y * val) / 100;
    parent.picframe.document.open();
    parent.picframe.document.writeln('<BODY LEFTMARGIN=0 TOPMARGIN=0 BOTTOMMARGIN=0 RIGHTMARGIN=0><center><table cellpadding=0 cellspacing=0 border=0 height="100%" width="100%"><tr><td>');
    parent.picframe.document.writeln('<img align="center" src="$imgfile" width='+x+' height='+y+'></td></tr></table></center></body>');
    parent.picframe.document.close();
}
</SCRIPT>
</HEAD>
<BODY onLoad="zoom(100)">
<center>
[ <A HREF="javascript:{}" onClick="zoom(50)">50%</A> | 
<A HREF="javascript:{}" onClick="zoom(100)">100%</A> | 
<A HREF="javascript:{}" onClick="zoom(200)">200%</A> | 
<A HREF="javascript:{}" onClick="zoom(400)">400%</A> ]
</center>
</BODY>
</HTML>
EOF

