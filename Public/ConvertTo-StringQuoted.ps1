#*------v Function ConvertTo-StringQuoted v------
Function ConvertTo-StringQuoted {
    <#
    .SYNOPSIS
    ConvertTo-StringQuoted.ps1 - Wrap argument with quotes
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : ConvertTo-StringQuoted.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 9:22 AM 11/22/2021 updated to pipeline support, fixed non-func; flipped name quote-string-> ConvertTo-StringQuoted, with quote-string alias; added example to pass pester
    * 8:27 PM 5/23/2014 
    .DESCRIPTION
    ConvertTo-StringQuoted.ps1 - rap argument with quotes
    .EXAMPLE
    Mr. Watson, Come Here! | ConvertTo-StringQuoted
    .LINK
    #>
    [CmdletBinding()]
    [Alias('quote-string')]
    PARAM([Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be quote-wrapped[-PARAM SAMPLEINPUT]")][string]$String
    ) ;
    "`"$($String)`"" | write-output ; 
} ; #*------^ END Function ConvertTo-StringQuoted ^------
