
# Function to get direct reports of a user
function Get-DirectReports {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [PSCredential]$Credential
    )

    # Get the distinguished name of the user
    $user = Get-ADUser -Credential $Credential -Identity $UserName -Properties directReports

    if ($user -eq $null) {
        Write-Host "User not found."
        return
    }

    # Get direct reports
    $directReports = $user.directReports

    if ($directReports -eq $null) {
        Write-Host "$UserName has no direct reports."
        return
    }

    # Collect results in an array
    $results = @()

    # Output the direct reports
    foreach ($report in $directReports) {
        $reportUser = Get-ADUser -Credential $Credential -Identity $report -Properties DisplayName, Title, SAMAccountName
        $results += [PSCustomObject]@{
            Name            = $reportUser.DisplayName
            Title           = $reportUser.Title
            SAMAccountName  = "ELDREDGE_A\" + $reportUser.SAMAccountName
        }
    }

    # Export results to CSV
    $results | Export-Csv -Path "c:\temp\DirectReports.csv" -NoTypeInformation
    Write-Host "Direct reports exported to DirectReports.csv"
}

# Main script execution
$userName = Read-Host -Prompt "Enter the username of the manager (e.g., jdoe)"
$credential = Get-Credential -Message "Enter your AD credentials"
Get-DirectReports -UserName $userName -Credential $credential
