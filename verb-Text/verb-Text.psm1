﻿# verb-text.psm1


  <#
  .SYNOPSIS
  verb-Text - Generic text-related functions
  .NOTES
  Version     : 5.1.3.0
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
    $runningInVsCode = $env:TERM_PROGRAM -eq 'vscode' ;

#*======v FUNCTIONS v======




#*------v compare-CodeRevision.ps1 v------
function compare-CodeRevision {
    <#
    .SYNOPSIS
    compare-CodeRevision - Wrapper for Compare-Object to compare two revisions of a given text block of code. Defaults to appending Line numbers to the comparison output (suppress with -nolinenumbers).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-01-10
    FileName    : compare-CodeRevision.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Development,ChangeTracking
    AddedCredit : PaulChavez
    AddedWebsite:	https://groups.google.com/g/microsoft.public.windows.powershell/c/0zoV5ekugXY
    AddedTwitter:	URL
    REVISIONS
    * 8:04 AM 1/11/2022 minor CBH update
    * 12:36 PM 1/10/2022 compare-CodeRevision:init
    .DESCRIPTION
    compare-CodeRevision - Wrapper for Compare-Object to compare two revisions of a given text block of code. Defaults to appending Line numbers to the comparison output (suppress with -nolinenumbers).
    
    Yea, [Git's](https://git-scm.com/) a *much* better choice for revision tracking - *if* you've been doing all editing in your *project directory*. But if you're doing debugging on a remote admin box, fixing the odd bug *on the fly*, by editing-and-'ipmo -force'ing the live installed module .psm1 copy, sometimes you just want to diff the *revised*/newly-functional *local* copy, across the network against your last commited source copy, to see how many changes you actually added (and which functions need to be duped back to your source, for git tracking/build). 
    .PARAMETER  Reference
    Code block reference for comparison[-Reference (gc c:\path-to\mod.psm1)]
    .PARAMETER  Difference
    Code block to be compared to the reference code[-Revision (gc c:\path-to\modv2.psm1)]
    .PARAMETER  NoLineNumbers
    Switch to suppress default line-number addition (in Reference & Difference code blocks)[-NoLineNumbers]
    .EXAMPLE
    $mod = 'verb-exo' ; 
    $ref = (gc "\\tsclient\c\sc\$mod\$mod\$mod.psm1")  ;
    $rev = (gc (gmo $mod).path)  ;
    $diff = Compare-CodeRevision $ref $rev ; 
    Compare local (updated) module code agaisnt reference dev source (via automatic RDP client pathing)
    .LINK
    https://gist.github.com/chillitom/8335042
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Code block reference for comparison[-Reference (gc c:\path-to\mod.psm1)]")]
        [ValidateNotNullOrEmpty()]
        $Reference,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Code block to be compared to the reference code[-Revision (gc c:\path-to\modv2.psm1)]")]
        [ValidateNotNullOrEmpty()]
        $Difference,
        [Parameter(Mandatory=$false,HelpMessage="Switch to suppress default line-number addition (in Reference & Difference code blocks)[-NoLineNumbers]")]
        [switch]$NoLineNumbers
    ) ;
    if(-not $NoLineNumbers){
        $smsg = "(adding line#'s...)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$($smsg)" } ;
        $Reference = $Reference | %{$i = 1} { new-object psobject -prop @{LineNum=$i;Text=$_}; $i++} ;
        $Difference = $Difference | %{$i = 1} { new-object psobject -prop @{LineNum=$i;Text=$_}; $i++} ;
        $pltCO=[ordered]@{Reference = $Reference ;Difference = $Difference ;Property = 'Text' ;PassThru = $true ;} ;
    } else {
        $pltCO=[ordered]@{Reference = $Reference ;Difference = $Difference ; PassThru = $true ;} ;
    } ;  
     
    $smsg = "Compare-Object w`n$(($pltCO|out-string).trim())" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-verbose "$($smsg)" } ;
    $diff = Compare-Object @pltCO ; 
    $diff | write-output ; 
}

#*------^ compare-CodeRevision.ps1 ^------


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
    * 2:13 PM 11/22/2021 made Key & string mandetory params; added range validation on Key
    * 6:22 PM 6/18/2021 convert-CaesarCipher:init
    .DESCRIPTION
    convert-CaesarCipher - Converts passed string to/from RotNN where NN is the '-Key' offset of the alphabet
    This cipher rotates (either towards left or right) the letters of the alphabet (A to Z).
