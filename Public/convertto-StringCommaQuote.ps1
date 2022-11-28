#*------v Function convertto-StringCommaQuote v------
function convertto-StringCommaQuote{
    <#
    .SYNOPSIS
    convertto-StringCommaQuote - Converts an array of strings into a comma-quoted delimited string
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-11-18
    FileName    : convertto-StringCommaQuote
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text,csv
    REVISIONS
    * 5:27 PM 11/18/2022 init
    .DESCRIPTION
    convertto-StringCommaQuote - Converts an array of strings into a comma-quoted delimited string
    .PARAMETER String
    Array of strings to be comma-quote delimited
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()] PARAM([Parameter(ValueFromPipeline=$true)][string[]]$String) ;
    BEGIN{$outs = @()} 
    PROCESS{[array]$outs += $String | foreach-object{$_} ; } 
    END {'"' + $(($outs) -join '","') + '"' | out-string } ; 
} ;
#*------^ END Function convertto-StringCommaQuote ^------
