#+build !wasm32
#+build !wasm64p32

package stack_trace_v2

import st "../"
import test_utils "../../test_utils"
import "core:testing"

@(test)
test_parse_stack_trace_v2_chromium_build :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/chromium-build.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "chromium build")
}

@(test)
test_parse_stack_trace_v2_chromium_dev :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/chromium-dev.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "chromium dev")
}

@(test)
test_parse_stack_trace_v2_node :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/node.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "node")
}

@(test)
test_parse_stack_trace_v2_bun :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/bun.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "bun")
}

@(test)
test_parse_stack_trace_v2_safari_build :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/safari-build.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "safari build")
}

@(test)
test_parse_stack_trace_v2_safari_dev :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/safari-dev.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "safari dev")
}

@(test)
test_parse_stack_trace_v2_firefox_build :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/firefox-build.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "firefox build")
}

@(test)
test_parse_stack_trace_v2_zen_build :: proc(t: ^testing.T) {
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
	stack_trace := #load("../../../stacktraces/zen-build.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "zen build")
}

@(test)
test_parse_stack_trace_v2_firefox_dev :: proc(t: ^testing.T) {
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
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "react_stack_bottom_frame",
		},
		st.Stack_Frame {
			line = 997,
			col = 15,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "runWithFiberInDEV",
		},
		st.Stack_Frame {
			line = 9409,
			col = 163,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitHookEffectListMount",
		},
		st.Stack_Frame {
			line = 9463,
			col = 60,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitHookPassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11038,
			col = 29,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "flushPassiveEffects",
		},
		st.Stack_Frame {
			line = 12774,
			col = 13,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/commitRoot/<",
		},
		st.Stack_Frame {
			line = 34,
			col = 58,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "performWorkUntilDeadline",
		},
		st.Stack_Frame {
			line = 154,
			col = 9,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "EventHandlerNonNull*node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/cjs/scheduler.development.js/<",
		},
		st.Stack_Frame {
			line = 264,
			col = 7,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/cjs/scheduler.development.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js?v=b7a7de0f",
			name = "__require",
		},
		st.Stack_Frame {
			line = 275,
			col = 24,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/scheduler@0.27.0/node_modules/scheduler/index.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js?v=b7a7de0f",
			name = "__require",
		},
		st.Stack_Frame {
			line = 17257,
			col = 23,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/<",
		},
		st.Stack_Frame {
			line = 20175,
			col = 7,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js?v=b7a7de0f",
			name = "__require",
		},
		st.Stack_Frame {
			line = 20186,
			col = 24,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/client.js",
		},
		st.Stack_Frame {
			line = 3,
			col = 50,
			pathname = "http://localhost:5173/node_modules/.vite/deps/chunk-FOAMPUX3.js?v=b7a7de0f",
			name = "__require",
		},
		st.Stack_Frame {
			line = 20190,
			col = 16,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "",
		},
	}
	stack_trace := #load("../../../stacktraces/firefox-dev.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "firefox dev")
}

@(test)
test_parse_stack_trace_v2_zen_dev :: proc(t: ^testing.T) {
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
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "react_stack_bottom_frame",
		},
		st.Stack_Frame {
			line = 997,
			col = 15,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "runWithFiberInDEV",
		},
		st.Stack_Frame {
			line = 9409,
			col = 163,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitHookEffectListMount",
		},
		st.Stack_Frame {
			line = 9463,
			col = 60,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitHookPassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11038,
			col = 29,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11199,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 11008,
			col = 38,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "recursivelyTraversePassiveMountEffects",
		},
		st.Stack_Frame {
			line = 11064,
			col = 51,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "commitPassiveMountOnFiber",
		},
		st.Stack_Frame {
			line = 13148,
			col = 36,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "flushPassiveEffects",
		},
		st.Stack_Frame {
			line = 12774,
			col = 13,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "node_modules/.pnpm/react-dom@19.2.4_react@19.2.4/node_modules/react-dom/cjs/react-dom-client.development.js/commitRoot/<",
		},
		st.Stack_Frame {
			line = 34,
			col = 58,
			pathname = "http://localhost:5173/node_modules/.vite/deps/react-dom_client.js?v=d2bf3542",
			name = "performWorkUntilDeadline",
		},
	}
	stack_trace := #load("../../../stacktraces/zen-dev.txt", string)
	stack_frames := parse_stack_trace_v2(stack_trace)
	defer delete(stack_frames)
	test_utils.expect_slice(t, stack_frames, test_frames, "zen dev")
}

