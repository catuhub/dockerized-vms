#!/bin/bash
mv /tmp/grub /etc/default/grub
update-grub
mv /tmp/interfaces /etc/network/interfaces
service networking restart
