#!/bin/bash

# Script expects to be run with sudo

# Run remotely with: 
# IP=10.10.10.10; scp node_setup.sh pi@$IP:~/ && ssh -t pi@$IP "sudo ~/node_setup.sh && rm ~/node_setup.sh"

apt update 
apt upgrade -y 
       
snap install microk8s --classic

##### Enable necessary features #####

sed -i '${s/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1/}' /boot/firmware/cmdline.txt


##### Add user to microk8s group #####

usermod -a -G microk8s pi
mkdir -p /home/pi/.kube
chown -f -R pi /home/pi/.kube

reboot
