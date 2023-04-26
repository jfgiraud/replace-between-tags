DESTDIR ?= /usr/local
REPOSITORY_NAME ?= replace-between-tags
SCRIPTS = rbt
GENERATED_FILES = doc/generated/man/man1/rbt.1 doc/generated/txt/rbt.1.txt doc/generated/md/rbt.md
VERSION ?= $(shell cat doc/VERSION)
FILE_VERSION ?= $(shell cat doc/VERSION)
TESTS = tests/rbt_tests.sh


.ONESHELL:
SHELL=bash

.PHONY: usage
usage:
	@cat - <<EOF
		Targets:
		* install: install scripts in /usr/local/bin (you must call this target with sudo)
		* uninstall: remove scripts from /usr/local/bin
		* test: run all tests
		* archive: create a tgz (used in github pipeline for release)
		* commit-release VERSION=X.Y.Z: commit files and create a release
		* update-doc: update man pages and usages
		* update-version VERSION=X.Y.Z: update man pages and usages
		* install-dependencies: install dependencies (you must call this target with sudo)
	EOF

.PHONY: install-dependencies
install-dependencies:
	apt install asciidoctor
	apt install pandoc

/usr/bin/asciidoctor:
	echo "You must install dependencies."
	echo "sudo make install-dependencies"

doc/generated/man/man1/%.1: doc/%.adoc doc/VERSION
	@echo "Create $@"
	@asciidoctor -b manpage -a release-version="$(VERSION)" $< -o $@

doc/generated/md/%.md: doc/%.adoc doc/VERSION
	@echo "Create $@"
	@SCRIPT=$(shell basename "$@" | sed 's/\..*//')
	@asciidoctor -b docbook doc/$$SCRIPT.adoc -o doc/generated/md/$$SCRIPT.xml
	@pandoc -t gfm+footnotes -f docbook -t markdown_strict doc/generated/md/$$SCRIPT.xml -o doc/generated/md/$$SCRIPT.md
	@rm -f doc/generated/md/$$SCRIPT.xml

doc/generated/txt/%.1.txt: doc/generated/man/man1/%.1 doc/VERSION
	@echo "Create $@"
	@man -l $< > $@
	@SCRIPT=$(shell basename "$@" | sed 's/\..*//')
	@echo "Rewrite usage in $$SCRIPT"
	@awk -i inplace -v input="$@" 'BEGIN { p = 1 } /#BEGIN_DO_NOT_MODIFY:make update-doc/{ print; p = 0; while(getline line<input){print line} } /#END_DO_NOT_MODIFY:make update-doc/{ p = 1 } p' bin/$$SCRIPT

README.md: doc/generated/md/readme.md
	@echo "Move to README.md"
	@mv -f doc/generated/md/readme.md README.md

.PHONY: update-version
update-version:
	[[ "$(VERSION)" == "$(FILE_VERSION)" ]] && echo "Change version number! (make update-version VERSION=X.Y.Z)" && exit 1
	! grep -Eq "^## ${VERSION}\b" CHANGELOG.md && echo "No information about this version in CHANGELOG.md. Add an entry in CHANGELOG.md!" && exit 1
	@echo "Modify version in doc/VERSION"
	@echo "$(VERSION)" > doc/VERSION
	make update-doc

.PHONY: update-doc
update-doc: $(GENERATED_FILES) README.md

.PHONY: commit-release
commit-release: update-version
	@echo "Update documentation"
	make update-doc
	@echo "Commit release $$VERSION"
	git add -u .
	git commit -m "Commit for creating tag v$$VERSION"
	git push
	git tag "v$$VERSION" -m "Tag v$$VERSION"
	git push --tags


.PHONY: test
test:
	@echo "Run tests"
	@for t in $(TESTS); do
	@echo "Run $$t"
	@	bash $$t
	@done

$(REPOSITORY_NAME).tar.gz: $(REPOSITORY_NAME).tar
	@echo "Compress archive $@"
	@gzip -f $<

$(REPOSITORY_NAME).tar: update-doc
	@echo "Create archive $@"
	@tar cf $(REPOSITORY_NAME).tar bin/*
	@tar rf $(REPOSITORY_NAME).tar LICENSE --transform 's,^,share/doc/$(REPOSITORY_NAME)/,'
	@tar rf $(REPOSITORY_NAME).tar doc/generated/man/man1/*.1 --transform 's,^doc/generated/,,'

.PHONY: archive
archive: $(REPOSITORY_NAME).tar.gz

.PHONY: install
install: $(REPOSITORY_NAME).tar.gz
	@echo "Install software to $(DESTDIR)"
	tar zxvf $(REPOSITORY_NAME).tar.gz -C $(DESTDIR)

.PHONY: uninstall
uninstall:
	@echo "Uninstall software from $(DESTDIR)"
	@for script in $(SCRIPTS); do
	@	rm -f $(DESTDIR)/bin/$$script $(DESTDIR)/man/man1/$$script.1
	@done
	@rm -rf $(DESTDIR)/share/doc/$(REPOSITORY_NAME)/

.PHONY: clean
clean:
	@echo "Clean files"
	@rm -f $(REPOSITORY_NAME).tar.gz


