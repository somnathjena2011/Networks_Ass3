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
#add route in $1 namespace routing table to $2 network 
#via $3 host and device $3
addRoute(){
	ip netns exec $1 ip route add $2/24 via $3 dev $4
}

#add namespaces 
addNS H1
addNS H2
addNS H3
addNS H4
addNS R1
addNS R2
addNS R3
#add virtual ethernet interfaces
addVethPeer v1 v2
addVethPeer v3 v4
addVethPeer v5 v6
addVethPeer v7 v8
addVethPeer v9 v10
addVethPeer v11 v12
#set veth intefaces in namespaces
setVethNS v1 H1
setVethNS v2 R1
setVethNS v3 H2
setVethNS v4 R1
setVethNS v5 R1
setVethNS v6 R2
setVethNS v7 R2
setVethNS v8 R3
setVethNS v9 R3
setVethNS v10 H3
setVethNS v11 R3
setVethNS v12 H4
#bring up the veth interfaces
setUpVeth H1 v1
setUpVeth R1 v2
setUpVeth H2 v3
setUpVeth R1 v4
setUpVeth R1 v5
setUpVeth R2 v6
setUpVeth R2 v7
setUpVeth R3 v8
setUpVeth R3 v9
setUpVeth H3 v10
setUpVeth R3 v11
setUpVeth H4 v12
#bring up lo interfaces
setUpLo H1
setUpLo H2
setUpLo H3
setUpLo H4
setUpLo R1
setUpLo R2
setUpLo R3
#add IP addresses
addIP H1 10.0.10.47 v1
addIP R1 10.0.10.48 v2
addIP H2 10.0.20.47 v3
addIP R1 10.0.20.48 v4
addIP R1 10.0.30.47 v5
addIP R2 10.0.30.48 v6
addIP R2 10.0.40.47 v7
addIP R3 10.0.40.48 v8
addIP R3 10.0.50.47 v9
addIP H3 10.0.50.48 v10
addIP R3 10.0.60.47 v11
addIP H4 10.0.60.48 v12
#add routing
echo Adding routes to H1
addRoute H1 10.0.20.0 10.0.10.48 v1
addRoute H1 10.0.30.0 10.0.10.48 v1
addRoute H1 10.0.40.0 10.0.10.48 v1
addRoute H1 10.0.50.0 10.0.10.48 v1
addRoute H1 10.0.60.0 10.0.10.48 v1

echo Adding routes to H2
addRoute H2 10.0.10.0 10.0.20.48 v3
addRoute H2 10.0.30.0 10.0.20.48 v3
addRoute H2 10.0.40.0 10.0.20.48 v3
addRoute H2 10.0.50.0 10.0.20.48 v3
addRoute H2 10.0.60.0 10.0.20.48 v3

echo Adding routes to H3
addRoute H3 10.0.10.0 10.0.50.47 v10
addRoute H3 10.0.20.0 10.0.50.47 v10
addRoute H3 10.0.30.0 10.0.50.47 v10
addRoute H3 10.0.40.0 10.0.50.47 v10
addRoute H3 10.0.60.0 10.0.50.47 v10

echo Adding routes to H4
addRoute H4 10.0.10.0 10.0.60.47 v12
addRoute H4 10.0.20.0 10.0.60.47 v12
addRoute H4 10.0.30.0 10.0.60.47 v12
addRoute H4 10.0.40.0 10.0.60.47 v12
addRoute H4 10.0.50.0 10.0.60.47 v12

echo Adding routes to R1
addRoute R1 10.0.40.0 10.0.30.48 v5
addRoute R1 10.0.50.0 10.0.30.48 v5
addRoute R1 10.0.60.0 10.0.30.48 v5

echo Adding routes to R2
addRoute R2 10.0.10.0 10.0.30.47 v6
addRoute R2 10.0.20.0 10.0.30.47 v6
addRoute R2 10.0.50.0 10.0.40.48 v7
addRoute R2 10.0.60.0 10.0.40.48 v7

echo Adding routes to R3
addRoute R3 10.0.10.0 10.0.40.47 v8
addRoute R3 10.0.20.0 10.0.40.47 v8
addRoute R3 10.0.30.0 10.0.40.47 v8
##enable ip forwarding at R1,R2 and R3
ip netns exec R1 sysctl -wq net.ipv4.ip_forward=1
ip netns exec R2 sysctl -wq net.ipv4.ip_forward=1
ip netns exec R3 sysctl -wq net.ipv4.ip_forward=1
#pings
ip netns exec R1 ping -c 3 10.0.10.47
ip netns exec R1 ping -c 3 10.0.10.48
ip netns exec R1 ping -c 3 10.0.20.47
ip netns exec R1 ping -c 3 10.0.20.48
ip netns exec R1 ping -c 3 10.0.30.47
ip netns exec R1 ping -c 3 10.0.30.48
ip netns exec R1 ping -c 3 10.0.40.47
ip netns exec R1 ping -c 3 10.0.40.48
ip netns exec R1 ping -c 3 10.0.50.47
ip netns exec R1 ping -c 3 10.0.50.48
ip netns exec R1 ping -c 3 10.0.60.47
ip netns exec R1 ping -c 3 10.0.60.48

