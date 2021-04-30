#*------v Function convertFrom-Base64String v------
function convertFrom-Base64String {
    <#
    .SYNOPSIS
    convertFrom-Base64String - Convert specified file to Base64 encoded string and return to pipeline
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
    * 8:26 AM 12/13/2019 convertFrom-Base64String:init
    .DESCRIPTION
    convertFrom-Base64String - Convert specified string from Base64 encoded string back to text and return to pipeline
    .PARAMETER  path
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    convertFrom-Base64String.ps1 -string 'xxxxx' ; 
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="String to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    if($File){
        $String = (get-content $path -encoding byte) ; 
    } 
    # [convert]::ToBase64String((get-content $path -encoding byte)) | write-output ; 
    #[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) | write-output ; 
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string))| write-output ;     
} ; 
#*------^ END Function convertFrom-Base64String ^------