package stack_trace_v2

import st "../"
import "core:strconv"
import "core:strings"

parse_stack_trace_v2 :: proc(
	stack_trace: string,
	allocator := context.allocator,
	temp_allocator := context.temp_allocator,
) -> []st.Stack_Frame {
	stack_frames := make([dynamic]st.Stack_Frame, 0, 32, allocator)
	token_buffer := make([dynamic]Token, 0, 32, temp_allocator)

	remaining := stack_trace
	for stack_trace_line in strings.split_iterator(&remaining, "\n") {
		// tokenize
		tokens := tokenize_stack_frame(stack_trace_line, &token_buffer)
		tokens = token_trim(tokens)

		num_tokens := len(tokens)

		// we need to look at the first two tokens at least
		if num_tokens < 2 {
			continue
		}

		line: uint = ---
		col: uint = ---
		pathname: string = ---
		name: string = ---

		t0 := tokens[0]
		t1 := tokens[1]
		path_start: Token = ---
		path_end: Token = ---
		t_column: Token = ---
		t_column_colon: Token = ---
		t_line: Token = ---
		t_line_colon: Token = ---
		if t1.type == .WHITESPACE &&
		   t0.type == .WORD &&
		   stack_trace_line[t0.start:t0.end] == "at" {
			// we have a chromium like stack trace
			if tokens[num_tokens - 1].type == .BRACKET_CLOSING {
				opening_bracket_index := -1
				for i in 4 ..< num_tokens {
					if tokens[i].type == .BRACKET_OPENING {
						// -2 because there comes .WHITESPACE before the .BRACKET_OPENING
						name = stack_trace_line[tokens[2].start:tokens[i - 2].end]
						opening_bracket_index = i
						break
					}
				}

				// either
				// we did not found an `(` OR
				// we expect at least 4 more tokens (.DIGIT, .COLON, .DIGIT, .BRACKET_CLOSING)
				if opening_bracket_index < 0 || num_tokens <= opening_bracket_index + 4 {
					continue
				}

				path_start = tokens[opening_bracket_index + 1]
				// after the pathname, there come 5 more tokens (.COLON, .DIGIT, .COLON, .BRACKET_CLOSING)
				path_end = tokens[num_tokens - 6]
				t_column = tokens[num_tokens - 2]
				t_column_colon = tokens[num_tokens - 3]
				t_line = tokens[num_tokens - 4]
				t_line_colon = tokens[num_tokens - 5]
			} else {
				name = ""

				// we expect at least 7 tokens (.WORD (at), .WHITESPACE, .WORD, .COLON, .DIGIT, .COLON, .DIGIT)
				if num_tokens < 7 {
					continue
				}

				path_start = tokens[2]
				// after the pathname, there come 4 more tokens (.COLON, .DIGIT, .COLON)
				path_end = tokens[num_tokens - 5]
				t_column = tokens[num_tokens - 1]
				t_column_colon = tokens[num_tokens - 2]
				t_line = tokens[num_tokens - 3]
				t_line_colon = tokens[num_tokens - 4]
			}
		} else {
			// we have a Firefox/Safari like stack trace
			if t0.type == .AT {
				name = ""
				path_start = t1

				// we expect at least 6 tokens (.AT, .WORD, .COLON, .DIGIT, .COLON, .DIGIT)
				if num_tokens < 6 {
					continue
				}
			} else {
				at_index := -1
				for i in 1 ..< num_tokens {
					if tokens[i].type == .AT {
						name = stack_trace_line[t0.start:tokens[i - 1].end]
						at_index = i
					}
				}

				// either
				// we did not found an `@` OR
				// we expect at least 5 more tokens (.WORD, .COLON, .DIGIT, .COLON, .DIGIT)
				if at_index < 0 || num_tokens <= at_index + 5 {
					continue
				}

				path_start = tokens[at_index + 1]
			}

			path_end = tokens[num_tokens - 5]
			t_column = tokens[num_tokens - 1]
			t_column_colon = tokens[num_tokens - 2]
			t_line = tokens[num_tokens - 3]
			t_line_colon = tokens[num_tokens - 4]
		}

		// we expect `:d+:d+` at the end
		if t_column.type != .DIGIT && t_column_colon.type != .COLON && t_line.type != .DIGIT {
			continue
		}
		column_str := stack_trace_line[t_column.start:t_column.end]
		col = strconv.parse_uint(column_str) or_continue
		line_str := stack_trace_line[t_line.start:t_line.end]
		line = strconv.parse_uint(line_str) or_continue

		// it might happen, that we have no pathname and we only have `(d+:d+)`
		if t_line_colon.type != .COLON {
			path_end = t_line_colon
		}
		pathname = stack_trace_line[path_start.start:path_end.end]

		append(&stack_frames, st.Stack_Frame{line, col, pathname, name})
	}

	return stack_frames[:]
}

token_trim :: proc(tokens: []Token) -> []Token {
	start := 0
	end := len(tokens)
	if end == 0 {
		return tokens
	}
	for start < end {
		if tokens[start].type == .WHITESPACE {
			start += 1
		} else {
			break
		}
	}
	for end > start {
		if tokens[end - 1].type == .WHITESPACE {
			end -= 1
		} else {
			break
		}
	}

	return tokens[start:end]
}

tokenize_stack_frame :: proc(stack_frame_line: string, tokens: ^[dynamic]Token) -> []Token {
	clear(tokens)

	start := 0
	type: TokenType
	for index in 0 ..< len(stack_frame_line) {
		// first entry
		if index == 0 {
			type = token_type_from_byte(stack_frame_line[index])
			continue
		}
		current_type := token_type_from_byte(stack_frame_line[index])

		if type != current_type {
			append(tokens, Token{start = start, end = index, type = type})
			start = index
			type = current_type
		}
	}
	append(tokens, Token{start = start, end = len(stack_frame_line), type = type})

	return tokens[:]
}

token_type_from_byte :: proc(b: u8) -> TokenType {
	if b == ' ' || b == '\t' {
		return .WHITESPACE
	} else if b >= '0' && b <= '9' {
		return .DIGIT
	} else {
		switch (b) {
		case ':':
			return .COLON
		case '(':
			return .BRACKET_OPENING
		case ')':
			return .BRACKET_CLOSING
		case '@':
			return .AT
		}
	}
	return .WORD
}

Token :: struct {
	start: int,
	end:   int,
	type:  TokenType,
}

TokenType :: enum {
	START,
	WHITESPACE,
	DIGIT,
	WORD,
	COLON,
	BRACKET_OPENING,
	BRACKET_CLOSING,
	AT,
}
