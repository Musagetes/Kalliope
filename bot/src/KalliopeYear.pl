
package KalliopeYear;

use lib "..";

use Kalliope::Timeline;

sub get { 
    my $line = shift;
    unless ($line =~ /^�r/i) { 
	return '�h?';
   }

   my ($year) = $line =~ /�r *([^ ]+) *$/;
   return 'Hvilket �r t�nkte du p�?' unless $year;

   my @events = Kalliope::Timeline::getEventsInYear($year);

   return "Der skete vist ikke noget i �r $year ..." unless $#events >= 0;

   my $result = "I $year skete der f�lgende: ";
   foreach $event (@events) {
       my $descr = $event->{'descr'};
       $descr =~ s/<[^>]*>//g;
       $descr =~ s/\.$//g;
       $result .= $descr.", ";
   }
   $result =~ s/, $/./;
   return $result;

}

1;
