BIN_DIR := bin
BINARY := sourcemaps-v3-transformer
BIN := $(BIN_DIR)/$(BINARY)

$(BIN): *.odin
	odin build . -vet -o:aggressive -out:$(BIN)

.PHONY: clean
clean:
	rm $(BIN)

fast: *.odin
	odin build . -out:$(BIN)
