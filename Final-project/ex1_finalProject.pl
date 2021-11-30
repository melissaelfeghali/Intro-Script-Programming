#!/usr/bin/perl

use strict ;

# Number of arguments given on the command line 
my $args = $#ARGV + 1 ;

# Quit if wrong number of arguments was provided by user 
if ($args != 1)
{ print "Wrong number of arguments !\n"; exit ; }

# If we have the right number of command line arguments
my $file_name = @ARGV[0] ; 

# Inital number of interactions 
print "\nThe initial number of interactions is : ", `wc -l $file_name`, "\n" ;

# Extract header of file 
my $info_header = `sed -n '1p' $file_name` ;

# Get all the duplicate rows (once each)
my @duplicate_rows = `tail -n+2 $file_name | sort | uniq -d` ;

# Get all the rows that are not duplicated 
my @non_duplicate_rows = `tail -n+2 $file_name | sort | uniq -u` ;

# Get the overall data without duplicate rows 
my @data = (@non_duplicate_rows, @duplicate_rows) ;

open(DUPLICATE, ">duplicateInteractions.txt") || die "Can't write to file because: $! \n" ;
open(UNIQUE, ">uniquesInteractions.txt") || die "Can't write to file because: $! \n" ;

print DUPLICATE $info_header ;
print UNIQUE $info_header ;

foreach my $x (@duplicate_rows)
{ print DUPLICATE $x ; }

my %interactions ;

# Store non-duplicate rows data in hash 
for (my $i = 0 ; $i <= $#data ; $i++)
{
	$interactions{@data[$i]} = $i ;
}

my $duplicate_info = '' ; 
my %duplicated_interactions ;

# Keeps count of duplicates
my $count_d = 0 ;

# Keeps count of unique sequences 
my $count_u = 0 ;

foreach my $d (sort keys %interactions)
{
	my @a=split(/	/, $d);
	my $string1= @a[1] . @a[10] . @a[4] . @a[13] . @a[7] . @a[16] . @a[8] . @a[17]; 
	my $string2= @a[10] . @a[1] . @a[13] . @a[4] . @a[16] . @a[7] . @a[17] . @a[8]; 

	if (exists($interactions{$string2}))
	{	
		print DUPLICATE $d ; 
		$count_d ++ ;
	}

	else
	{
		$interactions{$string1} = $d;
		$count_u ++ ;
		print UNIQUE $d ;
	}
}

print "Number of Duplicated Interactions : $count_d\n" ; 
print "\nNumber of Unique Interactions : $count_u\n\n" ;

close UNIQUE ;
close DUPLICATE ;