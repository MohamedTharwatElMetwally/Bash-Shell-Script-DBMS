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
	
	read -p "Select an Option, from [1-6]: " option

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
		return 0
	elif [ $option -eq 6 ]
	then
		return 1
	else 
		echo not a valid option, you must select from the provided list of options, from [1-6].
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
	
	read -p "Select an Option, from [1-7]: " option

	if [ $option -eq 1 ]
	then
		if [ `ls $dbms_path/$1.db/ | wc -l` == 0 ]
		then
			echo No tables are available in $1.
		else
			ls $dbms_path/$1.db/ | grep ".tbl" | awk -F. '{print $1}'
		fi

	elif [ $option -eq 2 ]
	then

		read -p "Enter table name: " tname
		if [[ $tname =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
				if [ -f "${dbms_path}/${1}.db/${tname}.tbl" -a -f "${dbms_path}/${1}.db/${tname}.mtd" ]
				then				
					echo This table is already exit.
				else
    
					# =========== First, check if there is only one file due to any error, consider it as garbage, and delete it.

					if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
					then 
						rm -f "${dbms_path}/${1}.db/${tname}.tbl"
					fi

					if [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
					then 
						rm -f "${dbms_path}/${1}.db/${tname}.mtd"
					fi

					# =========== Then, create the table data and metadata files.
					
					# Creating the table
					touch "${dbms_path}/${1}.db/${tname}.tbl"
					if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
					then				
						echo table $tname created
						tblCreated=$true
					else
						echo Table creation failed. Please check that the database exits and that you have write privileges.
						tblCreated=$false
					fi

					# Creating the Metadata file
					touch "${dbms_path}/${1}.db/${tname}.mtd"
					if  [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
					then
						echo Metadata file created.
						mtdCreated=$true
					else
						echo Metadata file creation failed. Please check that the database exists and that you have write privileges.
						mtdCreated=$false
					fi

					# Building table metadata
					if [ $tblCreated ] -a [ $mtdCreated ]
					then

						# Reading number of columns
						read -p "Number of columns: " colNo
						while ! [[ $colNo =~ ^[0-9]+$ ]]; 
						do
							echo Invalid input. Please enter a number.
							read -p "Number of columns: " colNo
						done

						# Entering metadata
						PKchosen=0
						table_columns=""

						for ((i = 1; i <= $colNo; i++)); 
						do
							colData=""
							isPK=0

							# 1. Column name
							read -p "Enter name of column ${i}: " colName
							while ! [[ $colName =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]; 
							do
								echo Invalid name format. Column name cannot contain special characters or start with a number.
								read -p "Enter name of column ${i}: " colName
							done

							# Start populating column metadata
							colData+=$colName
							colData+=":"

							# Add the column name for the table_columns record to be added to the .tbl file finally. 
							table_columns+=$colName
							if ! [ $i -eq $colNo ]
							then
								table_columns+=":"
							fi

							# 2. check for Primary key
							if ! (($PKchosen)); 
							then

								read -p "Make this column the Primary Key? (y/n) " pkprmpt

								while ! [[ $pkprmpt =~ ^[YyNn]$ ]]; 
								do
									echo Invalid choice.
									read -p "Make this column the Primary Key? (y/n) " pkprmpt
								done

								if [[ $pkprmpt =~ ^[Yy]$ ]]; 
								then
									# Tag column as Primary Key
									echo Column $colName selected as Primary Key.
									PKchosen=1
									isPK=1
									colData+="1:1:1"

								# User has not selected any column to be the Primary Key. The last column will be chosen.
								elif [ $i -eq $colNo ]; 
								then
									echo Column $colName will be forced as as Primary Key since no other columns were selected.
									PKchosen=1
									isPK=1
									colData+="1:1:1"
								else
									# The user chose the primary key before.
									colData+="0"
									colData+=":"
								fi

							else
								# The user chose the primary key before.
								colData+="0"
								colData+=":"
							fi

							# 3. required or not | 4. unique or not
							if ! (($isPK))
							then

								# Check if the column is required
								read -p "Is this column required? (y/n) " rqprmpt
								while ! [[ $rqprmpt =~ ^[YyNn]$ ]]; 
								do
									echo Invalid choice.
									read -p "Is this column required? (y/n) " rqprmpt
								done

								if [[ $rqprmpt =~ ^[Yy]$ ]]; 
								then
									# Column  is required
									colData+="1"
									colData+=":"
								else
									# Column is not required
									colData+="0"
									colData+=":"
								fi

								# Unique
								read -p "Do values in this column have to be unique? (y/n) " unqprmpt
								while ! [[ $unqprmpt =~ ^[YyNn]$ ]]; 
								do
									echo Invalid choice.
									read -p "Do values in this column have to be unique? (y/n) " unqprmpt
								done

								if [[ $unqprmpt =~ ^[Yy]$ ]]; 
								then
									# Column  is unique
									colData+="1"
								else
									# Column is nor unique
									colData+="0"
								fi

							fi	

							# 5. Prompting for input type
							read -p "Choose input type. (S = string / I = integer) (s/i) " inptype
							while ! [[ $inptype =~ ^[SsIi]$ ]]; 
							do
								echo Invalid choice.
								read -p "Choose input type. (S = string / I = integer) (s/i) " inptype
							done
							if [[ $inptype =~ ^[Ss]$ ]]; then
								colData+=":s"
							else
								colData+=":i"
							fi

							echo $colData

							# populating metadata file with the column's metadata
							echo $colData >> "${dbms_path}/${1}.db/${tname}.mtd"

						done

						echo $table_columns >> "${dbms_path}/${1}.db/${tname}.tbl"
						
					else
						echo Error during creating the table data or metadata files. Please, try again.
					fi	
				fi
		else
			echo "invalid table name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi

	elif [ $option -eq 3 ]
	then

		read -p "Enter the name of the table you want to delete: " tname
		
		if [[ $tname =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
			if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
			then
				rm -f "${dbms_path}/${1}.db/${tname}.tbl"
				echo table $tname deleted.
			else
				echo The specified table $tname does not exist or has already been deleted.
			fi
			
			if [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
			then
				rm "${dbms_path}/${1}.db/${tname}.mtd"
				echo matching metadata file deleted.
			else
				echo Could not find matching metadata file.
			fi
		else
			echo "invalid table name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi


	elif [ $option -eq 4 ]
	then
		read -p "Enter Table Name: " tname

		if [[ $tname =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
			if [ -f "${dbms_path}/${1}.db/${tname}.tbl" -a -f "${dbms_path}/${1}.db/${tname}.mtd" ]
			then		
				awk -F':' '{
					for (i=1; i<=NF; i++) 
					{
						printf "%-20s", $i  
					}
					printf "\n"
				}' "${dbms_path}/${1}.db/${tname}.tbl"
			else
				echo The specified table $tname does not exist.
			fi
		else
			echo "invalid table name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi

	elif [ $option -eq 5 ]
	then	

		read -p "Enter Table Name: " tname

		if [[ $tname =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
			if [ -f "${dbms_path}/${1}.db/${tname}.tbl" -a -f "${dbms_path}/${1}.db/${tname}.mtd" ]
			then		

				#################
				## Records Level
				#################

				Records_level $1 $tname
				status=$?
				if [ $status == 1 ]
				then
					return 1
				fi
				
			else
				echo The specified table $tname does not exist.
			fi
		else
			echo "invalid table name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi

	elif [ $option -eq 6 ]
	then
		return 0
		
	elif [ $option -eq 7 ]
	then
		return 1

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
	
	# =======> to be handled
	# if [[ ! $option =~ ^[1-5]$ ]]
	# then
	# 	echo not a valid option, you must select from the provided list of options, from [1-5].
	# 	continue
	# fi

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
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
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
					status=$?
					if [ $status == 1 ]
					then
						return
					fi
						

			else
				echo the database $currentDB is not exist !!!
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
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
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi
		
		
	elif [ $option -eq 4 ]
	then

		if [  `ls $dbms_path | wc -l` == 0 ]
		then
			echo No databases are available.
		else
			ls $dbms_path | grep ".db" | awk -F. '{print $1}'
		fi
		
	elif [ $option -eq 5 ]
	then
		return
	else 
		echo not a valid option, you must select from the provided list of options, from [1-5].
	fi
done














