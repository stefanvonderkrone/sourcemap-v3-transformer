package mapping

import h "../help"
import io "../io"
import st "../stack_trace"
import "core:encoding/json"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

translate :: proc(args: []string) {
	num_args := len(args)
	if num_args == 0 {
		h.print_help(.Translate)
		return
	}

	for arg in args {
		switch (arg) {
		case "-h":
			fallthrough
		case "--help":
			h.print_help(.Translate)
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

	data, read_error := io.read_input(file_name)
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
		stack_frame: st.Stack_Frame
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


Source_Map_V3 :: struct {
	version:         u8, // mandatory
	file:            string, // optional
	mappings:        []Mapping_Line, // mandatory
	source_root:     string, // optional
	ignore_list:     []u16, // optional
	names:           []string, // optional
	sources:         []string, // mandatory
	sources_content: []string, // optional
}

Mapping_Line :: struct {
	mappings: []Mapping,
}

Mapping :: struct {
	length:           i32,
	generated_column: i32,
	source_index:     i32,
	original_line:    i32,
	original_column:  i32,
	name_index:       i32,
}

translate_mapping :: proc(source_map: Source_Map_V3, line: i32, col: i32) -> (^Mapping, bool) {
	generated_line := line - 1
	generated_column := col - 1

	num_mapping_lines := i32(len(source_map.mappings))
	if generated_line < 0 || generated_line >= num_mapping_lines {
		fmt.printfln("line out of range: %i. Got %i", line, num_mapping_lines)
		return nil, false
	}

	mapping_line := source_map.mappings[generated_line]

	if len(mapping_line.mappings) == 0 {
		fmt.printfln("empty mapping_line: %i", line)
		return nil, false
	}

	mapping := &mapping_line.mappings[0]
	for _, index in mapping_line.mappings {
		#no_bounds_check {
			m := &mapping_line.mappings[index]
			if m.generated_column <= generated_column {
				mapping = m
			} else {
				break
			}
		}
	}

	return mapping, true
}


// TODO: write tests
source_map_read :: proc(data: []u8, allocator := context.allocator) -> (Source_Map_V3, bool) {
	value, json_error := json.parse(data, parse_integers = true, allocator = allocator)

	if json_error != nil {
		fmt.eprintfln("%e", json_error)
		return {}, false
	}

	object, object_ok := value.(json.Object)
	if !object_ok {
		fmt.eprintfln("Null not an object", value)
		return {}, false
	}

	source_map: Source_Map_V3

	// version
	{
		version, version_ok := json_object_get_prop(object, "version", json.Integer)
		if !version_ok {
			fmt.eprintfln("version Null or not an Integer")
			return {}, false
		}
		if version != 3 {
			fmt.eprintfln("version %i not supported", version)
			return {}, false
		}
		source_map.version = 3
	}

	// file (optional)
	{
		file, file_ok := json_object_get_prop(object, "file", json.String)
		if file_ok {
			source_map.file = file
		}
	}

	// sourceRoot (optional)
	{
		source_root, source_root_ok := json_object_get_prop(object, "sourceRoot", json.String)
		if source_root_ok {
			source_map.source_root = source_root
		}
	}

	// mappings
	{
		mappings, mappings_ok := json_object_get_prop(object, "mappings", json.String)
		if !mappings_ok {
			fmt.eprintfln("mappings Null or not a string")
			return {}, false
		}
		decoded_mappings := mappings_decode(mappings, allocator)
		source_map.mappings = decoded_mappings
	}

	// ingoreList (optional)
	{
		list: json.Array
		list_ok := false
		ignore_list, ignore_list_ok := json_object_get_prop(object, "ignoreList", json.Array)
		if ignore_list_ok {
			list = ignore_list
			list_ok = true
		} else {
			ignore_list, ignore_list_ok = json_object_get_prop(
				object,
				"x_google_ignoreList",
				json.Array,
			)
			if ignore_list_ok {
				list = ignore_list
				list_ok = true
			}
		}

		if list_ok {
			ignore_list := make([dynamic]u16, 0, len(list), allocator)
			for val in list {
				int, ok := val.(json.Integer)
				if ok && int >= 0 && int < 1 << 16 {
					append(&ignore_list, u16(int))
				}
			}
			source_map.ignore_list = ignore_list[:]
		}
	}

	// names (optional)
	{
		names, names_ok := json_object_get_prop(object, "names", json.Array)
		if names_ok {
			names_list := json_string_array(names, allocator)
			source_map.names = names_list[:]
		}
	}


	// sources
	{
		sources, sources_ok := json_object_get_prop(object, "sources", json.Array)
		if !sources_ok {
			fmt.eprintfln("sources Null or not an Array")
			return {}, false
		}
		sources_list := json_string_array(sources, allocator)
		source_map.sources = sources_list[:]
	}

	// sourcesContent
	{
		content, content_ok := json_object_get_prop(object, "sourcesContent", json.Array)
		if !content_ok {
			fmt.eprintfln("sourcesContent Null or not an Array")
			return {}, false
		}
		content_list := json_string_array(content, allocator)
		source_map.sources_content = content_list[:]
	}

	return source_map, true
}

json_string_array :: proc(array: json.Array, allocator := context.allocator) -> []string {
	copy := make([dynamic]string, 0, len(array), allocator)
	for item in array {
		string, ok := item.(json.String)
		if ok {
			append(&copy, string)
		}
	}
	return copy[:]
}

json_object_get_prop :: proc(object: json.Object, key: string, $T: typeid) -> (T, bool) {
	val, val_ok := object[key]
	if !val_ok {
		return T{}, false
	}

	type, type_ok := val.(T)
	if !type_ok {
		return T{}, false
	}

	return type, true
}

// mappings is a string of bas64 vlq strings that encode a list of integers
// the strings are separated by `;` for each file and by `,` for each offset into a file
// so in the end we have a three dimensional list of integers
mappings_decode :: proc(mappings: string, allocator := context.allocator) -> []Mapping_Line {
	arena: vmem.Arena
	arena_allocator := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	lines := strings.split(mappings, ";", arena_allocator)
	num_lines := len(lines)
	result := make([dynamic]Mapping_Line, num_lines, num_lines, allocator)

	generated_column: i32
	source_index: i32
	original_line: i32
	original_column: i32
	names_index: i32

	for line, line_index in lines {
		generated_column = 0
		segments := strings.split(line, ",", arena_allocator)
		num_segments := len(segments)
		mapping_line := result[line_index]
		decoded_segments := make([dynamic]Mapping, num_segments, num_segments, allocator)

		if len(segments) > 0 {
			for segment, index in segments {
				values := vlq_decode(segment, arena_allocator)
				num_values := len(values)

				if num_values >= 1 {
					generated_column += values[0]
				}

				if num_values >= 4 {
					source_index += values[1]
					original_line += values[2]
					original_column += values[3]
				}

				if num_values == 5 {
					names_index += values[4]
				}

				decoded_mapping := decoded_segments[index]
				decoded_mapping.length = i32(num_values)
				if num_values >= 1 {
					decoded_mapping.generated_column = generated_column
				}

				if num_values >= 4 {
					decoded_mapping.source_index = source_index
					decoded_mapping.original_line = original_line
					decoded_mapping.original_column = original_column
				}

				if num_values == 5 {
					decoded_mapping.name_index = names_index
				}

				decoded_segments[index] = decoded_mapping
			}
		}

		mapping_line.mappings = decoded_segments[:]
		result[line_index] = mapping_line
	}

	return result[:]
}

vlq_decode :: proc(str: string, allocator := context.allocator) -> []i32 {
	result := make([dynamic]i32, 0, 5, allocator)

	shift: uint = 0
	value: i32 = 0

	for char in str {
		integer := char_to_integer(char)

		if integer > 64 {
			fmt.printfln("invalid char: %s", char)
			break
		}

		has_continuation_bit := (integer & 32) != 0

		integer &= 31
		value += integer << shift

		if has_continuation_bit {
			shift += 5
		} else {
			should_negate := (value & 1) != 0
			value = unsigned_right_shift32(value, 1)

			if should_negate {
				append(&result, value == 0 ? -0x80000000 : -value)
			} else {
				append(&result, value)
			}

			shift = 0
			value = 0
		}
	}

	return result[:]
}

char_to_integer :: proc(char: rune) -> i32 {
	switch char {
	case 'A':
		return 0
	case 'B':
		return 1
	case 'C':
		return 2
	case 'D':
		return 3
	case 'E':
		return 4
	case 'F':
		return 5
	case 'G':
		return 6
	case 'H':
		return 7
	case 'I':
		return 8
	case 'J':
		return 9
	case 'K':
		return 10
	case 'L':
		return 11
	case 'M':
		return 12
	case 'N':
		return 13
	case 'O':
		return 14
	case 'P':
		return 15
	case 'Q':
		return 16
	case 'R':
		return 17
	case 'S':
		return 18
	case 'T':
		return 19
	case 'U':
		return 20
	case 'V':
		return 21
	case 'W':
		return 22
	case 'X':
		return 23
	case 'Y':
		return 24
	case 'Z':
		return 25
	case 'a':
		return 26
	case 'b':
		return 27
	case 'c':
		return 28
	case 'd':
		return 29
	case 'e':
		return 30
	case 'f':
		return 31
	case 'g':
		return 32
	case 'h':
		return 33
	case 'i':
		return 34
	case 'j':
		return 35
	case 'k':
		return 36
	case 'l':
		return 37
	case 'm':
		return 38
	case 'n':
		return 39
	case 'o':
		return 40
	case 'p':
		return 41
	case 'q':
		return 42
	case 'r':
		return 43
	case 's':
		return 44
	case 't':
		return 45
	case 'u':
		return 46
	case 'v':
		return 47
	case 'w':
		return 48
	case 'x':
		return 49
	case 'y':
		return 50
	case 'z':
		return 51
	case '0':
		return 52
	case '1':
		return 53
	case '2':
		return 54
	case '3':
		return 55
	case '4':
		return 56
	case '5':
		return 57
	case '6':
		return 58
	case '7':
		return 59
	case '8':
		return 60
	case '9':
		return 61
	case '+':
		return 62
	case '/':
		return 63
	case '=':
		return 64
	}

	// error case
	return 65
}

unsigned_right_shift32 :: proc(x: i32, n: uint) -> i32 {
	return i32(u32(x) >> n)
}
