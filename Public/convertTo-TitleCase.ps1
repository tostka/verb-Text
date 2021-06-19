#*------v Function convertTo-TitleCase v------
function convertTo-TitleCase {
    <#
    .SYNOPSIS
    convertTo-TitleCase - Convert passed string to TitleCase and return to pipeline (simplistic)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-TitleCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convertTo-TitleCase:init
    .DESCRIPTION
    convertTo-TitleCase - Convert passed string to TitleCase and return to pipeline (simplistic)
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-TitleCase.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-ProperCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    # SentanceCase : capitalize first word, rest lcase (simplistic)
    $txtInfo=(get-culture).TextInfo ;
    # Doesn’t work on all-caps (make lcase first)
    "$($txtInfo.ToTitleCase($string.toLower()))" | write-output ; 
} ; 
#*------^ END Function convertTo-TitleCase ^------