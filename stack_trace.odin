package smv3t

import "core:container/intrusive/list"
import "core:encoding/json"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:text/regex"

StackFrame :: struct {
	line:     uint,
	col:      uint,
	pathname: string,
	name:     string,
}

parse_stack_trace :: proc(stack_trace: string) -> []StackFrame {
	lines := strings.split(stack_trace, "\n")
	stack_frames := make([dynamic]StackFrame, 0, len(lines))
	for stack_frame_line in lines {
		if len(stack_frame_line) == 0 {
			continue
		}
		fmt.println("")
		fmt.printfln("stack_frame_line: \n%s", stack_frame_line)
		parser := make_parser_iterator(stack_frame_line)

		has_closing_parenthesis := false
		if parser_current_char(&parser) == ')' {
			// v8/bun based stackframe with name
			parser_skip_n(&parser, 1)
			has_closing_parenthesis = true
		}

		// parse column
		col_str, col_str_ok := parser_collect_digits(&parser)
		if !col_str_ok {
			continue
		}
		col, col_ok := strconv.parse_uint(col_str, 10)
		if !col_ok {
			continue
		}
		fmt.printfln("col: '%i'", col)

		// parse line
		line_str, line_str_ok := parser_collect_digits(&parser)
		if !line_str_ok {
			// TODO: bun internal function
			//       at loadAndEvaluateModule (2:1)
			continue
		}
		line, line_ok := strconv.parse_uint(line_str, 10)
		if !line_ok {
			continue
		}
		fmt.printfln("line: '%i'", line)

		last_char := parser_current_char(&parser)

		path: string
		if (last_char != ' ') {
			// parse path
			end_pos := parser_current_position(&parser)
			start_pos := end_pos

			// TODO: bun internal module -> last_char points to last char of name

			last_slash_pos := -1
			for char, idx in parser_iterator(&parser) {
				start_pos = idx
				if char == '(' || char == ' ' || char == '@' {
					// end of path
					break
				}
				if char == '/' && parser_char_at(&parser, idx - 1) == '/' {
					if parser_char_at(&parser, idx - 2) == '/' {
						// local file urls
						start_pos -= 1
						break
					}
					// http urls
					start_pos = last_slash_pos - 1
					break
				}
				if char == '/' {
					last_slash_pos = idx
				}

				last_char = char

			}

			path = stack_frame_line[start_pos + 1:end_pos + 1]
			fmt.printfln("path: '%s'", path)
		} else {
			// move one char ahead
			// parser_iterator(&parser)
		}

		// skip whitespace
		parser_skip_char(&parser, ' ')

		fmt.printfln(
			"char: \"%c\" %i",
			parser_current_char(&parser),
			parser_current_position(&parser),
		)
		// fmt.printfln("rest: '%s'", stack_frame_line[:parser_current_position(&parser) + 1])

		// parse name
		// skip until ' ' || '@'
		fmt.printfln("rest: '%s'", stack_frame_line[:parser_current_position(&parser) + 1])
		name: string
		if has_closing_parenthesis {
			fmt.printfln("cur char: '%c':", parser_current_char(&parser))
			for char in parser_iterator(&parser) {
				if char == '(' {
					break
				}
			}
			parser_skip_n(&parser, 1)
			name_t, name_ok := parser_collect_until(&parser, ' ')
			if name_ok {
				name = name_t
			}
			// no name
		} else {
			for _ in parser_iterator(&parser) {
				if parser_current_char(&parser) == '@' {
					break
				}
			}
			if parser_current_position(&parser) >= 0 {
				name = stack_frame_line[:parser_current_position(&parser)]
			}
			// no name
		}

		fmt.printfln("name: '%s'", name)

		append(&stack_frames, StackFrame{line = line, col = col, pathname = path, name = name})
	}

	fmt.printfln("%v", stack_frames)

	return stack_frames[:]
}

ParserIterator :: struct {
	length:      int,
	current_pos: int,
	content:     string,
}

make_parser_iterator :: proc(content: string) -> ParserIterator {
	length := len(content)
	return {length = length, content = content, current_pos = length - 1}
}

