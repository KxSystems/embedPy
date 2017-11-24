/ test embedPy behaviour when passing bad unicode strings to python
-1"## unicode tests start";
p)1
bad:"hello\351world";
p)def slen(x):return len(x)
v:.p.callable .p.eval"slen";
`pyerr~@[v;bad;{`pyerr}]
`pyerr~@[.p.set[`bad];bad;{`pyerr}]
`pyerr~@[.p.set[`bad];2#enlist bad;{`pyerr}]
`pyerr~@[.p.set[`bad];`a`b!2#enlist bad;{`pyerr}]
-1"## unicode tests end";
