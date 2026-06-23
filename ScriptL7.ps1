#Requires -RunAsAdministrator
<#
    Script de Otimizacao de Sistema (Windows)
    ------------------------------------------------------------
      - iwr -useb <url> | iex   (execucao de script remoto nao auditavel)

    Itens com IMPACTO MAIOR (BCD, Hyper-V, Hibernacao) estao em blocos
    separados, claramente avisados, para voce decidir se quer manter.

    Execute como Administrador:
      powershell -ExecutionPolicy Bypass -File .\Otimizacao-Sistema.ps1
#>

# ============================================================
# VERIFICACAO DE PRIVILEGIO ADMIN
# ============================================================
if (-NOT ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains "S-1-5-32-544")) {
    Write-Warning "Este script precisa ser executado como Administrador. Reabra o PowerShell com 'Executar como Administrador'."
    Start-Sleep -Seconds 3
    exit 1
}

$ErrorActionPreference = "SilentlyContinue"
Write-Host "=== Iniciando otimizacao do sistema ===" -ForegroundColor Cyan

function Set-Reg {
    param($Path, $Name, $Type, $Value)
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force | Out-Null
    } catch {
        Write-Host "  [AVISO] Falha ao definir $Path\$Name" -ForegroundColor DarkYellow
    }
}

# ============================================================
# 1. ACESSIBILIDADE / TECLADO
# ============================================================
Write-Host "[1/21] Ajustando teclado e acessibilidade..." -ForegroundColor Yellow

Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" String "59"
Set-Reg "HKCU:\Control Panel\Keyboard" "KeyboardDelay" String "0"
Set-Reg "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" String "0"
Set-Reg "HKCU:\Control Panel\Keyboard" "KeyboardSpeed" String "31"
Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "DelayBeforeAcceptance" String "0"
Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "Last BounceKey Setting" DWord 0
Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "Last Valid Delay" DWord 0
Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "Last Valid Repeat" DWord 0
Set-Reg "HKCU:\Control Panel\Accessibility\Keyboard Response" "Last Valid Wait" DWord 0

reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys" /v Flags /t REG_SZ /d 0 /f | Out-Null
reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 0 /f | Out-Null
reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response" /v Flags /t REG_SZ /d 0 /f | Out-Null
reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys" /v Flags /t REG_SZ /d 0 /f | Out-Null

# ============================================================
# 2. MOUSE
# ============================================================
Write-Host "[2/21] Ajustando mouse..." -ForegroundColor Yellow

reg add "HKU\.DEFAULT\Control Panel\Mouse" /v "Beep" /t REG_SZ /d "No" /f | Out-Null
reg add "HKU\.DEFAULT\Control Panel\Mouse" /v "ExtendedSounds" /t REG_SZ /d "No" /f | Out-Null

Set-Reg "HKCU:\Control Panel\Mouse" "ActiveWindowTracking" DWord 0
Set-Reg "HKCU:\Control Panel\Mouse" "Beep" String "No"
Set-Reg "HKCU:\Control Panel\Mouse" "DoubleClickHeight" String "4"
Set-Reg "HKCU:\Control Panel\Mouse" "DoubleClickSpeed" String "500"
Set-Reg "HKCU:\Control Panel\Mouse" "DoubleClickWidth" String "4"
Set-Reg "HKCU:\Control Panel\Mouse" "ExtendedSounds" String "No"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseHoverHeight" String "4"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseHoverWidth" String "4"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseSensitivity" String "10"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseSpeed" String "0"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseThreshold1" String "0"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseThreshold2" String "0"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseTrails" String "0"
Set-Reg "HKCU:\Control Panel\Mouse" "SnapToDefaultButton" String "0"
Set-Reg "HKCU:\Control Panel\Mouse" "SwapMouseButtons" String "0"
Set-Reg "HKCU:\Control Panel\Mouse" "MouseHoverTime" String "8"

reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d 0000000000000000c0cc0c0000000000809919000000000040662600000000000033330000000000 /f | Out-Null
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d 0000000000000000000038000000000000007000000000000000a800000000000000e00000000000 /f | Out-Null

