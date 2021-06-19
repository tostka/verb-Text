#*------v Function ConvertTo-lowerCamelCase v------
function ConvertTo-lowerCamelCase {
    <#
    .SYNOPSIS
    ConvertTo-lowerCamelCase - Convert passed string to StudlyCaps\CrazyCaps etc (randomize uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-lowerCamelCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-lowerCamelCase:init
    .DESCRIPTION
    ConvertTo-lowerCamelCase - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    lowerCamelCase: Words are written without spaces, and the first letter of each word is capitalized, with the *exception* of the first letter, which is lowercase.
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> convertto-lowercamelcase -string 'i phone apple'
    .EXAMPLE
    PS> ConvertTo-lowerCamelCase -string $string -AlphaNumeric $false 
    Converting a string, with Alphanumeric overridden (passes puncuation, high ascii chars, and other non-Alphanumeric characters).
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-PascalCase','convertTo-UpperCamelCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="boolean (defaults `$true) that strips all non-alphanumerics from the string[-string 'SAMPLEINPUT']")]
        [boolean]$AlphaNumeric=$true 
    ) ;
    # TitleCase, strip spaces, and lcase the first character of the string
    $txtInfo=(get-culture).TextInfo ;
    $string = "$($txtInfo.ToTitleCase($string.toLower()))".replace(' ','') 
    if($AlphaNumeric){
        $string = ($string -split "" |?{$_ -match '[a-zA-Z0-9]'}) -join '' ;
    }
    $string.substring(0,1).tolower()+$string.substring(1) | write-output ; 
} ; 
#*------^ END Function ConvertTo-lowerCamelCase ^------