The encoding replaces each letter with the 1st to `$Key-th letter in the alphabet (wrapping Z to A).
So key 2 encrypts "HI" to "JK", but key 20 encrypts "HI" to "BC".
This simple "mono-alphabetic substitution cipher" provides almost no security, because an attacker who has the encoded message can either use frequency analysis to guess the key, or just try all 25 keys.
Caesar cipher is identical to Vigenère cipher with a Key of length 1.
Also, Rot-13 is identical to Caesar cipher with Key 13. 
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
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string,
        [Parameter(Position=1,Mandatory=$true,HelpMessage="Integer 'key' [1-25] to be used to encode[-key 2]")]
        [ValidateRange(1,25)]
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
    convertFrom-Base64String - Convert Base64 encoded string back to original text, and return to pipeline
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
    * 3:58 PM 4/20/2022 Work in progress, was adding file 'sourcefile/targetfile' support, untested, I believe I had issues with the conversion, b64 wouldn't convert cleanly back to original (as part of the encoding for the invoke-soundcue bundled ping updates).
    * 10:38 AM 9/16/2021 removed spurious DefaultParameterSet matl and file/path test material (from convertto-b64...), added pipeline example to CBH, fixed CBH params (had convertfrom params spec'd); added email address conversion example
    * 8:26 AM 12/13/2019 convertFrom-Base64String:init
    .DESCRIPTION
    convertFrom-Base64String - Convert specified string from Base64 encoded string back to text and return to pipeline
    .PARAMETER  string
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    PS> convertFrom-Base64String -string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8=' ; 
    Convert Base64 encoded string back to original unencoded text
    .EXAMPLE
    PS> $EmailAddress = 'YWRkcmVzc0Bkb21haW4uY29t' | convertFrom-Base64String
    Pipeline conversion of encoded EmailAddress back to string.
    .EXAMPLE
    PS> convertTo-Base64String -path c:\path-to\file.png >> base64.txt ; 
    PS> $Media = ''UklGRmysA...TRIMMED...QD8/97/y/+8/7P/' ;
    PS> convertfrom-Base64String -string $media -TargetPath c:\path-to\file.png ; 
    Demo conversion of encoded wav file (using 
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,HelpMessage="string to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']")]
        [String]$string,
        [Parameter(HelpMessage="Optional param that designates path from which to read a file containing Base64 encoded content, to be decoded[-SourceFile 'c:\path-to\base64.txt']")]
        [string]$SourceFile,
        [Parameter(HelpMessage="Optional param that designates path into which to write the decoded Base64 content [-TargetPath 'c:\path-to\file.png']")]
        [string]$TargetFile
    ) ;
    if($string -AND $SourceFile){
        throw "Please use either -String or -SourceFile, but not both!"
        break ; 
    } ; 
    
    $error.clear() ;
    TRY {
        if(-not($string) -AND $SourceFile){
            $string = Get-Content $SourceFile #-Encoding Byte ; 
        } elseif (-not($string)){
            throw "Please specify either -String '[base64-encoded string]', or -SourceFile c:\path-to\base64.txt" ; 
        } ; 
        
        if(-not $TargetFile){
            $String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string)) ;  
            write-verbose "returning output to pipeline" ;
            #[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string))| write-output ;     
            $String | write-output ;     
        } else {
            write-verbose "writing output to specified:$($TargetFile)..." ; 
            <# 
            # Get-Content without -raw splits the file into an array of lines thus destroying the code
            # Text.Encoding interprets the binary code as text thus destroying the code
            # Out-File is for text data, not binary code
            #>
            #$Content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string)) ;  
            #$Content = [System.Convert]::FromBase64String($string)
            $folder = Split-Path $TargetFile ; 
            if(-not(Test-Path $folder)){
                New-Item $folder -ItemType Directory | Out-Null ; 
            } ; 
            #Set-Content -Path $TargetFile -Value $Content #-Encoding Byte ;
            [IO.File]::WriteAllBytes($TargetFile, [Convert]::FromBase64String($string))
        }; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
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
    * 2:35 PM 11/22/2021 update CBH, this is invertable, so cmdlet name should be convert-Rot13, not to/from. 
    * 6:22 PM 6/18/2021 convert-Rot13:init
    .DESCRIPTION
    convert-Rot13 - Converts passed string to/from Rot13. Run encoded text back through and the origen text is returned
    Replace every letter of the ASCII alphabet with the letter which is "rotated" 13 characters "around" the 26 letter alphabet from its normal cardinal position   (wrapping around from   z   to   a   as necessary). 
    Rot13 is an invertible algorithm: applying the same algorithm to the input twice will return the origin text. 
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot13 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
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
    convert-Rot47 - Converts passed string to/from Rot47. Run encoded text back through and the origen text is returned
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
    * 2:35 PM 11/22/2021 update CBH, this is invertable, so cmdlet name should be convert-Rot13, not to/from. 
    * 6:22 PM 6/18/2021 convert-Rot47:init
    .DESCRIPTION
    convert-Rot47 - Converts passed string to/from Rot47 
    Replaces a character within the ASCII range [33, 126] with the character 47 character after it (rotation) in the ASCII table.
    Rot47 is an invertible algorithm: applying the same algorithm to the input twice will return the origin text. 
    .PARAMETER  path
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convert-Rot47 -string 'YOU can convert a string to title case (every word start with a capital letter).' ; 
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://gist.github.com/chillitom/8335042
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [Alias('in')]
        [String]$string
    ) ;
    $table = @{} ; 
    for ($i = 0; $i -lt 94; $i++) {
        $table.Add(
            "!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~"[$i],
            "PQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~!`"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO"[$i]) ; 
    } ; 
    $out = New-Object System.Text.StringBuilder ;
    $string.ToCharArray() | %{
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
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If -String resolves to a path, it will be treated as a -SourceFile parameter (file content converted to Base64 encoded string). 
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
    * 3:58 PM 4/20/2022 Work in progress, was adding file 'sourcefile/targetfile' support, untested, I believe I had issues with the conversion, b64 wouldn't convert cleanly back to original (as part of the encoding for the invoke-soundcue bundled ping updates).
    * 10:27 AM 9/16/2021 updated CBH, set -string as position 0, flipped pipeline to string from path, removed typo $file test, pre-resolve-path any string, and if it resolves to a file, load the file for conversion. Shift path validation into the body. 
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If String resolves to a path, it will be treated as a -path parameter (file content converted to Base64 encoded string). 
    .PARAMETER  SourceFile
    File to be Base64 encoded (image, text, whatever)[-SourceFile path-to-file]
    .PARAMETER  string
    String to be Base64 encoded [-string 'string to be encoded']
    .EXAMPLE
    PS> convertTo-Base64String -SourceFile C:\Path\To\Image.png > base64.txt ; 
    Example converting a png file to base64 and outputing result to text using redirection
    .EXAMPLE
    PS> convertto-base64string -sourcefile 'c:\path-to\some.jpg' -targetfile c:\tmp\b64.txt -verbose
    Example converting a jpg file to a base64-encoded text file leveraging the -targetfile parameter, and with verbose output 
    .EXAMPLE
    PS> convertTo-Base64String -string "my *very* minimally obfuscated info"
    .EXAMPLE
    PS> "address@domain.com" | convertTo-Base64String
    Pipeline conversion of an email address to b64
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,HelpMessage="string to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']")]
        [String]$string,
        [Parameter(HelpMessage="Optional param that designates path from which to read a file to be Base64 encoded[-SourceFile 'c:\path-to\base64.txt']")]
        [string]$SourceFile,
        [Parameter(HelpMessage="Optional param that designates path into which to write the encoded Base64 content [-TargetPath 'c:\path-to\file.png']")]
        [string]$TargetFile
    ) ;
    $error.clear() ;
    TRY {
        if($SourceFile -OR ($SourceFile = $string| Resolve-Path -ea 0)){
            if(test-path $SourceFile){
                write-verbose "(loading specified/resolved SourceFile:$($SourceFile))" ; 
                <# Get-Content without -raw splits the file into an array of lines thus destroying the code
                # Text.Encoding interprets the binary code as text thus destroying the code
                # Out-File is for text data, not binary code
                #>
                #$String = (get-content $SourceFile -encoding byte) ; 
                #$String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile))
                # direct convert 1-liner bin2b64
                if(-not $TargetFile){
                    write-verbose "returning output to pipeline" ;
                    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile))
                    $base64string | write-output ; 
                } else {
                    write-verbose "writing output to specified:$($TargetFile)..." ; 
                        $folder = Split-Path $TargetFile ; 
                        if(-not(Test-Path $folder)){
                            New-Item $folder -ItemType Directory | Out-Null ; 
                        } ; 
                        #Set-Content -Path $TargetFile -Value $Content #-Encoding Byte ;
                        #[IO.File]::WriteAllBytes($TargetFile, [Convert]::FromBase64String($String ))
                        [IO.File]::WriteAllBytes($TargetFile,[char[]][Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile))) ; ; 
                }; 
                
            } else { throw "Unable to load specified -SourceFile:`n$($SourceFile))" } ; 
        } else { 
            $String = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) ;
        } ; 
        if(-not $TargetFile){
            write-verbose "returning output to pipeline" ;
            $String | write-output ; 
        } else {
            write-verbose "writing output to specified:$($TargetFile)..." ; 
                $folder = Split-Path $TargetFile ; 
                if(-not(Test-Path $folder)){
                    New-Item $folder -ItemType Directory | Out-Null ; 
                } ; 
                Set-Content -Path $TargetFile -Value $Content #-Encoding Byte ;
                #[IO.File]::WriteAllBytes($TargetFile, [Convert]::FromBase64String($String ))
        }; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
}

