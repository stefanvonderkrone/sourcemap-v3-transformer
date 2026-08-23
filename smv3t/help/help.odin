package help

import c "../command"
import "core:fmt"
import "core:os"

print_help :: proc(cmd: c.Command) {
	bin := os.args[0]
	switch cmd {
	case .Parse:
		fmt.printfln("%s parse - parses a javascript stacktrace to json", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s parse [options] <file>", bin)
	case .Translate:
		fmt.printfln("%s - translate a given javascript stackframe", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s translate <file> <line> <olumn>", bin)
	case .Transform:
		fmt.printfln("%s - transform a javascript stacktrace", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s transform [options] <file>", bin)
	case .Help:
		fmt.printfln("%s is a tool to work with javascript stachtraces", bin)
		fmt.println("Usage:")
		fmt.printfln("\t%s command [options]", bin)
		fmt.println("Commands:")
		fmt.println("\tparse")
		fmt.println("\ttranslate")
		fmt.println("\ttransform")
		fmt.println("\thelp")
	}
}
