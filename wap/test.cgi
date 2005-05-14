#!/usr/bin/perl

use lib '..';

use Kalliope;
use Kalliope::Page::WML;

my $page = new Kalliope::Page::WML( title => 'Kalliope test' );
my $WML = '<p>En testside.</p>';
$WML .= '<p><img src="../gfx/icons/poet-w32.png" alt="Digtere"/></p>';
$WML .= '<p><img src="../gfx/icons/poet-w16.png" alt="Digtere"/>Digtere</p>';
$WML .= '<p><img src="../gfx/icons/works-w16.png" alt="Digtere"/>Værker</p>';
$page->addWML($WML);
$page->print;
