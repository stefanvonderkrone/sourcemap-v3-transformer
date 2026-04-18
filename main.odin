package smv3t

import "core:bufio"
import "core:encoding/json"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

main :: proc() {
	num_args := len(os.args)
	command := num_args > 1 ? os.args[1] : "help"
	switch command {
	case "parse":
		cmd_parse(os.args[2:])
	case "translate":
		cmd_translate(os.args[2:])
	case "help":
		fallthrough
	case:
		cmd_print_help(.Help)
	}
}

cmd_print_help :: proc(cmd: Command) {
	switch cmd {
	case .Parse:
		fmt.println("print help parse")
	case .Translate:
		fmt.println("print help translate")
	case .Help:
		fmt.println("print help")
	}
}

cmd_translate :: proc(args: []string) {
	num_args := len(args)
	if num_args == 0 {
		cmd_print_help(.Translate)
		return
	}

	file_name := args[0]
	line: i32 = 0
	column: i32 = 0

	if num_args > 1 {
		if l, ok := strconv.parse_int(args[1]); ok {
			line = i32(l)
		}
	}

	if num_args > 2 {
		if c, ok := strconv.parse_int(args[2]); ok {
			column = i32(c)
		}
	}

	data, file_error := os.read_entire_file_from_path(file_name, context.temp_allocator)
	if file_error != nil {
		fmt.eprintfln("%e", file_error)
		return
	}

	source_map: Source_Map_V3
	json_read_sourcemap(data, &source_map)
	free_all(context.temp_allocator)

	mapping, ok := translate_mapping(source_map, line, column)
	if ok {
		fmt.printfln("original_line: %i", mapping.original_line + 1)
		fmt.printfln("original_column: %i", mapping.original_column + 1)
		if mapping.source_index >= 0 && int(mapping.source_index) < len(source_map.sources) {
			fmt.printfln("original_file: %s", source_map.sources[mapping.source_index])
		}
		if mapping.length > 4 &&
		   mapping.name_index >= 0 &&
		   int(mapping.name_index) < len(source_map.names) {
			fmt.printfln("original_name: %s", source_map.names[mapping.name_index])
		}
	}
}

cmd_parse :: proc(args: []string) {
	num_args := len(args)
	handle := os.stdin
	if num_args > 0 {
		file_name := args[0]
		h, h_error := os.open(file_name)
		if h_error != nil {
			fmt.eprintfln("%e", h_error)
			return
		}
		handle = h
	}
	// TODO: make it more flexible
	buffer: [4096]byte
	n, read_error := os.read(handle, buffer[:])
	if read_error != nil {
		fmt.eprintfln("%e", read_error)
	}
	if n == 0 {
		return
	}
	contents := string(buffer[:n])

	stack_traces := parse_stack_trace(string(contents))
	json_out, json_error := json.marshal(stack_traces)
	if json_error != nil {
		fmt.eprintfln("%e", json_error)
	}
	fmt.printfln("%s", json_out)
}

Command :: enum {
	Help,
	Translate,
	Parse,
}
