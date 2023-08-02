<#
.PREREQUISITE
- Make Sure to create Dir "C:\packages" and download all packages 
    * ActiveMQ with name "apache-activemq-5.18.2"
    * Redis with name "Redis-x64-3.0.504.msi"
    * HostBundle with name "dotnet-hosting-3.1.32-win.exe"
    * Java JDK with name "jdk-19_windows-x64_bin.msi"
    * URL Rewrite with name "rewrite_amd64_en-US.msi"
    
.INPUTS
- Domain to add in iisstart.html

.PARAMETER   Redis_Password 
- redis password to add in redis.windows.conf file

.PARAMETER  Domain
- Domain to add in iisstart.html

.PARAMETER Redis_Database_line
- where database line in redis.windows.conf file

.PARAMETER DefaultAppPath
- wwwroot path where all applications downloaded in

.PARAMETER DefaultPrgramPath
- path that found all programs and packages we need

.PARAMETER RedisConfigFile1 RedisConfigFile2 
- where redis config files installed

.PARAMETER JavaVariable
- java variable name to add new Environment variable

.PARAMETER InetpubPath
- Inetpub path 

.PARAMETER JavaInstallationPath
- where java files installed

.PARAMETER Users
- list of all users you want add to access  DefaultAppPath 

.PARAMETER ActiveMQserviceName
- ActiveMQ service name

.PARAMETER RedisServiceName
- redis service name

.PARAMETER ActiveMQinstallationFile
- activeMQ BAT file to install activeMQ

.PARAMETER RedisProgramName
- redis program

.PARAMETER ActiveMQ_JDK
- Java JDK to install ActiveMQ

.PARAMETER HostBundle
- ASP.NET Core Runtime 3.1.28 version Windows Hosting Bundle

.PARAMETER URLRewrite
- URL Rewrite program name

#>

param(
    # [Parameter(Position = 0, mandatory)]
    # [string]$Redis_Password,
    [Parameter(Position = 1, mandatory)]
    [string]$Domain, 
    [string]$Redis_Database_line = 113,
    
    [string]$DefaultAppPath = "C:\inetpub\wwwroot",
    [string]$DefaultPrgramPath = "C:\packages",
    [string]$RedisConfigFile1 = "C:\Program Files\Redis\redis.windows.conf",
    [string]$RedisConfigFile2 = "C:\Program Files\Redis\redis.windows-service.conf",
    [string]$JavaVariable = "JAVA_HOME",
    [string]$InetpubPath = "C:\inetpub",
    [string]$JavaInstallationPath = "C:\Program Files\Java\jdk-19",
    
    [Collections.Generic.List[Object]]$Users = @("Users","IIS_IUSRS"),
    
    [string]$ActiveMQserviceName = "ActiveMQ",
    [string]$RedisServiceName ="Redis",
    
    [string]$ActiveMQinstallation = "apache-activemq-5.18.2\bin\win64\InstallService.bat",
    [string]$RedisProgramName= "Redis-x64-3.0.504.msi",
    [string]$ActiveMQ_JDK = "jdk-19_windows-x64_bin.msi",
    [string]$HostBundle = "dotnet-hosting-3.1.32-win.exe",
    [string]$URLRewrite = "rewrite_amd64_en-US.msi"
)

