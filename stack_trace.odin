package smv3t

import "core:slice"
import "core:strings"
import "core:testing"

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

@(test)
test_parse_stack_trace_safari_build :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 9, col = 37413, pathname = "/assets/index-D6p3_k4u.js", name = "U"},
		Stack_Frame{line = 8, col = 127055, pathname = "/assets/index-D6p3_k4u.js", name = "Hy"},
		Stack_Frame{line = 8, col = 132072, pathname = "/assets/index-D6p3_k4u.js", name = ""},
		Stack_Frame{line = 8, col = 15122, pathname = "/assets/index-D6p3_k4u.js", name = "Yi"},
		Stack_Frame{line = 8, col = 128289, pathname = "/assets/index-D6p3_k4u.js", name = "Xc"},
		Stack_Frame{line = 9, col = 28541, pathname = "/assets/index-D6p3_k4u.js", name = "Pc"},
		Stack_Frame{line = 9, col = 28363, pathname = "/assets/index-D6p3_k4u.js", name = "j1"},
	}
	stack_trace := #load("stacktraces/safari-build.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_safari_dev :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 11, col = 28, pathname = "/src/App.tsx", name = ""},
		Stack_Frame {
			line = 18565,
			col = 26,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		Stack_Frame {
			line = 997,
			col = 23,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		Stack_Frame {
			line = 9409,
			col = 180,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		Stack_Frame {
			line = 9463,
			col = 85,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		Stack_Frame {
			line = 11038,
			col = 58,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		Stack_Frame {
			line = 12774,
			col = 32,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "",
		},
		Stack_Frame {
			line = 34,
			col = 58,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
	}
	stack_trace := #load("stacktraces/safari-dev.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_chromium_build :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 9, col = 37404, pathname = "/assets/index-D6p3_k4u.js", name = "U"},
		Stack_Frame{line = 8, col = 127054, pathname = "/assets/index-D6p3_k4u.js", name = "Hy"},
		Stack_Frame{line = 8, col = 132070, pathname = "/assets/index-D6p3_k4u.js", name = ""},
		Stack_Frame{line = 8, col = 15121, pathname = "/assets/index-D6p3_k4u.js", name = "Yi"},
		Stack_Frame{line = 8, col = 128287, pathname = "/assets/index-D6p3_k4u.js", name = "Xc"},
		Stack_Frame{line = 9, col = 28539, pathname = "/assets/index-D6p3_k4u.js", name = "Pc"},
		Stack_Frame{line = 9, col = 28361, pathname = "/assets/index-D6p3_k4u.js", name = "j1"},
	}
	stack_trace := #load("stacktraces/chromium-build.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_chromium_dev :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 10, col = 19, pathname = "App.tsx", name = ""},
		Stack_Frame {
			line = 25989,
			col = 20,
			pathname = "react-dom-client.development.js",
			name = "Object.react_stack_bottom_frame",
		},
		Stack_Frame {
			line = 871,
			col = 30,
			pathname = "react-dom-client.development.js",
			name = "runWithFiberInDEV",
		},
		Stack_Frame {
			line = 13249,
			col = 29,
			pathname = "react-dom-client.development.js",
			name = "commitHookEffectListMount",
		},
		Stack_Frame {
			line = 13336,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "commitHookPassiveMountEffects",
		},
		Stack_Frame {
			line = 15484,
			col = 13,
			pathname = "react-dom-client.development.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 15439,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 15718,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 15439,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 15519,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "commitPassiveMountOnFiber",
		},
	}
	stack_trace := #load("stacktraces/chromium-dev.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_node :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame {
			line = 14,
			col = 9,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "d",
		},
		Stack_Frame {
			line = 10,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "c",
		},
		Stack_Frame {
			line = 6,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "b",
		},
		Stack_Frame {
			line = 2,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "a",
		},
		Stack_Frame {
			line = 17,
			col = 1,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "",
		},
		Stack_Frame {
			line = 343,
			col = 25,
			pathname = "node:internal/modules/esm/module_job",
			name = "ModuleJob.run",
		},
		Stack_Frame {
			line = 665,
			col = 26,
			pathname = "node:internal/modules/esm/loader",
			name = "async onImport.tracePromise.__proto__",
		},
		Stack_Frame {
			line = 117,
			col = 5,
			pathname = "node:internal/modules/run_main",
			name = "async asyncRunEntryPointWithESMLoader",
		},
	}
	stack_trace := #load("stacktraces/node.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_bun :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame {
			line = 14,
			col = 13,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "d",
		},
		Stack_Frame {
			line = 10,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "c",
		},
		Stack_Frame {
			line = 6,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "b",
		},
		Stack_Frame {
			line = 2,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "a",
		},
		Stack_Frame {
			line = 17,
			col = 1,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "",
		},
		Stack_Frame{line = 2, col = 1, pathname = "", name = "loadAndEvaluateModule"},
	}
	stack_trace := #load("stacktraces/bun.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_deno :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame {
			line = 14,
			col = 9,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "d",
		},
		Stack_Frame {
			line = 10,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "c",
		},
		Stack_Frame {
			line = 6,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "b",
		},
		Stack_Frame {
			line = 2,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "a",
		},
		Stack_Frame {
			line = 17,
			col = 1,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "",
		},
	}
	stack_trace := #load("stacktraces/deno.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_zen_build :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 9, col = 37404, pathname = "/assets/index-D6p3_k4u.js", name = "U"},
		Stack_Frame{line = 8, col = 127055, pathname = "/assets/index-D6p3_k4u.js", name = "Hy"},
		Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "/assets/index-D6p3_k4u.js",
			name = "P1/Xc/<",
		},
		Stack_Frame{line = 8, col = 15122, pathname = "/assets/index-D6p3_k4u.js", name = "Yi"},
		Stack_Frame{line = 8, col = 128289, pathname = "/assets/index-D6p3_k4u.js", name = "Xc"},
		Stack_Frame{line = 9, col = 28541, pathname = "/assets/index-D6p3_k4u.js", name = "Pc"},
		Stack_Frame{line = 9, col = 28361, pathname = "/assets/index-D6p3_k4u.js", name = "j1"},
		Stack_Frame {
			line = 8,
			col = 127850,
			pathname = "/assets/index-D6p3_k4u.js",
			name = "EventListener.handleEvent*py",
		},
		Stack_Frame{line = 8, col = 127250, pathname = "/assets/index-D6p3_k4u.js", name = "Gc"},
		Stack_Frame {
			line = 8,
			col = 127416,
			pathname = "/assets/index-D6p3_k4u.js",
			name = "P1/jc/<",
		},
		Stack_Frame{line = 8, col = 127361, pathname = "/assets/index-D6p3_k4u.js", name = "jc"},
		Stack_Frame {
			line = 9,
			col = 36400,
			pathname = "/assets/index-D6p3_k4u.js",
			name = "P1/ze.createRoot",
		},
		Stack_Frame{line = 9, col = 38122, pathname = "/assets/index-D6p3_k4u.js", name = ""},
	}
	stack_trace := #load("stacktraces/zen-build.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_firefox_build :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 9, col = 37404, pathname = "/assets/index-D6p3_k4u.js", name = "U"},
		Stack_Frame{line = 8, col = 127055, pathname = "/assets/index-D6p3_k4u.js", name = "Hy"},
		Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "/assets/index-D6p3_k4u.js",
			name = "P1/Xc/<",
		},
		Stack_Frame{line = 8, col = 15122, pathname = "/assets/index-D6p3_k4u.js", name = "Yi"},
		Stack_Frame{line = 8, col = 128289, pathname = "/assets/index-D6p3_k4u.js", name = "Xc"},
		Stack_Frame{line = 9, col = 28541, pathname = "/assets/index-D6p3_k4u.js", name = "Pc"},
		Stack_Frame{line = 9, col = 28361, pathname = "/assets/index-D6p3_k4u.js", name = "j1"},
	}
	stack_trace := #load("stacktraces/firefox-build.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_firefox_dev :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 11, col = 19, pathname = "/src/App.tsx", name = "App/<"},
		Stack_Frame {
			line = 18565,
			col = 20,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		Stack_Frame {
			line = 997,
			col = 15,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		Stack_Frame {
			line = 9409,
			col = 163,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		Stack_Frame {
			line = 9463,
			col = 60,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		Stack_Frame {
			line = 11038,
			col = 29,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		Stack_Frame {
			line = 12774,
			col = 13,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/commitRoot/<",
		},
		Stack_Frame {
			line = 34,
			col = 58,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
		Stack_Frame {
			line = 154,
			col = 9,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "EventHandlerNonNull*node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/cjs/scheduler.development.js/<",
		},
		Stack_Frame {
			line = 264,
			col = 7,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/cjs/scheduler.development.js",
		},
		Stack_Frame {
			line = 3,
			col = 50,
			pathname = "/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		Stack_Frame {
			line = 275,
			col = 24,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/index.js",
		},
		Stack_Frame {
			line = 3,
			col = 50,
			pathname = "/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		Stack_Frame {
			line = 17257,
			col = 23,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/<",
		},
		Stack_Frame {
			line = 20175,
			col = 7,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js",
		},
		Stack_Frame {
			line = 3,
			col = 50,
			pathname = "/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		Stack_Frame {
			line = 20186,
			col = 24,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/client.js",
		},
		Stack_Frame {
			line = 3,
			col = 50,
			pathname = "/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		Stack_Frame {
			line = 20190,
			col = 16,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "",
		},
	}
	stack_trace := #load("stacktraces/firefox-dev.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}

@(test)
test_parse_stack_trace_zen_dev :: proc(t: ^testing.T) {
	test_frames := []Stack_Frame {
		Stack_Frame{line = 11, col = 19, pathname = "/src/App.tsx", name = "App/<"},
		Stack_Frame {
			line = 18565,
			col = 20,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		Stack_Frame {
			line = 997,
			col = 15,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		Stack_Frame {
			line = 9409,
			col = 163,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		Stack_Frame {
			line = 9463,
			col = 60,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		Stack_Frame {
			line = 11038,
			col = 29,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		Stack_Frame {
			line = 12774,
			col = 13,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/commitRoot/<",
		},
		Stack_Frame {
			line = 34,
			col = 58,
			pathname = "/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
	}
	stack_trace := #load("stacktraces/zen-dev.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}
