#*------v Function convertFrom-Base64String v------
function convertFrom-Base64String {
    <#
    .SYNOPSIS
    convertFrom-Base64String - Convert Base64 encoded string back to original text, and return to pipeline
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-30
    FileName    : convertFrom-Base64String.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:38 AM 9/16/2021 removed spurious DefaultParameterSet matl and file/path test material (from convertto-b64...), added pipeline example to CBH, fixed CBH params (had convertfrom params spec'd); added email address conversion example
    * 8:26 AM 12/13/2019 convertFrom-Base64String:init
    .DESCRIPTION
    convertFrom-Base64String - Convert specified string from Base64 encoded string back to text and return to pipeline
    .PARAMETER  string
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    PS> convertFrom-Base64String -string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8=' ; 
    Convert Base64 encoded string back to original unencoded text
    .EXAMPLE
    PS> $EmailAddress = 'YWRkcmVzc0Bkb21haW4uY29t' | convertFrom-Base64String
    Pipeline conversion of encoded EmailAddress back to string.
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="string to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']")]
        [String]$string
    ) ;
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string))| write-output ;     
} ; 
#*------^ END Function convertFrom-Base64String ^------