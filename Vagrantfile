# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/zesty64"
  config.vm.provision "shell", inline: <<SHELL
apt update;
apt install -yq build-essential;
apt upgrade -yq;
sudo -iu ubuntu bash <<BASH
git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew;
eval "$(~/.rakudobrew/bin/rakudobrew init -)";
echo 'eval "''$''"(~/.rakudobrew/bin/rakudobrew init -)"' >> ~/.profile;
rakudobrew build moar;
rakudobrew build zef;
zef --depsonly --/test install /vagrant;
BASH
SHELL

	config.vm.provider "virtualbox" do |v|
	  v.memory = 4096
	  v.cpus = 2
	end

end
