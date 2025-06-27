# Active Directory Setup

# 0 - VM Environment Setup

1. Install VirtualBox
2. Install Windows Server 2022 as a VM
3. Install Windows 11 as a VM

# 1 - Domain Controller Installation

1. Use `sconfig` for configurations such as IP address, DNS, etc.

2. Install Active Directory
```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

# 2 - Configuring DNS

1. Set Windows Server 2022 DNS to its own IP Address

Find network interface index for the network adapter
```shell
Get-DnsClientServerAddress
```

Change the DNS to the Window Server 2022's IPv4 Address
```shell
Set-DnsClientServerAddress -InterfaceIndex {Index} -ServerAddresses {IP Address}
```

2. Set Windows 11 Machine DNS to the Windows Server 2022's IP Address

Repeat the same steps from configuring the Windows Server 2022's DNS

# Troubleshooting

Random list for now
```shell
nslookup {DomainName}
```

