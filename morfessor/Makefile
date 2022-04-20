
# LONGCODES = ces eng fra hun spa ita lat rus mon
LONGCODES = lat mon
DATASOURCE = ../data
WIKIDATASOURCE = ../wikidata

WORDCOUNTS = $(addsuffix .train.wordcounts.txt,$(LONGCODES)) $(addsuffix .combined.wordcounts.txt,$(LONGCODES))
DEV_WORDS = $(addsuffix .dev.words.txt,$(LONGCODES))
DEV_SEGS = $(addsuffix .dev.seg.txt,$(LONGCODES))

datasets: $(WORDCOUNTS) $(DEV_WORDS) $(DEV_SEGS)

# Training data sentences
%.sentence.train.txt: $(DATASOURCE)/%.sentence.train.tsv
	cat $< | cut -f 1 > $@

# Training data sentence wordcounts
mon.sentence.train.wordcounts.txt: \
%.sentence.train.wordcounts.txt: %.sentence.train.txt
	python ../src/extract_word_counts.py -s Cyrillic $< $@

%.sentence.train.wordcounts.txt: %.sentence.train.txt
	python ../src/extract_word_counts.py -s Latin $< $@

# Training data words (with count 1)
# NOTE: Some Latin words in the list have spaces 
%.train.wordcounts.txt: $(DATASOURCE)/%.word.train.tsv
	cat $< | cut -f 1 | tr -d ' ' | sort | sed 's/^/1 /' > $@

# Words from Wikipedia
%.wiki.wordcounts.txt: $(WIKIDATASOURCE)/%_wordcounts.txt
	python ../src/join_word_counts.py --max-length 40 --min-count 2 --lowercase $< $@

# Combined word counts (training sentences + words + wiki)
ces.combined.wordcounts.txt eng.combined.wordcounts.txt mon.combined.wordcounts.txt: \
%.combined.wordcounts.txt: %.sentence.train.wordcounts.txt %.train.wordcounts.txt %.wiki.wordcounts.txt
	python ../src/join_word_counts.py $^ $@

%.combined.wordcounts.txt: %.train.wordcounts.txt %.wiki.wordcounts.txt
	python ../src/join_word_counts.py $^ $@

# Development data for tuning Morfessor parameters
# NOTE: Some words in the Latin set have spaces 

%.dev.words.txt: $(DATASOURCE)/%.word.dev.tsv
	cat $< | cut -f 1 | tr -d ' ' > $@

%.dev.seg.txt: $(DATASOURCE)/%.word.dev.tsv
	cat $< | cut -f 1,2 | sed 's/ \([^@]\)/\1/g' | sed 's/ @@/ /g' > $@

# Morfessor Baseline training

%_tuning: %.combined.wordcounts.txt %.dev.words.txt %.dev.seg.txt
	mkdir -p $@
	test -f $@/combined.wordcounts.txt || ln -s ../$*.combined.wordcounts.txt $@/combined.wordcounts.txt
	test -f $@/dev.words.txt || ln -s ../$*.dev.words.txt $@/dev.words.txt
	test -f $@/dev.seg.txt || ln -s ../$*.dev.seg.txt $@/dev.seg.txt
	test -f $@/Makefile || ln -s ../tuning-Makefile $@/Makefile

%_tuning.done: %_tuning
	$(MAKE) -C $*_tuning all
	touch $@

# %.baseline.bin: %.combined.wordcounts.txt
# 	morfessor-train -s $@ --traindata-list --skips -w 1.0 $<

# %.baseline.dev.txt: %.baseline.bin %.dev.words.txt
# 	morfessor-segment -l $(word 1,$^) --output-format "{compound}\t{analysis}\n" -o $@ $(word 2,$^)
