Disable-UAC

Programs = @(
    #"sysinternals -y"
    "geforce-game-ready-driver"

    "Microsoft-Hyper-V-All -source windowsFeatures"
    "Microsoft-Windows-Subsystem-Linux -source windowsfeatures"
    "Net-Framework-Core -source windowsFeatures"
    "git"
    "github-desktop"
    "insomnia-rest-api-client"
    "jdk8"
    "jre8"
    "powershell"
    "vscode"
    "virtualbox"
    "vagrant"
    "docker-desktop"
    "vcxsrv"

    "7zip"
    "firefox"
    "googlechrome"

    "k-litecodecpackfull"
    "ccleaner"
    "sharex"
    "ffmpeg"
    "qbittorrent"
    "bitwarden"
    "polar"
    "station"
    "steam"

    "google-backup-and-sync"
    "dropbox"
)
        
ForEach ($Program in $Programs) {
    Write-Output "Instaling $Program"
    choco install $Program
    Remove-Variable Program
}
Remove-Variable Programs

#Dark Theme
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0

#Settings
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Set-TaskbarOptions -Dock Bottom -Combine Full -Lock
Set-TaskbarOptions -Dock Bottom -Combine Full -AlwaysShowIconsOn

Enable-UAC

Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
 
#--- Rename the Computer ---
# Requires restart, or add the -Restart flag
$NameList = "Turing", "Knuth", "Berners-Lee", "Torvalds", "Hopper", "Ritchie", "Stallman", "Gosling", "Church", "Dijkstra", "Cooper", "Gates", "Jobs", "Wozniak", "Zuckerberg", "Musk", "Nakamoto", "Dotcom", "Snowden", "Kruskal", "Neumann"

$ComputerName = Get-Random -InputObject $NameList
if ($env:computername -ne $ComputerName) {
    Rename-Computer -NewName $ComputerName
}
Remove-Variable NameList

bash -c "git clone https://github.com/MatheusRV/dotfiles && chmod -R 777 dotfiles && cd dotfiles && ./install.sh "$ComputerName""

Remove-Variable ComputerName
