#*------v Function ConvertTo-CamelCase v------
function ConvertTo-CamelCase {
    <#
    .SYNOPSIS
    ConvertTo-CamelCase - Convert passed string to StudlyCaps\CrazyCaps etc (randomize uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-CamelCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-CamelCase:init
    .DESCRIPTION
    ConvertTo-CamelCase - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    CamelCase: Words are written without spaces, and the first letter of each word is capitalized. Also called Upper Camel Case or Pascal Casing.
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> ConvertTo-CamelCase.ps1 -string 'In PowerShell, the command used for string matching is of course Select-String' ; 
    .EXAMPLE
    PS> convertto-camelcase -string $string -AlphaNumeric $false 
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
    # TitleCase, and strip spaces
    $txtInfo=(get-culture).TextInfo ;
    $string = "$($txtInfo.ToTitleCase($string.toLower()))".replace(' ','') 
    if($AlphaNumeric){
        $string = ($string -split "" |?{$_ -match '[a-zA-Z0-9]'}) -join '' ;
    }
    $string | write-output ; 
} ; 
#*------^ END Function ConvertTo-CamelCase ^------