# new-LoremString.ps1

function new-LoremString {
    <#
    .SYNOPSIS
    new-LoremString - Creates a new Lorem Ipsum string with the specified characteristics. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-
    FileName    : new-LoremString.ps1
    License     : (Non asserted)
    Copyright   : (Non asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Adam Driscoll
    AddedWebsite: https://www.powershellgallery.com/packages/LoremIpsum/1.0
    AddedTwitter: URL
    REVISIONS
    * 12:47 PM 5/4/2023 Took AD's basic idea (stringbuilder assembly on looping 
        array), and reworked the logic a bit, primarily to require less inputs to get 
        any output; defaulted some params (to output a default 6-word phrase), expanded 
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
    Min number of words to be returned[-minwords 5]
    .PARAMETER .PARAMETER maxWords
    Max number of words to be returned[-maxwords 7]
    .PARAMETER minSentences
    Min number of sentances to be returned[-minSentences 1]
    .PARAMETER maxSentences
    Max number of sentances to be returned[-maxSentences 3]
    .PARAMETER numParagraphs
    Number of paragraphs to be returned[-numParagraphs 2]
    .PARAMETER NoLorem
    Switch to use non-Lorem-based words (random 100 words)[-NoLorem]
    .PARAMETER AltLexicon
    String Array of random words to use with -NoLorem switch (prepopulated with 100 random words from https://sites.google.com/site/thissiteistotallyrandom/100-random-words)[-AltLexicon 'word1','word2']
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
    PS> $ret = new-loremstring -minWords 4 -maxWords 13 -minSentences 3 -maxSentences 12 -numParagraphs 2 ; 
    PS> $ret | wrap-text -Characters 80 ; 

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
    $block | wrap-text -char 80 ; 
    Demo building a mixed case 'post' with title of dummy text, word wrapped.
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage="Min number of words to be returned (defaults to 6, the base phrase)[-minwords 5]")]
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
            [string[]]$AltLexicon = 'sausage','blubber','pencil','cloud','moon','water','computer','school','network','hammer','walking','violently','mediocre','literature','chair','two','window','cords','musical','zebra','xylophone','penguin','home','dog','final','ink','teacher','fun','website','banana','uncle','softly','mega','ten','awesome','attatch','blue','internet','bottle','tight','zone','tomato','prison','hydro','cleaning','telivision','send','frog','cup','book','zooming','falling','evily','gamer','lid','juice','moniter','captain','bonding','loudly','thudding','guitar','shaving','hair','soccer','water','racket','table','late','media','desktop','flipper','club','flying','smooth','monster','purple','guardian','bold','hyperlink','presentation','world','national','comment','element','magic','lion','sand','crust','toast','jam','hunter','forest','foraging','silently','tawesomated','joshing','pong'
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
} ; 
