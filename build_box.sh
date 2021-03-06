#!/usr/bin/env bash
set -e

MACHINE="measurebox_dev"

# needed to resize the guest
#export VAGRANT_EXPERIMENTAL="disks"

# alternative disk resize choice
#vagrant plugin install vagrant-disksize

# provision
vagrant up
echo "Done provisioning"

# replace the ssh key and shut off the machine
vagrant ssh -c 'curl -fsSL -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys; chown -R vagrant:vagrant ~/.ssh; history -r; sudo shutdown -P now' | true
echo "Shutdown initiated"

# dump ssh config
#vagrant ssh-config > vagrant-ssh

# replace the ssh key and shut off the machine
#sshpass -p vagrant ssh -F vagrant-ssh vagrant:@default 'curl -fsSL -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub;chmod 700 ~/.ssh;chmod 600 ~/.ssh/authorized_keys;chown -R vagrant:vagrant ~/.ssh'

# ask machine to shutdown with password login
#sshpass -p vagrant ssh -F vagrant-ssh vagrant:@default 'sudo shutdown -P now'
#rm vagrant-ssh

# wait for the shutdown to complete
until $(VBoxManage showvminfo --machinereadable ${MACHINE} | grep -q ^VMState=.poweroff.)
do
  sleep 1
done
sleep 1
echo "Shutdown done"

# package the box
rm out.box | true
rm -rf vtmp | true
VAGRANT_HOME=./vtmp vagrant package --base ${MACHINE} --output ./out.box
rm -rf vtmp | true
echo "Packaging done"

# read its checksum
echo "Calculating SHA512 checksum..."
sha512sum out.box
