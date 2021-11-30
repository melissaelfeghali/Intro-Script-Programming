#!/usr/bin/perl -l
use strict ;

# Subroutine to check if file in given path exists 
# Exits if file does not exists
sub check_file_path 
{
	my ($file) = @_;

	# Check if file exists 
	unless (-e $file)
	{
		print "File \"$file\" does not seem to exist ! \n" ; exit;
	}
}

# Subroutine to get data from a file given its path/name 
sub get_file_data 
{
	my ($file) = @_;

	# Initialize variable 
	my @filedata = () ;

	# Check if file opens 
	open(GETDATA, $file) || die "Can't open file because: $! \n" ;
	
	@filedata = <GETDATA> ;

	#Close the file 
	close MYFILE || "Can't close file because: $! \n" ;

	return @filedata ;
}

# Subroutine to extract FASTA header 
sub extract_fasta_header 
{
	my @fasta_header = @_ ;

	# Declare and initialize variables
	my $header = '' ;

	foreach my $line (@fasta_header)
	{
		# Save fasta header line 
		if ($line =~ /^>/)
		{ $header = $line ; }

		# Discard the rest 
		else
		{ next ; }
	} 

	return ($header) ; 
}

# Subroutine to extract single FASTA sequence 
sub extract_single_sequence 
{
	my @fasta_data = @_ ;

	# Declare and initialize variable
	my $sequence = '' ;

	foreach my $line (@fasta_data)
	{
		# Discard blank lines
		if ($line =~ /^\s*$/) 
		{ next ; } 

		# Discard FASTA header lines 
		elsif ($line =~ /^>/)
		{ next ; }

		# Save sequence
		else
		{
			$sequence .= $line ;
		}
	}

	# Remove whitespace from sequence line
	$sequence =~ s/\s//g ;

	return ($sequence) ;
}

# Subroutine to extract FASTA reading frames 
sub extract_reading_frames
{
	my @fasta_frames = @_ ;

	# Declare and initialize variables
	my @reading_frames = () ;

	foreach my $line (@fasta_frames)
	{
		# Save reading frames
		if ($line =~ /^--/)
		{ 
			push @reading_frames, $line;
		}

		# Discard the rest  
		else
		{ next ; } 
	}

	return (@reading_frames) ;
}

