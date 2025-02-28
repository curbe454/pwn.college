# assembly
Here's an example of simple assembly on Linux(x86_64):

```s
mov rdi, 42
mov rax, 60
syscall
```

It's the similar as call `exit()` function as C language on inux.
In not just for hardware, assembly codes are also different to interact with different operation systems.

On Linux, `rax` the register is where to store syscall code.
So the `mov rax, 60` is to store syscall code of "exit", then `syscall` to call the operation store in `rax`.

The `mov rdi, 42` is to set the function parameter.

So the whole three sentences is to call the function encoded by 60 with parameter 42,
to exit the assembly program(do nothing).


To pass more paramter to a function, there are more registers.
Such as `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` in order(for integers or pointers, contract by System V AMD64 ABI).


# assemble and disassemble
- Use `as` to assemble and then use `ld` to link.
- Use `gcc -nostdlib`.

Use `objdump -d` to disassmble a ELF file.
The `-M intel` flag will let the result to be the style the same as in pwn.college.

# assembly operations
mov,  
add, sub, mul, imul, div, shr, shl,  
and, or, not, xor,  
push, pop,  
jmp, nop, loop,  
call, ret

### note
`imul` is signed multiply.

`div` is integer division. Divisor should be in `rax`, division should be in a register.
The quotient is in `rax`; the remainder is in `rdx`, and it should be 0 before the divition.

`shr` shift to right; `shl` to left.

`push` and `pop` are operation to manipulate data in a stack in the running program.
There is a register `rsp` automatically trace the top pointer of the stack.

`loop` times depend on the amount of `rcx` register.

The `call` instruction pushes the memory address of the next instruction onto the stack and then
jumps to the value stored in the first argument.
`ret` pops the top value off of the stack and jumps to it.

# bytes in register
`rax` has 8 bytes, `eax` has 4 lower bytes in `rax`, `ax` has 2 lower bytes in `eax`,
`ah` has 1 higher byte in `ax`, `al` has 1 lower byte in `ax`.

# efficient-modulo
`./short_admit.sh "mov rax, 0\nmov al, dil\nmov rbx, 0\nmov bx, esi\n"`

This is also right: `./short_admit.sh "mov rax, 0\nmov al, rdi\nmov rbx, 0\nmov bx, rsi\n"`

# register
`rip` store the instruction pointer.

`rbp`(Register stack Base Pointer) stores the base pointer of stack in programm.
`rsp`(Register Stack Pointer) stores the stack pointer.