#*------^ convertTo-Base64String.ps1 ^------


#*------v convertto-Base64StringCommaQuoted.ps1 v------
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
    PROCESS{[array]$outs += $str | %{[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($_))} ; }
    END {'"' + $(($outs) -join '","') + '"' | out-string | set-clipboard } ; 
}

#*------^ convertto-Base64StringCommaQuoted.ps1 ^------


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


#*------v convertTo-PSHelpExample.ps1 v------
Function convertTo-PSHelpExample {
    <#
    .SYNOPSIS
    convertTo-PSHelpExample - Given a ScriptBlock of unindented sample code, adds leading keyword, prefixes each code line with PS>, and adds empty line for description, for use in a CommentBasedHelp block. If -Scriptblock isn't specified, the current clipboard content is used.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-03-01
    FileName    : convertTo-PSHelpExample.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text,Code,Development,CommentBasedHelp
    REVISIONS
    * 1:36 PM 4/5/2023 suddenly set-clipboard -value breaks, param now shows as -Text: retooled splits, remove blank lines, coerce array and then coerse to text before writing to set-clipboard -text
    * 11:52 AM 9/8/2022 fix: #106 was writing codeblock with `n EOL, which resulted in [LF], instead of "proper" Win [CR][LF]. Pester complains, so updated to wright `n`r as EOL instead
    * 12:37 PM 6/1 7/2022 updated CBH, moved from vert-text -> verb-dev
    * 1:50 PM 3/1/2022 init
    .DESCRIPTION
    convertTo-PSHelpExample - Given a ScriptBlock of unindented sample code, adds leading keyword, prefixes each code line with PS>, and adds empty line for description, for use in a CommentBasedHelp block. If -Scriptblock isn't specified, the current clipboard content is used.
    To save time, pre-left-justify - move the scriptblock leftmost indent to the left margin, before running this process on the code 
    (e.g. don't have the block pre-indented beyond the minimum 1st level).

    Due to the vageries of parsing & splitting herestrings (e.g. attempting to feed the -ScriptBlock with a herestring), 
    it's generally simplest to let this off of code pre-copied to the clipboard
    (comes through cleanly as an array without further need for testing or conversion).

    .PARAMETER  ScriptBlock
    ScriptBlock of powershell to be wrapped reformatted to CBH code sample 
    .PARAMETER Wrap
    Switch to wrap (suffix semcolons with CrLFs) the specified block of code[-wrap]
    .PARAMETER NoPad
    Switch to suppress addition of extra NewLines in output code (true by default)[-noPad
    .EXAMPLE
    convertTo-PSHelpExample ;
    Default no-parameter behavior: Convert clipboard code content into a CBH help example-formatted block. 
    .EXAMPLE
    $text= "write-host 'yea';`ngci 'c:\somefile.txt' ;`n" | convertTo-PSHelpExample ;
    Pipeline example
    .LINK
    https://github.com/tostka/verb-Text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="ScriptBlock of powershell to be wrapped reformatted to CBH code sample")]
        [Alias('Code')]
        [string[]]$ScriptBlock,
        [Parameter(HelpMessage="Switch to wrap (suffix semcolons with CrLFs) the specified block of code[-wrap]")]
        [switch]$Wrap,
        [Parameter(HelpMessage="Switch to suppress addition of extra NewLines in output code (true by default)[-noPad]")]
        [switch]$NoPad=$true 
    )  ; 
    $sCBHKeyword = '.EXAMPLE' ;
    $sCBHPrompt = 'PS> ' ;
    $fromCB = $false ; 
    if(-not $ScriptBlock){
        $ScriptBlock= (get-clipboard) # .trim().replace("'",'').replace('"','') ;
        if($ScriptBlock){
            write-verbose "No -ScriptBlock specified, detected text on clipboard:`n$($ScriptBlock)" ;
            $fromCB = $true ;
        } else {
            write-warning "No -path specified, nothing suitable found on clipboard. EXITING!" ;
            Break ;
        } ;
    } else {
        write-verbose "ScriptBlock:$($ScriptBlock)" ;
    } ;

    # we need split lines to prefix with PS> (and no blank lines)
    if(($ScriptBlock |  measure).count -eq 1){
        [array]$ScriptBlock = $ScriptBlock.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
    } ; 

    # issue specific to PS, -replace isn't literal, see's $ as variable etc control char
    # rgx replace to prefix all special chars, to make them literals, before doing any text -replace (graveaccent escape ea)
    #$ScriptBlock = $scriptblock -replace '([$*\~;(%?.:@/]+)','`$1' ;
    # use wrapper function for the above
    $ScriptBlock=convertTo-EscapedPSText -ScriptBlock $ScriptBlock -Verbose:($PSBoundParameters['Verbose'] -eq $true) ; 
    
    if($wrap -OR ($ScriptBlock |  measure).count -eq 1){
        write-verbose "(-wrap: wrapping code at semicolons)" ; 
        #  code that wraps ;-delim'd code to prefixable lines
        # functional AHK: StringReplace clipboard, clipboard, `;, `;`r`n, All
        $splitAt = ";" ; 
        $replaceWith = ";$([Environment]::NewLine)" ; 
        # ";`r`n"  ; 
        $ScriptBlock = $ScriptBlock | Foreach-Object {
                $_ -replace $splitAt, $replaceWith ;
        } ; 
    } ;
    
    # ensure we have an array of separate lines to prefix - no empties
    if($scriptblock -isnot  [array] -OR (($ScriptBlock |  measure).count -eq 1)){
        write-verbose "(`$ScriptBlock non-Array, splitting on NewLines)" ; 
        # split into lines - looks like a wrapped block, but it's one line with crlfs - need each to loop and append prefixes, so split it out
        #[array]$ScriptBlock = $ScriptBlock.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) ;
        # above results in PS> [blank], drop the empties
        [array]$ScriptBlock = $ScriptBlock.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
    } ; 
    
    # coercing every assign into array, and typing the aggreg
    if($nopad){
        [array]$CBH = @("$($sCBHKeyword)")
    } else {
        [array]$CBH = @("$($sCBHKeyword)`n")
    } ; 
    $ScriptBlock = @(
        $ScriptBlock | Foreach-Object {
            if($nopad){
                @($CBH += "$($sCBHPrompt) $($_)") 
            } else {
                #$CBH += "$($sCBHPrompt) $($_)`n" ;
                # above was creating examples with EOL [LF] vs [CR][LF], use both (Pester no-likey)
                @($CBH += "$($sCBHPrompt) $($_)`r`n" )
            }  
        } ; 
    ) ; 
    $CBH += @("SAMPLEOUTPUT") ; 
    $CBH += @("DESCRIPTION") ; 

    # reverse escapes - have to use dbl-quotes around escaped backtick (dbld), or it doesn't become a literal
    #$ScriptBlock = $scriptblock -replace "``([$*\~;(%?.:@/]+)",'$1'; 
    # wrapper function: 
    $CBH=convertFrom-EscapedPSText -ScriptBlock $CBH -verbose:$($VerbosePreference -eq "Continue") ;  ;  
    if($fromCB){
        write-host "(sending results back to clipboard)" ;
        #$CBH | out-clipboard ; 
        # 4/5/2023: suddenly set-clipboard -value breaks, param now shows as -Text [facepalm]
        <# -Files <FileSystemInfo[]>,-Html <String>,-Image <Image>,-Rtf <String>,-Text <String> #>
        # try default positional # nope, param error
        #set-clipboard $CBH ;
        # coerce system.array to string and use -text
        set-clipboard -text ($cbh | out-string) ; 
    } else { ; 
        # or to pipeline
        write-verbose "(sending results to pipeline)" ;
        $CBH | write-output ; 
    } ; 
}

#*------^ convertTo-PSHelpExample.ps1 ^------


#*------v convertTo-QuotedList.ps1 v------
Function convertTo-QuotedList {
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
    * 10:54 AM 1/17/2023 # psv2 bug: $psitem isn't supported, need to use $_
    * 1:16 PM 11/22/2021 added presplit to lines; upgraded to adv function; ren'd quote-list -> convertTo-QuotedList ; made actually functional (wasn't, was a half-finished copy of quote-text)
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    convertTo-QuotedList.ps1 - wrap list with quotes
    .LINK
    #>
    [CmdletBinding()]
    [Alias('quote-list')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be quote-wrapped[-PARAM SAMPLEINPUT]")]
        [string]$List
    ) ;
    write-verbose "lines:`n$($lines)" ;
    if( ($List.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) | measure).count -gt 1){
        write-verbose "(splitting multi-line block into array of lines)" ;
        $List = $List.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) ;  
    } ; 
    $List |foreach-object {
         "`"$($_)`""  ; 
    } ; 
}

#*------^ convertTo-QuotedList.ps1 ^------


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


#*------v convertto-StringCommaQuote.ps1 v------
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
}

#*------^ convertto-StringCommaQuote.ps1 ^------


#*------v ConvertTo-StringQuoted.ps1 v------
Function ConvertTo-StringQuoted {
    <#
    .SYNOPSIS
    ConvertTo-StringQuoted.ps1 - Wrap argument with quotes
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : ConvertTo-StringQuoted.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 9:22 AM 11/22/2021 updated to pipeline support, fixed non-func; flipped name quote-string-> ConvertTo-StringQuoted, with quote-string alias; added example to pass pester
    * 8:27 PM 5/23/2014 
    .DESCRIPTION
    ConvertTo-StringQuoted.ps1 - rap argument with quotes
    .EXAMPLE
    Mr. Watson, Come Here! | ConvertTo-StringQuoted
    .LINK
    #>
    [CmdletBinding()]
    [Alias('quote-string')]
    PARAM([Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be quote-wrapped[-PARAM SAMPLEINPUT]")][string]$String
    ) ;
    "`"$($String)`"" | write-output ; 
}

