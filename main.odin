package smv3t

import "core:bufio"
import "core:encoding/json"
import "core:fmt"
import "core:io"
import vmem "core:mem/virtual"
import "core:os"
import "core:path/filepath"
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
	case "transform":
		cmd_transform(os.args[2:])
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
	case .Transform:
		fmt.println("print help transform")
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

	data, read_error := read_input(file_name)
	if read_error != nil {
		fmt.eprintfln("could not read input: %e", read_error)
		return
	}

	source_map: Source_Map_V3
	json_read_sourcemap(data, &source_map)
	free_all(context.temp_allocator)

	mapping, ok := translate_mapping(source_map, line, column)
	if ok {
		stack_frame: Stack_Frame
		// TODO: consider using uints for Mapping struct
		stack_frame.line = uint(mapping.original_line + 1)
		stack_frame.col = uint(mapping.original_column + 1)

		if mapping.source_index >= 0 && int(mapping.source_index) < len(source_map.sources) {
			stack_frame.pathname = source_map.sources[mapping.source_index]
		}
		if mapping.length > 4 &&
		   mapping.name_index >= 0 &&
		   int(mapping.name_index) < len(source_map.names) {
			stack_frame.name = source_map.names[mapping.name_index]
		}

		json_string, ok := json.marshal(stack_frame, {use_spaces = true, pretty = true})
		fmt.printfln("%s", json_string)
	}
}

cmd_parse :: proc(args: []string) {
	num_args := len(args)
	input := ""
	version := 1
	for arg in args {
		switch (arg) {
		case "--v2":
			version = 2
		case "--v3":
			version = 3
		case:
			input = arg
		}
	}
	data, read_error := read_input(input != "" ? input : nil)
	if read_error != nil {
		fmt.eprintfln("could not read input: %v", read_error)
		os.exit(1)
	}

	stack_frames: []Stack_Frame = ---
	switch (version) {
	case 1:
		stack_frames = parse_stack_trace(string(data))
	case 2:
		stack_frames = parse_stack_trace_v2(string(data))
	case 3:
		stack_frames = parse_stack_trace_v3(string(data))
	}
	json_out, json_error := json.marshal(stack_frames, {use_spaces = true, pretty = true})
	if json_error != nil {
		fmt.eprintfln("could not parse json: %e", json_error)
		os.exit(1)
	}
	fmt.printfln("%s", json_out)
}

// --map *=/path/to/assets (how-to this?)
// --map localhost=/path/to/assets
cmd_transform :: proc(args: []string) {
	num_args := len(args)
	mappings: map[string]string
	input: Maybe(string)
	i := 0
	for i < num_args {
		arg := args[i]
		switch (arg) {
		// mapping
		case "-m":
			fallthrough
		case "--mapping":
			if i + 1 >= num_args {
				fmt.eprintfln("no mapping after `--mapping` arg")
				os.exit(1)
			}
			i = i + 1
			mapping := args[i]
			key, value, ok := parse_key_value(mapping)
			if !ok {
				fmt.eprintfln("invalid mapping '%s'", mapping)
				os.exit(1)
			}
			mappings[key] = value
		// input
		case "-i":
			fallthrough
		case "--input":
			if i + 1 >= num_args {
				fmt.eprintfln("no input after `--input` arg")
				os.exit(1)
			}
			i = i + 1
			input = args[i]
		}
		i = i + 1
	}
	fmt.printfln("mappings = %v", mappings)
	data, read_error := read_input(input)
	if read_error != nil {
		fmt.eprintfln("could not read input: v%", read_error)
		os.exit(1)
	}
	stack_frames := parse_stack_trace_v3(string(data))
	file_map: map[string]Source_Map_V3
	translated_stack_frames := make([dynamic]Stack_Frame, 0, len(stack_frames), context.allocator)
	for frame in stack_frames {
		for path, replacement in mappings {
			index := strings.index(frame.pathname, path)
			// fmt.printfln("pathname = %s", frame.pathname)
			// fmt.printfln("path = %s", path)
			// fmt.printfln("index = %i", index)
			if index > -1 {
				tmp_path := frame.pathname[index + len(path):]
				new_path := strings.join({replacement, tmp_path, ".map"}, "")
				fmt.printfln("new_path=%s", new_path)

				// load file
				source_map, source_map_ok := file_map[new_path]
				if !source_map_ok {
					data, read_error := read_input(new_path)
					if read_error != nil {
						fmt.eprintfln("could not read input: %e", read_error)
						return
					}
					json_read_sourcemap(data, &source_map)
					file_map[new_path] = source_map
				}

				// parse file
				// push translation
				mapping, mapping_ok := translate_mapping(
					source_map,
					i32(frame.line),
					i32(frame.col),
				)
				if mapping_ok {
					stack_frame: Stack_Frame
					// TODO: consider using uints for Mapping struct
					line := uint(mapping.original_line + 1)
					col := uint(mapping.original_column + 1)
					pathname := ""
					name := ""

					if mapping.source_index >= 0 &&
					   int(mapping.source_index) < len(source_map.sources) {
						pathname = source_map.sources[mapping.source_index]
					}
					if mapping.length > 4 &&
					   mapping.name_index >= 0 &&
					   int(mapping.name_index) < len(source_map.names) {
						name = source_map.names[mapping.name_index]
					}
					append(&translated_stack_frames, Stack_Frame{line, col, pathname, name})
				}

				break
			}
		}
	}
	json_string, error := json.marshal(translated_stack_frames, {use_spaces = true, pretty = true})
	fmt.printfln("%s", json_string)

}

// TODO: validation (only one =, security, etc)
parse_key_value :: proc(s: string) -> (key: string, value: string, ok: bool) {
	key = {}
	value = {}
	ok = false
	num_chars := len(s)
	for i in 0 ..< num_chars {
		char := s[i]
		if char == '=' {
			key = s[:i]
			value = s[i + 1:]
			ok = true
			return
		}
	}
	return
}

read_input :: proc(path: Maybe(string), allocator := context.allocator) -> ([]byte, os.Error) {
	handle := os.stdin
	if path != nil {
		h, h_error := os.open(path.?)
		if h_error != nil {
			fmt.eprintfln("could not open file: %v", h_error)
			return {}, h_error
		}
		handle = h
	}
	defer if handle != os.stdin {os.close(handle)}

	BUFFER_SIZE :: 4096
	buffer := make([dynamic]byte, 0, BUFFER_SIZE, allocator)
	chunk: [BUFFER_SIZE]byte

	for {
		n, read_error := os.read(handle, chunk[:])
		if read_error != nil && read_error != io.Error.EOF {
			fmt.eprintfln("could not read handle: %v", read_error)
			return {}, read_error
		}
		if n == 0 {break}
		append(&buffer, ..chunk[:n])
	}
	return buffer[:], nil
}

Command :: enum {
	Help,
	Translate,
	Parse,
	Transform,
}
