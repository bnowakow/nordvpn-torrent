Vagrant.configure("2") do |config|
  config.vm.box = "bnowakow/nordvpn-torrent"

  config.vm.network :forwarded_port, guest: 9091, host: 9091, auto_correct: true

  # rsync as woraround that I use with vagrant rsync-back  
  # https://stackoverflow.com/a/35821148
  config.vm.synced_folder "/mnt/PlexPool/plex", "/mnt/ubu-storage/Plex", type: "rsync", rsync__auto: true, 
        rsync__exclude: ['lost+found', 'TV-Series-non-rsync', 'Movies-non-rsync', 'Downloads'] 
  # https://askubuntu.com/a/1015068
  config.disksize.size = '100GB'

  config.vm.provision "file", source: "settings.json", destination: "~/"

  config.vm.provision "configure transmission gui", type: "shell", inline: <<-SHELL
    ufw allow 9091,51413/tcp

    service transmission-daemon stop
    # https://linuxconfig.org/how-to-set-up-transmission-daemon-on-a-raspberry-pi-and-control-it-via-web-interface
    cp settings.json /etc/transmission-daemon/settings.json
    chown debian-transmission:debian-transmission -R /etc/transmission-daemon
    mv /var/lib/transmission-daemon/.config/transmission-daemon /var/lib/transmission-daemon/.config/transmission-daemon-old
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
    nordvpn set protocol tcp
    #nordvpn set technology nordlynx
    #nordvpn set obfuscate on

    bash nord-run.sh
    nordvpn set autoconnect on Czech_Republic p2p
    nordvpn connect --group p2p Czech_Republic
    nordvpn set killswitch on
    nordvpn status

    # debug
    #rm nord-run.sh
  SHELL

  config.vm.provision "check if vpn connection is active", type: "shell", inline: <<-SHELL
    #echo debug disabled; exit
    # https://github.com/bubuntux/nordvpn/blob/master/Dockerfile
    if test $( curl -m 10 -s https://api.nordvpn.com/v1/helpers/ips/insights | jq -r '.["protected"]' ) = "true" ; then 
      echo "vpn is connected"; 
    else 
      >&2 echo "vpn isn't connected!";
      exit 1; 
    fi

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
