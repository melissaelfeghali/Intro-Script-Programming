#!/bin/bash

# Check if todo directory exists in home directory, if not create it
if [ ! -d ~/todo ]
then
	mkdir ~/todo
	echo "/todo directory successfully created in user's home directory"
	echo
fi

# Check if data.txt file exists in todo directory, if not create it 
if [ ! -f ~/todo/data.txt ]
then 
	touch ~/todo/data.txt
	echo "The file \"data.txt\" was successfully created in the /todo directory"
	echo
fi

# The first argument given will be the chosen option to do 
option=$1

# Synopsis of available commands with a brief description as to what each command does 
command1="help: Prints out the available commands with a brief description of each"
command2="add: Inserts and saves the specified task provided in double quotes into the to-do list. You can optionally add a date to the task with the following format dd/mm/yyyy"
command3="del: Removes the specified task number and updates the to-do list"
command4="list: Displays all the tasks in the to-do list"

# Initialize a variable to 0 to later increment when needed to keep track of the current task number 
numb=0
# Date format used 
date_format="(0[1-9]|[1-2][0-9]|30|31)/(0[1-9]|1[0-2])/(20[0-1][0-9]|2020)"
# Task number must be a digit 
digit_format="[0-9]+"

#switch case
case $option in

	"help" )
		echo
		echo "These are the available commands:"
		echo
		echo $command1
		echo
		echo $command2
		echo
		echo $command3
		echo
		echo $command4
		echo
		;;

	# Add command inserts and saves the specified task into todo list data file 
	"add" )
		# Checks if given task name is already present in to do list data file 
		found=$(grep -E "\b$2\b" ~/todo/data.txt | wc -m)
		if [ $found -ne 0 ]
		then
			echo
			echo "ERROR: task already exists!"

		else
			# If there are only two arguments 
			if [ $# -eq 2 ]
			then 
				taskTodo=$2
				numb+=1
				printf "%s: %-10s\n" $numb $taskTodo >> ~/todo/data.txt
				echo "ADDED #$numb - $taskTodo"
			# If there are three elements 	
			elif [ $# -eq 3 ]
			then
				date=$(echo "$3" | grep -E "$date_format" | wc -m)
				# The third argument matches the date format 
				if [ $date -ne 0 ]
				then
						taskTodo=$2
						taskDate=$3
						numb+=1
						printf "%s: %-10s%10s\n" $numb $taskTodo $taskDate >> ~/todo/data.txt
						echo "ADDED #$numb - $taskTodo"
				else 
					echo "ERROR !! Please follow the below instructions: "
					echo "Make sure you have entered the task to add between double quotes"
					echo "Make sure you have entered the correct date format dd/mm/yyyy"
				fi
			# If the user entered more than 3 arguments
			elif [ $# -gt 3 ]
			then
				echo "ERROR: Make sure you have entered the task to do between double quotes"
			# If the user entered less than 2 arguments 
			else
				echo "ERROR: You have to enter at two one arguments, the second between double quotes which is the task to be added"
			fi
		fi
		;;

	# Locates task number, removes it and updates the data file accordingly
	"del" )
		# The user can only enter two arguments 
		if [ $# -ne 2 ]
		then 
			echo "ERROR: the task number to be deleted ONLY must be provided after del "
		elif [ $# -eq 2 ]
		then 
			# Check if task number given is a digit 
			digit=$(echo "$2" | grep -E "$digit_format" | wc -m)
			if [ $digit -ne 0 ]
			then
				# Check if task number is a positive digit 
				if [ $2 -gt 0 ]
				then
					taskNumb=$2
					tracker=$(grep -E "\b$taskNumb:" ~/todo/data.txt | wc -m)
					taskdeleted=$(grep -E "\b$taskNumb:" ~/todo/data.txt | awk -F : ' { print $2 } ')
					# Check if task number exists in data file
					if [ $tracker -ne 0 ]
					then
						grep -v "$taskNumb:" ~/todo/data.txt > ~/todo/data.txt
						echo "DELETED #$taskNumb - $taskdeleted"
						echo
					else
						echo
						echo "ERROR: The task number provided does not exist"
						echo
					fi
				else
					echo
					echo "ERROR: The task number must be a positive digit"
					echo
				fi
			else
				echo
				echo "ERROR: The task number must be a digit "
				echo
			fi
		fi
		;;

	"list" )
		# The user should not insert more than one argument 
		if [ $# -ne 1 ]
		then 
			echo 
			echo "ERROR: No arguments should be provided after list"
		else
			echo
			echo "UPCOMING ITEMS:"
			cat ~/todo/data.txt
		fi
		;;

	# Default 
	* )
		echo "ERROR: Enter a valid option. If you need help with the commands write the world help" ;;

esac

