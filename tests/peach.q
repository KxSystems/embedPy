/  q peach.q -s -4
.p:(`:./p 2:`lib,1)`
`py2q`pycall`pyeval set' .p`py2q`call`eval;
{-3#py2q pycall[pyeval"lambda x:list(range(x))";enlist x;()!()]}peach 10000+til 10
