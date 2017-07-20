# ************************************************************************************
# 
# Script Name   : Test-2DOWSman.ps1
# Version       : 0.1
# Author        :                      
# Date          : 19 july 2017
# First Release : 
# Final Version : 
#

#
# Notes: Simple scriptje, doet wat het moet doen. Vraagt VM uit in VMWare vCenter, en test de WinRM.
#   
#

# Start Parameters
$credential = Get-Credential
$servers = Import-Csv -Path C:\Users\%%%%%\Desktop\servers-prd-2DO.csv
$Logfile = "C:\Users\%%%%%%\Desktop\Logging\servers-prd-ok.csv"
$ErrorLogAD = "C:\Users\%%%%%\Desktop\Logging\servers-ad-error.csv"
$ErrorLogWSMAN = "C:\Users\%%%%%\Desktop\Logging\servers-wsman-error.csv"

# CSV File Generate Commands
#Get-Cluster -Name PRD | Get-VM * | where {$_.PowerState -like "PoweredOn*" -and $_.Guest.Hostname -like "*duo.local"} | select Name,@{N="Hostname";E={@($_.Guest.Hostname)}},@{N="PowerState";E={@($_.PowerState)}},@{N="Ethernet0";E={@($_.guest.IPAddress[0])}},@{N="Ethernet1";E={@($_.guest.IPAddress[1])}},@{N="Ethernet2";E={@($_.guest.IPAddress[1])}},@{N="Ethernet3";E={@($_.guest.IPAddress[2])}},VMHost | export-csv -Path servers-prd-2DO.csv
#Get-ADComputer -ResultPageSize 10 -filter * -SearchScope Subtree -SearchBase "ou=servers,ou=Managed Machines,dc=domain,dc=local"


function CheckAD($server){
            try
              {   
                  Write-Host -ForegroundColor Green "Check if $server exists in ActiveDirectory"
                  Get-ADComputer $server
                  return 1
              }
        catch {
                  Write-Host -ForegroundColor Red "$server not found in ActiveDirectory"
                  Write-Output "$server,$_" | Out-File -NoClobber -Append $ErrorLogAD
                  return 0
              }
}

Foreach ($server in $servers)
       {
            try
              {
                $AdCheck = CheckAD($server.Name)
                if ($AdCheck -eq 1)
                  {
                    Write-host -ForegroundColor Yellow "Testing WSman on server " $server.Name
                    Invoke-Command -ComputerName:$server.Name -Credential:$credential -ScriptBlock:{Get-Culture} -ErrorAction SilentlyContinue | Out-Null
                    Write-Output $server.Name | Out-File -NoClobber -Append $Logfile
                  }
              }
         catch
              {
                 Write-Host "Error!!!!"                 
                 Write-Output "$server,$_" | Out-File -NoClobber -Append $ErrorLogWSMAN
              }
       }
