
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

function AddNewUesr ($UserName) {
    LogInformation   "Adding user '$UserName' "
    New-LocalUser -Name $UserName -NoPassword -ErrorAction SilentlyContinue
    if ( $?) {
        LogDebug   "Adding user '$UserName' "
        LogSuccess "Add user '$UserName' successfully!`n"
    } 
    else {
        LogWarning "The user '$UserName' exists.`n"
    }
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

$Users = @("Users","IIS_IUSRS")

foreach ($user in $Users){
    AddUesrToDir            $user
}
