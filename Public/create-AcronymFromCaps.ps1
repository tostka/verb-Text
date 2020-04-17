#*------v Function create-AcronymFromCaps()  v------
Function create-AcronymFromCaps {
<#
    .SYNOPSIS
    create-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    12:14 PM 2/16/2016 - working
    8:58 AM 2/16/2016 - initial version
    .DESCRIPTION
    create-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    .PARAMETER  String
    String to be convered to a 'Capital Acrynym'
    .INPUTS
    None
    .OUTPUTS
    System.String
    .EXAMPLE
    create-AcronymFromCaps "get-AdGroupMembersRecurseManual" ;
    Create an Capital-letter Acroynm for the specified string
    .EXAMPLE
    $fn=".\$(create-AcronymFromCaps $scriptNameNoExt)-$(get-date -uformat '%Y%m%d-%H%M').csv" ;
    Create a filename based off of an Acronym from the capital letters in the ScriptNameNoExt.
    .LINK
    *---^ END Comment-based Help  ^--- #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "String to be convered to a 'Capital Acrynym'[string]")][ValidateNotNullOrEmpty()]
        [string]$String
    ) # PARAM BLOCK END
    $AcroCap = $String -split "" -cmatch '([A-Z])' -join ""  ;
    write-output $AcroCap ;
} #*------^ END Function create-AcronymFromCaps() ^------ ;