﻿# verb-text.psm1


  <#
  .SYNOPSIS
  verb-Text - Generic text-related functions
  .NOTES
  Version     : 1.0.13.0
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

#*======v FUNCTIONS v======



#*------v convert-CaesarCipher.ps1 v------
function convert-CaesarCipher {
    <#
    .SYNOPSIS
    convert-CaesarCipher - Converts passed string to/from Caesar cipher, using a passed integer Key [1-25]
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convert-CaesarCipher.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-text
    AddedCredit : M. McNabb
    AddedWebsite:	https://rosettacode.org/wiki/Caesar_cipher#PowerShell
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convert-CaesarCipher:init
    .DESCRIPTION
    convert-CaesarCipher - Converts passed string to/from Rot13 
    This cipher rotates (either towards left or right) the letters of the alphabet (A to Z).
The encoding replaces each letter with the 1st to 25th next letter in the alphabet (wrapping Z to A).
So key 2 encrypts "HI" to "JK", but key 20 encrypts "HI" to "BC".
This simple "mono-alphabetic substitution cipher" provides almost no security, because an attacker who has the encoded message can either use frequency analysis to guess the key, or just try all 25 keys.
Caesar cipher is identical to Vigen�re cipher with a key of length 1.
Also, Rot-13 is identical to Caesar cipher with key 13. 
    .PARAMETER  path
    String to be converted[-string 'SAMPLEINPUT']
    .PARAMETER  key
Integer 'key' [1-25] to be used to encode[-key 2]
    .EXAMPLE
    convert-CaesarCipher -string 'YOU can convert a string to title case (every word start with a capital letter).' -key 13 ; 
    Encode a string.
    .EXAMPLE
    convert-CaesarCipher -string 'LBH pna pbaireg n fgevat gb gvgyr pnfr (rirel jbeq fgneg jvgu n pncvgny yrggre).' -decode -key 13
    Decode a string (actually, as we're using a 13 key, decrypting Rot13)
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://rosettacode.org/wiki/Caesar_cipher#PowerShell    
    #>
    ##[Alias('convertTo-ProperCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(Position=1,Mandatory=$false,HelpMessage="Integer 'key' [1-25] to be used to encode[-key 2]")]
        [String]$key,
        [Parameter(Position=1,Mandatory=$false,HelpMessage="Switch to trigger decode function (vs default encode)[-decode]")]
        [switch]$Decode
    ) ;
    BEGIN {
        $LowerAlpha = [char]'a'..[char]'z'
        $UpperAlpha = [char]'A'..[char]'Z'
    }
    PROCESS {
        $Chars = $string.ToCharArray() ; 
        
        #*------v Function _encode v------
        function _encode{
            param(
              $Char,
              $Alpha = [char]'a'..[char]'z'
            ) ; 
            $Index = $Alpha.IndexOf([int]$Char) ; 
            $NewIndex = ($Index + $Key) - $Alpha.Length ; 
            $Alpha[$NewIndex] ; 
        } ; #*------^ END Function _encode ^------
        #*------v Function _decode v------
        function _decode {
            param(
              $Char,
              $Alpha = [char]'a'..[char]'z'
            ) 
            $Index = $Alpha.IndexOf([int]$Char) ;
            $int = $Index - $Key ; 
            if ($int -lt 0) {$NewIndex = $int + $Alpha.Length}
            else {$NewIndex = $int} ; 
            $Alpha[$NewIndex] ; 
        } ; #*------^ END Function _decode ^------
        
        foreach ($Char in $Chars){
            if ([int]$Char -in $LowerAlpha){
                if ($decode) {$Char = _decode $Char}
                else {$Char = _encode $Char} ; 
            } elseif ([int]$Char -in $UpperAlpha){ ; 
                if ($Decode) {$Char = _decode $Char $UpperAlpha}
                else {$Char = _encode $Char $UpperAlpha}
            } ; 
            $Char = [char]$Char ; 
            [string]$OutText += $Char ; 
        } ; 
        $OutText | write-output ; 
        $OutText = $null ; 
    } # if-E-PROCESS
}

#*------^ convert-CaesarCipher.ps1 ^------

#*------v convertFrom-Base64String.ps1 v------
function convertFrom-Base64String {
    <#
    .SYNOPSIS
    convertFrom-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-30
    FileName    : convertFrom-Base64String.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 8:26 AM 12/13/2019 convertFrom-Base64String:init
    .DESCRIPTION
    convertFrom-Base64String - Convert specified string from Base64 encoded string back to text and return to pipeline
    .PARAMETER  path
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    convertFrom-Base64String.ps1 -string 'xxxxx' ; 
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    if($File){
        $String = (get-content $path -encoding byte) ; 
    } 
    # [convert]::ToBase64String((get-content $path -encoding byte)) | write-output ; 
    #[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) | write-output ; 
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string))| write-output ;     
}

