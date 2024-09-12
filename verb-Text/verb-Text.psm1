# verb-text.psm1


  <#
  .SYNOPSIS
  verb-Text - Generic text-related functions
  .NOTES
  Version     : 6.2.3.0
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


#*------v Convert-CodePointToPSSyntaxTDO.ps1 v------
function Convert-CodePointToPSSyntaxTDO {
    <#
    .SYNOPSIS
    Convert-CodePointToPSSyntaxTDO -  Converts a given Unicode CodePoint into the matching PSSyntax ([char]0xnnnn), [char]::ConvertFromUtf32(0xnnnnn)), returned as a Customobject summarizing the input CodePoint, the rendered Character it represents, and PSSyntax necessary to render the codepoint in Powershell
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2024-09-12
    FileName    : Convert-CodePointToPSSyntaxTDO.ps1
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:52 PM 9/12/2024 added CodePoint validator regex for PSCodePoint format (0xnnnn) ;  init

    .DESCRIPTION

    Convert-CodePointToPSSyntaxTDO -  Converts a given Unicode CodePoint into the matching PSSyntax ([char]0xnnnn), [char]::ConvertFromUtf32(0xnnnnn)), returned as a Customobject summarizing the input CodePoint, the rendered Character it represents, and PSSyntax necessary to render the codepoint in Powershell

    .PARAMETER CodePoint
    Unicode Codepoint (U+1F4AC|\u2717) to be converted into equivelent Powershell Syntax[-CodePoint 'U+1F4AC']
    .INPUT
    System.String[]
    .OUTPUT
    PSCustomObject summary of Codepoint, Character, and PSSyntax example to render the specified character
    .EXAMPLE
    PS> $Returned = Convert-CodePointToPSSyntaxTDO -CodePoint 'U+2620' -verbose
    PS> $Returned ; 

        CodePoint Character PSSyntax                        
        --------- --------- --------                        
        U+2620    ☠         [char]::ConvertFromUtf32(0x2620)

    PS> $Returned.PsSyntax ;

        [char]::ConvertFromUtf32(0x2620)

    Demo conversion of the codepoint for 'Skull & Crossbones' into PS Syntax
    .EXAMPLE
    PS> $codes = "U+2620 U+2623" ;     
    PS> $PSSyntax = ($item.CodePoint.split(' ') | Convert-CodePointToPSSyntaxTDO -Verbose:($PSBoundParameters['Verbose'] -eq $true) | select -expand PSSyntax ) -join ' ' ;         
    demo splitting a space-delimited set of CodePoints, looping them through Convert-CodePointToPSSyntaxTDO, and then space-joining them on return
    .LINK
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage = "Unicode Codepoint (U+1F4AC|\u2717) to be converted into equivelent Powershell Syntax[-CodePoint 'U+1F4AC']")]
        # \u2717 | U+1F600
        #[ValidatePattern("U\+[0-9a-fA-F]+|\\u[0-9a-fA-F]+")]
        [ValidatePattern("U\+[0-9a-fA-F]+|\\u[0-9a-fA-F]+|0x[0-9a-fA-F]+")] # updated rgx passes pre-converted PSCodePoint format
        [string[]]$CodePoint
    ) ;
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======
    } ;  # BEG-E
    PROCESS {
        foreach($point in $CodePoint){
            if($point -match "0x[0-9a-fA-F]+"){
                write-verbose "`$CodePoint $($point) is already in PSCodePoint format" ; 
                $psCodePoint = $point ; 
            }else{
                $psCodePoint = $point.replace('U+','0x').replace('\u','0x') ; 
            } ; 
            $PSSyntax = try{
                [char]$psCodePoint | out-null ;
                "[char]$($psCodePoint)"| write-output ;
            } catch {
                try{
                    [char]::ConvertFromUtf32($psCodePoint) | out-null;
                    "[char]::ConvertFromUtf32($($psCodePoint))" | write-output 
                }catch{throw "Unable to resolve Codepoint $(codepoint) to a working [char] string"}
            } ; 
            if($PSSyntax){
              write-verbose "Character: $($PSSyntax | invoke-expression)`n`PSSyntax:$($PSSyntax)" ; 
              [pscustomobject]([ordered]@{
                  CodePoint = $point ; 
                  Character = $($PSSyntax | iex) ; 
                  PSSyntax = $PSSyntax ; 
              }) | write-output ; 
              #$PSSyntax | write-output ; 
            } ;    
        } # loop-E  
    } 
    END {} ; 
}

#*------^ Convert-CodePointToPSSyntaxTDO.ps1 ^------


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
    * 11:02 AM 9/5/2023 updated catch: wasn't echo'ing anything, just throw everything out. Considered putting in PROC loop, but w mix of string & path intputs, that'd be too hard to arbitrate between processing an inbound loop.
    * 3:58 PM 4/20/2022 Work in progress, was adding file 'sourcefile/targetfile' support, untested, I believe I had issues with the conversion, b64 wouldn't convert cleanly back to original (as part of the encoding for the invoke-soundcue bundled ping updates).
    * 10:38 AM 9/16/2021 removed spurious DefaultParameterSet matl and file/path test material (from convertto-b64...), added pipeline example to CBH, fixed CBH params (had convertfrom params spec'd); added email address conversion example
    * 8:26 AM 12/13/2019 convertFrom-Base64String:init
    .DESCRIPTION
    convertFrom-Base64String - Convert specified string from Base64 encoded string back to text and return to pipeline
    .PARAMETER string
    String to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']
    .PARAMETER SourceFile
    Optional param that designates path from which to read a file containing Base64 encoded content, to be decoded[-SourceFile 'c:\path-to\base64.txt']
    .PARAMETER TargetFile
    Optional param that designates path into which to write the decoded Base64 content [-TargetPath 'c:\path-to\file.png']
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
    [Alias('cfB64')]
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
        $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
}

#*------^ convertFrom-Base64String.ps1 ^------


