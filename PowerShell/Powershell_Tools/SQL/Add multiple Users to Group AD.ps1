# Replace 'GroupName' with the name of the AD group you want to add members to
$groupName = 'SQL_OCR_ADMIN_TOOL' 
        #Snowflake Data Warehouse - User

# Replace 'Member1' and 'Member2' with the usernames of the users you want to add
$membersToAdd =  'cPierson'

# Add members to the AD group
$membersToAdd | ForEach-Object {
    Add-ADGroupMember -Identity $groupName -Members $_
}



# Retrieve members of the AD group
$groupMembers = Get-ADGroupMember -Identity $groupName

# Display members' details
$groupMembers | Select-Object   @{Name='Username'; Expression={$groupName}}, SamAccountName, Name, ObjectClass |Where-Object SamAccountName -eq $membersToAdd
