<#
# Copyright (c) 2021 All Rights Reserved by the RWS Group for and on behalf of its affiliates and subsidiaries.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#>

param (
    [Parameter(Mandatory=$false)]
    [string]$Computer,
    [Parameter(Mandatory=$true)]
    [PSCredential]$OSUserCredential,
    [Parameter(Mandatory=$true)]
    [ValidateSet("12","13","14","15")]
    [string]$ISHServerVersion
)    
$cmdletsPaths="$PSScriptRoot\..\..\Cmdlets"

. "$cmdletsPaths\Helpers\Write-Separator.ps1"
. "$cmdletsPaths\Helpers\Get-ProgressHash.ps1"
Write-Separator -Invocation $MyInvocation -Header
$scriptProgress=Get-ProgressHash -Invocation $MyInvocation

. "$cmdletsPaths\Helpers\Invoke-CommandWrap.ps1"

if($Computer)
{
    . $cmdletsPaths\Helpers\Add-ModuleFromRemote.ps1
    . $cmdletsPaths\Helpers\Remove-ModuleFromRemote.ps1
}


try
{
    if($Computer)
    {
        $ishServerModuleName="ISHServer.$ISHServerVersion"
        $session=New-PSSession -ComputerName $Computer -Credential $OSUserCredential
        $remote=Add-ModuleFromRemote -Session $session -Name $ishServerModuleName

        Write-Progress @scriptProgress -Status "Initializing regional settings"
        Initialize-ISHRegional
    }
    else
    {
        $session=$null

        Write-Progress @scriptProgress -Status "Initializing regional settings"
        # Initialize-ISHRegional needs to execute from the osuser's context.
        $arguments=@(
            "-Command"
            "Initialize-ISHRegional"
        )
        $powerShellPath=& C:\Windows\System32\where.exe powershell

        Start-Process -FilePath $powerShellPath -ArgumentList $arguments -Credential $OSUserCredential -LoadUserProfile -NoNewWindow  -Wait
    }

}

finally
{
    if($Computer)
    {
        Remove-ModuleFromRemote -Remote $remote
        $session|Remove-PSSession
    }
}

Write-Progress @scriptProgress -Completed
Write-Separator -Invocation $MyInvocation -Footer
