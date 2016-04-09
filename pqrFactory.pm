#/usr/bin/perl
# 8th April 2016
#
#	By Bruno Cuevas
#
=head1 Class Name

PDB File

=head1 Description

This class allows us to create PQR files from PDB and RTF files that we have
obtained previously from SwissProt.

=head1 Synopsis
 my $factory = pqrFactory -> new (
 	'pbd_filename' => $ARGV[0],
	'rtf_filename' => $ARGV[1],
	'pqr_outfile' => $ARGV[2]
 );
 $pqrFactory -> loadPDB	;
 $pqrFactory -> parsePDB;
 $pqrFactory -> loadRTF	;
 $pqrFactory -> parseRTF;
 $pqrFactory -> builtPQR;

=cut
package pqrFactory;
use strict;
use warnings;
use Moose;
use atom;

has 'pdb_filename' => (
	'is' => 'rw',
	'isa' => 'Str'
);
has 'rtf_filename' => (
	'is' => 'rw',
	'isa' => 'Str'
);
has 'pqr_outfile' => (
	'is' => 'rw',
	'isa' => 'Str'
);
has 'pdb_info' => (
	'is' => 'rw',
	'isa' => 'ArrayRef[Str]',
	'required' => 0
);
has 'rtf_info' => (
	'is' => 'rw',
	'isa' => 'ArrayRef[Str]',
	'required' => 0
);
my %charm2pqr_radius = (
	'CB' => 1.9924,
	'C=' => 2.0000,
	'CR' => 2.1750,
	'O=' => 1.7000,
	'OR' => 1.7700,
	'N?' => 1.8500,
	'HO' => 0.2245,
	'HN' => 0.2245,
	'HC' => 1.3500
);
# has 'chains' => (
# 	'is' => 'rw',
# 	'isa' => 'HashRef[chains]'
# );
has 'atom_entries' => (
	'is' => 'rw',
	'isa' => 'HashRef[atom]',
	'required' => 0
);
sub loadPDB {
	if (@_) {
		my ($self) = @_	;
		my $filename = $self -> pdb_filename;
		if ($filename =~ /\.pdb$/ ) {
			if (open(FILE, $filename)) {
				print "loading info from $filename\n";
				my @file = <FILE>;
				$self -> pdb_info(\@file)
					or die "ERROR 2 : Unable to load $filename\n";
				print "done\n";
				return 1;
			} else {
				print "ERROR 1 : Unable to access to $filename\n";
			}
		}
	} else {
		print "Usage : \$obj -> loadPDB(filename.pdb)\n";
	}
}
sub parsePDB {
	if (@_) {
		my ($self) = @_ ;
		my @pdb_file = @{$self->pdb_info};
			my $line = shift(@pdb_file);
		my %atom_hash;
		print "parsing PDB\n";
		while (@pdb_file) {
			my $line = shift(@pdb_file)	;
			if ($line =~ /ATOM\s{2}\s{1,4}(\d{1,4})\s{1,2}(\w{1,4})\s{1,2}(\w{3})\s{5}(\d{1})\s{6}(.\d{1,3}\.\d{3})\s{2}(.\d{1,3}\.\d{3})\s{2}(.\d{1,3}\.\d{3})\s{2}(\d\.\d{2})\s{2}(\d\.\d{2})\s*LIG/) {

				my $pos = $1			;
				my $atom_type = $2 		;
				my $chain = $3			;
				my $coordinates_x = $5	;
				my $coordinates_y = $6	;
				my $coordinates_z = $7	;
				my $ocupancy	  = $8	;
				my $termic_factor = $9	;
					$coordinates_x =~ s/\s//g;
					$coordinates_y =~ s/\s//g;
					$coordinates_z =~ s/\s//g;
					$ocupancy	   =~ s/\s//g;
					$termic_factor =~ s/\s//g;

				my $current_atom = atom -> new(
					'position' 		=> $pos,
					'atom_type' 	=> $atom_type,
					'chain' 		=> $chain,
					'coordinates_x' => $coordinates_x,
					'coordinates_y' => $coordinates_y,
					'coordinates_z' => $coordinates_z,
					'ocupancy'		=> $ocupancy,
					'termic_factor' => $termic_factor,

					'element'		=> 'null',
					'charge'		=> 0
				);
				$atom_hash{$atom_type} = $current_atom;
			}
		}
		$self->atom_entries(\%atom_hash);
		print "done\n";
		return 1;
	}
}

