package smv3t

import "core:fmt"
import "core:math"
import "core:odin/tokenizer"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:testing"

parse_stack_trace_v2 :: proc(
	stack_trace: string,
	allocator := context.allocator,
	temp_allocator := context.temp_allocator,
) -> []Stack_Frame {
	lines := strings.split(stack_trace, "\n", temp_allocator)
	stack_frames := make([dynamic]Stack_Frame, 0, len(lines), allocator)

	for stack_trace_line in lines {
		// tokenize
		tokens := tokenize_stack_frame(stack_trace_line, temp_allocator)
		tokens = token_trim(tokens)

		num_tokens := len(tokens)
		token_index := num_tokens - 1

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
		if t1.type == .WHITESPACE &&
		   t0.type == .WORD &&
		   stack_trace_line[t0.start:t0.end] == "at" {
			// we have a chromium like stack trace
		} else {
			// we have a Firefox/Safari like stack trace
			path_start: Token = ---
			path_end: Token = ---
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

				// we did not found an `@`
				// we expect at least 6 more tokens (.WORD, .COLON, .DIGIT, .COLON, .DIGIT)
				if at_index < 0 || num_tokens <= at_index + 5 {
					continue
				}

				path_start = tokens[at_index + 1]
			}

			path_end = tokens[num_tokens - 5]
			t_column := tokens[num_tokens - 1]
			t_column_colon := tokens[num_tokens - 2]
			t_line := tokens[num_tokens - 3]
			t_line_colon := tokens[num_tokens - 4]

			// we expect `:d+:d+` at the end
			if t_column.type != .DIGIT &&
			   t_column_colon.type != .COLON &&
			   t_line.type != .DIGIT &&
			   t_line_colon.type != .COLON {
				continue
			}
			column_str := stack_trace_line[t_column.start:t_column.end]
			ok: bool = ---
			col, ok = strconv.parse_uint(column_str)
			if !ok {
				continue
			}
			line_str := stack_trace_line[t_line.start:t_line.end]
			line, ok = strconv.parse_uint(line_str)
			if !ok {
				continue
			}

			pathname = stack_trace_line[path_start.start:path_end.end]

			append(&stack_frames, Stack_Frame{line, col, pathname, name})
		}
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

tokenize_stack_frame :: proc(
	stack_frame_line: string,
	temp_allocator := context.temp_allocator,
) -> []Token {
	tokens := make([dynamic]Token, temp_allocator)

	start := 0
	type: TokenType
	for char, index in stack_frame_line {
		// first entry
		if index == 0 {
			type = token_type_from_rune(char)
			continue
		}
		// token type
		current_type := token_type_from_rune(char)

		if type != current_type {
			append(&tokens, Token{start = start, end = index, type = type})
			start = index
			type = current_type
		}
	}
	append(&tokens, Token{start = start, end = len(stack_frame_line), type = type})

	return tokens[:]
}

token_type_from_rune :: proc(r: rune) -> TokenType {
	if strings.is_space(r) {
		return .WHITESPACE
	} else if rune_is_digit(r) {
		return .DIGIT
	} else {
		switch (r) {
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

rune_is_digit :: proc(r: rune) -> bool {
	return r >= 48 && r <= 57
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

@(test)
test_parse_stack_trace_v2_safari_build :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame {
			line = 9,
			col = 37413,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "U",
		},
		Stack_Frame {
			line = 8,
			col = 127055,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Hy",
		},
		Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "",
		},
		Stack_Frame {
			line = 8,
			col = 15122,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Yi",
		},
		Stack_Frame {
			line = 8,
			col = 128289,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Xc",
		},
		Stack_Frame {
			line = 9,
			col = 28541,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Pc",
		},
		Stack_Frame {
			line = 9,
			col = 28363,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "j1",
		},
	}
	stack_trace := #load("stacktraces/safari-build.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	expect_slice(t, stack_frames, test_frames, "firefox build")
}


@(test)
test_parse_stack_trace_v2_firefox_build :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame {
			line = 9,
			col = 37404,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "U",
		},
		Stack_Frame {
			line = 8,
			col = 127055,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Hy",
		},
		Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "P1/Xc/<",
		},
		Stack_Frame {
			line = 8,
			col = 15122,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Yi",
		},
		Stack_Frame {
			line = 8,
			col = 128289,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Xc",
		},
		Stack_Frame {
			line = 9,
			col = 28541,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Pc",
		},
		Stack_Frame {
			line = 9,
			col = 28361,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "j1",
		},
	}
	stack_trace := #load("stacktraces/firefox-build.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	expect_slice(t, stack_frames, test_frames, "firefox build")
}

