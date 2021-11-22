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
    * 1:50 PM 11/22/2021 added param pipeline support & hepmessage on params
    * Mar 22, 2019, init
    .DESCRIPTION
    Remove-StringDiacritic() - This function will remove the diacritics (accents) characters from a string.unaccented characters.
    .PARAMETER String ;
    Specifies the String(s) on which the diacritics need to be removed ;
    .PARAMETER NormalizationForm ;
    Specifies the normalization form to use ;
    https://msdn.microsoft.com/en-us/library/system.text.normalizationform(v=vs.110).aspx
    .EXAMPLE
    PS C:\> Remove-StringDiacritic "L'été de Raphaël" ;
    L'ete de Raphael ;
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
                if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
                    [void]$NewString.Append($psitem) ;
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