sub showPDB {
	if (@_) {
		my ($self) = @_ ;
		if ($self->atom_entries) {
			my @entries = sort keys %{$self->atom_entries};
			foreach my $current_atom (@entries)	{
				print $self -> atom_entries -> {$current_atom} -> position , "\t";
				print $self -> atom_entries -> {$current_atom} -> atom_type , "\t";
				print $self -> atom_entries -> {$current_atom} -> chain, "\t";
				print $self -> atom_entries -> {$current_atom} -> coordinates_x, " / ";
				print $self -> atom_entries -> {$current_atom} -> coordinates_y, " / ";
				print $self -> atom_entries -> {$current_atom} -> coordinates_z, "\n";
			}
		}
	}
}
sub loadRTF {
	if (@_) {
		my ($self) = @_ ;
		my $filename = $self->rtf_filename;
		if (open(RTF_FILE, $filename)) {
			print "loading RTF from $filename\n";
			my @rtf_file = <RTF_FILE> ;
			$self -> rtf_info(\@rtf_file) or
				die "ERROR 2 : Unable to load $filename\n";
			print "done\n";
			return 1;
		} else {
			die "ERROR 1 : Unable to access $filename\n";
		}
	}
}
sub parseRTF {
	if (@_) {
		my ($self) = @_ ;
		my @rtf_info	= @{$self->rtf_info}	;
		my $iter = 0 ;
		print "parsing RTF\n";
		while (@rtf_info) {
			my $line = shift(@rtf_info);
			if ($line =~ /^ATOM/) {
				my ($label, $type, $charge) = $line =~ /^ATOM\s*(\w{1,4})\s*(.{1,4})\s*(.\d{1,2}\.\d{4})/;
				$charge =~ s/\s//g;
				$type	=~ s/\s//g;
				if (exists $self -> atom_entries -> {$label}) {
					$self -> atom_entries -> {$label} -> charm_type($type);
					$self -> atom_entries -> {$label} -> charge($charge);
				} else {
					die "ERROR 3 : Incoherence between RTF and PDB";
				}
			}
		}
		print "done\n";
		return 1;
	}
}

sub builtPQR {
	if (@_) {
		my ($self) = @_ ;
		my $fileout = $self -> pqr_outfile;

		if (open(PQRFILE, '>'.$fileout)) {
			print "building PQR file\n";
			my $iter = 0;
			my $length_control	;
			my $refill			;
			my $length_chain = scalar(keys %{$self->atom_entries});

			print PQRFILE 'REMARK    File generated through pdb2pqr by BrunoCuevas', "\n";
			print PQRFILE 'REMARK    Mail: brunocuevaszuviria@gmail.com', "\n";
			while ($iter <= $length_chain) {
				$iter ++			;
				foreach my $atomlabel (sort keys %{$self-> atom_entries}) {
					my $position = $self->atom_entries -> {$atomlabel} -> position;
					#print $position, ':', $iter, "\n";
					if ($position eq $iter) {

						my $formated_label = $atomlabel;
							$length_control = length($formated_label)	;
							($length_control eq 1) and $formated_label = '  '.$formated_label.' ';
							($length_control eq 2) and $formated_label = ' '.$formated_label.' ';
							($length_control eq 3) and $formated_label = ' '.$formated_label;
							($length_control eq 4) and $formated_label = $formated_label;
						my $formated_serial_number = $self->atom_entries -> {$atomlabel} -> position;
							$length_control = length($formated_serial_number) ;
							$length_control < 2 and $formated_serial_number = ' '.$formated_serial_number;
						my $formated_residue = $self->atom_entries -> {$atomlabel} -> chain;
						my $formated_coordinates_x = $self -> atom_entries -> {$atomlabel} -> coordinates_x;



							$refill			=	8 - length($formated_coordinates_x);
							$formated_coordinates_x = (' 'x $refill).$formated_coordinates_x;
						my $formated_coordinates_y = $self -> atom_entries -> {$atomlabel} -> coordinates_y;

							$refill			=	8 - length($formated_coordinates_y);
							$formated_coordinates_y = (' 'x $refill).$formated_coordinates_y;
						my $formated_coordinates_z = $self -> atom_entries -> {$atomlabel} -> coordinates_z;

							$refill			=	8 - length($formated_coordinates_z);
							$formated_coordinates_z = (' ' x $refill).$formated_coordinates_z;

						my $radius_label	 = $self -> atom_entries -> {$atomlabel} -> charm_type;

						my $formated_radius;
						foreach my $radius_charm_label (sort keys %charm2pqr_radius) {
							if ($radius_label =~ m/^$radius_charm_label/) {
								$formated_radius = $charm2pqr_radius{$radius_charm_label};
								last;
							}
						}

							if ($formated_radius =~ /\d{1,2}\.(\d{1,4})/) {
								$formated_radius = $formated_radius.'0'x(4-length($1));
							} else {
								$formated_radius = $formated_radius.'.0000';
							}
							$refill			=	8 - length($formated_radius);
							$formated_radius = (' ' x $refill).$formated_radius;
						my $formated_charge		   = $self -> atom_entries -> {$atomlabel} -> charge;

							$refill			=	7 - length($formated_charge);
							$formated_charge = (' ' x $refill).$formated_charge;

						print PQRFILE 'ATOM'.' 'x5;
						print PQRFILE $formated_serial_number.' ';
						print PQRFILE $formated_label.' ';
						print PQRFILE $formated_residue;
						print PQRFILE ' 'x5;
						print PQRFILE '1';
						print PQRFILE ' 'x4;
						print PQRFILE $formated_coordinates_x, $formated_coordinates_y, $formated_coordinates_z, $formated_charge, $formated_radius, "\n";

					}
				}

			}
			print PQRFILE 'END';
			close (PQRFILE);
			print "done\n";
			return 1;
		} else {
			die "ERROR 1 : couldn't access to $fileout\n";
		}
	} else  {
		die "whadafak?\n";
	}
}

#Don't writte bellow this line
1;
