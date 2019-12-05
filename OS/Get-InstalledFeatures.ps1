<#
.SYNOPSIS
This function collects the list of installed Windows features from remote or local computer with Server OS.

.DESCRIPTION
This function detects the OS type and if it is Windows Server OS, it will collect the list of installed Windows Features and return it.

.PARAMETER ComputerName
Specifies the name computer or computers.

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.INPUTS
None; Computer(s) name(s);, Credentials

.OUTPUTS
Installed Windows Features

.EXAMPLE
C:\PS> Get-InstalledFeatures

.EXAMPLE
C:\PS> Get-InstalledFeatures -ExportPath "C:\export.csv"

.EXAMPLE
C:\PS> Get-InstalledFeatures -ComputerName COMPUTERNAME1, COMPUTERNAME2 | Format-Table -GroupBy ComputerName

.EXAMPLE
C:\PS> $ComputerList | % { Get-InstalledFeatures -ComputerName $_ }

.LINK
https://github.com/vukasinterzic/AdminToolBox

#>

function Get-InstalledFeatures {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials
    )     

    begin {

        Write-Verbose -Message "Running function Get-InstalledFeatures..."

        $InstalledFeatures = @()

        if (($UseCredentials) -and (!$Credential)) {
            $Credential = Get-Credential -Message "Enter credentials"
        }

        if (($ComputerName -eq $env:COMPUTERNAME) -or ($ComputerName -eq ".") -or ($ComputerName -eq "localhost")) {
            $ComputerName = $env:COMPUTERNAME
            Write-Verbose -Message "Script will run on local computer."
        }
        else {
            Write-Verbose -Message "Script will run on a remote computer(s)."
        }

    } #end of Begin

        process {

        $InstalledFeatures = @()

        foreach ($Computer in $ComputerName) {

            Write-Verbose -Message "Proceeding with computer $Computer..."

            Try {

                if ($UseCredentials) {
                    #creating cmdlet with parameter -Credentials. Variables have escape character (`) so their content is not added to $arg string.
                    $arg1 = "Get-WmiObject win32_OperatingSystem -ComputerName `$Computer -Credential `$Credential -ErrorAction Stop"
                    $arg2 = "Get-WindowsFeature -ComputerName `$Computer -Credential `$Credential | Where-Object{`$_.installed -eq `$true -and `$_.featuretype -eq 'Role'}"

                }
                elseif ($Computer -eq "$env:COMPUTERNAME") {
                    #cmdlet without -Credentials and without -ComputerName parameters
                    $arg1 = "Get-WmiObject win32_OperatingSystem -ErrorAction Stop"
                    $arg2 = "Get-WindowsFeature | Where-Object{`$_.installed -eq `$true -and `$_.featuretype -eq 'Role'}"
                }

                else {
                    #cmdlet without -Credentials, useful if user already has access
                    $arg1 = "Get-WmiObject win32_OperatingSystem -ComputerName `$Computer -ErrorAction Stop"
                    $arg2 = "Get-WindowsFeature -ComputerName `$Computer | Where-Object{`$_.installed -eq `$true -and `$_.featuretype -eq 'Role'}"
                }

                
                Write-Verbose -Message "Collecting OS info ..."
                
                $OSCaption = Invoke-Expression $arg1 | Select-Object -ExpandProperty Caption

                Write-Verbose -Message "Computer $Computer OS is $OSCaption"


                if ($OSCaption -like "*Server*") {

                    Write-Verbose -Message "Computer is Server, collecting installed roles ..."
                
                    $features = Invoke-Expression $arg2 | Select-Object Name, DisplayName, Installed, InstallState

                    foreach ($result in $features) {

                        $obj = New-Object -TypeName psobject
                        $obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
                        $obj | Add-Member -MemberType NoteProperty -Name FeatureName -Value $result.Name
                        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $result.DisplayName
                        $obj | Add-Member -MemberType NoteProperty -Name Installed -Value $result.Installed
                        $obj | Add-Member -MemberType NoteProperty -Name InstalledState -Value $result.InstallState

                        $InstalledFeatures += $obj
                    }
                    
                }
                else {
                    Write-Verbose -Message "Computer $Computer is not running Server OS, server roles will not be collected."     
                }
            }

            Catch {
                Write-Verbose -Message "Error was detected."
                Write-Host -ForegroundColor Yellow "There was an error while collecting information from computer " -NoNewline
                Write-Host -ForegroundColor Red  "$Computer" -NoNewline
                Write-Host -ForegroundColor Yellow ". Error message is bellow:"
                Write-Host ""
                Write-Host -ForegroundColor Red $($_.Exception.message)
                Write-Host ""

            }

        } #end of computer loop

    } #end of process

    end {

        If ($InstalledFeatures.Count -gt 0) {

            if ($ExportPath) {
                Write-Verbose -Message "Parameter ExportPath specified, exporting data to CSV file..."
                $InstalledFeatures | Export-Csv -Path $ExportPath -Delimiter ";" -NoTypeInformation
            }

            Write-Verbose -Message "Installed features are:"
            $InstalledFeatures
        }

        Write-Verbose -Message "End of function Get-InstalledFeatures."
    } #end of end

} #end of function Get-InstalledFeatures