P=$1;platform=$2
pip3 install virtualenv;
virtualenv test_virtualenv;
. test_virtualenv/bin/activate
pip -q install -r tests/requirements.txt;
QHOME=$P/q QLIC=$P $P/q/$platform/q test.q -s 4 -q;

