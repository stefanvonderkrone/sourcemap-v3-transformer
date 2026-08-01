#+build !wasm32
#+build !wasm64p32

package stack_trace_v3

import st "../"
import test_utils "../../test_utils"
import "core:testing"

@(test)
test_parse_stack_trace_v3_chromium_build :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 9,
			col = 37404,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "U",
		},
		st.Stack_Frame {
			line = 8,
			col = 127054,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Hy",
		},
		st.Stack_Frame {
			line = 8,
			col = 132070,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "",
		},
		st.Stack_Frame {
			line = 8,
			col = 15121,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Yi",
		},
		st.Stack_Frame {
			line = 8,
			col = 128287,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Xc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28539,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Pc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28361,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "j1",
		},
	}
	stack_trace := #load("../../stacktraces/chromium-build.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "chromium build")
}

@(test)
test_parse_stack_trace_v3_chromium_dev :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame{line = 10, col = 19, pathname = "App.tsx", name = ""},
		st.Stack_Frame {
			line = 25989,
			col = 20,
			pathname = "react-dom-client.development.js",
			name = "Object.react_stack_bottom_frame",
		},
		st.Stack_Frame {
			line = 871,
			col = 30,
			pathname = "react-dom-client.development.js",
			name = "runWithFiberInDEV",
		},
		st.Stack_Frame {
			line = 13249,
			col = 29,
			pathname = "react-dom-client.development.js",
			name = "commitHookEffectListMount",
		},
		st.Stack_Frame {
			line = 13336,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "commitHookPassiveMountEffects",
		},
		st.Stack_Frame {
			line = 15484,
			col = 13,
			pathname = "react-dom-client.development.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 15439,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 15718,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 15439,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 15519,
			col = 11,
			pathname = "react-dom-client.development.js",
			name = "commitPassiveMountOnFiber",
		},
	}
	stack_trace := #load("../../stacktraces/chromium-dev.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "chromium dev")
}

@(test)
test_parse_stack_trace_v3_node :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 14,
			col = 9,
			pathname = "file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "d",
		},
		st.Stack_Frame {
			line = 10,
			col = 3,
			pathname = "file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "c",
		},
		st.Stack_Frame {
			line = 6,
			col = 3,
			pathname = "file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "b",
		},
		st.Stack_Frame {
			line = 2,
			col = 3,
			pathname = "file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "a",
		},
		st.Stack_Frame {
			line = 17,
			col = 1,
			pathname = "file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "",
		},
		st.Stack_Frame {
			line = 343,
			col = 25,
			pathname = "node:internal/modules/esm/module_job",
			name = "ModuleJob.run",
		},
		st.Stack_Frame {
			line = 665,
			col = 26,
			pathname = "node:internal/modules/esm/loader",
			name = "async onImport.tracePromise.__proto__",
		},
		st.Stack_Frame {
			line = 117,
			col = 5,
			pathname = "node:internal/modules/run_main",
			name = "async asyncRunEntryPointWithESMLoader",
		},
	}
	stack_trace := #load("../../stacktraces/node.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "node")
}

@(test)
test_parse_stack_trace_v3_bun :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 14,
			col = 13,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "d",
		},
		st.Stack_Frame {
			line = 10,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "c",
		},
		st.Stack_Frame {
			line = 6,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "b",
		},
		st.Stack_Frame {
			line = 2,
			col = 3,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "a",
		},
		st.Stack_Frame {
			line = 17,
			col = 1,
			pathname = "/Volumes/Work/Github/sourcemaps-v3-transformer/error.js",
			name = "",
		},
		st.Stack_Frame{line = 2, col = 1, pathname = "", name = "loadAndEvaluateModule"},
	}
	stack_trace := #load("../../stacktraces/bun.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "bun")
}

@(test)
test_parse_stack_trace_v3_safari_build :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 9,
			col = 37413,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "U",
		},
		st.Stack_Frame {
			line = 8,
			col = 127055,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Hy",
		},
		st.Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "",
		},
		st.Stack_Frame {
			line = 8,
			col = 15122,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Yi",
		},
		st.Stack_Frame {
			line = 8,
			col = 128289,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Xc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28541,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Pc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28363,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "j1",
		},
	}
	stack_trace := #load("../../stacktraces/safari-build.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "safari build")
}