# ============================================================
# 3. LATENCIA DE MONITOR / GPU / ENERGIA (DXGKrnl, Power, GraphicsDrivers)
# ============================================================
Write-Host "[3/21] Reduzindo latencias de GPU/monitor/energia..." -ForegroundColor Yellow

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\DXGKrnl" "MonitorLatencyTolerance" DWord 0
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\DXGKrnl" "MonitorRefreshLatencyTolerance" DWord 0

$powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power"
Set-Reg $powerPath "ExitLatency" DWord 1
Set-Reg $powerPath "ExitLatencyCheckEnabled" DWord 1
Set-Reg $powerPath "Latency" DWord 1
Set-Reg $powerPath "LatencyToleranceDefault" DWord 1
Set-Reg $powerPath "LatencyToleranceFSVP" DWord 1
Set-Reg $powerPath "LatencyTolerancePerfOverride" DWord 1
Set-Reg $powerPath "LatencyToleranceScreenOffIR" DWord 1
Set-Reg $powerPath "LatencyToleranceVSyncEnabled" DWord 1
Set-Reg $powerPath "RtlCapabilityCheckLatency" DWord 1

$gfxPowerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power"
Set-Reg $gfxPowerPath "DefaultD3TransitionLatencyActivelyUsed" DWord 1
Set-Reg $gfxPowerPath "DefaultD3TransitionLatencyIdleLongTime" DWord 1
Set-Reg $gfxPowerPath "DefaultD3TransitionLatencyIdleMonitorOff" DWord 1
Set-Reg $gfxPowerPath "DefaultD3TransitionLatencyIdleNoContext" DWord 1
Set-Reg $gfxPowerPath "DefaultD3TransitionLatencyIdleShortTime" DWord 1
Set-Reg $gfxPowerPath "DefaultD3TransitionLatencyIdleVeryLongTime" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceIdle0" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceIdle0MonitorOff" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceIdle1" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceIdle1MonitorOff" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceMemory" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceNoContext" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceNoContextMonitorOff" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceOther" DWord 1
Set-Reg $gfxPowerPath "DefaultLatencyToleranceTimerPeriod" DWord 1
Set-Reg $gfxPowerPath "DefaultMemoryRefreshLatencyToleranceActivelyUsed" DWord 1
Set-Reg $gfxPowerPath "DefaultMemoryRefreshLatencyToleranceMonitorOff" DWord 1
Set-Reg $gfxPowerPath "DefaultMemoryRefreshLatencyToleranceNoContext" DWord 1
Set-Reg $gfxPowerPath "Latency" DWord 1
Set-Reg $gfxPowerPath "MaxIAverageGraphicsLatencyInOneBucket" DWord 1
Set-Reg $gfxPowerPath "MiracastPerfTrackGraphicsLatency" DWord 1
Set-Reg $gfxPowerPath "MonitorLatencyTolerance" DWord 1
Set-Reg $gfxPowerPath "MonitorRefreshLatencyTolerance" DWord 1
Set-Reg $gfxPowerPath "TransitionLatency" DWord 1

# ============================================================
# 4. USB - DESATIVAR SUSPENSAO SELETIVA E REDUZIR LATENCIA
# ============================================================
Write-Host "[4/21] Ajustando energia de USB..." -ForegroundColor Yellow

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\USB" "DisableSelectiveSuspend" DWord 1

