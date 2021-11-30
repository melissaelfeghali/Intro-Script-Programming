# List all the files in home directory and displays the number of readable directories
# For a directory to be readable it is sufficient to have the readable permission for the user. In this case we will have the pattern "dr" in the first column of the listing 

ls -l ~/ | awk ' { print $1 } ' | grep -c "dr"