#*------^ convertFrom-Base64String.ps1 ^------

#*------v convertFrom-Html.ps1 v------
function convertFrom-Html {
    <#
    .SYNOPSIS
    convertFrom-Html - Convert specified text html to plain text (replace html tags & entities) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-05-14
    FileName    : convertFrom-Html.ps1
    License     : (non-asserted)
    Copyright   : 
    Github      : https://github.com/tostka
    AddedCredit : Winston Fassett
    AddedWebsite:	http://winstonfassett.com/blog/author/Winston/
    REVISIONS
    * 3:11 PM 5/14/2021 convertFrom-Html:init, added $file spec
    .DESCRIPTION
    convertFrom-Html - Convert specified text html to plain text (replace html tags & entities) and return to pipeline
    Minimal port of Winston Fassett's html-ToText()
    .PARAMETER  string
    File to be Base64 encoded (image, text, whatever)[-string path-to-file]
    .EXAMPLE
    convertFrom-Html.ps1 -string 'xxxxx' ; 
    .LINK
    http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/
    .LINK
    https://github.com/tostka/verb-text
    #>
    <# #-=-=-=MUTUALLY EXCLUSIVE PARAMS OPTIONS:-=-=-=-=-=
# designate a default paramset, up in cmdletbinding line
[CmdletBinding(DefaultParameterSetName='SETNAME')]
  # * set blank, if none of the sets are to be forced (eg optional mut-excl params)
  # * force exclusion by setting ParameterSetName to a diff value per exclusive param

# example:single $Computername param with *multiple* ParameterSetName's, and varying Mandatory status per set
    [Parameter(ParameterSetName='LocalOnly', Mandatory=$false)]
    $LocalAction,
    [Parameter(ParameterSetName='Credential', Mandatory=$true)]
    [Parameter(ParameterSetName='NonCredential', Mandatory=$false)]
    $ComputerName,
    # $Credential as tied exclusive parameter
    [Parameter(ParameterSetName='Credential', Mandatory=$false)]
    $Credential ;    
    # effect: 
    -computername is mandetory when credential is in use
    -when $localAction param (w localOnly set) is in use, neither $Computername or $Credential is permitted
    write-verbose -verbose:$verbose "ParameterSetName:$($PSCmdlet.ParameterSetName)"
#-=-=-=-=-=-=-=-=
#>
    [CmdletBinding(DefaultParameterSetName='fromstring')]
    PARAM(
        [Parameter(ParameterSetName='fromstring',Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted from html to plain text[-string '<b>text</b>']")]
        [System.String]$string,
        [Parameter(ParameterSetName='fromfile',HelpMessage="File to be converted from HTML to Text (and returned to pipeline)[-PARAM SAMPLEINPUT]")]
        [ValidateScript({Test-Path $_})]
        [string]$File
    ) ;
    if($File){
        $String = (get-content $file -encoding byte) ; 
    } ;
    
    # remove line breaks, replace with spaces
    $string = $string -replace "(`r|`n|`t)", " "
    # write-verbose "removed line breaks: `n`n$string`n"

    # remove invisible content
    @('head', 'style', 'script', 'object', 'embed', 'applet', 'noframes', 'noscript', 'noembed') | % {
    $string = $string -replace "<$_[^>]*?>.*?</$_>", ""
    }
    write-verbose "removed invisible blocks: `n`n$string`n"

    # Condense extra whitespace
    $string = $string -replace "( )+", " "
    write-verbose "condensed whitespace: `n`n$string`n"

    # Add line breaks
    @('div','p','blockquote','h[1-9]') | % { $string = $string -replace "</?$_[^>]*?>.*?</$_>", ("`n" + '$0' )} 
    # Add line breaks for self-closing tags
    @('div','p','blockquote','h[1-9]','br') | % { $string = $string -replace "<$_[^>]*?/>", ('$0' + "`n")} 
    write-verbose "added line breaks: `n`n$string`n"

    #strip tags 
    $string = $string -replace "<[^>]*?>", ""
    write-verbose "removed tags: `n`n$string`n"

    # replace common entities
    @( 
    @("&amp;bull;", " * "),
    @("&amp;lsaquo;", "<"),
    @("&amp;rsaquo;", ">"),
    @("&amp;(rsquo|lsquo);", "'"),
    @("&amp;(quot|ldquo|rdquo);", '"'),
    @("&amp;trade;", "(tm)"),
    @("&amp;frasl;", "/"),
    @("&amp;(quot|#34|#034|#x22);", '"'),
    @('&amp;(amp|#38|#038|#x26);', "&amp;"),
    @("&amp;(lt|#60|#060|#x3c);", "<"),
    @("&amp;(gt|#62|#062|#x3e);", ">"),
    @('&amp;(copy|#169);', "(c)"),
    @("&amp;(reg|#174);", "(r)"),
    @("&amp;nbsp;", " "),
    @("&amp;(.{2,6});", "")
    ) | foreach-object { $string = $string -replace $_[0], $_[1] }
    write-verbose "replaced entities: `n`n$string`n"

    $string | write-output ;     
}

#*------^ convertFrom-Html.ps1 ^------

#*------v Convert-invertCase.ps1 v------
function Convert-invertCase {
    <#
    .SYNOPSIS
    Convert-invertCase - Convert passed string to Invert Case (UPPER->lower ; lower->UPPER) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : Convert-invertCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 Convert-invertCase:init
    .DESCRIPTION
    Convert-invertCase - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    Convert-invertCase.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    [array]$chars = $String -split "" ; 
    $output = $null ; 
    foreach($c in $chars){
        switch -regex -CaseSensitive ($c){
            '([A-Z])'{$output += $c.tolower() }
            '([a-z])'{$output += $c.toUpper() }
            default {$output += $c }
        }
    } ;
    $output | write-output ; 
}

#*------^ Convert-invertCase.ps1 ^------

#*------v convert-Rot13.ps1 v------
function convert-Rot13 {
    <#
    .SYNOPSIS
    convert-Rot13 - Converts passed string to/from Rot13 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convert-Rot13.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : rosettacode.org
    AddedWebsite:	https://rosettacode.org/wiki/Rot-13#PowerShell
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convert-Rot13:init
    .DESCRIPTION
    convert-Rot13 - Converts passed string to/from Rot13 
    Replace every letter of the ASCII alphabet with the letter which is "rotated" 13 characters "around" the 26 letter alphabet from its normal cardinal position   (wrapping around from   z   to   a   as necessary). 
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot13.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://rosettacode.org/wiki/Rot-13#PowerShell
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    [char[]](0..64+78..90+65..77+91..96+110..122+97..109+123..255)[[char[]]$string] -join "" | write-output ; 
}

#*------^ convert-Rot13.ps1 ^------

#*------v convert-Rot47.ps1 v------
function convert-Rot47 {
    <#
    .SYNOPSIS
    convert-Rot47 - Converts passed string to/from Rot47
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convert-Rot47.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-text
    AddedCredit : ChilliTom
    AddedWebsite:	https://gist.github.com/chillitom/8335042
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convert-Rot47:init
    .DESCRIPTION
    convert-Rot47 - Converts passed string to/from Rot13 
    Replace every letter of the ASCII alphabet with the letter which is "rotated" 13 characters "around" the 26 letter alphabet from its normal cardinal position   (wrapping around from   z   to   a   as necessary). 
    .PARAMETER  path
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot47.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://gist.github.com/chillitom/8335042
    #>
    ##[Alias('convertTo-ProperCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    $table = @{} ; 
    for ($i = 0; $i -lt 94; $i++) {
        $table.Add(
            "!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~"[$i],
            "PQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO"[$i]) ; 
    } ; 
    $out = New-Object System.Text.StringBuilder ;
    $in.ToCharArray() | %{
        $char = if ($table.ContainsKey($_)) {$table[$_]} else {$_} ; 
        $out.Append($char) | Out-Null ; 
    } ; 
    $out.ToString() | write-output ; 
}

#*------^ convert-Rot47.ps1 ^------

#*------v convertTo-Base64String.ps1 v------
function convertTo-Base64String {
    <#
    .SYNOPSIS
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-12-13
    FileName    : convertTo-Base64String.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .PARAMETER  path
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    .\convertTo-Base64String.ps1 C:\Path\To\Image.png >> base64.txt ; 
    .EXAMPLE
    .\convertTo-Base64String.ps1
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(ParameterSetName='File',Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="File to be Base64 encoded (image, text, whatever)[-path path-to-file]")]
        [ValidateScript({Test-Path $_})][String]$path,
        [Parameter(ParameterSetName='String',HelpMessage="Optional string to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    if($File){
        $String = (get-content $path -encoding byte) ; 
    } 
    # [convert]::ToBase64String((get-content $path -encoding byte)) | write-output ; 
    [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) | write-output ; 
    
}

#*------^ convertTo-Base64String.ps1 ^------

#*------v ConvertTo-CamelCase.ps1 v------
function ConvertTo-CamelCase {
    <#
    .SYNOPSIS
    ConvertTo-CamelCase - Convert passed string to StudlyCaps\CrazyCaps etc (randomize uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-CamelCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-CamelCase:init
    .DESCRIPTION
    ConvertTo-CamelCase - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    CamelCase: Words are written without spaces, and the first letter of each word is capitalized. Also called Upper Camel Case or Pascal Casing.
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> ConvertTo-CamelCase.ps1 -string 'In PowerShell, the command used for string matching is of course Select-String' ; 
    .EXAMPLE
    PS> convertto-camelcase -string $string -AlphaNumeric $false 
    Converting a string, with Alphanumeric overridden (passes puncuation, high ascii chars, and other non-Alphanumeric characters).
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-PascalCase','convertTo-UpperCamelCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="boolean (defaults `$true) that strips all non-alphanumerics from the string[-string 'SAMPLEINPUT']")]
        [boolean]$AlphaNumeric=$true 
    ) ;
    # TitleCase, and strip spaces
    $txtInfo=(get-culture).TextInfo ;
    $string = "$($txtInfo.ToTitleCase($string.toLower()))".replace(' ','') 
    if($AlphaNumeric){
        $string = ($string -split "" |?{$_ -match '[a-zA-Z0-9]'}) -join '' ;
    }
    $string | write-output ; 
}

