# Define the username
$username = 'rali'

# Get the group membership for the specified username
Get-ADPrincipalGroupMembership -Identity $username |
    Select-Object SamAccountName, Name, @{Name='Username'; Expression={$username}}
