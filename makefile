d=/home/awilson/anaconda3/lib/libpython3.6m.so
C=gcc -g3 -Os -DKXVER=3 
D=-DPH='L"/home/awilson/anaconda3:/home/awilson/anaconda3"' -DRP=1 -DDY='"/home/awilson/anaconda3/lib/libpython3.6m.so"'
I=-I/home/awilson/anaconda3/include/python3.6m -I/home/awilson/anaconda3/lib/python3.6/site-packages/numpy/core/include
L= -L/home/awilson/anaconda3/lib -lpython3.6m -Xlinker -rpath -Xlinker /home/awilson/anaconda3/lib -fPIC -shared
p.so:p.c k.h makefile
	$C $< -o $@ $D $I $L
k.h:
	curl https://raw.githubusercontent.com/KxSystems/kdb/master/c/c/k.h -o k.h
test:p.so
	q test.q tests/*.t 
