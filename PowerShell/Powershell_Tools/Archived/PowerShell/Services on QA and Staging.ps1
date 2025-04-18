get-wmiobject win32_service -comp UTSTAGE-APP1 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\staging\UTSTAGE-APP1.csv" 
get-wmiobject win32_service -comp UTSTAGE-APP2 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\staging\UTSTAGE-APP2.csv" 
get-wmiobject win32_service -comp UTSTAGE-APP3 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\staging\UTSTAGE-APP3.csv" 
get-wmiobject win32_service -comp UTSTAGE-APP4 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\staging\UTSTAGE-APP4.csv" 
get-wmiobject win32_service -comp UTSTAGE01 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\staging\UTSTAGE01.csv" 
get-wmiobject win32_service -comp UTSTAGE-RPT01 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\staging\UTSTAGERPT01.csv" 
get-wmiobject win32_service -comp UTQA-SQL | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\QA\UTQA-SQL.csv" 
get-wmiobject win32_service -comp UTQA-SQL2012 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\QA\UTQA-SQL2012.csv" 
get-wmiobject win32_service -comp UTQA2-APP1 | Select Name, State, SystemName, StartName | Export-Csv -path "C:\temp\QA\UTQA2-APP1.csv" 