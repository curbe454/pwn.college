# HTTP Host Header(curl)
Just to use `cat` to read the src of /challenge/server and get the host cryptopals.com and route /pass.
```ans
curl -H "Host: cryptopals.com" http://challenge.localhost:80/pass
```

# HTTP Host Header(netcat)
printf "GET /access HTTP/1.0\r\nHost: challs.reyammer.io\r\n\r\n" | nc localhost 80

# HTTP Host Header(python)
```sh
printf "import requests\ns = requests.get('http://challenge.localhost:80/complete', headers={'Host': 'net-force.nl'}).text; print(s)" | python3
```

# Multiple HTTP Arguments(curl)
`curl "http://challenge.localhost:80/meet?secret=hxlogchk&unlock_code=mwtggjba&auth_pass=xoowabjz"`

# HTTP Forms(curl)
POST-ing data to the server calls posting form data, usually the data are sensitive infomation.
For example, sending flag to the server in a CTF competetion. :D
`curl -F security_token=uwcaspzq http://challenge.localhost:80/verify`


# HTTP Forms(nc)
```sh
route="/submit"
request_line="POST ${route} HTTP/1.0\r\n"

header1="Host: challenge.localhost:80\r\n"

post_params="keycode=czyqjhzs"
post_header="Content-Type: application/x-www-form-urlencoded\r\nContent-Length: $(printf ${post_params} | wc -c)\r\n"

data="\r\n${post_params}\r\n"

printf "${request_line}${header1}${post_header}${data}" | nc challenge.localhost 80
```
this is what to be constructed: 
```plaintext
POST /submit HTTP/1.0
Host: challenge.localhost:80
Content-Type: application/x-www-form-urlencoded
Content-Length: 16

keycode=czyqjhzs
```


# HTTP Forms(python)
```python
#! /run/workspace/bin/python3
import requests
route="/meet"
url=f"http://challenge.localhost:80{route}"

r = requests.post(url, data={"auth_key": "etnqjdtc"})
print(r.text)
```

# Multiple Forms Fields(curl)
`params="-F authcode=rauvrutk -F unlock=easgrmzq -F credential=gefgxmap" && curl $params http://challenge.localhost:80/submission`

# Multiple Forms Fields(nc)
```
route="/submit"
request_line="POST ${route} HTTP/1.0\r\n"

header1="Host: challenge.localhost:80\r\n"

post_params="auth=wsbwuwbp&auth_pass=geptrjat&solution=cgpdmkdx&private_key=imtyffpa"
post_header="Content-Type: application/x-www-form-urlencoded\r\nContent-Length: $(printf ${post_params} | wc -c)\r\n"

data="\r\n${post_params}\r\n"

printf "${request_line}${header1}${post_header}${data}" | nc challenge.localhost 80
```
below are what's to be generated:
```
POST /submit HTTP/1.0
Host: challenge.localhost:80
Content-Type: application/x-www-form-urlencoded
Content_Length: 71

auth=wsbwuwbp&auth_pass=geptrjat&solution=cgpdmkdx&private_key=imtyffpa
```

# JSON parameters(curl)
```sh
curl -X POST \
     -H "Content-Type: application/json \
     -d '{"key": "data"}' \
     http://challenge.localhost:80/route
```


# JSON parameters(netcat)
POST /route HTTP/1.0
Host: challenge.localhost:80
Content-Type: application/json
Content-Length: xxx

{"key": "data"}

# JSON parameters(python)
```python
import requests as req
h = '{"Content-Type": "application/json"}'
data = {'key': 'value'}
print(
    re.post("http://challenge.localhost/route", headers=h, json=data)
```

# HTTP Redirects(curl)
`curl http://challenge.localhost:80 -L`

# HTTP Redirects(netcat)
Just try the 2nd time for the return redirect path.  
it's too troublesome to do it by one-line script.

# HTTP redirects(python)
Just use GET, python will automatically redirect to the right path.


# HTTP Cookies(curl)
Use -v to get Cookie for the first time and send cookie by -H for the 2nd time.

`curl http://127.0.0.1:80 -v`

`curl http://127.0.0.1:80 -H "Cookie: cookie=9407ebb674a139ea2c0314b3095a8947"`

# HTTP Cookies(nc)
Send cookie the 2nd time.
```
GET / HTTP/1.0
Cookie: cookie=3d53b33ae102d7552de09ba374608e0c
```

# HTTP Cookies(python)
Just simply GET that url. 
```python
import requests
url=f"http://localhost:80"

r = requests.get(url)
print(r.text)
```
Quickily skim some code of requests lib.
Each requests.get() method create an anomynous Session object. That session saved the cookie.
To see the cookie, a session object should be exposed.
```python
import requests as req
url=f"http://localhost:80"

sess = req.Session()
r = sess.get(url)
print(r.text) # print flag
print(sess.cookies) # print cookie
```

