.intel_syntax noprefix
.global _start
_start:
    socket:
    mov rdi, 2 # AF_INIT
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0
    mov rax, 0x29
    syscall

    bind:
    mov rdi, rax
        new_sockeraddr:
        mov rbp, rsp
        # below little endian
        sub rsp, 0x10                  # 16 bytes for struct
        mov word ptr [rbp-0x10], 2     # AF_INIT
        mov word ptr [rbp-0xE], 0x5000 # port 80 == 0x0050
        mov dword ptr [rbp-0xC], 0     # 0.0.0.0
        mov qword ptr [rbp-0x8], 0
    mov rsi, rsp
    mov rdx, 0x10 # struct size
    mov rax, 0x31 # bind
    syscall

    listen:
    # mov rdi, rdi
    mov rsi, 0
    mov rax, 0x32 # listen
    syscall

    accept:
    # mov rdi, rdi
    mov rsi, 0 # NULL
    mov rdx, 0 # NULL
    mov rax, 0x2b # accept
    syscall


    exit:
    mov rsp, rbp
    mov rdi, 0
    mov rax, 60
    syscall