#*------^ ConvertTo-CamelCase.ps1 ^------

#*------v ConvertTo-L33t.ps1 v------
function ConvertTo-L33t {
    <#
    .SYNOPSIS
    ConvertTo-L33t - replace vowels with similar shaped numberse, and return string to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-L33t.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-L33t:init
    .DESCRIPTION
    ConvertTo-L33t - replace vowels with similar shaped numberse, and return string to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> convertto-l33t -string 'leet' 
    Convert replacing aeio with numerals, and the letter t with '7'
    .EXAMPLE
    PS> convertto-l33t -string 'leet' -vowelsonly
    Convert replacing aeio with numerals, only (no T->7 replacement)
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(HelpMessage="replace only vowels in target string[-vowelsonly]")]
        [switch]$VowelsOnly
    ) ;
    $string = $string.replace("a", "4").replace("e", "3").replace("i", "1").replace("o", "0") 
    # .replace("u", "(_)") ; 
    if(!$VowelsOnly){
            $string = $string.replace('t','7') 
    } ; 
    $string | write-output ; 
}

#*------^ ConvertTo-L33t.ps1 ^------

#*------v ConvertTo-lowerCamelCase.ps1 v------
function ConvertTo-lowerCamelCase {
    <#
    .SYNOPSIS
    ConvertTo-lowerCamelCase - Convert passed string to StudlyCaps\CrazyCaps etc (randomize uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-lowerCamelCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-lowerCamelCase:init
    .DESCRIPTION
    ConvertTo-lowerCamelCase - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    lowerCamelCase: Words are written without spaces, and the first letter of each word is capitalized, with the *exception* of the first letter, which is lowercase.
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> convertto-lowercamelcase -string 'i phone apple'
    .EXAMPLE
    PS> ConvertTo-lowerCamelCase -string $string -AlphaNumeric $false 
    Converting a string, with Alphanumeric overridden (passes puncuation, high ascii chars, and other non-Alphanumeric characters).
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-PascalCase','convertTo-UpperCamelCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="boolean (defaults `$true) that strips all non-alphanumerics from the string[-string 'SAMPLEINPUT']")]
        [boolean]$AlphaNumeric=$true 
    ) ;
    # TitleCase, strip spaces, and lcase the first character of the string
    $txtInfo=(get-culture).TextInfo ;
    $string = "$($txtInfo.ToTitleCase($string.toLower()))".replace(' ','') 
    if($AlphaNumeric){
        $string = ($string -split "" |?{$_ -match '[a-zA-Z0-9]'}) -join '' ;
    }
    $string.substring(0,1).tolower()+$string.substring(1) | write-output ; 
}

