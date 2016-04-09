#/usr/bin/perl
# 8th April 2016
#
#	By Bruno Cuevas
#
package atom;
use Moose;
use warnings;
use strict;

has 'position' => (
	'is' => 'rw',
	'isa' => 'Int'
);

has 'atom_type' => (
	'is' => 'rw',
	'isa' => 'Str'
);

has 'chain' => (
	'is' => 'rw',
	'isa' => 'Str'
);

has 'coordinates_x' => (
	'is' => 'rw',
	'isa' => 'Num'
);

has 'coordinates_y' => (
	'is' => 'rw',
	'isa' => 'Num'
);

has 'coordinates_z' => (
	'is' => 'rw',
	'isa' => 'Num'
);

has 'ocupancy' => (
	'is' => 'rw',
	'isa' => 'Num'
);

has 'termic_factor' => (
	'is' => 'rw',
	'isa' => 'Num'
);

has 'element' => (
	'is' => 'rw',
	'isa' => 'Str'
);

has 'charge' => (
	'is' => 'rw',
	'isa' => 'Str'
);
has 'charm_type' => (
	'is' => 'rw',
	'isa' => 'Str',
	'required' => 0
);
has 'charge' => (
	'is' => 'rw',
	'isa' => 'Num',
	'required' => 0
);
sub return_coordinates {
	if (@_) {
		my ($self) = @_ ;
		my $coords = $self -> coordinates_x;
			$coords = $coords.' '.$self->coordinates_y;
			$coords = $coords.' '.$self->coordinates_z;
		return $coords;
	}
}
1;
