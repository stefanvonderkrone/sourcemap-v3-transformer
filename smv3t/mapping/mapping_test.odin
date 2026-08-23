#+build !wasm32
#+build !wasm64p32

package mapping

import "core:fmt"
import "core:slice"
import "core:testing"

@(test)
test_unsigned_right_shift32 :: proc(t: ^testing.T) {
	// Basic positive numbers (should behave same as >>)
	testing.expect_value(t, unsigned_right_shift32(8, 2), 2)
	testing.expect_value(t, unsigned_right_shift32(16, 4), 1)
	testing.expect_value(t, unsigned_right_shift32(100, 1), 50)
	testing.expect_value(t, unsigned_right_shift32(1, 0), 1)

	// Negative numbers (main use case - differs from >>)
	testing.expect_value(t, unsigned_right_shift32(-1, 1), 0x7FFFFFFF)
	testing.expect_value(t, unsigned_right_shift32(-8, 2), 0x3FFFFFFE)
	testing.expect_value(t, unsigned_right_shift32(-16, 4), 0x0FFFFFFF)
	testing.expect_value(t, unsigned_right_shift32(-100, 1), 0x7FFFFFCE)

	// Shift by 0 (no change)
	testing.expect_value(t, unsigned_right_shift32(42, 0), 42)
	testing.expect_value(t, unsigned_right_shift32(-1, 0), -1)
	testing.expect_value(t, unsigned_right_shift32(-8, 0), -8)

	// Shift by 31 (only sign bit remains or disappears)
	testing.expect_value(t, unsigned_right_shift32(-1, 31), 1)
	testing.expect_value(t, unsigned_right_shift32(1, 31), 0)
	testing.expect_value(t, unsigned_right_shift32(min(i32), 31), 1)
	testing.expect_value(t, unsigned_right_shift32(max(i32), 31), 0)

	// Boundary values
	testing.expect_value(t, unsigned_right_shift32(max(i32), 1), 0x3FFFFFFF)
	testing.expect_value(t, unsigned_right_shift32(min(i32), 1), 0x40000000)
	testing.expect_value(t, unsigned_right_shift32(min(i32), 2), 0x20000000)

	// Powers of 2
	testing.expect_value(t, unsigned_right_shift32(1 << 30, 30), 1)
	testing.expect_value(t, unsigned_right_shift32(1 << 16, 8), 256)

	// All bits set patterns
	testing.expect_value(t, unsigned_right_shift32(-1, 8), 0x00FFFFFF)
	testing.expect_value(t, unsigned_right_shift32(-1, 16), 0x0000FFFF)
	testing.expect_value(t, unsigned_right_shift32(-1, 24), 0x000000FF)

	// Zero
	testing.expect_value(t, unsigned_right_shift32(0, 0), 0)
	testing.expect_value(t, unsigned_right_shift32(0, 16), 0)
	testing.expect_value(t, unsigned_right_shift32(0, 31), 0)
}

@(test)
test_vlq_decode :: proc(t: ^testing.T) {
	expect_slice :: proc(t: ^testing.T, result: []i32, expected: []i32, msg: string) {
		if !slice.equal(result, expected) {
			fmt.printf("FAIL %s: got %v, expected %v\n", msg, result, expected)
			testing.fail(t)
		}
	}

	expect_slice(t, vlq_decode("AAAA", context.temp_allocator), {0, 0, 0, 0}, "AAAA")
	expect_slice(t, vlq_decode("AAgBC", context.temp_allocator), {0, 0, 16, 1}, "AAgBC")
	expect_slice(t, vlq_decode("D", context.temp_allocator), {-1}, "D")
	expect_slice(t, vlq_decode("B", context.temp_allocator), {min(i32)}, "B")
	expect_slice(t, vlq_decode("+/////D", context.temp_allocator), {max(i32)}, "+/////D")
}