parser_collect_until :: proc(parser: ^ParserIterator, until_char: u8) -> (string, bool) {
	end_pos := parser.current_pos + 1
	for char, idx in parser_iterator(parser) {
		if char == until_char {
			start_pos := idx + 1
			return parser.content[start_pos:end_pos], true
		}
	}

	return {}, false
}

is_digit :: proc(char: u8) -> bool {
	return char >= 48 && char <= 57
}

parser_collect_digits :: proc(parser: ^ParserIterator) -> (string, bool) {
	if !is_digit(parser_current_char(parser)) {
		return {}, false
	}
	end_pos := parser.current_pos + 1
	for char, idx in parser_iterator(parser) {
		if !is_digit(char) {
			start_pos := idx + 1
			return parser.content[start_pos:end_pos], true
		}
	}
	return {}, false
}

parser_skip_char :: proc(parser: ^ParserIterator, char: u8) {
	for {
		if parser_current_char(parser) != char {
			return
		}
		parser_iterator(parser)
	}
}

parser_skip_n :: proc(parser: ^ParserIterator, n: int) {
	new_pos := parser.current_pos - n
	if new_pos < 0 {
		parser.current_pos = 0
	} else if new_pos >= parser.length {
		parser.current_pos = parser.length - 1
	} else {
		parser.current_pos = new_pos
	}
}

parser_current_char :: proc(parser: ^ParserIterator) -> u8 {
	if parser.length > 0 && parser.current_pos >= 0 {
		return parser.content[parser.current_pos]
	}
	return 0
}

parser_char_at :: proc(parser: ^ParserIterator, pos: int) -> u8 {
	if pos >= 0 && pos < parser.length {
		return parser.content[pos]
	}
	return 0
}

parser_preceeding_char :: proc(parser: ^ParserIterator) -> u8 {
	if parser.length > 0 && parser.current_pos >= 1 {
		return parser.content[parser.current_pos - 1]
	}
	return 0
}

parser_current_position :: proc(parser: ^ParserIterator) -> int {
	return parser.current_pos
}

parser_iterator :: proc(parser: ^ParserIterator) -> (val: u8, idx: int, cond: bool) {
	cond = parser.current_pos >= 0
	idx = parser.current_pos
	if parser.current_pos >= 0 {
		val = parser.content[idx]
	}
	parser.current_pos -= 1
	return
}

@(test)
text_parse_stack_trace_safari_build :: proc(t: ^testing.T) {
	test_frames := []StackFrame {
		StackFrame{line = 9, col = 37413, pathname = "/assets/index-D6p3_k4u.js", name = "U"},
		StackFrame{line = 8, col = 127055, pathname = "/assets/index-D6p3_k4u.js", name = "Hy"},
		StackFrame{line = 8, col = 132072, pathname = "/assets/index-D6p3_k4u.js", name = ""},
		StackFrame{line = 8, col = 15122, pathname = "/assets/index-D6p3_k4u.js", name = "Yi"},
		StackFrame{line = 8, col = 128289, pathname = "/assets/index-D6p3_k4u.js", name = "Xc"},
		StackFrame{line = 9, col = 28541, pathname = "/assets/index-D6p3_k4u.js", name = "Pc"},
		StackFrame{line = 9, col = 28363, pathname = "/assets/index-D6p3_k4u.js", name = "j1"},
	}
	stack_trace := #load("stacktraces/safari-build.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_safari_dev :: proc(t: ^testing.T) {
	test_frames := []StackFrame {
		StackFrame{line = 11, col = 28, pathname = "/src/App.tsx", name = ""},
		StackFrame {
			line = 18565,
			col = 26,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		StackFrame {
			line = 997,
			col = 23,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		StackFrame {
			line = 9409,
			col = 180,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		StackFrame {
			line = 9463,
			col = 85,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		StackFrame {
			line = 11038,
			col = 58,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		StackFrame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		StackFrame {
			line = 11199,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		StackFrame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		StackFrame {
			line = 11064,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		StackFrame {
			line = 13148,
			col = 36,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		StackFrame {
			line = 12774,
			col = 32,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "",
		},
		StackFrame {
			line = 34,
			col = 58,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
	}
	stack_trace := #load("stacktraces/safari-dev.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}
