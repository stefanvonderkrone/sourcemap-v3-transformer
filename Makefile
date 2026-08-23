BIN_DIR := bin
BINARY := sourcemaps-v3-transformer
BIN := $(BIN_DIR)/$(BINARY)
ODIN_PACKAGES := $(shell find ./smv3t -type f -name '*.odin')

$(BIN): $(ODIN_PACKAGES)
	odin build ./smv3t -vet -o:aggressive -out:$(BIN)

.PHONY: clean
clean:
	rm $(BIN)

fast: *.odin
	odin build ./smv3t -vet -out:$(BIN)

.PHONY: test
test:
	odin test ./smv3t -all-packages
