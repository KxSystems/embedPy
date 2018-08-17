requiremod`pandas
tab2df:{
  r:.p.import[`pandas;`:DataFrame.from_dict;flip 0!x][@;cols x];
  $[count k:keys x;r[`:set_index]k;r]}
df2tab:{
  n:$[.p.isinstance[x`:index;.p.import[`pandas]`:RangeIndex]`;0;x[`:index.nlevels]`];
  n!raze[`$$[n;x[`:index.names]`;0#`],x[`:columns.values]`]xcols flip$[n;x[`:reset_index][];x][`:to_dict;`list]`}
k:1!`c3`c2`c1 xcols x:([]c1:1 2 3;c2:("one";"two";"three");c3:1.5 2.5 3.5)
x~df2tab tab2df x
k~df2tab tab2df k