$Dirs_Paths = @("root2","root2/gateway","root2/frontend","root2/webchat","root2/uploads")
$App_Details = @(
    #  app name                 | site name         | app path                                 | app pool
    @{ Name = "gateway"     ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\gateway"     ; App_Pool = "gateway"        },
    @{ Name = "webchat"     ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\webchat"     ; App_Pool = "webchatFrontend"},
    @{ Name = "uploads"     ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\uploads"     ; App_Pool = "uploads"        },
    @{ Name = "frontend"    ;   Site = "Public" ;   Path = "$DefaultAppPath\root2\frontend"    ; App_Pool = "frontend"       }
)
$WebSite_Details = @(
    @{Site = "Public"; Path = "$DefaultAppPath\root2"}
    )
$App_Pools = @("gateway","frontend","uploads","webchatFrontend")


function AddUesrToDir ($UserName) {
    $UserInfo = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    LogInformation   "- Adding user '$UserName' "
    New-LocalUser -Name $UserName -NoPassword -ErrorAction SilentlyContinue
    if ( $?) {
        LogDebug   "  adding user '$UserName' "
        LogSuccess "  add user '$UserName' successfully!`n"
    } 
    else {
        LogWarning "  The user '$UserName' exists.`n"
    }
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

function RunMSIProgram ($PogramName) { 
    $msiFilePath = "$DefaultPrgramPath\$PogramName"
    LogInformation "- Executing program $PogramName "
    LogDebug "  executing program $PogramName "
    $process = Start-Process msiexec.exe -ArgumentList "/i `"$msiFilePath`" /qn" -PassThru -Wait
    if ($process.HasExited) {
        if ($process.ExitCode -eq 0) {
            LogSuccess "  Installation completed successfully.`n"
        } else {
            LogError "  Installation failed `n"
            ExitFromScript $_.Exception.Message $_.InvocationInfo.ScriptLineNumber $_.CategoryInfo
        }
    } else {
        LogError "  Installation did not complete within the specified timeout.`n"
    }
}

function RunBatProgram ($PogramName) {
    LogInformation "- Executing program $PogramName"
    LogDebug "  executing program $PogramName"
    Start-Process -FilePath "$DefaultPrgramPath\$PogramName"
    LogSuccess "  execute program $PogramName successfully!`n"
}

function RunExeProgram ($PogramName) {
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

function StartService ($ServiceName) {
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if ($service -eq $null) {
        LogError "  Service '$ServiceName' does not exist.`n"
    } else {
            LogInformation "- Setting service $ServiceName as Automatic"
            Set-Service -Name $ServiceName  -StartupType Automatic
            LogSuccess "  set service $ServiceName as Automatic`n"
            LogInformation "  starting service $ServiceName successfully!"
            Start-Service -Name $ServiceName
            LogSuccess "  started service $ServiceName successfully!`n"
    }
}

function AddContent ($FilePath,$Value) {
    LogInformation "- Adding values $Value "
    LogDebug "  Adding values $Value "
    Add-Content -Path $FilePath -Value $Value
    LogSuccess "  added values $Value successfully!`n"
}

function EditContent ($FilePath,$Value,$Line_Number) {
    LogInformation "- Adding values $Value "
    LogDebug "  Adding values $Value "
    $FileContent = Get-Content -Path $FilePath
    $FileContent[$Line_Number - 1] = $Value
    $FileContent | Set-Content -Path $FilePath
    LogSuccess "  added values $Value successfully!`n"
}

function CreateFolder ($FolderName) {
    LogInformation "- Creating dir $FolderName ..."
    LogDebug "  Creating dir $FolderName ..."
    if (-not (Test-Path -Path $FolderName -PathType Container)) {
        # Create the directory
        New-Item -ItemType Directory -Path $FolderName
        LogSuccess "  Create dir $FolderName successfully!`n"
    }
    else {
        LogWarning "  directory $FolderName already exists.`n"
    }
}

function CreateAppPool ($applicationPoolName) {
    $serverManager = Get-IISServerManager
    $existingAppPool = $serverManager.ApplicationPools | Where-Object { $_.Name -eq $applicationPoolName }
    LogInformation "- Creating application pool $applicationPoolName ..."
    LogDebug "  Creating application pool $applicationPoolName ..."
    if ($existingAppPool -eq $null) {
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

function CreateWebsite($arrOfSitesInfo) {
        $websiteName = $arrOfSitesInfo["Site"]
        $Port = $arrOfSitesInfo["Port"]
        $physicalPath = $arrOfSitesInfo["Path"]
        LogInformation "- Creating website $websiteName ..."
        LogDebug "  Creating website $websiteName ..."
        if (-not (Get-Website -Name "$websiteName" -ErrorAction SilentlyContinue)) {
            New-Website -Name "$websiteName" -PhysicalPath "$physicalPath"  #####
            Start-Website -Name "$websiteName" # check is started
            LogSuccess "  Create website $websiteName successfully!`n"
        }
        else {
            LogWarning "  website already exists.`n"
        }
}

function CreateApplication($arrOfAppInfo) {
    $Name = $arrOfAppInfo["Name"]
    $App =  Get-WebApplication -Site $arrOfAppInfo["Site"] -Name $arrOfAppInfo["Name"]
    LogInformation "- Creating app $Name ..."
    LogDebug "  Creating app $Name ..."
    if ($App -ne $null) {
        LogWarning "  The application $Name  exists in IIS.`n"
    } else {
        New-WebApplication -Name $arrOfAppInfo["Name"]  -Site $arrOfAppInfo["Site"] -PhysicalPath $arrOfAppInfo["Path"] -ApplicationPool $arrOfAppInfo["App_Pool"]
        LogSuccess "  Create website $Name successfully!`n"
    }
}

function AddDomainTohtml($FilePath,$Content){   
    LogInformation "- Adding domain  ..."         
    LogDebug "  Adding domain  ..."         
    [System.IO.File]::ReadAllText($FilePath)
    [System.IO.File]::WriteAllText($FilePath, "")
    AddContent $FilePath  $Content
    LogSuccess "  Added domain  ...`n"  
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

#===============================================================
try{  
    Import-Module WebAdministration

    # install IIS
    DownloadFeature "Web-Server"

    # WebSocket Protocol
    DownloadFeature "Web-WebSockets"
    
    # Media Foundation
    DownloadFeature "Server-Media-Foundation"

    DownloadFeature "Web-Asp-Net"

    DownloadFeature "Web-Net-Ext"

    # Host bundle
    RunExeProgram $HostBundle

    RunMSIProgram $URLRewrite

    cd $DefaultAppPath -ErrorAction Stop
    LogInformation "- Go to $DefaultAppPath"
    
    # Create dirs
    for($i = 0; $i -lt $Dirs_Paths.length; $i++){ 
        CreateFolder($Dirs_Paths[$i])
    }

    #Create App Pools
    for($i = 0; $i -lt $App_Pools.length; $i++){ 
        CreateAppPool $App_Pools[$i]
    }

    #Create WebSites
    foreach ($args in $WebSite_Details) {
        CreateWebsite $args
    }

    #Create Apps
    foreach ($args in $App_Details) {
        CreateApplication      $args
    }

    #Add users and permissions
    foreach ($user in $Users){
        AddUesrToDir            $user
        AddFullPermissionToDir $InetpubPath $user
    }

    #ActiveMQ 
    # RunMSIProgram  $ActiveMQ_JDK
    # # system and Environment var
    # LogInformation "  adding system and Environment var for JAVA ..."
    # $Dirs_Paths = @("root","root2","root/backend","root/bot","root/inbox","root/webchat","root/analytics","root/auth","root/integrations","root2/gateway","root2/frontend","root2/webchat","root2/uploads")
    # LogDebug       "  adding system and Environment var for JAVA ..."
    # [Environment]::SetEnvironmentVariable($JavaVariable,$JavaInstallationPath, "User")
    # Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name $JavaVariable -Value $JavaInstallationPath
    # $env:JAVA_HOME = $JavaInstallationPath
    # LogSuccess     "  added system and Environment var for JAVA successfully! ... `n"

    # RunBatProgram $ActiveMQinstallation

    # StartService  $ActiveMQserviceName

    # #===================================================

    # #Redis
    # RunMSIProgram  $RedisProgramName
    # StartService   $RedisServiceName
    # $Files_Paths = @($RedisConfigFile1,$RedisConfigFile2)
    # for($i = 0; $i -lt $Files_Paths.length; $i++){ 
    #     AddContent  $Files_Paths[$i] "requirepass $Redis_Password"
    #     AddContent  $Files_Paths[$i] "bind  0.0.0.0"
    #     EditContent $Files_Paths[$i] "databases 30" $Redis_Database_line
    # }

    # Add content to iisstart.html
    AddDomainTohtml "$DefaultAppPath\iisstart.htm" "window.location.href = `"$Domain`";`n"  

    Write-Host "Press Enter to continue...`n"
    $null = Read-Host
}
catch{
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
















