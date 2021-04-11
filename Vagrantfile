

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.network "private_network", ip: "192.168.10.147"

  config.vm.provision "install nordvpn", type: "shell", inline: <<-SHELL
    apt-get update && \
    apt-get install -y curl wget;
    
    wget https://downloads.nordcdn.com/apps/linux/install.sh 2>/dev/null;
    chmod +x install.sh;
    ./install.sh -n;

    service nordvpn status
    service nordvpn start
    service nordvpn status
  
    #chmod +x nord-run.sh
    #bash nord-run.sh
    #nordvpn status
    ###rm nord-run.sh
    ###nordvpn set killswitch on
  SHELL

  config.vm.provision "create nordvpn login script", type: "shell" do |s|
    username = ENV['NORDVPN_USERNAME']
    password = ENV['NORDVPN_PASSWORD']
    s.inline = "echo \"#!/bin/bash\nnordvpn whitelist add port 22\nnordvpn login -u '#{username}' -p '#{password}'\nexit 0\" > nord-run.sh"
  end

  config.vm.provision "connect to vpn", type: "shell", inline: <<-SHELL
    chmod +x nord-run.sh
    nordvpn status
    bash nord-run.sh
    nordvpn status
    nordvpn connect P2P
    nordvpn status
    nordvpn set killswitch on
    rm nord-run.sh
  SHELL

end
