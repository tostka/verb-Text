#*------v Function ConvertTo-CleanString v------
function ConvertTo-CleanString {
    <#
    .SYNOPSIS
    ConvertTo-CleanString() - Wrapper function for verb-text\Remove-StringDiacritic() & verb-text\Remove-StringLatinCharacters(): Replaces diacritics (accents) characters and Latin (Polish crossed-L) chars with plain text equivs (Pipelines string through both funcs, in series)
    .NOTES
    Version     : 1.0.0
	Author      : Todd Kadrie
	Website     : http://www.toddomation.com
	Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2019-3-22
    FileName    : ConvertTo-CleanString.ps1
License     : MIT License
Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text,String,ForeignLanguage,Language
    REVISIONS
    * 9:06 AM 9/23/2024 init
    .DESCRIPTION
    ConvertTo-CleanString() - Wrapper function for verb-text\Remove-StringDiacritic() & verb-text\Remove-StringLatinCharacters(): Replaces diacritics (accents) characters and Latin (Polish crossed-L) chars with plain text equivs (Pipelines string through both funcs, in series)
    .PARAMETER String ;
    Specifies the String(s) on which the diacritics or latin/characters need to be removed ;
    .EXAMPLE
	PS> $clean = ConvertTo-CleanString -String "Helen Bräuchlę"  ;
	PS> write-host "'$($clean)'" ;

		'Helen Brauchle'
	.EXAMPLE
	write-verbose "Note: Clipboard tends to paste latin cyrillics as western charcters (removes diacritical from 'ę', pastes as 'e'), so pull from clipboard into a variable for processing, to ensure we're converting the raw latin characters with the functions" ;
	PS> $in = get-clipboard ;
	PS> write-host "'$($in)'" ;
	PS> [regex]$rgxAccentedNameChars = "[^a-zA-Z0-9\s\.\(\)\{\}\/\&\$\#\@\,\`"\'\’\:\–_-]" ; 
	PS> if($in -match $rgxAccentedNameChars){
	PS> 	$clean = $in |ConvertTo-CleanString ;
	PS> 	write-host "'$($clean)'" ;
	PS> } else {write-host "already clean raw text:$(in)" } ; 
	Demo pipeline conversion, sourced from clipboard (rather than pasted text string), avoids autoconversion performed on paste to console, by Powershell.
    .LINK
    https://lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CMdletBinding()]
    PARAM (
      [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true, HelpMessage = 'Specifies the String(s) on which the diacritics need to be removed')]
		  [ValidateNotNullOrEmpty()][Alias('Text')]
		  [System.String[]]$String
    ) ;
    foreach ($StringValue in $String) {
        Write-Verbose -Message "$StringValue"
        TRY {
            # pipe stringvalue through Remove-StringDiacritic & Remove-StringLatinCharacters (Cyrillic)
            $StringValue |Remove-StringDiacritic -Verbose:($PSBoundParameters['Verbose'] -eq $true) |Remove-StringLatinCharacters -Verbose:($PSBoundParameters['Verbose'] -eq $true)
            #Write-Output $($NewString -as [string]) ;
        } CATCH {
			$ErrTrapd=$Error[0] ;
			$smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
			if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
			else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
		} ; 
    } ;
} ; 
#*------^ END Function ConvertTo-CleanString ^------
