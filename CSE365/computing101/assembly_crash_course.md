## Before writeup

### makefile
I wrote makefile for convenience in this module.
```makefile
newest:
	new_asm=$$(ls -tr *.s | tail -n 1); \
		gcc -nostdlib $$new_asm -o exe
# new_asm=$$(ls -tr *.s | tail -n 1); \
# 	as $$new_asm -o $${new_asm/.s/.o} && \
# 	ld $$_ -o $${new_asm/.s/.exe}

n: newest

cleanobj:
	-rm *.o

clean: cleanobj
	-rm *.exe
```

### short input
```short_admit.sh
#!/usr/bin/bash
# usage: input assembly code in format string.
tmp_file="tmp.s"
out_file=exe

head=".intel_syntax noprefix\n.global _start\n_start:\n"
code="$1"
asm="$head$code"
printf "$asm" > $tmp_file

gcc -nostdlib $tmp_file -o $out_file
/challenge/run $out_file
```
`chmod 711 short_admit.sh`

# set-register
```s
.intel_syntax
.global _start
_start:
mov %rdi, 0x1337
mov %rax, 60
syscall
```

# set-multiple-registers
```s
.intel_syntax noprefix
.global _start
_start:
mov rax, 0x1337
mov r12, 0xCAFED00D1337BEEF
mov rsp, 0x31337
```
And we didn't exit...

# add-to-register
`./short_admit.sh "add rdi, 0x331337\n"`

# linear-equation-registers
`./short_admit.sh "imul rdi, rsi\nadd rdi, rdx\nmov rax, rdi\n"`

# integer-division
`./short_admit.sh "mov rdx, 0\nmov rax, rdi\ndiv rsi\n"`

# modulo-operation
`./short_admit.sh "mov rdx, 0\nmov rax, rdi\ndiv rsi\nmov rax, rdx"`

# set-upper-byte
`./short_admit.sh "mov ah, 0x42"`

# efficient-modulo
I'm reading the book CSAPP, which mentioned about this. But this(challenge) is simpler than that.
Since $2^8 = 256$, keep the lower 8 bits; $2^16 = 65536$, keep the lower 16 bits.

# byte-extraction
`./short_admit.sh "mov rax, 0\nshr rdi, 32\nmov al, dil\n"`

# bitwise-and
`./short_admit.sh "and rax, 0\nand rdi, rsi\nxor rax, rdi\n"`

Below will be a little difficult for who haven't learnt bool algebra.

# check-even
`./short_admit.sh "and rax, 0\nand rdi, 1\nxor rax, rdi\nxor rax, 1\n"`

# memory-read
`./short_admit.sh "mov rax, [0x404000]\n"`

# memory-write
`./short_admit.sh "mov [0x404000], rax\n"`

# memory-increment
`./short_admit.sh "mov rax, [0x404000]\nmov rdi, rax\nadd rdi, 0x1337\nmov [0x404000], rdi\n"`

# byte-access
`./short_admit.sh "mov rax, 0\nmov al, [0x404000]\n"`

# memory-size-access
```s
.intel_syntax noprefix
.global _start
_start:
mov rdi, [0x404000]
mov rax, 0
mov rbx, 0
mov rcx, 0
mov rdx, 0
mov al, dil
mov bx, di
mov ecx, edi
mov rdx, rdi
```

# little-endian-write
`[ADDRESS + BYTESHIFT]` is to take the value in the shifted address.
### writeup1

```s
.intel_syntax noprefix
.global _start
_start:
mov qword ptr [rdi], 0
mov byte ptr [rdi+0], 0x37
mov byte ptr [rdi+1], 0x13
mov byte ptr [rdi+2], 0x00
mov byte ptr [rdi+3], 0x00
mov byte ptr [rdi+4], 0xef
mov byte ptr [rdi+5], 0xbe
mov byte ptr [rdi+6], 0xad
mov byte ptr [rdi+7], 0xde
mov qword ptr [rsi], 0
mov byte ptr [rsi+0], 0x00
mov byte ptr [rsi+1], 0x00
mov byte ptr [rsi+2], 0xee
mov byte ptr [rsi+3], 0xff
mov byte ptr [rsi+4], 0xc0
```
The value in the address shold be set to 0 at first. Because I get the error:
`[0x404a18] expected to be 0xc0ffee0000, instead was 0xffffffc0ffee0000`

### writeup2
```s
.intel_syntax noprefix
.global _start
_start:
mov rax, 0xdeadbeef00001337
mov rdx, 0
MOV_ONE:
mov byte ptr [rdi+rdx], al
add rdx, 1
shr rax, 8
test rax, rax
jnz MOV_ONE

mov rax, 0xc0ffee0000
mov rdx, 0
mov qword ptr [rsi], 0
MOV_TWO:
mov byte ptr [rsi+rdx], al
add rdx, 1
shr rax, 8
test rax, rax
jnz MOV_TWO
```

# memory-sum
```s
.intel_syntax noprefix
.global _start
_start:
mov rdx, [rdi]
add rdx, [rdi + 8]
mov [rsi], rdx
```

# stack-substraction
`./short_admit.sh "pop rax\nsub rax, rdi\npush rax\n"`

# swap-stack-values
`./short_admit.sh "push rdi\npush rsi\npop rdi\npop rsi\n"`

# average-stack-values
```s
.intel_syntax noprefix
.global _start
_start:
mov rax, 0
add rax, [rsp+0x00]
add rax, [rsp+0x08]
add rax, [rsp+0x10]
add rax, [rsp+0x18]
mov rdx, 0
mov rsi, 4
div rsi
push rax
```

