
DATASOURCE = ../data/

%.train.wordcounts.txt: $(DATASOURCE)/%.word.train.tsv
	cat $< | cut -f 1 | sort | sed 's/^/1 /' > $@

%.dev.words.txt: $(DATASOURCE)/%.word.dev.tsv
	cat $< | cut -f 1 | sort > $@

%.dev.seg.txt: $(DATASOURCE)/%.word.dev.tsv
	cat $< | cut -f 1,2 | sort | sed 's/ @@/ /g' > $@

%.baseline.bin: %.train.words.txt
	morfessor-train -s $@ --traindata-list --skips -w 1.0 $<

%.baseline.dev.txt: %.baseline.bin %.dev.words.txt
	morfessor-segment -l $(word 1,$^) --output-format "{compound}\t{analysis}\n" -o $@ $(word 2,$^)
