/ pandas dataframes
-1"## Pandas DataFrame tests start";
qt2df:{.p.callable_imp[`pandas;`DataFrame]flip x}
df2qt:{flip .p.attr[;`values]each .p.callable_attr[x;`to_dict]"series"}
x:([]c1:1 2 3;c2:1.5 2.5 3.5)
x~df2qt qt2df x
-1"## Pandas DataFrame tests end";
