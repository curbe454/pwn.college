### lvl 29
```
[INFO] WELCOME! This challenge makes the following asks of you:
[INFO] - the challenge checks for a specific parent process : binary
[INFO] - the challenge will output a reward file if all the tests pass : /flag

[HYPE] ONWARDS TO GREATNESS!

[INFO] This challenge will perform a bunch of checks.
[INFO] If you pass these checks, you will receive the /flag file.

[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure that the process is a custom binary that you created by compiling a C program
[TEST] that you wrote. Make sure your C program has a function called 'pwncollege' in it --- otherwise,
[TEST] it won't pass the checks.

[HINT] If this is a check for the *parent* process, keep in mind that the exec() family of system calls
[HINT] does NOT result in a parent-child relationship. The exec()ed process simply replaces the exec()ing
[HINT] process. Parent-child relationships are created when a process fork()s off a child-copy of itself,
[HINT] and the child-copy can then execve() a process that will be the new child. If we're checking for a
[HINT] parent process, that's how you make that relationship.

[INFO] The executable that we are checking is: /usr/bin/dash.

[HINT] One frequent cause of the executable unexpectedly being a shell or docker-init is that your
[HINT] parent process terminated before this check was run. This happens when your parent process launches
[HINT] the child but does not wait on it! Look into the waitpid() system call to wait on the child!
[HINT]
[HINT] Another frequent cause is the use of system() or popen() to execute the challenge. Both will actually
[HINT] execute a shell that will then execute the challenge, so the parent of the challenge will be that
[HINT] shell, rather than your program. You must use fork() and one of the exec family of functions (execve(),
[HINT] execl(), etc).
```

```c
// lvl29.c
#include <unistd.h> // defined unix syscall functions
#include <sys/wait.h> // use waitpid()

#define NO_OPTION 0

int pwncollege() {
        int pid = fork();
        int exit_status;
        if (pid == 0) {
                execve("/challenge/run", NULL, NULL);
        } else {
                int changed_cpid = waitpid(pid, &exit_status, NO_OPTION);
        }
        return 0;
}

int main() {
        pwncollege();
        return 0;
}


/*
there's type `pid_t` is defined in `sys/types.h` header.
but `pid_t` is `int`.
*/
```

### lvl 30
```log
[INFO] - the challenge checks for a specific parent process : binary
[INFO] - the challenge will check for a hardcoded password over stdin : qmyclfmk
```

Writeup 1: `printf "qmyclfmk" | ./lvl29.exe`
Writeup 2:
```c
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <string.h>

int pwncollege() {
        const char* s = "qmyclfmk";
        int ssize = strlen(s);

        int fd[2];
        pipe(fd);
        // create pipe:  [p 0] -- [0 process 1] -- [1 p]
        // fork: [p 0] -- [0 parent 1] -- [1 p 0] -- [0 child 1] -- [1 p]
        // close redundant: [parent 1] -- [1 p 0] -- [0 child]
        // redirect: [parent 1] -- [0 child]; [p]

        pid_t fpid = fork();
        if (fpid == 0) {
                close(fd[1]); // close [child 1] to 
                dup2(fd[0], 0); // redirect
                execve("/challenge/run", NULL, NULL);
        } else {
                int wtstatus;
                close(fd[0]); // close [0 parent] from [p 0]
                write(fd[1], s, ssize);
                close(fd[1]); // send EOF to fd[1]
                waitpid(-1, NULL, 0);
        }
        return 0;
}

int main() {
        pwncollege();
}
```

### lvl 31
```log
[INFO] - the challenge checks for a specific parent process : binary
[INFO] - the challenge will check that argv[NUM] holds value VALUE (listed to the right as NUM:VALUE) : 1:njgyfjlybs
```

```c
int pwncollege() {
        int fpid = fork();
        if (fpid == 0) {
                char *argv[] = {"/challenge/run", "njgyfjlybs"};
                execve(argv[0], argv, NULL);
        } else
            waitpid(-1, NULL, 0);
        return 0;
}
```

### lvl 32
```log
[INFO] - the challenge checks for a specific parent process : binary
[INFO] - the challenge will check that env[KEY] holds value VALUE (listed to the right as KEY:VALUE) : ujfafn:iabztmmpxi
```

**writeup 1**
```c
// lvl32.c
#include <unistd.h>
#include <sys/wait.h>

int pwncollege(char *argv[], char *envp[]) {
        int fpid=fork();
        if (fpid==0) {
                execve("/challenge/run", argv, envp);
        } else {
                waitpid(-1, NULL, 0);
        }
        return 0;
}
int main(int argc, char *argv[], char *envp[]) {
        pwncollege(argv, envp);
}
```

Then `gcc lvl32.c -o lvl32.exe && ujfafn=iabztmmpxi ./lvl32.exe`.

I tried this 
```c
int main() {
        char *env[] = {"ujfafn=iabztmmpxi\n"};
        pwncollege(argv, env);
}
```
But it can't work. This might because of lack of some environment variables.

**writeup 2**
Finally I found more useful info.
The `envp` arg of `main()` in C language is not defined in POSIX or ISO.

Instead, use `extern char **environ;` to import the environment variables.

And there're according `setenv()`, `unsetenv()`, `putenv()` which in `stdlib.h`.
```c
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

extern char **environ;

int pwncollege() {
        int fpid=fork();
        if (fpid==0) {
                execve("/challenge/run", NULL, environ);
        } else {
                waitpid(-1, NULL, 0);
        }
        return 0;
}

int main() {
        setenv("ujfafn", "iabztmmpxi", 1);
        pwncollege();
}

```

### lvl 33
```log
[INFO] - the challenge checks for a specific parent process : binary
[INFO] - the challenge will check that input is redirected from a specific file path : /tmp/ukdwqy
[INFO] - the challenge will check for a hardcoded password over stdin : ljxjvcyy
```

```c
#include <fcntl.h> // open
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

int pwncollege() {
        int fdin = open("/tmp/ukdwqy", O_CREAT|O_WRONLY);
        char buf[100] = "ljxjvcyy";
        write(fdin, buf, strlen(buf));
        close(fdin);

        int cpid = fork();
        if (cpid == 0) {
                int fdin = open("/tmp/ukdwqy", O_RDONLY);
                dup2(fdin, 0); // redirect
                close(fdin);

                execve("/challenge/run", NULL, NULL);

        } else {
                waitpid(-1, NULL, 0);
        }

        return 0;
}

int main() {
        pwncollege();
}
```
