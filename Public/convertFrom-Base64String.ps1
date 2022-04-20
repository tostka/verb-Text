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
    * 3:58 PM 4/20/2022 Work in progress, was adding file 'sourcefile/targetfile' support, untested, I believe I had issues with the conversion, b64 wouldn't convert cleanly back to original (as part of the encoding for the invoke-soundcue bundled ping updates).
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
    .EXAMPLE
    PS> convertTo-Base64String -path c:\path-to\file.png >> base64.txt ; 
    PS> $Media = ''UklGRmysA...TRIMMED...QD8/97/y/+8/7P/' ;
    PS> convertfrom-Base64String -string $media -TargetPath c:\path-to\file.png ; 
    Demo conversion of encoded wav file (using 
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,HelpMessage="string to be decoded from Base64 [-string 'bXkgKnZlcnkqIG1pbmltYWxseSBvYmZ1c2NhdGVkIGluZm8']")]
        [String]$string,
        [Parameter(HelpMessage="Optional param that designates path from which to read a file containing Base64 encoded content, to be decoded[-SourceFile 'c:\path-to\base64.txt']")]
        [string]$SourceFile,
        [Parameter(HelpMessage="Optional param that designates path into which to write the decoded Base64 content [-TargetPath 'c:\path-to\file.png']")]
        [string]$TargetFile
    ) ;
    if($string -AND $SourceFile){
        throw "Please use either -String or -SourceFile, but not both!"
        break ; 
    } ; 
    
    $error.clear() ;
    TRY {
        if(-not($string) -AND $SourceFile){
            $string = Get-Content $SourceFile #-Encoding Byte ; 
        } elseif (-not($string)){
            throw "Please specify either -String '[base64-encoded string]', or -SourceFile c:\path-to\base64.txt" ; 
        } ; 
        
        if(-not $TargetFile){
            $String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string)) ;  
            write-verbose "returning output to pipeline" ;
            #[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string))| write-output ;     
            $String | write-output ;     
        } else {
            write-verbose "writing output to specified:$($TargetFile)..." ; 
            <# 
            # Get-Content without -raw splits the file into an array of lines thus destroying the code
            # Text.Encoding interprets the binary code as text thus destroying the code
            # Out-File is for text data, not binary code
            #>
            #$Content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($string)) ;  
            #$Content = [System.Convert]::FromBase64String($string)
            $folder = Split-Path $TargetFile ; 
            if(-not(Test-Path $folder)){
                New-Item $folder -ItemType Directory | Out-Null ; 
            } ; 
            #Set-Content -Path $TargetFile -Value $Content #-Encoding Byte ;
            [IO.File]::WriteAllBytes($TargetFile, [Convert]::FromBase64String($string))
        }; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
} ; 
#*------^ END Function convertFrom-Base64String ^------