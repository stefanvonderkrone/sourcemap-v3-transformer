.Phony: run
run:
	odin run .

.Phony: run-translate
run-translate:
	odin run . -- translate example.js.map 13 9767

.Phony: build
build:
	odin build . -o:aggressive

.Phony: build-fast
build-fast:
	odin build .

