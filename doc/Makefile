# Makefile for Sphinx documentation

#SPHINXOPTS    = -a -n -W
SPHINXOPTS    = -a -n
SPHINXBUILD   = sphinx-build
SOURCEDIR     = .
BUILDDIR      = build
LINKCHECKDIR  = $(BUILDDIR)/linkcheck
METPLUSROOT   = /scratch1/NCEPDEV/nems/role.epic/spack-stack/spack-stack-1.6.0/envs/upp-addon-env/install/intel/2021.5.0/metplus-5.1.0-eznr7ze

.PHONY: help Makefile linkcheck

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS)

doc:
	make clean
	export METPLUS_ROOT=$(METPLUSROOT) ; $(MAKE) linkcheck
	export METPLUS_ROOT=$(METPLUSROOT) ; $(MAKE) html

linkcheck:
	$(SPHINXBUILD) -b linkcheck $(SPHINXOPTS) $(SOURCEDIR) $(LINKCHECKDIR)

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option. $(O) is meant as a shortcut for $(SPHINXOPTS).

%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) -w $(BUILDDIR)/warnings.log
