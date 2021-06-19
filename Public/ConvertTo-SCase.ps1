#*------v Function ConvertTo-SCase v------
function ConvertTo-SCase {
    <#
    .SYNOPSIS
    ConvertTo-SCase - Convert passed string to SentanceCase and return to pipeline (simplistic)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-SCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-SCase:init
    .DESCRIPTION
    ConvertTo-SCase - Convert passed string to SentanceCase and return to pipeline (simplistic)
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    ConvertTo-SCase.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-SentanceCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    # SentanceCase : capitalize first word, rest lcase (simplistic)
    ($string.substring(0,1).toupper())+($string.substring(1).tolower()) | write-output ; 
} ; 
#*------^ END Function ConvertTo-SCase ^------