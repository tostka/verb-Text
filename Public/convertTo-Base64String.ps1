﻿#*------v Function convertTo-Base64String v------
function convertTo-Base64String {
    <#
    .SYNOPSIS
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
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
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .PARAMETER  path
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    .\convertTo-Base64String.ps1 C:\Path\To\Image.png >> base64.txt ; 
    .EXAMPLE
    .\convertTo-Base64String.ps1
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    PARAM(
        [Parameter(ParameterSetName='File',Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="File to be Base64 encoded (image, text, whatever)[-path path-to-file]")]
        [ValidateScript({Test-Path $_})][String]$path,
        [Parameter(ParameterSetName='String',HelpMessage="Optional string to be converted[-string 'SAMPLEINPUT']")]
        [String]$string
    ) ;
    if($File){
        $String = (get-content $path -encoding byte) ; 
    } 
    # [convert]::ToBase64String((get-content $path -encoding byte)) | write-output ; 
    [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) | write-output ; 
    
} ; 
#*------^ END Function convertTo-Base64String ^------