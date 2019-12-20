<#
.SYNOPSIS
This function will find the uptime of local or remote computers.

.DESCRIPTION
Run function against local or remote computer or computers and get their exact uptime in format Computer Name + Last Boot Up Time + Uptime duration

.PARAMETER ComputerName
Specifies the name computer or computers. If not computer parameter is specified, it will run on local computer

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.PARAMETER ExportPath
Specify export file path, including file name.

.INPUTS
None; Computer(s) name(s); Credentials; Export Path

.OUTPUTS
Uptime

.EXAMPLE
C:\PS> Get-Uptime

.EXAMPLE
C:\PS> Get-Uptime -Computers COMPUTERNAME1 -UseCredentials user@domain.extension

.EXAMPLE
C:\PS> $ComputerList | Get-Uptime

.LINK
https://github.com/vukasinterzic/AdminToys

#>


function Get-Uptime {
    [CmdletBinding()]

    param 
    (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$ComputerName = $env:COMPUTERNAME,

        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials,
        
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$ExportPath
    
    )

    begin {
        Write-Verbose "Function Get-Uptime start. Finding uptime space."
        
        if (($UseCredentials) -and (!$Credential)) {
            Write-Verbose "Parameter UseCredentials is used. Getting user credentials..."
            Write-Host -ForegroundColor Cyan "Enter your credentials:"
            $Credential = Get-Credential
        }
        
    }

    process {

        $ComputersUptime = @()

        # Computers loop start
        foreach ($Computer in $ComputerName) {

            Try {

                Write-Verbose "Collecting uptime information on $Computer..."

                if ($UseCredentials) { 
                    #creating cmdlet with parameter -Credentials. Variables have escape character (`) so their content is not added to $arg string.
                    $arg = "Get-WmiObject -Class Win32_OperatingSystem -Property LastBootUpTime -ComputerName `$Computer -Credential `$Credential -ErrorAction Stop"

                }
                elseif ($Computer -eq "$env:COMPUTERNAME") {
                    #cmdlet without -Credentials and without -ComputerName parameters
                    $arg = "Get-WmiObject -Class Win32_OperatingSystem -Property LastBootUpTime -ErrorAction Stop"
                }
                else {
                    #cmdlet without -Credentials parameter. Useful for localhost or computers where current user has access.
                    $arg = "Get-WmiObject -Class Win32_OperatingSystem -Property LastBootUpTime -ComputerName `$Computer -ErrorAction Stop"

                }

                $UpTime = Invoke-Expression $arg 
                $LastBootUpTime = $UpTime.ConvertToDateTime($Uptime.LastBootUpTime)
                $Time = (Get-Date) - $LastBootUpTime
                $UptimeLength = '{0:00}:{1:00}:{2:00}:{3:00}' -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds

                $obj = New-Object -TypeName psobject
                $obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
                $obj | Add-Member -MemberType NoteProperty -Name LastBootupTime -Value $LastBootUpTime
                $obj | Add-Member -MemberType NoteProperty -Name Uptime -Value $UptimeLength

                $ComputersUptime += $obj

            }
            
            Catch {
                Write-Verbose "Error was detected."
                Write-Host -ForegroundColor Yellow "There was an error while connecting to " -NoNewline
                Write-Host -ForegroundColor Red  "$Computer" -NoNewline
                Write-Host -ForegroundColor Yellow ". Error message is bellow:"
                Write-Host ""
                Write-Host -ForegroundColor Red $($_.Exception.message)
                Write-Host ""
            
            } 

        } #end of Computers loop

        if ($ComputersUptime.Count -gt 0 ) {

            if ($ExportPath) {
                Write-Verbose "Parameter ExportPath specified, exporting data to CSV file..."
                $ComputersUptime | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation
            }

            #show results:    
            Write-Verbose -Message "Uptime information collected on $(Get-Date -DisplayHint Date):"

            $ComputersUptime

        }

    } #end of Process

    end {

        Write-Verbose "End of Get-Uptime function."
    }


} #end of Get-Uptime