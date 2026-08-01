#+build !wasm32
#+build !wasm64p32

package test_utils

import "core:fmt"
import "core:math"
import "core:slice"
import "core:testing"

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
