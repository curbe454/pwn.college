# python bytes
Python bytes starts from b, for example, `exp = b'2b[=3a.-\x184'`.

Each printable value is a byte in bytes, `exp[0] == b'2'`.

Unprintable value will be represent as escape character, it's also aviliable to use escape character to construct a byptes object.

```python -i
>>> b'\x41' # use prefix "\x" escape character by HEX.
b'A'
>>> b'\101' # use prefix "\" escape character by OCT.
b'A'
```

The function `ord()` in python acts different between byte and string. `ord(b'A')` and `ord('A')` are both `65`.

For byte, it just convert the inner value from HEX to DEC; for string convert character to its order in Unicode.
