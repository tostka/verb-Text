#*------v Function test-IsNumeric v------
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
} ; #*------^ END Function test-IsNumeric ^------
