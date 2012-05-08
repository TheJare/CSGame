# Somewhat overengineered Makefile. Damn I'm rusty with this stuff

SRCDIR = src
STATIC_FILES = index.html
SOURCE_FILES = \
	utils.coffee \
	vec2.coffee \
	gameobject.coffee \
	game.coffee

OUTDIR = bin
OUTFILE = $(OUTDIR)/all.min.js
TEMPDIR = lib
TEMPFILE = $(TEMPDIR)/all.js

build: $(OUTFILE) $(addprefix $(OUTDIR)/, $(STATIC_FILES))

clean:
	rm -r $(OUTDIR)
	rm -r $(TEMPDIR)

$(addprefix $(OUTDIR)/, $(STATIC_FILES)): $(addprefix $(SRCDIR)/, $(STATIC_FILES))
	@mkdir -p $(OUTDIR)
	cp $(addprefix $(SRCDIR)/, $(STATIC_FILES)) $(addprefix $(OUTDIR)/, $(STATIC_FILES))

$(OUTFILE): $(TEMPFILE)
	@mkdir -p $(OUTDIR)
	#cp $< $@
	uglifyjs $< > $@

$(TEMPDIR)/%.js: $(SRCDIR)/%.coffee
	@mkdir -p $(TEMPDIR)
	coffee -c -o $(TEMPDIR) $<

$(TEMPFILE): $(addprefix $(TEMPDIR)/, $(addsuffix .js, $(basename $(SOURCE_FILES))))
	cat $(addprefix $(TEMPDIR)/, $(addsuffix .js, $(basename $(SOURCE_FILES)))) > $(TEMPFILE)

.PHONY: build clean
