open Yyocamlc_lib.Ast
open Yyocamlc_lib.Nlf_semantic

let test_semantic_analysis () =
  Printf.printf "🧪 自然语言函数语义分析测试\n\n";
  
  (* 测试递归阶乘函数 *)
  let factorial_body = 
    CondExpr (
      BinaryOpExpr (VarExpr "n", Le, LitExpr (IntLit 1)),
      LitExpr (IntLit 1),
      BinaryOpExpr (
        VarExpr "n", 
        Mul, 
        FunCallExpr (VarExpr "factorial", [BinaryOpExpr (VarExpr "n", Sub, LitExpr (IntLit 1))])
      )
    ) in
  
  let semantic_info = analyze_natural_function_semantics "factorial" ["n"] factorial_body in
  
  Printf.printf "=== 阶乘函数语义分析 ===\n";
  Printf.printf "函数名: %s\n" semantic_info.function_name;
  Printf.printf "是否递归: %s\n" (if semantic_info.is_recursive then "是" else "否");
  Printf.printf "复杂度级别: %d\n" semantic_info.complexity_level;
  (match semantic_info.return_type_hint with
   | Some typ -> Printf.printf "推断返回类型: %s\n" typ
   | None -> Printf.printf "推断返回类型: 未知\n");
  
  Printf.printf "\n参数绑定分析:\n";
  List.iter (fun binding ->
    Printf.printf "  参数「%s」:\n" binding.param_name;
    Printf.printf "    递归上下文: %s\n" (if binding.is_recursive_context then "是" else "否");
    Printf.printf "    使用模式: %s\n" (String.concat ", " binding.usage_patterns);
  ) semantic_info.parameter_bindings;
  
  (* 验证语义一致性 *)
  let validation_errors = validate_semantic_consistency semantic_info in
  Printf.printf "\n语义一致性验证:\n";
  if List.length validation_errors = 0 then
    Printf.printf "  ✓ 无语义问题\n"
  else
    List.iter (fun err -> Printf.printf "  ⚠ %s\n" err) validation_errors;
  
  (* 测试简单函数 *)
  Printf.printf "\n=== 简单函数语义分析 ===\n";
  let simple_body = BinaryOpExpr (VarExpr "x", Add, LitExpr (IntLit 1)) in
  let simple_info = analyze_natural_function_semantics "增一" ["x"] simple_body in
  
  Printf.printf "函数名: %s\n" simple_info.function_name;
  Printf.printf "是否递归: %s\n" (if simple_info.is_recursive then "是" else "否");
  Printf.printf "复杂度级别: %d\n" simple_info.complexity_level;
  (match simple_info.return_type_hint with
   | Some typ -> Printf.printf "推断返回类型: %s\n" typ
   | None -> Printf.printf "推断返回类型: 未知\n");
  
  Printf.printf "\n🎉 语义分析测试完成！\n"

let () = test_semantic_analysis ()