#*------v convert-HtmlCodeToTextTDO.ps1 v------
function convert-HtmlCodeToTextTDO {
    <#
    .SYNOPSIS
    convert-HtmlCodeToTextTDO - Convert specified text html code to plain text (replace html tags & entities, configure whitespace) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-05-14
    FileName    : convert-HtmlCodeToTextTDO.ps1
    License     : (non-asserted)
    Copyright   : 
    Github      : https://github.com/tostka
    AddedCredit : Winston Fassett
    AddedWebsite:	http://winstonfassett.com/blog/author/Winston/
    REVISIONS
    * 8:34 AM 11/8/2023 name-clash with importExcel mod leverage of ConvertFrom-Html(): ren convertFrom-Html -> convert-HtmlCodeToTextTDO (alias:     convertFrom-HtmlTDO ; don't alias to old name, do alias to tagged variant: This doesn't convert web pages, it replaces common html entities, strips tags & configures raw text whitespace
    * 3:11 PM 5/14/2021 convertFrom-Html:init, added $file spec
    .DESCRIPTION
    convert-HtmlCodeToTextTDO - Convert specified text html to plain text (replace html tags & entities) and return to pipeline
    Minimal port of Winston Fassett's html-ToText()
    .PARAMETER  string
    File to be Base64 encoded (image, text, whatever)[-string path-to-file]
    .EXAMPLE
    convert-HtmlCodeToTextTDO.ps1 -string 'xxxxx' ; 
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
    [Alias('convertFrom-HtmlTDO')]
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

#*------^ convert-HtmlCodeToTextTDO.ps1 ^------


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


#*------v convertto-AcronymFromCaps.ps1 v------
Function convertto-AcronymFromCaps {
    <#
    .SYNOPSIS
    convertto-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 9:47 AM 8/31/2023 bad verb: ren create-AcronymFromCaps -> convertto-AcronymFromCaps, alias orig name; CBH, updated examples to have output demo
    * 9:34 AM 3/12/2021 added -doEXOSubstitution to auto-tag 'exo' cmds in generated acronym (part of autoaliasing hybrid cmds across both onprem & EXO); added -verbose support
    12:14 PM 2/16.2.36 - working
    8:58 AM 2/16.2.36 - initial version
    .DESCRIPTION
    convertto-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
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
    PS> convertto-AcronymFromCaps "get-AdGroupMembersRecurseManual" ;
    
        AGMRM
        
    Create a Capital-letter Acroynm for the specified string
    .EXAMPLE
    PS> $fn=".\$(convertto-AcronymFromCaps $scriptNameNoExt)-$(get-date -uformat '%Y%m%d-%H%M').csv" ;
    Create a filename based off of an Acronym from the capital letters in the ScriptNameNoExt.
    .EXAMPLE
    PS> $tCmdlet = 'Get-xoMailboxFolderStatistics' ; 
    PS> write-verbose 'get-command resolves to standardized name capitalization (regardless of input string case)'
    PS> $tCmdlet = (gcm $tCmdlet).Name ; 
    PS> set-alias -name "$(convertto-AcronymFromCaps -string $tCmdlet -doEXOSubstitution)" -value $tCmdlet ; 
    
        GxMFS
        
    Create an alias 'GxMFS' for the Exchange Online Get-xoMailboxFolderStatistics cmdlet (which in this case reflects an 'xo' commandprefix'd) . Example also pre-resolves the specified cmdlet name, to the default cmdlet Name capitalization scheme (for consistency; ensure it always produces the same acronym for a given cmdlet)
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    [Alias('create-AcronymFromCaps')]
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
            write-verbose "-doEXOSubstitution specified, and 'exo|xo' substring detected: adding 'x' into 2nd position of output" ; 
            $AcroCap = "$($AcroCap.substring(0,1))x$($AcroCap.substring(1,$AcroCap.length-1))" ; 
        } ; 
    } ; 
    write-verbose "output:$($AcroCap)" ; 
    write-output $AcroCap ;
}

#*------^ convertto-AcronymFromCaps.ps1 ^------


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
    * 10:12 AM 5/23/2024 add: -ForceString param, to permit encoding paths to b64 (insted of attempting to convert the file contents to b64).
    * 11:02 AM 9/5/2023 updated catch: wasn't echo'ing anything, just throw everything out.
    * 3:58 PM 4/20/2022 Work in progress, was adding file 'sourcefile/targetfile' support, untested, I believe I had issues with the conversion, b64 wouldn't convert cleanly back to original (as part of the encoding for the invoke-soundcue bundled ping updates).
    * 10:27 AM 9/16/2021 updated CBH, set -string as position 0, flipped pipeline to string from path, removed typo $file test, pre-resolve-path any string, and if it resolves to a file, load the file for conversion. Shift path validation into the body. 
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If String resolves to a path, it will be treated as a -path parameter (file content converted to Base64 encoded string). 
    .PARAMETER string
    String to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']
    .PARAMETER SourceFile
    Optional param that designates path from which to read a file containing Base64 encoded content, to be decoded[-SourceFile 'c:\path-to\base64.txt']
    .PARAMETER TargetFile
    Optional param that designates path into which to write the decoded Base64 content [-TargetPath 'c:\path-to\file.png']
    .PARAMETER ForceString
    Optional param that forces treament of -String as a string (vs file; avoids mis-recognition of string as a path to a file to be converted)
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
    [Alias('CtB64')]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,HelpMessage="string to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']")]
            [String]$string,
        [Parameter(HelpMessage="Optional param that designates path from which to read a file to be Base64 encoded[-SourceFile 'c:\path-to\base64.txt']")]
            [string]$SourceFile,
        [Parameter(HelpMessage="Optional param that designates path into which to write the encoded Base64 content [-TargetPath 'c:\path-to\file.png']")]
            [string]$TargetFile,
        [Parameter(HelpMessage="Optional param that forces treament of -String as a string (vs file; avoids mis-recognition of string as a path to a file to be converted)")]
            [switch]$ForceString
    ) ;
    $error.clear() ;
    TRY {
        if($SourceFile -OR ( -not $ForceString -AND ($SourceFile = $string| Resolve-Path -ea 0) ) ){
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
        $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
}

#*------^ convertTo-Base64String.ps1 ^------


#*------v convertto-Base64StringCommaQuoted.ps1 v------
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
    [CmdletBinding()]
    PARAM([Parameter(ValueFromPipeline=$true)][string[]]$String) ;
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


#*------v ConvertTo-StudlyCaps.ps1 v------
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


#*------v convert-UnicodeUPlusToCharCode.ps1 v------
function convert-UnicodeUPlusToCharCode {
    <#
    .SYNOPSIS
    convert-UnicodeUPlusToCharCode - Convert a Unicode U+nnnn literal into a Code Point, Decimal, and equivelent [char]0xnnn string
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20240619-0300PM
    FileName    : convert-UnicodeUPlusToCharCode.ps1
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    Github      : https://github.com/tostka/verb-Text
    Tags        : Powershell,Unicode,Type,Fonts,Conversion
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 3:46 PM 7/11/2024 shift into verb-text
    * 8:18 AM 6/20/2024 init, working, though likely/untested that long codepoints fail (at least they did in cmdline testing)
    .DESCRIPTION
    convert-UnicodeUPlusToCharCode - Convert a Unicode U+nnnn literal into a Code Point, Decimal, and equivelent [char]0xnnn string

    ## Unicode Ranges

        - Control Codes span U+0000 	0  to U+009F 	159
        - Basic Latin spans U+0020 	  	32 to U+007E 	~ 	126
        - Latin-1 Supplement spans U+00A0 	  	160  to U+00FF 	ÿ 	255
        - Latin Extended-Apans U+0100 	Ā 	256 to U+017F 	ſ 	383
        - Latin Extended-B spans U+0180 ƀ 384 to U+024F ɏ 591
        - Latin Extended Additional spans U+1E00 	Ḁ to U+1EFF 	ỿ 
        - IPA Extensions spans U+0250 ɐ 	592  to U+02AF ʯ 687
        - Spacing modifier letters spans U+02B0 	ʰ 	688 to U+02FF 	˿ 	767 
        - Combining marks spans U+0300 	   ̀ 	768 to U+036F 	   ͯ 	879
        - Greek and Coptic spans U+0370 	Ͱ 	880 to U+03FF 	Ͽ 	1023
        - Greek Extended spans U+1F00 	ἀ to U+1FFE ῾
        - Cyrillic spans U+0400 	Ѐ to 
        [ long list of language specific variants]
        - Unicode symbols spans U+2013 	– to U+204A 	⁊
        - General Punctuation spans U+2000 to U+206F 
        - Currency Symbols spans U+20A0 	₠ to U+20C0 	⃀
        - Letterlike Symbols spans U+2100 	℀ to U+214F ⅏
        - Number Forms spans U+2150 	⅐ to U+218B ↋
        - Arrows spans U+2190 	← to U+21FF ⇿
        - Mathematical symbols spans U+2200 	∀ to U+22FF ⋿
        - Miscellaneous Technical spans U+2300 	⌀ to U+23FF ⏿
        - Enclosed Alphanumerics spans U+2460 	① 	to U+24FF ⓿
        - Box Drawing spans U+2500 	─ to U+257F ╿
        - Block Elements spans U+2580 	▀  to U+259F 	▟ 
        - Geometric Shapes spans U+25A0 	■  to U+25FF 	◿ 
        - Miscellaneous Symbols spans U+2600 	☀ to U+26FF ⛿
        - Dingbats spans U+2700 	✀  to U+27BF 	➿ 
        - Alchemical symbols spans U+1F700 	🜀 to U+1F77 
        - Domino Tiles spans U+1F030 	🀰 to U+1F093 🂓
        - Playing Cards spans U+1F0A0 	🂠  to U+1F0F5 🃵
        - Chess Symbols spans U+1FA00 to U+1FA6D

        # getting from U+nnnn to [char]"code"
        U+0034 is the code for digit 4
        to make it a usable character code, 
        [char]0x34
        - carve U+0 off the front, prefix it with 0x, then and type the resulting string as [char] 
        [char]0x34
        4
        - you can pad with zeros to accomodate longer hex
        [char]0x0034
        4

        Unicode code points appear as U+<codepoint>?
        For example, U+2202 represents the character ∂.


        U+2705 	✅ 	White heavy check mark 
        U+2709 	✉ 	Envelope 
        U+270A 	✊ 	Raised fist
        U+270B 	✋ 	Raised hand 
        U+270C 	✌ 	Victory hand
        U+270D 	✍ 	Writing hand 
        U+2713 	✓ 	Check mark
        U+2714 	✔ 	Heavy check mark
        U+2715 	✕ 	Multiplication X
        U+2716 	✖ 	Heavy multiplication X
        U+2717 	✗ 	Ballot X
        U+2718 	✘ 	Heavy ballot X 
        U+2726 	✦ 	Black four-pointed star
        U+2727 	✧ 	White four-pointed star
        U+2728 	✨ 	Sparkles
        U+2729 	✩ 	Stress outlined white star
        U+272A 	✪ 	Circled white star
        U+272B 	✫ 	Open center black star
        U+272C 	✬ 	Black center white star
        U+272D 	✭ 	Outlined black star
        U+272E 	✮ 	Heavy outlined black star
        U+272F 	✯ 	Pinwheel star
        U+2730 	✰ 	Shadowed white star 
        U+2744 	❄ 	Snowflake
        U+2745 	❅ 	Tight trifoliate snowflake
        U+2746 	❆ 	Heavy chevron snowflake 
        U+274C 	❌ 	Cross mark 
        U+274E 	❎ 	Negative squared cross mark 
        U+2753 	❓ 	Black question mark ornament
        U+2754 	❔ 	White question mark ornament
        U+2755 	❕ 	White exclamation mark ornament
        U+2757 	❗ 	Heavy exclamation mark symbol 
        U+2764 	❤ 	Heavy black heart 
        U+2776 	❶ 	Dingbat negative circled digit one
        U+2777 	❷ 	Dingbat negative circled digit two
        U+2778 	❸ 	Dingbat negative circled digit three
        U+2779 	❹ 	Dingbat negative circled digit four
        U+277A 	❺ 	Dingbat negative circled digit five
        U+277B 	❻ 	Dingbat negative circled digit six
        U+277C 	❼ 	Dingbat negative circled digit seven
        U+277D 	❽ 	Dingbat negative circled digit eight
        U+277E 	❾ 	Dingbat negative circled digit nine
        U+277F 	❿ 	Dingbat negative circled digit ten
        U+2780 	➀ 	Dingbat circled sans-serif digit one
        U+2781 	➁ 	Dingbat circled sans-serif digit two
        U+2782 	➂ 	Dingbat circled sans-serif digit three
        U+2783 	➃ 	Dingbat circled sans-serif digit four
        U+2784 	➄ 	Dingbat circled sans-serif digit five
        U+2785 	➅ 	Dingbat circled sans-serif digit six
        U+2786 	➆ 	Dingbat circled sans-serif digit seven
        U+2787 	➇ 	Dingbat circled sans-serif digit eight
        U+2788 	➈ 	Dingbat circled sans-serif digit nine
        U+2789 	➉ 	Dingbat circled sans-serif digit ten
        U+278A 	➊ 	Dingbat negative circled sans-serif digit one
        U+278B 	➋ 	Dingbat negative circled sans-serif digit two
        U+278C 	➌ 	Dingbat negative circled sans-serif digit three
        U+278D 	➍ 	Dingbat negative circled sans-serif digit four
        U+278E 	➎ 	Dingbat negative circled sans-serif digit five
        U+278F 	➏ 	Dingbat negative circled sans-serif digit six
        U+2790 	➐ 	Dingbat negative circled sans-serif digit seven
        U+2791 	➑ 	Dingbat negative circled sans-serif digit eight
        U+2792 	➒ 	Dingbat negative circled sans-serif digit nine
        U+2793 	➓ 	Dingbat negative circled sans-serif digit ten
        U+2794 	➔ 	Heavy wide-headed rightward arrow
        U+2795 	➕ 	Heavy plus sign
        U+2796 	➖ 	Heavy minus sign
        U+2797 	➗ 	Heavy division sign 
        U+279C 	➜ 	Heavy round-tipped rightward arrow
        U+279D 	➝ 	Triangle-headed rightward arrow
        U+279E 	➞ 	Heavy triangle-headed rightward arrow
        U+279F 	➟ 	Dashed triangle-headed rightward arrow
        U+27A0 	➠ 	Heavy dashed triangle-headed rightward arrow
        U+27A1 	➡ 	Black rightward arrow
        U+27A2 	➢ 	Three-D top-lighted rightward arrowhead
        U+27A3 	➣ 	Three-D bottom-lighted rightward arrowhead
        U+27A4 	➤ 	Black rightward arrowhead 
        U+2620 	☠ 	Skull & Crossbones
        U+2622 ☣ Ionizing radiation
        U+2623 ☣ Biological hazard 	
        U+26A1 ⚡︎ High voltage
        U+26CC ⛌ Accident
        U+2615 ☕ drink
        U+2639 ☹ frowny
        U+263A ☺ smiley
        U+263B ☻ dark smiley
        U+26B0 	⚰ coffin
        U+26BF ⚿ Parental Controls

    #     For showing all (or almost all) characters run the following code. The example gets 15.000 characters.
    # Showing Unicode 16-bit character
    for($i=0; $i-lt15000;$i++) {
        "Char $i : $([char]$i)"
    }
    # Want more fun? Get Emoji Characters …
    [char]::ConvertFromUtf32(0x1F4A9)
    [char]::ConvertFromUtf32(0x1F601)
    [Full Emoji List, v15.1](https://unicode.org/emoji/charts/full-emoji-list.html)
    - includes Code U+1F600 and samples (browser, gmail, CLDR shortname)
    - spans U+1F600 	😀 	😀 	😀 	grinning face to [ downloads a looong time, never completes, it's a lot of chars]

    Convert glyph to Unicode CodePoint
    $ThumbsUp = "👍" ; 
    $utf32bytes = [System.Text.Encoding]::UTF32.GetBytes( $ThumbsUp ) ; 
    $codePoint = [System.BitConverter]::ToUint32( $utf32bytes ) ; 
    "0x{0:X}" -f $codePoint ; 

    # [Unicode literals in PowerShell – mnaoumov.NET](https://mnaoumov.wordpress.com/2014/06/14/unicode-literals-in-powershell/)
    C# has three ways to declare Unicode literals.
    \x 
    \u 
    \U 
    # example
    char x1Upper = '\xA';
    char x2Lower = '\xab';
    char x3Upper = '\xABC';
    char x4Mixed = '\xaBcD';
    char uUpper = '\uABCD';
    char UMixed = '\U000abcD1';

    But none of Unicode literals are available in PowerShell

    \xnnnn and \unnnn literals can be expressed by a simple cast hex int to char.

    $x1Upper = [char] 0xA
    $x2Lower = [char] 0xab
    $x3Upper = [char] 0xABC
    $x4Mixed = [char] 0xaBcD
    $uUpper = [char] 0xABCD

    \Unnnnnnnn literals require a bit more sophisticated approach

    PS> $UMixed = [char]::ConvertFromUtf32(0x000abcD1) ; 

    The last approach is the most generic and works for all literals
    When we need to declare a string with Unicode characters inside it requires more complex syntax

    PS> $str = "xyz$([char] 0xA)klm$([char]::ConvertFromUtf32(0x000abc

    [Working with Unicode scripts, blocks and categories in Powershell](https://www.serverbrain.org/system-administration/working-with-unicode-scripts-blocks-and-categories-in-powershell.html)
    - The last version is 8.0 and defines a code space of 1,114,112 code points in the range 0 hex to 10FFFF hex:
    (10FFFF)base16 = (1114111)base10
    - Each code point is referred to by writing "U+" followed by its hexadecimal number, where U stands for Unicode. So U+10FFFF is the code point for the last code point in the database

    # How to convert a glyph to a unicode code point
    PS> $char = 'X' ; [int][char]$char ; 
    PS> $char = '✅' ; [int][char]$char ; # ✅ 

    # How to convert a unicode code point to a glyph
    PS> [int][Convert]::ToInt32('0058', 16) ; [Convert]::ToChar([int][Convert]::ToInt32('0058', 16)) ; 
    # a loop to convert all the four digits long hex values of the Basic Multilingual Plane to their corresponding glyphs.
    PS> '0058','0389','221A','0040','9999','0033' | % { [Convert]::ToChar([int][Convert]::ToInt32($_, 16)) }
    X
    Ή
    √
    @
    香
    3

    # simpler way to get the same result, which relies on the implicit conversion performed by the compiler when numbers are prefixed by '0x':
    PS> 0x0058, 0x389, 0x221a, 0x0040, 0x9999, 0x0033 | % { [char]$_ }

    .PARAMETER  Value
    Unicode H+nnnn Code Point Literal array (e.g. U+0021)
    .INPUTS
    System.string Accepts piped input.
    .OUTPUTS
    System.double
    .EXAMPLE
    PS> 'U+0021','U+0783','U+2752' | convert-UnicodeUPlusToCharCode ; 
    Demo converting a single quota property of an Exchange mailbox, from dehydrated string format to double in megabytes.
    .LINK
    https://www.serverbrain.org/system-administration/working-with-unicode-scripts-blocks-and-categories-in-powershell.html
    https://mnaoumov.wordpress.com/2014/06/14/unicode-literals-in-powershell/
    https://unicode.org/emoji/charts/full-emoji-list.html
    #>
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    ## PSV3+ whatif support:[CmdletBinding(SupportsShouldProcess)]
    ###[Alias('Alias','Alias2')]
    PARAM(
        #[Parameter(ValueFromPipeline=$true)] # this will cause params to match on matching type, [array] input -> [array]$param
        #[Parameter(ValueFromPipelineByPropertyName=$true)] # this will cause params to 
            # match on type, but *also* must have _same param name_ (must be an inbound property 
            # named 'arrayVariable' to match the -arrayVariable param, and it must be an 
            # [array] type, for the initial match 
        # -- if you use both Pipeline & ByPropertyName, you'll get mixed results. 
        # -> if it breaks, strip back to ValueFromPipeline and ensure you have type matching on inbound object and typed parameter.
        # see Trace-Command use below, for t-shooting
        #On type matches: ```[array]$arrayVariable``` param will be matched with 
          #  inbound pipeline [array] type data, (and other type-to-type matching).  including 
          #  typed array variants like: ```[string[]]$stringArrayVariable``` 
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="HELPMSG[-PARAM SAMPLEINPUT]")]
            [ValidateNotNullOrEmpty()]
            [ValidatePattern("^U\+[0-9A-F]+$")]
            #[Alias('ALIAS1', 'ALIAS2')]
            [string]$Value
    ) ;
    BEGIN { 
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            $smsg = "Data received from pipeline input: '$($InputObject)'" ;
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } else {
            # doesn't actually return an obj in the echo
            #$smsg = "Data received from parameter input: '$($InputObject)'" ;
            #if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            #else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } ;
    }
    PROCESS{
        foreach($item in $value) {
            # works
            # [int][convert]::ToInt32('2752',16) ; [convert]::ToChar([int][convert]::ToInt32('2752',16))
            # $ucode.replace('0x','')

            $oReport = [ordered]@{
                CodePoint = $item ; 
                Hex = $null ; 
                Decimal = $null ; 
                DecimalToChar = $null ; 
                CodePointToChar = $null ; 
                Character = $null ; 
            } ; 
            #$inUPlus = $_ ; 
            $ucode = $item -replace 'U\+','0x' ; 
            $oReport.Hex = $ucode ; 
            #write-host "`n`n$item converted to Hex: $($ucode)" ; 
            #$deci = [int][convert]::ToInt32($ucode.replace('0x',''),16)  ; 
            $oReport.Decimal = [int][convert]::ToInt32($ucode.replace('0x',''),16) ; 
            $oReport.DecimalToChar = "[convert]::ToChar($($oReport.Decimal))" ; 
            $oReport.CodePointToChar = "[char]$($ucode)" ; 
            #write-host "$item converted to [int32]$($deci)" ; 
            #write-host "output as char: [convert]::ToChar($deci)`n or via [char]$($ucode)" ; 
            #[convert]::ToChar($deci) ; 
            $oReport.Character = [convert]::ToChar($($oReport.Decimal)) ; 
            [pscustomobject]$oReport | write-output ; 
        } ; 
    } ; 
}

#*------^ convert-UnicodeUPlusToCharCode.ps1 ^------


#*------v Get-CharInfo.ps1 v------
function Get-CharInfo {
    <#
    .SYNOPSIS
    Get-CharInfo.ps1 - Return basic information about supplied Unicode characters.
    .NOTES
    Version     : 0.0.
    Author      : JosefZ
    Website     : https://stackoverflow.com/users/3439404/josefz
    Twitter     : 
    CreatedDate : 2024-
    FileName    : Get-CharInfo.ps1
    License     : CC0 https://creativecommons.org/publicdomain/zero/1.0/legalcode
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell
    AddedCredit      : Todd Kadrie
    AddedWebsite     : http://www.toddomation.com
    AddedTwitter     : @tostka / http://twitter.com/tostka
    REVISIONS
    2:25 PM 6/21/2024 updated CBH, moved the type load into BEGIN{} of function (from outside of func)
        Improved by: https://stackoverflow.com/users/3439404/josefz
                    (to version 2)
    .DESCRIPTION
    Get-CharInfo.ps1 - Return basic information about supplied Unicode characters.

    Return information about supplied Unicode characters:
        - as a PSCustomObject for programming purposes,
        - in a human-readable form, and
        - with optional additional output to the Information Stream.

    Properties of the output PSCustomObject are as follows:

    Char        The character itself (if renderable)
    CodePoint   [string[]]Unicode CodePoint, its UTF-8 byte sequence
    Category    General Category (long name or abbreviation)
    Description Name (and surrogate pair in parentheses if apply).

    The UnicodeData.txt file (if used) must be saved locally
    from https://www.unicode.org/Public/UNIDATA/UnicodeData.txt
    (currently Unicode 13.0.0)

    The UnicodeData.txt file is not required however, in such case,
    Get-CharInfo function could be return inaccurate properties
    Category and Description for characters above BMP, see Example-3.
    HISTORY NOTES

    Origin by: http://poshcode.org/5234
                http://fossil.include-once.org/poshcode/artifact/5757dbbd0bc26c84333e7cf4ccc330ab89447bf679e86ddd6fbd3589ca24027e

    .PARAMETER  PARAMNAME

    .PARAMETER  PARAMNAME2

    .PARAMETER Ticket
    Ticket number[-ticket 123456]
    .PARAMETER Path
    Path [-path c:\path-to\]
    .PARAMETER File
    File [-file c:\path-to\file.ext]
    .PARAMETER TargetMailboxes
    HelpMessage="Mailbox email addresses(array)[-Targetmailboxes]
    .PARAMETER ResultSize
    Integer maximum number of results to request (for shortened debugging passes)
    .PARAMETER TenOrg
    Tenant Tag (3-letter abbrebiation)[-TenOrg 'XYZ']
    .PARAMETER Credential
    Use specific Credentials (defaults to Tenant-defined SvcAccount)[-Credentials [credential object]]
    .PARAMETER UserRole
    Credential User Role spec (SID|CSID|UID|B2BI|CSVC|ESVC|LSVC|ESvcCBA|CSvcCBA|SIDCBA)[-UserRole @('SIDCBA','SID','CSVC')]
    .PARAMETER useEXOv2
    Use EXOv2 (ExchangeOnlineManagement) over basic auth legacy connection [-useEXOv2]
    .PARAMETER Silent
    Switch to specify suppression of all but warn/error echos.(unimplemented, here for cross-compat)
    .PARAMETER showDebug
    Debugging Flag [-showDebug]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .INPUTS
    An array of characters, strings and numbers (in any combination)
    can be piped to the function as parameter $InputObject, e.g as
    "ΧАB",[char]4301,191,0x1F3DE | Get-CharInfo
    or (the same in terms of decimal numbers) as
    935,1040,66,4301,191,127966 | Get-CharInfo

    On the other side, the $InputObject parameter supplied named
    or positionally must be of the only base type: either a number
    or a character or a string.
    The same input as a string:
    Get-CharInfo -InputObject 'ΧАBჍ¿🏞'

    -Verbose implies all -OutUni, -OutHex and -OutStr

    .OUTPUTS
    [System.Management.Automation.PSCustomObject]
    [Object[]]    (an array like [PSCustomObject[]])
    .EXAMPLE
    # full (first three lines are in the Information Stream)
    'r Ř👍'|Get-CharInfo -OutUni -OutHex -OutStr -IgnoreWhiteSpace

    r Ř👍
    0x0072,0x0020,0x0158,0x0001F44D
    \u0072\u0020\u0158\U0001F44D
        Char CodePoint                             Category Description                
        ---- ---------                             -------- -----------                
        r {U+0072, 0x72}                 LowercaseLetter Latin Small Letter R       
        Ř {U+0158, 0xC5,0x98}            UppercaseLetter Latin Capital Letter R W...
        👍 {U+1F44D, 0xF0,0x9F,0x91,0x8D}              So THUMBS UP SIGN (0xd83d,0...


    .EXAMPLE
    # shortened version of above (output is the same)
    'r Ř👍'|chr -Verbose -IgnoreWhiteSpace

    .EXAMPLE
    # inaccurate (inexact) output above BMP if missing UnicodeData.txt
    'r Ř👍'|chr -Verbose -IgnoreWhiteSpace -UnicodeData .\foo.bar

    r Ř👍
    0x0072,0x0020,0x0158,0x0001F44D
    \u0072\u0020\u0158\U0001F44D
        Char CodePoint                             Category Description                
        ---- ---------                             -------- -----------                
        r {U+0072, 0x72}                 LowercaseLetter Latin Small Letter R       
        Ř {U+0158, 0xC5,0x98}            UppercaseLetter Latin Capital Letter R W...
        👍 {U+1F44D, 0xF0,0x9F,0x91,0x8D}     OtherSymbol ??? (0xd83d,0xdc4d)        

    .LINK
    https://stackoverflow.com/questions/65748858/how-to-display-unicode-character-names-and-their-hexadecimal-codes-with-powershe
    .LINK
    Unicode® Standard Annex #44: Unicode Character Database (UCD)
    .LINK
    https://www.unicode.org/reports/tr44/
    .LINK
    https://www.unicode.org/reports/tr44/#General_Category_Values
    .LINK
    https://github.com/tostka/verb-text
    .FUNCTIONALITY
    Tested: Windows 8.1/64bit, Powershell 4
            Windows 10 /64bit, Powershell 5
            Windows 10 /64bit, Powershell Core 6.2.0
            Windows 10 /64bit, Powershell Core 7.1.0
    #>
    [CmdletBinding()]
    [Alias('chr')]
    [OutputType([System.Management.Automation.PSCustomObject],
                [System.Array])]
    PARAM(
        # named or positional: a string or a number e.g. 'r Ř👍'
        # pipeline: an array of strings and numbers, e.g 'r Ř',0x1f44d
        [Parameter(Position=0, Mandatory, ValueFromPipeline,HelpMessage="a string or a number['r Ř👍']")]
            $InputObject,
        # + Write-Host Python-like Unicode literal e.g. \u0072\u0020\u0158\U0001F44D
        [Parameter(HelpMessage="Switch to output Python-like Unicode literal e.g. \u0072\u0020\u0158\U0001F44D")]
            [switch]$OutUni,
        # + Write-Host array of hexadecimals e.g. 0x0072,0x0020,0x0158,0x0001F44D
        [Parameter(HelpMessage="Switch to output array of hexadecimals e.g. 0x0072,0x0020,0x0158,0x0001F44D")]
            [switch]$OutHex,
        # + Write-Host concatenated string e.g. r Ř👍
        [Parameter(HelpMessage="Switch to output concatenated string e.g. r Ř👍")]
            [switch]$OutStr,
        # choke down whitespaces ( $s -match '\s' ) from output
        [Parameter(HelpMessage="Switch to choke down whitespaces ( `$s -match '\s' ) from output")]
            [switch]$IgnoreWhiteSpace,
        # from https://www.unicode.org/Public/UNIDATA/UnicodeData.txt
        [Parameter(HelpMessage="Optional Path to local downloaded copy of https://www.unicode.org/Public/UNIDATA/UnicodeData.txt (improves info accuracy)[-UnicodeData c:\pathto\UnicodeData.txt")]
            [string]$UnicodeData = 'c:\usr\work\ps\scripts\CodePages\UnicodeData.txt'
    )
    BEGIN {
        if ( -not ('Microsofts.CharMap.UName' -as [type]) ) {
          Add-Type -Name UName -Namespace Microsofts.CharMap -MemberDefinition $(
            switch ("$([System.Environment]::SystemDirectory -replace 
                        '\\', '\\')\\getuname.dll") {
            {Test-Path -LiteralPath $_ -PathType Leaf} {@"
[DllImport("${_}", ExactSpelling=true, SetLastError=true)]
private static extern int GetUName(ushort wCharCode, 
    [MarshalAs(UnmanagedType.LPWStr)] System.Text.StringBuilder buf);

public static string Get(char ch) {
    var sb = new System.Text.StringBuilder(300);
    UName.GetUName(ch, sb);
    return sb.ToString();
}
"@
            }
            default {'public static string Get(char ch) { return "???"; }'}
            })
        }    
        Set-StrictMode -Version latest
        if ( [string]::IsNullOrEmpty( $UnicodeData) ) { $UnicodeData = '::' }
        Function ReadUnicodeRanges {
            if ($Script:UnicodeFirstLast.Count -eq 0) {
                $Script:UnicodeFirstLast = @'
                    First,Last,Category,Description
                    128,128,Cc-Control,Padding Character
                    129,129,Cc-Control,High Octet Preset
                    132,132,Cc-Control,Index
                    153,153,Cc-Control,Single Graphic Character Introducer
                    13312,19903,Lo-Other_Letter,CJK Ideograph Extension A
                    19968,40956,Lo-Other_Letter,CJK Ideograph
                    44032,55203,Lo-Other_Letter,Hangul Syllable
                    94208,100343,Lo-Other_Letter,Tangut Ideograph
                    1016.2.301640,Lo-Other_Letter,Tangut Ideograph Supplement
                    131072,173789,Lo-Other_Letter,CJK Ideograph Extension B
                    173824,177972,Lo-Other_Letter,CJK Ideograph Extension C
                    177984,178205,Lo-Other_Letter,CJK Ideograph Extension D
                    178208,183969,Lo-Other_Letter,CJK Ideograph Extension E
                    183984,191456,Lo-Other_Letter,CJK Ideograph Extension F
                    196608,201546,Lo-Other_Letter,CJK Ideograph Extension G
                    983040,1048573,Co-Private_Use,Plane 15 Private Use
                    1048576,1114109,Co-Private_Use,Plane 16 Private Use
'@ | ConvertFrom-Csv -Delimiter ',' |
                ForEach-Object {
                    [PSCustomObject]@{
                        First      = [int]$_.First
                        Last       = [int]$_.Last
                        Category   = $_.Category
                        Description= $_.Description
                    }
                }
            }
            foreach ( $FirstLast in $Script:UnicodeFirstLast) {
                if ( $FirstLast.First -le $ch -and $ch -le $FirstLast.Last ) {
                    $out.Category = $FirstLast.Category
                    $out.Description = $FirstLast.Description + $nil
                    break
                }
            }
        }
        $AuxHex = [System.Collections.ArrayList]::new()
        $AuxStr = [System.Collections.ArrayList]::new()
        $AuxUni = [System.Collections.ArrayList]::new()
        $Script:UnicodeFirstLast = @()
        $Script:UnicodeDataLines = @()
        function ReadUnicodeData {
            if ( $Script:UnicodeDataLines.Count -eq 0 -and (Test-Path $UnicodeData) ) {
                 $Script:UnicodeDataLines = @([System.IO.File]::ReadAllLines(
                        $UnicodeData, [System.Text.Encoding]::UTF8))
            }
            $DescrLine = $Script:UnicodeDataLines -match ('^{0:X4}\;' -f $ch)
            if ( $DescrLine.Count -gt 0) {
                $u0, $Descr, $Categ, $u3 = $DescrLine[0] -split ';'
                $out.Category = $Categ
                $out.Description = $Descr + $nil
            }
        }
        function out {
            param(
                [Parameter(Position=0, Mandatory=$true )] $ch,
                [Parameter(Position=1, Mandatory=$false)]$nil=''
                 )
            if (0 -le $ch -and 0xFFFF -ge $ch) {
                [void]$AuxHex.Add('0x{0:X4}' -f $ch)
                $s = [char]$ch
                [void]$AuxStr.Add($s)
                [void]$AuxUni.Add('\u{0:X4}' -f $ch)
                $out = [pscustomobject]@{
                    Char      = $s
                    CodePoint = ('U+{0:X4}' -f $ch),
                        (([System.Text.UTF32Encoding]::UTF8.GetBytes($s) |
                            ForEach-Object { '0x{0:X2}' -f $_ }) -join ',')
                    Category  = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch)
                    Description = [Microsofts.CharMap.UName]::Get($ch)
                }
                if ( $out.Description -eq 'Undefined' ) { ReadUnicodeRanges }
                if ( $out.Description -eq 'Undefined' ) { ReadUnicodeData }
            } elseif (0x10000 -le $ch -and 0x10FFFF -ge $ch) {
                [void]$AuxHex.Add('0x{0:X8}' -f $ch)
                $s = [char]::ConvertFromUtf32($ch)
                [void]$AuxStr.Add($s)
                [void]$AuxUni.Add('\U{0:X8}' -f $ch)
                $out = [pscustomobject]@{
                    Char        = $s
                    CodePoint   = ('U+{0:X}' -f $ch),
                        (([System.Text.UTF32Encoding]::UTF8.GetBytes($s) |
                            ForEach-Object { '0x{0:X2}' -f $_ }) -join ',')
                    Category    = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($s, 0)
                    Description = '???' + $nil
                }
                ReadUnicodeRanges 
                if ( $out.Description -eq ('???' + $nil) ) { ReadUnicodeData }
            } else {
                Write-Warning ('Character U+{0:X4} is out of range' -f $ch)
                $s = $null
            }
            if (( $null -eq $s ) -or
                ( $IgnoreWhiteSpace.IsPresent -and ( $s -match '\s' ))
               ) {
            } else {
                $out
            }
        }
    }
    PROCESS {
        #if ($PSBoundParameters['Verbose']) {
        #    Write-Warning "InputObject $InputObject, type = $($InputObject.GetType().Name)"
        #}
        if ( ($InputObject -as [int]) -gt 0xFFFF -and 
             ($InputObject -as [int]) -le 0x10ffff ) {
            $InputObject = [string][char]::ConvertFromUtf32($InputObject)
        }
        if ($null -cne ($InputObject -as [char])) {
            #Write-Verbose "A $([char]$InputObject) InputObject character"
            out $([int][char]$InputObject) ''
        } elseif (  $InputObject -isnot [string] -and 
                    $null -cne ($InputObject -as [int])) {
            #Write-Verbose "B $InputObject InputObject"
            out $([int]$InputObject) ''
        } else {
            $InputObject = [string]$InputObject
            #Write-Verbose "C $InputObject InputObject.Length $($InputObject.Length)"
            for ($i = 0; $i -lt $InputObject.Length; ++$i) {
                if (  [char]::IsHighSurrogate($InputObject[$i]) -and 
                      (1+$i) -lt $InputObject.Length -and 
                      [char]::IsLowSurrogate($InputObject[$i+1])) {
                    $aux = ' (0x{0:x4},0x{1:x4})' -f [int]$InputObject[$i], 
                                                   [int]$InputObject[$i+1]
                    # Write-Verbose "surrogate pair $aux at position $i" 
                    out $([char]::ConvertToUtf32($InputObject[$i], $InputObject[1+$i])) $aux
                    $i++
                } else {
                    out $([int][char]$InputObject[$i]) ''
                }
            }
        }
    }
    END {
        if ( $OutStr.IsPresent -or $PSBoundParameters['Verbose']) {
            Write-Host -ForegroundColor Magenta -Object $($AuxStr -join '')
        }
        if ( $OutHex.IsPresent -or $PSBoundParameters['Verbose']) {
            Write-Host -ForegroundColor Cyan -Object $($AuxHex -join ',')
        }
        if ( $OutUni.IsPresent -or $PSBoundParameters['Verbose']) {
            Write-Host -ForegroundColor Yellow -Object $($AuxUni -join '')
        }
    }

}

#*------^ Get-CharInfo.ps1 ^------


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
        * 2:22 PM 8/21/2024 add: alias: convertto-StringHash
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
        [Alias('convertto-StringHash')]
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


#*------v new-LoremString.ps1 v------
function new-LoremString {
    <#
    .SYNOPSIS
    new-LoremString - Creates a new Lorem Ipsum string with the specified characteristics. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2016-04-04
    FileName    : new-LoremString.ps1
    License     : (Non asserted)
    Copyright   : (Non asserted)
    Github      : https://github.com/tostka/verb-TEXT
    Tags        : Powershell
    AddedCredit : Adam Driscoll
    AddedWebsite: https://www.powershellgallery.com/packages/LoremIpsum/1.0
    AddedTwitter: @adamdriscoll
    REVISIONS
    * 4:19 PM 9/11/2024 added trim() to wrap-text outputs (tends to have a leading space)
    * 1:25 PM 6/1/2023 fixed param $AltLexicon; wrapped in @() forced array.
    * 12:47 PM 5/4/2023 Took AD's basic idea (stringbuilder assembly on looping 
        array), and reworked the logic, primarily to require less inputs to get 
        any output; defaulted some params, coereced others around inputs, expanded 
        CBH, filled out param specs, added trailing explicit write-output; added 
        verbose outputs; dbl CR between paras; Capped 1st char of ea Sentance; 
        added -AltLexicon & -NoLorem params; range of extra CBH examples.
    * 4/4/16 AD's posted PSG vers 1.0 
    .DESCRIPTION
    new-LoremString - Creates a new Lorem Ipsum string with the specified characteristics. 
    
    By default, without parameters, outputs a six-word random Lorem-based sentance.

    The -AltLexicon parameter is prestocked with 100 words from Google's [100 Random Words - This Site Is Totally Random - Google Sites](https://sites.google.com/site/thissiteistotallyrandom/100-random-words)
    and are used as the word source with the -NoLorem parameter. 
    This parameter can also be specified on the command line with a custom string array of other words.

    .PARAMETER minWords
    Min number of words to be returned (defaults to 6)[-minwords 5]
    .PARAMETER maxWords
    Max number of words to be returned[-maxwords 7]
    .PARAMETER minSentences
    Min number of sentances to be returned(defaults to 1)[-minSentences 1]
    .PARAMETER maxSentences
    Max number of sentances to be returned[-maxSentences 3]
    .PARAMETER numParagraphs
    Number of paragraphs to be returned(defaults to 1)[-numParagraphs 2]
    .PARAMETER NoLorem
    Switch to use non-Lorem-based words (random 100 words)[-NoLorem]
    .PARAMETER AltLexicon
    String array of random words to use with -NoLorem switch (prepopulated with 100 random words from https://sites.google.com/site/thissiteistotallyrandom/100-random-words)[-AltLexicon 'word1','word2']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> new-loremstring -minWords 12 ;

        Dolore erat elit diam nonummy dolore ipsum laoreet elit diam laoreet tincidunt. 

    Output a single 12 word sentance. 
    .EXAMPLE
    PS> new-loremstring -minWords 15 -NoLorem ;

        Prison juice moon frog computer flying hyperlink element cords mediocre moon zebra home cords final. 

    Output a single 15 word sentance using the alt non-Lorem-text-based word list
    
    .EXAMPLE
    PS> new-loremstring -minWords 4 -maxWords 8 -minSentences 3 -maxSentences 5 -numParagraphs 2 ; 

        Elit consectetuer elit magna. Euismod ut consectetuer ut. Sit elit elit ut. 

        Elit aliquam ut elit. Erat tincidunt nibh euismod. Elit nibh nibh nibh. 

    Generate two random paragraphs of 3-5 sentances with 4-8 word each.
    .EXAMPLE
    PS> (new-loremstring -minWords 4 -maxWords 13 -minSentences 3 -maxSentences 12 -numParagraphs 2 | wrap-text -Characters 80).trim() ;

        Ut erat magna dolor amet magna ipsum erat. Nonummy laoreet nonummy diam erat
        lorem ipsum adipiscing. Ut nibh amet sed euismod magna diam nibh. Ut euismod
        elit laoreet adipiscing dolor ipsum aliquam. Ipsum dolor elit euismod diam
        adipiscing ut dolor. Laoreet laoreet diam aliquam euismod sit nibh laoreet.
        Laoreet sit euismod tincidunt dolore dolor amet dolor. 

        Diam ut laoreet dolor
        sit nonummy tincidunt tincidunt. Nonummy sed laoreet ut aliquam magna diam nibh.
        Sit aliquam magna ipsum euismod erat nibh aliquam. Dolore consectetuer tincidunt
        dolore dolore elit ut elit. Sit elit euismod erat nibh dolore ipsum dolore. Ut
        sit tincidunt ipsum nibh sed dolore ut. Lorem diam aliquam dolor ipsum ipsum sit
        amet. 

    Longer example piped through my verb-Text:wrap-text() to produce wrapped text output:
    .EXAMPLE
    PS> (new-loremstring -minWords 6).replace(' ','').substring(0,15) ; 
        
        Elitnonummyelit

    Demo generation of a 16-character semi-random lorem-based string, with all spaces removed (for dummy values & inputs).
    .EXAMPLE
    PS> ((new-loremstring -minWords 6) | convertto-titlecase).replace(' ','').substring(0,15)

        LaoreetIpsumDol

    Variant demo that uses my verb-text:convertto-TitleCase to titlecase each word before removing spaces, and truncating to 16 characters.
    .EXAMPLE
    $block = @() ; 
    $block = new-loremstring -minwords 6 | convertto-titlecase ; 
    $block += "`n`r" ; 
    $block += new-loremstring -minWords 4 -maxWords 13 -minSentences 3 -maxSentences 12 -numParagraphs 2 ;
    ($block | wrap-text -char 80).trim() ; 
    Demo building a mixed case 'post' with title of dummy text, word wrapped. Uses my verb-Text module convertTo-Titlecase. 
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage="Min number of words to be returned (defaults to 6)[-minwords 5]")]
            [int]$minWords = 6, 
        [Parameter(HelpMessage="Max number of words to be returned[-maxwords 7]")]
            [int]$maxWords, 
        [Parameter(HelpMessage="Min number of sentances to be returned(defaults to 1)[-minSentences 1]")]
            [int]$minSentences = 1, 
        [Parameter(HelpMessage="Max number of sentances to be returned[-maxSentences 3]")]
            [int]$maxSentences, 
        [Parameter(HelpMessage="Number of paragraphs to be returned(defaults to 1)[-numParagraphs 2]")]
            [int]$numParagraphs = 1,
        [Parameter(HelpMessage="Switch to use non-Lorem-based words (random 100 words)[-NoLorem]")]
            [switch]$NoLorem, 
        [Parameter(HelpMessage="String Array of random words to use with -NoLorem switch (prepopulated with 100 random words from https://sites.google.com/site/thissiteistotallyrandom/100-random-words)[-AltLexicon 'word1','word2']")]
            [string[]]$AltLexicon = @('sausage','blubber','pencil','cloud','moon','water','computer','school','network','hammer','walking','violently','mediocre','literature','chair','two','window','cords','musical','zebra','xylophone','penguin','home','dog','final','ink','teacher','fun','website','banana','uncle','softly','mega','ten','awesome','attatch','blue','internet','bottle','tight','zone','tomato','prison','hydro','cleaning','telivision','send','frog','cup','book','zooming','falling','evily','gamer','lid','juice','moniter','captain','bonding','loudly','thudding','guitar','shaving','hair','soccer','water','racket','table','late','media','desktop','flipper','club','flying','smooth','monster','purple','guardian','bold','hyperlink','presentation','world','national','comment','element','magic','lion','sand','crust','toast','jam','hunter','forest','foraging','silently','tawesomated','joshing','pong')
    ) ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;

    $lex = "lorem;ipsum;dolor;sit;amet;consectetuer;adipiscing;elit;sed;diam;nonummy;nibh;euismod;tincidunt;ut;laoreet;dolore;magna;aliquam;erat".split(';') ;
    # seed this with a fresh random list from: https://sites.google.com/site/thissiteistotallyrandom/100-random-words

    if(-not $NoLorem){ $words = $lex } 
    else {
        write-host "(using non-Lorum 100-word seed list)" ; 
        $words = $AltLexicon ;
    } ; 

    if (($minWords -AND ($maxWords -gt 0)) -AND ($minWords -gt $maxWords)){
        throw "MinWords cannot be greater than MaxWords." ; 
    }
    if (($minSentences -AND ($maxSentences -gt 0)) -AND ($minSentences -gt $maxSentences)){
        throw "MinSentences cannot be greater than MaxSentences." ; 
    }

    if($minWords -gt 0 -AND $maxWords -eq 0){
        $numWords = $minWords
    } elseif($minWords -gt 0 -AND ($maxWords -gt 0)) {    
        $pltGRWord = @{
            Minimum = $minWords ; 
            Maximum = $maxWords
        } ; 
    } ;
    if($minSentences -gt 0 -AND $maxSentences -eq 0){
        $numSentences = $minSentences  ; 
    } elseif($minSentences -gt 0 -AND ($maxSentences -gt 0)) {    
        $pltGRSent = @{
            Minimum = $minSentences ; 
            Maximum = $maxSentences
        } ; 
    } ; 
    
    if($numWords -eq $null -and ( ($pltGRWord.keys).count -ge 2)){
        write-verbose "get-Random [words] w`n$(($pltGRWord|out-string).trim())" ; 
        $numWords = Get-Random @pltGRWord ; 
    } ; 
    
    if($numSentences -eq $null -and ( ($pltGRSent.keys).count -ge 2)){
        write-verbose "get-Random [sentances] w`n$(($pltGRSent|out-string).trim())" ; 
        $numSentences = Get-Random @pltGRSent ; 
    } ; 
    
    $smsg = "numWords:$($numWords)" ; 
    $smsg += "`nnumSentences:$($numSentences)" ; 
    $smsg += "`nnumParagraphs:$($numParagraphs)" ; 
    write-verbose $smsg ; 

    $result = New-Object System.Text.StringBuilder ; 
    for($p = 0; $p -lt $numParagraphs; $p++) {
        for($s = 0; $s -lt $numSentences; $s++) {
            for($w = 0; $w -lt $numWords; $w++) {
                if ($w -gt 0) { $result.Append(" ") | Out-Null }
                if($w -eq 0){
                    $word = $words[(Get-Random -Minimum 0 -Maximum $words.Length)]
                    $result.Append( $word.substring(0,1).toupper() + $word.substring(1).tolower() ) | Out-Null ;
                } else { 
                    $result.Append($words[(Get-Random -Minimum 0 -Maximum $words.Length)]) | Out-Null ; 
                } ; 
            } ; 
            $result.Append(". ") | Out-Null ; 
        } ; 
        $result.Append("`r`n`r`n") | Out-Null ; 
    } ; 
    $result.ToString() | write-output ; 
}

