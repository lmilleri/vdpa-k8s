#!/usr/bin/env bash

sudo systemctl stop crio
sudo systemctl disable crio

sudo dnf remove -y http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/cri-o/1.23.0/98.rhaos4.10.git9b7f5ae.el8/x86_64/cri-o-1.23.0-98.rhaos4.10.git9b7f5ae.el8.x86_64.rpm

sudo dnf remove -y \
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


