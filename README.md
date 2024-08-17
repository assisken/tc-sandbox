# TC-Sanbox

A sandbox for `tc` experiments.

## Setup

```shell
docker-compose up -d
docker exec -it server bash
iperf3 -p 6379 -sD
iperf3 -p 80   -sD
```

## How to measure traffic

Run at new window:

```shell
docker exec -it client iperf3 -c server -p <port> -t 9999    # for incoming traffic
docker exec -it client iperf3 -c server -p <port> -t 9999 -R # for outgoing traffic
```

## How to use tc

Just run in server container to setup `tc`

```shell
/tc/tc.sh
```

You can also remove settings:

```shell
tc qdisc del dev eth0 root
tc qdisc del dev eth0 ingress
```
