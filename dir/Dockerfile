FROM ubuntu:18.04

RUN apt-get update -y && apt-get install -y qemu-kvm libvirt-daemon-system libvirt-dev bridge-utils iputils-ping net-tools
RUN apt-get autoclean
RUN apt-get autoremove

COPY qemu-ifup /root/qemu-ifup
COPY qemu-ifdown /root/qemu-ifdown
COPY startup.sh /root/startup.sh

ENTRYPOINT ["/root/startup.sh"]
