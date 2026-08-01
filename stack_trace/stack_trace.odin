package stack_trace

import "core:strings"

Stack_Frame :: struct {
	line:     uint,
	col:      uint,
	pathname: string,
	name:     string,
}

/**
 * TODO: rewrite with proper tokenizing, lexing, parsing
 * and a formalized way of interpreting stack frames
 **/
parse_stack_trace :: proc(
	stack_trace: string,
	allocator := context.allocator,
	temp_allocator := context.temp_allocator,
) -> []Stack_Frame {
	stack_frames := make([dynamic]Stack_Frame, 0, 32, allocator)

	remaining := stack_trace
	for stack_frame_line in strings.split_iterator(&remaining, "\n") {
		if len(stack_frame_line) == 0 {
			continue
		}
		parser := make_parser_iterator(stack_frame_line)

		has_closing_parenthesis := false
		if parser_current_char(&parser) == ')' {
			// v8/bun based stackframe with name
			parser_skip_n(&parser, 1)
			has_closing_parenthesis = true
		}

		// parse column
		col := parser_collect_uint(&parser) or_continue

		// parse line
		// TODO: bun internal function
		//       at loadAndEvaluateModule (2:1)
		line := parser_collect_uint(&parser) or_continue

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
				if char == '?' {
					end_pos = idx - 1
					continue
				}
				if char == '(' || char == ' ' || char == '@' {
					// end of path
					break
				}
				if char == '/' && parser_char_at(&parser, idx - 1) == '/' {
					if parser_char_at(&parser, idx - 2) == '/' {
						// local file urls
						start_pos -= 1
						// skip rest until whitespace
						if has_closing_parenthesis {
							parser_skip_until(&parser, ' ')
						}
						break
					}
					// http urls
					start_pos = last_slash_pos - 1
					// skip rest until whitespace
					if has_closing_parenthesis {
						parser_skip_until(&parser, ' ')
					}
					break
				}
				if char == '/' {
					last_slash_pos = idx
				}

				last_char = char

			}

			path = stack_frame_line[start_pos + 1:end_pos + 1]
		}

		// skip whitespace
		parser_skip_char(&parser, ' ')

		// parse name
		// skip until ' ' || '@'
		name: string
		if has_closing_parenthesis {
			end_pos := parser_current_position(&parser)
			start_pos := end_pos
			for _, idx in parser_iterator(&parser) {
				// we need space for " at "
				if idx < 4 {
					break
				}
				// find " at " before the current position
				if stack_frame_line[idx - 4] == ' ' &&
				   stack_frame_line[idx - 3] == 'a' &&
				   stack_frame_line[idx - 2] == 't' &&
				   stack_frame_line[idx - 1] == ' ' {
					start_pos = idx
					break
				}
			}
			name = stack_frame_line[start_pos:end_pos + 1]
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

		append(&stack_frames, Stack_Frame{line = line, col = col, pathname = path, name = name})
	}

	// fmt.printfln("%v", stack_frames)

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

parser_collect_uint :: proc(parser: ^ParserIterator) -> (uint, bool) {
	if !is_digit(parser_current_char(parser)) {
		return 0, false
	}
	val: uint = 0
	multiplier: uint = 1
	for char in parser_iterator(parser) {
		if !is_digit(char) {
			return val, true
		}
		val += uint(char - '0') * multiplier
		multiplier *= 10
	}
	return 0, false
}

parser_skip_char :: proc(parser: ^ParserIterator, char: u8) {
	for {
		if parser_current_char(parser) != char {
			return
		}
		parser_iterator(parser)
	}
}

parser_skip_until :: proc(parser: ^ParserIterator, char: u8) {
	for {
		if parser_current_char(parser) == char || parser_current_position(parser) == 0 {
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
