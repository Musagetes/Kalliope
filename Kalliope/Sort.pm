package Kalliope::Sort;

#  Copyright (C) 1999-2001 Jesper Christensen 
#
#  This script is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this script; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#  Author: Jesper Christensen <jesper@kalliope.org>
#
#  $Id$

sub sort { 
    my ($a,$b) = @_;
    my $aa = mylc($a->{'sort'});
    $aa =~ s/aa/�/g;
    $aa =~ tr/���������������������������/aaaa��ceeeeiiiidnoooo�uuuyy/;

    my $bb = mylc($b->{'sort'});
    $bb =~ s/aa/�/g;
    $bb =~ tr/���������������������������/aaaa��ceeeeiiiidnoooo�uuuyy/;
    return $aa cmp $bb;
}

sub mylc {
    my $str = shift || '';
    $str =~ tr/A-Z������������������������������/a-z������������������������������/;
    return $str;
}

sub myuc {
    my $str = shift;
    $str =~ tr/a-z������������������������������/A-Z������������������������������/;
    return $str;
}

sub sortObject {
    my ($a,$b) = @_;
    if ($a && $b) {
	return mylc($a->sortString) cmp mylc($b->sortString);
    } else {
        return 0
    };
}

1;
