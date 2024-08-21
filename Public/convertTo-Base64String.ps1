#*------v Function convertTo-Base64String v------
function convertTo-Base64String {
    <#
    .SYNOPSIS
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If -String resolves to a path, it will be treated as a -SourceFile parameter (file content converted to Base64 encoded string). 
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
    * 10:12 AM 5/23/2024 add: -ForceString param, to permit encoding paths to b64 (insted of attempting to convert the file contents to b64).
    * 11:02 AM 9/5/2023 updated catch: wasn't echo'ing anything, just throw everything out.
    * 3:58 PM 4/20/2022 Work in progress, was adding file 'sourcefile/targetfile' support, untested, I believe I had issues with the conversion, b64 wouldn't convert cleanly back to original (as part of the encoding for the invoke-soundcue bundled ping updates).
    * 10:27 AM 9/16/2021 updated CBH, set -string as position 0, flipped pipeline to string from path, removed typo $file test, pre-resolve-path any string, and if it resolves to a file, load the file for conversion. Shift path validation into the body. 
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified string or Path-to-file to Base64 encoded string and return to pipeline. If String resolves to a path, it will be treated as a -path parameter (file content converted to Base64 encoded string). 
    .PARAMETER string
    String to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']
    .PARAMETER SourceFile
    Optional param that designates path from which to read a file containing Base64 encoded content, to be decoded[-SourceFile 'c:\path-to\base64.txt']
    .PARAMETER TargetFile
    Optional param that designates path into which to write the decoded Base64 content [-TargetPath 'c:\path-to\file.png']
    .PARAMETER ForceString
    Optional param that forces treament of -String as a string (vs file; avoids mis-recognition of string as a path to a file to be converted)
    .EXAMPLE
    PS> convertTo-Base64String -SourceFile C:\Path\To\Image.png > base64.txt ; 
    Example converting a png file to base64 and outputing result to text using redirection
    .EXAMPLE
    PS> convertto-base64string -sourcefile 'c:\path-to\some.jpg' -targetfile c:\tmp\b64.txt -verbose
    Example converting a jpg file to a base64-encoded text file leveraging the -targetfile parameter, and with verbose output 
    .EXAMPLE
    PS> convertTo-Base64String -string "my *very* minimally obfuscated info"
    .EXAMPLE
    PS> "address@domain.com" | convertTo-Base64String
    Pipeline conversion of an email address to b64
    .LINK
    #>
    [CmdletBinding(DefaultParameterSetName='File')]
    [Alias('CtB64')]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,HelpMessage="string to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']")]
            [String]$string,
        [Parameter(HelpMessage="Optional param that designates path from which to read a file to be Base64 encoded[-SourceFile 'c:\path-to\base64.txt']")]
            [string]$SourceFile,
        [Parameter(HelpMessage="Optional param that designates path into which to write the encoded Base64 content [-TargetPath 'c:\path-to\file.png']")]
            [string]$TargetFile,
        [Parameter(HelpMessage="Optional param that forces treament of -String as a string (vs file; avoids mis-recognition of string as a path to a file to be converted)")]
            [switch]$ForceString
    ) ;
    $error.clear() ;
    TRY {
        if($SourceFile -OR ( -not $ForceString -AND ($SourceFile = $string| Resolve-Path -ea 0) ) ){
            if(test-path $SourceFile){
                write-verbose "(loading specified/resolved SourceFile:$($SourceFile))" ; 
                <# Get-Content without -raw splits the file into an array of lines thus destroying the code
                # Text.Encoding interprets the binary code as text thus destroying the code
                # Out-File is for text data, not binary code
                #>
                #$String = (get-content $SourceFile -encoding byte) ; 
                #$String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile))
                # direct convert 1-liner bin2b64
                if(-not $TargetFile){
                    write-verbose "returning output to pipeline" ;
                    $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile))
                    $base64string | write-output ; 
                } else {
                    write-verbose "writing output to specified:$($TargetFile)..." ; 
                        $folder = Split-Path $TargetFile ; 
                        if(-not(Test-Path $folder)){
                            New-Item $folder -ItemType Directory | Out-Null ; 
                        } ; 
                        #Set-Content -Path $TargetFile -Value $Content #-Encoding Byte ;
                        #[IO.File]::WriteAllBytes($TargetFile, [Convert]::FromBase64String($String ))
                        [IO.File]::WriteAllBytes($TargetFile,[char[]][Convert]::ToBase64String([IO.File]::ReadAllBytes($SourceFile))) ; ; 
                }; 
                
            } else { throw "Unable to load specified -SourceFile:`n$($SourceFile))" } ; 
        } else { 
            $String = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String)) ;
        } ; 
        if(-not $TargetFile){
            write-verbose "returning output to pipeline" ;
            $String | write-output ; 
        } else {
            write-verbose "writing output to specified:$($TargetFile)..." ; 
                $folder = Split-Path $TargetFile ; 
                if(-not(Test-Path $folder)){
                    New-Item $folder -ItemType Directory | Out-Null ; 
                } ; 
                Set-Content -Path $TargetFile -Value $Content #-Encoding Byte ;
                #[IO.File]::WriteAllBytes($TargetFile, [Convert]::FromBase64String($String ))
        }; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
} ; 
#*------^ END Function convertTo-Base64String ^------