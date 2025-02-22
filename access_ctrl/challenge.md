# lvl 1 & 2
`/challenge/run && cat /flag`

# lvl 3
```sh
/challenge/run
chmod +r /flag
cat /flag
```

# lvl 4
The same as level 1 or 2.

# lvl 5
```sh
/challenge/run 
cp --no-preserve=mode /flag ./ans
cat ./ans && rm ./ans
```

# lvl 6
```sh
/challenge/run
newgrp group_mvhqcysb
Password:
cat /flag
```

# lvl 7
chmod

# lvl 8 & 9
```sh
su user_wgomhysm
cat /flag
```

# lvl 10
`getent group group_grt` and login.

# lvl 11
Just go to `/tmp` directory and use `ls -l`, then it's easy to find the flag.

# lvl 17 ~ 19
```python
import pwn,re

S = 0
O = 1

def is_ans(s):
    return 'pwn.college' in s

def is_ques(s):
    return '?' in s

def is_read(s): return 'read' in s
def is_write(s): return 'write' in s

def have_cate(s):
    return '{' in s

def out(p, bol):
    if bol: p.write('yes\n'.encode())
    else: p.write('no\n'.encode())
    print(bol)

def get_cate(s):
    ss = s.split('Object')
    p = r'\{([^}]+)\}'
    ma = [ re.findall(p, x) for x in ss ]
    res = [ set({}) if len(ls)==0
                    else set(ls[0].replace(' ','').split(',')) for ls in ma ]
    return res


def solve_cate(p, s):
    words = s.split()
    levels = list(filter(lambda w: w in LVL, words))
    cats = get_cate(s)
    print(cats)
    if is_read(s):
        out(p, cats[O].issubset(cats[S]) and v(levels[S]) >= v(levels[O]))
    else: # is write
        out(p, cats[S].issubset(cats[O]) and v(levels[S]) <= v(levels[O]))

def solve_no_cate(p, s):
    print('Error: solve_no_cate', s)

def v(lvl_s):
    return LVL_DICT[lvl_s]


def get_levels(p):
    line = ""
    while "Level" not in line:
        line = p.recvline().decode()
    lvl_num = int(re.findall(r'^\d+', line)[0])
    res = dict()
    for i in range(lvl_num):
        lvl = p.recvline(keepends=False).decode()
        res[lvl] = -i
    # print(res)
    return res

def get_categories(p):
    line = ""
    while "Categories" not in line:
        line = p.recvline().decode()

    cate_num = int(re.findall(r'^\d+', line)[0])
    res = set()
    for i in range(cate_num):
        cate = p.recvline(keepends=False).decode()
        res.add(cate)
    # print(res)
    return res

p = pwn.process('/challenge/run')

LVL_DICT = get_levels(p)
LVL = set(LVL_DICT.keys())
CAT = get_categories(p)


line = p.recvuntil(b'Q ').decode()
while not is_ans(line):
    try:
        line = p.recvline().decode()
        print(line)
    except EOFError: pass
    if is_ques(line):
        if have_cate(line):
            solve_cate(p, line)
        else:
            solve_no_cate(p, line)
```
