# Get-SetupTextVersionTDO.ps1

    #region GET_SETUPTEXTVERSIONTDO ; #*------v Get-SetupTextVersionTDO v------
    Function Get-SetupTextVersionTDO {
        <#
        .SYNOPSIS
        Get-SetupTextVersionTDO - Resolves an Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (in 4-integer dot-separated format), to matching Exchange Version Text string. Works for either installed bins, or setup cab bins.
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Get-SetupTextVersionTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 9:59 AM 9/24/2025 second thought, this doesn't do the file lookup, it's a straight up low-brow alt to Resolve-xopBuildSemVersToTextNameTDO: dump it, alias the name
        * 9:11 AM 9/24/2025 ren Get-SetupTextVersionTDO -> Get-xopSetupTextVersionTDO() ; * 10:48 AM 9/22/2025 port to vx10 from xopBuildLibrary; add CBH, and Adv Function specs
        * 1:58 PM 8/8/2025 added CBH; init; renamed AdminAccount -> Account, aliased  orig param and logon variant. ren: Get-SetupTextVersionTDO -> Get-SetupTextVersionTDO, aliased orig name
        .DESCRIPTION
        Get-SetupTextVersionTDO - Resolves an Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (in 4-integer dot-separated format), to matching Exchange Version Text string. Works for either installed bins, or setup cab bins.
        
        This is designed to track the core/build-installable CU & RTM builds (vs hotfixes etc).
        Evaluates by using vio\get-FileVersionTDO() reading the (gcm ExSetup.exe) revision (which reflects last installed CU).
        
        This version, as of 10:42 AM 9/22/2025, documents the following specific revisions of Exchange Server
        
            $EX2016SETUPEXE_CU23= 'Exchange Server 2016 Cumulative Update 23';
            $EX2019SETUPEXE_CU10= 'Exchange Server 2019 CU10';
            $EX2019SETUPEXE_CU11= 'Exchange Server 2019 CU11';
            $EX2019SETUPEXE_CU12= 'Exchange Server 2019 CU12';
            $EX2019SETUPEXE_CU13= 'Exchange Server 2019 CU13';
            $EX2019SETUPEXE_CU14= 'Exchange Server 2019 CU14';
            $EX2019SETUPEXE_CU15= 'Exchange Server 2019 CU15';
            $EXSESETUPEXE_RTM= 'Exchange Server SE RTM';
        
        Requires manual updates to track new CUs over time.
        
        
        .PARAMETER FileVersion
        Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (from FileVersionInfo.ProductVersion in Powershell, or ProductVersion in Explorer), in 4-integer dot-separated format[-FileVersion '15.01.2507.006']
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> $SourcePath = 'D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked'  ; 
        PS> $SetupVersion= Get-DetectedFileVersion "$($SourcePath)\Setup\ServerRoles\Common\ExSetup.exe" ; 
        PS> $SetupVersionText= Get-SetupTextVersion $SetupVersion ; 
        Demo pulling setup CAB version
        .EXAMPLE
        PS> if($InstalledSetup= (gcm ExSetup.exe).source){$InstalledSetupVersionText= Get-SetupTextVersion $InstalledSetup } ; 
        Demo pulling installed bin version, by way of D:\Program Files\Microsoft\Exchange Server\V15\Bin\ExSetup.exe ProductVersion        
        .LINK
        https://github.org/tostka/verb-io/
        #>
        [CmdletBinding()]
        [alias('Get-SetupTextVersion821')]
        PARAM(
            [Parameter(Mandatory=$true,HelpMessage = "Exchange Server binary file (.exe, .dll, etc)'s SemanticVersion value (from FileVersionInfo.ProductVersion in Powershell, or ProductVersion in Explorer), in 4-integer dot-separated format[-FileVersion '15.01.2507.006']")]
                [string]$FileVersion
        ) ;
        # ensure dep constants are defined
        if($EX2016SETUPEXE_CU23){$EX2016SETUPEXE_CU23            = '15.01.2507.006'} ;         
        if($EX2019SETUPEXE_CU10){$EX2019SETUPEXE_CU10            = '15.02.0922.007'} ; 
        if($EX2019SETUPEXE_CU11){$EX2019SETUPEXE_CU11            = '15.02.0986.005'} ; 
        if($EX2019SETUPEXE_CU13){$EX2019SETUPEXE_CU13            = '15.02.1258.012'} ; 
        if($EX2019SETUPEXE_CU14){$EX2019SETUPEXE_CU14            = '15.02.1544.004'} ; 
        if($EX2019SETUPEXE_CU15){$EX2019SETUPEXE_CU15            = '15.02.1748.008'} ; 
        if($EXSESETUPEXE_RTM){$EXSESETUPEXE_RTM               = '15.02.2562.017'} ; 
        # supported versions lookup table (maps semvers above to text string)
        $Versions= @{
            $EX2016SETUPEXE_CU23= 'Exchange Server 2016 Cumulative Update 23';
            $EX2019SETUPEXE_CU10= 'Exchange Server 2019 CU10';
            $EX2019SETUPEXE_CU11= 'Exchange Server 2019 CU11';
            $EX2019SETUPEXE_CU12= 'Exchange Server 2019 CU12';
            $EX2019SETUPEXE_CU13= 'Exchange Server 2019 CU13';
            $EX2019SETUPEXE_CU14= 'Exchange Server 2019 CU14';
            $EX2019SETUPEXE_CU15= 'Exchange Server 2019 CU15';
            $EXSESETUPEXE_RTM= 'Exchange Server SE RTM';
        }
        $res= "Unsupported version (build $FileVersion)"
        $Versions.GetEnumerator() | Sort-Object -Property {[System.Version]$_.Name} | ForEach-Object {
            If( [System.Version]$FileVersion -ge [System.Version]$_.Name) {
                $res= '{0} (build {1})' -f $_.Value, $FileVersion
            }
        }
        return $res
    } ; 

    #endregion GET_SETUPTEXTVERSIONTDO ; #*------^ END Get-SetupTextVersionTDO ^------