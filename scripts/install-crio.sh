#!/usr/bin/env bash

sudo dnf install -y \
	  containers-common \
	  device-mapper-devel \
	  git \
	  make \
	  glib2-devel \
	  glibc-devel \
	  glibc-static \
	  runc \
	  gpgmepp-devel \
	  libassuan-devel


sudo dnf install -y http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/cri-o/1.23.0/98.rhaos4.10.git9b7f5ae.el8/x86_64/cri-o-1.23.0-98.rhaos4.10.git9b7f5ae.el8.x86_64.rpm

sudo systemctl enable crio
sleep 3
sudo systemctl start crio
sleep 3
