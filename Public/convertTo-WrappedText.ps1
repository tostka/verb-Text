#*------v Function convertTo-WrappedText v------
Function convertTo-WrappedText {
    <#
    .SYNOPSIS
    convertTo-WrappedText - Wrap a string at specified number of characters
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-08
    FileName    : convertTo-WrappedText.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 9:32 AM 11/22/2021 ren'd wrap-text -> convertTo-WrappedText, w wrap-text alias; added pipeline support ; spliced over -chars 'window' support from wordwrap-string.ps1 (and retired the variant); pulled strong type on $chars, shifted nchars name to an alias, and renamed it Characters; renamed $sText to $Text and shifted sText to an alias; added $host.name checking for 'Window' use
    * 8:35 PM 11/8/2021 typo'd postion on 2nd param; updated CBH to modern spec; added param name aliases (standardizing param names); added clipboard check for sText; defaulted nChars to 80
    * added CBH
    .DESCRIPTION
    convertTo-WrappedText - Wrap a string at specified number of characters
    .PARAMETER  Text
    String to be wrapped[-Text 'Four score and seven years ago']
    .PARAMETER  Characters
[int]Character number to wrap at, or 'WINDOW' to indicate wrap should be performed at width of current window[-Wrap 'WINDOW']
    .EXAMPLE
    $text=convertTo-WrappedText -sText "Please send issues to technisbetas@gmail.com, putting them in the reviews doesn't help me find fix them" -nChars 30 ;
    .LINK
    https://github.com/tostka/verb-Text
    #>
    [CmdletBinding()]
    [Alias('wrap-text')]
    param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be wrapped[-Text 'Four score and seven years ago']")]
        [Alias('String','sText')]
        [string]$Text, 
        #[Parameter(Position=1,HelpMessage="Number of characters, at which to wrap the string[-nChars 120")]
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "[int]Character number to wrap at, or 'WINDOW' to indicate wrap should be performed at width of current window[-Wrap 'WINDOW']")][ValidateNotNullOrEmpty()]
        [Alias('nChars')]
        #[int]
        $Characters=80
    ) 
    
    switch ($Characters.GetType().FullName){
        'System.String' {
            if ($Characters.ToUpper() -eq "WINDOW") {
                switch ($host.name){
                    'ConsoleHost' {
                        [int]$Characters = (get-host).ui.rawui.windowsize.width ; 
                        write-verbose "wrapping to WINDOW -Characters:$($Characters)" ; 
                    }
                    default {
                        write-verbose "$($host.name):-Characters:$($Characters)`n$($Text.length) chars long" ;
                        throw "$($host.name) is not a supported host for this script with the -Characters 'Window' option`nPlease use an interger number instead" ;
                    } ; 
                } ; 
            } else {
                Throw "Unrecognized -Characters string (Please use an integer, or the word 'Window')" ;
            } ;
        } 
        'System.Int32' {
            write-verbose "wrapping to -Characters:$($Characters)" ; 
        } ;
        default {
            Throw "Unrecognized -Characters spec (Please use an integer number, or the word 'Window')" ; 
        } 
    } ; 
    
    if(-not $Text){
        $Text= (get-clipboard) # .trim().replace("'",'').replace('"','') ;
        if($Text){
            write-verbose "No -Text specified, detected text on clipboard:`n$($Text)" ;
        } else {
            write-warning "No -path specified, nothing suitable found on clipboard. EXITING!" ;
            Break ;
        } ;
    } else {
        write-verbose "Text:$($Text)" ;
    } ;
    
    $words = $Text.split(" ");
    $sPad = $sTextO = "";
    foreach ($word in $words) {
        if (($sPad + " " + $word).length -gt $Characters) {
            $sTextO = $sTextO + $sPad + [Environment]::Newline ;
            $sPad = $word ;
        }
        else {$sPad = $sPad + " " + $word  } ;
    }  ;
    if ($sPad.length -ne 0) {$sTextO = $sTextO + $sPad };
    $sTextO | write-output ; 
} ; #*------^ END Function convertTo-WrappedText ^------
