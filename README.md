# AdminToolBox
This is the place where I keep the code for my AdminToolBox PowerShell module.

Module contains bunch of functions that are helping with everyday taks. Functions are saved in individual folders and they are fetched inside psm1 file.

Functions are designed in the way so they can be used individually, or as a part of a larger script. If you use variable $Credential to store credentials, you won't need to enter credentials for each function. Individual functions do not check for remote computer accessibility. You can do that once and then pass only accessible computers to individual functions. It is designed like this to avoid multiple checks.

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

#### StampFile
Add date and time stamp to the end of the file name. You can use it to rename the existing file or to make a copy of that file with date and time added to the end of the original name.

#### Invoke-Unzip
Zip file extraction by attempting 3 methods, in case prerequisites are not met.

#### Get-ConsoleMusic
Fun little function that plays songs directly from console. Currently available melodies: Super Mario, Tetris, Mission Impossible, Star Wars.

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
Get-SCOMObjectsInMaintenance, Get-SCOMMonitoredVMs, Get-SCOMNotMonitoredVMs, Get-SCOMAgentHealth, Get-SCOMEventsForVM, Get-DPMProtectedVMs, Get-DPMUnprotectedVMs, Get-DPMServerInfo (storage, network, jobs, cloud etc..), Get-iDRACInfo

Optional: Set-Elevation, Get-AccountFromSID, Get-SIDFromAccount, Get-ShutDown, Get-LogOnLogOut, Get-InstalledSoftware, Get-FirewallRules, Copy-MyItem, Install-ModuleFromGitHub, Update-ModuleFromGitHub, Get-ADGroupMembershipChanges, Get-ComputerBitlockerInfo, Set-PingFirewallRule, Get-Shares, Get-AdministrativeEvents, Write-ToEventLog, Get-ScheduledTask, SayThis, Export-ScriptsToModule, Copy-DownloadedModule  ...

## Planned changes
#FIXME Rename module and repository and give it unique name

#TODO Start Changelog.md file and track all changes in repository

#TODO Add more functions

#TODO Add guide on how to install module from github/gallery