#*------^ ConvertTo-StringQuoted.ps1 ^------


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
    * 11:04 AM 11/19/2021 removed typo Crlf (prevented proper join), pulled strong typing on $string (prevented flipping to [array] for processing)
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
        $string
    ) ;
    $string = $string.ToCharArray() ; 
    [Array]::Reverse($string) ;
    $string -join '' | write-output ; 
}

#*------^ convertTo-StringReverse.ps1 ^------


#*------v convertTo-StUdlycaPs.ps1 v------
function convertTo-StUdlycaPs {
    <#
    .SYNOPSIS
    convertTo-StUdlycaPs - Convert passed string to StudlyCaps\CrazyCaps etc (random uppper & lowercase) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-18
    FileName    : convertTo-StUdlycaPs.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    REVISIONS
    * 6:22 PM 6/18/2021 convertTo-StUdlycaPs:init
    .DESCRIPTION
    convertTo-StUdlycaPs - Convert passed string to Invert Case (upper->lower ; lower -> upper) and return to pipeline
    .PARAMETER  string
    String to be converted[-string 'SAMPLEINPUT']
    .EXAMPLE
    convertTo-StUdlycaPs.ps1 -string 'xxxxx' ; 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [Alias('convertTo-StUdlycaSe','convertTo-CrAzYCaPS')]
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

#*------^ convertTo-StUdlycaPs.ps1 ^------


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
    # Doesn’t work on all-caps (make lcase first)
    "$($txtInfo.ToTitleCase($string.toLower()))" | write-output ; 
}

#*------^ convertTo-TitleCase.ps1 ^------


