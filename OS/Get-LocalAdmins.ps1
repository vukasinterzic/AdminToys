
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
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials,
    
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath = ""    
    )  

    begin {

        Write-Verbose "Starting function Get-LocalAdmins..."

        if (($UseCredentials) -and (!$Credential)) {
            Write-Verbose "Parameter UseCredentials is used. Getting user credentials..."
            Write-Host -ForegroundColor Cyan "Enter your credentials:"
            $Credential = Get-Credential
        }

    }

    process {

        $ComputerAdmins = @()

        # Computers loop
        foreach ($Computer in $ComputerName) {

            Write-Verbose -Message "Proceeding with computer $Computer ..."

            if ($UseCredentials) { 
                #creating cmdlet with parameters -Credentials and -ComputerName. Variables have escape character (`) so their content is not added to $arg string.
                $arg = "Get-WmiObject -ClassName win32_GroupUser –ComputerName `$Computer -Credential `$Credential -ErrorAction Stop"

            }
            elseif ($Computer -eq "$env:COMPUTERNAME") {
                #cmdlet without -Credentials and -ComputerName parameters in case of local computer
                $arg = "Get-WmiObject -ClassName win32_GroupUser -ErrorAction Stop"
            }
            else {
                #cmdlet without -Credentials parameter. Remote computer where current user has access
                $arg = "Get-WmiObject -ClassName win32_GroupUser –ComputerName `$Computer -ErrorAction Stop"

            }


            Try {

                $Admins = Invoke-Expression $arg
                $Admins = $Admins | Where-Object {$_.groupcomponent –like '*"Administrators"'}

                $result = $admins | ForEach-Object {  
                    $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $nul  
                    $matches[1].trim('"') + “\” + $matches[2].trim('"')  
                }



                $result | ForEach-Object {
                    $obj = New-Object -TypeName psobject
                    $obj | Add-Member -MemberType NoteProperty -Name Computer -Value $Computer
                    $obj | Add-Member -MemberType NoteProperty -Name Admin -Value $_
                    
                    $ComputerAdmins += $obj
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
    
    } #End of Process

    end {

        if ($ComputerAdmins.Count -gt 0) {

            if ($ExportPath) {

                Write-Verbose -Message "ExportPath parameter selected. Exporting results to file."
                #export CSV file
                $report | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation -Append
                
            }

            Write-Verbose -Message "Local admins on computers are:"
            
            $ComputerAdmins

        }

        Write-Verbose "End of Get-LocalAdmins function."

    }



} #End of Get-LocalAdmins

