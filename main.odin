package smv3t

import "core:encoding/json"
import "core:fmt"
import "core:io"
import "core:os"
import "core:path/filepath"
import "core:slice"
import "core:strconv"
import "core:strings"

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
	case "--help":
		fallthrough
	case "-h":
		fallthrough
	case:
		cmd_print_help(.Help)
	}
}

cmd_print_help :: proc(cmd: Command) {
	bin := os.args[0]
	switch cmd {
	case .Parse:
		fmt.printfln("%s parse - parses a javascript stacktrace to json", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s parse [options] <file>", bin)
	case .Translate:
		fmt.printfln("%s - translate a given javascript stackframe", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s translate <file> <line> <olumn>", bin)
	case .Transform:
		fmt.printfln("%s - transform a javascript stacktrace", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s transform [options] <file>", bin)
	case .Help:
		fmt.printfln("%s is a tool to work with javascript stachtraces", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s command [options]", bin)
		fmt.println("Commands:")
		fmt.println("\tparse")
		fmt.println("\ttranslate")
		fmt.println("\ttransform")
		fmt.println("\thelp")
	}
}

cmd_translate :: proc(args: []string) {
	num_args := len(args)
	if num_args == 0 {
		cmd_print_help(.Translate)
		return
	}

	for arg in args {
		switch (arg) {
		case "-h":
			fallthrough
		case "--help":
			cmd_print_help(.Translate)
			os.exit(0)
		}
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

	source_map, source_map_ok := source_map_read(data)
	defer free_all(context.temp_allocator)
	if !source_map_ok {
		fmt.eprintln("could not read source-map")
		os.exit(1)
	}

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

		json_string, json_error := json.marshal(stack_frame, {use_spaces = true, pretty = true})
		if json_error != nil {
			fmt.eprintfln("failed to convert to json: %v", json_error)
			os.exit(1)
		}
		fmt.printfln("%s", json_string)
	}
}

cmd_parse :: proc(args: []string) {
	input := ""
	version := 1
	for arg in args {
		switch (arg) {
		case "--v2":
			version = 2
		case "--v3":
			version = 3
		case "--help":
			fallthrough
		case "-h":
			cmd_print_help(.Parse)
			os.exit(0)
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
//      maybe we detect urls and use the pathname as the path and we start at the current working dir
// --map localhost=/path/to/assets
cmd_transform :: proc(args: []string) {
	num_args := len(args)
	mappings: map[string]string
	input: Maybe(string)
	i := 0
	use_json := false
	show_context := false
	no_ignore := false
	context_lines_pre := 3
	context_lines_post := 3
	for i < num_args {
		arg := args[i]
		switch (arg) {
		case "-h":
			fallthrough
		case "--help":
			cmd_print_help(.Transform)
			os.exit(0)
		// mapping
		case "-m":
			fallthrough
		case "--mapping":
			if i + 1 >= num_args {
				fmt.eprintfln("no mapping after `--mapping` arg")
				os.exit(1)
			}
			i += 1
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
			i += 1
			input = args[i]
		case "-j":
			fallthrough
		case "--json":
			use_json = true
		case "-c":
			fallthrough
		case "--context":
			show_context = true
		case "-n":
			fallthrough
		case "--no-ignore":
			no_ignore = true
		}
		i += 1
	}
	data, data_error := read_input(input)
	if data_error != nil {
		fmt.eprintfln("could not read input: v%", data_error)
		os.exit(1)
	}
	stack_frames := parse_stack_trace_v3(string(data))
	// file cache for map files
	file_map: map[string]Source_Map_V3
	translated_stack_frames := make([dynamic]Stack_Frame, 0, len(stack_frames), context.allocator)
	sources := make([dynamic]string, 0, len(stack_frames), context.allocator)
	for frame in stack_frames {
		new_path := ""
		// find path from mappings
		for path, replacement in mappings {
			index := strings.index(frame.pathname, path)
			if index > -1 {
				tmp_path := frame.pathname[index + len(path):]
				new_path = strings.join({replacement, tmp_path, ".map"}, "")
				break
			}
		}
		if len(new_path) > 0 {
			// load file
			source_map, source_map_ok := file_map[new_path]
			if !source_map_ok {
				read_bytes, read_error := read_input(new_path)
				if read_error != nil {
					os.exit(1)
				}
				source_map, source_map_ok = source_map_read(read_bytes)
				if !source_map_ok {
					fmt.eprintln("could not read source-map")
				}
				if source_map_ok {
					file_map[new_path] = source_map
				}
			}

			// parse file
			mapping, mapping_ok := translate_mapping(source_map, i32(frame.line), i32(frame.col))
			if mapping_ok {
				// TODO: consider using uints for Mapping struct
				line := uint(mapping.original_line + 1)
				col := uint(mapping.original_column + 1)
				pathname := ""
				name := ""
				source := ""

				if mapping.source_index >= 0 &&
				   int(mapping.source_index) < len(source_map.sources) {
					pathname = source_map.sources[mapping.source_index]
					// TODO: do we need this?
					p, p_error := filepath.clean(
						strings.join({filepath.dir(new_path), "/", pathname}, ""),
						context.allocator,
					)
					if p_error == nil {
						pathname = p
					}
				}
				if mapping.length > 4 &&
				   mapping.name_index >= 0 &&
				   int(mapping.name_index) < len(source_map.names) {
					name = source_map.names[mapping.name_index]
				}
				if mapping.source_index >= 0 &&
				   int(mapping.source_index) < len(source_map.sources_content) {
					source = source_map.sources_content[mapping.source_index]
				}
				// push translation
				if no_ignore ||
				   !slice.contains(source_map.ignore_list, u16(mapping.source_index)) {
					append(&translated_stack_frames, Stack_Frame{line, col, pathname, name})
					append(&sources, source)
				}
			}
		} else {
			fmt.eprintfln("no mapping found for '%s'", frame.pathname)
			if no_ignore {
				append(&translated_stack_frames, frame)
				append(&sources, "")
			}
		}
	}
	if use_json {
		json_string, json_error := json.marshal(
			translated_stack_frames,
			{use_spaces = true, pretty = true},
		)
		if json_error != nil {
			fmt.eprintfln("failed to convert to json: %v", json_error)
			os.exit(1)
		}
		fmt.printfln("%s", json_string)
	} else {
		for frame, index in translated_stack_frames {
			source := sources[index]
			fmt.printf("    at ")
			if frame.name != "" {
				fmt.printf("%s (", frame.name)
			}
			if frame.pathname != "" {
				fmt.printf("%s:", frame.pathname)
			}
			fmt.printf("%i:%i", frame.line, frame.col)
			if frame.name != "" {
				fmt.print(")")
			}
			fmt.print("\n")
			// TODO: show context only for first stack frame OR use ignoreList to skip context for ignored sources
			if show_context && len(source) > 0 {
				lines := strings.split(source, "\n")
				num_lines := len(lines)
				line := int(frame.line) - 1
				col := int(frame.col) - 1
				width := len(fmt.aprintf("%d", line + context_lines_post))
				for i = line - context_lines_pre; i <= line + context_lines_post; i += 1 {
					if i < 0 || i >= num_lines {
						continue
					}
					fmt.printfln("% *d: %s", width, i + 1, lines[i])
					if i == int(line) {
						fmt.printfln(
							"%s^",
							strings.repeat(" ", col + width + 2, context.allocator),
						)
					}
				}
				fmt.printfln("")
			}
		}
	}
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
