# Ultimate Robocopy Tool
# Aufruf: iex (irm https://deinserver.com/robocopy.ps1)

param(
    [string]$QuickMode = "",
    [string]$Source = "",
    [string]$Destination = ""
)

# Farben für die Ausgabe
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Banner
Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                                  v2.0 - 2025                                    ║
║                         Erstellt für maximale Effizienz                         ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

# Hauptfunktion
function Show-Menu {
    Write-Host "`n" -NoNewline
    Write-Host "┌─────────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "│                                 HAUPTMENÜ                                      │" -ForegroundColor Yellow
    Write-Host "├─────────────────────────────────────────────────────────────────────────────────┤" -ForegroundColor Yellow
    Write-Host "│  1. 🎯 Geführte Robocopy-Konfiguration                                         │" -ForegroundColor White
    Write-Host "│  2. ⚡ Schnellmodus (Vordefinierte Profile)                                     │" -ForegroundColor White
    Write-Host "│  3. 📊 Robocopy-Logs analysieren                                               │" -ForegroundColor White
    Write-Host "│  4. 🔧 Erweiterte Optionen                                                     │" -ForegroundColor White
    Write-Host "│  5. 💾 Backup-Assistent                                                        │" -ForegroundColor White
    Write-Host "│  6. 🌐 Netzwerk-Sync                                                           │" -ForegroundColor White
    Write-Host "│  7. 📈 Performance-Monitor                                                     │" -ForegroundColor White
    Write-Host "│  8. ❓ Hilfe & Tipps                                                           │" -ForegroundColor White
    Write-Host "│  9. 🚪 Beenden                                                                 │" -ForegroundColor White
    Write-Host "└─────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
}

# Eingabe mit Validation
function Get-ValidPath {
    param(
        [string]$Prompt,
        [bool]$MustExist = $true
    )
    
    do {
        $path = Read-Host $Prompt
        if ($path -eq "") {
            Write-Host "❌ Pfad darf nicht leer sein!" -ForegroundColor Red
            continue
        }
        
        if ($MustExist -and -not (Test-Path $path)) {
            Write-Host "❌ Pfad existiert nicht: $path" -ForegroundColor Red
            $create = Read-Host "Soll der Pfad erstellt werden? (j/n)"
            if ($create -eq "j" -or $create -eq "y") {
                try {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                    Write-Host "✅ Pfad erstellt: $path" -ForegroundColor Green
                    return $path
                } catch {
                    Write-Host "❌ Fehler beim Erstellen: $($_.Exception.Message)" -ForegroundColor Red
                    continue
                }
            } else {
                continue
            }
        }
        
        return $path
    } while ($true)
}

