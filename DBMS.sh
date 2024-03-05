#!/usr/bin/bash

dbms_path="dbms"

if ! [ -d $dbms_path ]
then
    mkdir $dbms_path
    echo Welcome for the first time ... create the direcoty for your new DBMS
fi



function Records_level {
while true
do
	echo --------------------------------- 
	echo 1. Insert
	echo 2. Delete
	echo 3. Update
	echo 4. Select
	echo 5. Disconnect
	echo 6. Exit
	echo ---------------------------------  

	typeset -i option
	
	read -p "Select an Option, from [1-5]: " option

	if [ $option -eq 1 ]
	then
		echo $1
	elif [ $option -eq 2 ]
	then
		echo $1
	elif [ $option -eq 3 ]
	then
		echo $1
	elif [ $option -eq 4 ]
	then
		echo $1
	elif [ $option -eq 5 ]
	then
		return
	elif [ $option -eq 6 ]
	then
		return
	else 
		echo not a valid option, you must select from the provided list of options, from [1-7].
	fi
done
}


function Tables_level {
while true
do
	echo --------------------------------- 
	echo 1. List all Tables
	echo 2. Create new table  
	echo 3. Delete an Existing Table
	echo 4. Show content of an Existing Table
	echo 5. Open an Existing Table 
	echo 6. Disconnect
	echo 7. Exit
	echo ---------------------------------  

	typeset -i option
	
	read -p "Select an Option, from [1-5]: " option

	if [ $option -eq 1 ]
	then
		echo $1
	elif [ $option -eq 2 ]
	then
		read -p "Enter table name: " tname
		if [[ $tname =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
				touch "${dbms_path}/${1}.db/${tname}.tbl"
				if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
				then				
					echo table $tname created
				else
					echo Table creation failed. Please check that the database exits and that you have write privileges.
				fi

				touch "${dbms_path}/${1}.db/${tname}.mtd"
				if  [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
				then
					echo Metadata file created.
				else
					echo Metadata file creation failed. Please check that the database exists and that you have write privileges.
				fi
		else
			echo Invalid table name. Tables cannot contain special characters or begin with symbols
		fi
	elif [ $option -eq 3 ]
	then
		read -p "Enter the name of the table you want to delete: " tname
		
		if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
		then
			rm "${dbms_path}/${1}.db/${tname}.tbl"
			echo table $tname deleted
		else
			echo The specified table $tname does not exist or has already been deleted.
		fi
		
		if [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
		then
			rm "${dbms_path}/${1}.db/${tname}.mtd"
			echo matching metadata file deleted
		else
			echo Could not find matching metadata file.
		fi
		echo $1
	elif [ $option -eq 4 ]
	then
		echo $1
	elif [ $option -eq 5 ]
	then		
		read -p "Enter table name: " tname
		
		if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
		then		
			Records_level $tname
		else
			echo The specified table $tname does not exist
		fi

		
	elif [ $option -eq 6 ]
	then
		return
		
	elif [ $option -eq 7 ]
	then
		return
	else 
		echo not a valid option, you must select from the provided list of options, from [1-7].
	fi
done
}



while true
do
	echo --------------------------------- 
	echo 1. Create a New Database
	echo 2. Open an Existing Database
	echo 3. Delete an Existing Database
	echo 4. List All Available Databases
	echo 5. Exit
	echo ---------------------------------  

	typeset -i option
	
	read -p "Select an Option, from [1-5]: " option

	if [ $option -eq 1 ]
	then
	
		read -p "Enter Database Name: " newDB
		
		if [[ $newDB =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
			if ! [ -d $dbms_path/$newDB.db ]
			then
				mkdir $dbms_path/$newDB.db
			    	echo the database $newDB has been created successfully.
			else
				echo the database $newDB is already exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]. And the name must start with at least one char".
		fi
		
	elif [ $option -eq 2 ]
	then
	
		read -p "Enter Database Name: " currentDB
		
		if [[ $currentDB =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
			if [ -d $dbms_path/$currentDB.db ]
			then
			    	echo successfully connected to $currentDB.
			    	
			    	#################
			    	## Tables Level
			    	#################
			    	
			    	Tables_level $currentDB
			    	
			    	break
			else
				echo the database $currentDB is not exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]. And the name must start with at least one char".
		fi
		
	elif [ $option -eq 3 ]
	then
	
		read -p "Enter Database Name: " DBName
		
		if [[ $DBName =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
			if [ -d $dbms_path/$DBName.db ]
			then
				rm -r $dbms_path/$DBName.db
			    	echo the database $DBName has been deleted successfully.
			else
				echo the database $DBName is not exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]. And the name must start with at least one char".
		fi
		
		
	elif [ $option -eq 4 ]
	then
	
		ls $dbms_path | grep ".db" | awk -F. '{print $1}'
		
	elif [ $option -eq 5 ]
	then
		return
	else 
		echo not a valid option, you must select from the provided list of options, from [1-5].
	fi
done













