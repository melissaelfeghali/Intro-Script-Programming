#!/usr/bin/perl -l 

use strict ; 

# Declare and initialize variables 
my @theft_data = () ; 
my @info = () ;
my $id = '';
my $residence = '' ;
my $first_name = '' ;
my $last_name = '' ;
my $date_birth = '' ;

open (DATA, "theftData.txt") || die "Can't open file because: $! \n" ;

@theft_data = <DATA> ;

close DATA || die "Can't close file because: $! \n" ;

foreach my $line (@theft_data)
{
	# Store each column of info seperately in array 
	# @inf0[0] is the LastName, @info[1] is the FirstName and so on 
	@info = split('\t', $line) ; 

	# Get ID 
	$id = @info[2] ;

	# Check if last 4 digits of ID start and end with the same number 
	# If it does, keep investigating the person 
	if ($id =~ /^\d*(\d)\d\d(?=\1)\d$/ )
	{
		# Get residence
		$residence = @info[3] ;

		# Check if the residence is dorms
		# If it is not, keep investigating the person 
		if ($residence !~ /Dorms/)
		{
			# Get first name 
			$first_name = @info[1] ;

			# Check if first name has between 2 and 4 characters 
			# If it does, keep investigating the person
			if ($first_name =~ /^\w{2,4}\b/)
			{
				# Get last name 
				$last_name = @info[0] ;
				$last_name =~ s/\s//g ;

				# Check if last name has more than 5 characters 
				# If it does, keep investigating the person
				if ($last_name =~ /^\w{6,}/)
				{
					# Get date of birth 
					$date_birth = @info[4] ;

					# Check if born in January, October, November or December 
					# If applicable, keep investigating the person 
					if ($date_birth =~ /\/1\/|\/1[0-2]\//)
					{
						# Check if person is more than 45 years old 
						# If applicable, keep investigating the person
						# To be more than 45 years old, the max_birth_year < 2020 - 45 = 1975
						if ($date_birth !~ /\/197[5-9]|\/19[8-9]\d|\/2\d{3}/)
						{
							# Check if their birthday is two equal digits 
							# If it is, keep investigating the person
							if ($date_birth =~ /^(\d)(?=\1)\d\//)
							{
								# Check if person joined LAU after 2017
								# If true, then we found our thief 
								# This means that their ID should start with 2018 or 2019 
								if ($id =~ /^201[8-9]\d*/)
								{
									print "\n!!! The thief is $first_name $last_name !!!\n" ;
								}

							}
						}

					}
				}
			}
		}
	}
}

