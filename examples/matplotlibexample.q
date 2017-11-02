/ this example shows importing pyplot from matplotlib and exposing the methods in pyplot as q functions
/ it can be loaded in a q session with p.q loaded with
/ q)\l matplotlibexample.q

/ import matplotlib.pyplot and wrap it in a dictionary called plt
\l importmatplotlib.q
plt:.matplotlib.pyplot[]

/ now we create and display a simple plot
t:til[200]%100
pi:2*asin 1
s:1+sin 2*pi*t
/ because each of the plt functions returns a foreign we suppress output here
plt.plot[t;s];
plt.xlabel"time (s)";
plt.ylabel"voltage (mV)";

plt.title"A chart created using q data";
plt.grid 1b;
plt.show[];



\
This is equivalent to the python below
t = np.arange(0.0, 2.0, 0.01)
s = 1 + np.sin(2*np.pi*t)
plt.plot(t, s)

plt.xlabel('time (s)')

plt.ylabel('voltage (mV)')
plt.title('About as simple as it gets, folks')
plt.grid(True)
plt.show()

