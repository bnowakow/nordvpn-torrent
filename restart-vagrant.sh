#!/bin/bash

rm -f *log

#apt-cache madison linux-headers-truenas-amd64
#sudo apt install -y linux-headers-truenas-amd64=5.10.70+truenas-1 #5.10.42+truenas-3

# add group vboxusers
# https://maxedtech.com/how-to-enable-or-disable-secure-boot/
#sudo /sbin/vboxconfig
#sudo modprobe vboxdrv vboxnetflt vboxnetadp vboxpci 
#sudo service vboxautostart-service restart
vagrant box update &

vagrant ssh -c 'sudo chmod -R 777 /mnt/ubu-storage/Plex/'
VAGRANT_VAGRANTFILE=Vagrantfile.full-rsync vagrant rsync-back

vagrant halt; vagrant destroy -f
source ./nordvpn-set-password-in-env-var.sh

# https://stackoverflow.com/questions/43492322/vagrant-was-unable-to-mount-virtualbox-shared-folders
#vagrant plugin install vagrant-vbguest
#vagrant plugin install vagrant-disksize
#vagrant plugin install vagrant-rsync-back
#vagrant plugin install vagrant-scp

#vagrant up
VAGRANT_VAGRANTFILE=Vagrantfile.full-rsync vagrant up

#ssh-keygen -f "/mnt/MargokPool/home/sup/.ssh/known_hosts" -R "[127.0.0.1]:2222"

vagrant box prune
