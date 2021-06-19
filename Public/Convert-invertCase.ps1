#*------v Function Convert-invertCase v------
function Convert-invertCase {
    <#
    .SYNOPSIS
    Convert-invertCase - Convert passed string to Invert Case (UPPER->lower ; lower->UPPER) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : Convert-invertCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 Convert-invertCase:init
    .DESCRIPTION
    Convert-invertCase - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    Convert-invertCase.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    [array]$chars = $String -split "" ; 
    $output = $null ; 
    foreach($c in $chars){
        switch -regex -CaseSensitive ($c){
            '([A-Z])'{$output += $c.tolower() }
            '([a-z])'{$output += $c.toUpper() }
            default {$output += $c }
        }
    } ;
    $output | write-output ; 
} ; 
#*------^ END Function Convert-invertCase ^------