param([Parameter(Mandatory = $true)] $jsonFile)

$json = (Get-Contents $jsonFile | ConvertFrom-JSON)
$domain = $json.domain

foreach ($group in $json.groups) {
    $name = $group.name
    New-ADGroup -Name $name -GroupScope Global
}

foreach ($user in $json.users) {
    $name = $user.name
    $username = $user.username
    $password = $user.password
    $samAccountName = $username
    $principalName = $username
    $firstName, $lastName = $name.split(" ")

    New-ADUser -Name "$name" -GivenName $firstName -Surname $lastName -SamAccountName $samAccountName -UserPrincipalName $principalName@$domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    foreach ($groupName in $user.groups) {
        Add-ADGroupMember -Identity $groupName -Members $username
    }
}