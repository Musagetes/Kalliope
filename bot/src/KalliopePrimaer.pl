
package KalliopePrimaer;

use lib "..";

use Kalliope::Person;

sub get { 
    my $line = shift;
    unless ($line =~ /^prim�r/i) { 
	return '�h?';
   }

   my ($fhandle) = $line =~ /prim�r *([^ ]+) *$/;
   return 'Hvilket navn ville du se prim�r litteratur for?' unless $fhandle;

   return "Jeg kender ingen $fhandle ..." unless Kalliope::Person::exist($fhandle);

   my $person = new Kalliope::Person (fhandle => $fhandle);

   $filename = "../fdirs/$fhandle/primaer.txt";

   return "Jeg kender intet prim�rlitteratur for ".$person->name."." unless -e $filename;

   my $result = $person->name."s prim�rlitteratur er ";

   open (FILE,$filename);
   $result .= join ' *** ', <FILE>;

   $result =~ s/\n//g;
   $result =~ s/<[^>]*>//g;

   return $result;	      
}

1;
