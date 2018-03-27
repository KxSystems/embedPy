/ python function call tests
p)def foo(a,b,c=None,d=3):return(a,b,c,d)
p)def goo(a,b,c=None,d=2,*args):return(a,b,c,d,args)
p)def hoo(a,b,c=None,d=2,*args,**kwargs):return(a,b,c,d,args,kwargs)
foo:.p.get[`foo;*]
goo:.p.get[`goo;*]
hoo:.p.get[`hoo;*]
til[4]~foo[0;1;2;3]`
til[4]~(foo . til 4)`
til[4]~foo[0;1;`d pykw 3;`c pykw 2]`
til[4]~foo[0;1;2]`
(0;1;::;3)~foo[0;1;`d pykw 3]`
til[4]~foo[0;1;pyarglist 2 3]`
til[4]~foo[pyarglist til 4]`
til[4]~foo[0;1;pyarglist 3;2]`
til[4]~foo[0;pykwargs `b`c`d!1 2 3]`
til[4]~foo[pyarglist 0;pykwargs `c`b`d!2 1 3]`
1b~.[foo;(`a pykw 0;1;2;3);{"keywords last"~x}]
1b~.[foo;(`a pykw 0;pyarglist 1 2 3);{"keywords last"~x}]
1b~.[foo;(`a pykw 0;1 2 3);{"keywords last"~x}]