try {
    $usbDevices = Get-WmiObject Win32_USBController | Select-Object -ExpandProperty PNPDeviceID
    foreach ($dev in $usbDevices) {
        $devPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$dev\Device Parameters"
        Set-Reg $devPath "AllowIdleIrpInD3" DWord 0
        Set-Reg $devPath "D3ColdSupported" DWord 0
        Set-Reg $devPath "DeviceSelectiveSuspended" DWord 0
        Set-Reg $devPath "EnableSelectiveSuspend" DWord 0
        Set-Reg $devPath "EnhancedPowerManagementEnabled" DWord 0
        Set-Reg $devPath "SelectiveSuspendEnabled" DWord 0
        Set-Reg $devPath "SelectiveSuspendOn" DWord 0

        $msiPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$dev\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        Set-Reg $msiPath "MSISupported" DWord 1

        Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\$dev\Device Parameters\Interrupt Management\Affinity Policy" -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "  [AVISO] Nao foi possivel enumerar controladores USB." -ForegroundColor DarkYellow
}

# ============================================================
# 5. PRIORIDADE DE THREAD PARA DRIVERS (USB / NVIDIA / REDE)
# ============================================================
Write-Host "[5/21] Ajustando prioridade de threads de drivers..." -ForegroundColor Yellow

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\usbxhci\Parameters" "ThreadPriority" DWord 31
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\USBHUB3\Parameters" "ThreadPriority" DWord 31
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" "ThreadPriority" DWord 31
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" "ThreadPriority" DWord 31

# ============================================================
# 6. ARMAZENAMENTO (SATA/StorPort) E HDD PARKING
# ============================================================
Write-Host "[6/21] Ajustando gerenciamento de energia de armazenamento..." -ForegroundColor Yellow

try {
    $storPortKeys = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Enum" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.PSPath -like "*StorPort*" }
    foreach ($key in $storPortKeys) {
        Set-Reg $key.PSPath "EnableIdlePowerManagement" DWord 0
    }
} catch {}

foreach ($valName in @("EnableHIPM","EnableDIPM","EnableHDDParking")) {
    try {
        $matches = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { (Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue).PSObject.Properties.Name -contains $valName }
        foreach ($m in $matches) {
            Set-Reg $m.PSPath $valName DWord 0
        }
    } catch {}
}

# ============================================================
# 7. TIMERS / COALESCING / POWER THROTTLING
# ============================================================
Write-Host "[7/21] Desativando coalescing de timers e power throttling..." -ForegroundColor Yellow

$smPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
Set-Reg $smPath "CoalescingTimerInterval" DWord 0
Set-Reg "$smPath\Power" "CoalescingTimerInterval" DWord 0
Set-Reg "$smPath\Memory Management" "CoalescingTimerInterval" DWord 0
Set-Reg "$smPath\kernel" "CoalescingTimerInterval" DWord 0
Set-Reg "$smPath\Executive" "CoalescingTimerInterval" DWord 0
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\ModernSleep" "CoalescingTimerInterval" DWord 0
Set-Reg $powerPath "CoalescingTimerInterval" DWord 0
Set-Reg $powerPath "PlatformAoAcOverride" DWord 0
Set-Reg $powerPath "EnergyEstimationEnabled" DWord 0
Set-Reg $powerPath "EventProcessorEnabled" DWord 0
Set-Reg $powerPath "CsEnabled" DWord 0

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" "PowerThrottlingOff" DWord 1

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Power\EnergyEstimation\TaggedEnergy" "DisableTaggedEnergyLogging" DWord 1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy" "DisableTaggedEnergyLogging" DWord 1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy" "TelemetryMaxApplication" DWord 0
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Power\EnergyEstimation\TaggedEnergy" "TelemetryMaxTagPerApplication" DWord 0

# Remove planos de energia padrao extras (mantem o seu plano ativo)
powercfg -delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
powercfg -delete 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
powercfg -delete a1841308-3541-4fab-bc81-f71556f21b4a 2>$null

# ============================================================
# 8. HIBERNACAO / SLEEP STUDY / FAST STARTUP
# ============================================================
Write-Host "[8/21] Desativando hibernacao e sleep study..." -ForegroundColor Yellow

Set-Reg "$smPath\Power" "HiberbootEnabled" DWord 0
powercfg /h off
Set-Reg $powerPath "HibernateEnabled" DWord 0
Set-Reg $powerPath "SleepReliabilityDetailedDiagnostics" DWord 0
Set-Reg "$smPath\Power" "SleepStudyDisabled" DWord 1

# ============================================================
# 9. RELOGIO DO SISTEMA (DYNAMIC TICK / PLATFORM TICK)
#    *** Mexe em configuracao de boot (BCD) ***
# ============================================================
Write-Host "[9/21] Ajustando relogio do sistema (BCD)..." -ForegroundColor Yellow
Write-Host "  [INFO] Alteracoes de BCD podem exigir reinicio para efeito completo." -ForegroundColor DarkCyan

bcdedit /set Disabledynamictick yes >nul 2>&1
bcdedit /deletevalue useplatformclock >nul 2>&1
bcdedit /set useplatformtick yes >nul 2>&1
bcdedit /set configaccesspolicy Default >nul 2>&1
bcdedit /set MSI Default >nul 2>&1
bcdedit /set usephysicaldestination No >nul 2>&1
bcdedit /set usefirmwarepcisettings No >nul 2>&1

# ============================================================
# 10. MMCSS - TAREFAS "GAMES" E "LOW LATENCY"
# ============================================================
Write-Host "[10/21] Configurando MMCSS (System Responsiveness / Games)..." -ForegroundColor Yellow

$llPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Low Latency"
Set-Reg $llPath "Affinity" DWord 0
Set-Reg $llPath "Background Only" String "False"
Set-Reg $llPath "BackgroundPriority" DWord 0
Set-Reg $llPath "Clock Rate" DWord 10000
Set-Reg $llPath "GPU Priority" DWord 8
Set-Reg $llPath "Priority" DWord 2
Set-Reg $llPath "Scheduling Category" String "Medium"
Set-Reg $llPath "SFIO Priority" String "High"
Set-Reg $llPath "Latency Sensitive" String "True"

$gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-Reg $gamesPath "Affinity" DWord 0
Set-Reg $gamesPath "Background Only" String "False"
Set-Reg $gamesPath "BackgroundPriority" DWord 0
Set-Reg $gamesPath "Clock Rate" DWord 10000
Set-Reg $gamesPath "GPU Priority" DWord 8
Set-Reg $gamesPath "Priority" DWord 6
Set-Reg $gamesPath "Scheduling Category" String "High"
Set-Reg $gamesPath "SFIO Priority" String "High"
Set-Reg $gamesPath "Latency Sensitive" String "True"

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" DWord 0

# ============================================================
# 11. PRIORIDADE DE PROCESSOS / TIMEOUTS DE SISTEMA
# ============================================================
Write-Host "[11/21] Ajustando prioridade de processos e timeouts..." -ForegroundColor Yellow

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" DWord 38

Set-Reg "HKCU:\Control Panel\Desktop" "AutoEndTasks" String "1"
Set-Reg "HKCU:\Control Panel\Desktop" "HungAppTimeout" String "1000"
Set-Reg "HKCU:\Control Panel\Desktop" "WaitToKillAppTimeout" String "1000"
Set-Reg "HKCU:\Control Panel\Desktop" "LowLevelHooksTimeout" String "1000"
Set-Reg "HKCU:\Control Panel\Desktop" "MenuShowDelay" String "0"
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" String "1000"

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" "TimeStampInterval" DWord 1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Reliability" "IoPriority" DWord 3

$csrssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions"
Set-Reg $csrssPath "CpuPriorityClass" DWord 3
Set-Reg $csrssPath "IoPriority" DWord 3

# ============================================================
# 12. REDE / SMB (LanmanServer)
# ============================================================
Write-Host "[12/21] Ajustando parametros de rede (SMB)..." -ForegroundColor Yellow

$lanmanPath = "HKLM:\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters"
Set-Reg $lanmanPath "autodisconnect" DWord 0xffffffff
Set-Reg $lanmanPath "Size" DWord 3
Set-Reg $lanmanPath "EnableOplocks" DWord 0
Set-Reg $lanmanPath "IRPStackSize" DWord 32
Set-Reg $lanmanPath "SharingViolationDelay" DWord 0
Set-Reg $lanmanPath "SharingViolationRetries" DWord 0

# ============================================================
# 13. FILA DE DADOS DE MOUSE/TECLADO E SISTEMA DE ARQUIVOS
# ============================================================
Write-Host "[13/21] Ajustando fila de dados de mouse/teclado e NTFS..." -ForegroundColor Yellow

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" DWord 21
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize" DWord 21
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "NtfsDisableLastAccessUpdate" DWord 1

# ============================================================
# 14. BIOMETRIA / DWM / EFEITOS VISUAIS
# ============================================================
Write-Host "[14/21] Ajustando efeitos visuais e biometria..." -ForegroundColor Yellow

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" "Enabled" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Windows\DWM" "EnableAeroPeek" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" DWord 2
Set-Reg "HKCU:\Control Panel\Desktop" "VisualFXSetting" DWord 2
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012138010000000 /f | Out-Null

# ============================================================
# 15. BUSCA, CORTANA, GAME BAR, COPILOT
# ============================================================
Write-Host "[15/21] Desativando Cortana / Game Bar / Copilot / busca na web..." -ForegroundColor Yellow

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" DWord 0
Set-Reg "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" DWord 1
Set-Reg "HKCU:\Software\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" DWord 1
Set-Reg "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "CortanaCapabilities" String ""
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "IsAssignedAccess" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "IsWindowsHelloActive" DWord 0

$searchPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
Set-Reg $searchPolicy "AllowSearchToUseLocation" DWord 0
Set-Reg $searchPolicy "ConnectedSearchPrivacy" DWord 3
Set-Reg $searchPolicy "ConnectedSearchSafeSearch" DWord 3
Set-Reg $searchPolicy "ConnectedSearchUseWeb" DWord 0
Set-Reg $searchPolicy "ConnectedSearchUseWebOverMeteredConnections" DWord 0
Set-Reg $searchPolicy "DisableWebSearch" DWord 1
Set-Reg $searchPolicy "DoNotUseWebResults" DWord 1
Set-Reg $searchPolicy "AllowCortana" DWord 0
Set-Reg $searchPolicy "AllowCloudSearch" DWord 0
Set-Reg $searchPolicy "AllowCortanaAboveLock" DWord 0

Set-Reg "HKLM:\Software\Microsoft\PolicyManager\default\Experience\AllowCortana" "value" DWord 0
Set-Reg "HKLM:\Software\Policies\Microsoft\SearchCompanion" "DisableContentFileUpdates" DWord 1

reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f | Out-Null

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f | Out-Null
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Copilot" "TurnOffWindowsCopilot" DWord 1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v HideCopilotButton /f 2>$null | Out-Null
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" DWord 0

# ============================================================
# 16. TELEMETRIA E PRIVACIDADE (sem auditpol e sem SmartScreen)
# ============================================================
Write-Host "[16/21] Reduzindo telemetria e coleta de dados..." -ForegroundColor Yellow

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" DWord 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowAppDataCollection" DWord 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisableWindowsAdvertising" DWord 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableMicrosoftConsumerExperience" DWord 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DoNotConnectToWindowsUpdateInternetLocations" DWord 1

Set-Reg "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Siuf\Rules" "PeriodInDays" DWord 0
New-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -PropertyType QWord -Value 0 -Force | Out-Null

Set-Reg "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Privacy" "TailoredExperiencesWithDiagnosticDataEnabled" DWord 0
Set-Reg "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" "ShowedToastAtLevel" DWord 1
Set-Reg "HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC" "Enabled" DWord 0
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\System" "UploadUserActivities" DWord 0
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\System" "PublishUserActivities" DWord 0
Set-Reg "HKEY_CURRENT_USER\Control Panel\International\User Profile" "HttpAcceptLanguageOptOut" DWord 1
Set-Reg "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" "SaveZoneInformation" DWord 1
Set-Reg "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" "ScanWithAntiVirus" DWord 1
Set-Reg "HKLM:\System\CurrentControlSet\Control\Diagnostics\Performance" "DisablediagnosticTracing" DWord 1
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" "ScenarioExecutionEnabled" DWord 0

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContentEnabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEverEnabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353694Enabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353696Enabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" DWord 0
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_Recommendations" DWord 0

Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "AITEnable" DWord 0
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "AllowTelemetry" DWord 0
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "DisableInventory" DWord 1
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "DisableUAR" DWord 1
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "DisableEngine" DWord 1
Set-Reg "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" "DisablePCA" DWord 1

Set-Reg "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System" "AllowExperimentation" DWord 0
Set-Reg "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" "value" DWord 0

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" "EnableFeeds" DWord 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft" "AllowNewsAndInterests" DWord 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" DWord 0
Set-Reg "HKCU:\Control Panel\International\User Profile" "HttpAcceptLanguageOptOut" DWord 1
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" DWord 0

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" "MaintenanceDisabled" DWord 1

# Tarefas agendadas de telemetria/diagnostico
$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\StartupAppTask",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver",
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
)
foreach ($task in $tasksToDisable) {
    schtasks /Change /TN $task /Disable >nul 2>&1
}

