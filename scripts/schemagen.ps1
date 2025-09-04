param(
    [Parameter(Mandatory = $true)][int] $numOfUsers,
    [Parameter(Mandatory = $true)][int] $numOfGroups
)
$firstNames = [System.Collections.ArrayList](Get-Content -Path res\firstnames.txt)
$lastNames = [System.Collections.ArrayList](Get-Content -Path res\lastnames.txt)
$schemaTable = @{
    users = New-Object System.Collections.ArrayList
    groups = New-Object System.Collections.ArrayList
}

function generateUsername {
    param(
        [Parameter(Mandatory = $true)][string] $firstName,
        [Parameter(Mandatory = $true)][string] $lastName
    )
    $firstNameCutoff = $firstName.substring(0, (Get-Random -Minimum 1 -Maximum $randomFirstName.length))
    $lastNameCutoff = $lastName.substring(0, (Get-Random -Minimum 1 -Maximum $randomLastName.length))
    $username = $firstNameCutoff + $lastNameCutoff
    $firstNames.remove($firstName)
    $lastNames.remove($lastName)

    return $username
}
function generatePassword {
    $minPasswordLength = 7
    $maxPasswordLength = 15
    $passwordLength = Get-Random -Minimum $minPasswordLength -Maximum $maxPasswordLength
    $passwordChars = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $passwordLength; $i++) {
        $randomChar = [char] (Get-Random -Minimum 33 -Maximum 127)
        while ($randomChar -eq "\" -or $randomChar -eq ([char] 34)) {
            $randomChar = [char] (Get-Random -Minimum 33 -Maximum 127)
        }
        $passwordChars.add($randomChar) | Out-Null
    }

    return ($passwordChars -join "")
    
}

for ($i = 0; $i -lt $numOfGroups; $i++) {
    $schemaTable["groups"].add(@{name = "group$i"})
}
for ($i = 0; $i -lt $numOfUsers; $i++) {
    $randomFirstName = $firstNames | Get-Random
    $randomLastName = $lastNames | Get-Random
    $username = generateUsername -firstName $randomFirstName -lastName $randomLastName
    $password = generatePassword
    $schemaTable["users"].add(@{name = "$randomFirstName $randomLastName"; username = "$username"; password = "$password"})
}

($schemaTable | ConvertTo-Json) | Set-Content -Path "output.json"