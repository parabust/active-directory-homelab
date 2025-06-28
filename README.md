# Active Directory Setup

# 0 - VM Environment Setup

**1. Install VirtualBox**

**2. Install Windows Server 2022 as a VM**

**3. Install Windows 11 Pro as a VM (NOT ABLE TO JOIN A DOMAIN ON HOME VERSION)**

# 1 - Domain Controller Setup (Windows Server)

**1. Use `sconfig` for customizations such as IP address, host name, etc.**

**2. Install Active Directory.**
```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

ADDSDeployment module may already be automatically installed on Windows server, but to ensure it's there:
```shell
Import-Module ADDSDeployment
```

Install the forest:
```shell
Install-ADDSForest
```
Pick a domain name and safe-mode administrator password.

# 2 - Configuring DNS for Both Machines

**1. Set Windows server DNS to its own IPv4 address**

Find network interface index for the network adapter:
```shell
Get-DnsClientServerAddress
```

Change the DNS to the Windows server's IPv4 address:
```shell
Set-DnsClientServerAddress -InterfaceIndex {Index} -ServerAddresses {IP Address}
```

**2. Set Windows 11 machine DNS to the Windows server's IPv4 address**

Repeat the same steps from configuring the Windows Server 2022's DNS

# 3 - Join Windows 11 Machine to the Domain

**1. On the Windows 11 machine, run this command and then use the domain controller's credentials:**
```shell
Add-Computer -DomainName {Domain Name} -Credential {Domain}\{Username} -Force -Restart
```
When inputting the domain name with the username for the credential field, ensure you don't include the top level domain. (e.g. .com, .org). If the domain name is domain.com as an example, then it would be domain\User1231.

# Troubleshooting

Check that your domain controller is running.
```shell
nslookup {DomainName}
```

