function make_green
{process {Write-Host $_ -ForegroundColor green}}

function make_red
{process {Write-Host $_ -ForegroundColor red}}


### Enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart


### Prompt user to install kernel update package
clear
echo "[INFO] Please download and run the following file:" | make_green
echo "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
echo ""
while ( $ready_response -ne "ready" )
{
	$ready_response=Read-Host -Prompt "Type 'ready' once you are ready to move on"
}
$ready_response=""


### Set WSL to version 2
wsl --set-default-version 2


### Prompt user to install a Linux distro
clear
echo "[INFO] Your Windows environment is now configured for WSL" | make_green
echo "Please install one of the following Linux distrubitions"
echo ""
echo "Ubuntu 18.04 LTS : https://aka.ms/wsl-ubuntu-1804"
echo "openSUSE Tumbleweed : https://aka.ms/wsl-opensuse-tumbleweed"
echo ""
echo ""
