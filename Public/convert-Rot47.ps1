#*------v Function convert-Rot47 v------
function convert-Rot47 {
    <#
    .SYNOPSIS
    convert-Rot47 - Converts passed string to/from Rot47
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convert-Rot47.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-text
    AddedCredit : ChilliTom
    AddedWebsite:	https://gist.github.com/chillitom/8335042
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convert-Rot47:init
    .DESCRIPTION
    convert-Rot47 - Converts passed string to/from Rot13 
    Replace every letter of the ASCII alphabet with the letter which is "rotated" 13 characters "around" the 26 letter alphabet from its normal cardinal position   (wrapping around from   z   to   a   as necessary). 
    .PARAMETER  path
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot47.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://gist.github.com/chillitom/8335042
    #>
    ##[Alias('convertTo-ProperCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    $table = @{} ; 
    for ($i = 0; $i -lt 94; $i++) {
        $table.Add(
            "!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~"[$i],
            "PQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO"[$i]) ; 
    } ; 
    $out = New-Object System.Text.StringBuilder ;
    $in.ToCharArray() | %{
        $char = if ($table.ContainsKey($_)) {$table[$_]} else {$_} ; 
        $out.Append($char) | Out-Null ; 
    } ; 
    $out.ToString() | write-output ; 
} ; 
#*------^ END Function convert-Rot47 ^------