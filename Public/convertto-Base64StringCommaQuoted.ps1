#*------v Function convertto-Base64StringCommaQuoted v------
function convertto-Base64StringCommaQuoted{
    <#
    .SYNOPSIS
    convertto-Base64StringCommaQuoted - Converts an array of Base64 strings, then into a comma-quoted delimited string, and outputs the result to the clipboard
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
    * 10:29 AM 9/26/2023 fix trailing ] typo on #33; added -outObject, and set verbose to dump the ouptut to pipeline (verifying it works if cb access issues); add: 'string' as param alias for str
    * 11:02 AM 9/5/2023 added proc-loop try-catch: wasn't echo'ing anything, just throw everything out.
    * 5:27 PM 11/18/2022 init
    .DESCRIPTION
    convertto-Base64StringCommaQuoted - Converts an array of strings Base64 string, then into a comma-quoted delimited string, and outputs the result to the clipboard
    .PARAMETER String
    Array of strings to be converted
    .PARAMETER outObject
    Switch that returns results to pipeline
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()] 
    PARAM(
		[Parameter(ValueFromPipeline=$true, HelpMessage='Array of strings to be converted')]
			[Alias('String')]
			[string[]]$str,
		[Parameter(HelpMessage='Switch that returns results to pipeline')]
			[switch]$outObject
	) ;
    BEGIN{$outs = @()}
    PROCESS{
		[array]$outs += $str | foreach-object{
			TRY{
				[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($_)) ; 
			} CATCH {
				$ErrTrapd=$Error[0] ;
				$smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
				if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
				else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
				CONTINUE
			} ; 
        } ; 
    } ; 
    END {
		$ret = '"' + $(($outs) -join '","') + '"' | out-string  ; 
		if($ret){
			$ret | set-clipboard 
			if($outObject -OR ($VerbosePreference -eq "Continue")){$ret | write-output} 
		} else {
			write-verbose "No output" ; 
			if($outObject -OR ($VerbosePreference -eq "Continue")){$false | write-output} 
		} ;  ; 
	} ; 
} ;
#*------^ END Function convertto-Base64StringCommaQuoted ^------
