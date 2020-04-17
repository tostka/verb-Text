#*------v Function wrap-Text v------
Function wrap-Text {
    <#
    .SYNOPSIS
    wrap-Text.ps1 - Wrap a string at specified number of characters
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * added CBH
    .DESCRIPTION
    wrap-Text.ps1 - Wrap a string at specified number of characters
    .PARAMETER  sText
    Specify string to be wrapped
    .PARAMETER  nChars
    Number of characters, at which to wrap the string
    .EXAMPLE
    $text=wrap-Text -sText "Please send issues to technisbetas@gmail.com, putting them in the reviews doesn't help me find fix them" -nChars 30 ;
    .LINK
    https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
    #>
    [CmdletBinding()]
    param([string]$sText, [int]$nChars) 
    $words = $sText.split(" ");
    $sPad = "";
    $sTextO = "";
    foreach ($word in $words) {
        if (($sPad + " " + $word).length -gt $nChars) {
            $sTextO = $sTextO + $sPad + "`n"  ;
            $sPad = $word ;
        }
        else {$sPad = $sPad + " " + $word  } ;
    }  ;
    if ($sPad.length -ne 0) {$sTextO = $sTextO + $sPad };
    $sTextO | write-output ; 
} ; #*------^ END Function wrap-Text ^------
