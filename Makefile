BIN_DIR := bin
BIN := $(BIN_DIR)/sourcemaps-v3-transformer

main: *.odin
	odin build . -o:aggressive -out:$(BIN)

fast: *.odin
	odin build . -out:$(BIN)
