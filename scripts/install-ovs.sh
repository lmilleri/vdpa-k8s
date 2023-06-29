#!/usr/bin/env bash

start_ovs() {
	if /usr/share/openvswitch/scripts/ovs-ctl status ; then
		echo "OvS already running"
	else
		if [ -f "/etc/openvswitch/conf.db" ]; then
			echo "Do you want to remove the OpenVSwitch configuration? (y/n)"
			read proceed
			if [ $proceed == "y" ]; then
				sudo rm /etc/openvswitch/conf.db
			fi
																											           fi
		sudo systemctl start openvswitch
		sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:hw-offload="true"
		sudo systemctl restart openvswitch
	fi
	sudo ovs-vsctl add-br br-int || true
	sudo ovs-vsctl add-br breno1 || true
}

start_ovs
