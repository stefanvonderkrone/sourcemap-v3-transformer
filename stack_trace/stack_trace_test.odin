#+build !wasm32
#+build !wasm64p32

package stack_trace

import "core:slice"
import "core:testing"

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
	stack_trace := #load("../stacktraces/safari-build.txt", string)
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
	stack_trace := #load("../stacktraces/safari-dev.txt", string)
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
	stack_trace := #load("../stacktraces/chromium-build.txt", string)
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
	stack_trace := #load("../stacktraces/chromium-dev.txt", string)
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
	stack_trace := #load("../stacktraces/node.txt", string)
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
	stack_trace := #load("../stacktraces/bun.txt", string)
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
	stack_trace := #load("../stacktraces/deno.txt", string)
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
	stack_trace := #load("../stacktraces/zen-build.txt", string)
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
	stack_trace := #load("../stacktraces/firefox-build.txt", string)
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
	stack_trace := #load("../stacktraces/firefox-dev.txt", string)
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
	stack_trace := #load("../stacktraces/zen-dev.txt", string)
	stack_frames := parse_stack_trace(stack_trace)
	defer delete(stack_frames)
	if !slice.equal(stack_frames, test_frames) {
		testing.fail(t)
	}
}
