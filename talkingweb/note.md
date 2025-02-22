# HTTP

## HTTP protocalo

### request
`<method> SP <request-URI> SP <HTTP_VERSION> CRLF`

The request-URI contains route(also named path) and parameters.


## HTTP URL Scheme
`<scheme>://<host>:<port>/<path>?<query>#<fragment>`

query is `key=value&anotherkey=anothervalue` with & as split operator.

query and fragment are parameters.

### URL Encoding
Use %HEX_NUM to be request-URI

## Making HTTP Requests

host
```
nc -lkN 127.0.0.1 80

HTTP/1.0 200 OK
Content-type: text/html

<h1>hello world<h1>

```

client
```sh
curl <domain/IP>

curl -v -X POST -H 'Some-content: value' localhost:80
```
```
nc localhost 80

<HTTP_CONTENTS(notice two newline for end)>
```

```python
import requests
response = requests.get(url_str)

print(response.text())
print(response.headers()) # this is a dict object

for k, v in response.headers.items():
    print(f"{k}: {v}")

requests.post(url_str, headers=dict_obj)
```
