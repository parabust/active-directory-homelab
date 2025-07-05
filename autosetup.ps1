param([Parameter(Mandatory = $true)][string] $domainControllerIP)
Enable-PSRemoting -Force
Start-Service WinRM
Set-Item wsman:\localhost\Client\TrustedHosts -value $domainControllerIP -Force

$session = New-PSSession -ComputerName $domainControllerIP -Credential (Get-Credential)

$sessionAdminStatus = [bool] (Invoke-Command -Session $session -ScriptBlock {
    net localgroup administrators -contains (whoami).split("\")[-1]
})
if ($sessionAdminStatus -eq $false) {
    Write-Host "This account on the domain controller doesn't have admin privileges"
    exit
}

Invoke-Command -Session $session -ScriptBlock {
    if ((Get-WindowsFeature -Name AD-Domain-Services).installState -eq "Available") {
        Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -Force
        Import-Module ADDSDeployment
        Install-ADDSForest
    }
}

$domain = [string] (Invoke-Command -Session $session -ScriptBlock {
    (Get-ADDomain).DNSRoot
})
Add-Computer -DomainName $domain -Credential ($domain.split(".")[0] + "\\") -Force -Restart

