#*------v Function convertTo-WordsReverse v------
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
            $l = $psitem -replace $rgxNonText,'' ;
        } else {
            $l = $psitem ; 
        } ; 
        [boolean]$hasPeriod = $false ; 
        write-verbose $PSItem ; 
        if($l -match '\.$'){
            $hashPeriod = $true ;
            $l = [regex]::match($l,'(.*)\.').captures[0].groups[1].value ;
        } else { 
            #$l = $PsItem 
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
    
} ; #*------^ END Function convertTo-WordsReverse ^------
