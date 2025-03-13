# Hex
```py
import pwn
p = pwn.process('/challenge/run')

def get_num_from_line(p):
    line = p.recvline().decode()
    print(line, end='')
    if '0x' in line:
        num = int(line[line.index('0x'):], 16)
        return num
    return None

nums = []
while True:
    try:
        a = get_num_from_line(p)
        if a:
            nums.append(a)
        if len(nums) == 2:
            p.write(f'{hex(nums[0]^nums[1])}\n'.encode())
            print(p.recvline().decode(),end='')
            nums = []
    except EOFError:
        break

print(p.recvall().decode())
```

# ASCII
> The challenge will give you one letter a time, along with a key to "decrypt" (XOR) the letter with. You give us the result of the XOR.

```log
You must interact with me directly. No scripting this!
```
So I can only calc this myself.

# ASCII Strings
```log
Challenge number 1...
- Encrypted String: dbcfOhlodJ
- XOR Key String: ((((!$#%&$
- Decrypted String? Correct! Moving on.
Challenge number 2...
```
```py
import pwn
from Crypto.Util.strxor import strxor
p = pwn.process('/challenge/run')

str_key = []
while True:
    try:
        line = p.recvline().decode()
        print(line,end='')
        if 'Encrypted' in line:
            s = line.split(':')[1].strip()
            str_key.append(s)
        if 'XOR Key' in line:
            s = line.split(':')[1].strip()
            str_key.append(s)
            #print(p.recvline().decode(),end='')
            str_key = [ s.encode('ascii') for s in str_key ]
            b_msg = strxor(str_key[0], str_key[1]) + b'\n'
            p.write(b_msg)
            str_key = []

            print(p.recvline().decode(),end='')
            print(b_msg.decode('ascii'),end='')
    except EOFError:
        break

print(p.recvall().decode())
```

