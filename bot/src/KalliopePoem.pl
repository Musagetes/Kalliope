
package KalliopePoem;

use lib "..";

use Kalliope::Person;
use Kalliope::Work;
use Kalliope::Poem;

sub get { 
    my $line = shift;
    unless ($line =~ /^vis digt/i) { 
	return '�h?';
   }

   my ($longdid) = $line =~ /digt *([^ ]+) *$/i;
   return 'Hvilket digt t�nker du p�?' unless $longdid;

   return "Jeg kender ikke digtet $longdid ..." unless Kalliope::Poem::exist($longdid);

   my $poem = new Kalliope::Poem (longdid => $longdid);

   my $result = "$longdid er ";
   $result .= $poem->clickableTitle;
   $result =~ s/<[^>]*>//g;

   return $result;	      
}

1;
