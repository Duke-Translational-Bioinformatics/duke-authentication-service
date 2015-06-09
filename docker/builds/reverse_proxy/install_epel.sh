#!/bin/bash
wget -O /root/installs/epel-release-6-8.noarch.rpm http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh /root/installs/epel-release-6-8.noarch.rpm
rm /root/installs/epel-release-6-8.noarch.rpm
