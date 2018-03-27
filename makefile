QHOME=$(shell echo '-1 getenv`QHOME;'|q -q)
CFLAGS=-ggdb3 -O2 -Wno-pointer-sign -Wno-parentheses
ifeq ($(shell uname),Linux)
LDFLAGS=-fPIC -shared
else ifeq ($(shell uname),Darwin)
LDFLAGS=-bundle -undefined dynamic_lookup
endif
p.so: py.c py.h k.h
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@
p.dll: py.c py.h k.h q.lib
	cl64 /LD /DKXVER=3 /Fe$@ /O2 $< q.lib
embedPy.zip: p.so p.q p.k test.q tests LICENSE README.md
	zip -r $@ $^
embedPy-w64.zip: p.dll p.q p.k test.q tests LICENSE README.md
	zip -r $@ $^
k.h:
	wget https://github.com/KxSystems/kdb/raw/master/c/c/k.h
q.lib:
	wget https://github.com/KxSystems/kdb/raw/master/w64/q.lib
