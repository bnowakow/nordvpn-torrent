#!/bin/bash

#vagrant plugin install vagrant-rsync-back
vagrant ssh -c 'sudo chmod -R 777 /mnt/ubu-storage/Plex/'
vagrant rsync-back

