# Bash-Shell-Script-DBMS

## 1. Overview
This is a console app written in Bash that mimics the functionality of a Database Engine. It saves the data in a file-based structure where Databases are saved as directories with a .db extension, and tables are saved as files.
The system uses a two-file structure to describe and manage tables. A .tbl file that is the table itself, and holds its data. The other is a .mtd file that contains the metadata for the table. Data is saved in the tables such that rows are separated by colons ":", and rows are simply described by lines in the file. The resulting structure is similar to the passwd file found in any Linux Distribution.

## 2. Usage
The user can navigate the app through the numbered menus commonly user in console apps. A user enters a number that corresponds to the option they wish to select, and all interaction is text based. The UI is structured on three levels: Database, Table, and Record. Each level contains a menu for all operations that can be done on a specific object. For example, if a user wants to perform operations on a record, they can access the record level menu through selecting a table first in the table level, which is of course accessed by selecting a database in the database level.

## 3. Features
The app contains multiple features for multiple operation types that can be performed on any object in a DBMS.
### 1- Database Level
1. Create a new database
2. Open an existing database
3. Delete an existing database
4. List all available databases

### 2- Table level
1. List all tables
2. Create new table
3. Delete an existing table
4. Show content of an existing table
5. Open an existing table
6. Disconnect and select another table

### 3- Record level
1. Insert
2. Delete (clear entire table, delete by Primary Key, delete by given value)
3. Update 
4. Select (view entire table, select by primary key, select specific column, select by field value)
5. Disconnect