#!/usr/bin/bash


dbms_path="dbms"

if ! [ -d $dbms_path ]
then
    mkdir $dbms_path
    echo Welcome for the first time ... create the direcoty for your new DBMS
fi


echo -e "\e[32;1m"  # switch color to green 
cat << "EOF"

  ______   ______   ____    ____   ______   
 |_   _ `.|_   _ \ |_   \  /   _|.' ____ \  
   | | `. \ | |_) |  |   \/   |  | (___ \_| 
   | |  | | |  __'.  | |\  /| |   _.____`.  
  _| |_.' /_| |__) |_| |_\/_| |_ | \____) | 
 |______.'|_______/|_____||_____| \______.' 

EOF
echo -e "\e[0m"  # reset color


namingRules="^[a-zA-Z]+[a-zA-Z0-9_]+$"
intValuePattern="^[0-9]+$"
stringValuePattern="^[a-zA-Z0-9_]+$"


function Select {

while true
do
	echo --------------------------------- 
	echo "1. Select * From $2"
	echo 2. Select by Primary Key
	echo 3. Select Specific column
	echo 4. Select by Field value
	echo 5. Back
	echo ---------------------------------  

	typeset -i option
	
	read -p "Select an Option [1-4]: " option

	if [ $option -eq 1 ]
	then
		awk -F':' '{
			for (i=1; i<=NF; i++) 
			{
				printf "%-20s", $i  
			}
			printf "\n"
		}' "${dbms_path}/${1}.db/${2}.tbl"

	elif [ $option -eq 2 ]
	then

		pk_column_name=""
		pk_column_datatype=""
		pk_column_index=""

		output=$(
			awk -F':' '{ 
				if ($2 == 1) 
				{ 
					print $1,$5,NR
					exit; 
				} 
			}' "${dbms_path}/${1}.db/${2}.mtd"
		)

		read pk_column_name pk_column_datatype pk_column_index <<< "$output"
		
		read -p "Enter Primary Key: " pk

		if [ $pk_column_datatype == 'i' ] && [[ $pk =~ ^[0-9]+$ ]] || [ $pk_column_datatype == 's' ] && [[ $pk =~ ^[a-zA-Z0-9_]+$ ]] 
		then
			awk -F':' -v pk_name="$pk_column_name" -v pk_type="$pk_column_datatype" -v pk_index="$pk_column_index" -v pk="$pk" '{
				if (NR > 1) 
				{ 
					if ($pk_index == pk)
					{
						for (i=1; i<=NF; i++) 
						{
							printf "%-20s", $i  
						}
						printf "\n"
						exit;
					}
				}  
				else
				{
					for (i=1; i<=NF; i++) 
					{
						printf "%-20s", $i  
					}
					printf "\n"
				}
			}' "${dbms_path}/${1}.db/${2}.tbl"

		else
			if [ $pk_column_datatype == 'i' ]
			then
				echo "invalid value for integer primary key. You must enter numbers only." 
			else
				echo "invalid value for string primary key. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			fi
		fi



	elif [ $option -eq 3 ]
	then

		printf "All Columns: "

		awk -F':' '{ 
			if (NR == 1) 
			{ 
				for (i=1; i<=NF; i++) 
				{
					printf "%-5s", $i  
				}
				printf "\n"
				exit; 
			} 
		}' "${dbms_path}/${1}.db/${2}.tbl"
		
		read -p "Enter Column Name: " colName

		if [[ $colName =~ ^[a-zA-Z]+[a-zA-Z0-9_]+$ ]]
		then
				awk -F':' -v colName="$colName" -v colIndex="0" '{
					if (NR == 1) 
					{ 
						for (i=1; i<=NF; i++) 
						{
							if ($i == colName) 
							{
								print $i
								colIndex=i;
								break;
							}
						}
						if(colIndex == 0)
						{
							print "Column does not exist."
							exit;
						}
					}  
					else
					{
						print $colIndex
					}
				}' "${dbms_path}/${1}.db/${2}.tbl"

		else
			echo Invalid name format. Column name cannot contain special characters or start with a number.
		fi

	elif [ $option -eq 4 ]
	then

		awk -F':' '{ 
			if (NR == 1) 
			{ 
				for (i=1; i<=NF; i++) 
				{
					print i": "$i
				}
				exit; 
			} 
		}' "${dbms_path}/${1}.db/${2}.tbl"
	  
		columns=$(
			awk -F':' '{ 
				if (NR == 1) 
				{ 
					print NF
					exit; 
				} 
			}' "${dbms_path}/${1}.db/${2}.tbl"
		)

		read -p "Enter column number. [1-$columns]: " colNum

		if [ $colNum -ge 1 -a $colNum -le $columns ]
		then
			read -p "Value: " value
			awk -F':' -v colNum="$colNum" -v value="$value"  '{ 
				if (NR == 1 || NR != 1 && $colNum == value ) 
				{ 
					for (i=1; i<=NF; i++) 
					{
						printf "%-20s", $i  
					}
					printf "\n"
				} 
			}' "${dbms_path}/${1}.db/${2}.tbl"
		else
			echo "Invalid input. Please select [1-$columns]".
		fi

	elif [ $option -eq 5 ]
	then
		return

	else
		echo Invalid input. Please select [1-4].
	fi
