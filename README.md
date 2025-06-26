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