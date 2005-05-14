#!/usr/bin/perl

use lib '..';

use Kalliope;
use Kalliope::Page::WML;

my $page = new Kalliope::Page::WML( title => 'Kalliope' );
my $WML = '<p>Velkommen til Kalliopes mobiludgave.</p>';
$WML .= '<p><img src="../gfx/icons/poet-w16.png" alt="Digtere"/><a href="poets.cgi">Digtere</a></p>';
$WML .= '<p><img src="../gfx/icons/keywords-w16.png" alt="Om Kalliope"/><a href="about.cgi">Om Kalliope</a></p>';
#$WML .= '<p><a href="test.cgi">Test</a></p>';
$page->addWML($WML);
$page->print;