#*------v convertTo-UnWrappedText.ps1 v------
Function convertTo-UnWrappedText {
    <#
    .SYNOPSIS
    convertTo-UnWrappedText
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : convertTo-UnWrappedText
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    REVISIONS   :
    * 9:34 AM 11/22/2021 swapped out hard-coded crlf, with os agnostic method (& purged unwrap-textN `n-targeting variant); made adv func ; ren'd unwrap-text -> convertTo-UnWrappedText, with unwrap-text alias; ren'd param to Text, w sText alias
    * 8:41 AM 4/12/2015, make it drop into the pipeline instead of return
    .DESCRIPTION
    convertTo-UnWrappedText
    .PARAMETER  sText
    Text to be unwrapped
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Outputs unwrapped text to pipeline
    .EXAMPLE
    get-fortune | convertTo-UnWrappedText | speak-words
    Get a fortune, unwrap the text, and text-to-speech the words
    .EXAMPLE
    convertTo-UnWrappedText $x ;
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    [Alias('unwrap-text','Unwrap-TextN')]
    PARAM(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'Text to be unwrapped')]
        [Alias('sText')]
        [string]$Text
    )    
    Foreach ($sTxt in $Text) {
        $sTxt0 = $sTxt.replace(([Environment]::NewLine)," ");
        return $sTxtO;
    } 
}

#*------^ convertTo-UnWrappedText.ps1 ^------


#*------v convertTo-WordsReverse.ps1 v------
Function convertTo-WordsReverse {
    <#
    .SYNOPSIS
    convertTo-WordsReverse - Reverse the order of words in a sentance/phrase. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-08
    FileName    : convertTo-WordsReverse.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:54 AM 1/17/2023 # psv2 bug: $psitem isn't supported, need to use $_
    * 5:01 PM 4/6/2022 add name reverse example
    * 10:34 AM 11/19/2021 init
    .DESCRIPTION
    convertTo-WordsReverse - Reverse the order of words in a sentance/phrase. 
    Included silly period-to-line-end code, to avoid parsing periods into mid-phrase, where in original text.    
    (silly, but looks better in output). 
    -TextOnly switch suppresses punctuation, which normally space-splits associated with it's proximate word, and clutters the output. 
    .PARAMETER  lines
    Text to be reversed in word-order[-lines 'THESE are the times that try men's souls.']
    .EXAMPLE
    PS> "Those who would give up essential Liberty, to purchase a little temporary Safety, deserve neither Liberty nor Safety." | convertTo-WordsReverse ;
    Safety nor Liberty neither deserve Safety, temporary little a purchase to Liberty, essential up give would who Those.
    Simple example reversing a phrase
    .EXAMPLE
    PS> $h=@"
Caesar had his Brutus, Charles the First his Cromwell; and George the Third
- ['Treason!' cried the Speaker] -
may profit by their example. 
If this be treason, make the most of it. 
― Patrick Henry
"@ ; 
    PS> convertTo-WordsReverse -lines $h -textonly -verbose; 
        Third the George and Cromwell his First the Charles Brutus his had Caesar
        Speaker the cried Treason
        example their by profit may
        it of most the make treason be this If
        Henry Patrick
    Processing herestring block with TextOnly & verbose options. 
    .EXAMPLE
    PS> $h1=@"
Some say the world will end in fire,
Some say in ice.
From what I've tasted of desire
I hold with those who favor fire.
"@ ; 
    PS> $h1 | convertTo-WordsReverse  ; 
        fire, in end will world the say Some
        ice in say Some.
        desire of tasted I've what From.
        fire favor who those with hold I.    
    Pipeline processing of herestring block 
    .EXAMPLE
    PS> ('Atticus Ross' | convertTo-WordsReverse) -replace ' ',', ' ;
        Ross, Atticus 
    Demo turning an 'FName Lname' string into 'Lname, Fname'
    .LINK
    https://github.com/tostka/verb-Text
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Text to be reversed in word-order [-lines 'THESE are the times that try men's souls.']")]
        [ValidateNotNullOrEmpty()][Alias('text','string')]
        #[String]
        $lines,
        [Parameter(HelpMessage="Switch to pre-purge all non-alphanumeric chars (e.g. punctuation)[-TextOnly]")]
        [switch]$TextOnly
    )  ; 
    $rgxNonText = "[^a-zA-Z0-9 ]" ; 
   write-verbose "lines:`n$($lines)" ;
    if( ($lines.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) | measure).count -gt 1){
        write-verbose "(splitting multi-line block into array of lines)" ;
        # block with line returns, split it into an array for processing
        # advanatage of this, if input naturally has empty lines, it will not remove them, 
        # while env::newline naturally pads them, and the split remove *always* purges them back out. 
        $lines = $lines.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) ;  
        # trailing purge of empty lines (prevents periods on their own lines)
        $lines = $lines | where-object {$_} ; 
    } ; 

    # it's flipping line order, try aggregating to an array
    $out = @() ; 
    #$lines = $lines | foreach-object {
    $lines | foreach-object {
        if($TextOnly){
            write-verbose "(-TextOnly, removing all but:$($rgxNonText))"
            $l = $_ -replace $rgxNonText,'' ;
        } else {
            $l = $_ ; 
        } ; 
        [boolean]$hasPeriod = $false ; 
        write-verbose $_ ; 
        if($l -match '\.$'){
            $hashPeriod = $true ;
            $l = [regex]::match($l,'(.*)\.').captures[0].groups[1].value ;
        } else { 
            #$l = $_ 
        } ; 
        $array = $l -Split '\s' 
        #$array[($l.Count-1)..0] -join ' '
        [Array]::Reverse($array) ;
        if($hashPeriod){
            #"$($array -join ' ')."  
            $out+= "$($array -join ' ')." 
        } else { 
            #$array -join ' ' # | write-output ; 
            $out+= $array -join ' '
        } ; 
    } ; 
    
    #$lines | write-output ; 
    $out | Write-Output ;
    
}

#*------^ convertTo-WordsReverse.ps1 ^------


#*------v convertTo-WrappedText.ps1 v------
Function convertTo-WrappedText {
    <#
    .SYNOPSIS
    convertTo-WrappedText - Wrap a string at specified number of characters
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-08
    FileName    : convertTo-WrappedText.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 9:32 AM 11/22/2021 ren'd wrap-text -> convertTo-WrappedText, w wrap-text alias; added pipeline support ; spliced over -chars 'window' support from wordwrap-string.ps1 (and retired the variant); pulled strong type on $chars, shifted nchars name to an alias, and renamed it Characters; renamed $sText to $Text and shifted sText to an alias; added $host.name checking for 'Window' use
    * 8:35 PM 11/8/2021 typo'd postion on 2nd param; updated CBH to modern spec; added param name aliases (standardizing param names); added clipboard check for sText; defaulted nChars to 80
    * added CBH
    .DESCRIPTION
    convertTo-WrappedText - Wrap a string at specified number of characters
    .PARAMETER  Text
    String to be wrapped[-Text 'Four score and seven years ago']
    .PARAMETER  Characters
[int]Character number to wrap at, or 'WINDOW' to indicate wrap should be performed at width of current window[-Wrap 'WINDOW']
    .EXAMPLE
    $text=convertTo-WrappedText -sText "Please send issues to technisbetas@gmail.com, putting them in the reviews doesn't help me find fix them" -nChars 30 ;
    .LINK
    https://github.com/tostka/verb-Text
    #>
    [CmdletBinding()]
    [Alias('wrap-text')]
    param(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be wrapped[-Text 'Four score and seven years ago']")]
        [Alias('String','sText')]
        [string]$Text, 
        #[Parameter(Position=1,HelpMessage="Number of characters, at which to wrap the string[-nChars 120")]
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "[int]Character number to wrap at, or 'WINDOW' to indicate wrap should be performed at width of current window[-Wrap 'WINDOW']")][ValidateNotNullOrEmpty()]
        [Alias('nChars')]
        #[int]
        $Characters=80
    ) 
    
    switch ($Characters.GetType().FullName){
        'System.String' {
            if ($Characters.ToUpper() -eq "WINDOW") {
                switch ($host.name){
                    'ConsoleHost' {
                        [int]$Characters = (get-host).ui.rawui.windowsize.width ; 
                        write-verbose "wrapping to WINDOW -Characters:$($Characters)" ; 
                    }
                    default {
                        write-verbose "$($host.name):-Characters:$($Characters)`n$($Text.length) chars long" ;
                        throw "$($host.name) is not a supported host for this script with the -Characters 'Window' option`nPlease use an interger number instead" ;
                    } ; 
                } ; 
            } else {
                Throw "Unrecognized -Characters string (Please use an integer, or the word 'Window')" ;
            } ;
        } 
        'System.Int32' {
            write-verbose "wrapping to -Characters:$($Characters)" ; 
        } ;
        default {
            Throw "Unrecognized -Characters spec (Please use an integer number, or the word 'Window')" ; 
        } 
    } ; 
    
    if(-not $Text){
        $Text= (get-clipboard) # .trim().replace("'",'').replace('"','') ;
        if($Text){
            write-verbose "No -Text specified, detected text on clipboard:`n$($Text)" ;
        } else {
            write-warning "No -path specified, nothing suitable found on clipboard. EXITING!" ;
            Break ;
        } ;
    } else {
        write-verbose "Text:$($Text)" ;
    } ;
    
    $words = $Text.split(" ");
    $sPad = $sTextO = "";
    foreach ($word in $words) {
        if (($sPad + " " + $word).length -gt $Characters) {
            $sTextO = $sTextO + $sPad + [Environment]::Newline ;
            $sPad = $word ;
        }
        else {$sPad = $sPad + " " + $word  } ;
    }  ;
    if ($sPad.length -ne 0) {$sTextO = $sTextO + $sPad };
    $sTextO | write-output ; 
}

