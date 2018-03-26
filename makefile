QHOME=$(shell echo '-1 getenv`QHOME;'|q -q)

p.so: py.c py.h k.h
	$(CC) -ggdb3 -O2 -shared -fPIC $< -o $@
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
