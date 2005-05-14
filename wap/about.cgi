#!/usr/bin/perl

use lib '..';

use Kalliope;
use Kalliope::Page::WML;

my @crumbs;
push @crumbs, ['Om',''];

my $page = new Kalliope::Page::WML( 
	title => 'Om Kalliope',
	crumbs => \@crumbs
       	);

my $WML;
$WML .= '<p>';
$WML .= 'Kalliope er en database indeholdende �ldre dansk lyrik samt biografiske oplysninger om danske digtere. M�let er intet mindre end at samle hele den �ldre danske lyrik, men indtil videre indeholder Kalliope et forh�bentligt repr�sentativt, og stadigt voksende, udvalg af den danske digtning. Kalliope indeholder ogs� udenlandsk digtning, men prim�rt i et omfang som kan bruges til belysning af den danske samling.';
$WML .= '</p>';
$page->addWML($WML);
$page->print;
