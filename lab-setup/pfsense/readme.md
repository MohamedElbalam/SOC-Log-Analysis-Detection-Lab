
**pfsense setup:**
  -it is a linux based firewall using BSD software that is installed on the network to act as router
  - It sets between the MAN internet and LAN network for the lab
  - install qemu-guest-agent for pfsense => inside pfsense shell command => pkg install -y qemu-guest-agent
  - in pfsense shell edit for qemu-guest-agent => echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf.local
  - in order for agent to talk ot t430 proxmox enable => echo 'virtio_console_load="YES"' >> /boot/loader.conf.local

**Issues:**
  - network installation error:
    - what is it? I cant pass through setting the LAN network.
    - vmbr1 cant come up using command => ip link set vmbr1 up?
       - it is proxmox network miss-configurations   
    Fixed pathes ideas:
      -I am thinking since my proxmox and my host on the same network. I checked my network with ip a and my vmb1 is down. So if I bring vmbr1 up could fix it?
          - No, vmbr1 down not an issue
          - Just chhoose 

**Learning topics:**
  - what if my proxmox and my host are on two different subnet mask?
  - understand how network would be designed to different machines?
