(* AI模块测试 - 智能文档生成器测试 *)
open Ai.Intelligent_doc_generator

(* 从生产代码中提取的测试函数 *)
let test_doc_generation () =
  Printf.printf "=== 智能文档生成器测试 ===\n\n";

  (* 测试用例：斐波那契函数 *)
  let fibonacci_body =
    make_condition
      (make_binary (make_variable "n") "<=" (make_literal "1"))
      (make_variable "n")
      (make_binary
         (make_function_call "斐波那契" [ make_binary (make_variable "n") "-" (make_literal "1") ])
         "+"
         (make_function_call "斐波那契" [ make_binary (make_variable "n") "-" (make_literal "2") ]))
  in

  let fib_info = make_function_info "斐波那契" [ "n" ] fibonacci_body true in
  let fib_doc = generate_function_documentation fib_info default_config in

  Printf.printf "函数: 斐波那契\n";
  Printf.printf "概要: %s\n" fib_doc.summary;
  Printf.printf "参数:\n";
  List.iter (fun (param, desc) -> Printf.printf "  %s: %s\n" param desc) fib_doc.parameters;
  Printf.printf "返回值: %s\n" fib_doc.return_value;
  Printf.printf "示例:\n";
  List.iter (fun example -> Printf.printf "  %s\n" example) fib_doc.examples;
  Printf.printf "置信度: %.0f%%\n\n" (fib_doc.confidence *. 100.0);

  (* 测试Markdown格式化 *)
  Printf.printf "=== Markdown格式 ===\n";
  Printf.printf "%s\n" (format_as_markdown fib_doc "斐波那契");

  (* 测试OCaml文档格式化 *)
  Printf.printf "=== OCaml文档格式 ===\n";
  Printf.printf "%s\n" (format_as_ocaml_doc fib_doc "斐波那契");

  Printf.printf "✅ 智能文档生成器测试完成！\n"

(* 运行测试 *)
let () = test_doc_generation ()
