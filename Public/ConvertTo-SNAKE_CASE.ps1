#*------v Function ConvertTo-SNAKE_CASE v------
function ConvertTo-SNAKE_CASE {
    <#
    .SYNOPSIS
    ConvertTo-SNAKE_CASE - Convert passed string to StudlyCaps\CrazyCaps etc (randomize uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-SNAKE_CASE.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-SNAKE_CASE:init
    .DESCRIPTION
    ConvertTo-SNAKE_CASE - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    lowerCamelCase: Words are written without spaces, and the first letter of each word is capitalized, with the *exception* of the first letter, which is lowercase.
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> ConvertTo-SNAKE_CASE -string 'i phone apple'
    .EXAMPLE
    PS> ConvertTo-SNAKE_CASE -string $string -AlphaNumeric $false 
    Converting a string, with Alphanumeric overridden (passes puncuation, high ascii chars, and other non-Alphanumeric characters).
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-PascalCase','convertTo-UpperCamelCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(HelpMessage="boolean (defaults `$true) that strips all non-alphanumerics from the string[-string 'SAMPLEINPUT']")]
        [boolean]$AlphaNumeric=$true, 
        [Parameter(HelpMessage="switch that outputs resulting string in lowercase (vs default UPPER_CASE)[-useLower 'SAMPLEINPUT']")]
        [switch]$useLower
    ) ;
    if($useLower){
        $string = $string.toLower().replace(' ','_')  ; 
    } else { 
        $string = $string.toUpper().replace(' ','_')  ; 
    } ; 
    if($AlphaNumeric){
        $string = ($string -split "" |?{$_ -match '[a-zA-Z0-9_]'}) -join '' ;
    }
    $string | write-output ; 
} ; 
#*------^ END Function ConvertTo-SNAKE_CASE ^------