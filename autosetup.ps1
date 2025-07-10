param(
[Parameter(Mandatory = $true)][string] $domainControllerIP,
[Parameter(Mandatory = $true)][string] $domainControllerUsername,
[Parameter(Mandatory = $true)][SecureString] $domainControllerPassword,
[Parameter(Mandatory = $true)][string] $domainName, 
[Parameter(Mandatory = $true)][SecureString] $safeModeAdminPassword)
Enable-PSRemoting -Force
Start-Service WinRM
Set-Item wsman:\localhost\Client\TrustedHosts -value $domainControllerIP -Force

$credentials = New-Object System.Management.Automation.PSCredential($domainControllerUsername, $domainControllerPassword)
$session = New-PSSession -ComputerName $domainControllerIP -Credential $credentials

$sessionAdminStatus = [bool] (Invoke-Command -Session $session -ScriptBlock {
    (net localgroup administrators) -contains (whoami).split("\")[-1]
})
if ($sessionAdminStatus -eq $false) {
    Write-Host "This account on the domain controller doesn't have admin privileges"
    exit
}

Invoke-Command -Session $session -ScriptBlock {
    if ((Get-WindowsFeature -Name AD-Domain-Services).InstallState -eq "Available") {
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
        Import-Module ADDSDeployment
        Install-ADDSForest -DomainName $domainName -InstallDNS -SafeModeAdministatorPassword $safeModeAdminPassword -Force
    }
}

$continueTestConnection = $true
while ($continueTestConnection -eq $true) {
    $testConnectionCounter = 1
    while ($testConnectionCounter -le 10) {
        $testConnection = Test-NetConnection -ComputerName $domainControllerIP
        if ($testConnection.PingSucceeded -eq $true) {
            $continueTestConnection = $false
            break
        }
        Start-Sleep -Seconds 15
        Write-Host "Attempting reconnect to domain controller.. ($($testConnectionCounter))"
        $testConnectionCounter++
    }
    Write-Host "Couldn't reconnect to domain controller, maybe slow restart or DNS issue?"
    $continueTestConnectionChoice = Read-Host "Retry connection to domain controller? ('y' to retry)"
    if ($continueTestConnectionChoice.toLower() -ne "y") {
        exit
    }
}

$updatedCredentials = New-Object System.Management.Automation.PSCredential(($domainName.split(".")[0] + "\") + $domainControllerUsername, $domainControllerPassword)

Add-Computer -DomainName $domainName -Credential $updatedCredentials -Force -Restart

