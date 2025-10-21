#*------v Function convert-HtmlCodeToTextTDO v------
function convert-HtmlCodeToTextTDO {
    <#
    .SYNOPSIS
    convert-HtmlCodeToTextTDO - Convert specified text html code or encoded-URL strings to plain text (replace html tags & entities, configure whitespace, decode encodings) and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-05-14
    FileName    : convert-HtmlCodeToTextTDO.ps1
    License     : (non-asserted)
    Copyright   : 
    Github      : https://github.com/tostka
    AddedCredit : Winston Fassett
    AddedWebsite:	http://winstonfassett.com/blog/author/Winston/
    REVISIONS
    # * 9:24 AM 9/25/2025 add -UrlDecode support, to unencode url's ; add -PlusLiteral steering + handling logic; $rgxURLDecodeFilter as a encoded url detection filter rgx
         fixed CBH params (didn't reflect param help msg specs)
    * 8:34 AM 11/8/2023 name-clash with importExcel mod leverage of ConvertFrom-Html(): ren convertFrom-Html -> convert-HtmlCodeToTextTDO (alias:     convertFrom-HtmlTDO ; don't alias to old name, do alias to tagged variant: This doesn't convert web pages, it replaces common html entities, strips tags & configures raw text whitespace
    * 3:11 PM 5/14/2021 convertFrom-Html:init, added $file spec
    .DESCRIPTION
    convert-HtmlCodeToTextTDO - Convert specified text html code or encoded-URL strings to plain text (replace html tags & entities, configure whitespace, decode encodings) and return to pipeline
    Minimal port of Winston Fassett's html-ToText()
    .PARAMETER string
    String to be converted from html to plain text[-string '<b>text</b>']
    .PARAMETERFile
    File to be converted from HTML to Text (and returned to pipeline)[-file c:\pathto\file.html]
    .EXAMPLE
    convert-HtmlCodeToTextTDO.ps1 -string 'xxxxx' ; 
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
    [Alias('convertFrom-HtmlTDO')]
    PARAM(
        [Parameter(ParameterSetName='fromstring',Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted from html to plain text[-string '<b>text</b>']")]
            [System.String]$string,
        [Parameter(ParameterSetName='fromfile',HelpMessage="File to be converted from HTML to Text (and returned to pipeline)[-file c:\pathto\file.html]")]
            [ValidateScript({Test-Path $_})]
            [string]$File,
        [Parameter(ParameterSetName='fromstring',HelpMessage="Switch to treat plus-signs as literal pluses (suitable for decoding individual components of a URL, vs default treatment of plus-sign's as encoded spaces, e.g. as part of URL query strings)[-string '<b>text</b>']")]
            [switch]$PlusLiteral,
        [Parameter(ParameterSetName='fromstring',HelpMessage="Switch to force URLDecode pass on string(normally triggered only on [?%+] match in string) [-UrlDecode']")]
            [switch]$UrlDecode
    ) ;
    $rgxURLDecodeFilter = '[?%+]'
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

    # * 9:24 AM 9/25/2025 add -UrlDecode support, to unencode url's ; add -PlusLiteral steering + handling logic; $rgxURLDecodeFilter as a encoded url detection filter rgx
    # $PlusLiteral $UrlDecode $rgxURLDecodeFilter
    if($UrlDecode -OR ($string -match $rgxURLDecodeFilter)){
        if($string -match $rgxURLDecodeFilter){$smsg = "matched UrlEncoding chars ($($rgxURLDecodeFilter))," }
        if($UrlDecode){$smsg = "`n-UrlDecode:"}
        $smsg += "running UrlDecode" ;
        write-host -foregroundcolor gray $smsg ; 
        if($PlusLiteral){
            write-verbose "-PlusLiteral: using [System.Uri]::UnescapeDataString()" ; 
            $string = [System.Uri]::UnescapeDataString($string)
        }else{
            write-verbose "Default plus as space: using [System.Web.HttpUtility]::UrlDecode()" ; 
            [Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null ;
            $string = [System.Web.HttpUtility]::UrlDecode($string)
        } ; 
    } ; 
    $string | write-output ;     
} ; 
#*------^ END Function convert-HtmlCodeToTextTDO ^------