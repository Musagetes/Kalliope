
package KalliopeWorks;

use lib "..";

use Kalliope::Person;
use Kalliope::Work;
use Kalliope::PersonHome;

sub get { 
    my $line = shift;
    unless ($line =~ /^v�rker/i) { 
	return '�h?';
   }

   my ($fhandle) = $line =~ /v�rker *([^ ]+) *$/;
   return 'Hvilket navn ville du se v�rker for?' unless $fhandle;

   return "Jeg kender ingen $fhandle ..." unless Kalliope::Person::exist($fhandle);

   my $person = Kalliope::PersonHome::findByFhandle($fhandle);

   my $result = $person->name."s v�rker er ";
   my @works = ($person->poeticalWorks,$person->proseWorks);
   $result .= join ", ",
              map { $_->titleWithYear } 
  	      @works;
   return $result;	      
}

1;
