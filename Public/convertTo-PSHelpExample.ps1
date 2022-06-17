#*------v Function convertTo-PSHelpExample v------
Function convertTo-PSHelpExample {
    <#
    .SYNOPSIS
    convertTo-PSHelpExample - Given a ScriptBlock of unindented sample code, adds leading keyword, prefixes each code line with PS>, and adds empty line for description, for use in a CommentBasedHelp block. If -Scriptblock isn't specified, the current clipboard content is used.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-03-01
    FileName    : convertTo-PSHelpExample.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text,Code,Development,CommentBasedHelp
    REVISIONS
    * 12:37 PM 6/1 7/2022 updated CBH, moved from vert-text -> verb-dev
    * 1:50 PM 3/1/2022 init
    .DESCRIPTION
    convertTo-PSHelpExample - Given a ScriptBlock of unindented sample code, adds leading keyword, prefixes each code line with PS>, and adds empty line for description, for use in a CommentBasedHelp block. If -Scriptblock isn't specified, the current clipboard content is used.
    To save time, pre-left-justify - move the scriptblock leftmost indent to the left margin, before running this process on the code 
    (e.g. don't have the block pre-indented beyond the minimum 1st level).

    Due to the vageries of parsing & splitting herestrings (e.g. attempting to feed the -ScriptBlock with a herestring), 
    it's generally simplest to let this off of code pre-copied to the clipboard
    (comes through cleanly as an array without further need for testing or conversion).

    .PARAMETER  ScriptBlock
    ScriptBlock of powershell to be wrapped reformatted to CBH code sample 
    .PARAMETER Wrap
    Switch to wrap (suffix semcolons with CrLFs) the specified block of code[-wrap]
    .PARAMETER NoPad
    Switch to suppress addition of extra NewLines in output code (true by default)[-noPad
    .EXAMPLE
    convertTo-PSHelpExample ;
    Default no-parameter behavior: Convert clipboard code content into a CBH help example-formatted block. 
    .EXAMPLE
    $text= "write-host 'yea';`ngci 'c:\somefile.txt' ;`n" | convertTo-PSHelpExample ;
    Pipeline example
    .LINK
    https://github.com/tostka/verb-Text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="ScriptBlock of powershell to be wrapped reformatted to CBH code sample")]
        [Alias('Code')]
        [string[]]$ScriptBlock,
        [Parameter(HelpMessage="Switch to wrap (suffix semcolons with CrLFs) the specified block of code[-wrap]")]
        [switch]$Wrap,
        [Parameter(HelpMessage="Switch to suppress addition of extra NewLines in output code (true by default)[-noPad]")]
        [switch]$NoPad=$true 
    )  ; 
    $sCBHKeyword = '.EXAMPLE' ;
    $sCBHPrompt = 'PS> ' ;
    $fromCB = $false ; 
    if(-not $ScriptBlock){
        $ScriptBlock= (get-clipboard) # .trim().replace("'",'').replace('"','') ;
        if($ScriptBlock){
            write-verbose "No -ScriptBlock specified, detected text on clipboard:`n$($ScriptBlock)" ;
            $fromCB = $true ;
        } else {
            write-warning "No -path specified, nothing suitable found on clipboard. EXITING!" ;
            Break ;
        } ;
    } else {
        write-verbose "ScriptBlock:$($ScriptBlock)" ;
    } ;
    # issue specific to PS, -replace isn't literal, see's $ as variable etc control char
    # rgx replace to prefix all special chars, to make them literals, before doing any text -replace (graveaccent escape ea)
    #$ScriptBlock = $scriptblock -replace '([$*\~;(%?.:@/]+)','`$1' ;
    # use wrapper function for the above
    $ScriptBlock=convertTo-EscapedPSText -ScriptBlock $ScriptBlock -Verbose:($PSBoundParameters['Verbose'] -eq $true) ; 
    
    if($wrap -OR ($ScriptBlock |  measure).count -eq 1){
        write-verbose "(-wrap: wrapping code at semicolons)" ; 
        #  code that wraps ;-delim'd code to prefixable lines
        # functional AHK: StringReplace clipboard, clipboard, `;, `;`r`n, All
        $splitAt = ";" ; 
        $replaceWith = ";$([Environment]::NewLine)" ; 
        # ";`r`n"  ; 
        $ScriptBlock = $ScriptBlock | Foreach-Object {
                $_ -replace $splitAt, $replaceWith ;
        } ; 
    } ;
    
    if($scriptblock -isnot  [array]){
        write-verbose "(`$ScriptBlock non-Array, splitting on NewLines)" ; 
        # split into lines - looks like a wrapped block, but it's one line with crlfs - need each to loop and append prefixes
        #$ScriptBlock = $ScriptBlock.Split([Environment]::NewLine)
        #$ScriptBlock = $ScriptBlock.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ; 
        $ScriptBlock = $ScriptBlock.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) ;
    } ; 

    
    if($nopad){
        [array]$CBH = "$($sCBHKeyword)"
    } else {
        [array]$CBH = "$($sCBHKeyword)`n"
    } ; 
    $ScriptBlock = $ScriptBlock | Foreach-Object {
        if($nopad){
            $CBH += "$($sCBHPrompt) $($_)" ;
        } else {
            $CBH += "$($sCBHPrompt) $($_)`n" ;
        } ; 
    } ; 
    $CBH += "SAMPLEOUTPUT" ; 
    $CBH += "DESCRIPTION" ; 
    
    # reverse escapes - have to use dbl-quotes around escaped backtick (dbld), or it doesn't become a literal
    #$ScriptBlock = $scriptblock -replace "``([$*\~;(%?.:@/]+)",'$1'; 
    # wrapper function
    $CBH=convertFrom-EscapedPSText -ScriptBlock $CBH -Verbose:($PSBoundParameters['Verbose'] -eq $true) ;  
    if($fromCB){
        write-host "(sending results back to clipboard)" ;
        #$CBH | out-clipboard ; 
        set-clipboard -value $CBH ;
    } else { ; 
        # or to pipeline
        write-verbose "(sending results to pipeline)" ;
        $CBH | write-output ; 
    } ; 
} ; #*------^ END Function convertTo-PSHelpExample ^------
