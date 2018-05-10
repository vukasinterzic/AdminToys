
<#
.SYNOPSIS

This function loads all commands in module and allow easy access to help. 

.DESCRIPTION

This function was written because of my module to simplify displaying all included functions and what they do.
It loads all commands in provided module and shows them with numbers. Then you can select number and it will show you full help for that command.

.PARAMETER Module
Specifies the name of the module. If no name specified, default module will be used.

.INPUTS

None or Module name.

.OUTPUTS

List of commands. Full help for selected command.

.EXAMPLE

C:\PS> Get-ModuleHelp

.EXAMPLE

C:\PS> Get-ModuleHelp -Module ActiveDirectory

.EXAMPLE

C:\PS> Get-Module -Name ActiveDirectory | Get-ModuleHelp

.LINK

http://www.vukasinterzic.com

#>
function Get-ModuleHelp {
    [CmdletBinding()]

    param 
    (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Module = "AdminToolBox"
    )

    #get name of each command
    $commands = Get-Command -Module $Module | Select-Object -ExpandProperty Name

    $n = 1

    #create ordered hashtable to store functions from module
    $matchHash = [ordered]@{}

    #fill hashtable with command names
    $commands | ForEach-Object { $matchHash.Add($n++, "$_") }

    $selection = ""
    Write-Host -ForegroundColor Green "Hi there. Thank you for using this module.
    Here you can find useful funcitons created to make your job easier.

    Using this module does not require more than a basic knowledge of PowerShell.
    However, it does not contain all the tools that you should ever need. 
    It contains only functions that are not part of PowerShell itself. Everything that already exists as a simple CMDLET is not part of this module.

    In case you have any suggestions or you want to report a bug, please send me an email.

    Vukasin Terzic
    terzic@kpcs.cz
    "


    Write-Host -ForegroundColor Yellow "List of all custom functions that are included in this module:"

    #write list of all commands in module
    foreach ($ln in $matchHash.GetEnumerator()) {
        if ($ln.Name % 2 -eq 0) {
            write-host -ForegroundColor Green "$($ln.Name) $($ln.Value)" #line with even numbers will be green
        }
        elseif ($ln.Name % 2 -eq 1) {
            write-host -ForegroundColor White "$($ln.Name) $($ln.Value)" #line with odd numbers will be white
        }
    }



    Write-Output `r`n

    while ($selection -ne "Q") { #runs untill you enter Q

        If ($matchHash.Keys -match $selection) {

            foreach ($line in $matchHash.GetEnumerator()) {
    
                if ($selection -eq $line.Name) {
                    Get-Help -Name $line.Value -Full #get -Full help for command
                }
            }
        }
        elseif ($selection -eq "L") { #entering L will list all commands again.
            Write-Output `r`n    
            Write-Host -ForegroundColor Yellow "List of all included Functions:"

            #write list of all commands in module
            foreach ($ln in $matchHash.GetEnumerator()) {
                if ($ln.Name % 2 -eq 0) {
                    write-host -ForegroundColor Green "$($ln.Name) $($ln.Value)" #line with even numbers will be green
                }
                elseif ($ln.Name % 2 -eq 1) {
                    write-host -ForegroundColor White "$($ln.Name) $($ln.Value)" #line with odd numbers will be white
                }
            }

            Write-Output `r`n
            $selection = ""
            
        }
        else {
            Write-Host -ForegroundColor Red "Invalid input!"
            $selection = ""
        }

        #multi color one line message
        Write-Host -ForegroundColor Green "Enter " -NoNewline
        Write-Host -ForegroundColor Yellow "'cmdlet number'" -NoNewline
        Write-Host -ForegroundColor Green " to show it's help page. " -NoNewline
        Write-Host -ForegroundColor Yellow "'L'" -NoNewline
        Write-Host -ForegroundColor Green " for listing all functions again. Enter " -NoNewline
        Write-Host -ForegroundColor Yellow "'Q'" -NoNewline
        Write-Host -ForegroundColor Green " to quit this function: " -NoNewline
        $selection = Read-Host #read user input
        
    }

}