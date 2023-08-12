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

function AddEnvSystemVar ($var,$value){
    LogInformation "  adding system and Environment var  ..."
    LogDebug       "  adding system and Environment var  ..."
    [Environment]::SetEnvironmentVariable($var,$value, "User")
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name $var -Value $value
    $env:var = $value
    LogSuccess     "  added system and Environment var  successfully! ... `n"
}

param(
    [Parameter(Position = 0, mandatory)]
    [string]$var,
    [Parameter(Position = 0, mandatory)]
    [string]$value
    )

AddEnvSystemVar $var $value