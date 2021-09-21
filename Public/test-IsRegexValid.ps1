#*------v Function test-IsRegexValid v------
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
} ; #*------^ END Function test-IsRegexValid ^------
