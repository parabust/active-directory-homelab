param([Parameter(Mandatory = $true)] $jsonFile)

$json = (Get-Content $jsonFile | ConvertFrom-JSON)
$domain = $json.domain

foreach ($group in $json.groups) {
    $name = $group.name
    try {
        Get-ADGroup -Identity "$name" -ErrorAction Stop
    } catch {
        New-ADGroup -Name $name -GroupScope Global
    }
}

foreach ($user in $json.users) {
    $name = $user.name
    $username = $user.username
    $password = $user.password
    $samAccountName = $username
    $principalName = $username
    $firstName, $lastName = $name.split(" ")

    try {
        Get-ADUser -Identity "$username" -ErrorAction Stop
    } catch {
        New-ADUser -Name "$name" -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName -UserPrincipalName $principalName@$domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount
    }
    foreach ($groupName in $user.groups) {
        try {
            Get-ADGroup -Identity "$name" -ErrorAction Stop
            Add-ADGroupMember -Identity $groupName -Members $username
        } catch {
            Write-Host "$group group doesn't exist"
        }
    }
}