#*------^ ConvertTo-lowerCamelCase.ps1 ^------

#*------v ConvertTo-SCase.ps1 v------
function ConvertTo-SCase {
    <#
    .SYNOPSIS
    ConvertTo-SCase - Convert passed string to SentanceCase and return to pipeline (simplistic)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-SCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-SCase:init
    .DESCRIPTION
    ConvertTo-SCase - Convert passed string to SentanceCase and return to pipeline (simplistic)
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    ConvertTo-SCase.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-SentanceCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    # SentanceCase : capitalize first word, rest lcase (simplistic)
    ($string.substring(0,1).toupper())+($string.substring(1).tolower()) | write-output ; 
}

#*------^ ConvertTo-SCase.ps1 ^------

#*------v ConvertTo-SNAKE_CASE.ps1 v------
function ConvertTo-SNAKE_CASE {
    <#
    .SYNOPSIS
    ConvertTo-SNAKE_CASE - Convert passed string to StudlyCaps\CrazyCaps etc (randomize uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : ConvertTo-SNAKE_CASE.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 ConvertTo-SNAKE_CASE:init
    .DESCRIPTION
    ConvertTo-SNAKE_CASE - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    lowerCamelCase: Words are written without spaces, and the first letter of each word is capitalized, with the *exception* of the first letter, which is lowercase.
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    PS> ConvertTo-SNAKE_CASE -string 'i phone apple'
    .EXAMPLE
    PS> ConvertTo-SNAKE_CASE -string $string -AlphaNumeric $false 
    Converting a string, with Alphanumeric overridden (passes puncuation, high ascii chars, and other non-Alphanumeric characters).
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-PascalCase','convertTo-UpperCamelCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(HelpMessage="boolean (defaults `$true) that strips all non-alphanumerics from the string[-string 'SAMPLEINPUT']")]
        [boolean]$AlphaNumeric=$true, 
        [Parameter(HelpMessage="switch that outputs resulting string in lowercase (vs default UPPER_CASE)[-useLower 'SAMPLEINPUT']")]
        [switch]$useLower
    ) ;
    if($useLower){
        $string = $string.toLower().replace(' ','_')  ; 
    } else { 
        $string = $string.toUpper().replace(' ','_')  ; 
    } ; 
    if($AlphaNumeric){
        $string = ($string -split "" |?{$_ -match '[a-zA-Z0-9_]'}) -join '' ;
    }
    $string | write-output ; 
}

