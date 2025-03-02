# lvl 1
`printf "r\nc\nq\n" | /challenge/embryogdb_level1`

# lvl 2
> In order to solve this level, you must figure out the current random value of register r12 in hex.

Use `p/x $r12`.

# lvl 3

> In order to solve this level, you must figure out the random value on the stack (the value read in from /dev/urandom). Think about what the arguments to the read system call are.

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
> In order to solve this level, you must figure out a series of random values which will be placed on the stack. As before, run will start you out, but it will interrupt the program and you must, carefully, continue its execution.

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
To skip the scanf function, I set the `rip` to the next instruction.
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

(If you want more detials, I tell it at writeup 2 in level 6).

# lvl 6
> You can modify the state of your target program with the set command.  
> In the previous level, your gdb scripting solution likely still required you to copy and paste your solutions. This time, try to write a script that doesn't require you to ever talk to the program, and instead automatically solves each challenge by correctly modifying registers / memory.

So I've did what it required at level 5. And I can't come up with other good solutions better than write a python script with pwntools, so I reused the code at writeup 1 in level 5.

### writeup 1
```gdb level6.gdb
r
b *(main+625)
commands
	set $rip = *(main+630)
	set *(long long*)($rbp-0x10) = *(long long*)($rbp-0x18)
	c
end
c
q
```

### writeup 2
The cheating way in level 5 is still effective. This time I'll give a detailed description.

Here's the disasm code, they are the final lines of the main function:
```s
   0x0000000000001d4c <+678>:   mov    rdx,QWORD PTR [rbp-0x10]
   0x0000000000001d50 <+682>:   mov    rax,QWORD PTR [rbp-0x18]
   0x0000000000001d54 <+686>:   cmp    rdx,rax
   0x0000000000001d57 <+689>:   je     0x1d63 <main+701>
   0x0000000000001d59 <+691>:   mov    edi,0x1
   0x0000000000001d5e <+696>:   call   0x1280 <exit@plt>
   0x0000000000001d63 <+701>:   add    DWORD PTR [rbp-0x1c],0x1
   0x0000000000001d67 <+705>:   cmp    DWORD PTR [rbp-0x1c],0x3f
   0x0000000000001d6b <+709>:   jle    0x1cbc <main+534>
   0x0000000000001d71 <+715>:   mov    eax,0x0
   0x0000000000001d76 <+720>:   call   0x197d <win>
   0x0000000000001d7b <+725>:   mov    eax,0x0
   0x0000000000001d80 <+730>:   mov    rcx,QWORD PTR [rbp-0x8]
   0x0000000000001d84 <+734>:   xor    rcx,QWORD PTR fs:0x28
   0x0000000000001d8d <+743>:   je     0x1d94 <main+750>
   0x0000000000001d8f <+745>:   call   0x11c0 <__stack_chk_fail@plt>
   0x0000000000001d94 <+750>:   leave
   0x0000000000001d95 <+751>:   ret
```
We know if the `DWORD PTR [rbp-0x1c]` is more than `0x3f`, it will give the flag.
So I set a breakpoint here: `b *(main+705)`, and run it till it hit the breakpoint.
Then I change the value in `[rbp-0x1c]` by `set *(char*)($rbp-0x1c) = 0x40`.
Finally, run it.

### writeup 3
Now I know I was detouring to just the the count value(`DWORD PTR [rbp-0x1c]`) to it's demand.

I can directly set the `rip` to the instruction where can give me flag.
```s
   0x0000000000001d76 <+720>:   call   0x197d <win>
```
So I should just `run` it and `set $rip = *(main+720)`, then `continue`.

# level 7
### description
> This level will expose you to some of the true power of gdb.

(before start the challenge)maybe I can predict it... I know what's the next.

### analysis
Now I'm reading the disassembled code. Shorter lines.
It allocate `0x30` bytes of space...(Skimmed the called function in whole `main`)
It seems just print something in the `main` function.
Let me run it.

