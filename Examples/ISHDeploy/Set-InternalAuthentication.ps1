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
    [Parameter(Mandatory=$false)]
    [pscredential]$Credential=$null,
    [Parameter(Mandatory=$true)]
    [string]$DeploymentName
)
$ishBootStrapRootPath=Resolve-Path "$PSScriptRoot\..\.."
$cmdletsPaths="$ishBootStrapRootPath\Source\Cmdlets"
$serverScriptsPaths="$ishBootStrapRootPath\Source\Server"

. $ishBootStrapRootPath\Examples\ISHDeploy\Cmdlets\Write-Separator.ps1
Write-Separator -Invocation $MyInvocation -Header -Name "Configure"
. "$cmdletsPaths\Helpers\Get-ProgressHash.ps1"
$scriptProgress=Get-ProgressHash -Invocation $MyInvocation

if(-not $Computer)
{
    & "$serverScriptsPaths\Helpers\Test-Administrator.ps1"
}

if(-not (Get-Command Invoke-CommandWrap -ErrorAction SilentlyContinue))
{
    . $cmdletsPaths\Helpers\Invoke-CommandWrap.ps1
}        

$internalAuthenticationScriptBlock= {
    Enable-ISHIntegrationSTSInternalAuthentication -ISHDeployment $DeploymentName
    Write-Host "Internal authentication enabled"
}


#Install the packages
try
{
    $blockName="Enabling internal authentication on $DeploymentName"
    Write-Progress @scriptProgress -Status $blockName
    Invoke-CommandWrap -ComputerName $Computer -Credential $Credential -ScriptBlock $internalAuthenticationScriptBlock -BlockName $blockName -UseParameters @("DeploymentName")
}
finally
{

}

Write-Progress @scriptProgress -Completed
Write-Separator -Invocation $MyInvocation -Footer -Name "Configure"
