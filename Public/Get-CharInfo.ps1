# Get-CharInfo.ps1

#*------v Function Get-CharInfo  v------
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
                    101632,101640,Lo-Other_Letter,Tangut Ideograph Supplement
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

} ; 
#*------^ END Function Get-CharInfo  ^------