# Geführte Konfiguration
function Start-GuidedConfiguration {
    Clear-Host
    Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
    
    Write-Host "`n🎯 GEFÜHRTE ROBOCOPY-KONFIGURATION" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    # Quell- und Zielpfad
    $source = Get-ValidPath "📁 Quellpfad eingeben"
    $destination = Get-ValidPath "📁 Zielpfad eingeben" -MustExist $false
    
    # Basis-Optionen
    Write-Host "`n🔧 KOPIEROPTIONEN" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    
    $options = @()
    
    # Unterverzeichnisse
    $subdirs = Read-Host "Unterverzeichnisse kopieren? (j/n) [Standard: j]"
    if ($subdirs -ne "n") { $options += "/S" }
    
    # Leere Verzeichnisse
    $empty = Read-Host "Leere Verzeichnisse kopieren? (j/n) [Standard: n]"
    if ($empty -eq "j") { $options += "/E" }
    
    # Überschreibmodus
    Write-Host "`n📋 ÜBERSCHREIBMODUS:" -ForegroundColor Green
    Write-Host "1. Neuere Dateien überschreiben (Standard)"
    Write-Host "2. Alle Dateien überschreiben"
    Write-Host "3. Nur fehlende Dateien kopieren"
    $overwrite = Read-Host "Auswahl (1-3)"
    
    switch ($overwrite) {
        "2" { $options += "/IS" }
        "3" { $options += "/XC", "/XN", "/XO" }
    }
    
    # Erweiterte Optionen
    Write-Host "`n⚙️ ERWEITERTE OPTIONEN" -ForegroundColor Magenta
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Magenta
    
    $retry = Read-Host "Anzahl Wiederholungen bei Fehlern [Standard: 3]"
    if ($retry -eq "") { $retry = "3" }
    $options += "/R:$retry"
    
    $wait = Read-Host "Wartezeit zwischen Wiederholungen in Sekunden [Standard: 30]"
    if ($wait -eq "") { $wait = "30" }
    $options += "/W:$wait"
    
    # Multithreading
    $threads = Read-Host "Anzahl Threads für bessere Performance [Standard: 8]"
    if ($threads -eq "") { $threads = "8" }
    $options += "/MT:$threads"
    
    # Logging
    $log = Read-Host "Detailliertes Log erstellen? (j/n) [Standard: j]"
    if ($log -ne "n") {
        $logPath = "$env:TEMP\robocopy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        $options += "/LOG:$logPath"
        $options += "/V", "/TS", "/FP"
    }
    
    # Fortschrittsanzeige
    $options += "/NDL", "/NP"
    
    # Befehl generieren
    $command = "robocopy `"$source`" `"$destination`" " + ($options -join " ")
    
    # Vorschau
    Write-Host "`n🎯 GENERIERTER BEFEHL:" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host $command -ForegroundColor Yellow
    
    # Geschätzte Informationen
    if (Test-Path $source) {
        $sourceSize = (Get-ChildItem $source -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $sourceSizeGB = [math]::Round($sourceSize / 1GB, 2)
        $fileCount = (Get-ChildItem $source -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        
        Write-Host "`n📊 QUELLVERZEICHNIS-INFORMATIONEN:" -ForegroundColor Green
        Write-Host "   Dateigröße: $sourceSizeGB GB"
        Write-Host "   Anzahl Dateien: $fileCount"
        
        # Geschätzte Kopierzeit (grobe Schätzung)
        $estimatedMinutes = [math]::Ceiling($sourceSizeGB / 2) # 2GB pro Minute als grobe Schätzung
        Write-Host "   Geschätzte Kopierzeit: ca. $estimatedMinutes Minuten"
    }
    
    # Ausführung
    Write-Host "`n🚀 AUSFÜHRUNG:" -ForegroundColor Red
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Red
    $execute = Read-Host "Befehl jetzt ausführen? (j/n)"
    
    if ($execute -eq "j") {
        Write-Host "`n⏳ Starte Robocopy..." -ForegroundColor Yellow
        Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
        
        $startTime = Get-Date
        
        try {
            # Robocopy ausführen
            $result = Invoke-Expression $command
            $endTime = Get-Date
            $duration = $endTime - $startTime
            
            # Ergebnis anzeigen
            Write-Host "`n✅ ROBOCOPY ABGESCHLOSSEN!" -ForegroundColor Green
            Write-Host "════════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
            Write-Host "Startzeit: $($startTime.ToString('HH:mm:ss'))" -ForegroundColor White
            Write-Host "Endzeit: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor White
            Write-Host "Dauer: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
            
            if ($log -ne "n") {
                Write-Host "📄 Logdatei: $logPath" -ForegroundColor Yellow
            }
            
            # Exit-Code interpretieren
            $exitCode = $LASTEXITCODE
            switch ($exitCode) {
                0 { Write-Host "Status: Keine Dateien kopiert" -ForegroundColor Yellow }
                1 { Write-Host "Status: Erfolgreich kopiert" -ForegroundColor Green }
                2 { Write-Host "Status: Zusätzliche Dateien/Verzeichnisse gefunden" -ForegroundColor Green }
                3 { Write-Host "Status: Erfolgreich kopiert + zusätzliche Dateien" -ForegroundColor Green }
                4 { Write-Host "Status: Einige Dateien nicht kopiert" -ForegroundColor Yellow }
                8 { Write-Host "Status: Fehler aufgetreten" -ForegroundColor Red }
                default { Write-Host "Status: Exit-Code $exitCode" -ForegroundColor Gray }
            }
            
        } catch {
            Write-Host "❌ Fehler beim Ausführen: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "`n📋 Befehl in Zwischenablage kopiert!" -ForegroundColor Green
        $command | Set-Clipboard
    }
    
    Write-Host "`nDrücke eine beliebige Taste, um fortzufahren..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Schnellmodus Profile
function Start-QuickMode {
    Clear-Host
    Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
    
    Write-Host "`n⚡ SCHNELLMODUS - VORDEFINIERTE PROFILE" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    Write-Host "`n📋 VERFÜGBARE PROFILE:" -ForegroundColor Yellow
    Write-Host "1. 🔄 Synchronisation (Mirror)"
    Write-Host "2. 💾 Backup (Inkrementell)"
    Write-Host "3. 🚀 Schnellkopie (Nur neue Dateien)"
    Write-Host "4. 📁 Ordner-Replikation"
    Write-Host "5. 🌐 Netzwerk-Sync (Robust)"
    Write-Host "6. 📸 Foto-Backup"
    Write-Host "7. 🎵 Musik-Sync"
    Write-Host "8. 🔒 Sicherheitskopie"
    
    $choice = Read-Host "`nProfil auswählen (1-8)"
    
    $source = Get-ValidPath "📁 Quellpfad"
    $destination = Get-ValidPath "📁 Zielpfad" -MustExist $false
    
    $commands = @{
        "1" = "robocopy `"$source`" `"$destination`" /MIR /R:3 /W:30 /MT:8 /V /TS"
        "2" = "robocopy `"$source`" `"$destination`" /S /XO /R:5 /W:60 /MT:8 /LOG:`$env:TEMP\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        "3" = "robocopy `"$source`" `"$destination`" /S /XC /XN /XO /R:1 /W:10 /MT:16"
        "4" = "robocopy `"$source`" `"$destination`" /E /PURGE /R:3 /W:30 /MT:8"
        "5" = "robocopy `"$source`" `"$destination`" /S /R:10 /W:120 /MT:4 /V /LOG:`$env:TEMP\network_sync_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        "6" = "robocopy `"$source`" `"$destination`" *.jpg *.jpeg *.png *.gif *.bmp *.tiff /S /XO /R:3 /W:30 /MT:8"
        "7" = "robocopy `"$source`" `"$destination`" *.mp3 *.wav *.flac *.m4a *.wma /S /XO /R:3 /W:30 /MT:8"
        "8" = "robocopy `"$source`" `"$destination`" /MIR /R:5 /W:60 /MT:4 /V /LOG:`$env:TEMP\security_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log /DCOPY:DAT"
    }
    
    if ($commands.ContainsKey($choice)) {
        $command = $commands[$choice]
        
        Write-Host "`n🎯 AUSGEWÄHLTES PROFIL:" -ForegroundColor Green
        Write-Host $command -ForegroundColor Yellow
        
        $execute = Read-Host "`nSofort ausführen? (j/n)"
        if ($execute -eq "j") {
            Write-Host "`n⏳ Starte Robocopy..." -ForegroundColor Yellow
            Invoke-Expression $command
            
            Write-Host "`n✅ Abgeschlossen! Exit-Code: $LASTEXITCODE" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Ungültige Auswahl!" -ForegroundColor Red
    }
    
    Write-Host "`nDrücke eine beliebige Taste, um fortzufahren..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Log-Analyse
function Analyze-RobocopyLogs {
    Clear-Host
    Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
    
    Write-Host "`n📊 ROBOCOPY-LOG ANALYSE" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $logPath = Read-Host "Pfad zur Logdatei (oder Enter für automatische Suche)"
    
    if ($logPath -eq "") {
        $logs = Get-ChildItem "$env:TEMP\robocopy*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
        if ($logs.Count -eq 0) {
            Write-Host "❌ Keine Robocopy-Logs gefunden!" -ForegroundColor Red
            return
        }
        
        Write-Host "`n📄 GEFUNDENE LOGS:" -ForegroundColor Yellow
        for ($i = 0; $i -lt [math]::Min($logs.Count, 10); $i++) {
            $log = $logs[$i]
            Write-Host "[$($i+1)] $($log.Name) - $($log.LastWriteTime.ToString('dd.MM.yyyy HH:mm:ss'))"
        }
        
        $choice = Read-Host "`nLog auswählen (1-$([math]::Min($logs.Count, 10)))"
        if ($choice -match '^\d+$' -and [int]$choice -le $logs.Count) {
            $logPath = $logs[[int]$choice - 1].FullName
        } else {
            Write-Host "❌ Ungültige Auswahl!" -ForegroundColor Red
            return
        }
    }
    
    if (-not (Test-Path $logPath)) {
        Write-Host "❌ Logdatei nicht gefunden: $logPath" -ForegroundColor Red
        return
    }
    
    # Log analysieren
    $logContent = Get-Content $logPath
    $stats = @{
        TotalFiles = 0
        CopiedFiles = 0
        SkippedFiles = 0
        FailedFiles = 0
        TotalSize = 0
        Errors = @()
    }
    
    foreach ($line in $logContent) {
        if ($line -match "Total\s+Copied\s+Skipped\s+Mismatch\s+FAILED\s+Extras") {
            # Statistik-Zeile gefunden
            $nextLine = $logContent[$logContent.IndexOf($line) + 1]
            if ($nextLine -match "Files\s*:\s*(\d+)\s+(\d+)\s+(\d+)\s+\d+\s+(\d+)") {
                $stats.TotalFiles = [int]$matches[1]
                $stats.CopiedFiles = [int]$matches[2]
                $stats.SkippedFiles = [int]$matches[3]
                $stats.FailedFiles = [int]$matches[4]
            }
        }
        
        if ($line -match "ERROR|FEHLER") {
            $stats.Errors += $line
        }
    }
    
    # Ergebnisse anzeigen
    Write-Host "`n📈 ANALYSE-ERGEBNISSE:" -ForegroundColor Green
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "📁 Dateien gesamt: $($stats.TotalFiles)" -ForegroundColor White
    Write-Host "✅ Kopiert: $($stats.CopiedFiles)" -ForegroundColor Green
    Write-Host "⏭️ Übersprungen: $($stats.SkippedFiles)" -ForegroundColor Yellow
    Write-Host "❌ Fehler: $($stats.FailedFiles)" -ForegroundColor Red
    
    if ($stats.Errors.Count -gt 0) {
        Write-Host "`n🚨 FEHLER-DETAILS:" -ForegroundColor Red
        $stats.Errors | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
    }
    
    Write-Host "`nDrücke eine beliebige Taste, um fortzufahren..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Performance Monitor
function Start-PerformanceMonitor {
    Clear-Host
    Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
    
    Write-Host "`n📈 PERFORMANCE-MONITOR" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    # System-Informationen
    $cpu = Get-WmiObject Win32_Processor
    $memory = Get-WmiObject Win32_ComputerSystem
    $disk = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    
    Write-Host "`n🖥️ SYSTEM-INFORMATIONEN:" -ForegroundColor Green
    Write-Host "CPU: $($cpu.Name)"
    Write-Host "RAM: $([math]::Round($memory.TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host "Freier Speicher C:\: $([math]::Round($disk.FreeSpace / 1GB, 2)) GB"
    
    # Netzwerk-Geschwindigkeit testen
    Write-Host "`n🌐 NETZWERK-GESCHWINDIGKEIT:" -ForegroundColor Yellow
    $networkPath = Read-Host "Netzwerkpfad zum Testen (oder Enter überspringen)"
    
    if ($networkPath -ne "" -and (Test-Path $networkPath)) {
        $testFile = "$env:TEMP\speedtest_$(Get-Date -Format 'yyyyMMddHHmmss').tmp"
        $testData = "0" * 1MB  # 1MB Testdaten
        
        try {
            $startTime = Get-Date
            $testData | Out-File -FilePath "$networkPath\speedtest.tmp" -Encoding ASCII
            $endTime = Get-Date
            
            $duration = ($endTime - $startTime).TotalSeconds
            $speedMBps = [math]::Round(1 / $duration, 2)
            
            Write-Host "✅ Schreibgeschwindigkeit: $speedMBps MB/s" -ForegroundColor Green
            
            # Aufräumen
            Remove-Item "$networkPath\speedtest.tmp" -ErrorAction SilentlyContinue
            
        } catch {
            Write-Host "❌ Netzwerk-Test fehlgeschlagen: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Empfehlungen
    Write-Host "`n💡 PERFORMANCE-EMPFEHLUNGEN:" -ForegroundColor Magenta
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Magenta
    
    $ramGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 0)
    $recommendedThreads = [math]::Min([math]::Max($cpu.NumberOfCores * 2, 4), 32)
    
    Write-Host "🧵 Empfohlene Thread-Anzahl: $recommendedThreads"
    Write-Host "💾 Optimal für RAM ($ramGB GB): /MT:$recommendedThreads"
    
    if ($ramGB -ge 16) {
        Write-Host "🚀 Hohe Performance möglich - verwende /MT:32 für große Dateien"
    } elseif ($ramGB -ge 8) {
        Write-Host "⚡ Gute Performance - verwende /MT:16 für normale Kopien"
    } else {
        Write-Host "🐌 Begrenzte Performance - verwende /MT:4 für Stabilität"
    }
    
    Write-Host "`nDrücke eine beliebige Taste, um fortzufahren..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Hilfe & Tipps
function Show-Help {
    Clear-Host
    Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
    
    Write-Host "`n❓ HILFE & TIPPS" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    Write-Host "`n🎯 WICHTIGE ROBOCOPY-PARAMETER:" -ForegroundColor Yellow
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Yellow
    
    $tips = @(
        @{Param="/S"; Desc="Kopiert Unterverzeichnisse (ohne leere)"}
        @{Param="/E"; Desc="Kopiert Unterverzeichnisse (mit leeren)"}
        @{Param="/MIR"; Desc="Spiegelt Verzeichnisse (löscht überschüssige Dateien)"}
        @{Param="/MT:n"; Desc="Multithreading mit n Threads (1-128)"}
        @{Param="/R:n"; Desc="Anzahl Wiederholungen bei Fehlern"}
        @{Param="/W:n"; Desc="Wartezeit zwischen Wiederholungen (Sekunden)"}
        @{Param="/XO"; Desc="Überspringt ältere Dateien"}
        @{Param="/XC"; Desc="Überspringt geänderte Dateien"}
        @{Param="/XN"; Desc="Überspringt neuere Dateien"}
        @{Param="/LOG:file"; Desc="Schreibt Log in Datei"}
        @{Param="/V"; Desc="Detaillierte Ausgabe"}
        @{Param="/NP"; Desc="Kein Fortschrittsbalken"}
    )
    
    foreach ($tip in $tips) {
        Write-Host "  $($tip.Param.PadRight(12)) - $($tip.Desc)" -ForegroundColor White
    }
    
    Write-Host "`n💡 PROFI-TIPPS:" -ForegroundColor Green
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Green
    Write-Host "🚀 Für maximale Geschwindigkeit: /MT:32 /R:1 /W:1"
    Write-Host "🔒 Für Sicherheit: /R:10 /W:60 /V /LOG:backup.log"
    Write-Host "🌐 Für Netzwerk: /MT:4 /R:5 /W:30 (weniger Threads bei Netzwerk)"
    Write-Host "📁 Für große Dateien: /J (unbepufferte I/O)"
    Write-Host "🎯 Für Backups: /MIR /XJD /XJF (ohne Junction Points)"
    
    Write-Host "`n⚠️ HÄUFIGE FEHLER:" -ForegroundColor Red
    Write-Host "────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor Red
    Write-Host "❌ Zu viele Threads bei Netzwerk-Kopien"
    Write-Host "❌ /MIR ohne Backup (löscht unbeabsichtigt Dateien)"
    Write-Host "❌ Keine Logs bei wichtigen Kopien"
    Write-Host "❌ Zu wenig Wiederholungen bei instabilen Verbindungen"
    
    Write-Host "`n📞 ONLINE-HILFE:" -ForegroundColor Magenta
    Write-Host "Microsoft Robocopy Dokumentation: https://docs.microsoft.com/robocopy"
    
    Write-Host "`nDrücke eine beliebige Taste, um fortzufahren..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Hauptprogramm
do {
    Clear-Host
    Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                                  v2.0 - 2025                                    ║
║                         Erstellt für maximale Effizienz                         ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
    
    # Schnellmodus-Parameter prüfen
    if ($QuickMode -ne "") {
        switch ($QuickMode.ToLower()) {
            "backup" { 
                if ($Source -and $Destination) {
                    $command = "robocopy `"$Source`" `"$Destination`" /S /XO /R:5 /W:60 /MT:8 /LOG:`$env:TEMP\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
                    Write-Host "🚀 Backup-Modus: $command" -ForegroundColor Green
                    Invoke-Expression $command
                    exit
                }
            }
            "sync" { 
                if ($Source -and $Destination) {
                    $command = "robocopy `"$Source`" `"$Destination`" /MIR /R:3 /W:30 /MT:8"
                    Write-Host "🚀 Sync-Modus: $command" -ForegroundColor Green
                    Invoke-Expression $command
                    exit
                }
            }
        }
    }
    
    Show-Menu
    $choice = Read-Host "Auswahl treffen (1-9)"
    
    switch ($choice) {
        "1" { Start-GuidedConfiguration }
        "2" { Start-QuickMode }
        "3" { Analyze-RobocopyLogs }
        "4" { 
            Clear-Host
            Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
            Write-Host "`n🔧 Erweiterte Optionen werden in der nächsten Version verfügbar!" -ForegroundColor Yellow
            Write-Host "`nDrücke eine beliebige Taste, um fortzufahren..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "5" { 
            Clear-Host
            Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
            Write-Host "`n💾 Backup-Assistent startet..." -ForegroundColor Green
            Start-Sleep -Seconds 1
            Start-QuickMode
        }
        "6" { 
            Clear-Host
            Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
            Write-Host "`n🌐 Netzwerk-Sync startet..." -ForegroundColor Blue
            Start-Sleep -Seconds 1
            Start-QuickMode
        }
        "7" { Start-PerformanceMonitor }
        "8" { Show-Help }
        "9" { 
            Clear-Host
            Write-Host "
╔══════════════════════════════════════════════════════════════════════════════════╗
║                           🚀 ULTIMATE ROBOCOPY TOOL 🚀                          ║
║                          © 2025 Lukas Leihs - Alle Rechte vorbehalten          ║
╚══════════════════════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan
            Write-Host "`n👋 Vielen Dank für die Nutzung des Ultimate Robocopy Tools!" -ForegroundColor Green
            Write-Host "   Entwickelt von Lukas Leihs - 2025" -ForegroundColor Yellow
            Write-Host "`n🚀 Bis zum nächsten Mal!" -ForegroundColor Cyan
            Start-Sleep -Seconds 2
            exit 
        }
        default { 
            Write-Host "`n❌ Ungültige Auswahl! Bitte wähle 1-9." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    
} while ($true)