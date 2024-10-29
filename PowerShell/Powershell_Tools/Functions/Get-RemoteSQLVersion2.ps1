function Get-RemoteSQLVersion {
    param (
        [string]$remoteServer,      # The remote server name or IP
        [string]$instanceName = "localhost"  # The SQL Server instance name (default: localhost)
    )

    # Define the common SQL Server installation paths on the remote server
    $commonPaths = @(
        "C:\Program Files\Microsoft SQL Server",
        "C:\Program Files (x86)\Microsoft SQL Server",
        "C:\ProgramData\Microsoft SQL Server"
    )

    # Define the file name you're searching for
    $fileName = "configurationfile.ini"

    # Script block to execute remotely
    $scriptBlock = {
        param ($instanceName, $commonPaths, $fileName)
        
        # Function to get SQL Server version using sqlcmd
        function Get-SQLVersionFromSQLCMD {
            param ($serverInstance)
            
            $query = "SELECT @@VERSION;"
            
            try {
                # Execute SQLCMD and capture the result
                $result = sqlcmd -S $serverInstance -Q $query -h -1
                if ($result) {
                    return $result
                } else {
                    return "Unable to retrieve version"
                }
            } catch {
                return "SQLCMD execution failed"
            }
        }

        # Loop through each path and search for the file
        foreach ($path in $commonPaths) {
            if (Test-Path -Path $path) {
                $files = Get-ChildItem -Path $path -Recurse -Filter $fileName -ErrorAction SilentlyContinue
                if ($files) {
                    foreach ($file in $files) {
                        # Get SQL Server version for the instance
                        $sqlVersion = Get-SQLVersionFromSQLCMD -serverInstance $instanceName
                        "$($file.FullName) - SQL Version: $sqlVersion"
                    }
                }
            }
        }
    }

    # Execute the script block on the remote server
    Invoke-Command -ComputerName $remoteServer -ScriptBlock $scriptBlock -ArgumentList $instanceName, $commonPaths, $fileName
}

# Example usage
 Get-RemoteSQLVersion -remoteServer "UTQA-UTL1" -instanceName "SQLInstanceName"
