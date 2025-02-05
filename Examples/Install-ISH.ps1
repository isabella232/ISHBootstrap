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

if ($PSBoundParameters['Debug']) {
    $DebugPreference = 'Continue'
}

$sourcePath=Resolve-Path "$PSScriptRoot\..\Source"
$cmdletsPaths="$sourcePath\Cmdlets"
$serverScriptsPaths="$sourcePath\Server"

. "$PSScriptRoot\Cmdlets\Get-ISHBootstrapperContextValue.ps1"
$computerName=Get-ISHBootstrapperContextValue -ValuePath "ComputerName" -DefaultValue $null
$credential=Get-ISHBootstrapperContextValue -ValuePath "CredentialExpression" -Invoke

$ishVersion=Get-ISHBootstrapperContextValue -ValuePath "ISHVersion"

. "$cmdletsPaths\Helpers\Invoke-CommandWrap.ps1"

$ishDeployments=Get-ISHBootstrapperContextValue -ValuePath "ISHDeployment"
$osUserCredential=Get-ISHBootstrapperContextValue -ValuePath "OSUserCredentialExpression" -Invoke

try
{
    if(-not $computerName)
    {
        & "$serverScriptsPaths\Helpers\Test-Administrator.ps1"
    }
    foreach($ishDeployment in $ishDeployments)
    {
        $hash=@{
            ISHVersion=$ishVersion
            OSUserCredential=$osUserCredential
            ConnectionString=$ishDeployment.ConnectionString
            IsOracle=$ishDeployment.IsOracle
            Name=$ishDeployment.Name
            LucenePort=$ishDeployment.LucenePort
            UseRelativePaths=$ishDeployment.UseRelativePaths
        }

        Write-Debug "Installing $($ishDeployment.Name) from $cdPath"
        & $serverScriptsPaths\Install\Install-ISHDeployment.ps1 -Computer $computerName -Credential $credential @hash
        Write-Verbose "Installed $($ishDeployment.Name) from $cdPath"
    }

    Write-Debug "Configuring IIS Applications for RequireSSL"
    & $serverScriptsPaths\IIS\Set-IISRequireSSL.ps1 -Computer $computerName -Credential $credential
    Write-Verbose "Configured IIS Applications for RequireSSL"
}
finally
{
}
