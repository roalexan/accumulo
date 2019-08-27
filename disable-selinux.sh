#!/bin/bash
# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
# https://linuxize.com/post/how-to-disable-selinux-on-centos-7/
sed -i "/^SELINUX=enforcing/c\SELINUX=disabled" /etc/selinux/config
#shutdown -r now