@(test)
test_parse_stack_trace_v3_safari_dev :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 11,
			col = 28,
			pathname = "http://localhost:5173/src/App.tsx",
			name = "",
		},
		st.Stack_Frame {
			line = 18565,
			col = 26,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		st.Stack_Frame {
			line = 997,
			col = 23,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		st.Stack_Frame {
			line = 9409,
			col = 180,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		st.Stack_Frame {
			line = 9463,
			col = 85,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11038,
			col = 58,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		st.Stack_Frame {
			line = 12774,
			col = 32,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "",
		},
		st.Stack_Frame {
			line = 34,
			col = 58,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
	}
	stack_trace := #load("../../stacktraces/safari-dev.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "safari dev")
}

@(test)
test_parse_stack_trace_v3_firefox_build :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 9,
			col = 37404,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "U",
		},
		st.Stack_Frame {
			line = 8,
			col = 127055,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Hy",
		},
		st.Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "P1/Xc/<",
		},
		st.Stack_Frame {
			line = 8,
			col = 15122,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Yi",
		},
		st.Stack_Frame {
			line = 8,
			col = 128289,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Xc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28541,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Pc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28361,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "j1",
		},
	}
	stack_trace := #load("../../stacktraces/firefox-build.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "firefox build")
}

@(test)
test_parse_stack_trace_v3_zen_build :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 9,
			col = 37404,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "U",
		},
		st.Stack_Frame {
			line = 8,
			col = 127055,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Hy",
		},
		st.Stack_Frame {
			line = 8,
			col = 132072,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "P1/Xc/<",
		},
		st.Stack_Frame {
			line = 8,
			col = 15122,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Yi",
		},
		st.Stack_Frame {
			line = 8,
			col = 128289,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Xc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28541,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Pc",
		},
		st.Stack_Frame {
			line = 9,
			col = 28361,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "j1",
		},
		st.Stack_Frame {
			line = 8,
			col = 127850,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "EventListener.handleEvent*py",
		},
		st.Stack_Frame {
			line = 8,
			col = 127250,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "Gc",
		},
		st.Stack_Frame {
			line = 8,
			col = 127416,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "P1/jc/<",
		},
		st.Stack_Frame {
			line = 8,
			col = 127361,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "jc",
		},
		st.Stack_Frame {
			line = 9,
			col = 36400,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "P1/ze.createRoot",
		},
		st.Stack_Frame {
			line = 9,
			col = 38122,
			pathname = "http://localhost:4173/assets/index-D6p3_k4u.js",
			name = "",
		},
	}
	stack_trace := #load("../../stacktraces/zen-build.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "zen build")
}

@(test)
test_parse_stack_trace_v3_firefox_dev :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 11,
			col = 19,
			pathname = "http://localhost:5173/src/App.tsx",
			name = "App/<",
		},
		st.Stack_Frame {
			line = 18565,
			col = 20,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		st.Stack_Frame {
			line = 997,
			col = 15,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		st.Stack_Frame {
			line = 9409,
			col = 163,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		st.Stack_Frame {
			line = 9463,
			col = 60,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11038,
			col = 29,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		st.Stack_Frame {
			line = 12774,
			col = 13,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/commitRoot/<",
		},
		st.Stack_Frame {
			line = 34,
			col = 58,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
		st.Stack_Frame {
			line = 154,
			col = 9,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "EventHandlerNonNull*node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/cjs/scheduler.development.js/<",
		},
		st.Stack_Frame {
			line = 264,
			col = 7,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/cjs/scheduler.development.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		st.Stack_Frame {
			line = 275,
			col = 24,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/index.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		st.Stack_Frame {
			line = 17257,
			col = 23,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/<",
		},
		st.Stack_Frame {
			line = 20175,
			col = 7,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		st.Stack_Frame {
			line = 20186,
			col = 24,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/client.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js",
			name = "__require",
		},
		st.Stack_Frame {
			line = 20190,
			col = 16,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "",
		},
	}
	stack_trace := #load("../../stacktraces/firefox-dev.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "firefox dev")
}

@(test)
test_parse_stack_trace_v3_zen_dev :: proc(t: ^testing.T) {
	test_frames := []st.Stack_Frame {
		st.Stack_Frame {
			line = 11,
			col = 19,
			pathname = "http://localhost:5173/src/App.tsx",
			name = "App/<",
		},
		st.Stack_Frame {
			line = 18565,
			col = 20,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "react_stack_bottom_frame",
		},
		st.Stack_Frame {
			line = 997,
			col = 15,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "runWithFiberInDEV",
		},
		st.Stack_Frame {
			line = 9409,
			col = 163,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookEffectListMount",
		},
		st.Stack_Frame {
			line = 9463,
			col = 60,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitHookPassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11038,
			col = 29,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "flushPassiveEffects",
		},
		st.Stack_Frame {
			line = 12774,
			col = 13,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/commitRoot/<",
		},
		st.Stack_Frame {
			line = 34,
			col = 58,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js",
			name = "performWorkUntilDeadline",
		},
	}
	stack_trace := #load("../../stacktraces/zen-dev.txt", string)
	stack_frames := parse_stack_trace_v3(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "zen dev")
}
