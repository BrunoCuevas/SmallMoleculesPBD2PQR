use strict;
use warnings;
use pdb_file;
my $pdb_object = pdb_file -> new(
	'pdb_filename' => 'butein_optimized.pdb',
	'rtf_filename' => 'butein_optimized.rtf',
	'pqr_outfile' => 'butein_optimized_false.pqr'
);
$pdb_object -> loadPDB();

$pdb_object -> parsePDB();
$pdb_object -> showPDB();
$pdb_object -> loadRTF();
$pdb_object -> parseRTF();
$pdb_object -> builtPQR();
