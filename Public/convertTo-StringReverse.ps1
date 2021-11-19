#*------v Function `convertTo-StringReverse` v------
function convertTo-StringReverse {
    <#
    .SYNOPSIS
    convertTo-StringReverse - Reverse character order of passed string & return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-StringReverse.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 11:04 AM 11/19/2021 removed typo Crlf (prevented proper join), pulled strong typing on $string (prevented flipping to [array] for processing)
    * 6:22 PM 6/18/2021 convertTo-StringReverse:init
    .DESCRIPTION
    convertTo-StringReverse - Reverse character order of passed string & return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-StringReverse.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        $string
    ) ;
    $string = $string.ToCharArray() ; 
    [Array]::Reverse($string) ;
    $string -join '' | write-output ; 
} ; 
#*------^ END Function convertTo-StringReverse ^------