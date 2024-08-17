#!/usr/bin/env bash

set -xu

# egress traffic shaping
tc qdisc add dev eth0 root handle 1: htb default 99
tc class add dev eth0 parent 1: classid 1:1 htb rate 5mbit  # general restriction

tc class add dev eth0 parent 1:1 classid 1:10 htb rate 1mbit ceil 5mbit prio 1  # HA-agent
tc class add dev eth0 parent 1:1 classid 1:20 htb rate 4mbit ceil 5mbit prio 2  # redis
tc class add dev eth0 parent 1:1 classid 1:30 htb rate 1mbit ceil 5mbit prio 3  # backup
tc class add dev eth0 parent 1:1 classid 1:99 htb rate 512kbit ceil 5mbit prio 99 # etc

# Match HA-agent traffic
tc filter add dev eth0 protocol ip parent 1: prio 1 u32 \
    match ip dport 16123 0xffff \
    flowid 1:10
tc filter add dev eth0 protocol ip parent 1: prio 1 u32 \
    match ip sport 16123 0xffff \
    flowid 1:10

tc filter add dev eth0 protocol ip parent 1: prio 1 u32 \
    match ip dport 16099 0xffff \
    flowid 1:10
tc filter add dev eth0 protocol ip parent 1: prio 1 u32 \
    match ip sport 16099 0xffff \
    flowid 1:10

# Match redis traffic
tc filter add dev eth0 protocol ip parent 1: prio 2 u32 \
    match ip sport 6379 0xffff \
    flowid 1:20


# Match backup traffic
tc filter add dev eth0 protocol ip parent 1: prio 3 u32 \
    match ip dport 80 0xffff \
    flowid 1:30

# ingress traffic shaping
tc qdisc add dev eth0 handle ffff: ingress

# Match and rate redis traffic
tc filter add dev eth0 protocol ip parent ffff: prio 1 u32 \
    match ip dport 6379 0xffff \
    police rate 10mbit burst 1024k mtu 64kb drop
