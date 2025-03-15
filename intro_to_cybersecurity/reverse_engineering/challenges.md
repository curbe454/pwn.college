# File Formats: Magic Numbers
I wrote a detailed writeup [here](File-Formats-Magic-Numbers/README.md).

`printf "cIMG" | /challenge/run` or
`printf "cIMG" > temp.cimg && /challenge/cimg $(pwd)/temp.cimg && rm $_`.

# Reading Endianness
`printf "Conn" | /challenge/run`

# Version Information
Now I can reversed that the (read_exact) function is like
`void read_exact(int fd, void* pdata, int len, char* err_msg, int exit_code)`.
To read `len` bytes in file of `fd` to store at the address of `pdata`, and check sth. If check is failed,
call `exit(exit_code)`.

`printf "cIMG\x01\x00" | /challenge/cimg` or
`printf 'import pwn, struct\np=pwn.process("/challenge/cimg");p.send(struct.pack("<hhh", 0x4963, 0x474d, 0x1))\nprint(p.recvall().decode())' | python`
