# Somewhat overengineered Makefile. Damn I'm rusty with this stuff

SRCDIR = src
STATIC_FILES = index.html
SOURCE_FILES = \
	utils.coffee \
	vec2.coffee \
	gameobject.coffee \
	game.coffee
	

OUTDIR = bin
OUTJSFILE = $(OUTDIR)/all.min.js
TEMPDIR = obj
TEMPJSFILE = $(TEMPDIR)/all.js

RELEASE_BUILD=

build: $(OUTJSFILE) $(addprefix $(OUTDIR)/, $(STATIC_FILES))

release: RELEASE_BUILD=1
release: clean build

clean:
	rm -r $(OUTDIR)
	rm -r $(TEMPDIR)

watch:
	while true; do make --no-print-directory | grep -v "Nothing to be done for"; sleep 1; done 

$(addprefix $(OUTDIR)/, $(STATIC_FILES)): $(addprefix $(SRCDIR)/, $(STATIC_FILES))
	@mkdir -p $(OUTDIR)
	cp $^ $(OUTDIR)/

$(OUTJSFILE): $(TEMPJSFILE)
	@mkdir -p $(OUTDIR)
	$(if $(RELEASE_BUILD), \
		uglifyjs $< > $@, \
		cp $< $@ \
	)

$(TEMPDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p $(TEMPDIR)
	coffee -c -o $(TEMPDIR) $<

$(TEMPJSFILE): $(addprefix $(TEMPDIR)/, $(addsuffix .js, $(basename $(SOURCE_FILES))))
	cat $^ > $@

.PHONY: build clean release watch

