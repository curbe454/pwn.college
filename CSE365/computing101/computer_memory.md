# Loading From Memory
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [133700]
mov rax, 60
syscall
```
Then check by `/challenge/check loading_from_memory.s`.
It's also OK to send a executable file to `/challenge/check`.


# More Loading Practice
The same as the above challenge.

# Dereferencing Pointers
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [rax]
mov rax, 60
syscall
```

# Dereferncing Yourself
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [rdi]
mov rax, 60
syscall
```

# Dereferencing with Offsets
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [rdi+8]
mov rax, 60
syscall
```

# Stored Address
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [567800]
mov rdi, [rdi]
mov rax, 60
syscall
```

# Double Dereference
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [rax]
mov rdi, [rdi]
mov rax, 60
syscall
```

# Triple Dereference
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [rdi]
mov rdi, [rdi]
mov rdi, [rdi]
mov rax, 60
syscall
```
