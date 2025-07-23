param(
    [Parameter(Mandatory = $true)][int] $numOfUsers
)

$firstNames = [System.Collections.ArrayList](Get-Content -Path res\firstnames.txt)
$lastNames = [System.Collections.ArrayList](Get-Content -Path res\lastnames.txt)

for ($i = 0; $i -lt $numOfUsers; $i++) {
    $randomFirstName = $firstNames | Get-Random
    $randomLastName = $lastNames | Get-Random
    $firstNameCutoff = $randomFirstName.substring(0, (Get-Random -Minimum 1 -Maximum $randomFirstName.length))
    $lastNameCutoff = $randomLastName.substring(0, (Get-Random -Minimum 1 -Maximum $randomLastName.length))

    $username = $firstNameCutoff + $lastNameCutoff
    Write-Host $username
    $firstNames.remove($randomFirstName)
    $lastNames.remove($randomLastName)
}