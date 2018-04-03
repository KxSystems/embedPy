// Numpy

np:.p.import`numpy
t:"f"$til@

t[12]~np[`:arange][*][12.]`
t[12]~np[`:arange;*][12.]`
t[12]~np[`:arange][*;12.]`
t[12]~np[`:arange;*;12.]`
t[12]~np[`:arange][12.]`
t[12]~np[`:arange;12.]`

t[12]~np[`:arange][<]12.
t[12]~np[`:arange;<]12.
t[12]~np[`:arange][<;12.]
t[12]~np[`:arange;<;12.]

t[12]~.p.py2q np[`:arange][>]12.
t[12]~.p.py2q np[`:arange;>]12.
t[12]~.p.py2q np[`:arange][>;12.]
t[12]~.p.py2q np[`:arange;>;12.]

v:np[`:arange]12.
t[12]~.p.py2q v`.
t[12]~v`

5.5~v[`:mean][*][]`
5.5~v[`:mean;*][]`
5.5~v[`:mean][*;::]`
5.5~v[`:mean;*;::]`
5.5~v[`:mean;::]`
5.5~v[`:mean][]`

5.5~v[`:mean][<][]
5.5~v[`:mean;<][]
5.5~v[`:mean][<;::]
5.5~v[`:mean;<;::]

5.5~.p.py2q v[`:mean][>][]
5.5~.p.py2q v[`:mean;>][]
5.5~.p.py2q v[`:mean][>;::]
5.5~.p.py2q v[`:mean;>;::]

(3 4#t 12)~v[`:reshape][*][3;4]`
(3 4#t 12)~v[`:reshape;*][3;4]`
(3 4#t 12)~v[`:reshape][*;3;4]`
(3 4#t 12)~v[`:reshape;*;3;4]`
(3 4#t 12)~v[`:reshape;3;4]`
(3 4#t 12)~v[`:reshape][3;4]`

(3 4#t 12)~v[`:reshape][<][3;4]
(3 4#t 12)~v[`:reshape;<][3;4]
(3 4#t 12)~v[`:reshape][<;3;4]
(3 4#t 12)~v[`:reshape;<;3;4]

(3 4#t 12)~.p.py2q v[`:reshape][>][3;4]
(3 4#t 12)~.p.py2q v[`:reshape;>][3;4]
(3 4#t 12)~.p.py2q v[`:reshape][>;3;4]
(3 4#t 12)~.p.py2q v[`:reshape;>;3;4]

m:v[`:reshape;3;4]
(3 4#t 12)~.p.py2q m`.
(3 4#t 12)~m`
(flip 3 4#t 12)~m[`:T]`
(flip 3 4#t 12)~.p.import[`numpy;`:arange;12.][`:reshape;3;4][`:T]`

/
// Stdout

.p.import[`sys][`:stdout.write][*]["hello\n"];
.p.import[`sys][`:stdout.write;*]["hello\n"];
.p.import[`sys][`:stdout.write][*;"hello\n"];
.p.import[`sys][`:stdout.write;*;"hello\n"];
.p.import[`sys;`:stdout.write;*;"hello\n"];
.p.import[`sys][`:stdout.write;"hello\n"];
.p.import[`sys][`:stdout.write]["hello\n"];

stdout:.p.import[`sys;`:stdout.write]
stdout"hello\n";
\

// Python function calls

oarg:.p.eval["10"]
10~.p.py2q oarg`.
10~oarg`

ofunc:.p.eval"lambda x:2+x"
3~ofunc[*][1]`
3~ofunc[*;1]`
3~ofunc[1]`
12~ofunc[*][oarg]`
12~ofunc[*;oarg]`
12~ofunc[oarg]`

3~ofunc[<]1
3~ofunc[<;1]
12~ofunc[<][oarg]
12~ofunc[<;oarg]

p)def add2(x,y):return x*y
add2:.p.get`add2
10~add2[*][1;oarg]`
10~add2[*;1;oarg]`
10~add2[1;oarg]`

10~add2[<][1;oarg]
10~add2[<;1;oarg]

// Get/set attr

system"l ",1_string` sv(` vs hsym .z.f)[0],`tests`test.p
obj:.p.get[`obj][]

(5#0)~obj'[;`]5#`:x
(til 5)~obj'[;`]5#`:y
obj[:;`:x;-2]
obj[:;`:y;-2]
(5#-2)~obj'[;`]5#`:x
(-2+til 5)~obj'[;`]5#`:y
obj[:;`x;-5]
obj[:;`y;-5]
(5#-5)~obj'[;`]5#`:x
(-5+til 5)~obj'[;`]5#`:y

// Help

ar:.p.import[`numpy]`:arange
/help ar`.
/help ar
"arange"~6#.p.helpstr ar`.
"arange"~6#.p.helpstr ar

// Indexing

x:.p.eval"[1,2,3,4,5]"
1 2 3 4 5~x`
1~x[@;0]`
5~x[@;-1]`
1 2 3 4 5~x[@;;`]each til 5
x[=;0;10]
x[=;-1;50]
10 2 3 4 50~x`
10 2 3 4 50~x[@;;`]each til 5

// Closures

xtil:{[x;dummy]x,x+:1}
ftil:.p.closure[xtil;0][<]
(1+til 8)~ftil each 8#(::)

xfib:{[x;dummy](x[1],r;r:sum x)}
fib:.p.closure[xfib;0 1][<]
1 2 3 5 8 13 21 34~fib each 8#(::)

xrunsum:{x,x+:y}
runsum:.p.closure[xrunsum;0][<]
2 5 10 7.5 7.5 17.5~runsum each 2 3 5 -2.5 0 10

// Generators

xfact:{[x;dummy](x;last x:prds x+1 0)}
fact4:.p.generator[xfact;0 1;4]     / generates first 4 factorial values
factinf:.p.generator[xfact;0 1;::]  / generates factorial values indefinitely

1 2 6 24~.p.list[fact4]`
.p.set[`factinf]factinf
1 2 6 24~.p.qeval"[next(factinf) for _ in range(4)]"

/.p.e"for x in factinf:\n print(x)\n if x>1000:break"  / force break to stop iteration

xlook:{[x;dummy]r,r:"J"$raze string[count each s],'first each s:(where differ s)_s:string x}
look:.p.generator[xlook;1;7]
11 21 1211 111221 312211 13112221 1113213211~.p.list[look]`

xsub:{[x;d](@[x;1;+;x 2];sublist[x 1 2]x 0)}
sub:.p.generator[xsub;(.Q.A;0;6);5]
(0N 6#.Q.A)~.p.list[sub]`
