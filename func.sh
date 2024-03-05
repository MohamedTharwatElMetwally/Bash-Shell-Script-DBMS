#!/usr/bin/bash
read -p "Enter Database Name: " input
		
		if [[ $input =~ ^[a-zA-Z0-9_]+$ ]]
		then
			echo 1	
		else
			echo 0
		fi





