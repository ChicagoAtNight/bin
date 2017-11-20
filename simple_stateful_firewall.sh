#!/bin/bash

# Simple Stateful Firewall from https://wiki.archlinux.org/index.php/Simple_Stateful_Firewall

OS_BANNER=`uname -a`

# create two user-defined chains that we will use to open up ports in the firewall.
iptables -N TCP
iptables -N UDP

# set the policy of the FORWARD chain to DROP
iptables -P FORWARD DROP

# We have no intention of filtering any outgoing traffic, as this would make the setup much more complicated and would require some extra thought. In this simple case, we set the OUTPUT policy to ACCEPT.
iptables -P OUTPUT ACCEPT

# First, we set the default policy for the INPUT chain to DROP in case something somehow slips by our rules. Dropping all traffic and specifying what is allowed is the best way to make a secure firewall.
iptables -P INPUT DROP

# Every packet that is received by any network interface will pass the INPUT chain first, if it is destined for this machine. In this chain, we make sure that only the packets that we want are accepted.
#The first rule will allow traffic that belongs to established connections, or new valid traffic that is related to these connections such as ICMP errors, or echo replies (the packets a host returns when pinged). ICMP stands for Internet Control Message Protocol. Some ICMP messages are very important and help to manage congestion and MTU, and are accepted by this rule.
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# You can add more trusted interfaces here such as "eth1" if you do not want/need the traffic filtered by the firewall, but be warned that if you have a NAT setup that redirects any kind of traffic to this interface from anywhere else in the network (let's say a router), it'll get through, regardless of any other settings you may have.
iptables -A INPUT -i lo -j ACCEPT

# This rule will drop all packets with invalid headers or checksums, invalid TCP flags, invalid ICMP messages (such as a port unreachable when we did not send anything to the host), and out of sequence packets which can be caused by sequence prediction or other similar attacks. The "DROP" target will drop a packet without any response, contrary to REJECT which politely refuses the packet. We use DROP because there is no proper "REJECT" response to packets that are INVALID, and we do not want to acknowledge that we received these packets.
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# The next rule will accept all new incoming ICMP echo requests, also known as pings. Only the first packet will count as NEW, the rest will be handled by the RELATED,ESTABLISHED rule. Since the computer is not a router, no other ICMP traffic with state NEW needs to be allowed.
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT

# Now we attach the TCP and UDP chains to the INPUT chain to handle all new incoming connections. Once a connection is accepted by either TCP or UDP chain, it is handled by the RELATED/ESTABLISHED traffic rule. The TCP and UDP chains will either accept new incoming connections, or politely reject them. New TCP connections must be started with SYN packets.
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

# We reject TCP connections with TCP RST packets and UDP streams with ICMP port unreachable messages if the ports are not opened. This imitates default Linux behavior (RFC compliant), and it allows the sender to quickly close the connection and clean up.
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-rst

# For other protocols, we add a final rule to the INPUT chain to reject all remaining incoming traffic with icmp protocol unreachable messages. This imitates Linux's default behavior.
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

# Allow ssh sessions to workstation
iptables -A TCP -p tcp -m tcp --dport 22 -j ACCEPT


if [[ "$OS_BANNER" =~ "Ubuntu" ]]; then
    iptables-save > /etc/iptables.rules
fi
