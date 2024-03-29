﻿#*------v Function convertTo-PSHelpExample v------
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
    * 1:36 PM 4/5/2023 suddenly set-clipboard -value breaks, param now shows as -Text: retooled splits, remove blank lines, coerce array and then coerse to text before writing to set-clipboard -text
    * 11:52 AM 9/8/2022 fix: #106 was writing codeblock with `n EOL, which resulted in [LF], instead of "proper" Win [CR][LF]. Pester complains, so updated to wright `n`r as EOL instead
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

    # we need split lines to prefix with PS> (and no blank lines)
    if(($ScriptBlock |  measure).count -eq 1){
        [array]$ScriptBlock = $ScriptBlock.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
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
    
    # ensure we have an array of separate lines to prefix - no empties
    if($scriptblock -isnot  [array] -OR (($ScriptBlock |  measure).count -eq 1)){
        write-verbose "(`$ScriptBlock non-Array, splitting on NewLines)" ; 
        # split into lines - looks like a wrapped block, but it's one line with crlfs - need each to loop and append prefixes, so split it out
        #[array]$ScriptBlock = $ScriptBlock.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) ;
        # above results in PS> [blank], drop the empties
        [array]$ScriptBlock = $ScriptBlock.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
    } ; 
    
    # coercing every assign into array, and typing the aggreg
    if($nopad){
        [array]$CBH = @("$($sCBHKeyword)")
    } else {
        [array]$CBH = @("$($sCBHKeyword)`n")
    } ; 
    $ScriptBlock = @(
        $ScriptBlock | Foreach-Object {
            if($nopad){
                @($CBH += "$($sCBHPrompt) $($_)") 
            } else {
                #$CBH += "$($sCBHPrompt) $($_)`n" ;
                # above was creating examples with EOL [LF] vs [CR][LF], use both (Pester no-likey)
                @($CBH += "$($sCBHPrompt) $($_)`r`n" )
            }  
        } ; 
    ) ; 
    $CBH += @("SAMPLEOUTPUT") ; 
    $CBH += @("DESCRIPTION") ; 

    # reverse escapes - have to use dbl-quotes around escaped backtick (dbld), or it doesn't become a literal
    #$ScriptBlock = $scriptblock -replace "``([$*\~;(%?.:@/]+)",'$1'; 
    # wrapper function: 
    $CBH=convertFrom-EscapedPSText -ScriptBlock $CBH -verbose:$($VerbosePreference -eq "Continue") ;  ;  
    if($fromCB){
        write-host "(sending results back to clipboard)" ;
        #$CBH | out-clipboard ; 
        # 4/5/2023: suddenly set-clipboard -value breaks, param now shows as -Text [facepalm]
        <# -Files <FileSystemInfo[]>,-Html <String>,-Image <Image>,-Rtf <String>,-Text <String> #>
        # try default positional # nope, param error
        #set-clipboard $CBH ;
        # coerce system.array to string and use -text
        set-clipboard -text ($cbh | out-string) ; 
    } else { ; 
        # or to pipeline
        write-verbose "(sending results to pipeline)" ;
        $CBH | write-output ; 
    } ; 
} ; #*------^ END Function convertTo-PSHelpExample ^------
