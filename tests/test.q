\d .t
er:0
tc:0
e:{if[not(::)~r:@[get;x;{er+:1;-2"ERROR (",y,")";-2"t)",x;::}x];tc+:1;if[not 1b~r;er+:1;-2"FAIL";-2"t)",x]];}
\d .
\c 10 1000
-1"## ALLTESTS start";
@[{-1"## Loading ",x;system"l ",x};;{-2"## Loading Error (",x,")"}]each .z.x;
-1"## ALLTESTS end (",string[.t.tc],") total tests, (",string[.t.er], " failed tests)";
exit .t.er
