/ https://github.com/JuliaPy/PyPlot.jl/issues/278
if[count r:@[read0;`$.p.import[`sys;`:exec_prefix;`],"/qt.conf";""];.p.import[`os;`:putenv;`QT_PLUGIN_PATH;(trim(1+r?"=")_ r:first r where r like"Prefix*"),"/plugins"]]
p)import matplotlib as mpl
p)mpl.use('Agg')
p)import matplotlib.pyplot as plt
.p.set[`x]x:til[50]%50
.p.set[`y]sin[4*x*4*atan 1]*exp -5*x
p)plt.fill(x,y,'r')
p)plt.grid(True)
/ p)plt.show() / not sure how to test this
