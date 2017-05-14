# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/zesty64"
  config.vm.provision "shell", inline: <<SHELL
apt update
apt upgrade
wget -Operl6.deb https://github.com/nxadm/rakudo-pkg/releases/download/2017.04.2/perl6-rakudo-moarvm-ubuntu17.04_20170402-01_amd64.deb
dpkg -i perl6.deb
rm perl6.deb
/opt/rakudo/bin/install_zef_as_root.sh
echo "export PATH=/opt/rakudo/bin:$PATH" >> .bashrc
/opt/rakudo/bin/zef --depsonly --/test /vagrant
SHELL
end