ip netns exec R2 ping -c 3 10.0.10.47
ip netns exec R2 ping -c 3 10.0.10.48
ip netns exec R2 ping -c 3 10.0.20.47
ip netns exec R2 ping -c 3 10.0.20.48
ip netns exec R2 ping -c 3 10.0.30.47
ip netns exec R2 ping -c 3 10.0.30.48
ip netns exec R2 ping -c 3 10.0.40.47
ip netns exec R2 ping -c 3 10.0.40.48
ip netns exec R2 ping -c 3 10.0.50.47
ip netns exec R2 ping -c 3 10.0.50.48
ip netns exec R2 ping -c 3 10.0.60.47
ip netns exec R2 ping -c 3 10.0.60.48

ip netns exec R3 ping -c 3 10.0.10.47
ip netns exec R3 ping -c 3 10.0.10.48
ip netns exec R3 ping -c 3 10.0.20.47
ip netns exec R3 ping -c 3 10.0.20.48
ip netns exec R3 ping -c 3 10.0.30.47
ip netns exec R3 ping -c 3 10.0.30.48
ip netns exec R3 ping -c 3 10.0.40.47
ip netns exec R3 ping -c 3 10.0.40.48
ip netns exec R3 ping -c 3 10.0.50.47
ip netns exec R3 ping -c 3 10.0.50.48
ip netns exec R3 ping -c 3 10.0.60.47
ip netns exec R3 ping -c 3 10.0.60.48

ip netns exec H1 ping -c 3 10.0.10.47
ip netns exec H1 ping -c 3 10.0.10.48
ip netns exec H1 ping -c 3 10.0.20.47
ip netns exec H1 ping -c 3 10.0.20.48
ip netns exec H1 ping -c 3 10.0.30.47
ip netns exec H1 ping -c 3 10.0.30.48
ip netns exec H1 ping -c 3 10.0.40.47
ip netns exec H1 ping -c 3 10.0.40.48
ip netns exec H1 ping -c 3 10.0.50.47
ip netns exec H1 ping -c 3 10.0.50.48
ip netns exec H1 ping -c 3 10.0.60.47
ip netns exec H1 ping -c 3 10.0.60.48

ip netns exec H2 ping -c 3 10.0.10.47
ip netns exec H2 ping -c 3 10.0.10.48
ip netns exec H2 ping -c 3 10.0.20.47
ip netns exec H2 ping -c 3 10.0.20.48
ip netns exec H2 ping -c 3 10.0.30.47
ip netns exec H2 ping -c 3 10.0.30.48
ip netns exec H2 ping -c 3 10.0.40.47
ip netns exec H2 ping -c 3 10.0.40.48
ip netns exec H2 ping -c 3 10.0.50.47
ip netns exec H2 ping -c 3 10.0.50.48
ip netns exec H2 ping -c 3 10.0.60.47
ip netns exec H2 ping -c 3 10.0.60.48

ip netns exec H3 ping -c 3 10.0.10.47
ip netns exec H3 ping -c 3 10.0.10.48
ip netns exec H3 ping -c 3 10.0.20.47
ip netns exec H3 ping -c 3 10.0.20.48
ip netns exec H3 ping -c 3 10.0.30.47
ip netns exec H3 ping -c 3 10.0.30.48
ip netns exec H3 ping -c 3 10.0.40.47
ip netns exec H3 ping -c 3 10.0.40.48
ip netns exec H3 ping -c 3 10.0.50.47
ip netns exec H3 ping -c 3 10.0.50.48
ip netns exec H3 ping -c 3 10.0.60.47
ip netns exec H3 ping -c 3 10.0.60.48

ip netns exec H4 ping -c 3 10.0.10.47
ip netns exec H4 ping -c 3 10.0.10.48
ip netns exec H4 ping -c 3 10.0.20.47
ip netns exec H4 ping -c 3 10.0.20.48
ip netns exec H4 ping -c 3 10.0.30.47
ip netns exec H4 ping -c 3 10.0.30.48
ip netns exec H4 ping -c 3 10.0.40.47
ip netns exec H4 ping -c 3 10.0.40.48
ip netns exec H4 ping -c 3 10.0.50.47
ip netns exec H4 ping -c 3 10.0.50.48
ip netns exec H4 ping -c 3 10.0.60.47
ip netns exec H4 ping -c 3 10.0.60.48

#trace route from H1 to H4
ip netns exec H1 traceroute 10.0.60.48
#trace route from H3 to H4
ip netns exec H3 traceroute 10.0.60.48
#trace route from H4 to H2
ip netns exec H4 traceroute 10.0.20.47