#!/usr/bin/bash

dbms_path="dbms"

if ! [ -d $dbms_path ]
then
    mkdir $dbms_path
    echo Welcome for the first time ... create the direcoty for your new DBMS
fi

function passUniqChk
{
	for i in "${@:2}"
	do
		if [[ ${1,,} == ${i,,} ]]
		then
			echo 0
			return
		fi
	done
	echo 1
	return
}

function passAllChk
{
	for i in ${@:1}
	do
	if [[ $i -eq 0 ]]
	then
		echo 0
		return
	fi
	done
	echo 1
	return
}

function Records_level
{
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
		# Preparing column list
		IFS=":" read -ra columns <<< `head -n 1 "dbms/${1}.db/${2}.tbl"`
		insertStr=""
		declare -i colIndex=1
		for i in ${columns[@]}
		do
		mtdata=(`cat "dbms/${1}.db/${2}.mtd" | grep $i | awk -F: '{for  (i=2; i<=NF; i++) print $i}'`)
		
		# Prompt user for data input.
		if ((${mtdata[0]}))
		then
			echo This column is the primary key.
		fi
		declare -i passedChecks=0
		checks=(0 0 0)
		read -p "Enter the data for column ${i}: " entry
		while ! (($passedChecks))
		do
			# Check for required, check also passes for PK enabled columns
			if ((${mtdata[0]})) ||  ((${mtdata[1]}))
			then
				# Perform required check
				while [ -z ${entry} ]
				do 
					echo This column is required.
					read -p "Enter the data for column ${i}: " entry
				done
				checks[0]=1
			else
				checks[0]=1
			fi

			# Check for unique, check also passes for PK enabled columns
			if ((${mtdata[0]})) ||  ((${mtdata[2]}))
			then
				existingData=`tail -n +2 dbms/${1}.db/${2}.tbl | cut -d: -f${colIndex}`
				isunique=$(passUniqChk $entry ${existingData[@]})

				# Perform unique check
				while ! (($isunique))
				do 
					echo This value already exists. Data in this column has to be unique.
					read -p "Enter the data for column ${i}: " entry
					isunique=$(passUniqChk $entry ${existingData[@]})
				done
				checks[1]=1
			else
				checks[1]=1
			fi

			#For each column, check data type.
			if [[ ${mtdata[3]} == "s" ]]
			then
				while ! [[ $entry =~ ^[a-zA-Z_\-]+$ ]]
				do
					echo Invalid input format. This column accepts alphabetic input only.
					read -p "Enter the data for column ${i}: " entry
				done
				checks[2]=1
			else
				while ! [[ $entry =~ ^[0-9]+$ ]]
				do
					echo Invalid input format. This column accepts numeric input only.
					read -p "Enter the data for column ${i}: " entry
				done
				checks[2]=1
			fi
			passedChecks=$(passAllChk ${checks[@]})
		done
		
		# Appending Column data into the insertion string.
		insertStr+=$entry
		if [ $colIndex -ne ${#columns[@]} ]
		then
			insertStr+=":"
		fi
		colIndex+=1
		done
	
	# All checks have been passed. Appending the data 2 the table, followed by a new line.
	echo $insertStr >> dbms/${1}.db/${2}.tbl

	elif [ $option -eq 2 ]
	then
		while true
		do
			echo --------------------------------- 
			echo 1. Clear entire table
			echo 2. Delete by Primary Key
			echo 3. Delete by Field Value
			echo 4. Back
			echo ---------------------------------  

			typeset -i option
			
			read -p "Select an Option, from [1-4]: " option

			# Clear entire table.
			if [ $option -eq 1 ]
			then
				sed -i '2,$d' "${dbms_path}/${1}.db/${2}.tbl"
				echo Table cleared successfully.
			
			# Delete row by Primary Key.
			elif [ $option -eq 2 ]
			then

				# Preparing column list
				IFS=":" read -ra columns <<< `head -n 1 "dbms/${1}.db/${2}.tbl"`
				insertStr=""
				declare -i colIndex=1
				
				# Loop over columns to find the primary key
				for i in ${columns[@]}
				do
					IFS=":" read -ra mtdata <<< `cat dbms/${1}.db/${2}.mtd | grep $i`
					if ((${mtdata[1]}))
					then

						# Tell the user which column is the primary key
						echo column $i is the Primary Key
						
						# Prompt for PK value
						read -p "Enter the Primary key for the row you want to delete: " query

						# Check input data type against PK column data type.
						if [[ ${mtdata[4]} == "s" ]]
						then
							while ! [[ $query =~ ^[a-zA-Z_\-]+$ ]]
							do
								echo Invalid input format. This column accepts alphabetic input only.
								read -p "Enter the Primary key for the row you want to delete: " query
							done
						else
							while ! [[ $query =~ ^[0-9]+$ ]]
							do
								echo Invalid input format. This column accepts numeric input only.
								read -p "Enter the Primary key for the row you want to delete: " query
							done
						fi
						
						# Check if the PK exists, reusing the unique check function
						existingData=`tail -n +2 dbms/${1}.db/${2}.tbl | cut -d: -f${colIndex}`
						doesntExist=$(passUniqChk $query ${existingData[@]})
						while (($doesntExist))
						do
							echo Primary Key does not exist.
							read -p "Enter the Primary key for the row you want to delete: " query
							doesntExist=$(passUniqChk $query ${existingData[@]})
						done

						# Delete the PK row.
						awk "NR==1 || !/${query}/" dbms/${1}.db/${2}.tbl > temp && mv temp dbms/${1}.db/${2}.tbl
						echo Row deleted successfully.
					fi					
					colIndex+=1
				done

			# Delete by field value.
			elif [ $option -eq 3 ]
			then
				# Prompt for value to match
				read -p "Enter the value(s) you want to match for deletion:  " query
				# delete lines where the query is found
				awk "NR==1 || !/${query}/" dbms/${1}.db/${2}.tbl > temp && mv temp dbms/${1}.db/${2}.tbl
			fi		
		done
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

function colExists
{
	IFS=':' read -ra fields <<< "$2"
	for i in "${fields[@]}"
	do
		if [ $i = $1 ]
		then
			echo 0
			return	
		fi
	done
	echo 1
	return
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
		# Checking for an empty database
		if [ `ls $dbms_path/$1.db/ | wc -l` == 0 ]
		then
			echo No tables are available in $1.
		else
			ls $dbms_path/$1.db/ | grep ".tbl" | awk -F. '{print $1}'
		fi

	elif [ $option -eq 2 ]
	then
		# Prompting user for table name
		read -p "Enter table name: " tname
		
		# Checking that the table doesn't exist already
		while [ -f "${dbms_path}/${1}.db/${tname}.tbl" -a -f "${dbms_path}/${1}.db/${tname}.mtd" ]
		do
			echo A table with this name already exists.
			read -p "Enter table name: " tname
		done
		
		# Checking if it matches the specified format
		if [[ $tname =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then 
			
			# First, check if there is only one file due to any error, consider it as garbage, and delete it.
			if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
			then 
				rm -f "${dbms_path}/${1}.db/${tname}.tbl"
			fi

			if [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
			then 
				rm -f "${dbms_path}/${1}.db/${tname}.mtd"
			fi

			# Then, create the table data and metadata files.
			
			# Creating the table
			touch "${dbms_path}/${1}.db/${tname}.tbl"
			if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
			then				
				echo table $tname created
				tblCreated=$true
			else
				echo Table creation failed. Please check that the database exists and that you have write privileges.
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
				while ! [[ $colNo =~ ^[0-9]+$ ]]
				do
					echo Invalid input. Please enter a number.
					read -p "Number of columns: " colNo
				done

				# Entering metadata
				PKchosen=0
				table_columns=""

				for ((i = 1; i <= $colNo; i++))
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
					
					# Checking that the column name has not been already entered
					if [ -z $table_columns ]
					then
						# First column passes the check
						table_columns+=$colName
						table_columns+=":"
					else
						newName=$(colExists $colName $table_columns)
						while ! (($newName))
						do
							echo Column name already exists. Please enter a different name.
							read -p "Enter name of column ${i}: " colName
							newName=$(colExists $colName $table_columns)
						done
						table_columns+=$colName
						
						# Adding : between column names as a delimiter
						if ! [ $i -eq $colNo ]
						then
							table_columns+=":"
						fi
					fi

					# Start populating column metadata
					colData+=$colName
					colData+=":"

					# 2. check for Primary key
					if ! (($PKchosen)) 
					then

						read -p "Make this column the Primary Key? (y/n) " pkprmpt

						while ! [[ $pkprmpt =~ ^[YyNn]$ ]]
						do
							echo Invalid choice.
							read -p "Make this column the Primary Key? (y/n) " pkprmpt
						done

						if [[ $pkprmpt =~ ^[Yy]$ ]]
						then
							# Tag column as Primary Key
							echo Column $colName selected as Primary Key.
							PKchosen=1
							isPK=1
							colData+="1:1:1"

						# User has not selected any column to be the Primary Key. The last column will be chosen.
						elif [ $i -eq $colNo ]
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
						while ! [[ $rqprmpt =~ ^[YyNn]$ ]]
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
						while ! [[ $unqprmpt =~ ^[YyNn]$ ]]
						do
							echo Invalid choice.
							read -p "Do values in this column have to be unique? (y/n) " unqprmpt
						done

						if [[ $unqprmpt =~ ^[Yy]$ ]]
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
				echo $table_columns 
				echo $table_columns >> "${dbms_path}/${1}.db/${tname}.tbl"
				
			else
				echo Error during creating the table data or metadata files. Please, try again.
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














