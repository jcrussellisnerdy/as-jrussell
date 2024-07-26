# Define the username
$username = 'sukumpati'

# Get the group membership for the specified username
Get-ADPrincipalGroupMembership -Identity $username | 
    Where-Object { $_.Name -like "SQL_*" } |
    Select-Object SamAccountName, Name, @{Name='Username'; Expression={$username}}
