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

function CreateApplication($arrOfAppInfo) {
    $Name = $arrOfAppInfo["Name"]
    $App =  Get-WebApplication -Site $arrOfAppInfo["Site"] -Name $arrOfAppInfo["Name"]
    LogInformation "- Creating app $Name ..."
    LogDebug "  Creating app $Name ..."
    if ($null -ne $App) {
        LogWarning "  The application $Name  exists in IIS.`n"
    } else {
        New-WebApplication -Name $arrOfAppInfo["Name"]  -Site $arrOfAppInfo["Site"] -PhysicalPath $arrOfAppInfo["Path"] -ApplicationPool $arrOfAppInfo["App_Pool"]
        LogSuccess "  Create website $Name successfully!`n"
    }
}

$App_Details = @(
    #  app name                 | site name         | app path                                 | app pool
    @{ Name = "integrations";   Site = "Private";   Path = "$DefaultAppPath\root\integrations" ; App_Pool = "integrations"   },
    @{ Name = "analytics"   ;   Site = "Private";   Path = "$DefaultAppPath\root\analytics"    ; App_Pool = "analytics"      },
    @{ Name = "backend"     ;   Site = "Private";   Path = "$DefaultAppPath\root\backend"      ; App_Pool = "backend"        },
    @{ Name = "webchat"     ;   Site = "Private";   Path = "$DefaultAppPath\root\webchat"      ; App_Pool = "webchatBackend" },
    @{ Name = "inbox"       ;   Site = "Private";   Path = "$DefaultAppPath\root\inbox"        ; App_Pool = "inbox"          },
    @{ Name = "auth"        ;   Site = "Private";   Path = "$DefaultAppPath\root\auth"         ; App_Pool = "auth"           },
    @{ Name = "bot"         ;   Site = "Private";   Path = "$DefaultAppPath\root\bot"          ; App_Pool = "bot"            },
    @{ Name = "gateway"     ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\gateway"     ; App_Pool = "gateway"        },
    @{ Name = "webchat"     ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\webchat"     ; App_Pool = "webchatFrontend"},
    @{ Name = "uploads"     ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\uploads"     ; App_Pool = "uploads"        },
    @{ Name = "frontend"    ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\frontend"    ; App_Pool = "frontend"       }
)

foreach ($args in $App_Details) {
    CreateApplication      $args
}