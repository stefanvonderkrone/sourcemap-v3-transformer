package parse

import h "../help"
import io "../io"
import st "../stack_trace"
import stv2 "../stack_trace/v2"
import stv3 "../stack_trace/v3"
import "core:encoding/json"
import "core:fmt"
import "core:os"

parse :: proc(args: []string) {
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
			h.print_help(.Parse)
			os.exit(0)
		case:
			input = arg
		}
	}
	data, read_error := io.read_input(input != "" ? input : nil)
	if read_error != nil {
		fmt.eprintfln("could not read input: %v", read_error)
		os.exit(1)
	}

	stack_frames: []st.Stack_Frame = ---
	switch (version) {
	case 1:
		stack_frames = st.parse_stack_trace(string(data))
	case 2:
		stack_frames = stv2.parse_stack_trace_v2(string(data))
	case 3:
		stack_frames = stv3.parse_stack_trace_v3(string(data))
	}
	json_out, json_error := json.marshal(stack_frames, {use_spaces = true, pretty = true})
	if json_error != nil {
		fmt.eprintfln("could not parse json: %e", json_error)
		os.exit(1)
	}
	fmt.printfln("%s", json_out)
}
