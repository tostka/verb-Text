#*------v Function convert-Rot13 v------
function convert-Rot13 {
    <#
    .SYNOPSIS
    convert-Rot13 - Converts passed string to/from Rot13 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convert-Rot13.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : rosettacode.org
    AddedWebsite:	https://rosettacode.org/wiki/Rot-13#PowerShell
    AddedTwitter:	URL
    REVISIONS
    * 2:35 PM 11/22/2021 update CBH, this is invertable, so cmdlet name should be convert-Rot13, not to/from. 
    * 6:22 PM 6/18/2021 convert-Rot13:init
    .DESCRIPTION
    convert-Rot13 - Converts passed string to/from Rot13. Run encoded text back through and the origen text is returned
    Replace every letter of the ASCII alphabet with the letter which is "rotated" 13 characters "around" the 26 letter alphabet from its normal cardinal position   (wrapping around from   z   to   a   as necessary). 
    Rot13 is an invertible algorithm: applying the same algorithm to the input twice will return the origin text. 
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot13 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://rosettacode.org/wiki/Rot-13#PowerShell
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    [char[]](0..64+78..90+65..77+91..96+110..122+97..109+123..255)[[char[]]$string] -join "" | write-output ; 
} ; 
#*------^ END Function convert-Rot13 ^------