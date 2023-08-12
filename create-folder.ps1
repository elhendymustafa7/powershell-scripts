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

function CreateFolder ($FolderName) {
    LogInformation "- Creating dir $FolderName ..."
    LogDebug "  Creating dir $FolderName ..."
    if (-not (Test-Path -Path $FolderName -PathType Container)) {
        New-Item -ItemType Directory -Path $FolderName
        LogSuccess "  Create dir $FolderName successfully!`n"
    }
    else {
        LogWarning "  directory $FolderName already exists.`n"
    }
}


#################   First usage #################
param(
    [Parameter(Position = 0, mandatory)]
    [string]$FolderName
    )

CreateFolder $FolderName

#################   second usage #################

$Dirs_Paths = @("path/folder1","path/folder2")

for($i = 0; $i -lt $Dirs_Paths.length; $i++){ 
    CreateFolder($Dirs_Paths[$i])
}
