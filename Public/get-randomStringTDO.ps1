function get-randomStringTDO {
<#
    .SYNOPSIS
    get-randomStringTDO() - Return a random alphanumeric string
   .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-06-13
    FileName    : get-randomStringTDO.ps1
    License     : MIT License
Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text,String,Random
    REVISIONS   :
    * 11:13 AM 6/13/2025 init
    .DESCRIPTION
    get-randomStringTDO() - Return a random alphanumeric string
    .PARAMETER length
    Specifies the string length to be returned
    .PARAMETER Alpha
    Alphabetic-only switch    
    .EXAMPLE
    PS> get-randomstring -length 25

        LncksueohGvaBtSJ14Tzf2Orl

    Generate a random Alphanumeric string
    .EXAMPLE
    PS> get-randomstring -length 25 -alpha

        lqDKNvBpkQCjnuJTgERwUSxYW
    
    Generate a random Alphabetic string
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CMdletBinding()]
    PARAM (
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Specifies the string length to be returned')]
            [int]$length,
        [Parameter(HelpMessage = 'Alphabetic-only switch')]
        [switch]$Alpha
    ) ;
    $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'.ToCharArray();
    if($Alpha){$chars = $chars | ?{$_ -notmatch '[0-9]'}} ; 
    ($chars | get-random -Count $length ) -join '' | write-output ; 
}