#*------^ new-LoremString.ps1 ^------


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

Export-ModuleMember -Function compare-CodeRevision,convert-CaesarCipher,_encode,_decode,Convert-CodePointToPSSyntaxTDO,convertFrom-Base64String,convert-HtmlCodeToTextTDO,Convert-invertCase,convert-Rot13,convert-Rot47,convertto-AcronymFromCaps,convertTo-Base64String,convertto-Base64StringCommaQuoted,ConvertTo-CamelCase,ConvertTo-L33t,ConvertTo-lowerCamelCase,convertTo-PSHelpExample,convertTo-QuotedList,ConvertTo-SCase,ConvertTo-SNAKE_CASE,convertto-StringCommaQuote,ConvertTo-StringQuoted,convertTo-StringReverse,convertTo-StUdlycaPs,convertTo-TitleCase,convertTo-UnWrappedText,convertTo-WordsReverse,convertTo-WrappedText,convert-UnicodeUPlusToCharCode,Get-CharInfo,ReadUnicodeRanges,ReadUnicodeData,out,get-StringHash,new-LoremString,Remove-StringDiacritic,Remove-StringLatinCharacters,Test-IsGuid,test-IsNumeric,test-IsRegexPattern,test-IsRegexValid,test-IsUri -Alias *




# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnU7tJIGpx3hZi5f2YNyS8EMj
# YoygggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSWkJmg
# 6X3W6TP6obgNy9W20bhTtDANBgkqhkiG9w0BAQEFAASBgALcHve8fkTunF18ByNL
# wIUQB+jvV42/K/IrmDduJiMIulH5w0omglgeMJZD1wxLet7arG4QJ+W/q0t4721c
# RycFIZ6RtnKsbi3R05tsGI9SgbRFi8Jp4dp+tveRuHnvJ0nVxSx8Lz5scao8I8Xr
# xhOrfQAHKgqGAfdNF/g9OOJF
# SIG # End signature block
