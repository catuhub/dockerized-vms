#!/bin/bash

chown root:kvm /dev/kvm
service libvirtd start
service virtlogd start

status=1

echo "Waiting for device virbr0 being brought up by libvirt..."

while [ $status -ne 0 ]; do
	ifconfig virbr0 2> /dev/null | grep inet 
	status=$?
done

echo "Device virbr0 active!"
echo "Setting iptables rules for ssh..."

iptables -A FORWARD -i eth0 -o virbr0 -p tcp --syn --dport 22 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -i eth0 -o virbr0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i virbr0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 22 -j DNAT --to-destination 192.168.122.10
iptables -t nat -A POSTROUTING -o virbr0 -p tcp --dport 22 -d 192.168.122.10 -j SNAT --to-source 192.168.122.1

iptables -D FORWARD -o virbr0 -j REJECT --reject-with icmp-port-unreachable
iptables -D FORWARD -i virbr0 -j REJECT --reject-with icmp-port-unreachable

echo "Starting virtual machine. This can take a couple of minutes..."

qemu-system-x86_64 -hda /image.img -m 2048 -enable-kvm -nographic -device e1000,netdev=vm0 -netdev tap,id=vm0,script=/root/qemu-ifup,downscript=/root/qemu-ifdown
