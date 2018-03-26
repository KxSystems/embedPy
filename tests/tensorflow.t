/ tensorflow tests
setenv[`TF_CPP_MIN_LOG_LEVEL]1#"2"
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
1 3~raze"j"$10*fit[x;y]
