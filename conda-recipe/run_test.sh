#!/bin/bash
if [ -e ${QLIC}/kc.lic ]
then
  conda install -y -q --file tests/requirements.txt
  q test.q -q;
else
  echo No kdb+, no tests;
fi
