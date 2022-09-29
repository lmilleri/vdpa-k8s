#!/usr/bin/env bash

stop_ovs() {
	sudo systemctl stop openvswitch || true
	sudo ovs-dpctl del-dp ovs-system || true
	sudo rmmod openvswitch || true
}

restart_network_manager() {
	sudo systemctl restart NetworkManager || true
	sudo nmcli c down eno1 || true
	sudo nmcli c up eno1 || true
}

stop_ovs
restart_network_manager
