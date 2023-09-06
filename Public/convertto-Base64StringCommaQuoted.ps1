#*------v Function convertto-Base64StringCommaQuoted v------
function convertto-Base64StringCommaQuoted{
    <#
    .SYNOPSIS
    convertto-Base64StringCommaQuoted - Converts an array of strings Base64 string, then into a comma-quoted delimited string, and outputs the result to the clipboard
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-11-18
    FileName    : convertto-Base64StringCommaQuoted
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text,csv
    REVISIONS
    * 11:02 AM 9/5/2023 added proc-loop try-catch: wasn't echo'ing anything, just throw everything out.
    * 5:27 PM 11/18/2022 init
    .DESCRIPTION
    convertto-Base64StringCommaQuoted - Converts an array of strings Base64 string, then into a comma-quoted delimited string, and outputs the result to the clipboard
    .PARAMETER String
    Array of strings to be converted
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()] 
    PARAM([Parameter(ValueFromPipeline=$true)][string[]]$str) ;
    BEGIN{$outs = @()}
    PROCESS{[array]$outs += $str | foreach-object{
        TRY{
            [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($_))} ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            CONTINUE
        } ; 
    }
    END {'"' + $(($outs) -join '","') + '"' | out-string | set-clipboard } ; 
} ;
#*------^ END Function convertto-Base64StringCommaQuoted ^------
