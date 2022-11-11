#!/bin/bash
if [[ $SUBDIR == $build_platform ]]
then
 if [ -e ${QLIC}/kc.lic ]
 then
   q conda-recipe/prep_requirements.q -q
   conda install -y -q --file tests/requirements_filtered.txt
   q test.q -s 4 -q;
 else
   echo No kdb+, no tests;
 fi
else
 echo cross compile, no tests
fi

