#*------v Function test-IsRegexPattern v------
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
} ; #*------^ END Function test-IsRegexPattern ^------
