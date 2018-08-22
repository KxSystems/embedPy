#!/bin/bash
export QHOME=$PREFIX/q
if [ $(uname) == Linux ];
then
	QLIBDIR=l64
else
	QLIBDIR=m64
fi
make p.so
mkdir -p $QHOME
mkdir -p $QHOME/$QLIBDIR
mv p.q p.k $QHOME
mv $QLIBDIR/p.so $QHOME/$QLIBDIR
