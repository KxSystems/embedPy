/ test embedPy behaviour when passing bad unicode strings to python
p)1
bad:"hello\351world";
p)def slen(x):return len(x)
v:.p.callable .p.eval"slen";
@[v;bad;::]like"*can't decode*"
@[.p.set[`bad];bad;::]like"*can't decode*"
@[.p.set[`bad];2#enlist bad;::]like"*can't decode*"
@[.p.set[`bad];`a`b!2#enlist bad;::]like"*can't decode*"
