#!/bin/bash

vagrant halt
vagrant destroy -f
VAGRANT_VAGRANTFILE=Vagrantfile.basebox vagrant up

# https://www.digitalocean.com/community/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one
vagrant ssh -c 'sudo apt-get clean'
vagrant ssh -c '#sudo dd if=/dev/zero of=/EMPTY bs=1M'
vagrant ssh -c 'sudo rm -f /EMPTY'
vagrant ssh -c 'cat /dev/null > ~/.bash_history && history -c'

rm nordvpn-torrent.box
vagrant package --output nordvpn-torrent.box
vagrant box add --force bnowakow/nordvpn-torrent nordvpn-torrent.box

vagrant destroy -f

