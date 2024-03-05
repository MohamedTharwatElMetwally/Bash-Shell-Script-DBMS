#!/usr/bin/bash

dbms_path="./dbms/"

if ! [ -d $dbms_path ]
then
    mkdir $dbms_path
    echo Welcome for the first time ... create the direcoty for your new DBMS
fi


function database_level {
while true
do
	echo --------------------------------- 
	echo 1. Create a New Database
	echo 2. Open an Existing Database
	echo 3. Delete an Existing Database
	echo 4. List All Available Databases
	echo 5. Exit
	echo ---------------------------------  

	read -p "Select an Option, from [1-5]: " option

	if [ $option -eq 1 ]
	then
	
		read -p "Enter Database Name: " newDB
		
		if [[ $newDB =~ ^[a-zA-Z0-9_]+$ ]]
		then
			if ! [ -d $dbms_path/$newDB ]
			then
				mkdir $dbms_path/$newDB
			    	echo the database $newDB has been created successfully.
			else
				echo the database $newDB is already exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]".
		fi
		
	elif [ $option -eq 2 ]
	then
	
		read -p "Enter Database Name: " currentDB
		
		if [[ $currentDB =~ ^[a-zA-Z0-9_]+$ ]]
		then
			if [ -d $dbms_path/$currentDB ]
			then
			    	echo successfully connected to $currentDB.
			    	break
			else
				echo the database $currentDB is not exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]".
		fi
		
	elif [ $option -eq 3 ]
	then
	
		read -p "Enter Database Name: " DBName
		
		if [[ $DBName =~ ^[a-zA-Z0-9_]+$ ]]
		then
			if [ -d $dbms_path/$DBName ]
			then
				rm -r $dbms_path/$DBName
			    	echo the database $newDB has been deleted successfully.
			else
				echo the database $DBName is not exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]".
		fi
		
		
	elif [ $option -eq 4 ]
	then
	
		ls $dbms_path
		
	elif [ $option -eq 5 ]
	then
	
		return
		
	else 
		echo not a valid option, you must select from the provided list of options, from [1-5].
	fi
done
}

database_level 






