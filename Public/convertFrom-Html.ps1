#*------v Function convertFrom-Html v------
function convertFrom-Html {
    <#
    .SYNOPSIS
    convertFrom-Html - Convert specified text html to plain text (replace html tags & entities) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-05-14
    FileName    : convertFrom-Html.ps1
    License     : (non-asserted)
    Copyright   : 
    Github      : https://github.com/tostka
    AddedCredit : Winston Fassett
    AddedWebsite:	http://winstonfassett.com/blog/author/Winston/
    REVISIONS
    * 3:11 PM 5/14/2021 convertFrom-Html:init, added $file spec
    .DESCRIPTION
    convertFrom-Html - Convert specified text html to plain text (replace html tags & entities) and return to pipeline
    Minimal port of Winston Fassett's html-ToText()
    .PARAMETER  string
    File to be Base64 encoded (image, text, whatever)[-string path-to-file]
    .EXAMPLE
    convertFrom-Html.ps1 -string 'xxxxx' ; 
    .LINK
    http://winstonfassett.com/blog/2010/09/21/html-to-text-conversion-in-powershell/
    .LINK
    https://github.com/tostka/verb-text
    #>
    <# #-=-=-=MUTUALLY EXCLUSIVE PARAMS OPTIONS:-=-=-=-=-=
# designate a default paramset, up in cmdletbinding line
[CmdletBinding(DefaultParameterSetName='SETNAME')]
  # * set blank, if none of the sets are to be forced (eg optional mut-excl params)
  # * force exclusion by setting ParameterSetName to a diff value per exclusive param

# example:single $Computername param with *multiple* ParameterSetName's, and varying Mandatory status per set
    [Parameter(ParameterSetName='LocalOnly', Mandatory=$false)]
    $LocalAction,
    [Parameter(ParameterSetName='Credential', Mandatory=$true)]
    [Parameter(ParameterSetName='NonCredential', Mandatory=$false)]
    $ComputerName,
    # $Credential as tied exclusive parameter
    [Parameter(ParameterSetName='Credential', Mandatory=$false)]
    $Credential ;    
    # effect: 
    -computername is mandetory when credential is in use
    -when $localAction param (w localOnly set) is in use, neither $Computername or $Credential is permitted
    write-verbose -verbose:$verbose "ParameterSetName:$($PSCmdlet.ParameterSetName)"
#-=-=-=-=-=-=-=-=
#>
    [CmdletBinding(DefaultParameterSetName='fromstring')]
    PARAM(
        [Parameter(ParameterSetName='fromstring',Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted from html to plain text[-string '<b>text</b>']")]
        [System.String]$string,
        [Parameter(ParameterSetName='fromfile',HelpMessage="File to be converted from HTML to Text (and returned to pipeline)[-PARAM SAMPLEINPUT]")]
        [ValidateScript({Test-Path $_})]
        [string]$File
    ) ;
    if($File){
        $String = (get-content $file -encoding byte) ; 
    } ;
    
    # remove line breaks, replace with spaces
    $string = $string -replace "(`r|`n|`t)", " "
    # write-verbose "removed line breaks: `n`n$string`n"

    # remove invisible content
    @('head', 'style', 'script', 'object', 'embed', 'applet', 'noframes', 'noscript', 'noembed') | % {
    $string = $string -replace "<$_[^>]*?>.*?</$_>", ""
    }
    write-verbose "removed invisible blocks: `n`n$string`n"

    # Condense extra whitespace
    $string = $string -replace "( )+", " "
    write-verbose "condensed whitespace: `n`n$string`n"

    # Add line breaks
    @('div','p','blockquote','h[1-9]') | % { $string = $string -replace "</?$_[^>]*?>.*?</$_>", ("`n" + '$0' )} 
    # Add line breaks for self-closing tags
    @('div','p','blockquote','h[1-9]','br') | % { $string = $string -replace "<$_[^>]*?/>", ('$0' + "`n")} 
    write-verbose "added line breaks: `n`n$string`n"

    #strip tags 
    $string = $string -replace "<[^>]*?>", ""
    write-verbose "removed tags: `n`n$string`n"

    # replace common entities
    @( 
    @("&amp;bull;", " * "),
    @("&amp;lsaquo;", "<"),
    @("&amp;rsaquo;", ">"),
    @("&amp;(rsquo|lsquo);", "'"),
    @("&amp;(quot|ldquo|rdquo);", '"'),
    @("&amp;trade;", "(tm)"),
    @("&amp;frasl;", "/"),
    @("&amp;(quot|#34|#034|#x22);", '"'),
    @('&amp;(amp|#38|#038|#x26);', "&amp;"),
    @("&amp;(lt|#60|#060|#x3c);", "<"),
    @("&amp;(gt|#62|#062|#x3e);", ">"),
    @('&amp;(copy|#169);', "(c)"),
    @("&amp;(reg|#174);", "(r)"),
    @("&amp;nbsp;", " "),
    @("&amp;(.{2,6});", "")
    ) | foreach-object { $string = $string -replace $_[0], $_[1] }
    write-verbose "replaced entities: `n`n$string`n"

    $string | write-output ;     
} ; 
#*------^ END Function convertFrom-Html ^------