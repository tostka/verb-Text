    #*------v Function get-StringHash v------
    function get-StringHash {
        <#
        .SYNOPSIS
        VERB-NOUN.ps1 - 1LINEDESC
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2020-
        FileName    : 
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka
        Tags        : Powershell
        AddedCredit : Bryan Dady
        AddedWebsite:	https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
        REVISIONS
        * 11:59 AM 4/17/2020 updated CBH, moved from incl-servercore to verb-text
        * 9:46 PM 9/1/2019 updated, added Algorithm param, added pshelp
        * 1/21/11 posted version
        .DESCRIPTION
        get-StringHash.ps1 - Convert specifed string to designated Cryptographic Hash string
        hybrid of work by Ivovan & Bryan Dady
        .PARAMETER  String
        Specify string to be hashed. Accepts from pipeline
        .PARAMETER  Algorithm
        Hashing Algorithm (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160) -Algorithm MD5
        .EXAMPLE
        $env:username | get-StringHash -Algorithm md5 ;
        .LINK
        https://www.powershellgallery.com/packages/PSLogger/1.4.3/Content/GetStringHash.psm1
        #>
        param (
            [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Specify string to be hashed. Accepts from pipeline.')]
            [alias('text', 'InputObject')]
            [ValidateNotNullOrEmpty()]
            [string]$String,
            [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $false, HelpMessage = "Hashing Algorithm (SHA1|SHA256|SHA384|SHA512|MACTripleDES|MD5|RIPEMD160) -Algorithm MD5")]
            [alias('HashName')]
            [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MACTripleDES', 'MD5', 'RIPEMD160')]
            [string]$Algorithm = 'SHA256'
        ) ;
        $StringBuilder = New-Object -TypeName System.Text.StringBuilder ;
        [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | ForEach-Object -Process { [Void]$StringBuilder.Append($_.ToString('x2')) } ;
        #'Optimize New-Object invocation, based on Don Jones' recommendation: https://technet.microsoft.com/en-us/magazine/hh750381.aspx
        $Private:properties = @{
            'Algorithm' = $Algorithm ;
            'Hash'      = $StringBuilder.ToString()  ;
            'String'    = $String ;
        } ;
        $Private:RetObject = New-Object -TypeName PSObject -Prop $properties | Sort-Object ;
        return $RetObject  ;
    }#*------^ END Function get-stringHash ^------