﻿param (
    [Parameter(Mandatory=$false)]
    [string]$Computer,
    [Parameter(Mandatory=$true)]
    [string]$DeploymentName,
    [Parameter(Mandatory=$true)]
    [string]$ISHVersion    
)
$ishBootStrapRootPath="C:\GitHub\ISHBootstrap"
$cmdletsPaths="$ishBootStrapRootPath\Source\Cmdlets"
$scriptsPaths="$ishBootStrapRootPath\Source\Scripts"

if(-not $Computer)
{
    & "$scriptsPaths\Helpers\Test-Administrator.ps1"
}

if(-not (Get-Command Invoke-ImplicitRemoting -ErrorAction SilentlyContinue))
{
    . $cmdletsPaths\Helpers\Invoke-ImplicitRemoting.ps1
}        

try
{
    $undoBlock={
        Undo-ISHDeployment -ISHDeployment $DeploymentName
        Clear-ISHDeploymentHistory -ISHDeployment $DeploymentName
    }

    $ishDelpoyModuleName="ISHDeploy.$ISHVersion"
    Invoke-ImplicitRemoting -ScriptBlock $undoBlock -BlockName "Undo deployment" -ComputerName $computerName -ImportModule $ishDelpoyModuleName
}
finally
{
}
