#!/usr/bin/perl

use strict ;

open (PROTEIN, "translated_file.txt") || die "Cannot open file because: $! \n" ;

my @data = <PROTEIN> ;

close PROTEIN; 

my @proteins = () ;
my @headers = () ;

foreach my $line (@data)
{
	# discard blank lines
	if ($line =~ /^\s*$/) 
	{ next; } 

	# discard reading frame lines
	elsif($line =~ /^--/) 
	{next; }

	# Keep fasta header line
	elsif ($line =~ /^>/)
	{ push @headers, $line ; }

	# keep line, add to protein array
	else 
	{ push @proteins, $line ; }
}

# Multiple codons are assigned to the same key 
my %amino_acids = (
				    'I' => [ qw'AUU AUC AUA' ], 
				    'L' => [ qw'CUU CUC CUA CUG UAA UUG' ],
				    'V' => [ qw'GUU GUC GUA GUG' ],
				    'F' => [ qw'UUU UUC' ],
				    'M' => [ qw'AUG' ],
				    'C' => [ qw'UGU UGC' ],
				    'A' => [ qw'GCU GCC GCA GCG' ],
				    'G' => [ qw'GGU GGC GGA GGG' ],
				    'P' => [ qw'CCU CCC CCA CGG' ],
				    'T' => [ qw'ACU ACC ACA ACG' ],
				    'S' => [ qw'TCT TCC TCA TCG AGT AGC' ],
				    'Y' => [ qw'TAT TAC' ],
				    'W' => [ qw'TGG' ],
				    'Q' => [ qw'CAA CAG' ],
				    'N' => [ qw'AAT AAC' ],
				    'H' => [ qw'CAT CAC' ],
				    'E' => [ qw'GGA GAG' ],
				    'D' => [ qw'GAT GAC' ],
				    'K' => [ qw'AAA AAG' ],
				    'R' => [ qw'CGT CGC CGA CGG AGA AGG' ],
				    '_' => [ qw'TAA TAG TGA' ] );

open (DNA, ">rev_translation.txt") || die "Cannot write to file because: $! \n" ;

my $frame = 0 ;
my $header = 0 ;
print DNA "@headers[0]\n\n";

for (my $i =0; $i <= $#proteins; $i ++)
{
	if ($frame < 3)
	{ 
		print DNA "-------Reading Frame $frame-------\n\n" ; 
		$frame ++ ; }

	else
	{
		$header ++ ;
		print DNA "@headers[$header]\n\n";
		$frame = 1 ;
		print DNA "-------Reading Frame $frame-------\n\n" ;
		$frame ++ ;
	}

	my $numb_dna = 1;

	while ($numb_dna < 4)
	{
		my @rna_seq = () ;
		my @codons = () ;
		my $aa = "" ;
		my $c = "" ;
		my $rna = "" ;

		for (my $k = 0; $k <= length(@proteins[$i]); $k ++)
		{
			$aa = substr(@proteins[$i], $k, 1) ;
			my $count = -1;

			for my $option (@{$amino_acids{$aa}})
			{
				$count ++ ;
			}

			my $rand = int(rand($count)); 
			$c = $amino_acids{$aa}[$rand] ;
			@rna_seq = (@rna_seq, $c) ;
		}
		
		$rna = join('', @rna_seq) ;
		my $dna = $rna ;
		$dna =~ s/U/T/g ;
		print DNA "#Corresponding DNA sequence $numb_dna:\n$dna \n\n"; 

		$numb_dna ++ ;
	}
	
}

close DNA || die "Cannot close file because: $! \n" ;




