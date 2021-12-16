Function Test-Cloudflare {
<#
.Synopsis
This will test connection to the CloudFlare DNS
.Description
This command will test the connection through the internet via CloudFlare's One.One.One.One DNS Server
.Parameter Computername
Computername specifies the computer being tested.
.Notes
Author: James Wilson
Last Edit: 2021-12-15
Version 1.12 - Test-Cloudflare is now a function just for testing connection to Cloudflare DNS server, output options have been removed.
    
--- Example 1 ---
    
PS C:\>.\Test-CloudFlare -computername JamesPC
    
Test connectivity to CloudFlare DNS on the computer specified.

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    [Alias('CN','Name')]
    [string[]]$computername
    ) #Param

BEGIN{}

PROCESS {
# Running a test net connection for each computer.
foreach ($computer in $computername) {
    Try {
        $params = @{'Computername'=$computer
                    'ErrorAction'='Stop'
                }
    

    Write-Verbose "Connecting to $computer ..."

    # Connecting to a remote session.
    $session = New-PSSession @params

    # Running the ping/connection test.
    $TestCF = test-netconnection -computername 'one.one.one.one' -InformationLevel Detailed
    Write-Verbose "Testing connection to CloudFlare's DNS with $computer ..."

    #Create a new object with specified properties
    $obj = [pscustomobject]@{'ComputerName'= $computer
               'PingSuccess'= $TestCF.PingSucceeded
               'NameResolve'= $TestCF.NameResolutionSucceeded
               'ResolvedAddresses'= $TestCF.ResolvedAddresses
            } #Object    
 
    #Closes session to the remote computer(s)
    Remove-PSSession $computer
        }
    Catch {
        Write-Host "Remote connection to $computer failed." -ForegroundColor Red
    } #Try/Catch

} #foreach

# Retrieving the job results and adding it to a .txt, .CSV, or displayed to screen depending on Output parameter.
Write-Verbose "Receiving test results ..."

Write-Verbose "Test Finished."

} #process

END {

}

} #function



Function Get-PipeResults {
<#

.Synopsis
Retrieves and/or displays the results of a command from the pipeline.

.Description
This will output piped commands to specified location via specified filename or out host.

.Parameter InputObject
Recieves objects passed to it through the pipeline via the Write-Output cmdlet

.Parameter Path
The name of the folder where results will be saved. The default location is the ccurrent users home directory.

.Parameter Output
Specifies the destination of the output when the script is ran. Accepted Values:
- Host (Output sent to screen)
- Text (Output sent to .txt file)
- CSV (Output sent to .csv file)
Both file options are saved in the users home directory. Default output option is Host.

.Parameter FileName
The name of the file that will be saved when selecting either CSV or Text as the output parameter. The default value is PipeResults.

.Notes
Author: James Wilson
Last Edit: 2021-12-15
Version 1.0
    
--- Example 1 ---
    
PS C:\>.\ Get-Process -Name *shell | Get-PipeResults
    
Get-Process cmdlet has its results via name "shell" output to get-piperesults which is then output to host.

#>
    param (
        [Parameter(ValueFromPipeline=$True)]
        [object[]]$InputObject,
        [Parameter(Mandatory=$False)]
        [string]$Path = "$Env:USERPROFILE",
        [Parameter(Mandatory=$False)]
        [ValidateSet("Host","Text","CSV")]
        [string]$Output = ("Host")
        [Parameter(Mandatory=$False)]
        [string]$FileName = "PipeResults"
     ) #Param

    BEGIN{}

    PROCESS {

    switch ($Output) {
        "Host" {$InputObject}
        "Text" {
            $InputObject | Out-File $Path\$FileName.txt
            Notepad $Path\$FileName.txt
        }
        "CSV" {
             $InputObject | Export-Csv -path $Path\$FileName.Csv
    } 
       } #switch

       Write-Verbose "Getting results ..."
    
    } #Process
} #Function     