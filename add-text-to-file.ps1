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

function AddContent ($FilePath,$Value) {
    LogInformation "- Adding values $Value "
    LogDebug "  Adding values $Value "
    Add-Content -Path $FilePath -Value $Value
    LogSuccess "  added values $Value successfully!`n"
}

param(
    [Parameter(Position = 0, mandatory)]
    [string]$FilePath,
    [Parameter(Position = 1, mandatory)]
    [string]$Value
    )

AddContent $FilePath $Value