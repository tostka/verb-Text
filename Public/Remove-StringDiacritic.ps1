#*------v Function Remove-StringDiacritic v------
function Remove-StringDiacritic {
    <#
    .SYNOPSIS
    Remove-StringDiacritic() - This function will remove the diacritics (accents) characters from a string.unaccented characters.
    .NOTES
    Version     : 1.0.0
    Author      : Francois-Xavier Cat
    Website     :	github.com/lazywinadmin, www.lazywinadmin.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-3-22
    FileName    : Remove-StringDiacritic.ps1
    License     : (none-specified)
    Copyright   : (none-specified)
    Github      : https://github.com/tostka
    Tags        : Powershell,Text,String,ForeignLanguage,Language
    REVISIONS
    * 3:42 PM 9/23/2024 added regex pretest example
    * 10:54 AM 1/17/2023 # psv2 bug: $psitem isn't supported, need to use $_
    * 1:50 PM 11/22/2021 added param pipeline support & hepmessage on params
    * Mar 22, 2019, init
    .DESCRIPTION
    Remove-StringDiacritic() - This function will remove the diacritics (accents) characters from a string.unaccented characters.
    
    Note verb-text\converTo-CleanString() wraps this and Remove-StringLatinCharacters (pipeline passthrough)
    .PARAMETER String ;
    Specifies the String(s) on which the diacritics need to be removed ;
    .PARAMETER NormalizationForm ;
    Specifies the normalization form to use ;
    https://msdn.microsoft.com/en-us/library/system.text.normalizationform(v=vs.110).aspx
    .EXAMPLE
    PS C:\> Remove-StringDiacritic "L'�t� de Rapha�l" ;
    L'ete de Raphael ;
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
    #>
    [CMdletBinding()]
    PARAM (
      [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true, HelpMessage = 'Specifies the String(s) on which the diacritics need to be removed')]
      [ValidateNotNullOrEmpty()][Alias('Text')]
      [System.String[]]$String,
      [Parameter(HelpMessage = 'optional the normalization form to use (defaults to FormD)')]
      [System.Text.NormalizationForm]$NormalizationForm = "FormD"
    ) ;
    foreach ($StringValue in $String) {
        Write-Verbose -Message "$StringValue"
        try {
            # Normalize the String
            $Normalized = $StringValue.Normalize($NormalizationForm) ;
            $NewString = New-Object -TypeName System.Text.StringBuilder
            # Convert the String to CharArray
            $normalized.ToCharArray() |
            ForEach-Object -Process {
                if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                    [void]$NewString.Append($_) ;
                } ;
            } ;
            #Combine the new string chars
            Write-Output $($NewString -as [string]) ;
        } Catch {
            Write-Error -Message $Error[0].Exception.Message
        } ;
    } ;
} ; 
#*------^ END Function Remove-StringDiacritic ^------
