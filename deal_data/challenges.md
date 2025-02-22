# What's the password?
use `cat` to look the code in `/challenge/runme` and get the right string "hctvgren"
```sh
printf "hctvgren" | /challenge/runme
```

# ... and again!
the same as above.


# Newline Troubles
It gave so many write up of the problem. This is the simplest: `printf "gszudhjc" | /challenge/runme`.


# Reasoning about files
```sh
printf "bvwmigzr" > byyf && /challenge/runme
```

# Specifying Filenames
I was surprised it worked out: `/challenge/runme <(printf "lakumkny")`

`<(COMMAND)` this will regard the out put of the COMMAND sentense to be a file.

# Bineary and Hex Encoding
It's known that for any valid string in python, `s == s.encode().decode()`.
So just reverse the steps of the code.
Since the correct answer is `b"\xc4"`,
```sh
python -c 'print((b"\xc4".hex().encode("l1")).decode())' | /challenge/runme
```
Notice the extra `.decode()` because the object transforming. Or just get the encoded string and print them manually.


# More Hex
Since the correct_password is `b"\xf6\xc1\xdc\xed\xb5\xd8\xa8\xda"`,
```sh
python -c 'print(b"\xf6\xc1\xdc\xed\xb5\xd8\xa8\xda".hex().encode("l1").decode())' | /challenge/runme
```

# Decoding Hex
### This is a crazy write up:
```sh
printf $(python -c 'h = b"addcd9e58dfada80".decode("l1"); print(bytes.fromhex(h))' \
| awk "{gsub(/b'/, \"\", \$0); gsub(/'/,\"\"); print}") \
| /challenge/runme
```
This is the combine of the two steps:
### echo solution
```sh
$ python -c 'h = b"addcd9e58dfada80".decode("l1"); print(bytes.fromhex(h)
b'\xad\xdc\xd9\xe5\x8d\xfa\xda\x80'
echo -n -e "\xad\xdc\xd9\xe5\x8d\xfa\xda\x80" | /challenge/runme
...(answer here)
```
And I know that `printf` command equals to `echo -n -e`.
I search to know that they're not equal because `echo -ne` is not so reliable in different shell/OS.

I also tried other ways:
### python solution
```python decoding_hex.py
import sys
h = b"addcd9e58dfada80".decode("l1")
out = bytes.fromhex(h)

sys.stdout.buffer.write(out)
```
And then `python decoding_hex.py | /challenge/runme`
### pwn moudle solution
```python
import pwn
h = b"addcd9e58dfada80".decode("l1")
out = bytes.fromhex(h)
p = pwn.process("/challenge/runme")
p.write(out)
print(p.readall().decode())
```

# Decoding Practice
Easy. And I practice to use pwn module.
```python
import pwn

def decode_from_bits(s):
    s = s.decode("latin1")
    assert set(s) <= {"0", "1"}, "non-binary characters found in bitstream!"
    assert len(s) % 8 == 0, "must enter data in complete bytes (each byte is 8 bits)"
    return int.to_bytes(int(s, 2), length=len(s) // 8, byteorder="big")

correct_password = b"1001000010101111111001001000110010100100111110111110010010001011"
correct_password = decode_from_bits(correct_password)

p = pwn.process("/challenge/runme")
p.write(correct_password)
print(p.readall().decode())
```

# Encoding Practice
```python
def encode_to_byte(x):
    bits_str = bin(int(x.hex(), 16))
    return bits_str[2:].encode("latin1")
```
Notice that `bin(0)` in python is `'0b0'`.

# Hex-encoding ASCII
```python
fname = 'ryfi'
with open(fname, 'wb') as fp:
    correct_password = b"oimewpfp"
    fp.write(correct_password.hex().encode("l1"))
```

# Nested Encoding
Just played some trick:
```python nested_encoding.py
def counter(b):
    return b.hex().encode("l1")

def iterate(func, times):
    def wrapper(x):
        res = func(x)
        for i in range(times - 1):
            res = func(res)
        return res
    return wrapper

correct_password = b"ytgdziwx"
print(iterate(counter, 4)(correct_password).decode())
```
```sh
/challenge/runme <(python nested_encoding.py)
```

# Hex-encoding UTF-8
```sh
python -c 'ans = "📌 👔 😐 🔖".encode().hex().encode("l1"); print(ans.decode())' | /challenge/runme
```

# UTF Mixups
Tried some fancy ways:
```python utf_mixups.py
import pwn
from temp_file import temp_file

correct_password = b"amoozuff".decode('l1').encode('utf-16')

ftmp = 'tmp'
temp_file(ftmp, 'wb', correct_password)(
    lambda p: print(p.readall().decode())
)(pwn.process(['/challenge/runme', ftmp]))
```
```python temp_file.py
def temp_file(fname, mode, content):
    def curry_func(func):
        def wrapper(*args, **kwargs):
            from os import remove
            with open(fname, mode) as fp:
                fp.write(content)
            res = func(*args, **kwargs)
            remove(fname)
            return res
        return wrapper
    return curry_func
```
`python utf_misups.py`

# Modifying Encoded Data
```python
import pwn

correct_password = b"\x87\xb7\x1b\xc3\n\x81d\x89".hex().encode('l1')[::-1]

p = pwn.process('/challenge/runme')
p.write(correct_password)
print(p.readall().decode())
```

# Decoding Base64
```python
import pwn
import base64
p = pwn.process('/challenge/runme')

correct_password = b"IRX+2Lj6XUo="
correct_password = base64.b64decode(correct_password.decode("l1"))
p.write(correct_password)

print(p.readall().decode())
```

# Encoding base64
```python
import pwn, base64

correct_password = b"\xf0\x06\xb4\x18\x17'i\xdd"
correct_password = base64.b64encode(correct_password).decode().encode('l1')

p = pwn.process('/challenge/runme')
p.write(correct_password)
print(p.readall().decode())
```
Notice that `base64.b64encode` returns a bytes object, while `base64.b64decode()` need a string object.
So there's a extra step to decode it to a string.

# Dealing with Obfusecation
But I can copy the codes in the question...

# Dealing with Obfusecation 2
Just result counter procedure.
It's known that
```log
bytes.fromhex(x) <=> y.hex()
x.decode() <=> y.encode()
x[::-1] <=> y[::-1]

bytes.fromhex(x.decode()) <=> y.hex().encode()
base64.b64decode(x.decode()) <=> base64.b64encode(y).decode().encode()
```
And the procedure of the code can be speak to that `entered_password -> a', correct_password -> b', a' == b'`.

So to get the correct password, b' is necessary, and do the counter procedure of the `entered_password -> a`.

```python
import pwn,base64

def get_password(correct_password):
    correct_password = correct_password[::-1]
    correct_password = correct_password[::-1]
    correct_password = correct_password[::-1]
    correct_password = correct_password.hex().encode("l1")

    correct_password = correct_password.hex().encode("l1")
    correct_password = correct_password[::-1]
    correct_password = base64.b64encode(correct_password).decode().encode("l1")
    correct_password = correct_password.hex().encode("l1")
    return correct_password

p = pwn.process("/challenge/runme")
p.write(get_password(b"T\x13\xd2\x9c>\x86\x9f1"))
print(p.readall().decode())
```
