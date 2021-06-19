#*------v Function ConvertTo-L33t v------
function ConvertTo-L33t {
    <#
    .SYNOPSIS
    ConvertTo-L33t - replace vowels with similar shaped numberse, and return string to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-L33t.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-L33t:init
    .DESCRIPTION
    ConvertTo-L33t - replace vowels with similar shaped numberse, and return string to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> convertto-l33t -string 'leet' 
    Convert replacing aeio with numerals, and the letter t with '7'
    .EXAMPLE
    PS> convertto-l33t -string 'leet' -vowelsonly
    Convert replacing aeio with numerals, only (no T->7 replacement)
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(HelpMessage="replace only vowels in target string[-vowelsonly]")]
        [switch]$VowelsOnly
    ) ;
    $string = $string.replace("a", "4").replace("e", "3").replace("i", "1").replace("o", "0") 
    # .replace("u", "(_)") ; 
    if(!$VowelsOnly){
            $string = $string.replace('t','7') 
    } ; 
    $string | write-output ; 
} ; 
#*------^ END Function ConvertTo-L33t ^------