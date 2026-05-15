package benchmark

import "core:fmt"
import "core:os"
import "core:time"

import smv3t ".."

ITERATIONS :: 10_000
WARMUP :: 100
RUNS :: 5

main :: proc() {
	data, err := os.read_entire_file_from_path("stacktraces/all.txt", context.allocator)
	if err != nil {
		fmt.eprintfln("failed to read stacktraces/all.txt: %v", err)
		os.exit(1)
	}
	defer delete(data)
	input := string(data)

	fmt.printfln("input: %d bytes", len(input))
	fmt.printfln("warmup: %d iter, runs: %d x %d iter", WARMUP, RUNS, ITERATIONS)
	fmt.println()

	bench_v1(input)
	fmt.println()
	bench_v2(input)
	fmt.println()
	bench_v3(input)
}

bench_v1 :: proc(input: string) {
	for _ in 0 ..< WARMUP {
		frames := smv3t.parse_stack_trace(input)
		delete(frames)
		free_all(context.temp_allocator)
	}

	best: time.Duration
	for r in 0 ..< RUNS {
		start := time.tick_now()
		for _ in 0 ..< ITERATIONS {
			frames := smv3t.parse_stack_trace(input)
			delete(frames)
			free_all(context.temp_allocator)
		}
		elapsed := time.tick_since(start)
		if r == 0 || elapsed < best {
			best = elapsed
		}
		per_iter := time.Duration(i64(elapsed) / i64(ITERATIONS))
		fmt.printfln("v1 run %d: %v (%v/iter)", r + 1, elapsed, per_iter)
	}
	fmt.printfln("v1 best: %v/iter", time.Duration(i64(best) / i64(ITERATIONS)))
}

bench_v2 :: proc(input: string) {
	for _ in 0 ..< WARMUP {
		frames := smv3t.parse_stack_trace_v2(input)
		delete(frames)
		free_all(context.temp_allocator)
	}

	best: time.Duration
	for r in 0 ..< RUNS {
		start := time.tick_now()
		for _ in 0 ..< ITERATIONS {
			frames := smv3t.parse_stack_trace_v2(input)
			delete(frames)
			free_all(context.temp_allocator)
		}
		elapsed := time.tick_since(start)
		if r == 0 || elapsed < best {
			best = elapsed
		}
		per_iter := time.Duration(i64(elapsed) / i64(ITERATIONS))
		fmt.printfln("v2 run %d: %v (%v/iter)", r + 1, elapsed, per_iter)
	}
	fmt.printfln("v2 best: %v/iter", time.Duration(i64(best) / i64(ITERATIONS)))
}

bench_v3 :: proc(input: string) {
	for _ in 0 ..< WARMUP {
		frames := smv3t.parse_stack_trace_v3(input)
		delete(frames)
		free_all(context.temp_allocator)
	}

	best: time.Duration
	for r in 0 ..< RUNS {
		start := time.tick_now()
		for _ in 0 ..< ITERATIONS {
			frames := smv3t.parse_stack_trace_v3(input)
			delete(frames)
			free_all(context.temp_allocator)
		}
		elapsed := time.tick_since(start)
		if r == 0 || elapsed < best {
			best = elapsed
		}
		per_iter := time.Duration(i64(elapsed) / i64(ITERATIONS))
		fmt.printfln("v3 run %d: %v (%v/iter)", r + 1, elapsed, per_iter)
	}
	fmt.printfln("v3 best: %v/iter", time.Duration(i64(best) / i64(ITERATIONS)))
}
