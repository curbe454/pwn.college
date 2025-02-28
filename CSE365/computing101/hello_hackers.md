# Writing Output
In Linux the write syscall is coded `as 1.
And the write function just like `write(file_stream_pointer, chars_pointer, len)`.
The file_stream_pointer of stdout is 1.
So set rdi to 1, rsi to 1337000, rdx to 1, rax to 1.
```s solution.s
.intel_syntax noprefix
.global _start
_start:
mov rdi, 1
mov rsi, 1337000
mov rdx, 1
mov rax, 1
syscall
mov rdi, 42
mov rax, 60
syscall
```
While the `/challenge/check` reminds me wrote too many lines to 8 out of 5. So we remove the last syscall(3 lines).
And the core dumped in my folder that I can't delete it!

# Chain Syscalls
See above writeup.

# Writing Strings
Write 14 characters.
```sh
cat solution.s | sed 's/rdx,\s\+1/rdx, 14/g' | /challenge/check
```

# Reading Data
The syscall code of read is 0.
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, 0
mov rsi, 1337000
mov rdx, 8
mov rax, 0
syscall
mov rdi, 1
mov rsi, 1337000
mov rdx, 8
mov rax, 1
syscall
mov rdi, 42
mov rax, 60
syscall
```
