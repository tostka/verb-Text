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
    * 1:53 PM 11/22/2021 added param pipeline support
    * May 21, 2015 posted version
    .DESCRIPTION
    Remove-StringLatinCharacters() - Substitute Cyrillic characters into normal unaccented characters. Addon to Remove-Stringdiacriic, converts untouched Polish crossed-L to L. But doesn't proper change some german chars (rplcs german est-set with ? -> do Remove-StringDiacritic first, and it won't damage german).
    .PARAMETER String ;
    Specifies the String(s) on which the latin chars need to be removed ;
    .EXAMPLE
    Remove-StringLatinCharacters -string "string" ;
    Substitute norma unaccented chars for cyrillic chars in the string specified
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
