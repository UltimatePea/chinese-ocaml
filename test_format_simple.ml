open Yyocamlc_lib

let () =
  (* 测试现有的格式化函数 *)
  let result1 = String_processing_utils.CCodegenFormatting.function_call "test_func" ["arg1"; "arg2"] in
  Printf.printf "现有函数测试: %s\n" result1;
  
  (* 测试新添加的函数 *)
  try
    let result2 = String_processing_utils.CCodegenFormatting.env_bind "var" "value" in
    Printf.printf "新函数测试: %s\n" result2
  with
  | _ -> Printf.printf "新函数不可用\n"