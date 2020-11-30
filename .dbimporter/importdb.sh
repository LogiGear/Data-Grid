#!/bin/bash

cd /dbimporter

if [ -f 'imported.txt' ]; then
    echo "DB is imported"
    exit 0
fi

if [ -f 'wwi.bak' ]; then
    echo "Sample DB exists"
else
    echo "Download Sample DB"
    curl -L -o wwi.bak 'https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak'
fi

[[ -d '/var/opt/mssql/backup' ]] || mkdir -p /var/opt/mssql/backup
cp /dbimporter/wwi.bak /var/opt/mssql/backup

echo "Begin import"
cd /var/opt/mssql
/opt/mssql-tools/bin/sqlcmd -S data-grid_db -U SA -P 'Password789' -Q 'RESTORE FILELISTONLY FROM DISK = "/var/opt/mssql/backup/wwi.bak"' | tr -s ' ' | cut -d ' ' -f 1-2
/opt/mssql-tools/bin/sqlcmd -S data-grid_db -U SA -P 'Password789' -Q 'RESTORE DATABASE WideWorldImporters FROM DISK = "/var/opt/mssql/backup/wwi.bak" WITH MOVE "WWI_Primary" TO "/var/opt/mssql/data/WideWorldImporters.mdf", MOVE "WWI_UserData" TO "/var/opt/mssql/data/WideWorldImporters_userdata.ndf", MOVE "WWI_Log" TO "/var/opt/mssql/data/WideWorldImporters.ldf", MOVE "WWI_InMemory_Data_1" TO "/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1"'
/opt/mssql-tools/bin/sqlcmd -S data-grid_db -U SA -P 'Password789' -Q 'SELECT Name FROM sys.Databases'
echo "DB is imported" > imported.txt
echo "Sample DB imported"