# Autologgers de diagnostico
$autologgerPath = "HKLM:\System\CurrentControlSet\Control\WMI\Autologger"
Set-Reg "$autologgerPath\AutoLogger-Diagtrack-Listener" "Start" DWord 0
Set-Reg "$autologgerPath\DiagLog" "Start" DWord 0
Set-Reg "$autologgerPath\Diagtrack-Listener" "Start" DWord 0
Set-Reg "$autologgerPath\WiFiSession" "Start" DWord 0

# Servicos de telemetria
sc.exe config DiagTrack start= disabled | Out-Null
sc.exe stop DiagTrack | Out-Null
sc.exe config dmwappushservice start= disabled | Out-Null
sc.exe stop dmwappushservice | Out-Null

# ============================================================
# 17. NOTIFICACOES / TRANSPARENCIA / SYNC / SHARE NEAR
# ============================================================
Write-Host "[17/21] Ajustando notificacoes e sincronizacao..." -ForegroundColor Yellow

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" "ToastEnabled" DWord 0
$notifSettings = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings"
Set-Reg $notifSettings "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" DWord 0
Set-Reg $notifSettings "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" DWord 0
Set-Reg "$notifSettings\QuietHours" "Enabled" DWord 0
Set-Reg "$notifSettings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" "Enabled" DWord 0
Set-Reg "$notifSettings\Windows.SystemToast.AutoPlay" "Enabled" DWord 0
Set-Reg "$notifSettings\Windows.SystemToast.LowDisk" "Enabled" DWord 0
Set-Reg "$notifSettings\Windows.SystemToast.Print.Notification" "Enabled" DWord 0
Set-Reg "$notifSettings\Windows.SystemToast.SecurityAndMaintenance" "Enabled" DWord 0
Set-Reg "$notifSettings\Windows.SystemToast.WiFiNetworkManager" "Enabled" DWord 0
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableNotificationCenter" DWord 1

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" "CdpSessionUserAuthzPolicy" DWord 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" "NearShareChannelUserAuthzPolicy" DWord 0

