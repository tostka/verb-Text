#*------v Function convertTo-UnWrappedText v------
Function convertTo-UnWrappedText {
    <#
    .SYNOPSIS
    convertTo-UnWrappedText
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : convertTo-UnWrappedText
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-text
    Tags        : Powershell,Text
    REVISIONS   :
    * 9:34 AM 11/22/2021 swapped out hard-coded crlf, with os agnostic method (& purged unwrap-textN `n-targeting variant); made adv func ; ren'd unwrap-text -> convertTo-UnWrappedText, with unwrap-text alias; ren'd param to Text, w sText alias
    * 8:41 AM 4/12/2015, make it drop into the pipeline instead of return
    .DESCRIPTION
    convertTo-UnWrappedText
    .PARAMETER  sText
    Text to be unwrapped
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Outputs unwrapped text to pipeline
    .EXAMPLE
    get-fortune | convertTo-UnWrappedText | speak-words
    Get a fortune, unwrap the text, and text-to-speech the words
    .EXAMPLE
    convertTo-UnWrappedText $x ;
    .LINK
    https://github.com/tostka/verb-text
    #>
    [CmdletBinding()]
    [Alias('unwrap-text','Unwrap-TextN')]
    PARAM(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'Text to be unwrapped')]
        [Alias('sText')]
        [string]$Text
    )    
    Foreach ($sTxt in $Text) {
        $sTxt0 = $sTxt.replace(([Environment]::NewLine)," ");
        return $sTxtO;
    } 
} ; #*------^ END Function convertTo-UnWrappedText ^------
