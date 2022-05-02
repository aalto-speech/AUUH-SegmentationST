
#LONGCODES = eng ces fra hun spa ita lat rus mon
LONGCODES = eng ces mon
DATASOURCE = ../data
WIKIDATASOURCE = ../wikidata

WORDCOUNTS = $(addsuffix .combined.wordcounts.txt,$(LONGCODES))
DEV_WORDS = $(addsuffix .dev.words.txt,$(LONGCODES))
DEV_SEGS = $(addsuffix .dev.seg.txt,$(LONGCODES))
TUNINGS = $(addsuffix _tuning.done,$(LONGCODES))
BEST_MODELS = $(addsuffix _best_flatcat.bin,$(LONGCODES))
PRESEGMENTED_TSVS = $(addsuffix _best_flatcat.dev.tsv,$(LONGCODES)) $(addsuffix _best_flatcat.train.tsv,$(LONGCODES))

datasets: $(WORDCOUNTS) $(DEV_WORDS) $(DEV_SEGS)
tunings: $(TUNINGS)
best_models: $(BEST_MODELS)
presegmented_tsvs: $(PRESEGMENTED_TSVS)

# Combined word counts (training sentences + words + wiki)
%.combined.wordcounts.txt:
	cp -i ../morfessor/$@ $@

# Development data for tuning Morfessor parameters
# NOTE: Some words in the Latin set have spaces 

%.dev.words.txt: $(DATASOURCE)/%.word.dev.tsv
	cp -i ../morfessor/$@ $@

%.dev.seg.txt: $(DATASOURCE)/%.word.dev.tsv
	cp -i ../morfessor/$@ $@

# Morfessor Flatcat training

%_tuning: %.combined.wordcounts.txt %.dev.words.txt %.dev.seg.txt
	mkdir -p $@
	test -f $@/combined.wordcounts.txt || ln -s ../$*.combined.wordcounts.txt $@/combined.wordcounts.txt
	test -f $@/dev.words.txt || ln -s ../$*.dev.words.txt $@/dev.words.txt
	test -f $@/dev.seg.txt || ln -s ../$*.dev.seg.txt $@/dev.seg.txt
	test -f $@/Makefile || ln -s ../tuning-Makefile $@/Makefile
	test -f $@/best_baseline.gz || ln -s ../$*_best_baseline.gz $@/best_baseline.gz

%_tuning.done: %_tuning
	$(MAKE) -C $*_tuning all
	touch $@

%_best_flatcat.name: %_tuning.done
	for x in $*_tuning/*.yaml; do cat $$x; echo "---"; done | head -n -1 | yq . -s | jq 'sort_by(.scores."f-score")[-1].files.predictions' -r > $@

%_best_flatcat.bin: %_best_flatcat.name
	test -f $@ || ln -s $*_tuning/`cat $< | sed 's/dev\.txt/bin/'` $@

%_best_flatcat.train.txt: %_best_flatcat.bin $(DATASOURCE)/%.word.train.tsv
	cat $(word 2,$^) | cut -f 1 | morfessor-segment -l $(word 1,$^) --output-format "{analysis}" --output-format-separator "⁙" --output-newlines -o $@ -

%_best_flatcat.train.tsv: %_best_flatcat.train.txt $(DATASOURCE)/%.word.train.tsv
	cat $(word 2,$^) | cut -f 2- | paste $(word 1,$^) - > $@

%_best_flatcat.dev.txt: %_best_flatcat.bin $(DATASOURCE)/%.word.dev.tsv
	cat $(word 2,$^) | cut -f 1 | morfessor-segment -l $(word 1,$^) --output-format "{analysis}" --output-format-separator "⁙" --output-newlines -o $@ -

%_best_flatcat.dev.tsv: %_best_flatcat.dev.txt $(DATASOURCE)/%.word.dev.tsv
	cat $(word 2,$^) | cut -f 2- | paste $(word 1,$^) - > $@
