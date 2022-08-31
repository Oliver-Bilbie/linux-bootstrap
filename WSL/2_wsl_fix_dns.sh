#!/bin/bash

### Fix DNS bug in WSL

# Here we will use PowerShell to list the current IP addresses.
# PowerShell is a bit quirky and will change the font in our WSL terminal if any data is directly
# passed back into WSL (ie echoed or stored as a variable) so we will instead write the output to
# a temporary file and read it back again.

powershell.exe "ipconfig /all | wsl grep 'DNS Servers' | wsl sudo tee /tmp/ip_data.txt"
cat /tmp/ip_data.txt | awk '{ print substr( $0, 40 ) }' | sudo tee /tmp/ip_data.txt
echo "[network]" | sudo tee /etc/wsl.conf >/dev/null
echo "generateResolvConf = false" | sudo tee -a /etc/wsl.conf >/dev/null
sudo rm -rf /etc/resolv.conf
echo "nameserver $(cat /tmp/ip_data.txt | awk 'NR==2' | tr -d '[[:cntrl:]]')" | sudo tee /etc/resolv.conf >/dev/null
echo "nameserver $(cat /tmp/ip_data.txt | awk 'NR==1' | tr -d '[[:cntrl:]]')" | sudo tee -a /etc/resolv.conf >/dev/null


### Prompt user to reboot

# A reboot is unavoidable here since /etc/resolv.conf will be overwritten despite our changes to
# /tmp/ip_data.txt if the WSL environment is reloaded. Rebooting the entire machine fixes this.

clear
echo "$(tput setaf 2)[INFO] Please reboot your machine now"
echo "$(tput setaf 1)[WARNING] Do NOT restart your WSL environment until this has been done $(tput setaf 7)"