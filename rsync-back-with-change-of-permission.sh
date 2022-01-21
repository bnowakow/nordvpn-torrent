#!/bin/bash

#vagrant plugin install vagrant-rsync-back
vagrant ssh -c 'sudo chmod -R 777 /mnt/ubu-storage/Plex/'

VAGRANT_VAGRANTFILE=Vagrantfile vagrant rsync-back
#VAGRANT_VAGRANTFILE=Vagrantfile.full-rsync vagrant rsync-back

