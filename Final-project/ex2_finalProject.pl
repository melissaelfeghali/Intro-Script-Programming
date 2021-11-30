#!/usr/bin/perl -l

use strict ;

# Subroutine to extract Non-bonded contacts interactions only
sub extract_nonbonded
{
	my $directory = @_[0] ;
	my $file = @_[1] ;
	my @interactions = () ;

	# Initialize variable 
	my @filedata = () ;

	# Check if file opens 
	open(GETDATA, "$directory/$file") || die "Cannot open file because: $! \n" ;
	
	@filedata = <GETDATA> ;

	#Close the file 
	close MYFILE || "Cannot close file because: $! \n" ;

	OUTER: for(my $i = 0 ; $i <= $#filedata; $i++)
	{
		# Extract only the data for the non-bonded contacts
		if(@filedata[$i]=~/^Non-bonded/)
		{
			for(my $j=$i+1; $j <= $#filedata; $j++)
			{
				if( @filedata[$j] =~ /^\s*\d{1,3}\./ )
				{
					push (@interactions, @filedata[$j]) ;
				}

				elsif(@filedata[$j]=~/^(Hydrogen|Disulphide)/)
				{
					next OUTER ;
				}
			}
		}
	}

	return (@interactions) ;
}

# Array that will contain all the files to be processed
my @files = () ;
# Name of the folder containing the files 
my $folder = "PDBSumFiles" ;
# Hash that will contain the final number of interactions
my %aa ;
 
 # Open the folder containing the files 
opendir(FOLDER, $folder) || die "Cannot open folder because : $! ;\n" ;

# Read the contents of the folder with the extension .txt only 
@files = grep (/.*\.txt/, readdir(FOLDER));

# Close the folder 
closedir(FOLDER) || die "Cannot close because: $!\n" ;

# List of the 20 amino acids 
my @amino_acids = qw (ALA ARG ASN ASP CYS GLU GLN GLY HIS ILE LEU LYS MET PHE PRO SER THR TRP TYR VAL);

# Create 2D hash to store interactions of amino acids 
foreach my $aa1 (@amino_acids)
{
	foreach my $aa2 (@amino_acids)
	{
		$aa{$aa1}{$aa2} = 0 ;
	}
}

# For each file in the folder
foreach my $f (@files) 
{
	my @non_bonded = () ;
	my @atoms = () ;
	my $atom1 = '' ; my $atom2 = '' ;
	my @a1 = () ; my @a2 = () ;

	# Get the non-bonded interactions
	@non_bonded = extract_nonbonded($folder,$f) ;

	# For each non-bonded contact, get interaction data
	foreach my $nb (@non_bonded)
	{
		@atoms = split("<-->", $nb) ;
		$atom1 = @atoms[0] ; # Interaction nb Atom 1
		$atom2 = @atoms[1] ; # Interaction nb Atom 2

		# Removes everything from start to amino acid name 
		$atom1 =~ s/\d+\.\s+\d+\s+\w+\s+\b//g ; 
		$atom2 =~ s/^\s+\d+\s+\w+\s+\b//g ;

		# Removes empty spaces from start of line 
		$atom1 =~ s/^\s*\b//g ;

		# Removes everything after amino acid number 
		$atom1 =~ s/\s+[^\d\W]+\b//g ;
		$atom2 =~ s/\s+\w+\s+\d.*\b//g ;
		 
		# Replace spaces with tab 
		$atom1 =~ s/\s+/	/g ;
		$atom2 =~ s/\s+/	/g ;

		# We only kept the name and number of the amino acids 
		push (@a1, $atom1) ;
		push (@a2, $atom2) ;
	}

	my %results ;

	# We only want to take the unique amino acid name and number combination
	for (my $k = 0; $k <= $#a1 ; $k ++)
	{
		if(exists($results{@a1[$k]}{@a2[$k]}))
		{ next ; }

		else
		{$results{@a1[$k]}{@a2[$k]} = 1 ; }	
	}

	# Add interactions to amino acid hash 
	foreach my $first_atom (sort keys %results) 
	{
	    foreach my $second_atom (keys %{ $results{$first_atom} }) 
	    {
	        $second_atom =~ s/\t\d+\t//g ; 
	        $first_atom =~ s/\t\d+\t//g ;
	        $aa{$first_atom}{$second_atom} ++ ; 
	    } 
	}	
}	

# Write interactions on output file 
open (FILE, ">interactions.txt") || die "Cannot write to file because: $!\n" ;

foreach my $aacid1 (sort keys %aa) 
{
	printf FILE "\t%s", $aacid1 ; 
}

foreach my $aacid1 (sort keys %aa) 
{
	printf FILE "\n%s", $aacid1 ;

    foreach my $aacid2 (sort keys %{ $aa{$aacid1} }) 
    {
        printf FILE "\t%d", $aa{$aacid1}{$aacid2} ;
	}
}

close (FILE) || die "Cannot close because: $!\n" ; 

# print the number of files processed
print "\nThe number of files processed is : ", ($#files + 1), "\n" ;