done

}


function Update {

while true
do
	echo --------------------------------- 
	echo Condition Columns
	echo -----------------

	awk -F':' '{ 
		if (NR == 1) 
		{ 
			for (i=1; i<=NF; i++) 
			{
				print i": "$i
			}
			exit; 
		} 
	}' "${dbms_path}/${1}.db/${2}.tbl"

	columns=$(
		awk -F':' '{ 
			if (NR == 1) 
			{ 
				print NF
				exit; 
			} 
		}' "${dbms_path}/${1}.db/${2}.tbl"
	)

	options=$((columns + 1))
	echo "$options: Back"
	echo --------------------------------- 

	read -p "Enter  column number. [1-$options]: " conColNum

	if [ $conColNum -ge 1 -a $conColNum -le $columns ]
	then
		read -p "Condition value: " conValue
		output=$(
			awk -F':' -v colNum="$conColNum" -v value="$conValue" -v check="0" '
				{
					if (NR != 1 && $colNum == value) {
						check += 1
					}
				} 
				END {
					print check
				}
			' "${dbms_path}/${1}.db/${2}.tbl"
		)


		if [ $output != 0 ]
		then
			echo there are $output records that match this condition.
			
			################ Updating ################

			Update_Menu2 $1 $2 $conColNum $conValue $output

			##########################################

		else
			echo there are no records that match this condition.
		fi

	elif [ $conColNum -eq $options ]
	then
		break

	else
		echo "Invalid input. Please select [1-$columns]".
	fi

done

}