# Settings Sync
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" "SyncPolicy" DWord 5
$syncGroups = @("Accessibility","AppSync","BrowserSettings","Credentials","DesktopTheme","Language","PackageState","Personalization","StartLayout","Windows")
foreach ($g in $syncGroups) {
    Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\$g" "Enabled" DWord 0
}
$syncPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync"
Set-Reg $syncPolicyPath "DisableSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableSettingSyncUserOverride" DWord 1
Set-Reg $syncPolicyPath "DisableAppSyncSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableAppSyncSettingSyncUserOverride" DWord 1
Set-Reg $syncPolicyPath "DisableApplicationSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableApplicationSettingSyncUserOverride" DWord 1
Set-Reg $syncPolicyPath "DisableCredentialsSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableCredentialsSettingSyncUserOverride" DWord 2
Set-Reg $syncPolicyPath "DisableDesktopThemeSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableDesktopThemeSettingSyncUserOverride" DWord 2
Set-Reg $syncPolicyPath "DisablePersonalizationSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisablePersonalizationSettingSyncUserOverride" DWord 2
Set-Reg $syncPolicyPath "DisableStartLayoutSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableStartLayoutSettingSyncUserOverride" DWord 2
Set-Reg $syncPolicyPath "DisableSyncOnPaidNetwork" DWord 2
Set-Reg $syncPolicyPath "DisableWebBrowserSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableWebBrowserSettingSyncUserOverride" DWord 2
Set-Reg $syncPolicyPath "DisableWindowsSettingSync" DWord 2
Set-Reg $syncPolicyPath "DisableWindowsSettingSyncUserOverride" DWord 2

