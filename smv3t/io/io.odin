package io2

import "core:fmt"
import "core:io"
import "core:os"

read_input :: proc(path: Maybe(string), allocator := context.allocator) -> ([]byte, os.Error) {
	handle := os.stdin
	if path != nil {
		h, h_error := os.open(path.?)
		if h_error != nil {
			fmt.eprintfln("could not open file: %s, reason: %v", path, h_error)
			return {}, h_error
		}
		handle = h
	}
	defer if handle != os.stdin {os.close(handle)}

	BUFFER_SIZE :: 4096
	buffer := make([dynamic]byte, 0, BUFFER_SIZE, allocator)
	chunk: [BUFFER_SIZE]byte

	for {
		n, read_error := os.read(handle, chunk[:])
		if read_error != nil && read_error != io.Error.EOF {
			fmt.eprintfln("could not read handle: %v", read_error)
			return {}, read_error
		}
		if n == 0 {break}
		append(&buffer, ..chunk[:n])
	}
	return buffer[:], nil
}
