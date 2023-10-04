PWD = $(shell pwd)

.tangle: source.org
	emacs --batch --quick -l org -l ${HOME}/.emacs --eval "(org-babel-tangle-file \"$<\")"
	touch $@


%.json: %.ttl .tangle schema/symbol-context.json
	bin/apache-jena/bin/riot --formatted=JSONLD $< > $@.temp
	bin/ld-cli frame -i file:$(PWD)/$@.temp file:$(PWD)/schema/symbol-context.json -po > $@
	sed -i 's/http:\/\/example\.equinor\.com\/symbol#\(\w\)/sym:\1/g' $@
	sed -i 's/http:\/\/purl.org\/pav\/\(\w\)/pav:\1/g' $@
	rm $@.temp

%.html: %.ttl .tangle
	curl https://shacl-play.sparna.fr/play/doc -F includeDiagram=on -F shapesSource=file -F inputShapeFile=@$< > $@


all: \
	example/example-symbol.json \
	schema/symbol.owl+shacl.html

pages: all
	mkdir -p $@
	cp -u schema/symbol.owl+shacl.html $@/index.html
	cp -u schema/symbol.owl+shacl.ttl $@
	cp -u schema/symbol-context.json $@
