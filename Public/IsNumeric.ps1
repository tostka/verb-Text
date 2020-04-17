#*------v Function IsNumeric v------
Function IsNumeric {
    <#
    .SYNOPSIS
    IsNumeric.ps1 - Test a given value is numeric
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : IsNumeric.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS
    * 8:27 PM 5/23/2014
    .DESCRIPTION
    IsNumeric.ps1 - Test a given value is numeric
    .PARAMETER Value
    Value to be evaluated
    .EXAMPLE
    $value="Win";IsNumeric($value);
    Test whether the string 'Win' is numeric (returns False)
    .EXAMPLE
    $value="80";IsNumeric($value);
    Test whether the string '80' is numeric (returns True)
    .LINK
    #>
    param($value)
    ($($value.Trim()) -match "^[-+]?([0-9]*\.[0-9]+|[0-9]+\.?)$") | write-output ; 
} ; #*------^ END Function IsNumeric ^------
