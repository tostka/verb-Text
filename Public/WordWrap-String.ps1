#*------v Function WordWrap-String  v------
Function WordWrap-String {
<#
    .SYNOPSIS
    WordWrap-String - Word wrap function, return word wrapped version of passed string
    .NOTES
    Author: wolfplusplus
    Website:	http://blog.wolfplusplus.com/?p=260
    REVISIONS   :
    9:50 AM 5/1/2014 try to extend it to vari-leng or window
    9:48 AM 5/1/2014
    .DESCRIPTION
    WordWrap-String - Word wrap function, return word wrapped version of passed string
    .PARAMETER  Str
    String to be wrapped
    .PARAMETER  Wrap
    Specify either the integer character number to perform a wrap at, or specify 'WINDOW', to default the wrap char count to the width of the current window.
    .INPUTS
    None
    .OUTPUTS
    System.String
    .EXAMPLE
    write-host (WordWrap-String $logline 80)
    .LINK
    http://blog.wolfplusplus.com/?p=260
    #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "String to be wrapped[-str 'string']")][ValidateNotNullOrEmpty()]
        [string]$Str,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "character number to wrap at, or 'WINDOW' to indicate wrap should be performed at width of current window[-Wrap 'WINDOW']")][ValidateNotNullOrEmpty()]
        $Wrap
    ) ;
    if ($Wrap.ToUpper() -eq "WINDOW") {
        $Wrap = (get-host).ui.rawui.windowsize.width
    } elseif ($Wrap -is [string]) {
        write-host -fore yell ("INVALID `$Wrap param: " + $Wrap + "`n Syntax: WordWrap-String [string] [#chars]")
    }  
    $sWrapped = ""
    $curLn = ""
    # $ split string at spaces, then Loop over the words and write a line out just short $spec'd size
    foreach ($word in $str.Split(" ")) {
        # see if adding a word makes string longer then window width
        $checkLinePlusWord = $curLn + " " + $word
        if ($checkLinePlusWord.length -gt $Wrap) {
            # With the new word, over width `n before next word
            $sWrapped += [Environment]::Newline
            $curLn = ""
        }
        # Append word to current line and final str
        $curLn += $word + " "
        $sWrapped += $word + " "
    } 
    return $sWrapped
} #*------^ END Function WordWrap-String ^------ ;