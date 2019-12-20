<#
.SYNOPSIS
This function finds the Public IP address of local or remote computer and returns it.

.DESCRIPTION
This function finds the Public IP address of local or remote computer and returns it. It can run with multiple computers and use credentials if needed.

.PARAMETER ComputerName
Specifies the name computer or computers.

.PARAMETER UseCredentials
Switch parameter. If used, you will be asked to provide credentials that are used to access computers.

.INPUTS
None; Computer(s) name(s);

.OUTPUTS
Public IP

.EXAMPLE
C:\PS> Get-PublicIP

.EXAMPLE
C:\PS> Get-PublicIP -ComputerName COMPUTERNAME1

.EXAMPLE
C:\PS> $ComputerList | Get-PublicIP

.LINK
https://github.com/vukasinterzic/AdminToys

#>

function Get-PublicIP {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [array]$ComputerName="$env:COMPUTERNAME",

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [switch]$UseCredentials
    )

    Write-Verbose -Message "Running function Get-PublicIP..."

    $PublicIP = @()

    Write-Verbose -Message "Defining API that is used to retreive public IP address.."
    $url = "https://api.ipify.org/?format=json"

    if (($UseCredentials) -and (!$Credential)) {
        $Credential = Get-Credential -Message "Enter credentials"
    }

    foreach ($Computer in $ComputerName) {

        Write-Verbose -Message "Testing if $Computer is accessible..."
        if (Test-Connection $Computer -Count 1 -Quiet) {

            Write-Verbose -Message "Computer $Computer is accessible."

            if ($UseCredentials) {
                #creating cmdlet with parameter -Credentials. Variables have escape character (`) so their content is not added to $arg string.
                $arg1 = "Invoke-Command -ComputerName `$Computer -Credential `$credential -ScriptBlock {(Invoke-RestMethod `$using:url).ip}"

            }
            elseif ($Computer -eq "$env:COMPUTERNAME") {
                #cmdlet without -Credentials and without -ComputerName parameters
                $arg1 = "(Invoke-RestMethod $url).ip"
            }

            else {
                #cmdlet without -Credentials, useful if user already has access
                $arg1 = "Invoke-Command -ComputerName `$Computer -ScriptBlock {(Invoke-RestMethod `$using:url).ip}"
            }

            Write-Verbose -Message "Collecting Public IP of computer $Computer..."
            
            $IP = Invoke-Expression $arg1

            Write-Verbose -Message "Creating object with all collected information..."

            $obj = New-Object psobject
            $obj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer
            $obj | Add-Member -MemberType NoteProperty -Name PublicIP -Value $IP
            $PublicIP += $obj

        }
        else {
            Write-Verbose -Message "Computer $Computer is not accessible. It will be skipped."
        }
    
    }
    
    if ($PublicIP) {
        $PublicIP
    }

    Write-Verbose -Message "End of function Get-PublicIP."
}