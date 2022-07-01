Vagrant.configure("2") do |config|
  config.vm.box = "bnowakow/nordvpn-torrent"

  # https://github.com/hashicorp/vagrant/issues/1437
  #config.vm.network "private_network", type: "dhcp"
  config.vm.network "private_network", ip: "192.168.10.147"
  config.vm.network :forwarded_port, guest: 9091, host: 9091, auto_correct: true

  # native nfs
  #config.vm.synced_folder "/mnt/PlexPool/plex", "/mnt/ubu-storage/", type: "nfs", linux__nfs_options: ['rw','no_subtree_check','all_squash','insecure']

  config.vm.provision "connect to nfs with manual workaround", type: "shell", inline: <<-SHELL
    mkdir -p /mnt/ubu-storage;
    mount -vvv -o vers=3 10.0.2.2:/mnt/PlexPool/plex /mnt/ubu-storage
  SHELL

  config.vm.provision "check environment variables", type: "shell" do |s|
    username = ENV['NORDVPN_USERNAME']
    password = ENV['NORDVPN_PASSWORD']
    s.inline = "if [[ -z \"#{username}\" || -z \"#{password}\" ]]; then >&2 echo 'please set NORDVPN_USERNAME and NORDVPN_PASSWORD env variables'; exit 1; else echo 'env variables are set'; fi;"
  end

  config.vm.provision "create nordvpn login script", type: "shell" do |s|
    username = ENV['NORDVPN_USERNAME']
    password = ENV['NORDVPN_PASSWORD']
    s.inline = "echo \"#!/bin/bash\nnordvpn login --username '#{username}' --password '#{password}'\" > nord-run.sh"
  end

  config.vm.provision "connect to vpn", type: "shell", inline: <<-SHELL
    chmod +x nord-run.sh

    # todo debug why "nordvpn whitelist add subnet 192.168.1.0/24" doesn't work (instead of definining ports)
    nordvpn whitelist add port 22	 # ssh
    nordvpn whitelist add port 2222	 # ssh
    nordvpn whitelist add port 9091	 # transmission-daemon
    nordvpn whitelist add port 111	 # nfs
    nordvpn whitelist add port 2049  # nfs 
    nordvpn whitelist add port 33333 # rpcbind https://serverfault.com/a/823236
    nordvpn set protocol tcp
    #nordvpn set technology nordlynx
    #nordvpn set obfuscate on

    # workaround for NordVPN insights api https://github.com/bubuntux/nordvpn/commit/9c338b86f4bf30badcdf7ad18256937d5b203de5
    nordvpn set cybersec off
    nordvpn set dns 1.1.1.1 1.0.0.1

    bash nord-run.sh
    nordvpn set autoconnect on Czech_Republic p2p
    
    # below often freezes so we'll give it a timeout and retry after it
    exit_status=1;
    while [ ! $exit_status -eq 0 ]; do
        echo "try to connect vpn"
        timeout 60s nordvpn connect --group p2p Czech_Republic || return 1
        exit_status=$?;
    done
    nordvpn set killswitch on
    nordvpn status

    # debug
    #rm nord-run.sh
  SHELL

  config.vm.provision "check if vpn connection is active", type: "shell", inline: <<-SHELL
    #curl -m 10 -s https://api.nordvpn.com/v1/helpers/ips/insights
    #echo disabled; exit;
    # https://github.com/bubuntux/nordvpn/blob/master/Dockerfile
    if test $( curl -m 10 -s https://api.nordvpn.com/v1/helpers/ips/insights | jq -r '.["protected"]' ) = "true" ; then 
      echo "vpn is connected"; 
    else 
      >&2 echo "vpn isn't connected!";
      exit 1; 
    fi

  SHELL

  config.vm.provision "file", source: "settings.json", destination: "~/"

  config.vm.provision "configure transmission gui", type: "shell", inline: <<-SHELL
    ufw allow 9091,51413/tcp

    service transmission-daemon stop
    # https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
    cp settings.json /etc/transmission-daemon/settings.json
    chown debian-transmission:debian-transmission -R /etc/transmission-daemon
    mv /var/lib/transmission-daemon/.config/transmission-daemon /var/lib/transmission-daemon/.config/transmission-daemon-old
  SHELL

  config.vm.provision "run transmission gui", type: "shell", inline: <<-SHELL
    ln -sf /mnt/ubu-storage/transmission-daemon/ /var/lib/transmission-daemon/.config/transmission-daemon
    chown debian-transmission:debian-transmission -R /var/lib/transmission-daemon
    chown debian-transmission:debian-transmission /var/lib/transmission-daemon/.config/transmission-daemon/*
    chown debian-transmission:debian-transmission -R /mnt/ubu-storage
    chmod 777 -R /mnt/ubu-storage/
    service transmission-daemon start
  SHELL

end