@(test)
test_token_trim :: proc(t: ^testing.T) {
	test_utils.expect_slice(t, token_trim([]Token{}), []Token{}, "#1")
	test_utils.expect_slice(
		t,
		token_trim([]Token{{0, 0, .WHITESPACE}, {0, 0, .WHITESPACE}}),
		[]Token{},
		"#2",
	)
	test_utils.expect_slice(
		t,
		token_trim([]Token{{0, 0, .WHITESPACE}, {0, 0, .DIGIT}}),
		[]Token{{0, 0, .DIGIT}},
		"#3",
	)
	test_utils.expect_slice(
		t,
		token_trim([]Token{{0, 0, .DIGIT}, {0, 0, .WHITESPACE}}),
		[]Token{{0, 0, .DIGIT}},
		"#4",
	)
	test_utils.expect_slice(
		t,
		token_trim([]Token{{0, 0, .WHITESPACE}, {0, 0, .DIGIT}, {0, 0, .WHITESPACE}}),
		[]Token{{0, 0, .DIGIT}},
		"#4",
	)
}

@(test)
test_tokenize_stack_frame :: proc(t: ^testing.T) {
	m: map[string][]Token
	defer delete(m)

	m["      at d (/Volumes/Work/Github/sourcemaps-v3-transformer/error.js:14:13)"] = {
		{0, 6, .WHITESPACE},
		{6, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 10, .WORD},
		{10, 11, .WHITESPACE},
		{11, 12, .BRACKET_OPENING},
		{12, 45, .WORD},
		{45, 46, .DIGIT},
		{46, 67, .WORD},
		{67, 68, .COLON},
		{68, 70, .DIGIT},
		{70, 71, .COLON},
		{71, 73, .DIGIT},
		{73, 74, .BRACKET_CLOSING},
	}
	m["      at loadAndEvaluateModule (2:1)"] = {
		{0, 6, .WHITESPACE},
		{6, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 30, .WORD},
		{30, 31, .WHITESPACE},
		{31, 32, .BRACKET_OPENING},
		{32, 33, .DIGIT},
		{33, 34, .COLON},
		{34, 35, .DIGIT},
		{35, 36, .BRACKET_CLOSING},
	}
	m["    at http://localhost:4173/assets/index-D6p3_k4u.js:8:132070"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 11, .WORD},
		{11, 12, .COLON},
		{12, 23, .WORD},
		{23, 24, .COLON},
		{24, 28, .DIGIT},
		{28, 43, .WORD},
		{43, 44, .DIGIT},
		{44, 45, .WORD},
		{45, 46, .DIGIT},
		{46, 48, .WORD},
		{48, 49, .DIGIT},
		{49, 53, .WORD},
		{53, 54, .COLON},
		{54, 55, .DIGIT},
		{55, 56, .COLON},
		{56, 62, .DIGIT},
	}
	m["    at d (file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js:14:9)"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 10, .BRACKET_OPENING},
		{10, 14, .WORD},
		{14, 15, .COLON},
		{15, 50, .WORD},
		{50, 51, .DIGIT},
		{51, 72, .WORD},
		{72, 73, .COLON},
		{73, 75, .DIGIT},
		{75, 76, .COLON},
		{76, 77, .DIGIT},
		{77, 78, .BRACKET_CLOSING},
	}
	m["    at file:///Volumes/Work/Github/sourcemaps-v3-transformer/error.js:17:1"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 11, .WORD},
		{11, 12, .COLON},
		{12, 47, .WORD},
		{47, 48, .DIGIT},
		{48, 69, .WORD},
		{69, 70, .COLON},
		{70, 72, .DIGIT},
		{72, 73, .COLON},
		{73, 74, .DIGIT},
	}
	m["U@http://localhost:4173/assets/index-D6p3_k4u.js:9:37404"] = {
		{0, 1, .WORD},
		{1, 2, .AT},
		{2, 6, .WORD},
		{6, 7, .COLON},
		{7, 18, .WORD},
		{18, 19, .COLON},
		{19, 23, .DIGIT},
		{23, 38, .WORD},
		{38, 39, .DIGIT},
		{39, 40, .WORD},
		{40, 41, .DIGIT},
		{41, 43, .WORD},
		{43, 44, .DIGIT},
		{44, 48, .WORD},
		{48, 49, .COLON},
		{49, 50, .DIGIT},
		{50, 51, .COLON},
		{51, 56, .DIGIT},
	}
	m["P1/Xc/<@http://localhost:4173/assets/index-D6p3_k4u.js:8:132072"] = {
		{0, 1, .WORD},
		{1, 2, .DIGIT},
		{2, 7, .WORD},
		{7, 8, .AT},
		{8, 12, .WORD},
		{12, 13, .COLON},
		{13, 24, .WORD},
		{24, 25, .COLON},
		{25, 29, .DIGIT},
		{29, 44, .WORD},
		{44, 45, .DIGIT},
		{45, 46, .WORD},
		{46, 47, .DIGIT},
		{47, 49, .WORD},
		{49, 50, .DIGIT},
		{50, 54, .WORD},
		{54, 55, .COLON},
		{55, 56, .DIGIT},
		{56, 57, .COLON},
		{57, 63, .DIGIT},
	}
	m["    at async asyncRunEntryPointWithESMLoader (node:internal/modules/run_main:117:5)"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 12, .WORD},
		{12, 13, .WHITESPACE},
		{13, 44, .WORD},
		{44, 45, .WHITESPACE},
		{45, 46, .BRACKET_OPENING},
		{46, 50, .WORD},
		{50, 51, .COLON},
		{51, 76, .WORD},
		{76, 77, .COLON},
		{77, 80, .DIGIT},
		{80, 81, .COLON},
		{81, 82, .DIGIT},
		{82, 83, .BRACKET_CLOSING},
	}
	m["@http://localhost:4173/assets/index-D6p3_k4u.js:8:132072"] = {
		{0, 1, .AT},
		{1, 5, .WORD},
		{5, 6, .COLON},
		{6, 17, .WORD},
		{17, 18, .COLON},
		{18, 22, .DIGIT},
		{22, 37, .WORD},
		{37, 38, .DIGIT},
		{38, 39, .WORD},
		{39, 40, .DIGIT},
		{40, 42, .WORD},
		{42, 43, .DIGIT},
		{43, 47, .WORD},
		{47, 48, .COLON},
		{48, 49, .DIGIT},
		{49, 50, .COLON},
		{50, 56, .DIGIT},
	}
	m["    at U (http://localhost:4173/assets/index.js:9:37404)"] = {
		{0, 4, .WHITESPACE},
		{4, 6, .WORD},
		{6, 7, .WHITESPACE},
		{7, 8, .WORD},
		{8, 9, .WHITESPACE},
		{9, 10, .BRACKET_OPENING},
		{10, 14, .WORD},
		{14, 15, .COLON},
		{15, 26, .WORD},
		{26, 27, .COLON},
		{27, 31, .DIGIT},
		{31, 47, .WORD},
		{47, 48, .COLON},
		{48, 49, .DIGIT},
		{49, 50, .COLON},
		{50, 55, .DIGIT},
		{55, 56, .BRACKET_CLOSING},
	}

	token_buffer := make([dynamic]Token, context.temp_allocator)
	for key, value in m {
		tokens := tokenize_stack_frame(key, &token_buffer)
		test_utils.expect_slice(t, tokens, value, key)
	}
}
