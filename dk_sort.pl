#En lille speciel sorterings sub til gammeldags Aa, etc.

sub dk_sort {
	local($ai) = "\L$a";
	$ai =~ s/aa/�/;
	local($bi) = "\L$b";
	$bi =~ s/aa/�/;
        return $ai cmp $bi;
}

sub dk_sort2 { 
    my $aa = mylc($a->{'sort'});
    $aa =~ s/aa/�/g;
    $aa =~ tr/���������������������������/aaaa��ceeeeiiiidnoooo�uuuyy/;

    my $bb = mylc($b->{'sort'});
    $bb =~ s/aa/�/g;
    $bb =~ tr/���������������������������/aaaa��ceeeeiiiidnoooo�uuuyy/;
    return $aa cmp $bb;
}

sub mylc {
    my $str = shift;
    $str =~ tr/A-Z������������������������������/a-z������������������������������/;
    return $str;
}
