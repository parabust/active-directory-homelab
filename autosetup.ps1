param([Parameter(Mandatory = $true)][string] $domainControllerIP)
Enable-PSRemoting -Force
Start-Service WinRM
Set-Item wsman:\localhost\Client\TrustedHosts -value $domainControllerIP -Force

$session = New-PSSession -ComputerName $domainControllerIP -Credential (Get-Credential)

$sessionAdminStatus = [bool] (Invoke-Command -Session $session -ScriptBlock {
    (net localgroup administrators) -contains (whoami).split("\")[-1]
})
if ($sessionAdminStatus -eq $false) {
    Write-Host "This account on the domain controller doesn't have admin privileges"
    exit
}

Invoke-Command -Session $session -ScriptBlock {
    if ((Get-WindowsFeature -Name AD-Domain-Services).InstallState -eq "Available") {
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -Force
        Import-Module ADDSDeployment
        Install-ADDSForest
    }
}

$testConnectionCounter = 1
$continueTestConnection = $true
while ($continueTestConnection -eq $true) {
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
    $testConnectionCounter = 1   
}

$domain = [string] (Invoke-Command -Session $session -ScriptBlock {
    (Get-ADDomain).DNSRoot
})
Add-Computer -DomainName $domain -Credential ($domain.split(".")[0] + "\") -Force -Restart

