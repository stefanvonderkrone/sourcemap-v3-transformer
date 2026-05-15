STACKTRACE_DIR := stacktraces
STACKTRACE_FILES := $(wildcard $(STACKTRACE_DIR)/*.txt)
STACKTRACE_NAMES := $(basename $(notdir $(STACKTRACE_FILES)))

BIN_DIR := bin
BIN := $(BIN_DIR)/sourcemaps-v3-transformer

PARSE_DEBUG_DIRECT_TARGETS := $(addprefix parse-debug-direct-,$(STACKTRACE_NAMES))
PARSE_DEBUG_STDIN_TARGETS := $(addprefix parse-debug-stdin-,$(STACKTRACE_NAMES))
PARSE_BUILD_DIRECT_TARGETS := $(addprefix parse-build-direct-,$(STACKTRACE_NAMES))
PARSE_BUILD_STDIN_TARGETS := $(addprefix parse-build-stdin-,$(STACKTRACE_NAMES))

.PHONY: run
.PHONY: run-translate
.PHONY: build
.PHONY: rebuild
.PHONY: build-fast
.PHONY: parse-debug-direct
.PHONY: parse-debug-stdin
.PHONY: parse-build-direct
.PHONY: parse-build-stdin
.PHONY: parse-debug
.PHONY: parse-build-all
.PHONY: parse-all
.PHONY: $(PARSE_DEBUG_DIRECT_TARGETS)
.PHONY: $(PARSE_DEBUG_STDIN_TARGETS)
.PHONY: $(PARSE_BUILD_DIRECT_TARGETS)
.PHONY: $(PARSE_BUILD_STDIN_TARGETS)

run:
	odin run .

run-translate:
	odin run . -- translate example.js.map 13 9767

$(BIN_DIR):
	mkdir -p "$(BIN_DIR)"

$(BIN): | $(BIN_DIR)
	odin build . -out:"$(BIN)" -o:aggressive

build: $(BIN)

rebuild:
	rm -rf bin
	$(MAKE) build

build-fast: $(BIN_DIR)
	odin build . -out:"$(BIN)"

bench: rebuild
	odin build benchmark -out:bin/benchmark -o:aggressive
	bin/benchmark

parse-debug-direct: $(PARSE_DEBUG_DIRECT_TARGETS)

parse-debug-stdin: $(PARSE_DEBUG_STDIN_TARGETS)

parse-build-direct: $(PARSE_BUILD_DIRECT_TARGETS)

parse-build-stdin: $(PARSE_BUILD_STDIN_TARGETS)

parse-debug: parse-debug-direct parse-debug-stdin

parse-build-all: parse-build-direct parse-build-stdin

parse-all: parse-debug parse-build-all

define STACKTRACE_TARGETS
parse-debug-direct-$(1):
	odin run . -- parse "$(STACKTRACE_DIR)/$(1).txt"

parse-debug-stdin-$(1):
	cat "$(STACKTRACE_DIR)/$(1).txt" | odin run . -- parse

parse-build-direct-$(1): $(BIN)
	./"$(BIN)" parse "$(STACKTRACE_DIR)/$(1).txt"

parse-build-stdin-$(1): $(BIN)
	cat "$(STACKTRACE_DIR)/$(1).txt" | ./"$(BIN)" parse
endef

$(foreach name,$(STACKTRACE_NAMES),$(eval $(call STACKTRACE_TARGETS,$(name))))
