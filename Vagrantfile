# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/zesty64"
    ubuntu.vm.provision "shell", inline: <<SHELL
apt update;
apt install -yq build-essential;
apt upgrade -yq;
sudo -iu ubuntu bash -c 'git clone https://github.com/tadzik/rakudobrew ~/.rakudobrew; eval "$(~/.rakudobrew/bin/rakudobrew init -)";echo '"'"'eval "'"''"'$'"''"'(~/.rakudobrew/bin/rakudobrew init -)"'"'"' >> ~/.profile;rakudobrew build moar;rakudobrew build zef;zef --depsonly --/test install /vagrant;'
SHELL
  end

  config.vm.define "freebsd" do |freebsd|
    freebsd.vm.box = "bento/freebsd-10.3"
    freebsd.vm.synced_folder ".", "/vagrant", type: "sshfs", sshfs_opts_append: "-o cache=no -o direct_io"

    freebsd.vm.provision "shell", inline: <<SHELL
pkg update;
pkg install -y gmake git;
pkg upgrade -y;
git clone https://github.com/tadzik/rakudobrew /opt/rakudobrew;
eval "$(/opt/rakudobrew/bin/rakudobrew init -)"
echo 'eval "$(/opt/rakudobrew/bin/rakudobrew init -)"' | tee -a ~/.profile >> /home/vagrant/.profile;
rakudobrew build moar;
rakudobrew build zef;
zef --depsonly --/test install /vagrant;
SHELL
  end

  config.vm.define "void" do |void|
    void.vm.box = "APELabs/voidlinux";
    void.vm.provision "shell", inline: <<SHELL
xbps-install -Syu;
xbps-install -Sy git make gcc perl;
git clone https://github.com/tadzik/rakudobrew /opt/rakudobrew;
eval "$(/opt/rakudobrew/bin/rakudobrew init -)"
echo 'eval "$(/opt/rakudobrew/bin/rakudobrew init -)"' | tee -a ~/.profile >> /root/.profile;
rakudobrew build moar;
rakudobrew build zef;
zef --depsonly --/test install /vagrant;
SHELL
  end

	config.vm.provider "virtualbox" do |v|
	  v.memory = 4096
	  v.cpus = 2
	end
end
