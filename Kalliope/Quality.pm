
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

package Kalliope::Quality;
use strict;

my %items = (
     korrektur1 => { name     => 'f�rste korrekturl�sning',
                     icon_on  => 'gfx/tb_yes.gif',
		     icon_off => 'gfx/tb_no.gif' },
     korrektur2 => { name     => 'anden korrekturl�sning',
                     icon_on  => 'gfx/tb_yes.gif',
		     icon_off => 'gfx/tb_no.gif' },
     korrektur3 => { name     => 'tredie korrekturl�sning',
                     icon_on  => 'gfx/tb_yes.gif',
		     icon_off => 'gfx/tb_no.gif' },
     kilde      => { name     => 'kildeangivelse',
                     icon_on  => 'gfx/tb_yes.gif',
		     icon_off => 'gfx/tb_no.gif' },
     side       => { name     => 'sidehenvisninger',
                     icon_on  => 'gfx/tb_yes.gif',
		     icon_off => 'gfx/tb_no.gif' } 
);

my @order = qw/ korrektur1 korrektur2 korrektur3 kilde side /;

sub new {
    my ($class,$quality) = @_;
    my $self = bless {},$class;
    @{$self->{'array'}} = split ',',$quality;
    %{$self->{'hash'}} = map { $_ => 1 } @{$self->{'array'}};
    return $self;
}

sub asHTML {
   my $self = shift;
   my $HTML;
   foreach my $key (@order) {
      my $status = $self->{'hash'}->{$key};
      my %item = %{$items{$key}};
      my $icon = $status ? $item{'icon_on'} : $item{'icon_off'};
      my $alt = $status ? 'Har ' : 'Mangler ';
      $alt .= $item{'name'};
      $HTML .= qq|<IMG SRC="$icon" ALT="$alt" TITLE="$alt">|;
   }
   return $HTML;
}
