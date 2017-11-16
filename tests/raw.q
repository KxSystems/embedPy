/this code shows q2py.. here for illustration purposes
-1"## raw tests start";
.p:(`:./p 2:`lib,1)`
\d .p
/q2py
1~getj j2py 1

/for other "integer" types, cast to j
1~getj j2py "j"$"\001"

/for ef, cast x to f
1.~getf f2py "f"$1.e

/for issue 18 (unicode encoding errors), we deal with bytes in p.c.  use bytes.decode('utf-8') in p.q and handle error there?
"hi!"~10h$getG G2py 4h$"hi!"

/just to prove nothin' of nothin' is nothin'
(::)~getnone  null2py[]

/array handling
2 3~getarray[;1;2] a2py 1 2 3

/tuple
getseq fs2py j2py each 1 2

/foreigns
1 2~getj each getseq fs2py j2py each 1 2

/lambda
lambda2py {}

-1"## raw tests end";
