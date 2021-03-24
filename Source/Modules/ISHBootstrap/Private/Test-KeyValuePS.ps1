<#
.Synopsis
   Test a key in json file
.DESCRIPTION
   Test if a key or folder exists in json file
.EXAMPLE
   Test-KeyValuePS -Uri uri -Key key
.EXAMPLE
   Test-KeyValuePS -Uri uri -Folder folder
.EXAMPLE
   Test-KeyValuePS -Uri uri -Folder folder -Empty
#>
Function Test-KeyValuePS {
    [OutputType([Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="Key")]
        [string]$Key,
        [Parameter(Mandatory=$true,ParameterSetName="Folder")]
        [string]$Folder,
        [Parameter(Mandatory=$true,ParameterSetName="Key")]
        [Parameter(Mandatory=$true,ParameterSetName="Folder")]
        [ValidateScript( {
            if (-Not ($_ | Test-Path -PathType Leaf) ) {
                throw "The Path argument must be an existing file."
            }
            return $true
        })]
        [string]$FilePath,
        [Parameter(Mandatory=$false,ParameterSetName="Folder")]
        [switch]$Empty=$false
    )

    begin {
        Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        foreach($psbp in $PSBoundParameters.GetEnumerator()){Write-Debug "$($psbp.Key)=$($psbp.Value)"}

        $newBoundParameters=@{} + $PSBoundParameters
        $null=$newBoundParameters.Remove('Key')
        $null=$newBoundParameters.Remove('Folder')
        $null=$newBoundParameters.Remove('Empty')
    }

    process {
        try{
            switch ($PSCmdlet.ParameterSetName)
            {
                'Key' {
                    $result= Get-KeyValuePS -Key $Key -FilePath $FilePath -Recurse -ErrorAction SilentlyContinue
                    $null -ne $result
                }
                'Folder' {
                    $result= Get-KeyValuePS -Key $Folder -FilePath $FilePath -Recurse -ErrorAction SilentlyContinue
                    if($Empty)
                    {
                        "" -eq $result.Value
                    }
                    else
                    {
                        $null -ne $result
                    }
                }
            }
        }
        catch {
            $false
        }
    }

    end {

    }
}