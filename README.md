# AdminToolBox
This is the place where I keep the code for my AdminToolBox PowerShell module.

Module contains bunch of functions that are helping with everyday taks. Functions are saved in individual folders and they are fetched inside psm1 file.


## Functions:

#### Get-ModuleHelp
This function was written to simplify using this module.
It loads all commands in module and shows them with numbers. Then you can enter function number and it will show you full help for that command.

This function can be used with any module.

#### Get-DiskSpace
Collect basic disk information from local and remote computers and export it to CSV.

#### New-DNSRecord
Create new A DNS record in AD integrated DNS zone using dnscmd tool.

#### Get-LocalAdmins
Get list of users and groups with local admin rights on local or remote computer. Export to CSV if needed.

#### Get-Uptime
Get the exact uptime and last bootup time of local or remote computer or computers.

#### Get-ADServersInfo
Collect basic information about specified servers or all servers found in Active Directory. Collected information is useful for having basic overview of where they are, what systems are they running and what are they used for.

#### Get-PublicIP
This function finds the Public IP address of local or remote computer and returns it. It can run with multiple computers and use credentials if needed.

#### StampFile
Add date and time stamp to the end of the file name. You can use it to rename the existing file or to make a copy of that file with date and time added to the end of the original name.

#### Convert-TextToASCIIArt
Converts your Text to
```
  _______        _   
 |__   __|      | |  
    | | _____  __ |_ 
    | |/ _ \ \/ / __|
    | |  __/>  <| |_ 
    |_|\___/_/\_\\__|
```

## Work in progress functions
Get-AccountFromSID, Get-SIDFromAccount, Get-ShutDown, Get-LogOnLogOut, Get-InstalledSoftware, Get-FirewallRules, Copy-MyItem, Install-ModuleFromGitHub, Update-ModuleFromGitHub, Get-ADGroupMembershipChanges, Get-ComputerBitlockerInfo, Set-PingFirewallRule, ...

## Planned changes
#TODO Add more functions

#TODO Add functions from FullServerInfo script

#TODO Add guide on how to install module from library/github

#FIXME Local computer should be default

#FIXME functions shouldn't ask for credentials if not specified
