#*------v Function convertto-AcronymFromCaps()  v------
Function convertto-AcronymFromCaps {
    <#
    .SYNOPSIS
    convertto-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 9:47 AM 8/31/2023 bad verb: ren create-AcronymFromCaps -> convertto-AcronymFromCaps, alias orig name; CBH, updated examples to have output demo
    * 9:34 AM 3/12/2021 added -doEXOSubstitution to auto-tag 'exo' cmds in generated acronym (part of autoaliasing hybrid cmds across both onprem & EXO); added -verbose support
    12:14 PM 2/16/2016 - working
    8:58 AM 2/16/2016 - initial version
    .DESCRIPTION
    convertto-AcronymFromCaps - Creates an Acroynm From string specified, by extracting only the Capital letters from the string
    Note:-doEXOSubstitution covers both 'exo' and 'xo' as String substrings because MS's newer ExchangeOnline v2 module arbitrarily blocks/reserves 'exo' prefix _for it's own_ new commandlets, necessitating users to retroactrively shift prior use of -commandprefix 'exo', in existing code, to another variant. In my case I routinely shift to 'xo' as prefix. 
    .PARAMETER  String
    String to be convered to a 'Capital Acrynym'[-String 'get-exoMailboxPermission]'
    .PARAMETER doEXOSubstitution
    switch to add an 'x' in output position _2_, when `$String, has 'exo' or 'xo' as a substring (used for tagging hybrid Exchange o365 cmdlets with a commandprefix)[-doEXOSubstitution]
    .INPUTS
    None
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> convertto-AcronymFromCaps "get-AdGroupMembersRecurseManual" ;
    
        AGMRM
        
    Create a Capital-letter Acroynm for the specified string
    .EXAMPLE
    PS> $fn=".\$(convertto-AcronymFromCaps $scriptNameNoExt)-$(get-date -uformat '%Y%m%d-%H%M').csv" ;
    Create a filename based off of an Acronym from the capital letters in the ScriptNameNoExt.
    .EXAMPLE
    PS> $tCmdlet = 'Get-xoMailboxFolderStatistics' ; 
    PS> write-verbose 'get-command resolves to standardized name capitalization (regardless of input string case)'
    PS> $tCmdlet = (gcm $tCmdlet).Name ; 
    PS> set-alias -name "$(convertto-AcronymFromCaps -string $tCmdlet -doEXOSubstitution)" -value $tCmdlet ; 
    
        GxMFS
        
    Create an alias 'GxMFS' for the Exchange Online Get-xoMailboxFolderStatistics cmdlet (which in this case reflects an 'xo' commandprefix'd) . Example also pre-resolves the specified cmdlet name, to the default cmdlet Name capitalization scheme (for consistency; ensure it always produces the same acronym for a given cmdlet)
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    [Alias('create-AcronymFromCaps')]
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "String to be convered to a 'Capital Acrynym'[-String 'get-exoMailboxPermission]'")][ValidateNotNullOrEmpty()]
        [string]$String,
        [Parameter(HelpMessage="switch to add an 'x' in output position _2_, when `$String, has 'exo' or 'xo' as a substring (used for tagging hybrid Exchange o365 cmdlets with a commandprefix)[-doEXOSubstitution]")]
        [switch] $doEXOSubstitution
    ) ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    if($doEXOSubstitution){
        if($String -cmatch '((E)*)XO'){
            write-verbose "-doEXOSubstitution: Ucase 'EXO|XO' detected in `$String: .toLower()'ing the matched string, so that it only appears in output acronym as single lcase 'x', rather than full all caps '(E)XO'" 
            $String = $tcmdlet.replace($matches[0],$matches[0].tolower()) ; 
        } ; 
    } ;
    $AcroCap = $String -split "" -cmatch '([A-Z])' -join ""  ;
    if($doEXOSubstitution){
        if($String -match '((e)*)xo'){
            write-verbose "-doEXOSubstitution specified, and 'exo|xo' substring detected: adding 'x' into 2nd position of output" ; 
            $AcroCap = "$($AcroCap.substring(0,1))x$($AcroCap.substring(1,$AcroCap.length-1))" ; 
        } ; 
    } ; 
    write-verbose "output:$($AcroCap)" ; 
    write-output $AcroCap ;
} #*------^ END Function convertto-AcronymFromCaps() ^------ ;
