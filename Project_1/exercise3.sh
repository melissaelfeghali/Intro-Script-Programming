#!/bin/bash

# Part a)
# After printing the first line of the Annotations.txt file, we notice that the index of column "code" is 1

awk -F \t ' { print $1 } ' Annotations.txt | grep -c ".*_"

# The awk command prints out the contents of the column "code" only 
# The piping and grep command are used to extract the lines in the colomun "code" matching the given pattern 
# -c counts the number of codes with the "_" symbols in them 

# The output after executing this command is : 7746


# Part b)
# Delete all the lines that have the symbol "_" in their "code" column
sed -E -i.backup '/^[0-9a-zA-z]+_[0-9]/d' Annotations.txt 


# Part c)

# We can use the commande below to find the path of the file if we are in the same working dircetory 
# ls "`pwd`/Annotations.txt"
# Check if more than one argument was entered 
if [ $# -gt 1 ] || [ $# -le 0 ]
then
	echo "ERROR: Enter ONE argument which is the path to the filtered file. Put it between double quotes"
else

# Question a. 
echo "This is the total number of lines in the filtered file, excluding the title line: "
sed 1d $1 | wc -l 
echo
# This command prints out the total number of lines in the file excluding the title row 
# The output after executing this command is : 22722

# Question b.
# Create new directory 
read -p "Enter the name of a new directory to create: " directory
while [ -d ~/$directory ]; do
	echo "ALERT: This directory already exists!"
	read -p "Enter the name a the new directory: " directory
done
mkdir ~/$directory
echo "Directory successfully created!"
echo

# Question c.
# Prompt user to enter a keyword search 
read -p "Enter a keyword search: " keyword
# Search for this keyword in filtered file 
echo
grep -i "$keyword" $1
echo
echo "Above, are all the lines that contain the keyword: $keyword"
echo

# Question d.
# Replaces spaces with the "_" symbol from keyword for the name of the new file 
name=$(echo $keyword | sed 's/ /_/g')
name="$name.txt"
# Creates file with appropriate name in the created directory above 
touch ~/$directory/$name
# Add title row to the first line of the file 
head -1 $1 > ~/$directory/$name
# Loop through all lines in the file and if the line contains the keyword, case insensitive, write the whole line to a new file 
grep -i "$keyword" $1 >> ~/$directory/$name

# Question e.
# This command displays the number of lines in the new created file
echo "This is the number of lines in the file $name : "
cat ~/$directory/$name | wc -l 
# The output of this command is: 4154
fi

