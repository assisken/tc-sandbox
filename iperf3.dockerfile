FROM networkstatic/iperf3

RUN apt-get update \
 && apt-get install -y iproute2 watch

CMD ["sleep", "infinity"]
