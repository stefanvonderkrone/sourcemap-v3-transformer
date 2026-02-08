.Phony: run

run:
	odin run .

build:
	odin build . -o:aggressive

build-fast:
	odin build .

