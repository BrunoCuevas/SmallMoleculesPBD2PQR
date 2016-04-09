use strict;
use warnings;
use pqrFactory;
my $pdb_object = pqrFactory-> new(
	'pdb_filename' => $ARGV[0],
	'rtf_filename' => $ARGV[1],
	'pqr_outfile' => $ARGV[2]
);
$pdb_object -> loadPDB();

$pdb_object -> parsePDB();
#$pdb_object -> showPDB();
$pdb_object -> loadRTF();
$pdb_object -> parseRTF();
$pdb_object -> builtPQR();
