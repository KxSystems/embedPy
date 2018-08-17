#!/bin/bash
if [ -e ${QLIC}/kc.lic ]
then
  q conda-recipe/prep_requirements.q -q
  conda install -y -q --file tests/requirements_filtered.txt
  q test.q -q;
else
  echo No kdb+, no tests;
fi
