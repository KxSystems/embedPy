/ tensorflow tests
-1"## Tensorflow fit tests start";
p)import tensorflow as tf
p)def fit(x_data,y_data): #adapted from https://www.tensorflow.org/get_started
 W = tf.Variable(tf.random_uniform([1], -1.0, 1.0))
 b = tf.Variable(tf.zeros([1]))
 y = W * x_data + b
 loss = tf.reduce_mean(tf.square(y - y_data))
 optimizer = tf.train.GradientDescentOptimizer(0.5)
 train = optimizer.minimize(loss)
 init = tf.global_variables_initializer()
 sess = tf.Session()
 sess.run(init)
 for step in range(201):
  sess.run(train)
 return [sess.run(W),sess.run(b)]
fit:.p.get[`fit;<]
x:100?1f
y:.3+.1*x
t)8 8h~type each fit[x;y]
8 8h~type each fit[x;y]
-1"## Tensorflow fit tests end";
