#!/bin/bash -x

# if there will be "The requested URL returned error: 416" after vagrant box update
# run vagrant box --debug update, there will be tmp path of box, remove it
VAGRANT_VAGRANTFILE=Vagrantfile.basebox vagrant box update

basebox_of_basebox=$(grep -o '^[^#]*' Vagrantfile.basebox | grep 'config.vm.box' | sed 's/^[^"]*"//' | sed 's/\".*//')
vagrant_version=$(vagrant box list | grep $basebox_of_basebox | tail -1 | sed 's/.*,\ //' | sed 's/)$//')

vagrant_username=bnowakow
vagrant_provider=virtualbox
# if token doesn't exist run
# vagrant login
# or use https://gist.github.com/dasgoll/64333371f66c82161373
vagrant_token=$(cat ~/.vagrant.d/data/vagrant_login_token)
vagrant_box_name=nordvpn-torrent


vagrant halt
vagrant destroy -f
#VAGRANT_VAGRANTFILE=Vagrantfile.basebox VAGRANT_LOG=debug vagrant up | tee vagrant.output
VAGRANT_VAGRANTFILE=Vagrantfile.basebox vagrant up | tee vagrant.output

# TODO verify if proviosion finished succesfully

sleep 60; # for vbguest to start

vbguest=$(vagrant vbguest --status)
if echo $vbguest | grep GuestAdditions; then 
    # guest additions has started
    guest_addition_version=$(echo $vbguest | tail -1 | sed 's/.*GuestAdditions.//' | sed 's/.running.*//')
else
    # guest additions didn't start
    guest_addition_version=$(echo $vbguest | sed 's/.*(//' | sed 's/).*//')
fi

if ! echo $guest_addition_version | egrep "^[0-9]*.[0-9]*.[0-9]*$"; then
#default: Guest Additions Version: 6.0.0 r127566
    guest_addition_version=$(grep "Guest Additions Version" vagrant.output | sed 's/.*Guest\ Additions\ Version:.//' | sed 's/\ .*//')
fi

ubuntu_numerical_version=$(vagrant ssh -c "grep DISTRIB_RELEASE /etc/lsb-release | sed 's/.*=//' | sed 's/\r$//'" | sed 's/\r$//')

# https://www.digitalocean.com/community/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one
vagrant ssh -c 'sudo apt-get clean'
vagrant ssh -c '#sudo dd if=/dev/zero of=/EMPTY bs=1M'
vagrant ssh -c 'sudo rm -f /EMPTY'
vagrant ssh -c 'cat /dev/null > ~/.bash_history && history -c'

rm nordvpn-torrent.box
rm vagrant.output
vagrant package --output nordvpn-torrent.box
#vagrant box add --force $vagrant_username/nordvpn-torrent $vagrant_box_name.box

vagrant destroy -f

vagrant cloud publish --release --force $vagrant_username/$vagrant_box_name $ubuntu_numerical_version-$vagrant_version-$guest_addition_version $vagrant_provider $vagrant_box_name.box

rm $vagrant_box_name.box

