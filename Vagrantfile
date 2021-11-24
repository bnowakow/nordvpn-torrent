Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.network "private_network", ip: "192.168.10.147"
  config.vm.network :forwarded_port, guest: 9091, host: 9091, auto_correct: true

  # native nfs
  #config.vm.synced_folder "/mnt/ubu-storage/", "/mnt/ubu-storage/", type: "nfs"
  
  # rsync as woraround that I use with vagrant rsync-back  
  # https://stackoverflow.com/a/35821148
  #config.vm.synced_folder "/mnt/ubu-storage/", "/mnt/ubu-storage/", type: "rsync", rsync__auto: true, rsync__exclude: ['lost+found', '/mnt/ubu-storage/lost+found']
  # https://askubuntu.com/a/1015068
  #config.disksize.size = '70GB'

  config.vm.provision "install nordvpn", type: "shell", inline: <<-SHELL
    apt-get update && \
    apt-get install -y curl wget jq ntp ncdu;

    #wget https://downloads.nordcdn.com/apps/linux/install.sh 2>/dev/null;
    #chmod +x install.sh;
    #./install.sh -n;

    # NordVPN support suggested that way of installation
    wget "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb"
    sudo dpkg -i nordvpn-release_1.0.0_all.deb
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install nordvpn -y

    sudo usermod -aG nordvpn $USER

    service nordvpn start
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
    #nordvpn set protocol tcp
    #nordvpn set technology nordlynx
    #nordvpn set obfuscate on

    bash nord-run.sh
    nordvpn connect --group p2p Czech_Republic
    nordvpn set killswitch on
    nordvpn status

    # debug
    #rm nord-run.sh
  SHELL

  config.vm.provision "check if vpn connection is active", type: "shell", inline: <<-SHELL
    # https://github.com/bubuntux/nordvpn/blob/master/Dockerfile
    if test $( curl -m 10 -s https://api.nordvpn.com/v1/helpers/ips/insights | jq -r '.["protected"]' ) = "true" ; then 
      echo "vpn is connected"; 
    else 
      >&2 echo "vpn isn't connected!";
      exit 1; 
    fi

  SHELL

  config.vm.provision "nfs workaround", type: "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y nfs-common
    mkdir -p /mnt/ubu-storage;
    mount -vvv -o vers=3,udp 10.0.2.2:/mnt/ubu-storage /mnt/ubu-storage
  SHELL

  config.vm.provision "file", source: "settings.json", destination: "~/"

  config.vm.provision "install transmission gui", type: "shell", inline: <<-SHELL
    ufw allow 9091,51413/tcp
    
    sudo apt-get -y install transmission-daemon
    service transmission-daemon stop
    # https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
    cp settings.json /etc/transmission-daemon/settings.json
    chown debian-transmission:debian-transmission -R /etc/transmission-daemon
    mv /var/lib/transmission-daemon/.config/transmission-daemon /var/lib/transmission-daemon/.config/transmission-daemon-old
  SHELL

  config.vm.provision "run transmission gui", type: "shell", inline: <<-SHELL
    ln -sf /mnt/ubu-storage/Plex/transmission-daemon/ /var/lib/transmission-daemon/.config/transmission-daemon
    chown debian-transmission:debian-transmission -R /var/lib/transmission-daemon
    chown debian-transmission:debian-transmission /var/lib/transmission-daemon/.config/transmission-daemon/*
    chown debian-transmission:debian-transmission -R /mnt/ubu-storage/Plex
    chmod 777 -R /mnt/ubu-storage/
    service transmission-daemon start
  SHELL

end
