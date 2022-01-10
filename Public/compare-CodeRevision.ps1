#*------v compare-CodeRevision.ps1 v------
function compare-CodeRevision {
    <#
    .SYNOPSIS
    compare-CodeRevisionrevision - Wrapper for Compare-Object to compare two revisions of a given text block of code,. Defaults to appending Line numbers to the comparison output (suppress with -nolinenumbers).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-01-10
    FileName    : compare-CodeRevision.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Development,ChangeTracking
    AddedCredit : PaulChavez
    AddedWebsite:	https://groups.google.com/g/microsoft.public.windows.powershell/c/0zoV5ekugXY
    AddedTwitter:	URL
    REVISIONS
    * 12:36 PM 1/10/2022 compare-CodeRevision:init
    .DESCRIPTION
    compare-CodeRevisionrevision - Wrapper for Compare-Object to compare two revisions of a given text block of code,. Defaults to appending Line numbers to the comparison output (suppress with -nolinenumbers).
    .PARAMETER  Reference
    Code block reference for comparison[-Reference (gc c:\path-to\mod.psm1)]
    .PARAMETER  Difference
    Code to be compared to the reference code[-Revision (gc c:\path-to\modv2.psm1)]
    .PARAMETER  NoLineNumbers
    Switch to suppress default line-number addition (in Reference & Difference code blocks)[-NoLineNumbers]
    .EXAMPLE
    $mod = 'verb-exo' ; 
    $ref = (gc "\\tsclient\c\sc\$mod\$mod\$mod.psm1")  ;
    $rev = (gc (gmo $mod).path)  ;
    $diff = Compare-CodeRevision $ref $rev ; 
    Compare local (updated) module code agaisnt reference dev source (via tsclient rdp path)
    .LINK
    https://github.com/tostka/verb-text
    .LINK
    https://gist.github.com/chillitom/8335042
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Code block reference for comparison[-Reference (gc c:\path-to\mod.psm1)]")]
        [ValidateNotNullOrEmpty()]
        $Reference,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Code to be compared to the reference code[-Revision (gc c:\path-to\modv2.psm1)]")]
        [ValidateNotNullOrEmpty()]
        $Difference,
        [Parameter(Mandatory=$false,HelpMessage="Switch to suppress default line-number addition (in Reference & Difference code blocks)[-NoLineNumbers]")]
        [switch]$NoLineNumbers
    ) ;
    if(-not $NoLineNumbers){
        $smsg = "(adding line#'s...)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$($smsg)" } ;
        $Reference = $Reference | %{$i = 1} { new-object psobject -prop @{LineNum=$i;Text=$_}; $i++} ;
        $Difference = $Difference | %{$i = 1} { new-object psobject -prop @{LineNum=$i;Text=$_}; $i++} ;
        $pltCO=[ordered]@{Reference = $Reference ;Difference = $Difference ;Property = 'Text' ;PassThru = $true ;} ;
    } else {
        $pltCO=[ordered]@{Reference = $Reference ;Difference = $Difference ; PassThru = $true ;} ;
    } ;  
     
    $smsg = "Compare-Object w`n$(($pltCO|out-string).trim())" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-verbose "$($smsg)" } ;
    $diff = Compare-Object @pltCO ; 
    $diff | write-output ; 
}
#*------^ compare-CodeRevision.ps1 ^------