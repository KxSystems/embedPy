df:.p.import[`pandas]`:DataFrame
qt2df:{df flip x}
df2qt:{flip{.p.wrap[x][`:values]`}each x[`:to_dict;"series"]`}
x:([]c1:1 2 3;c2:1.5 2.5 3.5)
x~df2qt qt2df x
