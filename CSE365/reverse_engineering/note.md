`cpp` is c pre-process.

`strip` strip redundant information of asm.

`_start()` function, which is the entry of `main()` func, provide `argc`, `argv`, `envp` args,
and evidently, they are in `rdi`, `rsi`, `rdx` registers in asm.

Read functions:
If the binary is unstripped, use `nm -C` or `readelf -s`.
If the binary is stripped, use objdump, radare2, or gdb to recover functions.
If you need interactive analysis, use gdb(`info func`) or radare2.

asm command `dec reg` decrease number in reg by one, and set flag reg. For example,

```
dec rdi
jle addr
```

to jump if `rdi <= 1`.

`struct.pack()` in python convert python obj to C structs.

`rep` instruction repeat do command after it, the times is defined by loop counter `rcx`.

`rep stos BYTE PTR es:[rdi], al` use the value of `al` to set all `rcx` bytes in the address of `rdi`.
The `es` is of no use in 64 bit mode.

`repnz scas al, BYTE PTR es:[rdi]` search `rcx` bytes in `rdi` address to find a byte equals to `al`.

`movsxd` sign expand, to let a number with fewer bits to more. E.g. `movsxd rax, eax` to expand 32 bit to 64 bit.

`movzx` zero expand, to expand unsigned number.

`jbe` compare two unsigned number, like `jle`.

`printf "|%2.3s" a ab abc abcd` will print `| a|ab|abc|abc`.  
I can generate repeated string by `printf "mystr%.0s" $(seq 3)` or `printf "mystr%.0s" {1..3}`.

`cmovne r1, r2` conditional `mov`` while value in`r2` is not zero.
