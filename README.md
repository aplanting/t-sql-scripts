# t-sql-scripts
T-SQL scripts worth saving and explaining

You need to enable xp_cmdshell in order to execute the SQL statements mentioned in the scripts.

### Import
loop-import-files.sql

Import one or more files automatically with BULK INSERT
Skip directories, process 1 by 1 one or all together.


### Download
download-scp.sql

On the SQL Server you need to download the portable version of WinSCP.
Create an folder for it, c:\tools or something like that. You will need to extract the WinSCP to that folder.
Then create an profile in WinSCP, give it a name, connect to the location where you want to download the file from to see if it works. Make sure you save it.
Next you will need an fingerprint.
