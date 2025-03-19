# File Formats: Magic Numbers
I wrote a detailed writeup [here](File-Formats-Magic-Numbers/README.md).

`printf "cIMG" | /challenge/run` or
`printf "cIMG" > temp.cimg && /challenge/cimg $(pwd)/temp.cimg && rm $_`.

# Reading Endianness
`printf "Conn" | /challenge/run`

# Version Information
Now I can guess that the `read_exact()` function is like
`void read_exact(int fd, void* pdata, int len, char* err_msg, int exit_code)`.
To read `len` bytes in file of `fd` to store at the address of `pdata`, and check sth. If check is failed,
call `exit(exit_code)`. In this challenge, it checks if length of read data is over than 6 bytes.

`printf "cIMG\x01\x00" | /challenge/cimg` or  
`printf 'import pwn, struct\np=pwn.process("/challenge/cimg");p.send(struct.pack("<hhh", 0x4963, 0x474d, 0x1))\nprint(p.recvall().decode())' | python`

# Metadata and Data
`printf 'import pwn, struct\np = pwn.process("/challenge/cimg");p.send(struct.pack("<hhhbb", 0x4963, 0x474d, 0x1, 0x50, 0x18));p.send(b"0" * 0x780)\nprint(p.recvall().decode())' | python`

# Input Restrictions
`0x0000000000401393 <+303>:   cmp    sil,0x5e`

The value of any channel in any pixel should be less than `0x5e`.
So the writeup of the first above challenge is reusable.

I have a sense of foreboding. Let me see will I use `numpy` or `Pillow` then.

I come up a good way to write writeup, to write a C language version of the asm code.
```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>

typedef char byte

void win() { printf("You're win!"); }

int read_exact(int fd, byte* buf, int len, char* err_msg, int exit_code) {
    size_t l = len;
    int read_len = read(fd, buf, l);
    if (read_len == len)
        return len;
    else {
        __fprintf_chk(stderr, 0x1, err_msg);
        // The interface __fprintf_chk() shall function in the same way as the interface fprintf(), except that __fprintf_chk() shall check for stack overflow before computing a result, depending on the value of the flag parameter.
        fputc(stderr, '\n');
        exit(exit_code);
    }
    // here may raise a warning.
}

// I think use struct is better to understand.
struct cimg_head {
     short int magic_fr; // should be 0x4963(Ic)
     short int magic_bc; // should be 0x474d(GM)
     short version;      // should be 0x01
     byte width;         // should be 0x50
     byte height;        // should be 0x18
}

int main(int argc, char* argv[]) {
    int read_fd = 0;
    argc--;
    struct cimg_head fhead = {0};
    if (argc <= 0)
        goto read_content;

    // there should be some content to handle the case that argc > 0.

read_content:
    char* err_msg = "ERROR: Failed to read cimg header!";
    read_exact(0, (byte*)&fhead, 0x8, err_msg, 0xffffffff);

    if (fhead.magic_fr != 0x4963)
        goto exit_invalid;
    if (fhead.magic_bc == 0x474d)
        goto check_version;

exit_invalid:
    char* msg = "ERROR: Invalid magic number!"
err_exit:
    puts(msg);
exit_direct:
    exit(0xffffffff);
    
check_version:
    if (fhead.version != 0x1) {
        char* msg = "ERROR: Unsupported version!";
        goto err_exit;
    }

    if (fhead.width != 0x50) {
        char* msg = "ERROR: Incorrect width!";
        goto err_exit;
    }

    if (fhead.height != 0x18) {
        char* msg = "ERROR: Incorrect height!";
        goto err_exit;

    byte** pimg_data = (byte**)malloc(0x780); // it is 0x50 * 0x18 !!!
    char* msg = "ERROR: Failed to allocate memory for the image data!";
    if (!pimg_data)
        goto err_exit;

    err_msg = "ERROR: Failed to read data!"
    byte** pdata = pimg_data;
    read_exact(0, pdata, 0x780, msg, 0xffffffff);

    int img_size = fhead.height;
    int i = fhead.width;
    img_size *= i;
    for (i=0; i < img; ) {
        int* curr = *(pimg_data + i);
        i++;
        int* ch = (curr - 0x20); // I don't know what's the meaning.
        if ((byte)ch <= 0x5e)    // maybe (byte)ch == *(byte)ch
            continue;

        __fprintf_chk(stderr, 1, "ERROR: Invalid character 0x%x in the image data!\n");
        goto exit_direct;
    }
    win();
}
```
I do these for an hour... Maybe I won't do this.

# Behold the cIMG!
The program will read the img by the input size.

The display function `display(char* magic_nums, char* img_bytes)`.  
All bytes to be display should not less than `0x20`.  
There's a loop to detect if the bytes in cimg is exactly have 0x113 bytes are not `0x20`.

`printf 'import pwn, struct\np=pwn.process("/challenge/cimg")\np.send(struct.pack("<hhhbb", 0x4963, 0x474d, 0x1, 0x10, 0x12));p.send(b"\\x20"*0xd + b"\\x30"*0x113)\nprint(p.recvall().decode())' | python`

# A Basic cIMG
Now the program can print colorful chars.

chars which is not `0x20` should be `0x780`, all pixels should have color `#8c1d40`.

### writeup 1
```py
import pwn, struct

p = pwn.process("/challenge/cimg")

metadata = struct.pack("<hhhbb", 0x4963, 0x474d, 0x2, 0x18, 0x50)
data = b'\x8c\x1d\x40\x30' * 0x780
p.send(metadata)
p.send(data)
print(
        repr(metadata),
       # repr(data),
        sep='\n')

print(p.recvall().decode())
```

### writeup 2
0x780 == 1920  
`data=$(printf '\x8c\x1d\x40\x30%.0s' {1..1920}) && printf "cIMG\x2\x0\x50\x18$data" | /challenge/cimg`
