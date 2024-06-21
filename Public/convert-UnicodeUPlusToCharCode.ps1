# convert-UnicodeUPlusToCharCode.ps1

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
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Unicode,Type,Fonts,Conversion
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
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
