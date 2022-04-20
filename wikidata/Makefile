# ces: Czech     - cs
# eng: English   - en
# fra: French    - fr
# hun: Hungarian - hu
# spa: Spanish   - es
# ita: Italian   - it
# lat: Latin     - la
# rus: Russian   - ru
# mon: Mongolian - mn

SHORTCODES = cs en fr hu es it la ru mn
LONGCODES = ces eng fra hun spa ita lat rus mon

ARTICLES = $(addsuffix wiki-20220401-pages-articles.xml.bz2,$(SHORTCODES))
EXTRACTED = $(addsuffix _text,$(LONGCODES))
RAWTEXT = $(addsuffix _text.raw.gz,$(LONGCODES))
WORDCOUNTS = $(addsuffix _wordcounts.txt,$(LONGCODES))

.PHONY: articles extracted
articles: $(ARTICLES)
extracted: $(EXTRACTED)


%wiki-20220401-pages-articles.xml.bz2:
	wget https://ftp.acc.umu.se/mirror/wikimedia.org/dumps/$*wiki/20220401/$*wiki-20220401-pages-articles.xml.bz2


# required: pip install wikiextractor

ces_text: cswiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

eng_text: enwiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

fra_text: frwiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

hun_text: huwiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

spa_text: eswiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

ita_text: itwiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

lat_text: lawiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

rus_text: ruwiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

mon_text: mnwiki-20220401-pages-articles.xml.bz2
	python -m wikiextractor.WikiExtractor $< --json -o $@

%_text.raw.gz: %_text
	cat $</*/wiki_* | jq .text -r | gzip > $@

mon_wordcounts.txt: mon_text.raw.gz
	python ../src/extract_word_counts.py -s Cyrillic $< $@

rus_wordcounts.txt: rus_text.raw.gz
	python ../src/extract_word_counts.py -s Cyrillic $< $@

%_wordcounts.txt: %_text.raw.gz
	python ../src/extract_word_counts.py -s Latin $< $@
