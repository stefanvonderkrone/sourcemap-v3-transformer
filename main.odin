package smv3t

import "core:encoding/json"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:strings"

EXAMPE_FILE :: "example.js.map"

main :: proc() {
	data, file_error := os.read_entire_file_from_filename_or_err(
		EXAMPE_FILE,
		context.temp_allocator,
	)
	if file_error != nil {
		fmt.printfln("%e", file_error)
		return
	}
	smv3: SourceMapV3
	json_read_sourcemap(data, &smv3)
	free_all(context.temp_allocator)
	fmt.printfln("%v", smv3)
}

SourceMapV3 :: struct {
	version:         i64, // mandatory
	file:            string, // optional
	mappings:        string, // mandatory
	source_root:     string, // optional
	ignore_list:     []i64, // optional
	names:           []string, // optional
	sources:         []string, // mandatory
	sources_content: []string, // optional
}

json_read_sourcemap :: proc(data: []u8, source_map: ^SourceMapV3, allocator := context.allocator) {
	arena: vmem.Arena
	arena_allocator := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)
	value, json_error := json.parse(data, parse_integers = true, allocator = arena_allocator)
	if json_error != nil {
		fmt.printfln("%e", json_error)
		return
	}

	object, object_ok := value.(json.Object)
	if !object_ok {
		fmt.printfln("Null not an object", value)
		return
	}

	// version
	{
		version, version_ok := json_object_get_prop(object, "version", json.Integer)
		if !version_ok {
			fmt.printfln("version Null or not an Integer")
			return
		}
		source_map.version = version
	}

	// file (optional)
	{
		file, file_ok := json_object_get_prop(object, "file", json.String)
		if file_ok {
			source_map.file = strings.clone(file, allocator)
		}
	}

	// sourceRoot (optional)
	{
		source_root, source_root_ok := json_object_get_prop(object, "sourceRoot", json.String)
		if source_root_ok {
			source_map.source_root = strings.clone(source_root, allocator)
		}
	}

	// mappings
	{
		mappings, mappings_ok := json_object_get_prop(object, "mappings", json.String)
		if !mappings_ok {
			fmt.printfln("mappings Null or not a string")
			return
		}
		source_map.mappings = strings.clone(mappings, allocator)
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
			ignore_list := make([dynamic]i64, 0, len(list), allocator)
			for val in list {
				int, ok := val.(json.Integer)
				if ok {
					append(&ignore_list, int)
				}
			}
			source_map.ignore_list = ignore_list[:]
		}
	}

	// names (optional)
	{
		names, names_ok := json_object_get_prop(object, "names", json.Array)
		if names_ok {
			names_list := json_array_copy_strings(names, allocator)
			source_map.names = names_list[:]
		}
	}


	// sources
	{
		sources, sources_ok := json_object_get_prop(object, "sources", json.Array)
		if !sources_ok {
			fmt.printfln("sources Null or not an Array")
			return
		}
		sources_list := json_array_copy_strings(sources, allocator)
		source_map.sources = sources_list[:]
	}

	// sourcesContent
	{
		content, content_ok := json_object_get_prop(object, "sourcesContent", json.Array)
		if !content_ok {
			fmt.printfln("sourcesContent Null or not an Array")
			return
		}
		content_list := json_array_copy_strings(content, allocator)
		source_map.sources_content = content_list[:]
	}

}

json_array_copy_strings :: proc(array: json.Array, allocator := context.allocator) -> []string {
	copy := make([dynamic]string, 0, len(array))
	for item in array {
		string, ok := item.(json.String)
		if ok {
			append(&copy, strings.clone(string, allocator))
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