#*------^ convertTo-WrappedText.ps1 ^------


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
        get-StringHash.ps1 - Convert specifed string to designated Cryptographic Hash string (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160)
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
        * 11:42 AM 11/22/2021 fixed CBH, missing desc to comply w pester
        * 11:59 AM 4/17/2020 updated CBH, moved from incl-servercore to verb-text
        * 9:46 PM 9/1/2019 updated, added Algorithm param, added pshelp
        * 1/21/11 posted version
        .DESCRIPTION
        get-StringHash.ps1 - Convert specifed string to designated Cryptographic Hash string (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160)
        Hybrid of work by Ivovan & Bryan Dady
        .PARAMETER  String
        Specify string to be hashed. Accepts from pipeline
        .PARAMETER  Algorithm
        Hashing Algorithm (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160) -Algorithm MD5
        .EXAMPLE
        $env:username | get-StringHash -Algorithm md5 ;
        .LINK
        https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
        #>
        PARAM (
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
    * 10:54 AM 1/17/2023 # psv2 bug: $psitem isn't supported, need to use $_
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
    PS C:\> Remove-StringDiacritic "L'�t� de Rapha�l" ;
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

#*------^ Remove-StringLatinCharacters.ps1 ^------


#*------v test-IsGuid.ps1 v------
function Test-IsGuid{
    <#
    .SYNOPSIS
    Test-IsGuid.ps1 - Validates a given guid using the TryParse method from the .NET Class “System.Guid”
    .NOTES
    Version     : 1.0.0
    Author      : Morgan
    Website     :	https://morgantechspace.com/
    Twitter     :	
    CreatedDate : 2022-06-23
    FileName    : Test-IsGuid.ps1
    License     : [none specified]
    Copyright   : © 2022 MorganTechSpace
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,GUID
    AddedCredit : 
    AddedWebsite:	https://morgantechspace.com/2021/01/powershell-check-if-string-is-valid-guid-or-not.html
    REVISIONS
    10:13 AM 6/23/2022 add to verb-text
    1/12/21 posted version morgantechspace.com
    .DESCRIPTION
    Test-IsGuid.ps1 - Validates a given guid using the TryParse method from the .NET Class “System.Guid”
    .PARAMETER String
    String to be validated
    .INPUTS
    Accepts pipeline input
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    Test-IsGuid -string '17863633-98b5-4898-9633-e92ccccd634c'
    Stock call
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://morgantechspace.com/2021/01/powershell-check-if-string-is-valid-guid-or-not.html
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        # Uri to be validated
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        #[Alias('')]
        [string]$String
    ) ;
    $ObjectGuid = [System.Guid]::empty
    # Returns True if successfully parsed
    return [System.Guid]::TryParse($String,[System.Management.Automation.PSReference]$ObjectGuid) ;
}

#*------^ test-IsGuid.ps1 ^------


#*------v test-IsNumeric.ps1 v------
Function test-IsNumeric {
    <#
    .SYNOPSIS
    test-IsNumeric.ps1 - Test a given value is numeric
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : test-IsNumeric.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    REVISIONS
    * 10:59 AM 9/20/2021 ren'd IsNumeric -> test-isNumeric and added orig name as alias 
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    test-IsNumeric.ps1 - Test a given value is numeric
    .PARAMETER Value
    Value to be evaluated
    .EXAMPLE
    $value="Win";test-IsNumeric($value);
    Test whether the string 'Win' is numeric (returns False)
    .EXAMPLE
    $value="80";test-IsNumeric($value);
    Test whether the string '80' is numeric (returns True)
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    [Alias('IsNumeric')]
    param($value)
    ($($value.Trim()) -match "^[-+]?([0-9]*\.[0-9]+|[0-9]+\.?)$") | write-output ; 
}

#*------^ test-IsNumeric.ps1 ^------


