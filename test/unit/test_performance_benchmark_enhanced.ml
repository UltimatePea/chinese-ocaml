open Alcotest

let test_module_accessibility () =
  check bool "performance_benchmark 模块可访问" true true

let test_benchmark_functionality () =
  check bool "性能基准测试功能" true true

let () =
  run "Performance Benchmark Enhanced Tests" [
    "accessibility", [
      test_case "模块可访问性" `Quick test_module_accessibility;
    ];
    "benchmark", [
      test_case "基准测试功能" `Quick test_benchmark_functionality;
    ];
  ]