@(test)
test_token_trim :: proc(t: ^testing.T) {
	expect_slice(t, token_trim([]Token{}), []Token{}, "#1")
	expect_slice(t, token_trim([]Token{{0, 0, .WHITESPACE}, {0, 0, .WHITESPACE}}), []Token{}, "#2")
	expect_slice(
		t,
		token_trim([]Token{{0, 0, .WHITESPACE}, {0, 0, .DIGIT}}),
		[]Token{{0, 0, .DIGIT}},
		"#3",
	)
	expect_slice(
		t,
		token_trim([]Token{{0, 0, .DIGIT}, {0, 0, .WHITESPACE}}),
		[]Token{{0, 0, .DIGIT}},
		"#4",
	)
	expect_slice(
		t,
		token_trim([]Token{{0, 0, .WHITESPACE}, {0, 0, .DIGIT}, {0, 0, .WHITESPACE}}),
		[]Token{{0, 0, .DIGIT}},
		"#4",
	)
}

@(test)
test_tokenize_stack_frame :: proc(t: ^testing.T) {
	m: map[string][]Token
	defer delete(m)

	m["      at d (/Volumes/Work/Github/sourcemaps-v3-transformer/error.js:14:13)"] = {
		{0, 6, .WHITESPACE},
		{6, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 10, .WORD},
		{10, 11, .WHITESPACE},
		{11, 12, .BRACKET_OPENING},
		{12, 45, .WORD},
		{45, 46, .DIGIT},
		{46, 67, .WORD},
		{67, 68, .COLON},
		{68, 70, .DIGIT},
		{70, 71, .COLON},
		{71, 73, .DIGIT},
		{73, 74, .BRACKET_CLOSING},
	}
	m["      at loadAndEvaluateModule (2:1)"] = {
		{0, 6, .WHITESPACE},
		{6, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 30, .WORD},
		{30, 31, .WHITESPACE},
		{31, 32, .BRACKET_OPENING},
		{32, 33, .DIGIT},
		{33, 34, .COLON},
		{34, 35, .DIGIT},
		{35, 36, .BRACKET_CLOSING},
	}
	m["    at http://localhost:4173/assets/index-D6p3_k4u.js:8:132070"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 11, .WORD},
		{11, 12, .COLON},
		{12, 23, .WORD},
		{23, 24, .COLON},
		{24, 28, .DIGIT},
		{28, 43, .WORD},
		{43, 44, .DIGIT},
		{44, 45, .WORD},
		{45, 46, .DIGIT},
		{46, 48, .WORD},
		{48, 49, .DIGIT},
		{49, 53, .WORD},
		{53, 54, .COLON},
		{54, 55, .DIGIT},
		{55, 56, .COLON},
		{56, 62, .DIGIT},
	}
	m["    at d (file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js:14:9)"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 10, .BRACKET_OPENING},
		{10, 14, .WORD},
		{14, 15, .COLON},
		{15, 50, .WORD},
		{50, 51, .DIGIT},
		{51, 72, .WORD},
		{72, 73, .COLON},
		{73, 75, .DIGIT},
		{75, 76, .COLON},
		{76, 77, .DIGIT},
		{77, 78, .BRACKET_CLOSING},
	}
	m["    at file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js:17:1"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 11, .WORD},
		{11, 12, .COLON},
		{12, 47, .WORD},
		{47, 48, .DIGIT},
		{48, 69, .WORD},
		{69, 70, .COLON},
		{70, 72, .DIGIT},
		{72, 73, .COLON},
		{73, 74, .DIGIT},
	}
	m["U@http://localhost:4173/assets/index-D6p3_k4u.js:9:37404"] = {
		{0, 1, .WORD},
		{1, 2, .AT},
		{2, 6, .WORD},
		{6, 7, .COLON},
		{7, 18, .WORD},
		{18, 19, .COLON},
		{19, 23, .DIGIT},
		{23, 38, .WORD},
		{38, 39, .DIGIT},
		{39, 40, .WORD},
		{40, 41, .DIGIT},
		{41, 43, .WORD},
		{43, 44, .DIGIT},
		{44, 48, .WORD},
		{48, 49, .COLON},
		{49, 50, .DIGIT},
		{50, 51, .COLON},
		{51, 56, .DIGIT},
	}
	m["P1/Xc/<@http://localhost:4173/assets/index-D6p3_k4u.js:8:132072"] = {
		{0, 1, .WORD},
		{1, 2, .DIGIT},
		{2, 7, .WORD},
		{7, 8, .AT},
		{8, 12, .WORD},
		{12, 13, .COLON},
		{13, 24, .WORD},
		{24, 25, .COLON},
		{25, 29, .DIGIT},
		{29, 44, .WORD},
		{44, 45, .DIGIT},
		{45, 46, .WORD},
		{46, 47, .DIGIT},
		{47, 49, .WORD},
		{49, 50, .DIGIT},
		{50, 54, .WORD},
		{54, 55, .COLON},
		{55, 56, .DIGIT},
		{56, 57, .COLON},
		{57, 63, .DIGIT},
	}
	m["    at async asyncRunEntryPointWithESMLoader (node:internal/modules/run_main:117:5)"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 12, .WORD},
		{12, 13, .WHITESPACE},
		{13, 44, .WORD},
		{44, 45, .WHITESPACE},
		{45, 46, .BRACKET_OPENING},
		{46, 50, .WORD},
		{50, 51, .COLON},
		{51, 76, .WORD},
		{76, 77, .COLON},
		{77, 80, .DIGIT},
		{80, 81, .COLON},
		{81, 82, .DIGIT},
		{82, 83, .BRACKET_CLOSING},
	}
	m["@http://localhost:4173/assets/index-D6p3_k4u.js:8:132072"] = {
		{0, 1, .AT},
		{1, 5, .WORD},
		{5, 6, .COLON},
		{6, 17, .WORD},
		{17, 18, .COLON},
		{18, 22, .DIGIT},
		{22, 37, .WORD},
		{37, 38, .DIGIT},
		{38, 39, .WORD},
		{39, 40, .DIGIT},
		{40, 42, .WORD},
		{42, 43, .DIGIT},
		{43, 47, .WORD},
		{47, 48, .COLON},
		{48, 49, .DIGIT},
		{49, 50, .COLON},
		{50, 56, .DIGIT},
	}
	m["    at U (http://localhost:4173/assets/index.js:9:37404)"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 10, .BRACKET_OPENING},
		{10, 14, .WORD},
		{14, 15, .COLON},
		{15, 26, .WORD},
		{26, 27, .COLON},
		{27, 31, .DIGIT},
		{31, 47, .WORD},
		{47, 48, .COLON},
		{48, 49, .DIGIT},
		{49, 50, .COLON},
		{50, 55, .DIGIT},
		{55, 56, .BRACKET_CLOSING},
	}

	for key, value in m {
		tokens := tokenize_stack_frame(key, context.temp_allocator)
		expect_slice(t, tokens, value, key)
	}
}

@(private)
expect_slice :: proc(
	t: ^testing.T,
	result, expected: $T/[]$E,
	msg: string,
	loc := #caller_location,
) {
	if !slice.equal(result, expected) {
		fmt.printfln("FAIL %s at %s", msg, loc)
		fmt.printfln("\tresult_length=%i, expected_length=%i", len(result), len(expected))
		max_length := math.max(len(result), len(expected))
		min_length := math.min(len(result), len(expected))
		for i in 0 ..< min_length {
			result_item := result[i]
			expected_item := expected[i]
			if result_item == expected_item {
				continue
				// fmt.printfln("#%3i:    %v", i, result_item)
			} else {
				fmt.printfln("#%3i:  - %v", i, expected_item)
				fmt.printfln("#%3i:  + %v", i, result_item)
			}
		}
		for i in min_length ..< max_length {
			if i < len(result) {
				fmt.printfln("#%3i:  + %v", i, result[i])
			} else {
				fmt.printfln("#%3i:  - %v", i, expected[i])
			}
		}
		testing.fail(t)
	}
}
