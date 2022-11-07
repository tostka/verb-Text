#*------v Function convertTo-QuotedList v------
Function convertTo-QuotedList {
    <#
    .SYNOPSIS
    Quote-List.ps1 - wrap list with quotes
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Quote-List.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 1:16 PM 11/22/2021 added presplit to lines; upgraded to adv function; ren'd quote-list -> convertTo-QuotedList ; made actually functional (wasn't, was a half-finished copy of quote-text)
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    convertTo-QuotedList.ps1 - wrap list with quotes
    .LINK
    #>
    [CmdletBinding()]
    [Alias('quote-list')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be quote-wrapped[-PARAM SAMPLEINPUT]")]
        [string]$List
    ) ;
    write-verbose "lines:`n$($lines)" ;
    if( ($List.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) | measure).count -gt 1){
        write-verbose "(splitting multi-line block into array of lines)" ;
        $List = $List.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) ;  
    } ; 
    $List |foreach-object {
         "`"$($PSItem)`""  ; 
    } ; 
} ; #*------^ END Function convertTo-QuotedList ^------
