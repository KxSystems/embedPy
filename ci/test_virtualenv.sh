pip3 install virtualenv;
virtualenv test_virtualenv;
. test_virtualenv/bin/activate
pip -q install -r tests/requirements.txt;
q test.q -s 4 -q;

