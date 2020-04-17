#*------v Function Unwrap-TextN v------
Function Unwrap-TextN {
    <#
    .SYNOPSIS
    Unwrap-TextN - Unwrap text. This variant just replaces newlines `n, without the carriage return `r
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Unwrap-Text
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Text
    REVISIONS   :
    * 8:41 AM 4/12/2015, make it drop into the pipeline instead of return
    .DESCRIPTION
    Unwrap-TextN - Unwrap text. This variant just replaces newlines `n, without the carriage return `r
    .PARAMETER  sText
    Text to be unwrapped
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Outputs unwrapped text to pipeline
    .EXAMPLE
    get-fortune | unwrap-textn | speak-words
    Get a fortune, unwrap the text, and text-to-speech the words
    .EXAMPLE
    unwrap-textn $x
    .LINK
     #>
    PARAM(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'What text do you want to unwrap?')][string]$sText)
    BEGIN { }
    PROCESS {
        Foreach ($sTxt in $sText) {
            $sTxt0 = $sText.replace("`n", " ");
            if (($host.version) -eq "2.0") {
                return $sTxtO;
            }
            else {
                write-output $sTxt0 ;
            } 
        } 
    } 
} ; 
#*------^ END Function Unwrap-TextN ^------