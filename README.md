# Dockerized VMs for Ethical Hacking Playgrounds
Run virtual machines in Docker containers for Linux using qemu and practice exploitation techniques overcoming containers limitations, such as shared kernel space.

## Getting Started
```
# git clone https://github.com/catuhub/dockerized-vms.git
# cd dockerized-vms
```

Provide the path to your qemu virtual disk (.img) in the docker-compose file

```
# docker-compose up
```

docker-compose will build the Docker image the first time and then run the virtual machine inside the container.
After a few minutes you can access the virtual machine using ssh

```
# ssh <user>@192.168.20.2
```
## Prerequisites
* Docker
* docker-compose
* KVM
### 1. Check requirements for KVM
```
# egrep -c '(vmx|svm)' /proc/cpuinfo
# 0 not good
# 1 or more is good
```

0 means that VT-x or AMD-v are not enabled.
Please enable them in your BIOS/UEFI. 

If you are using a VM, you need to enable nested virtualization extensions according to your type-2 hypervisors.
For instance, if you are using VirtualBox, nested virtualization is active by default, only you need to enable it for the specific VM using the following command:
```
# VBoxManage modifyvm <name_vm> --nested-hw-virt on
```

### 2. Check if KVM module is loaded

```
# lsmod | grep kvm  
prints:
# kvm
# kvm_intel or kvm_amd
```
If not loaded, please load it:

```
#eg. for intel
# modprobe kvm 
or 
# modprobe kvm_intel
```
### 3. Virtual Machine configuration
The image for the qemu vm can be created using the following command:
```
# qemu-img create -f qcow2 vulnerable_vm.img 5G
```
Then you can start the installation, using the cdrom boot qemu option:
```
# qemu-system-x86_64 -smp 1 -hda vulnerable_vm.img -cdrom vm.iso -m 2048 -boot c -enable-kvm
```
### 3.1 Network Configuration
In order to access the virtual machine from outside the container, an ssh server needs to be installed.
Also, the virtual machine needs to have a static IP address configuration. The one used in the scripts of this repo is "192.168.122.10".
To do so, just modify the /etc/network/interfaces file appending the following info:
```
# The primary network interface
auto ens3
iface ens3 inet static
address 192.168.122.10
netmask 255.255.255.0
gateway 192.168.122.1
dns-nameservers 8.8.8.8 8.8.4.4
```
and then restart the networking service
```
service networking restart
```
TODO: add Packer scripts to automate the installation and provisioning of the vulnerable VM

### 3.2 Connect Console to Terminal
If you wish to view the virtual machine logs inside the terminal executing the docker-compose command, modify the /etc/default/grub file:
```
# uncomment GRUB_TERMINAL=console
# give non-zero value to GRUB_TIMEOUT=
# GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0 earlyprintk=ttyS0 ftrace_dump_on_oops"
```
then update grub (from root). Changes are effective after the first restart.
```
# update-grub
# shutdown -h now
```
