#*------v Function Test-Uri v------
function Test-Uri{
    <#
    .SYNOPSIS
    Test-Uri.ps1 - Validates a given Uri ; localized verb-EXO vers of non-'$global:' helper funct from ExchangeOnlineManagement. The globals export fine, these don't and appear to need to be loaded manually
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 20201109-0833AM
    FileName    : Test-Uri.ps1
    License     : [none specified]
    Copyright   : [none specified]
    Github      : https://github.com/tostka/verb-exo
    Tags        : Powershell
    AddedCredit : Microsoft (edited version of published commands in the module)
    AddedWebsite:	https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2
    REVISIONS
    * 2:08 PM 12/6/2021 ren'd UriString param to String, and added orig name as alias. Set CBH Output, and broader example; moving into verb-text, where it better fits.
    * 8:34 AM 11/9/2020 init
    .DESCRIPTION
    Test-Uri.ps1 - localized verb-EXO vers of non-'$global:' helper funct from ExchangeOnlineManagement. The globals export fine, these don't and appear to need to be loaded manually. Note this only validates https, not http (which will fail). 
    .PARAMETER String
    String to be validated
    .PARAMETER PermitHttp
    Switch to permit validation of either https or http uri.schemes
    .INPUTS
    Accepts pipeline input
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    Test-Uri -string https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2 
    Stock call
    .EXAMPLE
    Test-Uri -string https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2 
    Call that accepts either https or http scheme (default fails http://)
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        # Uri to be validated
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias('UriString')]
        [string]$String,
        [Parameter()][switch]$PermitHttp
    ) ;
    [Uri]$uri = $String -as [Uri]
    if($PermitHttp){
      ($uri.AbsoluteUri -ne $null) -and ($uri.Scheme -eq 'https' -OR $uri.Scheme -eq 'http')
    } else { 
      $uri.AbsoluteUri -ne $null -and $uri.Scheme -eq 'https' ;
    } ; 
} 
#*------^ END Function Test-Uri ^------