```what popped up
###
### Welcome to /challenge/embryogdb_level7!
###

GDB is a very powerful dynamic analysis tool which you can use in order to understand the state of a program throughout
its execution. You will become familiar with some of gdb's capabilities in this module.

As we demonstrated in the previous level, gdb has FULL control over the target process. Under normal circumstances, gdb
running as your regular user cannot attach to a privileged process. This is why gdb isn't a massive security issue which
would allow you to just immediately solve all the levels. Nevertheless, gdb is still an extremely powerful tool.

Running within this elevated instance of gdb gives you elevated control over the entire system. To clearly demonstrate
this, see what happens when you run the command `call (void)win()`. As it turns out, all of the levels in this module
can be solved in this way.

GDB is very powerful!
```

It's not a surprise but I did't predict right.

### writeup
`printf "r\ncall (void)win()\nc\nq\n" | /challenge/embryogdb_level7`

# level 8

> The previous level showed you raw, but unrefined power. This level will force you to refine it, as the win function will no longer work. break at it, look around, and understand what is wrong.

### analysis
We know only the `win` function can give the flag.
When I call it, it raised an error.
```error log
Program received signal SIGSEGV, Segmentation fault.
0x000062f1b24a7969 in win ()
The program being debugged was signaled while in a function called from GDB.
GDB remains in the frame where the signal was received.
To change this behavior use "set unwindonsignal on".
Evaluation of the expression containing the function
(win) will be abandoned.
When the function is done executing, GDB will silently stop.
```
I don't know what happens, but I know I can see why the error raises, by `disas win`!.
```
(gdb) disas win
Dump of assembler code for function win:
   0x0000000000001951 <+0>:     endbr64
   0x0000000000001955 <+4>:     push   rbp
   0x0000000000001956 <+5>:     mov    rbp,rsp
   0x0000000000001959 <+8>:     sub    rsp,0x10
   0x000000000000195d <+12>:    mov    QWORD PTR [rbp-0x8],0x0
   0x0000000000001965 <+20>:    mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000001969 <+24>:    mov    eax,DWORD PTR [rax]
   0x000000000000196b <+26>:    lea    edx,[rax+0x1]
   0x000000000000196e <+29>:    mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000001972 <+33>:    mov    DWORD PTR [rax],edx
   0x0000000000001974 <+35>:    lea    rdi,[rip+0x73e]        # 0x20b9
   0x000000000000197b <+42>:    call   0x1180 <puts@plt>
   0x0000000000001980 <+47>:    mov    esi,0x0
   0x0000000000001985 <+52>:    lea    rdi,[rip+0x749]        # 0x20d5
   0x000000000000198c <+59>:    mov    eax,0x0
   0x0000000000001991 <+64>:    call   0x1240 <open@plt>
   0x0000000000001996 <+69>:    mov    DWORD PTR [rip+0x26a4],eax        # 0x4040 <flag_fd.5712>
   0x000000000000199c <+75>:    mov    eax,DWORD PTR [rip+0x269e]        # 0x4040 <flag_fd.5712>
   0x00000000000019a2 <+81>:    test   eax,eax
   0x00000000000019a4 <+83>:    jns    0x19ef <win+158>
   0x00000000000019a6 <+85>:    call   0x1170 <__errno_location@plt>
   0x00000000000019ab <+90>:    mov    eax,DWORD PTR [rax]
   0x00000000000019ad <+92>:    mov    edi,eax
   0x00000000000019af <+94>:    call   0x1270 <strerror@plt>
   0x00000000000019b4 <+99>:    mov    rsi,rax
   0x00000000000019b7 <+102>:   lea    rdi,[rip+0x722]        # 0x20e0
   0x00000000000019be <+109>:   mov    eax,0x0
   0x00000000000019c3 <+114>:   call   0x11c0 <printf@plt>
   0x00000000000019c8 <+119>:   call   0x11f0 <geteuid@plt>
   0x00000000000019cd <+124>:   test   eax,eax
   0x00000000000019cf <+126>:   je     0x1a66 <win+277>
   0x00000000000019d5 <+132>:   lea    rdi,[rip+0x734]        # 0x2110
   0x00000000000019dc <+139>:   call   0x1180 <puts@plt>
   0x00000000000019e1 <+144>:   lea    rdi,[rip+0x750]        # 0x2138
   0x00000000000019e8 <+151>:   call   0x1180 <puts@plt>
--Type <RET> for more, q to quit, c to continue without paging--c
   0x00000000000019ed <+156>:   jmp    0x1a66 <win+277>
   0x00000000000019ef <+158>:   mov    eax,DWORD PTR [rip+0x264b]        # 0x4040 <flag_fd.5712>
   0x00000000000019f5 <+164>:   mov    edx,0x100
   0x00000000000019fa <+169>:   lea    rsi,[rip+0x265f]        # 0x4060 <flag.5711>
   0x0000000000001a01 <+176>:   mov    edi,eax
   0x0000000000001a03 <+178>:   call   0x1200 <read@plt>
   0x0000000000001a08 <+183>:   mov    DWORD PTR [rip+0x2752],eax        # 0x4160 <flag_length.5713>
   0x0000000000001a0e <+189>:   mov    eax,DWORD PTR [rip+0x274c]        # 0x4160 <flag_length.5713>
   0x0000000000001a14 <+195>:   test   eax,eax
   0x0000000000001a16 <+197>:   jg     0x1a3c <win+235>
   0x0000000000001a18 <+199>:   call   0x1170 <__errno_location@plt>
   0x0000000000001a1d <+204>:   mov    eax,DWORD PTR [rax]
   0x0000000000001a1f <+206>:   mov    edi,eax
   0x0000000000001a21 <+208>:   call   0x1270 <strerror@plt>
   0x0000000000001a26 <+213>:   mov    rsi,rax
   0x0000000000001a29 <+216>:   lea    rdi,[rip+0x760]        # 0x2190
   0x0000000000001a30 <+223>:   mov    eax,0x0
   0x0000000000001a35 <+228>:   call   0x11c0 <printf@plt>
   0x0000000000001a3a <+233>:   jmp    0x1a67 <win+278>
   0x0000000000001a3c <+235>:   mov    eax,DWORD PTR [rip+0x271e]        # 0x4160 <flag_length.5713>
   0x0000000000001a42 <+241>:   cdqe
   0x0000000000001a44 <+243>:   mov    rdx,rax
   0x0000000000001a47 <+246>:   lea    rsi,[rip+0x2612]        # 0x4060 <flag.5711>
   0x0000000000001a4e <+253>:   mov    edi,0x1
   0x0000000000001a53 <+258>:   call   0x11a0 <write@plt>
   0x0000000000001a58 <+263>:   lea    rdi,[rip+0x75b]        # 0x21ba
   0x0000000000001a5f <+270>:   call   0x1180 <puts@plt>
   0x0000000000001a64 <+275>:   jmp    0x1a67 <win+278>
   0x0000000000001a66 <+277>:   nop
   0x0000000000001a67 <+278>:   leave
   0x0000000000001a68 <+279>:   ret
End of assembler dump.
```
There's an arrow points to the line `<win+24>`, this means where the `rip` points.
This means the error occurs after the line is executed and before the `rip` moves to the next instruction.

It's easy to explain this error. The `<+12>`, `<+20>` makes `rax` equals to `0x0`,
and then dereferenced `0x0` at `<+24>`. Dereferencing `0x0` made no sense and caused the error.

### writeup
Since the program won't use `rsp` and `rbp` after `<+42>`,
I just call the win function after I set a breakpoint by `b *win`.
After it hit the breakpoint, I `set $rip = *(win+47)` because I don't want the calling at `<+42>` raise a error.
I `continue` and get the flag.

### analysis 2
The way of writeup above will cause an error,
this is because I didn't allocate the stack(from `<+0>` to `<+8>`) but
the `leave` instruction tried to restore the stack.

It's okay to jump over the `leave` instruction and `continue` to complete th challenge without the error occuring.

I also tried to only jump over the instruction `<+12>` which let the value in the stack to be `0x0`.
This gave me the flag and do not cause any error.
But I don't believe what are already in the stack before the space in stack is allocated.
