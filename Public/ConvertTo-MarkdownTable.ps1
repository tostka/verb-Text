#*------v Function ConvertTo-MarkdownTable  v------
Function ConvertTo-MarkdownTable {
    <#
    .SYNOPSIS
    ConvertTo-MarkdownTable - Converts a powershell object into a markdown table
    .NOTES
    Version     : 1.0.0
    Author      : BenNeise
    Website     :	https://gist.github.com/BenNeise/4c837213d0f313715a93
    Twitter     :	
    CreatedDate : 2020-05-14
    FileName    : ConvertTo-MarkdownTable,os1
    License     : 
    Copyright   : 
    Github      : https://gist.github.com/mac2000/86150ab43cfffc5d0eef
    Tags        : Powershell,Markdown,Object
    AddedCredit : mac2000
    AddedWebsite:	https://gist.github.com/mac2000/86150ab43cfffc5d0eef
    AddedTwitter:	URL
    AddedCredit : TylerRudie
    AddedWebsite:	https://gist.github.com/mac2000/86150ab43cfffc5d0eef
    AddedCredit : aaroncalderon
    AddedWebsite:	https://gist.github.com/aaroncalderon/09a2833831c0f3a3bb57fe2224963942
    REVISIONS   :
    * 8:22 AM 5/14/2020 ren'd ConvertTo-Markdown -> ConvertTo-MarkdownTable ; updated CBH ; reformated a bit ; implemented TylerRudie' $null property fix ; added -NewLine switch to trigger aaroncalderon's `n-append file-append workaround, as an option ; added -Border param to create outer-border (|Heading1|Heading2| vs Heading1|Heading2)
    * Nov 6, 2019 TylerRudie added if/then to exempt property:$null issue
    * Jun 11, 2015 last BenNeise update (merged mac2000's Apr 17, 2015 changes)
    .DESCRIPTION
    ConvertTo-MarkdownTable - Converts a powershell object into a markdown table
    .PARAMETER  collection
    Powershell object to be converted
    .PARAMETER  NewLine
    Switch to append trailing \n to each line (suppresses errors writing to files)[-NewLine]
    .PARAMETER  Border
    Switch to wrap each line in outter pipe(|) symbols: |Heading1|Heading2| vs Heading1|Heading2 (defaulted `$true) [-Border]
    .INPUTS
    None
    .OUTPUTS
    System.String
    .EXAMPLE
    $data | ConvertTo-Markdown
    Convert object to markdown, input & output via pipeline
    .EXAMPLE
    ConvertTo-Markdown($data)
    Convert passed object to markdown, output via pipeline
    .EXAMPLE
    $data | ConvertTo-Markdown -border:$false -NewLine 
    Convert object to markdown, and output to pipeline, suppress border, add NewLines to separator row
    
    .LINK
    https://gist.github.com/mac2000/86150ab43cfffc5d0eef
    #>
    
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true,HelpMessage="Powershell object to be converted[-Collection `$obj]")]
        [PSObject[]]$Collection,
        [Parameter(HelpMessage="Switch to append trailing \n to each line (suppresses errors writing to files)[-NewLine]")]
        [switch] $NewLine,
        [Parameter(HelpMessage="Switch to wrap each line in outter pipe(|) symbols (makes more visually similar to a full table, defaulted `$true) [-Border]")]
        [switch] $Border=$true
    ) 
    
    Begin {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        Write-verbose -verbose:$verbose "$((get-date).ToString('HH:mm:ss')):MSG" ;
        $items = @() ; 
        $columns = @{} ; 
    } # BEG-E
    Process {
        ForEach($item in $collection) {
            $items += $item
            $item.PSObject.Properties | ForEach-Object {
                if ($null -ne $_.Value ){
                    if(-not $columns.ContainsKey($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                        $columns[$_.Name] = $_.Value.ToString().Length ; 
                    } ; 
                } ; 
            } ; 
        } ; 
    } # PROC-E

    End {
        # space-pad columns: 1)calc max len of ea column
        ForEach($key in $($columns.Keys)) { $columns[$key] = [Math]::Max($columns[$key], $key.Length) }

        # 2) space-pad hdr row, to match col widths
        $header = @()
        ForEach($key in $columns.Keys) { $header += ('{0,-' + $columns[$key] + '}') -f $key } ; 
        if($Border){  '| ' + $($header -join ' | ' ) + ' |' }
        else { $header -join ' | '  } ; 

        # space-pad seperator row, to match col widths
        $separator = @() ; 
        ForEach($key in $columns.Keys) { $separator += '-' * $columns[$key] } ; 
        if(!$NewLine){
            if($Border){  '| ' + $($separator -join ' | ' ) + ' |' }
            else { $separator -join ' | ' } ; 
        } else {
            <# TylerRudy: addresses issues piping seperator line output to a function that appends to a file: workaround via append trailing `n.
    $($separator -join ' | ') + "`n"
            #>
            if($Border){  '| ' + $($separator -join ' | ' ) + ' |`n' }
            else { $($separator -join ' | ') + "`n" } ; 
        } ;

        <#
        
        #>

        # append the items
        ForEach($item in $items) {
            $values = @() ; 
            ForEach($key in $columns.Keys) { $values += ('{0,-' + $columns[$key] + '}') -f $item.($key) } ; 
            if($Border){  '| ' + $($values -join ' | ' ) + ' |' }
            else { $values -join ' | '  } ; 
        } ; 
    } # END-E
} #*------^ END Function ConvertTo-MarkdownTable ^------ ;