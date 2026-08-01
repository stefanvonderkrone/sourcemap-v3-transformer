package stack_trace_v3

import st "../"
import "core:strconv"
import "core:strings"

parse_stack_trace_v3 :: proc(
	stack_trace: string,
	allocator := context.allocator,
	temp_allocator := context.temp_allocator,
) -> []st.Stack_Frame {
	stack_frames := make([dynamic]st.Stack_Frame, 0, 32, allocator)

	remaining := stack_trace
	line_loop: for stack_trace_line in strings.split_iterator(&remaining, "\n") {
		line := stack_trace_line

		line_no: uint = ---
		col: uint = ---
		name := ""

		state := ParseState.START
		type := StackTraceType.CHROMIUM

		// Start
		for index in 0 ..< len(line) {
			b := line[index]
			if b == ' ' || b == '\t' {
				continue
			}
			if b == 'a' &&
			   len(line) > index + 3 &&
			   line[index + 1] == 't' &&
			   line[index + 2] == ' ' {
				if line[len(line) - 1] == ')' {
					type = .CHROMIUM_WITH_NAME
					state = .NAME
					line = line[index + 3:len(line) - 1]
					break
				} else {
					type = .CHROMIUM
					state = .PATH
					line = line[index + 3:]
					name = ""
					break
				}
			} else {
				type = .NON_CHROMIUM
				state = .NAME
				break
			}
		}

		if state == .NAME {
			switch (type) {
			case .CHROMIUM_WITH_NAME:
				for index in 0 ..< len(line) {
					if line[index] == '(' && index > 0 {
						name = line[:index - 1]
						line = line[index + 1:]
						state = .PATH
						break
					}
				}
			case .NON_CHROMIUM:
				// search in reverse because `@` can come up in the name as well
				for i in 0 ..< len(line) {
					index := len(line) - 1 - i
					byte := line[index]
					if byte == '@' {
						name = line[:index]
						line = line[index + 1:]
						state = .PATH
						break
					}
				}
			case .CHROMIUM:
			// ignore
			}
		}

		// we should now have state=.PATH
		// now parse column
		for i in 0 ..< len(line) {
			index := len(line) - 1 - i
			byte := line[index]
			if byte == ':' {
				str := line[index + 1:]
				col = strconv.parse_uint(str) or_continue line_loop
				line = line[:index]
				break
			}
		}

		// now parse line
		line_no_block: {
			for i in 0 ..< len(line) {
				line_index := len(line) - 1 - i
				byte := line[line_index]
				if byte == ':' {
					str := line[line_index + 1:]
					line_no = strconv.parse_uint(str) or_continue line_loop
					line = line[:line_index]
					break line_no_block
				}
			}
			line_no = strconv.parse_uint(line) or_continue line_loop
			line = ""
		}

		for i in 0 ..< len(line) {
			index := len(line) - 1 - i
			byte := line[index]
			if byte == '?' {
				line = line[:index]
				break
			}
		}

		append(&stack_frames, st.Stack_Frame{line_no, col, line, name})
	}

	return stack_frames[:]
}

StackTraceType :: enum {
	CHROMIUM,
	CHROMIUM_WITH_NAME,
	NON_CHROMIUM,
}

ParseState :: enum {
	START,
	NAME,
	PATH,
	END,
}
