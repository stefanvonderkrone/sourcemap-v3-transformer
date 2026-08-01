BIN_DIR := bin
BINARY := sourcemaps-v3-transformer
BIN := $(BIN_DIR)/$(BINARY)
ODIN_PACKAGES := $(shell find . -type f -name '*.odin')

$(BIN): $(ODIN_PACKAGES)
	odin build . -vet -o:aggressive -out:$(BIN)

.PHONY: clean
clean:
	rm $(BIN)

fast: *.odin
	odin build . -out:$(BIN)

.PHONY: test
test:
	odin test . -all-packages
