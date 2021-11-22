#*------v convert-Rot47.ps1 v------
function convert-Rot47 {
    <#
    .SYNOPSIS
    convert-Rot47 - Converts passed string to/from Rot47. Run encoded text back through and the origen text is returned
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
    * 2:35 PM 11/22/2021 update CBH, this is invertable, so cmdlet name should be convert-Rot13, not to/from. 
    * 6:22 PM 6/18/2021 convert-Rot47:init
    .DESCRIPTION
    convert-Rot47 - Converts passed string to/from Rot47 
    Replaces a character within the ASCII range [33, 126] with the character 47 character after it (rotation) in the ASCII table.
    Rot47 is an invertible algorithm: applying the same algorithm to the input twice will return the origin text. 
    .PARAMETER  path
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot47 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://gist.github.com/chillitom/8335042
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [Alias('in')]
        [String]$string
    ) ;
    $table = @{} ; 
    for ($i = 0; $i -lt 94; $i++) {
        $table.Add(
            "!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~"[$i],
            "PQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO"[$i]) ; 
    } ; 
    $out = New-Object System.Text.StringBuilder ;
    $string.ToCharArray() | %{
        $char = if ($table.ContainsKey($_)) {$table[$_]} else {$_} ; 
        $out.Append($char) | Out-Null ; 
    } ; 
    $out.ToString() | write-output ; 
}

#*------^ convert-Rot47.ps1 ^------