#*------^ ConvertTo-SNAKE_CASE.ps1 ^------

#*------v convertTo-StringReverse.ps1 v------
function convertTo-StringReverse {
    <#
    .SYNOPSIS
    convertTo-StringReverse - Reverse character order of passed string & return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-StringReverse.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convertTo-StringReverse:init
    .DESCRIPTION
    convertTo-StringReverse - Reverse character order of passed string & return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-StringReverse.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    $string = $string.ToCharArray() ; 
    [Array]::Reverse($string) ;
    -join $string | write-output ; 
}

#*------^ convertTo-StringReverse.ps1 ^------

#*------v ConvertTo-StudlyCaps.ps1 v------
function convertTo-StudlyCaps {
    <#
    .SYNOPSIS
    convertTo-StudlyCaps - Convert passed string to StudlyCaps\CrazyCaps etc (random uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-StudlyCaps.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 convertTo-StudlyCaps:init
    .DESCRIPTION
    convertTo-StudlyCaps - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-StudlyCaps.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-StudlyCase','convertTo-CrAzYCaPS')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    [array]$chars = $String -split "" ; 
    [string]$output = $null ; 
    foreach($c in $chars){
        switch (1,2|get-random){
            1 {$output += $c.tolower() }
            2 {$output += $c.toUpper() }
        }
    } ;
    $output | write-output ; 
}

#*------^ ConvertTo-StudlyCaps.ps1 ^------

#*------v convertTo-TitleCase.ps1 v------
function convertTo-TitleCase {
    <#
    .SYNOPSIS
    convertTo-TitleCase - Convert passed string to TitleCase and return to pipeline (simplistic)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-TitleCase.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 6:22 PM 6/18/2021 convertTo-TitleCase:init
    .DESCRIPTION
    convertTo-TitleCase - Convert passed string to TitleCase and return to pipeline (simplistic)
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-TitleCase.ps1 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-ProperCase')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    # SentanceCase : capitalize first word, rest lcase (simplistic)
    $txtInfo=(get-culture).TextInfo ;
    # Doesn�t work on all-caps (make lcase first)
    "$($txtInfo.ToTitleCase($string.toLower()))" | write-output ; 
}

#*------^ convertTo-TitleCase.ps1 ^------

#*------v create-AcronymFromCaps.ps1 v------
Function create-AcronymFromCaps {
    <#
    .SYNOPSIS
    create-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 9:34 AM 3/12/2021 added -doEXOSubstitution to auto-tag 'exo' cmds in generated acronym (part of autoaliasing hybrid cmds across both onprem & EXO); added -verbose support
    12:14 PM 2/16/2016 - working
    8:58 AM 2/16/2016 - initial version
    .DESCRIPTION
    create-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    Note:-doEXOSubstitution covers both 'exo' and 'xo' as String substrings because MS's newer ExchangeOnline v2 module arbitrarily blocks/reserves 'exo' prefix _for it's own_ new commandlets, necessitating users to retroactrively shift prior use of -commandprefix 'exo', in existing code, to another variant. In my case I routinely shift to 'xo' as prefix. 
    .PARAMETER  String
    String to be convered to a 'Capital Acrynym'[-String 'get-exoMailboxPermission]'
    .PARAMETER doEXOSubstitution
    switch to add an 'x' in output position _2_, when `$String, has 'exo' or 'xo' as a substring (used for tagging hybrid Exchange o365 cmdlets with a commandprefix)[-doEXOSubstitution]
    .INPUTS
    None
    .OUTPUTS
    System.String
    .EXAMPLE
    create-AcronymFromCaps "get-AdGroupMembersRecurseManual" ;
    Create an Capital-letter Acroynm for the specified string
    .EXAMPLE
    $fn=".\$(create-AcronymFromCaps $scriptNameNoExt)-$(get-date -uformat '%Y%m%d-%H%M').csv" ;
    Create a filename based off of an Acronym from the capital letters in the ScriptNameNoExt.
    .EXAMPLE
    $tCmdlet = 'Get-exoMailboxFolderStatistics' ; 
    $tCmdlet = (gcm $tCmdlet).Name ; 
    set-alias -name "$(create-AcronymFromCaps -string $tCmdlet -doEXOSubstitution)" -value $tCmdlet ; 
    Create an alias 'GxMFS' for the Exchange Online Get-exoMailboxFolderStatistics cmdlet (which in this case reflects an 'exo' commandprefix'd) . Example also pre-resolves the specified cmdlet name, to the default cmdlet Name capitalization scheme (for consistency)
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "String to be convered to a 'Capital Acrynym'[-String 'get-exoMailboxPermission]'")][ValidateNotNullOrEmpty()]
        [string]$String,
        [Parameter(HelpMessage="switch to add an 'x' in output position _2_, when `$String, has 'exo' or 'xo' as a substring (used for tagging hybrid Exchange o365 cmdlets with a commandprefix)[-doEXOSubstitution]")]
        [switch] $doEXOSubstitution
    ) ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    if($doEXOSubstitution){
        if($String -cmatch '((E)*)XO'){
            write-verbose "-doEXOSubstitution: Ucase 'EXO|XO' detected in `$String: .toLower()'ing the matched string, so that it only appears in output acronym as single lcase 'x', rather than full all caps '(E)XO'" 
            $String = $tcmdlet.replace($matches[0],$matches[0].tolower()) ; 
        } ; 
    } ;
    $AcroCap = $String -split "" -cmatch '([A-Z])' -join ""  ;
    if($doEXOSubstitution){
        if($String -match '((e)*)xo'){
            write-verbose "-doEXOSubstitution specified, and 'exo' substring detected: adding 'x' into 2nd position of output" ; 
            $AcroCap = "$($AcroCap.substring(0,1))x$($AcroCap.substring(1,$AcroCap.length-1))" ; 
        } ; 
    } ; 
    write-verbose "output:$($AcroCap)" ; 
    write-output $AcroCap ;
}

#*------^ create-AcronymFromCaps.ps1 ^------

#*------v get-StringHash.ps1 v------
function get-StringHash {
        <#
        .SYNOPSIS
        VERB-NOUN.ps1 - 1LINEDESC
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2020-
        FileName    : 
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka
        Tags        : Powershell
        AddedCredit : Bryan Dady
        AddedWebsite:	https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
        REVISIONS
        * 11:59 AM 4/17/2020 updated CBH, moved from incl-servercore to verb-text
        * 9:46 PM 9/1/2019 updated, added Algorithm param, added pshelp
        * 1/21/11 posted version
        .DESCRIPTION
        get-StringHash.ps1 - Convert specifed string to designated Cryptographic Hash string
        hybrid of work by Ivovan & Bryan Dady
        .PARAMETER  String
        Specify string to be hashed. Accepts from pipeline
        .PARAMETER  Algorithm
        Hashing Algorithm (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160) -Algorithm MD5
        .EXAMPLE
        $env:username | get-StringHash -Algorithm md5 ;
        .LINK
        https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
        #>
        param (
            [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Specify string to be hashed. Accepts from pipeline.')]
            [alias('text', 'InputObject')]
            [ValidateNotNullOrEmpty()]
            [string]$String,
            [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, HelpMessage = "Hashing Algorithm (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160) -Algorithm MD5")]
            [alias('HashName')]
            [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
            [string]$Algorithm = 'SHA256'
        ) ;
        $StringBuilder = New-Object -TypeName System.Text.StringBuilder ;
        [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | ForEach-Object -Process { [Void]$StringBuilder.Append($_.ToString('x2')) } ;
        #'Optimize New-Object invocation, based on Don Jones' recommendation: https://technet.microsoft.com/en-us/magazine/hh750381.aspx
        $Private:properties = @{
            'Algorithm' = $Algorithm ;
            'Hash'      = $StringBuilder.ToString()  ;
            'String'    = $String ;
        } ;
        $Private:RetObject = New-Object -TypeName PSObject -Prop $properties | Sort-Object ;
        return $RetObject  ;
    }

#*------^ get-StringHash.ps1 ^------

#*------v IsNumeric.ps1 v------
Function IsNumeric {
    <#
    .SYNOPSIS
    IsNumeric.ps1 - Test a given value is numeric
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : IsNumeric.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    IsNumeric.ps1 - Test a given value is numeric
    .PARAMETER Value
    Value to be evaluated
    .EXAMPLE
    $value="Win";IsNumeric($value);
    Test whether the string 'Win' is numeric (returns False)
    .EXAMPLE
    $value="80";IsNumeric($value);
    Test whether the string '80' is numeric (returns True)
    .LINK
    #>
    param($value)
    ($($value.Trim()) -match "^[-+]?([0-9]*\.[0-9]+|[0-9]+\.?)$") | write-output ; 
}

#*------^ IsNumeric.ps1 ^------

#*------v Quote-List.ps1 v------
Function Quote-List {
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
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    Quote-List.ps1 - wrap list with quotes
    .LINK
    #>
    $args 
}

#*------^ Quote-List.ps1 ^------

#*------v Quote-String.ps1 v------
Function Quote-String {
    <#
    .SYNOPSIS
    Quote-String.ps1 - Wrap argument with quotes
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Quote-String.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    Quote-String.ps1 - rap argument with quotes
    .LINK
    #>
    "$args" 
}

#*------^ Quote-String.ps1 ^------

#*------v Remove-StringDiacritic.ps1 v------
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

#*------v unwrap-Text.ps1 v------
Function Unwrap-Text {
    <#
    .SYNOPSIS
    Unwrap-Text
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Unwrap-Text
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS   :
    * 8:41 AM 4/12/2015, make it drop into the pipeline instead of return
    .DESCRIPTION
    Unwrap-Text
    .PARAMETER  sText
    Text to be unwrapped
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Outputs unwrapped text to pipeline
    .EXAMPLE
    get-fortune | unwrap-text | speak-words
    Get a fortune, unwrap the text, and text-to-speech the words
    .EXAMPLE
    unwrap-text $x
    .LINK
     #>
    PARAM(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'Text to be unwrapped')][string]$sText)
    BEGIN { } 
    PROCESS {
        Foreach ($sTxt in $sText) {
            $sTxt0 = $sTxt.replace("`r`n", " ");
            if (($host.version) -eq "2.0") {
                return $sTxtO;
            }
            else {
                write-output $sTxt0 ;
            } # if-block end
        } 
    }
}

#*------^ unwrap-Text.ps1 ^------

#*------v unwrap-Textn.ps1 v------
Function Unwrap-TextN {
    <#
    .SYNOPSIS
    Unwrap-TextN - Unwrap text. This variant just replaces newlines `n, without the carriage return `r
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Unwrap-Text
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS   :
    * 8:41 AM 4/12/2015, make it drop into the pipeline instead of return
    .DESCRIPTION
    Unwrap-TextN - Unwrap text. This variant just replaces newlines `n, without the carriage return `r
    .PARAMETER  sText
    Text to be unwrapped
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Outputs unwrapped text to pipeline
    .EXAMPLE
    get-fortune | unwrap-textn | speak-words
    Get a fortune, unwrap the text, and text-to-speech the words
    .EXAMPLE
    unwrap-textn $x
    .LINK
     #>
    PARAM(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'What text do you want to unwrap?')][string]$sText)
    BEGIN { }
    PROCESS {
        Foreach ($sTxt in $sText) {
            $sTxt0 = $sText.replace("`n", " ");
            if (($host.version) -eq "2.0") {
                return $sTxtO;
            }
            else {
                write-output $sTxt0 ;
            } 
        } 
    } 
}

