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

function RunEXEProgram ($PogramName) {
    LogInformation "- Executing program $PogramName"
    LogDebug "  Executing program $PogramName"
    $process =  Start-Process -FilePath "$DefaultPrgramPath\$PogramName" -ArgumentList "/install", "/quiet" -PassThru -Wait
    if ($process.HasExited) {
        if ($process.ExitCode -eq 0) {
            LogSuccess "  Installation completed successfully.`n"
        } else {
            LogError "  Installation failed `n"
            ExitFromScript $_.Exception.Message $_.InvocationInfo.ScriptLineNumber $_.CategoryInfo
        }
    } else {
        LogError "  Installation did not complete within the specified timeout.`n"
        ExitFromScript $_.Exception.Message $_.InvocationInfo.ScriptLineNumber $_.CategoryInfo
    }
}

param(
    [Parameter(Position = 0, mandatory)]
    [string]$PogramName
)

RunEXEProgram $PogramName
