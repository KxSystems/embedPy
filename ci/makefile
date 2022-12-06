ifeq ($(platform),l64)
 CNDPLAT := linux-64
 CNDURL  := https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
 RMRPATH := patchelf --remove-rpath
else
 CNDPLAT := osx-64
 CNDURL  := https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
 RMRPATH := install_name_tool -delete_rpath @loader_path/../../lib
endif
P ?= $(HOME)/.gitlab-runner
KDBF   ?= kdb-4.0-20221026.tar.bz2
KDBURL := https://anaconda.org/kx/kdb/4.0/download/$(CNDPLAT)/$(KDBF)
CNDENV := bld_$(platform)
CNDCHN ?= kx
#prereqs
q: $(P)/q/$(platform)/q
#strip conda rpaths
$(P)/q/$(platform)/q:
	curl -O -J -L $(KDBURL)
	tar xf $(KDBF) q/q.k q/$(platform)/q
	mv q $(P)
	$(RMRPATH) $(P)/q/$(platform)/q
	
conda: $(P)/miniconda/
$(P)/miniconda/:
	wget $(CNDURL) -O miniconda.sh
	bash miniconda.sh -b -p $(P)/miniconda
	. "$(P)/miniconda/etc/profile.d/conda.sh" && \
	hash -r && \
	conda config --set always_yes yes --set changeps1 no && \
	conda update -q conda && \
	conda install -q conda-build
#tests
test: q
	pip3 install -r tests/requirements.txt
	cp $(platform)/p.so .
	QHOME=$(P)/q QLIC=$(P) $(P)/q/$(platform)/q test.q -s 4
	ci/test_virtualenv.sh

#release and deploy
l64/ghrelease:
	gpg -d --batch $(P)/ghtoken.gpg |gh auth login --with-token
	gh release create -d -p -R KxSystems/embedpy --generate-notes $(CI_COMMIT_TAG) embedPy-*-$(CI_COMMIT_TAG).tgz

$(platform)/conda: conda
	ci/conda.sh $(P) $(CNDENV) $(CNDCHN)
l64/docker:
	docker build -t kxsys/embedpy:latest -f docker/Dockerfile .
	docker tag kxsys/embedpy:latest kxsys/embedpy:$(CI_COMMIT_TAG)
	#echo $(DOCKER_PASSWORD)|docker login --username $(DOCKER_USERNAME) --password-stdin && docker push kxsys/embedpy:latest && docker push kxsys/embedpy:$(CI_COMMIT_TAG)
$(platform)/github:
	tar czf embedPy-$(platform)-$(CI_COMMIT_TAG).tgz p.q p.k test.q tests $(platform)/p.so LICENSE README.md
