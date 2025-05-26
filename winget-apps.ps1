# PowerShell script to install applications using winget
# This script is intended for unattended execution.

Write-Host "Starting application installation using winget..."

# Attempt to register winget
Write-Host "Attempting to register winget (Microsoft.DesktopAppInstaller)..."
# Ensure App Installer is present and updated, which provides winget
# Using -Quiet to suppress progress/output, -ForceApplicationShutdown to close App Installer if running.
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ForceApplicationShutdown -Quiet
Write-Host "Waiting for winget registration to complete..."
Start-Sleep -Seconds 15 # Increased sleep time to allow winget to fully initialize, especially on first run or slower systems.

# Define a list of applications to install with their winget package IDs
$applications = @(
    @{ Name = "7-Zip"; ID = "7zip.7zip" },
    @{ Name = "Google Chrome"; ID = "Google.Chrome" },
    @{ Name = "Java Runtime Environment 8"; ID = "Oracle.JavaRuntimeEnvironment" }, # Fallback to OpenJDK if this fails or is not found
    @{ Name = "Microsoft OpenJDK 11"; ID = "Microsoft.OpenJDK.11"; FallbackFor = "Java Runtime Environment 8" }, # Alternative for Java
    @{ Name = "Foxit PDF Reader"; ID = "Foxit.FoxitReader" },
    @{ Name = "Deluge"; ID = "DelugeTeam.Deluge" },
    @{ Name = "Paint.NET"; ID = "dotPDN.PaintDotNet" },
    @{ Name = "Notepad2 (XhmikosR)"; ID = "XhmikosR.Notepad2" }, # Primary Notepad2 choice
    @{ Name = "Notepad2 (zufuliu)"; ID = "zufuliu.notepad2"; FallbackFor = "Notepad2 (XhmikosR)"}, # Alternative Notepad2
    @{ Name = "VLC Media Player"; ID = "VideoLAN.VLC" },
    @{ Name = "CCleaner"; ID = "Piriform.CCleaner" },
    @{ Name = "FileZilla Client"; ID = "FileZilla.FileZillaClient" },
    @{ Name = "KeePass 2.x"; ID = "JeromeAgullo.KeePass" }, # KeePass 2.x
    @{ Name = "KeePassXC"; ID = "KeePassXCTeam.KeePassXC"; FallbackFor = "KeePass 2.x" }, # Alternative KeePass
    @{ Name = "LibreOffice"; ID = "TheDocumentFoundation.LibreOffice" },
    @{ Name = "Notepad++"; ID = "Notepad++.Notepad++" },
    @{ Name = "GIMP"; ID = "GIMP.GIMP" },
    @{ Name = "ownCloud Client"; ID = "ownCloud.ownCloudDesktopClient" }
)

# Applications to skip from the original Chocolatey list
Write-Host ""
Write-Host "Skipping CDBurnerXP: Likely no direct winget equivalent or not commonly available."
# Comment: CDBurnerXP is primarily distributed as a direct download or via other package managers.
Write-Host "Skipping ImgBurn: Likely no direct winget equivalent or not commonly available."
# Comment: ImgBurn is also primarily distributed as a direct download.
Write-Host "Skipping Atom: This editor has been sunsetted (archived by GitHub) and is no longer recommended for new installations."
# Comment: Atom project was officially archived in December 2022.

Write-Host ""
Write-Host "Starting application installation loop..."

$installedJava = $false
$installedNotepad2 = $false
$installedKeePass = $false

foreach ($app in $applications) {
    # Skip fallback applications if their primary has already been attempted or installed
    if ($app.ContainsKey("FallbackFor")) {
        if ($app.FallbackFor -eq "Java Runtime Environment 8" -and $installedJava) { continue }
        if ($app.FallbackFor -eq "Notepad2 (XhmikosR)" -and $installedNotepad2) { continue }
        if ($app.FallbackFor -eq "KeePass 2.x" -and $installedKeePass) { continue }
    }

    Write-Host ""
    Write-Host "Attempting to install $($app.Name) (ID: $($app.ID))..."
    
    winget install --id $app.ID --exact --accept-package-agreements --accept-source-agreements --disable-interactivity --scope machine
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host "$($app.Name) installed successfully."
        if ($app.Name -eq "Java Runtime Environment 8" -or $app.Name -eq "Microsoft OpenJDK 11") { $installedJava = $true }
        if ($app.Name -eq "Notepad2 (XhmikosR)" -or $app.Name -eq "Notepad2 (zufuliu)") { $installedNotepad2 = $true }
        if ($app.Name -eq "KeePass 2.x" -or $app.Name -eq "KeePassXC") { $installedKeePass = $true }
    } else {
        Write-Warning "Failed to install $($app.Name) (Package ID: $($app.ID)). Exit code: $exitCode"
        # If a primary Java, Notepad2, or KeePass fails, allow fallback attempt
        if ($app.Name -eq "Java Runtime Environment 8") { $installedJava = $false } # Explicitly set to false to allow fallback
        elseif ($app.Name -eq "Notepad2 (XhmikosR)") { $installedNotepad2 = $false }
        elseif ($app.Name -eq "KeePass 2.x") { $installedKeePass = $false }
    }

    # Mark that an attempt (success or fail) has been made for primary Java/Notepad2/KeePass
    if ($app.Name -eq "Java Runtime Environment 8") { $installedJava = $true } # Mark as attempted to prevent fallback if primary was just not found but didn't error in a way that reset $installedJava
    if ($app.Name -eq "Notepad2 (XhmikosR)") { $installedNotepad2 = $true }
    if ($app.Name -eq "KeePass 2.x") { $installedKeePass = $true }
}

Write-Host ""
Write-Host "Winget application installation script finished."
Write-Host "Please check any warnings above for applications that may have failed to install."
