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

function CreateAppPool ($applicationPoolName) {
    $serverManager = Get-IISServerManager
    $existingAppPool = $serverManager.ApplicationPools | Where-Object { $_.Name -eq $applicationPoolName }
    LogInformation "- Creating application pool $applicationPoolName ..."
    LogDebug "  Creating application pool $applicationPoolName ..."
    if ($null -eq $existingAppPool) {
        $newAppPool = $serverManager.ApplicationPools.Add($applicationPoolName)
        $newAppPool.ManagedRuntimeVersion = "v4.0"
        $newAppPool.ManagedPipelineMode = "Integrated"
        $serverManager.CommitChanges()
        LogSuccess "  Create application pool $applicationPoolName successfully!`n"
    }
    else {
        LogWarning "  Application pool $applicationPoolName already exists.`n"
    }
    
}
#################   First usage #################
param(
    [Parameter(Position = 0, mandatory)]
    [string]$applicationPoolName
    )

CreateAppPool $applicationPoolName

#################   second usage #################
$Apps_Pool = @("gateway","frontend","uploads","backend","inbox","bot","webchatBackend","analytics","auth","integrations","webchatFrontend")

for($i = 0; $i -lt $Apps_Pool.length; $i++){ 
    CreateAppPool $Apps_Pool[$i]
}
