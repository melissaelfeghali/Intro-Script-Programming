#!/usr/bin/perl

use strict; 
my @array ; 

# hash for codon table 
my %codon_table = (
			'UCA' => 'S','UCC' => 'S', 'UCG' => 'S', 'UCU' => 'S', 'AGC' => 'S', 'AGU' => 'S', # Serine
			'UUC' => 'F','UUU' => 'F', # Phenylalanine
			'UUA' => 'L','UUG' => 'L', 'CUA' => 'L', 'CUC' => 'L', 'CUG' => 'L', 'CUU' => 'L', # Leucine
			'UAC' => 'Y','UAU' => 'Y', # Tyrosine
			'UAA' => '_','UAG' => '_', 'UGA' => '_', # Stop
			'UGC' => 'C','UGU' => 'C', # Cysteine
			'UGG' => 'W', # Tryptophan
			'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCU' => 'P', # Proline
			'CAU' => 'H', 'CAC' => 'H', # Histidine
			'CAA' => 'Q', 'CAG' => 'Q', # Glutamine
			'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGU' => 'R', 'AGA' => 'R', 'AGG' => 'R', # Arginine
			'AUA' => 'I', 'AUC' => 'I', 'AUU' => 'I', # Isoleucine
			'AUG' => 'M', # Methionine
			'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACU' => 'T', # Threonine
			'AAC' => 'N', 'AAU' => 'N', # Asparagine
			'AAA' => 'K', 'AAG' => 'K', # Lysine
			'GUA' => 'V', 'GUC' => 'V', 'GUG' => 'V', 'GUU' => 'V', # Valine
			'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCU' => 'A', # Alanine
			'GAC' => 'D', 'GAU' => 'D', # Aspartic Acid
			'GAA' => 'E', 'GAG' => 'E', # Glutamic Acid
			'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGU' => 'G'  # Glycine
		);

open (FASTAFILE, "ACE2Sequences.fasta") || die "Cannot open file because: $! \n" ;

# Remove carriage returns from lines 
while(defined(my $line= <FASTAFILE>))
{
	local $/ = "\r\n" ;
	chomp($line) ;
	@array = (@array, $line) ;
}

my @headers = () ;
my $count = -1 ;
my @sequences = () ;

# Put headers in an array and sequences in another array 
foreach my $str (@array)
{
	if ($str =~ /^>/)
	{
		$count ++ ;
		push @headers, $str ; 
	}

	elsif ($count==0)
	{
		@sequences[0] = @sequences[0] . $str ;
	}

	elsif ($count > 0)
	{
		@sequences[$count] = @sequences[$count] . $str ;
	}
}

close FASTAFILE || die "Cannot close file because: $! \n" ;

open (MYFILE, ">translated_file.txt") ;

for (my $i = 0; $i <= $#sequences; $i ++) # For each sequence 
{
	# Get the ID from the header 
	my @id = split (/ /, @headers[$i]);
	my $seq_id = @id[0] ;
	
	# Write the ID to the new file 
	print MYFILE "$seq_id \n\n" ;

	my @protein1 = ();
	my @protein2 = ();
	my @protein3 = ();
	my $rna_seq = "";

	# Transcribe DNA sequence to RNA 
	for (my $k = 0; $k <= length(@sequences[$i]); $k++)
	{
		if (substr(@sequences[$i], $k, 1) eq 'A')
		{
			$rna_seq = $rna_seq . 'U';
		}

		elsif (substr(@sequences[$i], $k, 1) eq 'G')
		{
			$rna_seq = $rna_seq . 'C';
		}

		elsif (substr(@sequences[$i], $k, 1) eq 'T')
		{
			$rna_seq = $rna_seq . 'A';
		}

		elsif (substr(@sequences[$i], $k, 1) eq 'C')
		{
			$rna_seq = $rna_seq . 'G';
		}
	}

	# Protein from first reading frame 
	for (my $j = 0; $j <= length($rna_seq); $j+=3)
	{
		my $codon = substr($rna_seq, $j, 3) ;
		if (length($codon) < 3)
		{ last ; }
		my $amino_acid = $codon_table{$codon} ;
		@protein1 = (@protein1, $amino_acid);
	}

	my $p1 = join('', @protein1) ; 
	print MYFILE "---------Reading Frame 1---------\n$p1 \n\n";

	# Protein from second reading frame 
	for (my $j = 1; $j <= length($rna_seq); $j+=3)
	{
		my $codon = substr($rna_seq, $j, 3) ;
		if (length($codon) < 3)
		{ last ; }
		my $amino_acid = $codon_table{$codon} ;
		@protein2 = (@protein2, $amino_acid);
	}

	my $p2 = join('', @protein2) ;
	print MYFILE "---------Reading Frame 2---------\n$p1 \n\n";

	# Protein from third reading frame 
	for (my $j = 2; $j <= length($rna_seq); $j+=3)
	{
		my $codon = substr($rna_seq, $j, 3) ;
		if (length($codon) < 3)
		{ last ; }
		my $amino_acid = $codon_table{$codon} ;
		@protein3 = (@protein3, $amino_acid);
	}

	my $p3 = join('', @protein3) ;
	print MYFILE "---------Reading Frame 3---------\n$p1 \n\n";
}

close MYFILE || die "Cannot close file because: $! \n" ;