#*------v test-IsRegexPattern.ps1 v------
Function test-IsRegexPattern {
    <#
    .SYNOPSIS
    test-IsRegexPattern.ps1 - 1) does simple [regex]$pattern validation -AND checks for common rgx operators (And that it contains 1+ of ^[]\{}+*?): That a given string will *pass* for a regular-expresison - doesn't mean it's going to work, just that it doesn't fail initial parsing. Only way to know for sure is to try both -like & -match with the pattern and take the one that returns results. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : test-IsRegexPattern.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 12:28 PM 5/2/2022 updated examples, to better discern match vs like filter
    * 2:22 PM 11/12/2021 added [regex]$string initial test; fixed some typos; added example to run stack of rgx strings and output scores. 
    Expanded Description; Switched Threshold to 1; Added a verbose grouping output on $rgxOpsSingle; removed () from duplication in $rgxOpsPairedUnCommon; Seems functional. 
    * 11:10 AM 9/20/2021 init
    .DESCRIPTION
    test-IsRegexPattern.ps1 - does simple argument validation that a given string will pass for a regular-expresison, then scores for matches of three classes of Regex Operators in a given string:
    - does it match any single-character operators: \.*+?|^$ (score 1 per match)
    - does it match any common paired operators : (..) (score 5 for any match)
    - does it match any uncommon paired operators : [..]|{..} (score 10 for any match)
    - does it match a BackReference operator: \1 to \9 (score 20 for any match)
    If the net score on a string exceeds the specified Threshold (defaults to 1), [boolean]$true is returned. 

    Of course 'Threshold' is entirely arbitrary. But I did run some tests at it, to profile a range of regex/non-regex scores:
    (code used is in example 3)
    score name                                                                                                                                    
    ----- ----                                                                                                                                    
       27 (one()|two())-and-(three\2|four\3)                                                                                                      
       26 <img\s+src\s*=\s*["']([^"']+)["']\s*/*>                                                                                                 
       27 \b(?<username>[A-Z0-9._%+-]+)@(?<domain>[A-Z0-9.-]+\.[A-Z]+)\b                                                                          
       15 \.\d{2}\.                                                                                                                               
       55 ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*...
       21 ^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4}|[0-9]{2})$                                                      
       12 ^[0-2][0-3]:[0-5][0-9]$                                                                                                                 
       13 ^E[0-9a-fA-F]{10}.log$                                                                                                                  
        3 This\sis\sthe\send                                                                                                                      
        0 These are the times to test men's minds                                                                                                 
       13 ^\w{2,20}$                                                                                                                              
       19 (?i)DC=\w{1,}?\b                                                                                                                        
       15 ((s-)*)\w*\.\w*@(toro((lab)*)|)\.com                                                                                                    
       22 (?i:^(ADL|BCC|LYN|SPB)(MS(5|6)(2|4|5)((0)*)(0|1)((D)*)|\-\w{7})$)                                                                       
       25 ^sip:([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}$                                                               
        0 any character or a newline repeated zero or more times                                                                                  
       13 ^(.*?)\.(?i:RDP)$                                                                                                                       
       21 #\sSIG\s#\sBegin\ssignature\sblock(.|\n)*(.|\n)*#\sSIG\s#\sEnd\ssignature\sblock                                                        
       18 \w+((\s)*)\.\n((\r)*)((\s)*)\w+  


    Regex operators factored into the above: 
    - . matchany
    - * match zero or more: 
    - + match one or more
    - ? match zero or one
    - {} interval ops
    - | alternation op
    - [] list ops (char class)
    - - , [x-y] range op 
    - () grouping ops
    - \digit back-ref op
    - ^ match beginning-of-line 
    - $ match end-of-line
    
    .PARAMETER String
    String to be evaluated
    .PARAMETER Threshold
    Threshold score to classifiy a string as a regex pattern (1+, defaults to 1, the higher the stronger the confidence)[-Threshold 7]
    .PARAMETER ReturnScore
    Switch to return the score, rather than $true/$false[-returnscore]
    .EXAMPLE
    $pattern="I'm\sa\sREGEX";test-IsRegexPattern($PATTERN);
    Test whether the string evaluates as likely regex
    .EXAMPLE
    PS> if(test-IsRegexPattern -pattern $pattern){
    PS>     if(([regex]::matches($pattern,'\*').count) -AND ([regex]::matches($pattern,'\.').count -eq 0)){
    PS>         write-verbose "(-pattern specified - $($pattern): has wildcard *, but no period => 'like filter')" ; 
    PS>         $haystack = $haystack |Where-Object{$_.name -like $pattern}
    PS>         write-verbose "(-pattern specified - $($pattern) - *failed* as a regex, but worked, using -like postfilter)" ; 
    PS>         write-verbose "(use non-regex replace syntax)" ;
    PS>         $target.replace($pattern,$newString);
    PS>     } elseIf($haystack = $haystack |Where-Object{$_.name -match $pattern}){
    PS>         write-verbose "(-pattern specified - $($pattern) - worked as a regex, using -match postfilter)" ; 
    PS>         write-verbose "(use regex replace syntax)" ;
    PS>         $haystack -replace $pattern,$newString;
    PS>         #$likeResults | write-output ;
    PS>     } elseif ($haystack = $haystack |Where-Object{$_.name -like $pattern}){
    PS>         write-verbose "(-pattern specified - $($pattern) - *failed* as a regex, but worked, using -like postfilter)" ; 
    PS>         write-verbose "(use non-regex replace syntax)" ;
    PS>         $target.replace($pattern,$newString);
    PS>     } ;
    PS> } elseif ($haystack = $haystack |Where-Object{$_.name -like $pattern}){
    PS>     write-verbose "(-pattern specified - $($pattern) - would jnot pass test-IsRegexPattern: used a -like postfilter)" ; 
    PS>     write-verbose "(use non-regex replace syntax)" ;
    PS>     $target.replace($pattern,$newString);
    PS> } ;    
    Fancy conditional to evaluate -like from -regex filter string.
    .EXAMPLE
    PS> $rgxs ='(one()|two())-and-(three\2|four\3)' , '<img\s+src\s*=\s*["'']([^"'']+)["'']\s*/*>',
    PS>  "\b(?<username>[A-Z0-9._%+-]+)@(?<domain>[A-Z0-9.-]+\.[A-Z]+)\b", "\.\d{2}\.",
    PS>   "^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$", 
    PS>   "^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4}|[0-9]{2})$", "^[0-2][0-3]:[0-5][0-9]$",
    PS>    "^E[0-9a-fA-F]{10}.log$", "This\sis\sthe\send", "These are the times to test men's minds", 
    PS>    "^\w{2,20}$", '(?i)DC=\w{1,}?\b', '((s-)*)\w*\.\w*@(brand((lab)*)|)\.com', 
    PS>    "(?i:^(ABC|DEF|GHI|JKL)(MS(5|6)(2|4|5)((0)*)(0|1)((D)*)|\-\w{7})$)", 
    PS>    "^sip:([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}$", 
    PS>    "any character or a newline repeated zero or more times", "^(.*?)\.(?i:RDP)$", 
    PS>    "#\sSIG\s#\sBegin\ssignature\sblock(.|\n)*(.|\n)*#\sSIG\s#\sEnd\ssignature\sblock", 
    PS>    "\w+((\s)*)\.\n((\r)*)((\s)*)\w+" ; 
    PS> $Summary = @() ; 
    PS> foreach($rgx in $rgxs){
    PS>   $rpt = @{name= $rgx; score=$null} ; 
    PS>   $rpt.score = TEST-isregexpattern $rgx -ReturnScore -verbose ; 
    PS>   $Summary+= [pscustomobject]$rpt ; 
    PS> } ; 
    PS> $Summary  ; 
    Quick test suite to calibarate appropriate 'Threshold' for this function: Runs an array of variant regex strings through, 
    and reports on range of scores for comparison. 
    .LINK
    #>
    [CmdletBinding()]
    #[Alias('IsRegexValid')]
    param(   
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Pattern to be evaluated[-string '^My\sRegex$']")]
        [Alias('Pattern','Text')]
        [string]$string,
        [Parameter(HelpMessage="Threshold score to classifiy a string as a regex pattern (1+, defaults to 1, the higher the stronger the confidence)[-Threshold 7]")]
        [int]$Threshold=1,
        [Parameter(HelpMessage="Switch to return the score, rather than `$true/`$false[-returnscore]")]
        [switch]$ReturnScore
    )
    $rgxOpsSingle = [regex]'[\.\*\+\?\\^\$]' ; # single-char ops as literals: \.*+?|^$ (score 1 per match)
    $rgxOpsPairedCommon = [regex]'(\(.*\))' # (...)  (score 5 for any match)
    $rgxOpsPairedUnCommon = [regex]'(\[.*\]|\{.*\})' # paired ops - require the pair as a bracketing set, to function. ({[..]}) (score 10 for any match)
    $rgxBackRef = [regex]'\\[1-9]' ; # match \1 to \9 backrefs: (a(b))\2* (score 10 for any match)
    # below was a coarse attempt at any single instance of any op, no score, aimed at boolean eval.
    #$rgxRgxOps = [regex]'[\^\[\]\\\{\}\+\*\?\.]+' ; # check for ops:  ^[]\{}+*?() \^\[]\\\{}+\*?()
    try{
        # do the coarsest 'will it type as regex'? Proves litte, regular english will pass, but it's a starting point. 
      if([regex]$string){
            write-verbose "(passes initial test:`n[regex]$($string)" ; 
      } ; 

      #$bCouldBeRegex = ([boolean]([regex]$string) -AND [boolean]($string -match $rgxRgxOps) ); 
      $Score = 0 ; 
      if($ops = $string -split '' -match $rgxOpsSingle){
          #$Score += ($string -split '' -match $rgxOpsSingle | measure).count ;
          $Score += $ops.count ; 
          write-verbose "`$rgxOpsSingle matches:`n$(($ops | group | ft -auto count,name|out-string).trim())`nScore:$($score)" ;
      } ;
      if($string -match $rgxOpsPairedCommon){
          $vMatch = [regex]::match($string,$rgxOpsPairedCommon).captures[0].value ; 
          $Score += 5 ; 
          write-verbose "`$rgxOpsPairedCommon at least one match:`n$(($vMatch|out-string).trim())`nScore:$($score)" ; 
      } ;
      if($string -match $rgxOpsPairedUnCommon){
          $vMatch = [regex]::match($string,$rgxOpsPairedUnCommon).captures[0].value ; 
          $Score += 10 ;
          write-verbose "`$rgxOpsPairedUnCommon at least one match:`n$(($vMatch|out-string).trim())`nScore:$($score)" ;
      } ;
      if ($string -match $rgxBackRef) {
          $Score += 20 ;
          $vMatch = [regex]::match($string,$rgxBackRef).captures[0].value ; 
          write-verbose "`$rgxBackRef at least one match:`n$(($vMatch|out-string).trim())`nScore:$($score)" ;
      } ;
      write-verbose "(Aggregate Score:$($score))" ; 
      if($ReturnScore){
          $score | write-output ; 
      } else { 
          [boolean]($Score -ge $Threshold) | write-output ;
      } ; 
    } catch {
        $false | write-output ;
    }     
}

