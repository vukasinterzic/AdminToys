
<#
.SYNOPSIS

This function help you to find users that have local admin rights on computer. 

.DESCRIPTION

Find users and groups with local admin rights on local or remote computer.

.PARAMETER Computer

Specifies the name of computer or computers.

.PARAMETER ExportPath

Specify export file path, including file name. Export file is csv.

.INPUTS

None; Computer(s) name(s); ExportPath

.OUTPUTS

local admins

.EXAMPLE

C:\PS> Get-LocalAdmins

.EXAMPLE

C:\PS> Get-LocalAdmins -Computers COMPUTERNAME1 -ExportPath C:\export.csv

.EXAMPLE

C:\PS> computerlist.txt | Get-LocalAdmins

.LINK

https://github.com/vukasinterzic/AdminToolBox

#>


function Get-LocalAdmins {  
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$Computers = @(""),
    
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath = ""    
    )  

    $credentials = Get-Credential

    # Computers loop
    foreach ($Computer in $Computers) {

        Try {
    
            $admins = Get-WmiObject -ClassName win32_GroupUser –ComputerName $Computer -Credential $credentials -ErrorAction Stop
            $admins = $admins | Where-Object {$_.groupcomponent –like '*"Administrators"'}
  
            #trim unneccessary informaiton
            $result = $admins | ForEach-Object {  
                $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul  
                $matches[1].trim('"') + “\” + $matches[2].trim('"')  
            }

            #show results:    
            Write-Host -ForegroundColor Yellow "Local admins on computer " -NoNewline
            Write-Host -ForegroundColor Green  "$Computer" -NoNewline
            Write-Host -ForegroundColor Yellow ":"

            $result     

            if ($ExportPath) {

                $report = @()

                $result | ForEach-Object {
                    $obj = New-Object -TypeName psobject
                    $obj | Add-Member -MemberType NoteProperty -Name Computer -Value $Computer
                    $obj | Add-Member -MemberType NoteProperty -Name Admin -Value $_
                    
                    $report += $obj
                }

                #export CSV file
                $report | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation -Append
                
            }

        }

        Catch {

            Write-Host -ForegroundColor Yellow "There was an error while connecting to " -NoNewline
            Write-Host -ForegroundColor Red  "$Computer" -NoNewline
            Write-Host -ForegroundColor Yellow ". Error message is bellow:"
            Write-Host ""
            Write-Host -ForegroundColor Red $($_.Exception.message)
            Write-Host ""

        }
            
            
            
    } #End of Computers loop
    
} #End of Get-LocalAdmins

