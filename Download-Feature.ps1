function LogDebug($message) {
    Write-Host -ForegroundColor DarkGray $message
}

function LogInformation($message) {
    Write-Host -ForegroundColor Cyan $message
}

function LogSuccess($message) {
    Write-Host -ForegroundColor Green $message
}

function LogWarning($message) {
    Write-Host -ForegroundColor Yellow $message
}

function LogError($message) {
    Write-Host -ForegroundColor Red $message
}

function ExitFromScript($message,$line,$details) {
    $message = $_.Exception.Message
    $line = $_.InvocationInfo.ScriptLineNumber
    $details = $_.CategoryInfo 
    LogError "An Error has occurred: $message 
        `nline: $line
        `nError Details: $details"
    LogWarning "Stopping the script.`n"
    LogWarning "Press any key...`n"
    $null = Read-Host
    Exit
}

function DownloadFeature ($FeatureName) {
    $Feature = Get-WindowsFeature -Name $FeatureName
    LogInformation "- Installing $FeatureName ..."
    LogDebug "  Installing $FeatureName ..."
    if ($Feature.Installed) {
        LogWarning "  $FeatureName is exist.`n"
    } else {
        Install-WindowsFeature -Name $FeatureName
        LogSuccess "  $FeatureName is installed successfully!`n"
    }
}

param(
    [Parameter(Position = 0, mandatory)]
    [string]$FeatureName
    )

DownloadFeature $FeatureName