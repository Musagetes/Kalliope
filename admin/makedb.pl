#!/usr/bin/perl

use lib '..';
use Kalliope::Sort;
use Kalliope::DB;
use Kalliope::Strings;
use Kalliope::Array;
use Kalliope::Build::Persons;
use Kalliope::Build::Dict;
use Kalliope::Build::Timeline;
use Kalliope::Build::Xrefs;
use Kalliope::Build::Keywords;
use Kalliope::Build::Biblio;
use Kalliope::Build::Works;
use Kalliope::Build::Texts;
use Kalliope::Build::Timestamps;
use Kalliope::Build::Firstletters;
use POSIX;
use Getopt::Long;

$| = 1; # No buffered I/O on STDOUT

my $dbh = Kalliope::DB->connect;

my $__all = '';
GetOptions ("all" => \$__all);

if ($__all) {
    &log ("Creating tables...");
    Kalliope::Build::Persons::create();
    Kalliope::Build::Works::create();
    Kalliope::Build::Texts::create();
    Kalliope::Build::Timestamps::create();
    Kalliope::Build::Firstletters::create();
    Kalliope::Build::Keywords::create();
    Kalliope::Build::Database::grant();
}

#
# Build dictionary 
#
my $dictFile = '../data/dict.xml';
if (Kalliope::Build::Timestamps::hasChanged($dictFile)) {
    &log ("Making dict... ");
    Kalliope::Build::Dict::create();
    %dict = Kalliope::Build::Dict::parse($dictFile);
    Kalliope::Build::Dict::insert(\%dict);
    Kalliope::Build::Timestamps::register($dictFile);
    &log ("Done");
} else {
    &log ("(Dict not modified)");
}

#
# Keywords
#

&log ("Making keywords... ");
Kalliope::Build::Keywords::clean();
Kalliope::Build::Keywords::insert();
&log("Done");

$rc = $dbh->do("drop table keywords_relation");
$rc = $dbh->do("CREATE TABLE keywords_relation ( 
              keywordid int NOT NULL,
	      otherid int NOT NULL,
	      othertype VARCHAR(20), -- ENUM('digt','person','biografi','hist','keyword','vaerk') NOT NULL,
	      UNIQUE(keywordid,otherid,othertype))");

$sthkeyword = $dbh->prepare("INSERT INTO keywords_relation (keywordid,otherid,othertype) VALUES (?,?,?)");

#
# Build fnavne
#

$poetsFile = '../data/poets.xml';
if (Kalliope::Build::Timestamps::hasChanged($poetsFile)) {
    &log("Making persons... ");
    Kalliope::Build::Persons::create();
    my %persons = Kalliope::Build::Persons::parse($poetsFile);
    Kalliope::Build::Persons::insert(%persons);
    Kalliope::Build::Timestamps::register($poetsFile);
    &log("Done");
} else {
    &log ("(Poets not modified)");
}

