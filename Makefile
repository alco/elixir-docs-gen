ELIXIR_LANG_DIR = elixir-lang.github.com

SOURCE_DIR = source
DOCS_DIR = docs
DOCS_SUBDIRS = $(addprefix $(DOCS_DIR)/,intro mix_otp meta _static technical)

GETTING_STARTED_ROOT = $(ELIXIR_LANG_DIR)/getting_started

define make_path
$(addprefix $(1),$(addsuffix .rst,$(2)))
endef

CONF_FILES = $(DOCS_DIR)/conf.py
INDEX_FILES = $(addsuffix /index.rst,\
				  $(DOCS_DIR) $(DOCS_DIR)/intro $(DOCS_DIR)/mix_otp \
				  $(DOCS_DIR)/meta)

GETTING_STARTED_CHAPTERS = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
GETTING_STARTED_FILES = $(call make_path,$(DOCS_DIR)/intro/,$(GETTING_STARTED_CHAPTERS))

MIX_GUIDE_CHAPTERS = 1 2 3 4 5 6 7 8 9 10
MIX_GUIDE_FILES = $(call make_path,$(DOCS_DIR)/mix_otp/,$(MIX_GUIDE_CHAPTERS))

META_GUIDE_CHAPTERS = 1 2 3
META_GUIDE_FILES = $(call make_path,$(DOCS_DIR)/meta/,$(META_GUIDE_CHAPTERS))

TECHNICAL_FILES = $(DOCS_DIR)/technical/scoping.rst

.PHONY: elixir_lang_dir copy-files build rebuild push clean clean-build clean-generated

all: build

rebuild: clean-build build

copy-files: elixir_lang_dir \
			$(DOCS_SUBDIRS) \
	        $(CONF_FILES) \
	        $(INDEX_FILES) \
	        $(TECHNICAL_FILES) \
	        $(GETTING_STARTED_FILES) \
	        $(MIX_GUIDE_FILES) \
	        $(META_GUIDE_FILES) \
	        $(DOCS_DIR)/Makefile

build: copy-files
	$(MAKE) -C $(DOCS_DIR) html

push: build
	cd docs && git add -A . && git commit -m "Update generated docs" && git push origin master

$(ELIXIR_LANG_DIR):
	git clone https://github.com/elixir-lang/elixir-lang.github.com.git

elixir_lang_dir: $(ELIXIR_LANG_DIR)
	cd $(ELIXIR_LANG_DIR) && git checkout 09c5412~

$(DOCS_DIR)/conf.py: source/conf.py
	cp $< $@

$(DOCS_DIR)/index.rst: source/index.rst
	#cp $< $@
	sed 's/<GEN_COMMIT>/'`cd $(ELIXIR_LANG_DIR) && git rev-parse HEAD`'/' $< >$@

$(DOCS_DIR)/intro/index.rst: source/intro_index.rst
	cp $< $@
	echo $(GETTING_STARTED_CHAPTERS) | tr ' ' '\n' | awk '// { print("  ", $$0); }' >> $@

$(DOCS_DIR)/mix_otp/index.rst: source/mix_otp_index.rst
	cp $< $@
	echo $(MIX_GUIDE_CHAPTERS) | tr ' ' '\n' | awk '// { print("  ", $$0); }' >> $@

$(DOCS_DIR)/meta/index.rst: source/meta_index.rst
	cp $< $@
	echo $(META_GUIDE_CHAPTERS) | tr ' ' '\n' | awk '// { print("  ", $$0); }' >> $@

$(DOCS_DIR)/Makefile: source/sphinx_Makefile
	cp $< $@

$(DOCS_DIR)/technical/scoping.rst: $(SOURCE_DIR)/technical/scoping.md
	mkdir -p $(DOCS_DIR)/technical
	pandoc --from "markdown" --to "rst" $< \
		| sed 's/--: toc/.. contents:: :local:/' \
		> $@


define GETTING_STARTED_TEMPLATE
$(DOCS_DIR)/$(1)/$(3).rst: $(GETTING_STARTED_ROOT)/$(2)/$(3).markdown
	title=$$$$(cat $$< | grep -m 1 '^title:' | cut -c 8-); \
	cat $$< \
		| sed 's/<div class="toc"><\/div>/--: toc/' \
		| pandoc --from "markdown" --to "rst" \
		| sed "s/{{ page.title }}/$$$$title/" \
		| sed "s/================/==========================================================/" \
		| sed 's/--: toc/.. contents:: :local:/' \
		> $$@
endef

$(foreach chapter,$(GETTING_STARTED_CHAPTERS),$(eval $(call GETTING_STARTED_TEMPLATE,intro,,$(chapter))))
$(foreach chapter,$(MIX_GUIDE_CHAPTERS),$(eval $(call GETTING_STARTED_TEMPLATE,mix_otp,mix_otp,$(chapter))))
$(foreach chapter,$(META_GUIDE_CHAPTERS),$(eval $(call GETTING_STARTED_TEMPLATE,meta,meta,$(chapter))))


$(DOCS_DIR):
	git clone git@github.com:alco/elixir-docs.git docs
	cd docs && rm -rf *

$(DOCS_SUBDIRS): $(DOCS_DIR)
	mkdir -p $@

clean: clean-build clean-generated

clean-build:
	rm -rf $(DOCS_DIR)/_build

clean-generated:
	rm -rf $(DOCS_DIR)
