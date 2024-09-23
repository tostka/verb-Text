function Remove-StringLatinCharacters {
<#
    .SYNOPSIS
    Remove-StringLatinCharacters() - Substitute Cyrillic characters into normal unaccented characters. Addon to Remove-Stringdiacriic, converts untouched Polish crossed-L to L. But doesn't proper change some german chars (rplcs german est-set with ? -> do Remove-StringDiacritic first, and it won't damage german).
   .NOTES
    Version     : 1.0.1
    Author: Marcin Krzanowicz
    Website:	https://lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html#
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-3-22
    FileName    : Remove-StringDiacritic.ps1
    License     : (none-specified)
    Copyright   : (none-specified)
    Github      : https://github.com/tostka
    Tags        : Powershell,Text,String,ForeignLanguage,Language
    REVISIONS   :
    * 3:42 PM 9/23/2024 added regex pretest example
    * 1:53 PM 11/22/2021 added param pipeline support
    * May 21, 2015 posted version
    .DESCRIPTION
    Remove-StringLatinCharacters() - Substitute Cyrillic characters into normal unaccented characters. Addon to Remove-Stringdiacriic, converts untouched Polish crossed-L to L. But doesn't proper change some german chars (rplcs german est-set with ? -> do Remove-StringDiacritic first, and it won't damage german).
    
    Note verb-text\converTo-CleanString() wraps this and Remove-StringDiacritic (pipeline passthrough)
    .PARAMETER String ;
    Specifies the String(s) on which the latin chars need to be removed ;
    .EXAMPLE
    Remove-StringLatinCharacters -string "string" ;
    Substitute normal unaccented chars for cyrillic chars in the string specified
    .EXAMPLE
    write-verbose "Note: Clipboard tends to paste latin cyrillics as western charcters (removes diacritical from 'ę', pastes as 'e'), so pull from clipboard into a variable for processing, to ensure we're converting the raw latin characters with the functions" ;
    PS> $in = get-clipboard ;
    PS> write-host "'$($in)'" ;
    PS> [regex]$rgxAccentedNameChars = "[^a-zA-Z0-9\s\.\(\)\{\}\/\&\$\#\@\,\`"\'\’\:\–_-]" ; 
    PS> if($in -match $rgxAccentedNameChars){
    PS> 	$clean = $in | Remove-StringLatinCharacters ;
    PS> 	write-host "'$($clean)'" ;
    PS> } else {write-host "already clean raw text:$(in)" } ; 
    Demo pipeline conversion, sourced from clipboard (rather than pasted text string), avoids autoconversion performed on paste to console, by Powershell.
    .LINK
    https://lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html
    #>
    [CMdletBinding()]
    PARAM (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true, HelpMessage = 'Specifies the String(s) on which the latin chars need to be removed ')]
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String[]]$String
    ) ;
    [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String)) ;
}
