
package KalliopeDag;

use lib "..";

use Kalliope::Timeline;

sub get { 
    my $line = shift;
    $line = "$line ";
    unless ($line =~ /^dagen/i) { 
	return '�h?';
   }

    my ($dag,$md);

   if ($line =~ /idag/i) {
       (undef,undef,undef,$dag,$md,undef,undef,undef,undef)=localtime(time);
       $md++;
   } elsif ($line =~ /imorgen/i) {
       (undef,undef,undef,$dag,$md,
	undef,undef,undef,undef)=localtime(time+24*60*60);
       $md++;
   } elsif ($line =~ /ig�r/i) {
       (undef,undef,undef,$dag,$md,
	undef,undef,undef,undef)=localtime(time-24*60*60);
       $md++;
   } else {
       ($dag,$md) = $line =~ /dagen *([^ \/-]+)[ \/-]([^ ]+) *$/i;
   }

   return 'Hvilket dag t�nkte du p�?' unless $dag;

   return "Der er da ikke $md m�neder p� et �r..." if $md > 12;

   return "Den dato giver r�v mening ..." if $md < 1 || $dag < 1 || $dag > 31;

   my %events = Kalliope::Timeline::getEventsGivenMonthAndDay($md,$dag);

   my @years = keys %events;

   return "Der er vist aldrig sket noget $dag/$md ..." unless $#years >= 0;

   my $result = "P� $dag/$md er der sket f�lgende: ";
   foreach $year (sort @years) {
       my $descr = $events{$year};
       $descr =~ s/<[^>]*>//g;
       $descr =~ s/\.$//g;
       $result .= $descr." (".$year."); ";
   }
   $result =~ s/; $/./;
   return $result;

}

1;
