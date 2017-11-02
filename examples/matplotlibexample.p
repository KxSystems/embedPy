# a very simple chart created using python
# this file can be loaded in a q session with p.q loaded by running
# q)\l matplotlibexample.p
import matplotlib.pyplot as plt
import numpy as np

t = np.arange(0.0, 2.0, 0.01)
s = 1 + np.sin(2*np.pi*t)
plt.plot(t, s)

plt.xlabel('time (s)')

plt.ylabel('voltage (mV)')
plt.title('A chart created in python')
plt.grid(True)
print('hello')
plt.show()