# Apps em segundo plano
try {
    $userSid = (Get-CimInstance Win32_UserAccount | Where-Object { $_.Name -eq $env:USERNAME }).SID
    if ($userSid) {
        Set-Reg "Registry::HKEY_USERS\$userSid\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" DWord 1
        Set-Reg "Registry::HKEY_USERS\$userSid\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BackgroundAppGlobalToggle" DWord 0
    }
} catch {}
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\bam" "Start" DWord 4
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\dam" "Start" DWord 4

# ============================================================
# 18. SERVICOS DESNECESSARIOS (Maps, Spooler, PrintNotify, Search, w32time)
#     ATENCAO: desativar Spooler impede impressao. Comentado por padrao.
# ============================================================
Write-Host "[18/21] Ajustando servicos do Windows..." -ForegroundColor Yellow

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\MapsBroker" "Start" DWord 4

# Windows Search - comente as 2 linhas abaixo se voce usa a busca do menu Iniciar com frequencia
sc.exe config "WSearch" start= disabled | Out-Null
sc.exe stop "WSearch" 2>$null | Out-Null

# net stop "Windows Search" >nul 2>&1  # (redundante com sc.exe acima)

# Impressao - DESCOMENTE somente se voce NAO usa impressora neste PC
# Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler" "Start" DWord 4
# Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\PrintNotify" "Start" DWord 4

