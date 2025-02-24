# Your First Register
```s ur_1st_register.s
mov rax, 60
```
```sh
/challenge/check ur_1st_register.s
```

The `/challenge/check` will generate a `core` file in the current directory.
And we don't have permission to operate on it.
Maybe this will be useful in the folowing challenges.

# Your First Syscall
```s ur_1st_syscall.s
mov rax, 60
syscall
```
```sh
/challenge/check ur_1st_register.s
```

# Building Executables
I've learnt C language before.
The compiler gcc of GNU project will compile a C code file to an executable file by
doing preprocess, compile, assemble and link.

`file.c` $^{reprocess}$ `file.i` $^{compile}$ `file.s` $^{assemble}$ `file.o` $^{link}$ `file`(executable)
<--! It's difficult to draw sth in markdown, and I don't want use latex in markdown -->

In procedure, the assemble step use `as` and the link step use `ld`.
They're what in the description of the challenge.

### writeup
```s build_exe.s
.intel_syntax noprefix
.global _start
_start:
mov rdi, 42
mov rax, 60
syscall
```
```sh
as build_exe.s -o build_exe.o
ld build_exe.o -o built_exe
/challenge/check built_exe
```
Below are writeup.

If you know what is `$?`, maybe you also know `$_`.
```sh
as build_exe.s -o build_exe.o
ld $_ -o built_exe
/challenge/check $_
```

# Moving Between Registers
```s writeup.s
.intel_syntax noprefix
.global _start
_start:
mov rdi, rsi
mov rax, 60
syscall
```
Then `as writeup.s -o writup.o && ld $_ -o exe && /challenge/check $_`.
