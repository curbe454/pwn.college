s = 'Hello, せかい'
b = s.encode()

type(s), type(b) # s is string and b is bytes

assert s == b.decode('utf-8') # default encode-decode method is utf8
h = b.hex() # let bytes to be string of numbers of the contents

ch = 'a'
assert ord('a') != ch.encode().hex() # ord() is to get the Unicode value of one-character string.


s.encode('utf-8'), s.encode('utf-16'), ch.encode('latin-1') # there're many encoding ways


try: s.encode().decode('latin-1') # it makes error when try strange decoding way
except: pass

assert ch == chr(ord(ch))
