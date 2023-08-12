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



#################   First usage #################
function CreateWebsite($Site,$Port,$Path) {
    LogInformation "- Creating website $websiteName ..."
    LogDebug "  Creating website $websiteName ..."
    if (-not (Get-Website -Name "$websiteName" -ErrorAction SilentlyContinue)) {
        New-Website -Name "$websiteName" -PhysicalPath "$Path" -Port $Port  #####
        Start-Website -Name "$websiteName" # check is started
        LogSuccess "  Create website $websiteName successfully!`n"
    }
    else {
        LogWarning "  website already exists.`n"
    }
}
param(
    [Parameter(Position = 0, mandatory)]
    [string]$Site,
    [Parameter(Position = 1, mandatory)]
    [string]$Port,
    [Parameter(Position = 2, mandatory)]
    [string]$Path
    )

    CreateWebsite $Site $Port $Path

#################   second usage #################
function CreateWebsite($arrOfSitesInfo) {
    $websiteName = $arrOfSitesInfo["Site"]
    $Port = $arrOfSitesInfo["Port"]
    $physicalPath = $arrOfSitesInfo["Path"]
    LogInformation "- Creating website $websiteName ..."
    LogDebug "  Creating website $websiteName ..."
    if (-not (Get-Website -Name "$websiteName" -ErrorAction SilentlyContinue)) {
        New-Website -Name "$websiteName" -PhysicalPath "$physicalPath" -Port $Port  #####
        Start-Website -Name "$websiteName" # check is started
        LogSuccess "  Create website $websiteName successfully!`n"
    }
    else {
        LogWarning "  website already exists.`n"
    }
}

$WebSite_Details = @(
    @{Site = "Public" ; Port = 80  ; Path = "path\root2"},
    @{Site = "Private"; Port = 8080; Path = "path\root" }
    )

foreach ($args in $WebSite_Details) {
    CreateWebsite $args
}