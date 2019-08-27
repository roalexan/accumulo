#!/bin/bash
# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
sudo sed -i "/^SELINUX=enforcing/c\SELINUX=disabled" /etc/selinux/config
#sudo shutdown -r now
