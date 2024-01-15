#!/bin/bash
set -e

usage() {
    echo "$0 PCIADDR [NUM_VFs]"
    echo "  PCIADDR: The PCI address of the PF, e.g: 0000:40:00.0"
    echo "  NUM_VFS (defaul = 4): Number of VFs to configure"
    exit 1
}
error() {
    echo $@
    exit 1
}

gen_udev_script() {
    pf=$1
    switchid=$(ip -d link show ${pf} | sed -n 's/.* switchid \([^ ]*\).*/\1/p')
    [ -z ${switchid} ]  && error "cannot get switchid"
    cat <<EOF > /etc/udev/rules.d/82-net-setup-link-mlx.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{phys_switch_id}=="${switchid}", ATTR{phys_port_name}!="", NAME="\$attr{phys_port_name}"
EOF

}

get_eswitch_mode() {
    echo "get_eswitch_mode "
    echo $(devlink dev eswitch show pci/$(get_pci_addr ${pf}) | cut -d ' ' -f 3)
}

set_eswitch_mode() {
    pf=$1
    mode=$2
    devlink dev eswitch set pci/$(get_pci_addr ${pf})  mode ${mode}
#   devlink dev eswitch set pci/$(get_pci_addr ${pf})  encap disable
}
tc_offload() {
    pf=$1
    val=$(ethtool -k $pf | grep hw-tc-offload: | cut -d ':' -f 2 | tr -d '[:space:]')
    echo val
}

set_tc_offload() {
    pf=$1

echo "Setting switchdev_mode 3  ${pf}"
    ethtool -K $pf hw-tc-offload on
}

get_pci_addr() {
    pf=$1
    vf=$2
    if [ -z $vf ]; then
            echo $(basename $(readlink /sys/class/net/${pf}/device))
    else
            echo $(basename $(readlink /sys/class/net/${pf}/device/virtfn${vf}))
    fi
}

# The the device name of the representor
get_representor() {
    pf=$1
    vfid=$2

    switchid=$(ip -d link show ${pf} | sed -n 's/.* switchid \([^ ]*\).*/\1/p')
    # FXME: The following code including pf0 is not portable
    portname="pf0vf${vfid}"
    for dev in $(ls -x /sys/class/net); do
            [[ -f /sys/class/net/${dev}/phys_port_name ]] || continue
            [[ -f /sys/class/net/${dev}/phys_switch_id ]] || continue
            phys_port_name=$(cat /sys/class/net/${dev}/phys_port_name 2> /dev/null || true)
            phys_switch_id=$(cat /sys/class/net/${dev}/phys_switch_id 2> /dev/null || true)
            if [ "${phys_port_name}" == "$portname" ] && [ "${phys_switch_id}" == "${switchid}" ]; then
                    echo "$dev"
                    return
            fi
    done
}

get_hardcoded_vlan() {
    vfid=$1
    let vlan_id=100+10*${vfid}
    echo ${vlan_id}
}

PCI_ADDR=$1
NUM_VFS=${2:-4}

[ -z ${PCI_ADDR} ] && usage

echo "Loading vDPA Kernel modules"
modprobe vdpa
modprobe vhost-vdpa
modprobe mlx5-vdpa

echo "(Re)Starting OpenvSwitch"
systemctl stop openvswitch
systemctl start openvswitch

echo "Enabling OVS HW Offload"
ovs-vsctl set Open_vSwitch . other_config:hw-offload="true"

echo "Delete OVS Bridges:"
for br in `ovs-vsctl list-br`; do
    echo -n " $br"
    ovs-vsctl del-br $br
done
echo ""

echo "Creating VFs"
PF=$(ls -x /sys/bus/pci/devices/${PCI_ADDR}/net/)
    echo  "${PCI_ADDR}"
#echo 0 > /sys/class/net/${PF}/device/sriov_numvfs
echo 0 > /sys/bus/pci/devices/${PCI_ADDR}/sriov_numvfs
PF=$(ls -x /sys/bus/pci/devices/${PCI_ADDR}/net/)
#echo $NUM_VFS > /sys/class/net//device/sriov_numvfs
echo $NUM_VFS > /sys/bus/pci/devices/${PCI_ADDR}/sriov_numvfs
PF=$(ls -x /sys/bus/pci/devices/${PCI_ADDR}/net/)

num_vfs=$(cat /sys/class/net/${PF}/device/sriov_numvfs)
for i in $(seq 0 $(($num_vfs -1))); do
    echo "Unbinding VF ${i}"
    pci_addr=$(get_pci_addr ${PF} $i)
    echo $pci_addr >  /sys/bus/pci/drivers/mlx5_core/unbind
done

#PF=$(ls -x /sys/bus/pci/devices/${PCI_ADDR}/net/)
PF=$(ls -x  /sys/bus/pci/devices/${PCI_ADDR}/net/| awk '{print $1}')
set_eswitch_mode ${PF} switchdev
sleep 5
#PFNEW=$(ls -x  /sys/bus/pci/devices/${PCI_ADDR}/net/| awk '{print $1}')

echo "Setting switchdev_mode ${PF}"
nmcli device set ${PF} managed no

echo "Setting switchdev_mode 2  ${PF}"
set_tc_offload ${PF}
for i in $(seq 0 $(($num_vfs -1))); do
    echo "Binding VF ${i}"
    pci_addr=$(get_pci_addr ${PF} $i)
    echo $pci_addr >  /sys/bus/pci/drivers/mlx5_core/bind
    echo "Waiting for vf ${i} dev to be available "
    sleep 3

    devname=$(ls -x /sys/class/net/${PF}/device/virtfn${i}/net)
    [ -z "$devname" ] && error "Cannot get VF network device"
    set_tc_offload ${devname}

    echo  "${devname}"
    macaddr=`printf "%02x\n" ${i}`
    nmcli device set ${devname} managed no
    vdpa dev add name vdpa${i} mgmtdev pci/$pci_addr mac 00:11:22:33:44:${macaddr}
done


for i in $(seq 0 $(($num_vfs -1))); do
    devname=$(ls -x /sys/class/net/${PF}/device/virtfn${i}/net)
    rep=$(get_representor ${PF} $i)
    echo "Configuring ${devname} (rep: ${rep} )"
    set_tc_offload ${rep}
    nmcli device set ${rep} managed no
    ip link set ${rep} up
done

echo "Set PF link up"
ip link set ${PF} up

echo "Create OVS bridge"
br_name="${PF}_br"
ovs-vsctl add-br $br_name
ovs-vsctl add-port $br_name $PF
for i in $(seq 0 $(($num_vfs -1))); do
    rep=$(get_representor ${PF} $i)
    ovs-vsctl add-port $br_name $rep
done

echo "Set up OVS bridge up"
ip link set $br_name up
ip addr add 192.168.10.10/24 dev $br_name
dnsmasq --strict-order --bind-interfaces --listen-address 192.168.10.10 --dhcp-range 192.168.10.20,192.168.10.254 --dhcp-lease-max=253 --dhcp-no-override --pid-file=/tmp/dnsmasq.pid --log-facility=/tmp/dnsmasq.log
