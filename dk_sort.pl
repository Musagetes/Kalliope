#En lille speciel sorterings sub til gammeldags Aa, etc.

sub dk_sort {
	local($ai) = "\L$a";
	$ai =~ s/aa/�/;
	local($bi) = "\L$b";
	$bi =~ s/aa/�/;
	if ($ai lt $bi) {
		-1;
	}
	elsif ($ai eq $bi) {
		0;
	}
	else { 1; }
}

sub dk_sort2 { 
    my $aa = lc($a->{'sort'});
    $aa =~ s/aa/�/ig;
    my $bb = lc($b->{'sort'});
    $bb =~ s/aa/�/ig;
    if ($aa lt $bb) {
	-1;
    } elsif ($aa eq $bb) {
	0;
    } else {
	1;
    }
}

