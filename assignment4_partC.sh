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
addNS N5
addNS N6
#add virtual ethernet interfaces
addVethPeer v1 v2
addVethPeer v3 v4
addVethPeer v5 v6
addVethPeer v7 v8
addVethPeer v9 v10
addVethPeer v11 v12
#set veth intefaces in namespaces
setVethNS v1 N1
setVethNS v2 N2
setVethNS v3 N2
setVethNS v4 N3
setVethNS v5 N3
setVethNS v6 N4
setVethNS v7 N4
setVethNS v8 N5
setVethNS v9 N5
setVethNS v10 N6
setVethNS v11 N6
setVethNS v12 N1
#bring up the veth interfaces
setUpVeth N1 v1
setUpVeth N2 v2
setUpVeth N2 v3
setUpVeth N3 v4
setUpVeth N3 v5
setUpVeth N4 v6
setUpVeth N4 v7
setUpVeth N5 v8
setUpVeth N5 v9
setUpVeth N6 v10
setUpVeth N6 v11
setUpVeth N1 v12
#bring up lo interfaces
setUpLo N1
setUpLo N2
setUpLo N3
setUpLo N4
setUpLo N5
setUpLo N6
#add IP addresses
addIP N1 10.0.10.47 v1
addIP N2 10.0.10.48 v2
addIP N2 10.0.20.47 v3
addIP N3 10.0.20.48 v4
addIP N3 10.0.30.47 v5
addIP N4 10.0.30.48 v6
addIP N4 10.0.40.47 v7
addIP N5 10.0.40.48 v8
addIP N5 10.0.50.47 v9
addIP N6 10.0.50.48 v10
addIP N6 10.0.60.47 v11
addIP N1 10.0.60.48 v12
#add routing
echo Adding routes to N1
addRoute N1 10.0.20.0 10.0.10.48 v1
addRoute N1 10.0.30.0 10.0.10.48 v1
addRoute N1 10.0.40.0 10.0.10.48 v1
addRoute N1 10.0.50.0 10.0.10.48 v1

echo Adding routes to N2
addRoute N2 10.0.30.0 10.0.20.48 v3
addRoute N2 10.0.40.0 10.0.20.48 v3
addRoute N2 10.0.50.0 10.0.20.48 v3
addRoute N2 10.0.60.0 10.0.20.48 v3

echo Adding routes to N3
addRoute N3 10.0.10.0 10.0.30.48 v5
addRoute N3 10.0.40.0 10.0.30.48 v5
addRoute N3 10.0.50.0 10.0.30.48 v5
addRoute N3 10.0.60.0 10.0.30.48 v5

echo Adding routes to N4
addRoute N4 10.0.10.0 10.0.40.48 v7
addRoute N4 10.0.20.0 10.0.40.48 v7
addRoute N4 10.0.50.0 10.0.40.48 v7
addRoute N4 10.0.60.0 10.0.40.48 v7

echo Adding routes to N5
addRoute N5 10.0.10.0 10.0.50.48 v9
addRoute N5 10.0.20.0 10.0.50.48 v9
addRoute N5 10.0.30.0 10.0.50.48 v9
addRoute N5 10.0.60.0 10.0.50.48 v9

echo Adding routes to N6
addRoute N6 10.0.10.0 10.0.60.48 v11
addRoute N6 10.0.20.0 10.0.60.48 v11
addRoute N6 10.0.30.0 10.0.60.48 v11
addRoute N6 10.0.40.0 10.0.60.48 v11
##enable ip forwarding at all namespaces
ip netns exec N1 sysctl -wq net.ipv4.ip_forward=1
ip netns exec N2 sysctl -wq net.ipv4.ip_forward=1
ip netns exec N3 sysctl -wq net.ipv4.ip_forward=1
ip netns exec N4 sysctl -wq net.ipv4.ip_forward=1
ip netns exec N5 sysctl -wq net.ipv4.ip_forward=1
ip netns exec N6 sysctl -wq net.ipv4.ip_forward=1
#pings
ip netns exec N1 ping -c 3 10.0.20.48
ip netns exec N1 ping -c 3 10.0.30.47
#trace route from N1 to N5
ip netns exec N1 traceroute -m 10 10.0.40.48
ip netns exec N1 traceroute -m 10 10.0.50.47
#trace route from N3 to N5
ip netns exec N3 traceroute -m 10 10.0.40.48
ip netns exec N3 traceroute -m 10 10.0.50.47
#trace route from N3 to N1
ip netns exec N3 traceroute -m 10 10.0.10.47
ip netns exec N3 traceroute -m 10 10.0.60.48