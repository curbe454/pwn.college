### lvl 15
```
[INFO] - the challenge checks for a specific parent process : ipython
```

`printf "import pwn\np=pwn.process('/challenge/run').recvall().decode();print(p)" | ipython`

### lvl 26
```
[INFO] - the challenge checks for a specific parent process : ipython
[INFO] - the challenge will check for a hardcoded password over stdin : fnboxpki
```

Notice the `\\n`.
`printf 'import pwn\np=pwn.process("/challenge/run");p.send("fnboxpki\\n".encode())\nprint(p.recvall().decode())' | ipython`

### lvl 17
```
[INFO] - the challenge checks for a specific parent process : ipython
[INFO] - the challenge will check that argv[NUM] holds value VALUE (listed to the right as NUM:VALUE) : 1:mklyuwsdtv
```

`printf 'import pwn\np=pwn.process(["/challenge/run", "mklyuwsdtv"]);p.send("fnboxpki\\n".encode());print(p.recvall().decode())' | ipython`

### lvl 18
```
[INFO] - the challenge checks for a specific parent process : ipython
[INFO] - the challenge will check that env[KEY] holds value VALUE (listed to the right as KEY:VALUE) : zmfvyw:ywasunkgem
```

`printf 'import pwn\np=pwn.process("/challenge/run");print(p.recvall().decode())\nexit()' > tmp.py && env zmfvyw=ywasunkgem ipython <tmp.py && rm tmp.py`

### lvl 19
```
[INFO] - the challenge checks for a specific parent process : ipython
[INFO] - the challenge will check that input is redirected from a specific file path : /tmp/smfxer
[INFO] - the challenge will check for a hardcoded password over stdin : agrwruwa
```

```py
# lvl_19.py
import pwn

tmp = open('/tmp/smfxer', 'w+')
tmp.write("agrwruwa\n")
tmp.seek(0,0)

p = pwn.process('/challenge/run', stdin=tmp)
print(p.recvall().decode())

tmp.close()
```

Then `cat lvl_19.py | ipython`

### lvl 20
```
[INFO] - the challenge checks for a specific parent process : ipython
[INFO] - the challenge will check that output is redirected to a specific file path : /tmp/jbotzb
```

`printf 'import pwn\ntmp=open("/tmp/jbotzb","w+")\np=pwn.process("/challenge/run",stdout=tmp).wait()\n;tmp.seek(0,0)\nprint(tmp.read())\ntmp.close()' | ipython`

### lvl 21
```
[INFO] - the challenge checks for a specific parent process : ipython
[INFO] - the challenge will check that the environment is empty (except LC_CTYPE, which is impossible to get rid of in some cases)
```

`printf "import pwn\np=pwn.process('/challenge/run', ignore_environ=True);print(p.recvall().decode())" | ipython`

### lvl 22
```
[INFO] - the challenge checks for a specific parent process : python
```

`printf "import pwn;print(pwn.process('/challenge/run').recvall().decode())" > tmp.py && python tmp.py && rm $_`

### lvl 23
```
[INFO] - the challenge checks for a specific parent process : python
[INFO] - the challenge will check for a hardcoded password over stdin : hybnexdv
```

`printf 'import pwn;p=pwn.process("/challenge/run");p.send("hybnexdv\\n");print(p.recvall().decode())' > tmp.py && python tmp.py && rm $_`

### lvl 24
```
[INFO] - the challenge checks for a specific parent process : python
[INFO] - the challenge will check that argv[NUM] holds value VALUE (listed to the right as NUM:VALUE) : 1:plefmckxwa
```

`printf 'import pwn;p=pwn.process(["/challenge/run", "plefmckxwa"]);p.send("hybnexdv\\n");print(p.recvall().decode())' > tmp.py && python tmp.py && rm $_`