function Update_Menu2  {

while true
do
	echo --------------------------------- 
	echo Choose a Column to update
	echo ---------------------------------

	awk -F':' '{ 
		if (NR == 1) 
		{ 
			for (i=1; i<=NF; i++) 
			{
				print i": "$i
			}
			exit; 
		} 
	}' "${dbms_path}/${1}.db/${2}.tbl"

	columns=$(
		awk -F':' '{ 
			if (NR == 1) 
			{ 
				print NF
				exit; 
			} 
		}' "${dbms_path}/${1}.db/${2}.tbl"
	)

	options=$((columns + 1))
	echo "$options: Back"
	echo ---------------------------------

	read -p "Enter the number of columns to update. [1-$options]: " colNum

	if [ $colNum -ge 1 -a $colNum -le $columns ]
	then

		# read the metadata values: colName:PK:required:unique:datatype

		pk=""
		required=""
		unique=""
		type=""

		output=$(
			awk -F':' -v conColNum="$colNum" '{ 
				if (NR == conColNum) 
				{ 
					print $2,$3,$4,$5
					exit; 
				} 
			}' "${dbms_path}/${1}.db/${2}.mtd"
		)

		read pk required unique type <<< "$output"

		if [[ "$unique" == "1" && "$5" > 1 ]]
		then
			echo "This field is unique, and the number of matching records is $5, so you cannot set one value for these records together."
			echo "Please try to change each record independently by its primary key."
			continue
		fi

		read -p "New Value: " newValue

		# Required or not
		if [[ "$required" == "1" && "$newValue" == "" ]]
		then
			echo "This Field is required. Empty values are not allowed."
		else
			# Check datatype
			if [[ $newValue =~ $intValuePattern && $type == 'i' ]] || [[ $newValue =~ $stringValuePattern && $type == 's' ]]
			then

				# Check uniqueness
				check=$(
					awk -F':' -v colNum="$colNum" -v value="$newValue" -v check="0" '
						{
							if (NR != 1 && $colNum == value) 
							{
								check = 1
								print check
								exit
							}
						} 
						END {
							print check
						}
					' "${dbms_path}/${1}.db/${2}.tbl"
				)
                
				if [[ $unique == 0 || ($unique == 1 && $check == 0) ]] # 3 cases: unique=1 and check=0 | unique=0 and check=1 | unique=0 and check=0
				then
					
					# All checks passed. Proceed to update columns.

					touch "${dbms_path}/${1}.db/tmp.tbl" 

					awk -F':' -v colNum="$colNum" -v value="$newValue" -v conColNum="$3" -v conValue="$4" '
						{
							if (NR != 1 && $conColNum == conValue) {
								$colNum = value # update
								printf "%s", $1
								for (i = 2; i <= NF; i++) {
									printf ":%s", $i
								}
								printf "\n"
							}
							else
							{
								print $0
							}
						} 
					' "${dbms_path}/${1}.db/${2}.tbl" > "${dbms_path}/${1}.db/tmp.tbl" 
					
					cp "${dbms_path}/${1}.db/tmp.tbl" "${dbms_path}/${1}.db/${2}.tbl" 
					rm -f "${dbms_path}/${1}.db/tmp.tbl" 
                    
					echo Successfully updated records.

				else # one case only: unique=1 and check=1
					echo "The entered value already exists, and this field must be unique."
				fi

			else
				if [ $type == 'i' ]
				then 
					echo "Invalid datatype. You must enter integer values."
				else
					echo "Invalid datatype. You must enter string values."
				fi
			fi
		fi

		

	elif [ $colNum -eq $options ]
	then
		break

	else
		echo "Invalid input. Please select [1-$columns]".
	fi

done

}


function DeleteByFieldValue {

while true
do
	echo --------------------------------- 
	echo Condition Columns
	echo -----------------

	awk -F':' '{ 
		if (NR == 1) 
		{ 
			for (i=1; i<=NF; i++) 
			{
				print i": "$i
			}
			exit; 
		} 
	}' "${dbms_path}/${1}.db/${2}.tbl"

	columns=$(
		awk -F':' '{ 
			if (NR == 1) 
			{ 
				print NF
				exit; 
			} 
		}' "${dbms_path}/${1}.db/${2}.tbl"
	)

	options=$((columns + 1))
	echo "$options: Back"
	echo --------------------------------- 

	read -p "Enter  column number. [1-$options]: " conColNum

	if [ $conColNum -ge 1 -a $conColNum -le $columns ]
	then
		read -p "Condition value: " conValue

		output=$(
			awk -F':' -v colNum="$conColNum" -v value="$conValue" -v check="0" '
				{
					if (NR != 1 && $colNum == value) {
						check += 1
					}
				} 
				END {
					print check
				}
			' "${dbms_path}/${1}.db/${2}.tbl"
		)

		if [ $output != 0 ]
		then

			touch "${dbms_path}/${1}.db/tmp.tbl"

			awk -F':' -v colNum="$conColNum" -v value="$conValue" -v check="0" '
				{
					if (NR == 1 || $colNum != value) {
						print $0
					}
				} 
			' "${dbms_path}/${1}.db/${2}.tbl" > "${dbms_path}/${1}.db/tmp.tbl" 
			
			cp "${dbms_path}/${1}.db/tmp.tbl" "${dbms_path}/${1}.db/${2}.tbl" 
			rm -f "${dbms_path}/${1}.db/tmp.tbl" 

			echo There are $output records that match this condition.
			echo Successfully deleted $output records.
		else
			echo there are no records that match this condition.
		fi

	elif [ $conColNum -eq $options ]
	then
		break

	else
		echo "Invalid input. Please select [1-$columns]".
	fi

