#+build !js

package smv3t

import h "./help"
import m "./mapping"
import p "./parse"
import t "./transform"
import "core:os"

main :: proc() {
	num_args := len(os.args)
	command := num_args > 1 ? os.args[1] : "help"
	switch command {
	case "parse":
		p.parse(os.args[2:])
	case "translate":
		m.translate(os.args[2:])
	case "transform":
		t.transform(os.args[2:])
	case "help":
		fallthrough
	case "--help":
		fallthrough
	case "-h":
		fallthrough
	case:
		h.print_help(.Help)
	}
}
