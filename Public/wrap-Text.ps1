#*------v Function wrap-Text v------
Function wrap-Text {
    <#
    .SYNOPSIS
    wrap-Text - Wrap a string at specified number of characters
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-08
    FileName    : wrap-Text.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 8:35 PM 11/8/2021 typo'd postion on 2nd param; updated CBH to modern spec; added param name aliases (standardizing param names); added clipboard check for sText; defaulted nChars to 80
    * added CBH
    .DESCRIPTION
    wrap-Text - Wrap a string at specified number of characters
    .PARAMETER  sText
    Specify string to be wrapped
    .PARAMETER  nChars
    Number of characters, at which to wrap the string
    .EXAMPLE
    $text=wrap-Text -sText "Please send issues to technisbetas@gmail.com, putting them in the reviews doesn't help me find fix them" -nChars 30 ;
    .LINK
    https://github.com/tostka/verb-Text
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,,HelpMessage="Specify string to be wrapped[-sText 'c:\path-to\script.ps1']")]
        [Alias('Text','String')]
        [string]$sText, 
        [Parameter(Position=1,HelpMessage="Number of characters, at which to wrap the string[-nChars 120")]
        [Alias('Characters')]
        [int]$nChars=80
    ) 
    if(-not $sText){
        $sText= (get-clipboard) # .trim().replace("'",'').replace('"','') ;
        if($sText){
            write-verbose "No -sText specified, detected text on clipboard:`n$($sText)" ;
        } else {
            write-warning "No -path specified, nothing suitable found on clipboard. EXITING!" ;
            Break ;
        } ;
    } else {
        write-verbose "sText:$($sText)" ;
    } ;
    
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
