-1"## Matplotlib start";
trap:@[.p.e;;-2@]
trap"import matplotlib.pyplot as plt"
.p.set[`x]x:til[50]%50
.p.set[`y]sin[4*x*4*atan 1]*exp -5*x
trap"plt.fill(x,y,'r')"
trap"plt.grid(True)"
/ p)plt.show() / not sure how to test this
-1"## Matplotlib end";
