### lvl 1
Run the `/challenge/run` program, and got the message:
```log
[FAIL] Specifically, you must fix the following issue:
[FAIL]   The shell process must be running in its default, interactive mode (/bin/bash with no commandline arguments). Your commandline arguments are: ['/run/dojo/bin/bash', '--login']
```
So just input `/bin/bash` to start a child process of `bash`, and then run `/challenge/run` again.

### lvl 2
The `/challenge/run` requests
```log
[INFO] - the challenge checks for a specific parent process : bash
[INFO] - the challenge will check for a hardcoded password over stdin : ukeoouql
```
So start `/bin/bash` and `echo ukeoouql | /challenge/run`

### lvl 3
> [INFO] - the challenge checks for a specific parent process : bash
> [INFO] - the challenge will check that argv[NUM] holds value VALUE (listed to the right as NUM:VALUE) : 1:sycckvgsxt

Exactly, when I run `bash`, the bash is already going on the default mode.
So it works that `echo /challenge/run sycckvgsxt | bash`. This will open bash ephemerally to run the process.

### lvl 4
> [INFO] - the challenge checks for a specific parent process : bash
> [INFO] - the challenge will check that env[KEY] holds value VALUE (listed to the right as KEY:VALUE) : hhfegr:qbchuogeyx

`echo env hhfegr=qbchuogeyx /challenge/run | bash`

### lvl 5
> [INFO] - the challenge checks for a specific parent process : bash
> [INFO] - the challenge will check that input is redirected from a specific file path : /tmp/lxqhch
> [INFO] - the challenge will check for a hardcoded password over stdin : pnefcavh

Notice the quote: `echo pnefcavh > /tmp/lxqhch && echo "/challenge/run </tmp/lxqhch" | bash`
