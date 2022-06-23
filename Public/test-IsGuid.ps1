#*------v Function Test-IsGuid v------
function Test-IsGuid{
    <#
    .SYNOPSIS
    Test-IsGuid.ps1 - Validates a given guid using the TryParse method from the .NET Class “System.Guid”
    .NOTES
    Version     : 1.0.0
    Author      : Morgan
    Website     :	https://morgantechspace.com/
    Twitter     :	
    CreatedDate : 2022-06-23
    FileName    : Test-IsGuid.ps1
    License     : [none specified]
    Copyright   : © 2022 MorganTechSpace
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,GUID
    AddedCredit : 
    AddedWebsite:	https://morgantechspace.com/2021/01/powershell-check-if-string-is-valid-guid-or-not.html
    REVISIONS
    10:13 AM 6/23/2022 add to verb-text
    1/12/21 posted version morgantechspace.com
    .DESCRIPTION
    Test-IsGuid.ps1 - Validates a given guid using the TryParse method from the .NET Class “System.Guid”
    .PARAMETER String
    String to be validated
    .INPUTS
    Accepts pipeline input
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    Test-IsGuid -string '17863633-98b5-4898-9633-e92ccccd634c'
    Stock call
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://morgantechspace.com/2021/01/powershell-check-if-string-is-valid-guid-or-not.html
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        # Uri to be validated
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        #[Alias('')]
        [string]$String
    ) ;
    $ObjectGuid = [System.Guid]::empty
    # Returns True if successfully parsed
    return [System.Guid]::TryParse($String,[System.Management.Automation.PSReference]$ObjectGuid) ;
} 
#*------^ END Function Test-IsGuid ^------