#*------^ test-IsRegexPattern.ps1 ^------


#*------v test-IsRegexValid.ps1 v------
Function test-IsRegexValid {
    <#
    .SYNOPSIS
    test-IsRegexValid.ps1 - does simple argument validation that a given string will pass for a regular-expresison - doesn't mean it's going to work, just that it doesn't fail initial parsing. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : test-IsRegexValid.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 11:10 AM 9/20/2021 init
    .DESCRIPTION
    test-IsRegexValid.ps1 - does simple argument validation that a given string will pass for a regular-expresison - doesn't mean it's going to work, just that it doesn't fail initial parsing. 
    .PARAMETER pattern
    Value to be evaluated
    .EXAMPLE
    $pattern="I'm\sa\sREGEX";test-IsRegexValid($PATTERN);
    Test whether the string pattern' will parse as a regex
    .LINK
    #>
    [CmdletBinding()]
    #[Alias('IsRegexValid')]
    param([string]$pattern)
    try{
        if([regex]$pattern){$true| write-output}
    } catch {
        $false | write-output ;
    }     
}

#*------^ test-IsRegexValid.ps1 ^------


#*------v test-IsUri.ps1 v------
function test-IsUri{
    <#
    .SYNOPSIS
    test-IsUri.ps1 - Validates a given Uri ; localized verb-EXO vers of non-'$global:' helper funct from ExchangeOnlineManagement. The globals export fine, these don't and appear to need to be loaded manually
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 20201109-0833AM
    FileName    : test-IsUri.ps1
    License     : [none specified]
    Copyright   : [none specified]
    Github      : https://github.com/tostka/verb-exo
    Tags        : Powershell
    AddedCredit : Microsoft (edited version of published commands in the module)
    AddedWebsite:	https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2
    REVISIONS
    * 1:11 PM 6/29/2022 renamed test-uri-> test-IsUri, aliased orig name
    * 2:08 PM 12/6/2021 ren'd UriString param to String, and added orig name as alias. Set CBH Output, and broader example; moving into verb-text, where it better fits.
    * 8:34 AM 11/9/2020 init
    .DESCRIPTION
    test-IsUri.ps1 - localized verb-EXO vers of non-'$global:' helper funct from ExchangeOnlineManagement. The globals export fine, these don't and appear to need to be loaded manually. Note this only validates https, not http (which will fail). 
    .PARAMETER String
    String to be validated
    .PARAMETER PermitHttp
    Switch to permit validation of either https or http uri.schemes
    .INPUTS
    Accepts pipeline input
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    test-IsUri -string https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2 
    Stock call
    .EXAMPLE
    test-IsUri -string https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2 
    Call that accepts either https or http scheme (default fails http://)
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2
    #>
    [CmdletBinding()]
    [Alias('test-URI')]
    [OutputType([bool])]
    Param(
        # Uri to be validated
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias('UriString')]
        [string]$String,
        [Parameter()][switch]$PermitHttp
    ) ;
    [Uri]$uri = $String -as [Uri]
    if($PermitHttp){
      ($uri.AbsoluteUri -ne $null) -and ($uri.Scheme -eq 'https' -OR $uri.Scheme -eq 'http')
    } else { 
      $uri.AbsoluteUri -ne $null -and $uri.Scheme -eq 'https' ;
    } ; 
}

#*------^ test-IsUri.ps1 ^------


#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function compare-CodeRevision,convert-CaesarCipher,_encode,_decode,convertFrom-Base64String,convertFrom-Html,Convert-invertCase,convert-Rot13,convert-Rot47,convertTo-Base64String,convertto-Base64StringCommaQuoted,ConvertTo-CamelCase,ConvertTo-L33t,ConvertTo-lowerCamelCase,convertTo-PSHelpExample,convertTo-QuotedList,ConvertTo-SCase,ConvertTo-SNAKE_CASE,convertto-StringCommaQuote,ConvertTo-StringQuoted,convertTo-StringReverse,convertTo-StUdlycaPs,convertTo-TitleCase,convertTo-UnWrappedText,convertTo-WordsReverse,convertTo-WrappedText,create-AcronymFromCaps,get-StringHash,Remove-StringDiacritic,Remove-StringLatinCharacters,Test-IsGuid,test-IsNumeric,test-IsRegexPattern,test-IsRegexValid,test-IsUri -Alias *




# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjxgrHcApTRZm/iFKc5o0bJpi
# +UOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTyddEn
# tvmfkwo9xWiAUZaFSsb2ZDANBgkqhkiG9w0BAQEFAASBgKai87y9uxVzSvbJVvWk
# E1ZwM9cJx1EasIP0hdLCmAduMd5KiZxD92JZgp1iLYGS3FmlVj1q0q5vpd2aZwfj
# JCm9Hbyhmd/Mhumv1wR2DOOtieqpqBMkeUbKd8TGF/DZh3zEPfOuK3vnpUGHTGnS
# VImAHvbI8SoZuZPybwNBujsB
# SIG # End signature block
