CFLAGS=-ggdb3 -O2 -Wno-pointer-sign -Wno-parentheses
ifeq ($(shell uname),Linux)
LDFLAGS=-fPIC -shared
QLIBDIR=l64
else ifeq ($(shell uname),Darwin)
LDFLAGS=-bundle -undefined dynamic_lookup
QLIBDIR=m64
endif
p.so: $(QLIBDIR)/p.so
	cp $(QLIBDIR)/p.so .
$(QLIBDIR)/p.so: py.c py.h k.h
	mkdir -p $(QLIBDIR)
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@
p.dll: py.c py.h k.h q.lib
	cl64 /LD /DKXVER=3 /Fe$@ /O2 $< q.lib
embedPy.zip: p.so p.q p.k test.q tests LICENSE README.md
	zip -r $@ $^
embedPy-w64.zip: p.dll p.q p.k test.q tests LICENSE README.md
	zip -r $@ $^
k.h:
	curl -O -J -L https://github.com/KxSystems/kdb/raw/master/c/c/k.h
q.lib:
	curl -O -J -L https://github.com/KxSystems/kdb/raw/master/w64/q.lib
