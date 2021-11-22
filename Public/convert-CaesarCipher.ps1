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