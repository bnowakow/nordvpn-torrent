

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.network "private_network", ip: "192.168.10.147"
  config.vm.network :forwarded_port, guest: 9091, host: 9091

  config.vm.synced_folder "/mnt/ubu-storage/", "/mnt/ubu-storage/" #, type: "nfs"
  #config.vm.synced_folder "/mnt/ubu-storage/Plex/transmission-daemon", "/var/lib/transmission-daemon/.config/transmission-daemon" #, type: "nfs"  

  config.vm.provision "install nordvpn", type: "shell", inline: <<-SHELL
    apt-get update && \
    apt-get install -y curl wget;
    
    wget https://downloads.nordcdn.com/apps/linux/install.sh 2>/dev/null;
    chmod +x install.sh;
    ./install.sh -n;

    service nordvpn status
    service nordvpn start
    service nordvpn status
  SHELL

  config.vm.provision "check environment variables", type: "shell" do |s|
    username = ENV['NORDVPN_USERNAME']
    password = ENV['NORDVPN_PASSWORD']
    s.inline = "if [[ -z \"#{username}\" || -z \"#{password}\" ]]; then >&2 echo 'please set NORDVPN_USERNAME and NORDVPN_PASSWORD env variables'; exit 1; else echo 'env variables are set'; fi;"
  end

  config.vm.provision "create nordvpn login script", type: "shell" do |s|
    username = ENV['NORDVPN_USERNAME']
    password = ENV['NORDVPN_PASSWORD']
    s.inline = "echo \"#!/bin/bash\nnordvpn login -u '#{username}' -p '#{password}'\" > nord-run.sh"
  end

  config.vm.provision "connect to vpn", type: "shell", inline: <<-SHELL
    chmod +x nord-run.sh
    nordvpn whitelist add port 22
    nordvpn whitelist add port 2222
    nordvpn whitelist add port 9091
    nordvpn status
    bash nord-run.sh
    nordvpn status
    nordvpn connect Czech_Republic -g P2P
    nordvpn status
    nordvpn set killswitch on
    rm nord-run.sh
  SHELL

  config.vm.provision "file", source: "settings.json", destination: "~/"

  config.vm.provision "install transmission gui", type: "shell", inline: <<-SHELL
    # todo check if nord is running
    ufw allow 9091,51413/tcp
    sudo apt-get -y install transmission-daemon
    service transmission-daemon status
    service transmission-daemon stop
    service transmission-daemon status
    # https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
    cp settings.json /etc/transmission-daemon/settings.json
    chown debian-transmission:debian-transmission -R /etc/transmission-daemon
    mv /var/lib/transmission-daemon/.config/transmission-daemon /var/lib/transmission-daemon/.config/transmission-daemon-old
  SHELL

  config.vm.provision "run transmission gui", type: "shell", inline: <<-SHELL
    #ln -sf /mnt/ubu-storage/Plex/transmission-daemon/ /var/lib/transmission-daemon/.config/transmission-daemon
    cp -r /vagrant/transmission-daemon /var/lib/transmission-daemon/.config/
    chown debian-transmission:debian-transmission -R /var/lib/transmission-daemon
    service transmission-daemon start
  SHELL

end