# absolute-jump
`./short_admit.sh "mov rax, 0x403000\njmp rax\n"`
I don't know why `jmp 0x403000` is wrong...

# relative-jump
```
.intel_syntax noprefix
.global _start
_start:
jmp tag
.rept 0x51
nop
.endr

tag:
mov rax, 0x1
```

# jump-trampoline
`s
.intel_syntax noprefix
.global _start
_start:
jmp label
.rept 0x51
nop
.endr

label:
mov rdi, [rsp]
mov rdx, 0x403000
jmp 0x403000
`
# conditional-jump
```py
from pwn import *

p = process('/challenge/run')

code = asm('''
mov rax, 0
mov ebx, [rdi+4]
mov ecx, [rdi+8]
mov edx, [rdi+12]

cmp dword ptr [rdi], 0x7f454c46
je first
cmp dword ptr [rdi], 0x00005A4D
je second
jmp third

first:
add eax, ebx
add eax, ecx
add eax, edx
jmp done

second:
add eax, ebx
sub eax, ecx
sub eax, edx
jmp done

third:
mov rax, 1
imul eax, ebx
imul eax, ecx
imul eax, edx

done:
nop
''', arch='amd64', os='linux')

p.send(code)
p.interactive()
```

# indirect-jump
It seems that the `as` and `gcc -nostdlib` do not support comments...
```s
.intel_syntax noprefix
.global _start
_start:
cmp rdi, 3
jle not_default
mov rdi, 4 ;change the value from over 4

not_default:
imul rdi, 8
add rsi, rdi
jmp [rsi]
```

# average-loop
```s
.intel_syntax noprefix
.global _start
_start:
mov rax, 0
mov rcx, rsi
sub rcx, 0x1 ; start from n-1

calc_sum:
mov rdx, rcx
imul rdx, 0x8 ; mul 8 to be shift length
add rdx, rdi ; add to be address
add rax, [rdx]
loop calc_sum

add rax, [rdi] ; end from 0 shift of address

mov rdx, 0
div rsi
```

# count-non-zero
```s
.intel_syntax noprefix
.global _start
_start:
mov rax, 0
cmp rdi, 0
je done

mov rcx, 0
cnt_nz:
cmp byte ptr [rdi], 0
je done
add rdi, 1
add rcx, 1
jmp cnt_nz

done:
mov rax, rcx
```

# string-lower
Remember that functions return the value in `rax` and take arguments in `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`.
The address of string is in `rdi`, implement the following logic:
```python-like-psudo-code
str_lower(src_addr):
  i = 0
  if src_addr != 0:
    while [src_addr] != 0x00:
      if [src_addr] <= 0x5a:
        [src_addr] = foo([src_addr])
        i += 1
      src_addr += 1
  return i
```
The `src_addr` is already in `rdi`.
```s
.intel_syntax noprefix
.global _start
_start:
mov r9, 0x403000
mov rcx, 0
cmp rdi, 0x0
je done

cmp byte ptr [rdi], 0
je done
whil:
cmp byte ptr [rdi], 0x5a
jg after_if
mov rsi, rdi
mov dil, byte ptr [rdi]
call r9
mov rdi, rsi
mov byte ptr [rdi], al
add rcx, 1
after_if:
add rdi, 1
cmp byte ptr [rdi], 0
jne whil

done:
mov rax, rcx
ret
```

# most-common-byte

I will make comments for the code.
Once again, please make function(s) that implement the following:
```python-like-psudo-code
most_common_byte(src_addr, size):
  i = 0
  while i <= size-1:
    curr_byte = [src_addr + i] # get current byte from address
    [stack_base - curr_byte] += 1 # assume data in stack are all zeroes, count in range of a 0xff length list in stack.
    i += 1

  b = 0
  max_freq = 0
  max_freq_byte = 0
  while b <= 0xff: # iterate the whole stack list to find the bype having max frequency.
    if [stack_base - b] > max_freq:
      max_freq = [stack_base - b]
      max_freq_byte = b
    b += 1

  return max_freq_byte
```

### writeup
1. Notice to init the stack memory to 0.
1. Notice that although the stack is from bottom to top, the array's order is from top to bottom.
```s
.intel_syntax noprefix
.global _start, most_common_byte
_start:
call most_common_byte
ret

most_common_byte:
  allocate:
    mov rbp, rsp
    sub rsp, 0x100
  
  init_allocated:
    mov rcx, 0x100

    set_zero:
      mov r8, rbp
      sub r8, rcx
      mov byte ptr [r8], 0
    loop set_zero

  cnt_bytes:
    mov rcx, 0
    mov rbx, 0
    sub rsi, 1

    cmp rcx, rsi
    jg calc_max

    cnt:
      mov bl, byte ptr [rdi + rcx]
      mov r8, rbp
      sub r8, 0x100
      add r8, rbx
      add byte ptr [r8], 1
      add rcx, 1
    
      cmp rcx, rsi
      jle cnt

  calc_max:
    mov rbx, 0
    mov rcx, 0
    mov rax, 0

    iterate:
      cmp rbx, 0xff
      jg done

      mov r8, rbp
      sub r8, 0x100
      add r8, rbx
      cmp byte ptr [r8], cl
      jle continue

      change_max:
        mov rcx, qword ptr [r8]
        mov al, bl

      continue:
      add rbx, 1
      cmp rbx, 0xff
      jle iterate

  done:
  mov rsp, rbp
  ret
```

