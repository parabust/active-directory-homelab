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

# 2 - Configuring IPs and DNS for Both Machines

**1. Configure IP and DNS for the Windows Server Machine**

Retrieve network adapter information:
```shell
netsh interface ipv4 show interfaces
```
When using VirtualBox, the machines will be using Ethernet.

Change the IP address of the Windows server to a static IPv4 address:
```shell
netsh interface ipv4 set address name="{Interface Name}" static {IP Address} {Subnet Mask} {Default Gateway}
```

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

# 4 - Add user(s) to the Domain

**1. On the Windows Server machine, add any amount of users with this command:**
```shell
New-ADUser -Name {Name} -GivenName {First Name} -Surname {Last Name} -SamAccountName {Username} -UserPrincipalName {Username}@{Domain} -AccountPassword (ConvertTo-SecureString {Password} -AsPlainText -Force) -PassThru | Enable-ADAccount
```

# Troubleshooting

Check that your domain controller is running.
```shell
nslookup {DomainName}
```