#*------^ unwrap-Textn.ps1 ^------

#*------v WordWrap-String.ps1 v------
Function WordWrap-String {
<#
    .SYNOPSIS
    WordWrap-String - Word wrap function, return word wrapped version of passed string
    .NOTES
    Author: wolfplusplus
    Website:	http://blog.wolfplusplus.com/?p=260
    REVISIONS   :
    9:50 AM 5/1/2014 try to extend it to vari-leng or window
    9:48 AM 5/1/2014
    .DESCRIPTION
    WordWrap-String - Word wrap function, return word wrapped version of passed string
    .PARAMETER  Str
    String to be wrapped
    .PARAMETER  Wrap
    Specify either the integer character number to perform a wrap at, or specify 'WINDOW', to default the wrap char count to the width of the current window.
    .INPUTS
    None
    .OUTPUTS
    System.String
    .EXAMPLE
    write-host (WordWrap-String $logline 80)
    .LINK
    http://blog.wolfplusplus.com/?p=260
    #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "String to be wrapped[-str 'string']")][ValidateNotNullOrEmpty()]
        [string]$Str,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "character number to wrap at, or 'WINDOW' to indicate wrap should be performed at width of current window[-Wrap 'WINDOW']")][ValidateNotNullOrEmpty()]
        $Wrap
    ) ;
    if ($Wrap.ToUpper() -eq "WINDOW") {
        $Wrap = (get-host).ui.rawui.windowsize.width
    } elseif ($Wrap -is [string]) {
        write-host -fore yell ("INVALID `$Wrap param: " + $Wrap + "`n Syntax: WordWrap-String [string] [#chars]")
    }  
    $sWrapped = ""
    $curLn = ""
    # $ split string at spaces, then Loop over the words and write a line out just short $spec'd size
    foreach ($word in $str.Split(" ")) {
        # see if adding a word makes string longer then window width
        $checkLinePlusWord = $curLn + " " + $word
        if ($checkLinePlusWord.length -gt $Wrap) {
            # With the new word, over width `n before next word
            $sWrapped += [Environment]::Newline
            $curLn = ""
        }
        # Append word to current line and final str
        $curLn += $word + " "
        $sWrapped += $word + " "
    } 
    return $sWrapped
}

