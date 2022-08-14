#!/bin/bash

# ask for password in the begning so it would be "cached" later
sudo ls

rm nordvpn-torrent.box 
rm -f *log

#apt-cache madison linux-headers-truenas-amd64
#sudo apt install -y linux-headers-truenas-amd64=5.10.70+truenas-1 #5.10.42+truenas-3

# add group vboxusers
# https://maxedtech.com/how-to-enable-or-disable-secure-boot/
#sudo /sbin/vboxconfig
#sudo modprobe vboxdrv vboxnetflt vboxnetadp vboxpci 
#sudo service vboxautostart-service restart
vagrant box update &

# when getting VBoxManage: error: Cannot unregister the machine '(...)' while it is locked do
# disabled due to use of crashplan vagrant TODO detect when it happens and execute only then?
#sudo killall -9 VBoxHeadless # https://stackoverflow.com/a/15175657 

vagrant halt; vagrant destroy -f
source ./nordvpn-set-password-in-env-var.sh

#vagrant plugin install vagrant-disksize
#vagrant plugin install vagrant-scp

#sudo systemctl enable rpcbind.service
#sudo systemctl enable nfs-kernel-server
#sudo modprobe nfs
#sudo service nfs-kernel-server stop

grep Plex /etc/exports | grep insecure || {
    echo '#nord-virtualbox' | sudo tee -a /etc/exports
    echo '"/mnt/MargokPool/archive"     127.0.0.1(ro,no_subtree_check,all_squash,insecure,anonuid=114,anongid=119,fsid=365136518)' | sudo tee -a /etc/exports
    echo '"/mnt/PlexPool/plex"          127.0.0.1(rw,no_subtree_check,all_squash,insecure,anonuid=114,anongid=119,fsid=365136519)' | sudo tee -a /etc/exports
}
sudo service nfs-kernel-server start
sudo exportfs -r; sudo exportfs

vagrant up

#ssh-keygen -f "/mnt/MargokPool/home/sup/.ssh/known_hosts" -R "[127.0.0.1]:2222"

vagrant box prune
