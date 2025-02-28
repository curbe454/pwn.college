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
The return value is the number of byte have been read, or `-1` for error.
The value of `edi` is the file description.
So this will read 8 bytes from "/dev/urandom" and store it to address `rbp - 0x18`, or `rsp + 0x28`,
the same as the result in writeup 1.


# lvl 4
### description
In order to solve this level, you must figure out a series of random values which will be placed on the stack. As before, run will start you out, but it will interrupt the program and you must, carefully, continue its execution.

### writeup
I skimmed the codes and think there's nothing different from challenge level 3.
I used breakpoint to stop at where I was familiar with in level 3(before the open function and after the read function),
and `display/8gx $rsp` to see the changed value in `[rsp + 0x28]`.
Until I input 4 times the correct answer, then it gave me the flag.

### assembly analyse
It's also to code a python script to accoplish it.

Before that, I should find where the loop is.

(After a few minutes) I read the code and I found the loop is related to the junk I've talked at level 3.
It's the junk part in level 3:
```s
   0x0000000000001c74 <+462>:   mov    DWORD PTR [rbp-0x1c],0x0
   0x0000000000001c7b <+469>:   jmp    0x1d2b <main+645>
   0x0000000000001d2b <+645>:   cmp    DWORD PTR [rbp-0x1c],0x0
   0x0000000000001d2f <+649>:   jle    0x1c80 <main+474>
```
(Actually this is not difinitely the same with level 3, but I don't want reopen level 3 anymore)

In level 4, the number of `<+645>` is not 0x0. It's 0x3. So I input 4 times of answer in writeup.
There's the code to change the value in `rbp-0x1c`:
```s
   0x0000000000001cc8 <+546>:   lea    rax,[rbp-0x10]
   0x0000000000001ccc <+550>:   mov    rsi,rax
   0x0000000000001ccf <+553>:   lea    rdi,[rip+0xe31]        # 0x2b07
   0x0000000000001cd6 <+560>:   mov    eax,0x0
   0x0000000000001cdb <+565>:   call   0x1260 <__isoc99_scanf@plt>
```
This is `scanf` function in C-language. This is the function recieving inputs from stdin.
I know it is `int scanf(const char* format_string, addr1, addr2, ...)`.
The number and type of addr arguments depends on the `format_string`.
The return value is the number of read variables or -1 as error.

(I'm too lazy to code the python script...)

# lvl 5
The logic of whole `main` function doesn't change, but requires 8 times to input correct answer in `[rbp-0x18]`.

Here is the logic to judge the input.
```s
   0x0000000000001dd0 <+810>:   mov    rdx,QWORD PTR [rbp-0x10]
   0x0000000000001dd4 <+814>:   mov    rax,QWORD PTR [rbp-0x18]
   0x0000000000001dd8 <+818>:   cmp    rdx,rax
   0x0000000000001ddb <+821>:   je     0x1de7 <main+833>
   0x0000000000001ddd <+823>:   mov    edi,0x1
   0x0000000000001de2 <+828>:   call   0x1280 <exit@plt>
```
If I want it get and input the answer automatically, I should get the 8-byte value in `[rbp-0x18]`
and set the value in `[rbp-0x10]` the same with `[rbp-0x18]`.

### writeup 1
To skip the scanf function, I set the rip to the next instruction.
```gdb
r
b *(main+757)
commands
        set $rip = *(main+762)
        set *(long long*)($rbp-0x10) = *(long long*)($rbp-0x18)
        c
end
c
q
```
`main+757` points to the call instruction of `scanf` function and `main+762` points to the next instruction.
Since the programs compare the value of `[rbp-0x10]` and `[rbp-0x18]`,
I set the value in `rbp-0x10` to the `[rbp-0x18]`.
The casting to `(long long*)` is to let the gdb know the value in `rbp-0x10` is a 64-bit value,
because the `long long` type in C-language have 64-bit(in the current case).

### writeup 2
Exactly I didn't take the writeup 1 method.
Since it compare the `DWORD PTR [rbp-0x1c]` to `0x7`, I can change the value of `DWORD PTR [rbp-0x1c]` to `0x8`.

Just set a breakpoint at that `cmp` instruction and `set *(char*)($rbp-0x1c) = 0x8`
(although the char type in C-language have only 8-bits, it doesn't matter).
