.intel_syntax noprefix
.global _start
_start:
    mov rbp, rsp
    sub rsp, 0x10
    socket:
    mov rdi, 2 # AF_INIT
    mov rsi, 1 # SOCK_STREAM
    mov rdx, 0
    mov rax, 0x29
    syscall
    mov r8, rax # socket fd

    bind:
    mov rdi, r8
        new_sockeraddr:
        # use tmp space in stack(16 bytes for struct)
        # below little endian
        mov word ptr [rbp-0x10], 2     # AF_INIT
        mov word ptr [rbp-0xE], 0x5000 # port 80 == 0x0050
        mov dword ptr [rbp-0xC], 0     # 0.0.0.0
        mov qword ptr [rbp-0x8], 0
    mov rsi, rsp
    mov rdx, 0x10 # struct size
    mov rax, 0x31 # bind
    syscall

    listen:
    # mov rdi, r8
    mov rsi, 0
    mov rax, 0x32 # listen
    syscall

    accept:
    mov rdi, r8
    mov rsi, 0 # NULL
    mov rdx, 0 # NULL
    mov rax, 0x2b # accept
    syscall
    mov qword ptr [rbp-0x8], rax # accept fd

    dynamic_response:
        read_request:
            mov rdi, [rbp-0x8] # get fd from accept()
            ### TODO: now the fd of socket is not at rdi(lost)
            sub rsp, 0x100 # STACK1: read request
            mov rsi, rsp
            mov rdx, 0x100 # read length max
            mov rax, 0x0 # read()
            syscall
        
        open_reqested:
            mov rdi, rsp     # in `/challenge/run` we know after 4 bytes
            add rdi, 0x4     # of "GET " there'are 16 chars.
            # GET_abcdefgh ijklmnop xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx 
            mov byte ptr [rdi+0x10], 0 # we don't need rest msg anymore
            mov rsi, 0  # O_RDONLY
            mov rax, 0x2  # open
            syscall
        read_requested:
            mov rdi, rax # openfile fd
            sub rsp, 0x100 # STACK2 read content
            mov rsi, rsp
            mov rdx, 0x100
            mov rax, 0x0 # read
            syscall

            mov r9, rax # count read
        close_requested:
            # mov rdi, rdi # openfile fd
            mov rax, 0x3
            syscall
        
        response_head:
            # "HTTP/1.0 200 OK\r\n\r\n" have length 19
            sub rsp, 0x14 # on plus length of string
            mov rbx, 0x302e312f50545448
            mov qword ptr [rsp], rbx     # can't mov direct number with size over 32 bits
            mov rbx, 0x0d4b4f2030303220
            mov qword ptr [rsp+8], rbx
            mov dword ptr [rsp+0x10], 0x000a0d0a
            
            mov rdi, [rbp-0x8] # accept fd
            mov rsi, rsp
            mov rdx, 0x13
            mov rax, 0x1  # write
            syscall

            restore_string:
            mov rbx, 0
            mov qword ptr [rsp], rbx
            mov qword ptr [rsp+0x8], rbx
            mov dword ptr [rsp+0x10], ebx
            add rsp, 0x14
            
        response_content:
            # mov rdi, [rbp-0x8] # accept fd
            mov rsi, rsp
            mov rdx, r9 # count read
            mov rax, 0x1 # write
            syscall
            add rsp, 0x100 # STACK2: restore read
    
    close_accept:
        # mov rdi, [rbp-0x8]
        mov rax, 3
        syscall

    mov rsp, rbp # STACK: restore
    
    end_loop:
    jmp accept

    exit:
    mov rdi, 0
    mov rax, 60
    syscall

