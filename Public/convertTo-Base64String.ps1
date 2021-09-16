#*------v Function convertTo-Base64String v------
function convertTo-Base64String {
    <#
    .SYNOPSIS
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If -String resolves to a path, it will be treated as a -path parameter (file content converted to Base64 encoded string). 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-12-13
    FileName    : convertTo-Base64String.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:27 AM 9/16/2021 updated CBH, set -string as position 0, flipped pipeline to string from path, removed typo $file test, pre-resolve-path any string, and if it resolves to a file, load the file for conversion. Shift path validation into the body. 
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If String resolves to a path, it will be treated as a -path parameter (file content converted to Base64 encoded string). 
    .PARAMETER  path
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .PARAMETER  string
    String to be Base64 encoded [-string 'string to be encoded']
    .EXAMPLE
    PS> convertTo-Base64String -path C:\Path\To\Image.png >> base64.txt ; 
    .EXAMPLE
    PS> convertTo-Base64String -string "my *very* minimally obfuscated info"
    .EXAMPLE
    PS> "address@domain.com" | convertTo-Base64String
    Pipeline conversion of an email address to b64
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(ParameterSetName='File',HelpMessage="File to be Base64 encoded (image, text, whatever)[-path path-to-file]")]
        #[Alias('ALIAS1', 'ALIAS2')]
        #[ValidateScript({Test-Path $_})]
        [String]$path,
        [Parameter(ParameterSetName='String',Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="string to be converted[-string 'string to be encoded']")]
        [String]$string
    ) ;
    if($path -OR ($path = $string| Resolve-Path -ea 0)){
        if(test-path $path){
          write-verbose "(loading specified/resolved path:$($path))" ; 
          $String = (get-content $path -encoding byte) ; 
        } else { throw "Unable to load specified -path:`n$($path))" } ; 
    } 
    [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) | write-output ; 
    
} ; 
#*------^ END Function convertTo-Base64String ^------