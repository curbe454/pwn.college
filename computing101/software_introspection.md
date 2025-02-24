# Tracing syscalls
```bash shell
$ strace /challenge/trace-me 
execve("/challenge/trace-me", ["/challenge/trace-me"], 0x7ffdf1a3c350 /* 29 vars */) = 0
alarm(31139)                            = 0
exit(0)                                 = ?
+++ exited with 0 +++
$ /challenge/submit-number 31139
CORRECT! Here is your flag:
pwn.college{flag_here}
```



**Rests are too easy.**