done

}


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
	
	read -p "Select an Option [1-6]: " option

	if [ $option -eq 1 ]
	then
		# Preparing column list
		IFS=":" read -ra columns <<< `head -n 1 "dbms/${1}.db/${2}.tbl"`
		insertStr=""
		declare -i colIndex=1
		for i in ${columns[@]}
		do
		mtdata=(`cat "dbms/${1}.db/${2}.mtd" | grep $i | awk -F: '{for  (i=2; i<=NF; i++) print $i}'`)
		if ((${mtdata[0]}))
		then
			echo NOTE: This column is the primary key.
		fi
		declare -i passedChecks=0
		checks=(0 0 0)
		
		# Prompt user for data input.
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
					read -p "Enter data for column ${i}: " entry
				done
				checks[0]=1
			else
				checks[0]=1
			fi

			# Check for uniqueness, check also passes for PK enabled columns
			if ((${mtdata[0]})) ||  ((${mtdata[2]}))
			then
				existingData=`tail -n +2 dbms/${1}.db/${2}.tbl | cut -d: -f${colIndex}`
				isunique=$(passUniqChk $entry ${existingData[@]})

				# Perform uniqueness check
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
				while ! [[ $entry =~ $intValuePattern ]]
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
	
	# All checks have been passed. Appending the data to the table, followed by a new line.
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

						# Tell the user which column is the primary key.
						echo column $i is the Primary Key
						
						# Prompt for PK value.
						read -p "Enter the Primary key for the row you want to delete: " query

						# Check input data type against PK column data type.
						if [[ ${mtdata[4]} == "s" ]]
						then
							while ! [[ $query =~ ^[a-zA-Z_\-]+$ ]]
							do
								echo Invalid input format. This column accepts alphabetic values only.
								read -p "Enter the Primary key for the row you want to delete: " query
							done
						else
							while ! [[ $query =~ ^[0-9]+$ ]]
							do
								echo Invalid input format. This column accepts numeric values only.
								read -p "Enter the Primary key for the row you want to delete: " query
							done
						fi
						
						# Check if the PK exists, reusing the unique check function.
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
				# # Display table for visual aid.

				# # Prompt for value to match.
				# read -p "Enter the value(s) you want to match for deletion:  " query
				# # delete lines where the query is found.
				# awk "NR==1 || !/${query}/" dbms/${1}.db/${2}.tbl > temp && mv temp dbms/${1}.db/${2}.tbl

				DeleteByFieldValue $1 $2

			elif [ $option -eq 4 ]
			then
				break
			fi		
		done

	elif [ $option -eq 3 ]
	then
		Update $1 $2

	elif [ $option -eq 4 ]
	then
		Select $1 $2

	elif [ $option -eq 5 ]
	then
		return 0

	elif [ $option -eq 6 ]
	then
		return 1

	else 
		echo Invalid input. Please select [1-6].
	fi
done
}

