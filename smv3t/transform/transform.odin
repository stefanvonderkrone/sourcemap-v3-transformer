package transform

import h "../help"
import io "../io"
import m "../mapping"
import st "../stack_trace"
import stv3 "../stack_trace/v3"
import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:slice"
import "core:strings"

// --map *=/path/to/assets (how-to this?)
//      maybe we detect urls and use the pathname as the path and we start at the current working dir
// --map localhost=/path/to/assets
transform :: proc(args: []string) {
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
			h.print_help(.Transform)
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
	data, data_error := io.read_input(input)
	if data_error != nil {
		fmt.eprintfln("could not read input: v%", data_error)
		os.exit(1)
	}
	stack_frames := stv3.parse_stack_trace_v3(string(data))
	// file cache for map files
	file_map: map[string]m.Source_Map_V3
	translated_stack_frames := make(
		[dynamic]st.Stack_Frame,
		0,
		len(stack_frames),
		context.allocator,
	)
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
				read_bytes, read_error := io.read_input(new_path)
				if read_error != nil {
					os.exit(1)
				}
				source_map, source_map_ok = m.source_map_read(read_bytes)
				if !source_map_ok {
					fmt.eprintln("could not read source-map")
				}
				if source_map_ok {
					file_map[new_path] = source_map
				}
			}

			// parse file
			mapping, mapping_ok := m.translate_mapping(source_map, i32(frame.line), i32(frame.col))
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
					append(&translated_stack_frames, st.Stack_Frame{line, col, pathname, name})
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
@(private)
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
