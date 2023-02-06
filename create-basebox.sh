#!/bin/bash -x

VAGRANT_VAGRANTFILE=Vagrantfile.basebox vagrant box update

vagrant_username=bnowakow
vagrant_version=$(vagrant box list | grep focal64 | tail -1 | sed 's/.*,\ //' | sed 's/)$//')
vagrant_provider=virtualbox
# if token doesn't exist run
# vagrant login
# or use https://gist.github.com/dasgoll/64333371f66c82161373
vagrant_token=$(cat ~/.vagrant.d/data/vagrant_login_token)
vagrant_box_name=nordvpn-torrent


vagrant halt
vagrant destroy -f
VAGRANT_VAGRANTFILE=Vagrantfile.basebox vagrant up

sleep 60; # for vbguest to start

vbguest=$(vagrant vbguest --status)
if echo $vbguest | grep GuestAdditions; then 
    # guest additions has started
    guest_addition_version=$(echo $vbguest | tail -1 | sed 's/.*GuestAdditions.//' | sed 's/.running.*//')
else
    # guest additions didn't start
    guest_addition_version=$(echo $vbguest | sed 's/.*(//' | sed 's/).*//')
fi

# https://www.digitalocean.com/community/tutorials/how-to-create-a-vagrant-base-box-from-an-existing-one
vagrant ssh -c 'sudo apt-get clean'
vagrant ssh -c '#sudo dd if=/dev/zero of=/EMPTY bs=1M'
vagrant ssh -c 'sudo rm -f /EMPTY'
vagrant ssh -c 'cat /dev/null > ~/.bash_history && history -c'

rm nordvpn-torrent.box
vagrant package --output nordvpn-torrent.box
#vagrant box add --force $vagrant_username/nordvpn-torrent $vagrant_box_name.box

vagrant destroy -f

# https://www.vagrantup.com/vagrant-cloud/boxes/create
# TODO fails with 'resource not fond :/
#vagrant_upload_url=$(curl "https://vagrantcloud.com/api/v1/box/$vagrant_username/$vagrant_box_name/version/$vagrant_version-$guest_addition_version/provider/$vagrant_provider/upload?access_token=$vagrant_token" | jq '.upload_path' | sed 's/\"//')
#curl -X PUT --upload-file $vagrant_box_name.box $vagrant_upload_url

vagrant cloud publish --force $vagrant_username/$vagrant_box_name $vagrant_version-$guest_addition_version $vagrant_provider $vagrant_box_name.box

