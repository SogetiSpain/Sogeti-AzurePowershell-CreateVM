<#
-------------------------------------------------------------------------------
Sogeti-AzurePowershell-CreateVM version 0.9 [Beta-Demo]

Copyright (c) 2016 SOGETI Spain. All rights reserved.
Powered by Osc@rNET

This Powershell script creates a new resource group within Azure containing the
necessary virtual network infrastructure for a new VM with Windows 10-1511(x64)
Enterprise and Visual Studio Community 2015 Update 1 for demo purposes.

These are the default values for Azure profile:

  - Location               : 'North Europe'
  - Resource Group Name    : 'Sogeti-VirtualCourses-WPFMVVM'
  - Storage Accoung Type   : 'Standard_LRS'
  - VM Name                : 'SOGETI01'
  - VM Username'n'Password : 'Sogeti' - 'Sogeti#2016'
  - VM Size                : 'Standard_D2_V2' (7GB Ram - 2 Cores)

This script has been tested on Powershell v5.0 (Windows 10 1511).


WARNING: Before executing, you should review and/or change various aspects of
         this script to fit your needs!   Guy, good luck! ...
-------------------------------------------------------------------------------
#>

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Creates an Azure resource group. 
.DESCRIPTION
    The Create-ResourceGroup cmdlet creates an Azure resource group.