#*------^ WordWrap-String.ps1 ^------

#*------v wrap-Text.ps1 v------
Function wrap-Text {
    <#
    .SYNOPSIS
    wrap-Text.ps1 - Wrap a string at specified number of characters
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * added CBH
    .DESCRIPTION
    wrap-Text.ps1 - Wrap a string at specified number of characters
    .PARAMETER  sText
    Specify string to be wrapped
    .PARAMETER  nChars
    Number of characters, at which to wrap the string
    .EXAMPLE
    $text=wrap-Text -sText "Please send issues to technisbetas@gmail.com, putting them in the reviews doesn't help me find fix them" -nChars 30 ;
    .LINK
    https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
    #>
    [CmdletBinding()]
    param([string]$sText, [int]$nChars) 
    $words = $sText.split(" ");
    $sPad = "";
    $sTextO = "";
    foreach ($word in $words) {
        if (($sPad + " " + $word).length -gt $nChars) {
            $sTextO = $sTextO + $sPad + "`n"  ;
            $sPad = $word ;
        }
        else {$sPad = $sPad + " " + $word  } ;
    }  ;
    if ($sPad.length -ne 0) {$sTextO = $sTextO + $sPad };
    $sTextO | write-output ; 
}

#*------^ wrap-Text.ps1 ^------

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function convert-CaesarCipher,_encode,_decode,convertFrom-Base64String,convertFrom-Html,Convert-invertCase,convert-Rot13,convert-Rot47,convertTo-Base64String,ConvertTo-CamelCase,ConvertTo-L33t,ConvertTo-lowerCamelCase,ConvertTo-SCase,ConvertTo-SNAKE_CASE,convertTo-StringReverse,convertTo-StudlyCaps,convertTo-TitleCase,create-AcronymFromCaps,get-StringHash,IsNumeric,Quote-List,Quote-String,Remove-StringDiacritic,Remove-StringLatinCharacters,Unwrap-Text,Unwrap-TextN,WordWrap-String,wrap-Text -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXHUB9FqA3xLp3gb34crFXOuG
# QcygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSlWKRf
# BhuJHFIp+hkCQN/HB+TkazANBgkqhkiG9w0BAQEFAASBgEYoDEPoHo3qnIyntVg+
# 99Z4Gca+1urMmsKKqdYrkWSkRFWGfo7L0KBc7ZoLSYVK2fGarQGJEauz006W91Ma
# uwQD4VOTBZUn5PqKwe2K++eefgi8PHMx+oJmwB5USSb8gxE5UF4h01grrxv3YLpu
# KwibUzxZ2NjGtL6bqcisxq39
# SIG # End signature block
