# verb-Text.psm1

  <#
  .SYNOPSIS
  verb-Text - Generic text-related functions
  .NOTES
  Version     : 1.0.1.0
  Author      : Todd Kadrie
  Website     :	https://www.toddomation.com
  Twitter     :	@tostka
  CreatedDate : 4/8/2020
  FileName    : verb-Text.psm1
  License     : MIT
  Copyright   : (c) 4/8/2020 Todd Kadrie
  Github      : https://github.com/tostka
  REVISIONS
  * 4/8/2020 - 1.0.0.0 modularized
  # 11:15 AM 4/3/2020 initial version: added: Remove-StringDiacritic, Remove-StringLatinCharacters
  .DESCRIPTION
  verb-Text - Generic text-related functions
  .LINK
  https://github.com/tostka/verb-Text
  #>


$script:ModuleRoot = $PSScriptRoot ; 
$script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ; 



#*------v Remove-StringDiacritic.ps1 v------
function Remove-StringDiacritic {
    <#
    .SYNOPSIS
    Remove-StringDiacritic() - This function will remove the diacritics (accents) characters from a string.unaccented characters.
    .NOTES
    Version     : 1.0.1
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
    * Mar 22, 2019, init
    .DESCRIPTION
    Remove-StringDiacritic() - This function will remove the diacritics (accents) characters from a string.unaccented characters.
    .PARAMETER String ;
    Specifies the String(s) on which the diacritics need to be removed ;
    .PARAMETER NormalizationForm ;
    Specifies the normalization form to use ;
    https://msdn.microsoft.com/en-us/library/system.text.normalizationform(v=vs.110).aspx
    .EXAMPLE
    PS C:\> Remove-StringDiacritic "L'�t� de Rapha�l" ;
    L'ete de Raphael ;
    .LINK
    https://lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html
    #>
    [CMdletBinding()]
    PARAM ([ValidateNotNullOrEmpty()][Alias('Text')]
      [System.String[]]$String,
      [System.Text.NormalizationForm]$NormalizationForm = "FormD"
    ) ;
    FOREACH ($StringValue in $String) {
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
}

#*------^ Remove-StringDiacritic.ps1 ^------

#*------v Remove-StringLatinCharacters.ps1 v------
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
    REVISIONS
    REVISIONS   :
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
    PARAM ([ValidateNotNullOrEmpty()][Alias('Text')]
      [string]$String
    ) ;
    [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String)) ;
}

#*------^ Remove-StringLatinCharacters.ps1 ^------

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function Remove-StringDiacritic,Remove-StringLatinCharacters -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULU9cc/UX8Kde17EBPRY1AY5B
# tJ2gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSzvrs+
# ZjbeaDffJb9tgesuoKLokzANBgkqhkiG9w0BAQEFAASBgAqvUTrclvRt+9uCKyoI
# cyM8HDE63oQqthJpxH5j+iw1sD/g4SrPNFYTZrWfkQLfHLDTu5ZHFW6WSXVS9E8S
# Y5fUvRbRkDUHW9TOhfeE2iNTMjVZGlTJyxqPrvot7scXck/y7WR+6jT97/81xjkK
# 7zHxa8Yg7PmoGoQdfZ5woUt/
# SIG # End signature block
