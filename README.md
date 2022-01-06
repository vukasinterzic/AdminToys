# AdminToys

This module started as a collection of few functions to help with daily tasks. Module will grow over time and new useful functions will be added.

Functions are designed in the way so they can be used individually, or as a part of a larger script. If you use variable $Credential to store credentials, you won't need to enter credentials for each function. Individual functions do not check for remote computer accessibility. You can do that once and then pass only accessible computers to individual functions. It is designed like this to avoid multiple checks. Results can be saved in new object, and then presented and sorted in various formats.

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

#### Get-ADServerInfo
Collect basic information about specified servers or all servers found in Active Directory. Collected information is useful for having overview of where they are, in which site, are they physical or virtual and on wich physical host, what systems are they running and what are they used for.

#### Get-InstalledFeatures
This function collects the list of installed Windows features from remote or local computer with Server OS.

#### Get-NetAdapterInfo
Colects all information from Win32_NetworkAdapterConfiguration and Get-NetAdapter, and combines it in one object.

#### Get-PublicIP
This function finds the Public IP address of local or remote computer and returns it. It can run with multiple computers and use credentials if needed.

#### Get-GeoIPInfo
This function find geographical information about public IP address, including link to the map.

#### Get-MACVendor
Uses online up-to-date information to identify vendor of MAC address that is provided.

#### Get-DPMProtectedVMs
Gets the list of all items that are protected by DPM.

#### Test-Elevation
Check if PowerShell console is opened as Administrator. It returns Boolean value.

#### StampFile
Add date and time stamp to the end of the file name. You can use it to rename the existing file or to make a copy of that file with date and time added to the end of the original name.

#### Invoke-Unzip
Zip file extraction by attempting 3 methods, in case prerequisites are not met.

#### Get-ConsoleMusic
Fun little function that plays songs directly from console. Currently available melodies: Super Mario, Tetris, Mission Impossible, Star Wars.

#### Set-PingFirewallRules
Enables TCP IPv4 and IPv6 ports on remote or local computer so you can use PING. It can also create block rules to disable it.

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
Get-SCOMObjectsInMaintenance, Get-SCOMMonitoredVMs, Get-SCOMNotMonitoredVMs, Get-SCOMAgentHealth, Get-SCOMEventsForVM, Get-DPMUnprotectedVMs, Get-DPMServerInfo (storage, network, jobs, cloud etc..), Get-iDRACInfo, Get-iLOInfo, Find-ADAccountLockoutSource

Optional: Set-Elevation, Get-AccountFromSID, Get-SIDFromAccount, Get-ShutDown, Get-LogOnLogOut, Get-InstalledSoftware, Get-FirewallRules, Copy-MyItem, Set-PingFirewallRule, Get-Shares, Get-AdministrativeEvents, Write-ToEventLog, Get-ScheduledTask, SayThis, Get-ADGroupMembershipChanges, Get-ComputerBitlockerInfo ...

## Planned changes
#FIXME Rename module and repository and give it unique name

#TODO Start Changelog.md file and track all changes in repository

#TODO Add more functions

#TODO Create Azure DevOps workflow to test, update and add module to PowerShell Gallery