&log("Scanning works...");
my @changedWorks = Kalliope::Build::Works::findmodified();
&log("Done. ".($#changedWorks+1)." files have changed.");
&log("Cleaning works...");
Kalliope::Build::Works::clean(@changedWorks);
&log("Done");
&log("Inserting works heads...");
Kalliope::Build::Works::insert(@changedWorks);
&log("Done");

&log("Inserting works bodies...");
Kalliope::Build::Texts::insert();
&log("Done");

if (!$__all) {
    &log('Cleaning firstletters...');
    Kalliope::Build::Firstletters::clean(@changedWorks);
    &log("Done");
}
&log('Inserting firstletters...');
Kalliope::Build::Firstletters::insert(@changedWorks);
&log("Done");


&log('Persons postinsert...');
Kalliope::Build::Persons::postinsert();
&log("Done");

#
# Build biblio
#

&log("Making biblio... ");
Kalliope::Build::Biblio::build();
&log("Done");

exit;



#
# Andet pass af keywords som laver links imellem dem
#

&log("Second pass of keywords... ");
$sth = $dbh->prepare("SELECT * FROM keywords");
$sth->execute();
while ($h = $sth->fetchrow_hashref) {
    open(FILE,'../keywords/'.$h->{'ord'});
    while (<FILE>) { 
	if (/^K:/) {
	    s/^K://;
	    chop;
	    &insertkeywordrelation($_,$h->{'id'},'keyword',$h->{'ord'});
	} elsif (/^F:/) {
	    s/^F://;
	    chop;
	    &insertkeywordrelation($_,$h->{'id'},'person',$h->{'ord'});
        }
    }
    close(FILE)
}
&log("Done");

#
# Build links
#

&log("Build links... ");
$rc = $dbh->do("drop table if exists links");
$rc = $dbh->do("CREATE TABLE links ( 
              id int UNSIGNED DEFAULT '0' NOT NULL PRIMARY KEY auto_increment,
              fid int NOT NULL,
              fhandle char(40) NOT NULL,
              url text NOT NULL,
              beskrivelse text NOT NULL,
              KEY fid_index (fid), 
              UNIQUE (id))");

$sth = $dbh->prepare("SELECT fhandle,fid FROM fnavne WHERE links=1");
$sth->execute;
$sth2= $dbh->prepare("INSERT INTO links (fhandle,fid,url,beskrivelse) VALUES (?,?,?,?)");
while ($fn = $sth->fetchrow_hashref) {
    open (FILE,"../fdirs/".$fn->{'fhandle'}."/links.txt");
    while (<FILE>) {
	$url = $_;
	$desc = <FILE>;
	$sth2->execute($fn->{'fhandle'},$fn->{'fid'},$url,$desc);
    }
    close (FILE)
}
$sth2->finish;
$sth->finish;
&log("Done");

#
# Build v�rker
#

$sth = $dbh->prepare("SELECT count(*) FROM vaerker");
$sth->execute;
($c) = $sth->fetchrow_array;
&log ("Antal v�rker: $c");
$sth->finish;
$sth = $dbh->prepare("SELECT count(*) FROM vaerker WHERE type='p'");
$sth->execute;
($c) = $sth->fetchrow_array;
&log("  heraf prosa: $c");
$sth->finish;

#
# Timeline ------------------------------------------------------------
#

&log ("Making timeline... ");
Kalliope::Build::Timeline::build(%persons);

#
# Xrefs
#

&log ("Building Xrefs...");
Kalliope::Build::Xrefs::build();
&log ("Done");

#
# Build hasHenvisninger 
#

pis:
&log ("Detekterer henvisninger...");
Kalliope::Build::Persons::buildHasHenvisninger($dbh);
&log ("Done");

#$dbh->disconnect;


#
# Build haystack -------------------------------------------------------------
#

$rc = $dbh->do("DROP TABLE IF EXISTS haystack");
$rc = $dbh->do("CREATE TABLE haystack ( 
              id int,
	      id_class enum('Kalliope::Poem',
	                    'Kalliope::Keyword',
	                    'Kalliope::Work',
			    'Kalliope::Person'),
	      titel text,
	      fid char(40) NOT NULL,
	      hay text,
	      lang char(2) NOT NULL,
	      INDEX (fid),
	      INDEX (lang))");

my $sth_hay_ins = $dbh->prepare("INSERT INTO haystack (id,id_class,titel,hay,lang,fid) VALUES (?,?,?,?,?,?)");

# Poems
&log ("Inserting poem hay");
my $sth = $dbh->prepare("SELECT did,f.fid,indhold,underoverskrift,titel,sprog FROM digte AS d,fnavne AS f WHERE d.fid = f.fid AND d.afsnit = 0"); 
$sth->execute;
while ($h = $sth->fetchrow_hashref) {
    my $hay = Kalliope::Strings::stripHTML("$$h{titel} $$h{underoverskrift} $$h{indhold}");
    $sth_hay_ins->execute($$h{did},'Kalliope::Poem',$$h{titel},$hay,$$h{sprog},$$h{fid});
}

# Persons
print "Inserting person hay\n";
my $sth = $dbh->prepare("SELECT fid,efternavn,fornavn,sprog FROM fnavne"); 
$sth->execute;
while ($h = $sth->fetchrow_hashref) {
    my $hay = "$$h{fornavn} $$h{efternavn}";
    $sth_hay_ins->execute($$h{fid},'Kalliope::Person',$hay,$hay,$$h{sprog},'');
}

# Works 
print "Inserting works hay\n";
my $sth = $dbh->prepare("SELECT vid,fnavne.fid,titel,sprog FROM fnavne,vaerker WHERE fnavne.fid = vaerker.fid"); 
$sth->execute;
while ($h = $sth->fetchrow_hashref) {
    my $hay = "$$h{titel}";
    $sth_hay_ins->execute($$h{vid},'Kalliope::Work',$hay,$hay,$$h{sprog},$$h{fid});
}

# Keywords 
print "Inserting keyword hay\n";
my $sth = $dbh->prepare("SELECT id,titel,beskrivelse FROM keywords"); 
$sth->execute;
while ($h = $sth->fetchrow_hashref) {
    my $hay = Kalliope::Strings::stripHTML("$$h{titel} $$h{beskrivelse}");
    $sth_hay_ins->execute($$h{id},'Kalliope::Keyword',$$h{titel},$hay,'dk','');
}

print "Creating FULLTEXT index...\n";
$dbh->do('CREATE FULLTEXT INDEX haystackidx ON haystack (titel,hay)');


sub log {
   my $text = shift;
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   print sprintf("<%02d:%02d:%02d> %s\n",$hour,$min,$sec,$text);
}
