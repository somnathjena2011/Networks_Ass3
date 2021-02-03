#!/bin/bash
#run after gaining root access: sudo -s
# FUNCTION DEFINITIONS
#create namespace
addNS(){
	[[ -e /var/run/netns/$1 ]] && ip netns delete $1
	ip netns add $1
}
#add pair of virtual ethernet interfaces to default namespace initially
#along with a veth peer
addVethPeer(){
	ip link add $1 type veth peer name $2
}
#connect namespaces to the default namespace
#by moving the virtual interface $1 to namespace in $2
setVethNS(){
	ip link set $1 netns $2
}
#bring up the veth interface $2 in namespace $1
setUpVeth(){
	ip netns exec $1 ip link set $2 up
}
#bring up loopback interface for namespace $1
setUpLo(){
	ip netns exec $1 ip link set lo up
}
#add ip addresse $2 to the veth interface $3 in namespace $1
addIP(){
	ip netns exec $1 ip addr add $2/24 dev $3
}
#add a default gateway to the network interface $1 via ip $2
#which will be used while connecting between different sub-networks
addDefaultGW(){
	ip netns exec $1 ip route add default via $2
}
#add a bridge $2 in namespace $1
#first check if bridge exists, if yes then delete
addBridge(){
	bridgeExists=$(ip netns exec $1 brctl show | grep -c "$2")
	if [[ $bridgeExists -gt 0 ]]
	then
		ip netns exec $1 ip link delete $2 type bridge
	fi
	ip netns exec $1 brctl addbr $2
}
#add virtual interfaces to bridge
#$1=>namespace,$2=>bridge,$3=>veth interface
addVethToBridge(){
	ip netns exec $1 brctl addif $2 $3
}
#add route in $1 namespace routing table to $2 network 
#via $3 host and device $3
addRoute(){
	ip netns exec $1 ip route add $2/24 via $3 dev $4
}

#add namespaces 
addNS N1
addNS N2
addNS N3
addNS N4
#add virtual ethernet interfaces
addVethPeer v1 v2
addVethPeer v3 v4
addVethPeer v5 v6
#set veth intefaces in namespaces
setVethNS v1 N1
setVethNS v2 N2
setVethNS v3 N2
setVethNS v4 N3
setVethNS v5 N3
setVethNS v6 N4
#bring up the veth interfaces
setUpVeth N1 v1
setUpVeth N2 v2
setUpVeth N2 v3
setUpVeth N3 v4
setUpVeth N3 v5
setUpVeth N4 v6
#bring up lo interfaces
setUpLo N1
setUpLo N2
setUpLo N3
setUpLo N4
#add IP addresses
addIP N1 10.0.10.47 v1
addIP N2 10.0.10.48 v2
addIP N2 10.0.20.47 v3
addIP N3 10.0.20.48 v4
addIP N3 10.0.30.47 v5
addIP N4 10.0.30.48 v6
#add default routing
#addDefaultGW H1 10.0.10.47 veth1
#addDefaultGW H2 10.0.20.47 veth6
#addDefaultGW H3 10.0.30.47 veth5
#addDefaultGW R 10.0.10.1 veth2
#add routing
addRoute N1 10.0.20.0 10.0.10.48 v1
addRoute N1 10.0.30.0 10.0.10.48 v1
addRoute N2 10.0.30.0 10.0.20.48 v3
addRoute N3 10.0.10.0 10.0.20.47 v4
addRoute N4 10.0.10.0 10.0.30.47 v6
addRoute N4 10.0.20.0 10.0.30.47 v6
#add bridges
#addBridge N2 br2
#addBridge N3 br3
##add veths to bridges
#addVethToBridge N2 br2 v2
#addVethToBridge N2 br2 v3
#addVethToBridge N3 br3 v4
#addVethToBridge N3 br3 v4
##enable ip forwarding at N2 and N3
ip netns exec N2 sysctl -wq net.ipv4.ip_forward=1
ip netns exec N3 sysctl -wq net.ipv4.ip_forward=1
##bring up the bridges
#setUpVeth N2 br2
#setUpVeth N3 br3
#pings
ip netns exec N1 ping -c 3 10.0.10.47
ip netns exec N2 ping -c 3 10.0.10.48
ip netns exec N1 ping -c 3 10.0.20.47
ip netns exec N1 ping -c 3 10.0.20.48
ip netns exec N1 ping -c 3 10.0.30.47
ip netns exec N1 ping -c 3 10.0.30.48

ip netns exec N2 ping -c 3 10.0.10.47
ip netns exec N2 ping -c 3 10.0.10.48
ip netns exec N2 ping -c 3 10.0.20.47
ip netns exec N2 ping -c 3 10.0.20.48
ip netns exec N2 ping -c 3 10.0.30.47
ip netns exec N2 ping -c 3 10.0.30.48

ip netns exec N3 ping -c 3 10.0.10.47
ip netns exec N3 ping -c 3 10.0.10.48
ip netns exec N3 ping -c 3 10.0.20.47
ip netns exec N3 ping -c 3 10.0.20.48
ip netns exec N3 ping -c 3 10.0.30.47
ip netns exec N3 ping -c 3 10.0.30.48