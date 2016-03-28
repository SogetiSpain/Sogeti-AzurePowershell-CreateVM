# Sogeti-AzurePowershell-CreateVM
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

Copyright (c) 2016 SOGETI Spain. All rights reserved.
Powered by Osc@rNET
