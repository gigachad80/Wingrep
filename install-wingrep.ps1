# install-wingrep.ps1 - Automated wingrep installation script
# Run this script as Administrator for system-wide installation

param(
    [switch]$Help,
    [switch]$UserOnly
)

function Show-Help {
    Write-Host "wingrep Installer Script"
    Write-Host "======================"
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  .\install-wingrep.ps1           # Install system-wide (requires admin)"
    Write-Host "  .\install-wingrep.ps1 -UserOnly # Install for current user only"
    Write-Host "  .\install-wingrep.ps1 -Help     # Show this help"
    Write-Host ""
    Write-Host "The script will:"
    Write-Host "  1. Ask if you want to rename the executable"
    Write-Host "  2. Create C:\tools directory (or user tools directory)"
    Write-Host "  3. Copy executable to the tools directory"
    Write-Host "  4. Add tools directory to PATH"
    Write-Host "  5. Verify installation"
    exit
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-ToSystemPath {
    param([string]$PathToAdd)
    
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$PathToAdd*") {
            $newPath = $currentPath + ";" + $PathToAdd
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
            Write-Host "[OK] Added $PathToAdd to system PATH"
            return $true
        } else {
            Write-Host "[OK] $PathToAdd already in system PATH"
            return $true
        }
    } catch {
        Write-Host "[ERROR] Failed to add to system PATH: $($_.Exception.Message)"
        return $false
    }
}

function Add-ToUserPath {
    param([string]$PathToAdd)
    
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if (-not $currentPath) { $currentPath = "" }
        
        if ($currentPath -notlike "*$PathToAdd*") {
            if ($currentPath) {
                $newPath = $currentPath + ";" + $PathToAdd
            } else {
                $newPath = $PathToAdd
            }
            [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
            Write-Host "[OK] Added $PathToAdd to user PATH"
            return $true
        } else {
            Write-Host "[OK] $PathToAdd already in user PATH"
            return $true
        }
    } catch {
        Write-Host "[ERROR] Failed to add to user PATH: $($_.Exception.Message)"
        return $false
    }
}

function Test-Installation {
    param([string]$ExeName, [string]$ToolsPath)
    
    Write-Host ""
    Write-Host "Testing installation..."
    
    # Refresh PATH for current session
    $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
    
    # Test if file exists
    $exePath = Join-Path $ToolsPath $ExeName
    if (Test-Path $exePath) {
        Write-Host "[OK] $ExeName found at $exePath"
    } else {
        Write-Host "[ERROR] $ExeName not found at $exePath"
        return $false
    }
    
    # Test if command is accessible
    try {
        $result = & $ExeName "-h" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] $ExeName command is working!"
            return $true
        } else {
            Write-Host "[ERROR] $ExeName command failed to run"
            return $false
        }
    } catch {
        Write-Host "[ERROR] $ExeName command not found in PATH"
        Write-Host "You may need to restart your Command Prompt/PowerShell"
        return $false
    }
}

# Show help if requested
if ($Help) {
    Show-Help
}

# Main installation logic
Write-Host "wingrep Installation Script"
Write-Host "========================="
Write-Host ""

# Check if wingrep.exe exists
if (-not (Test-Path "wingrep.exe")) {
    Write-Host "[ERROR] wingrep.exe not found in current directory!"
    Write-Host "Please make sure wingrep.exe is present in the same folder as this script."
    exit 1
}

Write-Host "Found wingrep.exe - ready for installation."
Write-Host ""

# Ask about renaming
Write-Host "Do you want to rename the executable? (default: wingrep)"
$rename = Read-Host "Rename? (y/N)"

$exeName = "wingrep.exe"
if ($rename -eq "y" -or $rename -eq "Y" -or $rename -eq "yes") {
    do {
        $newName = Read-Host "Enter new name (without .exe extension)"
        if ($newName -and $newName.Trim() -ne "") {
            $exeName = $newName.Trim() + ".exe"
            Write-Host "Will install as: $exeName"
            break
        } else {
            Write-Host "Please enter a valid name!"
        }
    } while ($true)
}

# Determine installation type
$isAdmin = Test-Administrator
$installSystem = $false

if ($UserOnly) {
    Write-Host "Installing for current user only..."
    $toolsPath = "$env:USERPROFILE\tools"
} elseif ($isAdmin) {
    Write-Host "Installing system-wide (all users)..."
    $toolsPath = "C:\tools"
    $installSystem = $true
} else {
    Write-Host "Not running as Administrator."
    Write-Host "Installing for current user only..."
    Write-Host "(Run as Administrator for system-wide installation)"
    $toolsPath = "$env:USERPROFILE\tools"
}

Write-Host "Installation path: $toolsPath"
Write-Host ""

# Create tools directory
Write-Host "Creating tools directory..."
try {
    if (-not (Test-Path $toolsPath)) {
        New-Item -ItemType Directory -Path $toolsPath -Force | Out-Null
        Write-Host "[OK] Created directory: $toolsPath"
    } else {
        Write-Host "[OK] Directory already exists: $toolsPath"
    }
} catch {
    Write-Host "[ERROR] Failed to create directory: $($_.Exception.Message)"
    exit 1
}

# Copy executable
Write-Host "Copying executable..."
try {
    $destPath = Join-Path $toolsPath $exeName
    Copy-Item "wingrep.exe" $destPath -Force
    Write-Host "[OK] Copied wingrep.exe to $destPath"
} catch {
    Write-Host "[ERROR] Failed to copy executable: $($_.Exception.Message)"
    exit 1
}

# Add to PATH
Write-Host "Adding to PATH..."
$pathSuccess = $false
if ($installSystem) {
    $pathSuccess = Add-ToSystemPath $toolsPath
} else {
    $pathSuccess = Add-ToUserPath $toolsPath
}

if (-not $pathSuccess) {
    Write-Host "[ERROR] Failed to add to PATH. You may need to add manually."
    Write-Host "Add this to your PATH: $toolsPath"
}

# Test installation
$testSuccess = Test-Installation $exeName $toolsPath

# Final message
Write-Host ""
Write-Host "=================================================="
if ($testSuccess) {
    Write-Host "Installation completed successfully!"
    Write-Host ""
    Write-Host "You can now use: $($exeName.Replace('.exe', ''))"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  $($exeName.Replace('.exe', '')) -h"
    Write-Host "  type file.txt | $($exeName.Replace('.exe', '')) `"pattern`""
    Write-Host "  $($exeName.Replace('.exe', '')) `"error`" *.log"
    Write-Host "  cat input.txt | $($exeName.Replace('.exe', '')) -m output.txt `"pattern`""
} else {
    Write-Host "Installation completed with warnings!"
    Write-Host ""
    Write-Host "The executable was copied but may not be in PATH."
    Write-Host "Try restarting your Command Prompt or PowerShell."
    Write-Host ""
    Write-Host "If it still doesn't work, manually add to PATH:"
    Write-Host "  $toolsPath"
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
