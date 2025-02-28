# lvl 1
`printf "r\nc\nq\n" | /challenge/embryogdb_level1`

# lvl 2
In order to solve this level, you must figure out the current random value of register r12 in hex.

Use `p/x $r12`.

# lvl 3

### challenge
In order to solve this level, you must figure out the random value on the stack (the value read in from /dev/urandom). Think about what the arguments to the read system call are.

### analyse
If we input the `r`, `c`, `c` commands in order, there's prompt to input the value of request.
After the first `c`, it tells me the random number is set.

So just compare the value before with after in the stack.

### writeup 1
I tried two times of `x/10gx $rsp` before and after the value is set.
I see the 64-bit value at `rsp + 0x28` changed.

In my case, it's `0xcfccf659e8a3608f`. I input it and the result is
```txt
You input: 0xcfccf659e8a3608f
The correct answer is: cfccf659e8a3608f
```

So next time I get the flag.

### writeup 2
The writeup 1 is just a coincidence.

Input `disas main` and I saw a lot of complex code.
I read for a while, there's:
```s
Dump of assembler code for function main:
   0x0000000000001aa6 <+0>:     endbr64
   0x0000000000001aaa <+4>:     push   rbp
   0x0000000000001aab <+5>:     mov    rbp,rsp
   0x0000000000001aae <+8>:     sub    rsp,0x40
```
at the front to allocate space for stack. And the `rbp` and `rsp` never appear before I see the first `int3`. (Now I know why I can get the answer in writeup 1. Because the stack have only 0x40 space to space value, `x/8gx $rsp` can see all the values.)

And there're two `int3`, I know it's where to input `continue`.
So the codes between the two `int3` is to read the random values. Here it is:
```s
   0x0000000000001c1e <+376>:   int3
   0x0000000000001c1f <+377>:   nop
   0x0000000000001c20 <+378>:   mov    DWORD PTR [rbp-0x1c],0x0
   0x0000000000001c27 <+385>:   jmp    0x1cd9 <main+563>
   0x0000000000001c2c <+390>:   mov    esi,0x0
   0x0000000000001c31 <+395>:   lea    rdi,[rip+0xbd5]        # 0x280d
   0x0000000000001c38 <+402>:   mov    eax,0x0
   0x0000000000001c3d <+407>:   call   0x1250 <open@plt>
   0x0000000000001c42 <+412>:   mov    ecx,eax
   0x0000000000001c44 <+414>:   lea    rax,[rbp-0x18]
   0x0000000000001c48 <+418>:   mov    edx,0x8
   0x0000000000001c4d <+423>:   mov    rsi,rax
   0x0000000000001c50 <+426>:   mov    edi,ecx
   0x0000000000001c52 <+428>:   call   0x1210 <read@plt>
   0x0000000000001c57 <+433>:   lea    rdi,[rip+0xbc2]        # 0x2820
   0x0000000000001c5e <+440>:   call   0x1190 <puts@plt>
   0x0000000000001c63 <+445>:   int3
```
I go to see `<main+563>` and find `<+378>:   mov` and `<+385>:   jmp` are junk.

`<+407>` called C-language function `open(0x280d, 0x0)`.
The declaration of the function is `int open(char* pathname, int mode)` so 0x280d is where store a string("/dev/urandom"),
0x0 is the mode to open the file, which is O_RONLY(read only).
The return value of it is a file description code.

And `<+428>` called C-language function `read(edi, rbp - 0x18, 0x8`.
Declaration is `ssize_t read(int file_description, void* buf, size_t byte_count)`.
The value of `edi` is the file description.
So this will read 8 bytes from "/dev/urandom" and store it to address `rbp - 0x18`, or `rsp + 0x28`, the same as the result in writeup 1.
