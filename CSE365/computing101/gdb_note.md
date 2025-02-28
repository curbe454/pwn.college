# Commands
### common commands
- `q` to quit gdb. Use `ctrl+D` can also quit.
- `r` or `run` to run executable. `run ARGS` can run file with arguments.
- `b` or `break` to set break point.
- `p` or `print` to print variables.
- `x` is `examine` for short, which regard the parameter as a address and print it and the value in the address.
- `si` to step into the next asm instruction.
- `ni` to the next asm instruction.
- `finish` will complete the current function by `s` or `si` and to the lower frame.
- `display` will print the variable after every run step of the promgram. New display command will cover the old.

### break points
`info break` show all break points.

`del break 1` delete the 1st brakpoint coded by 1.

`b funcname` will set breakpoint to that function.`b *ADRESS_VALUE` will set breakpoint in the memory.
`b *funcname + addr` is more practical.

### print format
`COMMAND/PARAMETERS` can format the output of the `COMMAND` including `p` or `x`.

The parameters have the form `/<n><u><f>`.
- `<n>` is the number of the output,
- `<u>` express the unit size of the output number, choosed from `b`(1 byte), `h`(2 bytes), `w`(4 bytes), `g`(8 bytes).
- `<f>` valid formats are d (decimal), x (hexadecimal), s (string) and i (instruction).

The formater can be `x`(HEX), `i`(instructions), `u`(unsigned)

### variables
Variables in gdb have prefix `$`.

Variables use C-language dereference and C-language type casting.

- `set $my_var = 7` set a variable. `set` command can also change the value of variable.

### registers
- `info reg` or `info register` to print values of registers.
- `p $rax` to print `rax`.
- `set $rax = 0` change the value of `rax`. This can be used to debug dynamically.

### assemble
- `disassemble main` to disassemble a known function named `main`. `disas` for short.
- `x/10i rip` to examine the following 10 asm instructions start from where rip points. 
- `display/4i $rip` to see the following 4 asm instructions each step.

- `set disassembly-flavor intel` can set the style when gdb disasm the file. It's good to set it in the `~/.gdbinit` file.


# GDB scripts
`gdb -x file.gdb a.out` will use script in `file.gdb` to debug the `a.out` file.

### Example
```gdb
set disassembly-flavor intel

b *main
commands
    silent
    p $rip
    continue
end
run 
q
```
This will finish running the whole executable file and quit gdb.
When the breakpoint hits the `main` function, the $rip will be printed.

# GDB Plugins
`gef`: `https://github.com/hugsy/gef`
