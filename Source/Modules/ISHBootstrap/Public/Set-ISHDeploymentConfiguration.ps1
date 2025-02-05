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

<#
.Synopsis
    Add database configuration for project/stage.
.DESCRIPTION
    Add new section with database configuration for selected for project/stage.
.PARAMETER ConfigFilePath
    Path to json configuration file.
.PARAMETER ISHBootstrapVersion
    Version of ISHBootstrap module.
.PARAMETER Project
    A project name. Indicates how this configuration will be referenced in a recipe.
.PARAMETER Stage
    Stage of a project. (e.g. Dev, Test, Prod, etc.)
    Similar to project will be used as a part of configuration reference in recipe.
.PARAMETER DataSource
    Database source. By default databasesource deployment parameter will be used.
.PARAMETER InitialCatalog
    Database name. By default databasename deployment parameter will be used.
.PARAMETER Username
    Database user name. By default databaseuser deployment parameter will be used.
.PARAMETER Password
    Database user password. By default databasepassword deployment parameter will be used.
.PARAMETER Type
    Database type. By default databasetype deployment parameter will be used.
.EXAMPLE
    Set-ISHDeploymentConfiguration -ConfigFilePath configfilepath -ISHBootstrapVersion 2.0 -Project project -Stage stage
.EXAMPLE
    Set-ISHDeploymentConfiguration -ConfigFilePath configfilepath -ISHBootstrapVersion 2.0 -Project project -Stage stage -DataSource datasource -InitialCatalog db -Username user -Password pass -Type sqlserver2017
#>
Function Set-ISHDeploymentConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateScript( { Test-Path $_ })]
        [string]$ConfigFilePath = $((Get-Variable -Name "ISHDeploymentConfigFilePath").Value),
        [Parameter(Mandatory = $false)]
        [string]$ISHBootstrapVersion = "ISHBootstrap.2.0.0",
        [Parameter(Mandatory = $true)]
        [string]$Project,
        [Parameter(Mandatory = $true, HelpMessage = "The Tridion Docs stage (environment), e.g. Development, Acceptance, Production")]
        [string]$Stage,
        [Parameter(Mandatory = $false)]
        [string]$DataSource = $(Get-ISHDeploymentParameters -Name databasesource).Value,
        [Parameter(Mandatory = $false)]
        [string]$InitialCatalog = $(Get-ISHDeploymentParameters -Name databasename).Value,
        [Parameter(Mandatory = $false)]
        [string]$Username = $(Get-ISHDeploymentParameters -Name databaseuser).Value,
        [Parameter(Mandatory = $false)]
        [string]$Password = $(Get-ISHDeploymentParameters -Name databasepassword -ShowPassword).Value,
        [Parameter(Mandatory = $false)]
        [string]$Type = $(Get-ISHDeploymentParameters -Name databasetype).Value
    )

    begin {
        Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        foreach ($psbp in $PSBoundParameters.GetEnumerator()) { Write-Debug "$($psbp.Key)=$($psbp.Value)" }
    }

    process {
        $keyValues = Get-Content -Raw -Path $ConfigFilePath | ConvertFrom-Json
        Write-Verbose "Reed $ConfigFilePath"
        if (-not $keyValues.$ISHBootstrapVersion.Project.$Project.$Stage ) {
            throw "Project/Stage $Project/$Stage does not exist. Use New-Project.ps1"
        }

        $dbKV = @{
            DataSource     = $DataSource
            InitialCatalog = $InitialCatalog
            Username       = $Username
            Password       = $Password
            Type           = $Type
        }

        $path = $keyValues.$ISHBootstrapVersion.Project.$Project.$Stage.ISH
        foreach ($i in @('Integration', 'Database', 'SQLServer')) {
            if (-not $path.$i) {
                $path | Add-Member -MemberType NoteProperty -Name $i -Value ([pscustomobject]@{ })
            }
            $path = $path.$i
        }
        $keyValues.$ISHBootstrapVersion.Project.$Project.$Stage.ISH.Integration.Database.SQLServer = $dbKV

        ConvertTo-Json $keyValues -Depth 30 | Format-Json | Out-File -FilePath $ConfigFilePath
        Write-Verbose "Updated $ConfigFilePath"

        Set-Tag -Name "CodeVersion" -Value $ISHBootstrapVersion
        Set-Tag -Name "Project" -Value $Project
        Set-Tag -Name "Stage" -Value $Stage
    }

    end {

    }
}