.EXAMPLE
    Create-ResourceGroup
        -Location "North Europe"
        -Name "Sogeti-VirtualCourses-WPFMVVM"
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Create-ResourceGroup
{
    Param
    (
        # Specifies the location of the resource group. 
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,
        
        # Specifies a name for the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    
    If ((Get-AzureRmResourceGroup -Location $Location |
        Where-Object { $_.ResourceGroupName -eq $Name }).Length -eq 1)
    {
        throw ("The {0} resource group already exists!" -f $Name)
    }
    
    Write-Host ("Creating the {0} resource group ..." -f $Name)
    New-AzureRmResourceGroup `
        -Location $Location `
        -Name $Name
    Write-Host ("The {0} resource group was created successfully!" -f $Name)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Creates an Azure storage account. 
.DESCRIPTION
    The Create-StorageAccount cmdlet creates an Azure storage account.
.EXAMPLE
    Create-StorageAccount
        -Location "North Europe"
        -Name "storage7d219a95132b4713b"
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -Type "Standard_LRS" 
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Create-StorageAccount
{
    Param
    (
        # Specifies the location of the storage account to create.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,
        
        # Specifies the name of the storage account to create.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,
        
        # Specifies the name of the resource group in which to add the storage account.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the type of storage account to create.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Type
    )
    
    Validate-StorageAccountName -Name $Name
    If ((Test-AzureName -Name $Name -Storage) -eq $true)
    {
        throw ("The {0} storage account already exists within {1} resource group!" -f $Name, $ResourceGroupName)
    }
    
    Write-Host ("Creating the {0} storage account within {1} resource group ..." -f $Name, $ResourceGroupName)
    New-AzureRmStorageAccount `
        -Location $Location `
        -Name $Name `
        -ResourceGroupName $ResourceGroupName `
        -Type $Type
    Write-Host ("The {0} storage account was created successfully within {1} resource group!" -f $Name, $ResourceGroupName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Creates a virtual machine. 
.DESCRIPTION
    The Create-VirtualMachine cmdlet creates a virtual machine in Azure.
.EXAMPLE
    Create-VirtualMachine
        -Location "North Europe"
        -NICId "/subscriptions/3d50-..../SOGETI01-PrimaryNIC"
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -StorageAccountName "storage7d219a95132b4713b"
        -VMCredential (Get-Credential "SOGETI01\Sogeti")
        -VMImageOffer "VisualStudio"
        -VMImagePublisherName "MicrosoftVisualStudio"
        -VMImageSkus "VS-2015-Comm-VSU1-AzureSDK-2.8-W10T-1511-N-x64"
        -VMName "SOGETI01"
        -VMSize "Standard_D2_V2"
        -VMTimeZone "Romance Standard Time"
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Create-VirtualMachine
{
    Param
    (
        # Specifies a location for the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,
        
        # Specifies the ID of a network interface to add to the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $NICId,
        
        # Specifies the name of the resource group in which to add the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the storage account name in which to add the virtual hard disk of the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $StorageAccountName,
        
        # Specifies the credential for the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $VMCredential,
        
        # Specifies the type of VMImage offer.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMImageOffer,
        
        # Specifies the name of a publisher of a VMImage.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMImagePublisherName,
        
        # Specifies a VMImage SKU.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMImageSkus,
        
        # Specifies the name of the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName,
        
        # Specifies the size for the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMSize,
        
        # Specifies the time zone for the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMTimeZone
    )
    
    # Check if the VM already exists within resource group.
    If ((Get-AzureRmVM -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $VMName }).Length -eq 1)
    {
        throw ("The {0} VM already exists within {1} resource group!" -f $VMName, $ResourceGroupName)
    }
    
    Write-Host ("Creating the {0} VM within {1} resource group ..." -f $VMName, $ResourceGroupName)
    
    # Create the configurable VM object.
    Write-Host "Creating the configurable VM object ..."
    $VM = New-AzureRmVMConfig `
                -VMName $VMName `
                -VMSize $VMSize
    
    # Set the operating system properties for the VM.
    Write-Host "Setting the operating system properties for the VM ..."
    $VM = Set-AzureRmVMOperatingSystem `
                -ComputerName $VMName `
                -Credential $VMCredential `
                -EnableAutoUpdate `
                -ProvisionVMAgent `
                -TimeZone $VMTimeZone `
                -VM $VM `
                -Windows
    
    # Set the platform image for the VM.
    Write-Host "Setting the platform image for the VM ..."
    $VM = Set-AzureRmVMSourceImage `
                -Offer $VMImageOffer `
                -PublisherName $VMImagePublisherName `
                -Skus $VMImageSkus `
                -Version "latest" `
                -VM $VM
    
    # Get the storage account where the VHD need to be created for the VM.
    Write-Host "Getting the storage account where the VHD need to be created for the VM ..."
    $StorageAccount = Get-AzureRmStorageAccount `
                            -Name $StorageAccountName `
                            -ResourceGroupName $ResourceGroupName
    
    # Set the operating system disk properties for the VM.
    Write-Host "Setting the operating system disk properties for the VM ..."
    $VHDName = ($VMName + "-OSDisk")
    $VHDUri = ($StorageAccount.PrimaryEndPoints.Blob.ToString() + "vhds/" + $VHDName + ".vhd")
    $VM = Set-AzureRmVMOSDisk `
                -CreateOption "FromImage" `
                -Name $VHDName `
                -VHDUri $VHDUri `
                -VM $VM
    
    # Add the network interface to the virtual machine.
    Write-Host "Adding the network interface to the VM ..."
    $VM = Add-AzureRmVMNetworkInterface `
                -Id $NICId `
                -Primary `
                -VM $VM
    
    # Create the virtual machine.
    Write-Host "Creating the VM ..."
    Write-Host "`nNOTICE: This process may take a long time. Be patient!`n" -ForegroundColor Yellow
    New-AzureRmVM `
        -DisableBginfoExtension `
        -Location $Location `
        -ResourceGroupName $ResourceGroupName `
        -VM $VM
    Write-Host ("The {0} VM was created successfully within {1} resource group!" -f $VMName, $ResourceGroupName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Creates a virtual network infrastructure in Azure. 
.DESCRIPTION
    The Create-VirtualNetworkInfrastructure cmdlet creates a virtual network infrastructure in Azure.
.EXAMPLE
    Create-VirtualNetworkInfrastructure
        -AddressPrefix "10.0.0.0/16"
        -Location "North Europe"
        -NICId ([Ref]$NICId)
        -Prefix "SOGETI01"
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -SubnetAddressPrefix "10.0.1.0/24"
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Create-VirtualNetworkInfrastructure
{
    Param
    (
        # Specifies the range of IP addresses for the virtual network.
        [Parameter(Mandatory = $true)]
        [System.String]
        $AddressPrefix,
        
        # Specifies a location for the virtual network infrastructure.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,
        
        # Returns (by reference) the ID of the created network interface.
        [Parameter(Mandatory = $true)]
        [Ref]$NICId,
        
        # Specifies the prefix used to name the different components of the virtual network infrastructure.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Prefix,
        
        # Specifies the name of the resource group in which to add the virtual network infrastructure.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the range of IP addresses for the subnet configuration of the virtual network.
        [Parameter(Mandatory = $true)]
        [System.String]
        $SubnetAddressPrefix
    )
    
    $NetworkSecurityGroupName = ($Prefix + "-InboundAllowedConnections-NSG")
    $NICName = ($Prefix + "-PrimaryNIC")
    $PublicIPName = ($Prefix + "-PublicIP")
    $VirtualNetworkName = ($Prefix + "-VirtualNetwork")
    
    # Check if the network security group already exists within resource group.    
    If ((Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $NetworkSecurityGroupName }).Length -eq 1)
    {
        throw ("The {0} network security group already exists within {1} resource group!" -f $NetworkSecurityGroupName, $ResourceGroupName)
    }
    
    # Check if the virtual network already exists within resource group.    
    If ((Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $VirtualNetworkName }).Length -eq 1)
    {
        throw ("The {0} virtual network already exists within {1} resource group!" -f $VirtualNetworkName, $ResourceGroupName)
    }
    
    # Check if the public IP address already exists within resource group.
    If ((Get-AzureRmPublicIPAddress -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $PublicIPName }).Length -eq 1)
    {
        throw ("The {0} public IP address already exists within {1} resource group!" -f $PublicIPName, $ResourceGroupName)
    }
    
    # Check if the NIC already exists within resource group.
    If ((Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $NICName }).Length -eq 1)
    {
        throw ("The {0} network interface already exists within {1} resource group!" -f $NICName, $ResourceGroupName)
    }
    
    # Create the network security rule configurations.
    Write-Host "Creating the network security rule configurations ..."
    $NetworkSecurityRule1 = New-AzureRmNetworkSecurityRuleConfig `
                                -Access "Allow" `
                                -Description "Allows the remote desktop inbound connections" `
                                -DestinationAddressPrefix "*" `
                                -DestinationPortRange "3389" `
                                -Direction "Inbound" `
                                -Name "RemoteDesktop" `
                                -Priority "1000" `
                                -Protocol "Tcp" `
                                -SourceAddressPrefix "*" `
                                -SourcePortRange "*"
    $NetworkSecurityRule2 = New-AzureRmNetworkSecurityRuleConfig `
                                -Access "Allow" `
                                -Description "Allows the Powershell inbound connections" `
                                -DestinationAddressPrefix "*" `
                                -DestinationPortRange "5986" `
                                -Direction "Inbound" `
                                -Name "Powershell" `
                                -Priority "1100" `
                                -Protocol "Tcp" `
                                -SourceAddressPrefix "*" `
                                -SourcePortRange "*"
    
    # Create the network security group.
    Write-Host "Creating the network security group ..."
    $NetworkSecurityGroup = New-AzureRmNetworkSecurityGroup `
                                -Location $Location `
                                -Name $NetworkSecurityGroupName `
                                -ResourceGroupName $ResourceGroupName `
                                -SecurityRules $NetworkSecurityRule1, $NetworkSecurityRule2
    
    # Create the subnet and the virtual network.
    Write-Host "Creating the subnet and the virtual network ..."
    $Subnet = New-AzureRmVirtualNetworkSubnetConfig `
                    -AddressPrefix $SubnetAddressPrefix `
                    -Name ($Prefix + "-Subnet")
    $VirtualNetwork = New-AzureRmVirtualNetwork `
                            -AddressPrefix $AddressPrefix `
                            -Location $Location `
                            -Name $VirtualNetworkName `
                            -ResourceGroupName $ResourceGroupName `
                            -Subnet $Subnet
    
    # Create the public IP address.
    Write-Host "Creating the public IP address ..."
    $DomainNameLabel = Generate-FreeDomainNameLabel `
                            -Location $Location
    $PublicIP = New-AzureRmPublicIPAddress `
                    -AllocationMethod "Static" `
                    -DomainNameLabel $DomainNameLabel `
                    -Location $Location `
                    -Name $PublicIPName `
                    -ResourceGroupName $ResourceGroupName
    
    # Get the virtual network where the network interface need to be created.
    Write-Host "Getting the virtual network where the network interface need to be created ..."
    $VirtualNetwork = Get-AzureRmVirtualNetwork `
                            -Name $VirtualNetworkName `
                            -ResourceGroupName $ResourceGroupName
    
    # Create the network interface.
    Write-Host "Creating the network interface ..."
    $NIC = New-AzureRmNetworkInterface `
                -Location $Location `
                -Name $NICName `
                -NetworkSecurityGroupId $NetworkSecurityGroup.Id `
                -PublicIPAddressId $PublicIP.Id `
                -ResourceGroupName $ResourceGroupName `
                -SubnetId $VirtualNetwork.Subnets[0].Id
    $NIC = Get-AzureRmNetworkInterface `
                -Name $NICName `
                -ResourceGroupName $ResourceGroupName
    $NICId.Value = $NIC.Id
    
    Write-Host ("The virtual network infrastructure was created successfully within {0} resource group!" -f $ResourceGroupName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Deletes a resource group from Azure. 
.DESCRIPTION
    The Delete-ResourceGroup cmdlet deletes a resource group from Azure.
.EXAMPLE
    Delete-ResourceGroup
        -Confirm $false
        -Location "North Europe"
        -Name "Sogeti-VirtualCourses-WPFMVVM"
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Delete-ResourceGroup
{
    Param
    (
        # Specifies TRUE or FALSE for confirm.
        [Parameter(Mandatory = $false)]
        [System.Boolean]
        $Confirm = $true,
        
        # Specifies the location of the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location,
        
        # Specifies the name of the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    
    If ((Get-AzureRmResourceGroup -Location $Location |
        Where-Object { $_.ResourceGroupName -eq $Name }).Length -eq 0)
    {
        throw ("The {0} resource group not exists!" -f $Name)
    }
    
    If ($Confirm -eq $true)
    {
        While ($true)
        {
            Write-Host ("Are you sure you want to delete {0} resource group?" -f $Name)
            Write-Host "[" -NoNewLine
            Write-Host "Y" -ForegroundColor Cyan -NoNewLine
            Write-Host "]es or [" -NoNewLine
            Write-Host "N" -ForegroundColor Cyan -NoNewLine
            $YesNo = Read-Host "]o"
            If ($YesNo -eq 'y')
            {
                Break
            }
            ElseIf ($YesNo -eq 'n')
            {
                Write-Host "The resource group deleting was canceled by user!"
                Return
            }
        }
    }
    
    Write-Host ("Deleting the {0} resource group ..." -f $Name)
    Remove-AzureRmResourceGroup `
        -Force `
        -Name $Name
    Write-Host ("The {0} resource group was deleted successfully!" -f $Name)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Generates a free domain name label (not occupied in Azure). 
.DESCRIPTION
    The Generate-FreeDomainNameLabel cmdlet generates a free domain name label (not occupied in Azure).
.EXAMPLE
    Generate-FreeDomainNameLabel
.INPUTS
    None.
.OUTPUTS
    The generated domain name label. 
#>
function Generate-FreeDomainNameLabel
{
    Param
    (
        # Specifies the location for the DNS.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Location
    )

    $DomainNameLabel = $null
    
    Do
    {
        $DomainNameLabel = ("dns-" + [System.Guid]::NewGuid().ToString().ToLower())
        $IsFree = (Test-AzureRmDnsAvailability -DomainNameLabel $DomainNameLabel -Location $Location)
    }
    Until ($IsFree -eq $true)
    
    Return $DomainNameLabel
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Generates a free storage account name (not occupied in Azure). 
.DESCRIPTION
    The Generate-FreeStorageAccountName cmdlet generates a free storage account name (not occupied in Azure).
.EXAMPLE
    Generate-FreeStorageAccountName
.INPUTS
    None.
.OUTPUTS
    The generated domain name label. 
#>
function Generate-FreeStorageAccountName
{
    $Name = $null
    
    Do
    {
        $Name = ("storage" + [System.Guid]::NewGuid().ToString("N").ToLower().Substring(0, 17))
        $IsFree = !(Test-AzureName -Storage $Name)
    }
    Until ($IsFree -eq $true)
    
    Return $Name
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Installs the Azure PowerShell if it not exists. 
.DESCRIPTION
    The Install-AzurePowershellIfNotExists cmdlet installs the Azure PowerShell if it not exists.
    The NuGet Package Provider is required. 
.EXAMPLE
    Install-AzurePowershellIfNotExists 
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Install-AzurePowershellIfNotExists
{
    # Check if Azure Powershell is available.
    If ((Get-Module -ListAvailable Azure) -eq $null)
    {
        # Check if NuGet Package Provider is available (it is required for install Azure Powershell).
        If ((Get-PackageProvider | Select-String -InputObject {$_.Name} -Pattern "NuGet") -eq $null)
        {
            Write-Host "Installing the NuGet Package Provider ..."
            Get-PackageProvider "NuGet" -Force
            Set-PSRepository -Name "PSGallery" -PackageManagementProvider "NuGet" -InstallationPolicy "Trusted"
        }
        
        # Install the Azure Resource Manager modules from the PowerShell Gallery.
        Write-Host "Installing the Azure Resource Manager modules from the PowerShell Gallery ..."
        Install-Module AzureRM
        Install-AzureRM
        
        # Install the Azure Service Management module from the PowerShell Gallery
        Write-Host "Installing the Azure Service Management module from the PowerShell Gallery ..."
        Install-Module Azure
        
        # Import AzureRM modules for the given version manifest in the AzureRM module
        Write-Host "Importing AzureRM modules for the given version manifest in the AzureRM module ..."
        Import-AzureRM
        
        # Import Azure Service Management module
        Write-Host "Importing Azure Service Management module ..."
        Import-Module Azure
    }
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Installs the necessary extension for performs additional configuration on the virtual machine. 
.DESCRIPTION
    The Install-VMExtesionForAdditionalConfiguration cmdlet installs the necessary extension
    for performs additional configuration on the virtual machine.
    
    These are the additional configuration for the virtual machine:
        - Enable WinRM over HTTPS
        - Setup essential software  
.EXAMPLE
    Install-VMExtesionForAdditionalConfiguration
        -DNSName = $env:COMPUTERNAME
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -VMName = "SOGETI01" 
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Install-VMExtesionForAdditionalConfiguration
{
    Param
    (
        # Specifies the DNS for enable WINRM over HTTPS.
        [parameter(Mandatory = $false)]
        [System.String]
        $DNSName = $env:COMPUTERNAME,

        # Specifies the name of the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the name of the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName
    )
    
    $ContainerName = "scripts"
    $ExtensionName = "AdditionalConfigurationForVM"
    $FileName = "AdditionalConfigurationForVM.ps1"
    $FilePath = $env:TEMP + "\" + $FileName
    
    Write-Host ("Installing the extension within {0} VM for perform additional configuration!" -f $VMName)

# -----------------------------------------------------------------------------
# POWERSHELL SCRIPT TO EXECUTE ON THE VIRTUAL MACHINE BEGINS HERE
{
Param($DNSName)
$ErrorActionPreference = "Stop"

$Packages = @(
    @{ Name = "7zip" ; Title = "7-Zip" ; Description = "file archiver with high compression ratio" },
    @{ Name = "ilspy" ; Title = "ILSpy" ; Description = "assembly browsing and IL disassembly" },
    @{ Name = "notepadplusplus" ; Title = "Notepad++" ; Description = "source code editor" },
    @{ Name = "paint.net" ; Title = "Paint.NET" ; Description = "image and photo editing software" },
    @{ Name = "pdfcreator" ; Title = "PDFCreator" ; Description = "easily creates PDFs from any program" },
    @{ Name = "snoop" ; Title = "Snoop" ; Description = "allows to spy/browse the visual tree of a running WPF application" },
    @{ Name = "sysinternals" ; Title = "SysInternals" ; Description = "suite of utilities" },
    @{ Name = "teamviewer" ; Title = "TeamViewer" ; Description = "remote control" },
    @{ Name = "tortoisegit" ; Title = "TortoiseGit" ; Description = "Windows Shell Interface for Git based on TortoiseSVN" }
)

$Message = "The additional software was installed successfully in this VM"
Foreach ($Package In $Packages)
{
    $Message += (", " + $Package.Title)
}

$Message += ". To connect to the VM using the public IP address or DNS while bypassing certificate checks use the following command: "
$Message += "Enter-PSSession -ComputerName 'SOGETI01' -Credential 'SOGETI01\Sogeti' -UseSSL "
$Message += "-SessionOption (New-PSSessionOption -SkipCACheck -SkipCNCheck)"

# Check if this extension already ran in the virtual machine. 
$ExtensionOKFlag = "C:\AdditionalConfigurationForVM.OK"
If ((Test-Path -Path $ExtensionOKFlag) -eq $true)
{
    Write-Host $Message
    Exit
}
 
# Ensure PS remoting is enabled, although this is enabled by default for Azure VMs.
Enable-PSRemoting `
    -Force `
    -SkipNetworkProfileCheck

# Create rule in Windows Firewall.
New-NetFirewallRule `
    -Action "Allow" `
    -Direction "Inbound" `
    -DisplayName "WinRM HTTPS" `
    -Enabled "True" `
    -LocalPort "5986" `
    -Name "WinRM HTTPS" `
    -Profile "Any" `
    -Protocol "Tcp"

# Create self signed certificate and store thumbprint.
$ThumbPrint = (New-SelfSignedCertificate -DnsName $DNSName -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
  
# Run WinRM configuration on command line. DNS name set to computer hostname, you may wish to use a FQDN.
$CMD = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$DNSName""; CertificateThumbprint=""$ThumbPrint""}"
cmd.exe /C $CMD

If ((Get-PackageProvider | Select-String -InputObject {$_.Name} -Pattern "NuGet") -eq $null)
{
    Write-Host "Installing the NuGet Package Provider ..."
    Get-PackageProvider "NuGet" -Force
    Set-PSRepository -Name "PSGallery" -PackageManagementProvider "NuGet" -InstallationPolicy "Trusted"
    Write-Host "The NuGet Package Provider was installed successfully!"
}

If ((Get-PackageProvider | Select-String -InputObject {$_.Name} -Pattern "Chocolatey") -eq $null)
{
    Write-Host "Installing the Chocolatey Package Provider ..."
    Get-PackageProvider "Chocolatey" -Force
    Write-Host "The Chocolatey Package Provider was installed successfully!"
}

Foreach ($Package In $Packages)
{
    Try
    {
        Write-Host ("Installing {0} ({1}) ..." -f $Package.Title, $Package.Description)
        Install-Package -Force -Name $Package.Name -ProviderName "Chocolatey"
        Write-Host ("The {0} package was installed successfully!" -f $Package.Title)
    }
    Catch
    {
        Write-Host ("({0} - INSTALATION ERROR): {1}" -f $Package.Title, $_.Exception.Message)
    }
}

Write-Host $Message

# Marking this extension OK.
Get-Date -Format "yyyyMMdd-HHmmss" | Out-File $ExtensionOKFlag -Force     
} | Out-File $FilePath -Force -Width 255
# POWERSHELL TO EXECUTE ON THE VIRTUAL MACHINE ENDS HERE
# -----------------------------------------------------------------------------



    # Get the VM we need to configure.
    $VM = Get-AzureRmVM `
                -Name $VMName `
                -ResourceGroupName $ResourceGroupName
    
    # Get storage account name and key.
    $StorageAccountName = $VM.StorageProfile.OSDisk.VHD.Uri.Split(".")[0].Replace("https://", "")
    $StorageAccountKey = (
        Get-AzureRmStorageAccountKey `
            -Name $StorageAccountName `
            -ResourceGroupName $ResourceGroupName
    ).Key1
    
    # Create storage context and container for scripts.
    $StorageContext = New-AzureStorageContext `
                            -StorageAccountKey $StorageAccountKey `
                            -StorageAccountName $StorageAccountName
    New-AzureStorageContainer `
        -Context $StorageContext `
        -Name $ContainerName
    
    # Upload the script files.
    Set-AzureStorageBlobContent `
        -Blob $FileName `
        -Context $StorageContext `
        -Container $ContainerName `
        -File $FilePath `
        -Force
    
    # Create custom script extensions from uploaded files.
    Write-Host ("Running the extension within {0} VM for perform additional configuration!" -f $VMName)
    Write-Host "`nNOTICE: This process may take a long time. Be patient!`n" -ForegroundColor Yellow
    Set-AzureRmVMCustomScriptExtension `
        -Argument $DNSName `
        -ContainerName $ContainerName `
        -FileName $FileName `
        -Location $VM.Location `
        -Name $ExtensionName `
        -ResourceGroupName $ResourceGroupName `
        -Run $FileName `
        -StorageAccountKey $StorageAccountKey `
        -StorageAccountName $StorageAccountName `
        -VMName $VMName
    <#
    Set-AzureRmVMCustomScriptExtension `
        -Argument $DNSName `
        -ContainerName $ContainerName `
        -FileName $FileName `
        -Location $VM.Location `
        -Name $ExtensionName `
        -ResourceGroupName $ResourceGroupName `
        -Run $FileName `
        -StorageAccountKey $StorageAccountKey `
        -StorageAccountName $StorageAccountName `
        -VMName $VMName
    #>
    
    Write-Host ("The {0} VM need to restart for performing additional configuration." -f $VMName)
    Write-Host ("The extension within {0} VM was installed successfully!" -f $VMName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Restarts an Azure virtual machine. 
.DESCRIPTION
    The Restart-VirtualMachine cmdlet restarts an Azure virtual machine.
.EXAMPLE
    Restart-VirtualMachine
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -VMName = "SOGETI01" 
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Restart-VirtualMachine
{
    Param
    (
        # Specifies the name of the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the name of the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName
    )
    
    # Check If the virtual machine exists within the resource group.
    If ((Get-AzureRmVM -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $VMName }).Length -eq 0)
    {
        throw ("Can't restart the {0} VM within {1} resource group because isn't exists!" -f $VMName, $ResourceGroupName)
    }
    
    # Check If the virtual machine is running before restart it.
    $VMDetail = Get-AzureRmVM `
                    -Name $VMName `
                    -ResourceGroupName $ResourceGroupName `
                    -Status
    If (($VMDetail.Statuses | Where-Object { $_.Code -eq "PowerState/running" }).Length -eq 0)
    {
        throw ("Can't restart the {0} VM within {1} resource group because isn't running now!" -f $VMName, $ResourceGroupName)
    }
    
    # Restart the VM.
    Write-Host ("Restarting the {0} VM within {1} resource group ..." -f $VMName, $ResourceGroupName)
    Restart-AzureRmVM `
        -Name $VMName `
        -ResourceGroupName $ResourceGroupName
    Write-Host ("The {0} VM machine was restarted successfully within {1} resource group!" -f $VMName, $ResourceGroupName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Starts an Azure virtual machine. 
.DESCRIPTION
    The Start-VirtualMachine cmdlet starts an Azure virtual machine.
.EXAMPLE
    Start-VirtualMachine
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -VMName = "SOGETI01" 
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Start-VirtualMachine
{
    Param
    (
        # Specifies the name of the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the name of the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName
    )
    
    # Check If the virtual machine exists within the resource group.
    If ((Get-AzureRmVM -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $VMName }).Length -eq 0)
    {
        throw ("Can't start the {0} VM within {1} resource group because isn't exists!" -f $VMName, $ResourceGroupName)
    }
    
    # Check If the virtual machine is not running before start it.
    $VMDetail = Get-AzureRmVM `
                    -Name $VMName `
                    -ResourceGroupName $ResourceGroupName `
                    -Status
    If (($VMDetail.Statuses | Where-Object { $_.Code -eq "PowerState/running" }).Length -eq 1)
    {
        throw ("Can't start the {0} VM within {1} resource group because is running now!" -f $VMName, $ResourceGroupName)
    }
    
    # Start the VM.
    Write-Host ("Starting the {0} VM within {1} resource group ..." -f $VMName, $ResourceGroupName)
    Start-AzureRmVM `
        -Name $VMName `
        -ResourceGroupName $ResourceGroupName
    Write-Host ("The {0} VM was started successfully within {1} resource group!" -f $VMName, $ResourceGroupName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Stops an Azure virtual machine. 
.DESCRIPTION
    The Stop-VirtualMachine cmdlet stops an Azure virtual machine.
.EXAMPLE
    Stop-VirtualMachine
        -ResourceGroupName "Sogeti-VirtualCourses-WPFMVVM"
        -VMName = "SOGETI01" 
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Stop-VirtualMachine
{
    Param
    (
        # Specifies the name of the resource group.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceGroupName,
        
        # Specifies the name of the virtual machine.
        [Parameter(Mandatory = $true)]
        [System.String]
        $VMName
    )
    
    # Check If the virtual machine exists within the resource group.
    If ((Get-AzureRmVM -ResourceGroupName $ResourceGroupName |
        Where-Object { $_.Name -eq $VMName }).Length -eq 0)
    {
        throw ("Can't stop the {0} VM within {1} resource group because isn't exists!" -f $VMName, $ResourceGroupName)
    }
    
    # Check If the virtual machine is running before stop it.
    $VMDetail = Get-AzureRmVM `
                    -Name $VMName `
                    -ResourceGroupName $ResourceGroupName `
                    -Status
    If (($VMDetail.Statuses | Where-Object { $_.Code -eq "PowerState/running" }).Length -eq 0)
    {
        throw ("Can't stop the {0} VM within {1} resource group because isn't running now!" -f $VMName, $ResourceGroupName)
    }
    
    # Stop the VM.
    Write-Host ("Stopping the {0} VM within {1} resource group ..." -f $VMName, $ResourceGroupName)
    Stop-AzureRmVM `
        -Force `
        -Name $VMName `
        -ResourceGroupName $ResourceGroupName
    Write-Host ("The {0} VM was stopped successfully within {1} resource group!" -f $VMName, $ResourceGroupName)
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Validates the given domain name label. 
.DESCRIPTION
    The Validate-DomainNameLabel cmdlet validates the given domain name label.
.EXAMPLE
    Validate-DomainNameLabel
        -DomainNameLabel $DNSLabel
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Validate-DomainNameLabel
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DomainNameLabel
    )
    
    If ((($DomainNameLabel -cmatch "^[a-z][a-z0-9-]{1,61}[a-z0-9]$") -and ($Name.Length -ge 3) -and ($Name.Length -le 63)) -eq $false)
    {
        throw `
            "The domain name label must contain lowercase letters, numbers, hyphens and its length between 3 and 63; " +
            "the first character must be a letter and the last character must be a letter o number!"
    }
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Validates the given storage account name. 
.DESCRIPTION
    The Validate-StorageAccountName cmdlet validates the given storage account name.
.EXAMPLE
    Validate-StorageAccountName
        -Name $StorageAccountName
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Validate-StorageAccountName
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )
    
    If ((($Name -cmatch "^[a-z0-9]+$") -and ($Name.Length -ge 3) -and ($Name.Length -le 24)) -eq $false)
    {
        throw "The storage account name must contain lowercase letters, numbers and its length between 3 and 24!"
    }
}

<# ------------------------------------------------------------------------- #>

<#
.SYNOPSIS
    Writes a step information. 
.DESCRIPTION
    The Write-StepInfo cmdlet writes a step information.
.EXAMPLE
    Write-StepInfo
        -Msg $StorageAccountName
.INPUTS
    None.
.OUTPUTS
    None. 
#>
function Write-StepInfo
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Msg
    )
    
    Write-Host ("`n{0}`n" -f ("--> " + $Msg + " ").PadRight(80, '.')) -ForegroundColor Cyan
}

# -----------------------------------------------------------------------------
# Osc@rNET says: "Guy, good luck! ..."
# -----------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

New-Variable `
    -Name "DefaultVMCredential" `
    -Option "Constant" `
    -Scope "Script" `
    -Value (
        New-Object System.Management.Automation.PSCredential(
            "Sogeti", # UserName
            (ConvertTo-SecureString "Sogeti#2016" -AsPlainText -Force) # Password
        )
    )

$OriginalForegroundColor = [System.Console]::ForegroundColor
$OriginalBackgroundColor = [System.Console]::BackgroundColor
[System.Console]::ForegroundColor = "Gray"
[System.Console]::BackgroundColor = "Black"

If ($psISE -ne $null)
{
    $OriginalISEForegroundColor = $psISE.Options.ConsolePaneForegroundColor
    $OriginalISEBackgroundColor = $psISE.Options.ConsolePaneBackgroundColor
    $psISE.Options.ConsolePaneForegroundColor = "#FFC0C0C0"
    $psISE.Options.ConsolePaneTextBackgroundColor = "#FF000000"
    $psISE.Options.ConsolePaneBackgroundColor = "#FF000000"
}

Try
{
    While ($true)
    {
        Clear-Host
        Write-Host ("{0}`n" -f "".PadLeft(80, '_'))
        Write-Host "Sogeti-AzurePowershell-CreateVM version 0.9 [Beta-Demo]`n"
        Write-Host "Copyright (c) 2016 SOGETI Spain. All rights reserved.`nPowered by " -NoNewLine
        Write-Host "Osc@rNET" -ForegroundColor Cyan
        Write-Host ("{0}`n" -f "".PadLeft(80, '_'))
        Write-Host "This Powershell script creates a new resource group within Azure containing the"
        Write-Host "necessary virtual network infrastructure for a new VM with Windows 10-1511(x64)"
        Write-Host "Enterprise and Visual Studio Community 2015 Update 1 for demo purposes.`n"
        Write-Host "These are the default values for Azure profile:`n"
        Write-Host "  - Location               : 'North Europe'"
        Write-Host "  - Resource Group Name    : 'Sogeti-VirtualCourses-WPFMVVM'"
        Write-Host "  - Storage Accoung Type   : 'Standard_LRS'"
        Write-Host "  - VM Name                : 'SOGETI01'"
        Write-Host "  - VM Username'n'Password : 'Sogeti' - 'Sogeti#2016'"
        Write-Host "  - VM Size                : 'Standard_D2_V2' (7GB Ram - 2 Cores)`n"
        Write-Host "This script has been tested on Powershell v5.0 (Windows 10 1511).`n`n"
        Write-Host "WARNING: Before executing, you should review and/or change various aspects of" -ForegroundColor Yellow
        Write-Host "         this script to fit your needs!   " -ForegroundColor Yellow -NoNewLine
        Write-Host "Guy, good luck! ...`n" -ForegroundColor White 
        Write-Host "`nAre you sure you want to continue?"
        Write-Host "[" -NoNewLine
        Write-Host "Y" -ForegroundColor Cyan -NoNewLine
        Write-Host "]es or [" -NoNewLine
        Write-Host "N" -ForegroundColor Cyan -NoNewLine
        $YesNo = Read-Host "]o"
        If ($YesNo -eq 'y')
        {
            Write-Host "`n"
            Break
        }
        ElseIf ($YesNo -eq 'n')
        {
            throw "The execution of this script was aborted by yourself!"
        }
    }
    
    Write-StepInfo -Msg "Check for the Azure Powershell availability"
    Install-AzurePowershellIfNotExists
    Import-Module AzureRM.Profile
    
    Write-StepInfo -Msg "Sign in to your Azure account"
    Add-AzureRmAccount
    
    $DefaultLocation = "North Europe"
    $DefaultResourceGroupName = "Sogeti-VirtualCourses-WPFMVVM"
    $DefaultStorageAccountName = Generate-FreeStorageAccountName
    $DefaultVMName = "SOGETI01"
    
    <# Osc@rNET: ONLY IF YOU WANT TO START AGAIN FROM SCRATCH.
    Delete-ResourceGroup `
        -Confirm $false `
        -Location $DefaultLocation `
        -Name $DefaultResourceGroupName
    #>
    
    Write-StepInfo -Msg "Create the new resource group"
    Create-ResourceGroup `
        -Location $DefaultLocation `
        -Name $DefaultResourceGroupName
    
    Write-StepInfo -Msg "Create the new storage account"
    Create-StorageAccount `
        -Location $DefaultLocation `
        -Name $DefaultStorageAccountName `
        -ResourceGroupName $DefaultResourceGroupName `
        -Type "Standard_LRS"
    
    Write-StepInfo -Msg "Create the new virtual network infrastructure"
    $NICId = [System.String]::Empty
    Create-VirtualNetworkInfrastructure `
        -AddressPrefix "10.0.0.0/16" `
        -Location $DefaultLocation `
        -NICId ([Ref]$NICId) `
        -Prefix $DefaultVMName `
        -ResourceGroupName $DefaultResourceGroupName `
        -SubnetAddressPrefix "10.0.1.0/24"
    
    Write-StepInfo -Msg "Create the new VM"
    Create-VirtualMachine `
        -Location $DefaultLocation `
        -NICId $NICId `
        -ResourceGroupName $DefaultResourceGroupName `
        -StorageAccountName $DefaultStorageAccountName `
        -VMCredential $DefaultVMCredential `
        -VMImageOffer "VisualStudio" `
        -VMImagePublisherName "MicrosoftVisualStudio" `
        -VMImageSkus "VS-2015-Comm-VSU1-AzureSDK-2.8-W10T-1511-N-x64" `
        -VMName $DefaultVMName `
        -VMSize "Standard_D2_V2" `
        -VMTimeZone "Romance Standard Time"
    
    <# Osc@rNET: 100% NOT TESTED YET. IN ALL CASES THE PROCESS HAS BEEN LOCKED.
    Write-StepInfo -Msg "Perform additional configuration within VM"    
    Install-VMExtesionForAdditionalConfiguration `
        -ResourceGroupName $DefaultResourceGroupName `
        -VMName $DefaultVMName
    #>
    
    <# Oscar@NET: THIS STEP IS NOT NECESSARY.
    Write-StepInfo -Msg "Deallocate the VM and start it again"
    Stop-VirtualMachine `
        -ResourceGroupName $DefaultResourceGroupName `
        -VMName $DefaultVMName
    Start-VirtualMachine `
        -ResourceGroupName $DefaultResourceGroupName `
        -VMName $DefaultVMName
    #>
    
    Write-StepInfo -Msg "T H E   E N D"
}
Catch
{
    Write-Host ("`nERROR: {0}`n" -f $_.Exception.Message) `
        -ForegroundColor Red
}
Finally
{
    Pause
    
    [System.Console]::ForegroundColor = $OriginalForegroundColor
    [System.Console]::BackgroundColor = $OriginalBackgroundColor
    If ($psISE -ne $null)
    {
        $psISE.Options.ConsolePaneForegroundColor = $OriginalISEForegroundColor
        $psISE.Options.ConsolePaneTextBackgroundColor = $OriginalISEBackgroundColor
        $psISE.Options.ConsolePaneBackgroundColor = $OriginalISEBackgroundColor
    }
    
    Clear-Host
}