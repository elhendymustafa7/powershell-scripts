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

function AddFullPermissionToDir ($FolderPath,$UserName){
    $ACLsForFolder = Get-Acl -Path $FolderPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserName, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
    $ACLsForFolder.AddAccessRule($accessRule)
    Set-Acl -Path $FolderPath -AclObject $ACLsForFolder
    LogInformation   "- Giving user '$UserName' full permissions "
    LogDebug   "  giving user '$UserName' full permissions "
    LogSuccess "  giving user '$UserName' full permissions successfully!`n"
}

$Users = @("Users","IIS_IUSRS")


foreach ($user in $Users){
    AddFullPermissionToDir $InetpubPath $user
}