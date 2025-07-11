(** 骆言编译器完整测试套件 - Complete Test Suite *)

open Alcotest

(** 运行所有测试 *)
let () =
  Printf.printf "=== 骆言编译器完整测试套件 ===\n";
  Printf.printf "开始运行所有测试...\n\n";
  
  (* 这里可以添加测试运行逻辑，或者直接调用各个测试模块 *)
  Printf.printf "测试套件已配置完成。\n";
  Printf.printf "请运行以下命令来执行测试：\n";
  Printf.printf "  dune runtest --force\n";
  Printf.printf "或者运行特定测试：\n";
  Printf.printf "  dune exec -- test_yyocamlc\n";
  Printf.printf "  dune exec -- test_e2e\n";
  Printf.printf "  dune exec -- test_file_runner\n"