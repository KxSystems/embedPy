P=$1;CNDENV=$2;CNDCHN=$3
. "$P/miniconda/etc/profile.d/conda.sh"
set -e
conda create -n $CNDENV conda-build
conda activate $CNDENV
conda install -q -y anaconda-client
EMBEDPY_VERSION=$CI_COMMIT_TAG
export EMBEDPY_VERSION
conda build conda-recipe --output -c $CNDCHN > packagenames.txt
conda build -c $CNDCHN conda-recipe --no-long-test-prefix --no-include-recipe
set +x
CONDATOKEN=$(gpg -d $P/condauploadtoken.gpg)
for pack in $(cat packagenames.txt)
do
 anaconda -t $CONDATOKEN upload -l dev $pack
done
conda deactivate
conda env remove -n $CNDENV