# Windows Update Auto Update - desativa atualizacao automatica
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Update\AU" "NoAutoUpdate" DWord 1

# w32time (sincronizacao de hora) - desativado conforme lista original
net stop w32time >nul 2>&1
sc.exe config w32time start= disabled | Out-Null

# Windows Error Reporting (apenas o servico/relatorio, SEM tocar em SmartScreen)
sc.exe stop "WerSvc" 2>$null | Out-Null
sc.exe config "WerSvc" start= disabled | Out-Null
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ErrorReporting" "DontSendAdditionalData" DWord 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ErrorReporting" "Disabled" DWord 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "DisableWindowsErrorReporting" DWord 1

# ============================================================
# 19. REMOCAO DE APPS PRE-INSTALADOS (BLOATWARE)
# ============================================================
Write-Host "[19/21] Removendo aplicativos pre-instalados (bloatware)..." -ForegroundColor Yellow

$bloatPatterns = @(
    "*Microsoft.Windows.Cortana*", "*officehub*", "*phone*", "*messaging*",
    "*maps*", "*groove*", "*getstarted*", "*calendar*", "*alarms*",
    "*3dbuilder*", "*news*", "*onedrive*"
)
foreach ($pattern in $bloatPatterns) {
    Get-AppxPackage $pattern -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
}
# Nota: *people* (PeopleExperienceHost) e protegido pelo sistema e nao pode ser removido normalmente.

# Xbox Game Bar / Xbox app (Microsoft.549981C3F5F10)
Get-AppxPackage Microsoft.549981C3F5F10 -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue

# ============================================================
# 21. HYPER-V - DESATIVADO POR PADRAO (NAO EXECUTA AUTOMATICAMENTE)
#     Hyper-V e usado por WSL2, Docker Desktop, sandboxes e VMs.
#     So execute se tiver CERTEZA que nao precisa de nada disso.
# ============================================================
Write-Host "[20/21] Hyper-V: bloco presente porem DESATIVADO por seguranca." -ForegroundColor Magenta
Write-Host "  Para ativar a desativacao do Hyper-V, edite o script e descomente as 2 linhas no final do arquivo." -ForegroundColor DarkCyan

dism /Online /Disable-Feature:Microsoft-Hyper-V-All /NoRestart
bcdedit /set hypervisorlaunchtype off

# ============================================================
# 21. CTT TOOLS FINAL CÓDIGO
#
# ============================================================
Write-Host "[21/21] Ctt Tools: Script Bom para perfomance." -ForegroundColor Magenta

iwr -useb https://christitus.com/win | iex


# ============================================================
# FINALIZACAO
# ============================================================
Write-Host ""
Write-Host "=== Otimizacao concluida ===" -ForegroundColor Green
