#*------v Function convertTo-StUdlycaPs v------
function convertTo-StUdlycaPs {
    <#
    .SYNOPSIS
    convertTo-StUdlycaPs - Convert passed string to StudlyCaps\CrazyCaps etc (random uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-StUdlycaPs.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 convertTo-StUdlycaPs:init
    .DESCRIPTION
    convertTo-StUdlycaPs - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-StUdlycaPs.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-StUdlycaSe','convertTo-CrAzYCaPS')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    [array]$chars = $String -split "" ; 
    [string]$output = $null ; 
    foreach($c in $chars){
        switch (1,2|get-random){
            1 {$output += $c.tolower() }
            2 {$output += $c.toUpper() }
        }
    } ;
    $output | write-output ; 
} ; 
#*------^ END Function convertTo-StUdlycaPs ^------