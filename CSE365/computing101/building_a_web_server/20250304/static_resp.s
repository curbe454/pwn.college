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

    static_response:
        read:
            mov rdi, rax # get fd from accept()
            ### TODO: now the fd of socket is not at rdi(lost)
            sub rsp, 0x100
            mov rsi, rsp
            mov rdx, 0x100 # read length
            mov rax, 0 # read()
            syscall
            add rsp, 0x100
        write:
        # "HTTP/1.0 200 OK\r\n\r\n" have length 19
        sub rsp, 0x14 # on plus length of string
        mov rbx, 0x302e312f50545448
        mov qword ptr [rsp], rbx     # can't mov direct number with size over 32 bits
        mov rbx, 0x0d4b4f2030303220
        mov qword ptr [rsp+8], rbx
        mov dword ptr [rsp+0x10], 0x000a0d0a

        # mov rdi, rdi
        mov rsi, rsp
        mov rdx, 0x13
        mov rax, 0x1  # write
        syscall

    close_accept:
        # mov rdi, rdi
        mov rax, 3
        syscall

    exit:
    mov rsp, rbp
    mov rdi, 0
    mov rax, 60
    syscall
