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
		// tokens := tokenize_stack_frame(stack_trace_line, temp_allocator)

	}

	return stack_frames[:]
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
}

@(test)
test_tokenize_stack_frame :: proc(t: ^testing.T) {
	expect_slice :: proc(t: ^testing.T, result: []Token, expected: []Token, msg: string) {
		if !slice.equal(result, expected) {
			fmt.printfln("FAIL %s:", msg)
			fmt.printfln("\tresult_length=%i, expected_length=%i", len(result), len(expected))
			l := math.max(len(result), len(expected))
			// TODO: better diff checking
			for j in 0 ..< l {
				i := l - j - 1
				fmt.printf("#%i: ", i)
				if i < len(result) {
					fmt.printf("result: %v ", result[i])
				}
				if i < len(expected) {
					fmt.printf("expected: %v", expected[i])
				}
				fmt.printf("\n")
			}
			testing.fail(t)
		}
	}
	stack_frame_line := "    at U (http://localhost:4173/assets/index.js:9:37404)"
	tokens := tokenize_stack_frame(stack_frame_line)
	expect_slice(
		t,
		tokens,
		[]Token {
			Token{0, 4, .WHITESPACE},
			Token{4, 6, .WORD},
			Token{6, 7, .WHITESPACE},
			Token{7, 8, .WORD},
			Token{8, 9, .WHITESPACE},
			Token{9, 10, .BRACKET_OPENING},
			Token{10, 14, .WORD},
			Token{14, 15, .COLON},
			Token{15, 26, .WORD},
			Token{26, 27, .COLON},
			Token{27, 31, .DIGIT},
			Token{31, 47, .WORD},
			Token{47, 48, .COLON},
			Token{48, 49, .DIGIT},
			Token{49, 50, .COLON},
			Token{50, 55, .DIGIT},
			Token{55, 56, .BRACKET_CLOSING},
		},
		"",
	)
}