# Subroutine to extract the 3 FASTA sequences of each reading frame 
sub extract_reading_frame_sequences
{
	my @seq_frame = @_ ;

	# Declare and initialize variables
	my $f_count = -1 ;
	my @sequences = () ;

	foreach my $line (@seq_frame)
	{	
		# Discard blank lines
		if ($line =~ /^\s*$/) 
		{ next ; } 

		# Discard FASTA header lines 
		elsif ($line =~ /^>/)
		{ next ; }

		# Discard reading frame lines  
		elsif ($line =~ /^--/)
		{ next ; }

		# Discard comment line but increment counter 
		elsif ($line =~ /^#/)
		{
			$f_count ++ ;
		}

		# Save sequence
		else
		{
			@sequences[$f_count] .= $line ;
		}
	}

	# Remove white spaces from sequences 
	foreach my $s (@sequences)
	{
		$s =~ s/\s//g ;
	}
	
	return (@sequences) ;
}

# Declare and initialize variables 
my @query_data = () ;
my @seq_data = () ;
my $query_seq = '' ;
my $query_header = '' ;
my $seq_header = '' ;
my @seq_to_compare = () ;
my @frames = () ;
my @ordered_scores = () ;

# Prompt user for the path to the query sequence file
print "Enter the path to the query sequence file: " ;
my $query_file = <STDIN> ; chomp $query_file ;

# Read in the contents of the query sequence file, after checking the path
check_file_path($query_file) ;
@query_data = get_file_data($query_file) ;

# Prompt user for the path to the sequences file he wishes to compare
print "Enter the path to the sequences file to be compared: " ;
my $seq_file = <STDIN> ; chomp $seq_file ;

# Prompt user for the path of the target file
print "Enter the path where you wish to save the results of the comparison: " ;
my $target_file = <STDIN> ; chomp $target_file ;
check_file_path($target_file) ;

# Read in the contents of the sequences file to be compared, after checking path
check_file_path($seq_file) ;
@seq_data = get_file_data($seq_file) ;

# Extract query sequence and header 
$query_header = extract_fasta_header(@query_data);
$query_seq = extract_single_sequence(@query_data); 

# Extract sequences to be compared , their reading frames and header 
$seq_header = extract_fasta_header(@seq_data) ;
@frames = extract_reading_frames(@seq_data) ;
@seq_to_compare = extract_reading_frame_sequences (@seq_data) ;

my $seq_count = -1 ;
my @results = () ;

foreach my $s (@seq_to_compare) # For each sequence that needs to be compared to the query sequence 
{
	my @scores = ();
	$seq_count ++ ;
	my $total_count = 0 ; # Total score counter 
	my $a_count = 0 ; # Nucleotide A counter 
	my $g_count = 0 ; # Nucleotide G counter 
	my $c_count = 0 ; # Nucleotide C counter 
	my $t_count = 0 ; # Nucleotide T counter 

	for (my $i = 0; $i <= length ($query_seq); $i++)
	{
		# Compare the same length in both sequences 
		if ($i <= length($s))
		{
			my $q_nucleotide = '' ; # Nucleotide from query sequence 

			# Sequence from reading frame 0
			if ($seq_count < 3) 
			{ $q_nucleotide = substr($query_seq, $i, 1) ; }

			# Sequence from reading frame 1
			elsif ($seq_count < 6)
			{ $q_nucleotide = substr($query_seq, $i+1, 1) ; }

			# Sequence from reading frame 2
			else
			{ $q_nucleotide = substr($query_seq, $i+2, 1) ; }
			
			my $nucleotide = substr($s, $i, 1) ; # Nucleotide from other sequence at position $i 

			# If both nucleotides match at given position, check which nucleotide to increment counter
			if ($nucleotide eq $q_nucleotide)
			{
				if($nucleotide eq 'A')
				{ $a_count ++ ; }

				elsif ($nucleotide eq 'C')
				{ $c_count ++ ; }

				elsif ($nucleotide eq 'G')
				{ $g_count ++ ; }

				elsif ($nucleotide eq 'T')
				{ $t_count ++ ; }
			}
		}
	}

	# Total count is the sum of the count of all four nucleotides 
	$total_count = $a_count + $c_count + $g_count + $t_count ;

	# Keep track of sequence matching scores by storing them in scores array
	@scores[0] = $total_count ;
	@scores[1] = $c_count ;
	@scores[2] = $g_count ;
	@scores[3] = $t_count ;
	@scores[4] = $a_count ;

	# Create array reference to each sequence's matching scores 
	@results[$seq_count] = \@scores ;
}

# Create hash that contains sequence reference as key and total score as value 
my %totals = () ;
my $result = '';

for (my $k = 0 ; $k <= $#results; $k++)
{
	my $reference = @results[$k] ;
	my $value = $$reference[0]; 
	$totals{$k} = $value ; 
}

# Sort keys depending on total scores increasing order 
foreach my $t (sort { $totals{$a} <=> $totals{$b} } keys %totals)
{
	$result .= $t ; 
}

# Reverse order to decreasing 
my $decreasing = reverse($result); 
my @dec_order = split(//, $decreasing) ;

open (RANKING, ">$target_file/orderedSequences.txt") || die "Can't write to file because: $! \n" ;

print RANKING "Query sequence:\n" ;
print RANKING  "$query_header" ;
print RANKING "$query_seq\n" ;

print RANKING "RESULTS OF COMPARISON :\n\n" ;

print RANKING "$seq_header\n";

for (my $index = 0; $index <= $#dec_order; $index ++)
{
	my $dna_numb = 0 ;
	my $ref = @results[@dec_order[$index]] ;

	# Sequences 0, 1 and 2 belong to reading frame 0 
	if (@dec_order[$index] < 3)
	{
		print RANKING "@frames[0]\n" ;
		$dna_numb = @dec_order[$index]+1 ;
		
	}

	# Sequences 3, 4 and 5 belong to reading frame 1
	elsif (@dec_order[$index] < 6)
	{
		print RANKING "@frames[1]\n\n" ;
		$dna_numb = @dec_order[$index]-2 ;
	}

	# Sequences 6, 7 and 8 belong to reading frame 2 
	else
	{
		print RANKING "@frames[2]\n\n" ;
		$dna_numb = @dec_order[$index]-5 ;
	}

	print RANKING "DNA sequence $dna_numb : Total = $$ref[0] ; C = $$ref[1] ; G = $$ref[2] ; T = $$ref[3] ; A = $$ref[4]\n";
	print RANKING "@seq_to_compare[@dec_order[$index]]\n\n" ;
}

close RANKING || die "Can't close file because: $! \n" ;