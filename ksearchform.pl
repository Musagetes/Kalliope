#!/usr/bin/perl

do 'kstdhead.pl';

@ARGV = split(/\?/,$ARGV[0]);
$LA=$ARGV[0];

&kheaderHTML('S�gning');

do 'ksearch.ovs';

#&kcenterpageheader($ovs1{$LA});

#Indled kasse til selve teksten
beginwhitebox("","","");

print "<FORM METHOD=POST ACTION=\"ksearchresult.pl?$LA\">";
print "$ovs2{$LA} <INPUT TYPE=text NAME=string size=30>&nbsp;";
print "<INPUT TYPE=submit VALUE=\"$ovs10{$LA}\">";
#print "<INPUT TYPE=\"Reset\" VALUE=\"$ovs11{$LA}\"><BR><BR>";
#print "Logik:<BR>\n";
#print "<INPUT TYPE=radio NAME=logic VALUE=\"or\" CHECKED>Eller<BR>";
#print "<INPUT TYPE=radio NAME=logic VALUE=\"and\" >Og<BR>";

#Udskriv forfatter selector...

#print "$ovs3{$LA}: <FONT SIZE=2><select name=\"fdata\">\n";
#print "<FONT SIZE=2>";
#print "<option value=\"*%$ovs22{$LA}\">$ovs4{$LA}";

#open (IN, "data.$LA/fnavne.txt");
#while (<IN>) {
#	chop($_);chop($_);
#	($fhandle,$ffornavn,$fefternavn,$ffoedt,$fdoed) = split(/=/);
#	$fefternavn =~ s/^Aa/�/;	#Et lille hack til at klare sorteringsproblemet med Aa.
#	push(@liste,"$fefternavn%$ffornavn%$fhandle%$ffoedt%$fdoed");
#}
#close(IN);
#foreach (sort @liste) {
#	@k=split(/%/);
#	$k[0] =~ s/�/Aa/;
#	$fdata="$k[2]%$k[1] $k[0]";
#	print "<option value=\"$fdata\">$k[0], $k[1]";
#}
#print "</select></FONT><BR><BR>";


#udskriv resten af FORMen.

#print "<INPUT TYPE=radio NAME=hvor VALUE=\"begge\" CHECKED> $ovs5{$LA}.<BR>";
#print "<INPUT TYPE=radio NAME=hvor VALUE=\"indhold\"> $ovs6{$LA}<BR>";
#print "<INPUT TYPE=radio NAME=hvor VALUE=\"titler\"> $ovs7{$LA}<BR>";
#print "<INPUT TYPE=checkbox NAME=whole> $ovs8{$LA}<BR>";
#print "Indstillinger:<BR>\n";
#print "<INPUT TYPE=checkbox NAME=case>Forskel p� store og sm� bogstaver<BR>";
#print "<INPUT TYPE=checkbox NAME=aa CHECKED>Aa og � er ens<BR>";
print "</FORM>";
#print "<FONT SIZE=2><I>Flere ord kan knyttes sammen med \"...\" til �n s�geterm<BR>";
#print "pt. bruges kun f�rste s�geterm.</I><FONT><BR><BR>";

#if (-e "data.$LA/searchhelp.html") {
#    print "<BR><BR>\n";
#    print "<A HREF=\"ksearchhelp.pl?$LA\">$ovs9{$LA}</A>";
#}
print '<UL><LI><I>S�gemaskinen er stadig under udvikling. ';
print 'Den s�ger udelukkende i digtenes indhold eller titel.</I>';
print '<LI><I>S�g kun p� eet ord. Fors�g at v�lge det mest us�dvanlige ord i det digt du �nsker at finde.</I>';
print '</UL>';
#Afslut kassen
endbox();

&kfooterHTML;
