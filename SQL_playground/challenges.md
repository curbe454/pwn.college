I just lazy to print upper case letters.
The /challenge/sql allows just one command. So I write this:
```bash keep_sql_on.bash
while true; do /challenge/sql; done
```
Use Ctrl+C to stop this. Press Ctrl+D to send EOF.

I want to install sqlite in my computer to learn it and then I found I can use what in the workspace. :D
In this dojo module, there's ready-made sqlite3. Just input `sqlite3` in the terminal.

<!-- I can't use directional keys to recall the inputted command by this. So I use this then:
```sh input_to_sql.sh
echo $* | /challenge/sql
```
Add execute right to it and use like `./input_to_sql.sh select tbl_name from sqlite_master`.
And I find that sql command with some stuff like * sign, > sign can't work because of bash shell...
-->

# Structrued Query Language
```SQL
> select tbl_name from sqlite_master
Got 1 rows.
- {'tbl_name': 'assets'}
> select * from assets
```

# Filtering SQL
We can't not see more than one entry in this challenge. If the query result more than one entry, it tells: `You're not allowed to read this many rows!`. How strange the restriction!
```SQL
> select tbl_name from sqlite_master  -- this is one line comment in sql
Got 1 rows.
- {'tbl_name': 'data'}
> select * from data limit 1
Got 1 rows.
- {'flag_tag': 1, 'note': 'dOBcEozAvVKIFLeqpygbnJGPSxkSAEzLhvgOvsPQIsRoiWpWtmjMjSWkyey'} -- this is not flag
> select * from data where flag_tag != 1 limit 1   -- this works.
```
I was so lucky.

There are also other ways.
We know the data table have only `flag_tag` and `note` column.
So it's possible to brute-force attack useing pwntools. Like this:
```python like pseudo code
import pwn

query_res = ""
note_value = ""
flag_tag_min = 1

while True:
    p = pwn.process(challenge_filename)
    query_ans = query(p, f"select * from data where flag_tag >= {flag_tag_min} and note > \"pwn.college{\"")
    note_value = get_note(query_ans)

    if is_not_flag(note_value):
        flag_tag_min += 1
    else: break
```

# Choosing Columns
Till now I know that I can read the source code of `/challenge/sql`...

Look the code and knowing that the flag is at the secrets table whose flag_tag is 1337.
```sql
> select snippet from secrets where flag_tag=1337 limit 1
```

# Exclusionary Filtering
`> select record from storage where flag_tag>=1337 and flag_tag<=313371337 and record>"pwn.college" and record<"pwn.collegf" limit 1`

Or this: `> select record from storage where record LIKE "pwn.college{%"`

# Filtering Strings
`echo "SELECT content FROM data where flag_tag='yep'" | /challenge/sql`

# Filtering on Expressions
`echo "SELECT payload FROM items where substr(payload,1,11) == 'pwn.college'" | /challenge/sql`

While this also works out: `echo "SELECT payload FROM items where payload > 'pwn.college' and payload < 'pwn.collegf'" | /challenge/sql`.

# SELECTing Expressions
`for ((i=1; i<100; i=i+5)); do echo "SELECT substr(datum,$i,5) FROM dataset where substr(datum,1,11) == 'pwn.college'" | /challenge/sql; done >> output.txt`

Then I used vim to cat text into password. Learning regex helped me a lot against the copy-paste chores.

# Composite Conditions
`echo "SELECT content FROM storage WHERE flag_tag=1337 and content>'pwn.college'" | /challenge/sql`

# Reaching Your LIMITs
``echo "SELECT info FROM storage WHERE substr(info,1,11)=='pwn.college' LIMIT 1" | /challenge/sql`

# Querying Metadata
But I learned it at the first challenge...

It's also avaliable to write python script to get the flag.
