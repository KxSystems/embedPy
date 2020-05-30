CFLAGS=-ggdb3 -O2 -Wno-pointer-sign -Wno-parentheses -Wextra -Werror -Wsign-compare -Wwrite-strings

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)
MS      := $(shell getconf LONG_BIT)

ifeq ($(UNAME_S),Linux)
  OSFLAG  = l
  LDFLAGS = -fPIC -shared
  ifeq ($(UNAME_M),armv7l)
    CFLAGS  := $(filter-out -Wwrite-strings,$(CFLAGS))
  else
  ifeq ($(UNAME_M),armv6l)
    CFLAGS  := $(filter-out -Wwrite-strings,$(CFLAGS))
  endif
  endif
else ifeq ($(UNAME_S),Darwin)
  OSFLAG  = m
  LDFLAGS = -bundle -undefined dynamic_lookup
endif

TGT   = p.so
QARCH = $(OSFLAG)$(MS)
Q     = $(QHOME)/$(QARCH)


p.so: $(QARCH)/p.so
	cp $(QARCH)/p.so .
$(QARCH)/p.so: py.c py.h k.h
	mkdir -p $(QARCH)
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

install:
	install $(TGT) $(Q)
clean:
	rm -f p.so
	rm -f $(QARCH)/p.so
