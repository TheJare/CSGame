# Somewhat overengineered Makefile. Damn I'm rusty with this stuff

SRCDIR = src
TEMPDIR = obj
OUTDIR = bin

STATIC_FILES = index.html
SOURCE_FILES = \
	utils.coffee \
	vec2.coffee \
	gameobject.coffee \
	ui.coffee \
	game.coffee

COFFEEFILES = $(addprefix $(SRCDIR)/, $(addsuffix .coffee, $(basename $(SOURCE_FILES))))
JSFILES = $(addprefix $(TEMPDIR)/, $(addsuffix .js, $(basename $(SOURCE_FILES))))
OUTJSFILE = $(OUTDIR)/all.min.js

RELEASE_BUILD =

build: $(OUTJSFILE) $(addprefix $(OUTDIR)/, $(STATIC_FILES))

release: RELEASE_BUILD = 1
release: clean build

clean:
	rm -rf $(OUTDIR)
	rm -rf $(TEMPDIR)

watch:
	while true; do make --no-print-directory | grep -v "Nothing to be done for"; sleep 1; done 

$(addprefix $(OUTDIR)/, $(STATIC_FILES)): $(addprefix $(SRCDIR)/, $(STATIC_FILES))
	@mkdir -p $(OUTDIR)
	cp $^ $(OUTDIR)/

$(OUTJSFILE): $(COFFEEFILES)
	@mkdir -p $(OUTDIR)
	@# Compile only changed coffee files
	coffee -c -o $(TEMPDIR) $?
	@# Concat all JS files
	cat $(JSFILES) $(if $(RELEASE_BUILD), | uglifyjs) > $@

.PHONY: build clean release watch