function Tables_level 
{
while true
do
	echo --------------------------------- 
	echo 1. List all Tables
	echo 2. Create new table  
	echo 3. Delete an existing table
	echo 4. Show content of an existing table
	echo 5. Open an existing table 
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
		# Prompting user for table name.
		read -p "Enter table name: " tname
		
		# Checking that the table doesn't exist already.
		while [ -f "${dbms_path}/${1}.db/${tname}.tbl" -a -f "${dbms_path}/${1}.db/${tname}.mtd" ]
		do
			echo A table with this name already exists.
			read -p "Enter table name: " tname
		done
		
		# Checking if it matches the specified format.
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
			
			# Creating the table.
			touch "${dbms_path}/${1}.db/${tname}.tbl"
			if [ -f "${dbms_path}/${1}.db/${tname}.tbl" ]
			then				
				echo table $tname created
				tblCreated=$true
			else
				echo Table creation failed. Please check that the database exists and that you have write privileges.
				tblCreated=$false
			fi

			# Creating the Metadata file.
			touch "${dbms_path}/${1}.db/${tname}.mtd"
			if  [ -f "${dbms_path}/${1}.db/${tname}.mtd" ]
			then
				echo Metadata file created.
				mtdCreated=$true
			else
				echo Metadata file creation failed. Please check that the database exists and that you have write privileges.
				mtdCreated=$false
			fi

			# Building table metadata.
			if [ $tblCreated ] -a [ $mtdCreated ]
			then

				# Reading number of columns.
				read -p "Number of columns: " colNo
				while ! [[ $colNo =~ ^[0-9]+$ ]]
				do
					echo Invalid input. Please enter a number.
					read -p "Number of columns: " colNo
				done

				# Entering metadata.
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
					
					# Checking that the column name has not been already entered.
					if [ -z $table_columns ]
					then
						# First column passes the check.
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
						
						# Adding : between column names as a delimiter.
						if ! [ $i -eq $colNo ]
						then
							table_columns+=":"
						fi
					fi

					# Start populating column metadata.
					colData+=$colName
					colData+=":"

					# 2. check for Primary key.
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
							# Tag column as Primary Key.
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

						# Check if the column is required.
						read -p "Is this column required? (y/n) " rqprmpt
						while ! [[ $rqprmpt =~ ^[YyNn]$ ]]
						do
							echo Invalid choice.
							read -p "Is this column required? (y/n) " rqprmpt
						done

						if [[ $rqprmpt =~ ^[Yy]$ ]]; 
						then
							# Column  is required.
							colData+="1"
							colData+=":"
						else
							# Column is not required.
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
							# Column  is unique.
							colData+="1"
						else
							# Column is not unique.
							colData+="0"
						fi

					fi	

					# 5. Prompting for input type.
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

					# populating metadata file with the column's metadata.
					echo $colData >> "${dbms_path}/${1}.db/${tname}.mtd"

				done
				echo $table_columns 
				echo $table_columns >> "${dbms_path}/${1}.db/${tname}.tbl"
				
			else
				echo Error during creating the table data or metadata files. Please try again.
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
	echo 1. Create a new database
	echo 2. Open an existing database
	echo 3. Delete an existing database
	echo 4. List all available databases
	echo 5. Exit
	echo ---------------------------------  

	
	typeset -i option 

	read -p "Select an Option [1-5]: " option
	
	# =======> to be handled
	# if [[ ! $option =~ ^[1-5]$ ]]
	# then
	# 	echo not a valid option, you must select from the provided list of options, from [1-5].
	# 	continue
	# fi

	if [ $option -eq 1 ]
	then
	
		read -p "Enter Database Name: " newDB
		
		if [[ $newDB =~ $namingRules ]]
		then
			if ! [ -d $dbms_path/$newDB.db ]
			then
				mkdir $dbms_path/$newDB.db
			    	echo Database $newDB created successfully.
			else
				echo Database $newDB already exists.
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi
		
	elif [ $option -eq 2 ]
	then
	
		read -p "Enter Database Name: " currentDB
		
		if [[ $currentDB =~ $namingRules ]]
		then
			if [ -d $dbms_path/$currentDB.db ]
			then
			    	echo Successfully connected to $currentDB.
			    	
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
				echo Database $currentDB not found.
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi
		
	elif [ $option -eq 3 ]
	then
	
		read -p "Enter Database Name: " DBName
		
		if [[ $DBName =~ $namingRules ]]
		then
			if [ -d $dbms_path/$DBName.db ]
			then
				rm -r $dbms_path/$DBName.db
			    	echo $DBName has been deleted successfully.
			else
				echo Database $DBName not found.
			fi
		else
			echo "invalid database name. The allowed characters are [ A-Z | a-z | 0-9 | _ ]." 
			echo "The name must start with at least one alphabetic character, and the minimum character count is 2."
		fi
		
		
	elif [ $option -eq 4 ]
	then

		if [  `ls $dbms_path | wc -l` == 0 ]
		then
			echo No databases found.
		else
			ls $dbms_path | grep ".db" | awk -F. '{print $1}'
		fi
		
	elif [ $option -eq 5 ]
	then
		return
	else 
		echo Invalid input. Please select [1-5].
	fi
done














