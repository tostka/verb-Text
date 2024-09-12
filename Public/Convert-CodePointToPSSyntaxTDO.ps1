# Convert-CodePointToPSSyntaxTDO

#*------v Function Convert-CodePointToPSSyntaxTDO v------
function Convert-CodePointToPSSyntaxTDO {
    <#
    .SYNOPSIS
    Convert-CodePointToPSSyntaxTDO -  Converts a given Unicode CodePoint into the matching PSSyntax ([char]0xnnnn), [char]::ConvertFromUtf32(0xnnnnn)), returned as a Customobject summarizing the input CodePoint, the rendered Character it represents, and PSSyntax necessary to render the codepoint in Powershell
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2024-09-12
    FileName    : Convert-CodePointToPSSyntaxTDO.ps1
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:52 PM 9/12/2024 added CodePoint validator regex for PSCodePoint format (0xnnnn) ;  init

    .DESCRIPTION

    Convert-CodePointToPSSyntaxTDO -  Converts a given Unicode CodePoint into the matching PSSyntax ([char]0xnnnn), [char]::ConvertFromUtf32(0xnnnnn)), returned as a Customobject summarizing the input CodePoint, the rendered Character it represents, and PSSyntax necessary to render the codepoint in Powershell

    .PARAMETER CodePoint
    Unicode Codepoint (U+1F4AC|\u2717) to be converted into equivelent Powershell Syntax[-CodePoint 'U+1F4AC']
    .INPUT
    System.String[]
    .OUTPUT
    PSCustomObject summary of Codepoint, Character, and PSSyntax example to render the specified character
    .EXAMPLE
    PS> $Returned = Convert-CodePointToPSSyntaxTDO -CodePoint 'U+2620' -verbose
    PS> $Returned ; 

        CodePoint Character PSSyntax                        
        --------- --------- --------                        
        U+2620    ☠         [char]::ConvertFromUtf32(0x2620)

    PS> $Returned.PsSyntax ;

        [char]::ConvertFromUtf32(0x2620)

    Demo conversion of the codepoint for 'Skull & Crossbones' into PS Syntax
    .EXAMPLE
    PS> $codes = "U+2620 U+2623" ;     
    PS> $PSSyntax = ($item.CodePoint.split(' ') | Convert-CodePointToPSSyntaxTDO -Verbose:($PSBoundParameters['Verbose'] -eq $true) | select -expand PSSyntax ) -join ' ' ;         
    demo splitting a space-delimited set of CodePoints, looping them through Convert-CodePointToPSSyntaxTDO, and then space-joining them on return
    .LINK
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $true, ValueFromPipeline=$true, HelpMessage = "Unicode Codepoint (U+1F4AC|\u2717) to be converted into equivelent Powershell Syntax[-CodePoint 'U+1F4AC']")]
        # \u2717 | U+1F600
        #[ValidatePattern("U\+[0-9a-fA-F]+|\\u[0-9a-fA-F]+")]
        [ValidatePattern("U\+[0-9a-fA-F]+|\\u[0-9a-fA-F]+|0x[0-9a-fA-F]+")] # updated rgx passes pre-converted PSCodePoint format
        [string[]]$CodePoint
    ) ;
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======
    } ;  # BEG-E
    PROCESS {
        foreach($point in $CodePoint){
            if($point -match "0x[0-9a-fA-F]+"){
                write-verbose "`$CodePoint $($point) is already in PSCodePoint format" ; 
                $psCodePoint = $point ; 
            }else{
                $psCodePoint = $point.replace('U+','0x').replace('\u','0x') ; 
            } ; 
            $PSSyntax = try{
                [char]$psCodePoint | out-null ;
                "[char]$($psCodePoint)"| write-output ;
            } catch {
                try{
                    [char]::ConvertFromUtf32($psCodePoint) | out-null;
                    "[char]::ConvertFromUtf32($($psCodePoint))" | write-output 
                }catch{throw "Unable to resolve Codepoint $(codepoint) to a working [char] string"}
            } ; 
            if($PSSyntax){
              write-verbose "Character: $($PSSyntax | invoke-expression)`n`PSSyntax:$($PSSyntax)" ; 
              [pscustomobject]([ordered]@{
                  CodePoint = $point ; 
                  Character = $($PSSyntax | iex) ; 
                  PSSyntax = $PSSyntax ; 
              }) | write-output ; 
              #$PSSyntax | write-output ; 
            } ;    
        } # loop-E  
    } 
    END {} ; 
} ; 
#*------^ END Function Convert-CodePointToPSSyntaxTDO ^------
