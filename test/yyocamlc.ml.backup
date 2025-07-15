(** 骆言编译器测试 *)

open Yyocamlc_lib
open Alcotest

(** 测试词法分析器 *)
let test_lexer_basic () =
  let input = "「x」为四二" in
  let token_list = Lexer.tokenize input "test" in
  let expected_tokens =
    [
      (Lexer.QuotedIdentifierToken "x", { Lexer.line = 1; column = 1; filename = "test" });
      (Lexer.AsForKeyword, { Lexer.line = 1; column = 6; filename = "test" });
      (Lexer.IdentifierToken "四二", { Lexer.line = 1; column = 9; filename = "test" });
      (Lexer.EOF, { Lexer.line = 1; column = 15; filename = "test" });
    ]
  in
  check int "词元数量" (List.length expected_tokens) (List.length token_list)

(** 测试中文关键字 *)
let test_lexer_chinese_keywords () =
  let input = "让 递归 函数 如果 那么 否则 匹配 与" in
  let token_list = Lexer.tokenize input "test" in
  let keywords =
    [
      Lexer.LetKeyword;
      Lexer.RecKeyword;
      Lexer.FunKeyword;
      Lexer.IfKeyword;
      Lexer.ThenKeyword;
      Lexer.ElseKeyword;
      Lexer.MatchKeyword;
      Lexer.WithKeyword;
    ]
  in
  let actual_keywords = List.map (fun (token, _) -> token) token_list in
  let keyword_tokens =
    List.filter
      (function
        | Lexer.LetKeyword | Lexer.RecKeyword | Lexer.FunKeyword | Lexer.IfKeyword
        | Lexer.ThenKeyword | Lexer.ElseKeyword | Lexer.MatchKeyword | Lexer.WithKeyword ->
            true
        | _ -> false)
      actual_keywords
  in
  check int "中文关键字数量" (List.length keywords) (List.length keyword_tokens)

(** 测试数字字面量 *)
let test_lexer_numbers () =
  let input = "四二 三 一零 零" in
  let token_list = Lexer.tokenize input "test" in
  let numbers =
    List.filter (function 
      | Lexer.IntToken _, _ -> true 
      | Lexer.OneKeyword, _ -> true 
      | Lexer.ChineseNumberToken _, _ -> true
      | Lexer.IdentifierToken ("四二" | "三" | "零"), _ -> true
      | _ -> false) token_list
  in
  check int "数字字面量数量" 5 (List.length numbers)

(** 测试字符串字面量 *)
let test_lexer_strings () =
  let input = "「hello」 「world」 「测试」" in
  let token_list = Lexer.tokenize input "test" in
  let quoted_identifiers =
    List.filter (function Lexer.QuotedIdentifierToken _, _ -> true | _ -> false) token_list
  in
  check int "引用标识符数量" 3 (List.length quoted_identifiers)

(** 测试运算符 *)
let test_lexer_operators () =
  let input = "加 减去 乘以" in
  let token_list = Lexer.tokenize input "test" in
  let operators =
    List.filter
      (function
        | Lexer.PlusKeyword, _ | Lexer.SubtractKeyword, _ | Lexer.MultiplyKeyword, _ -> true
        | _ -> false)
      token_list
  in
  check int "运算符数量" 3 (List.length operators)

(** 测试解析器 - 基本表达式 *)
let test_parser_basic () =
  let input = "设 「结果」 为 一 并加 二" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [
   Ast.LetStmt ("结果", Ast.BinaryOpExpr (Ast.LitExpr (Ast.IntLit 1), Ast.Add, Ast.VarExpr "二"));
  ] ->
      ()
  | _ -> failwith "解析结果不匹配"

(** 测试解析器 - 变量声明 *)
let test_parser_let_binding () =
  let input = "让 「x」 为 九" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [ Ast.LetStmt ("x", Ast.VarExpr "九") ] -> ()
  | _ -> failwith "变量声明解析失败"

(** 测试解析器 - 函数定义 *)
let test_parser_function () =
  let input = "让 「f」 为 函数 「x」 应得 「x」 加 一" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [
   Ast.LetStmt
     ( "f",
       Ast.FunExpr ([ "x" ], Ast.BinaryOpExpr (Ast.VarExpr "x", Ast.Add, Ast.LitExpr (Ast.IntLit 1)))
     );
  ] ->
      ()
  | _ -> failwith "函数定义解析失败"

(** 测试解析器 - 条件表达式 *)
let test_parser_conditional () =
  let input = "如果 （「x」 大于 零） 那么 一 否则 零" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [
   Ast.ExprStmt
     (Ast.CondExpr
        ( Ast.BinaryOpExpr (Ast.VarExpr "x", Ast.Gt, Ast.VarExpr "零"),
          Ast.LitExpr (Ast.IntLit 1),
          Ast.VarExpr "零" ));
  ] ->
      ()
  | _ -> failwith "条件表达式解析失败"

(** 测试解析器 - 递归函数定义 *)
let test_parser_recursive_function () =
  let input = "递归 让 「阶乘」 为 函数 「n」 故 如果 「n」 小于等于 一 那么 一 否则 「n」 乘以 「阶乘」 （「n」 减去 一）" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [
   Ast.RecLetStmt
     ( "阶乘",
       Ast.FunExpr
         ( [ "n" ],
           Ast.CondExpr
             ( Ast.BinaryOpExpr (Ast.VarExpr "n", Ast.Le, Ast.LitExpr (Ast.IntLit 1)),
               Ast.LitExpr (Ast.IntLit 1),
               Ast.BinaryOpExpr
                 ( Ast.VarExpr "n",
                   Ast.Mul,
                   Ast.FunCallExpr
                     ( Ast.VarExpr "阶乘",
                       [ Ast.BinaryOpExpr (Ast.VarExpr "n", Ast.Sub, Ast.LitExpr (Ast.IntLit 1)) ]
                     ) ) ) ) );
  ] ->
      ()
  | _ -> failwith "递归函数定义解析失败"

(** 测试解析器 - 模式匹配 *)
let test_parser_pattern_matching () =
  let input = "观 「x」 之 性 若 零 则 答 零 余者 则 答 一 观毕" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [
   Ast.ExprStmt
     (Ast.MatchExpr
        ( Ast.VarExpr "x",
          [
            {
              pattern = Ast.VarPattern "零";
              guard = None;
              expr = Ast.VarExpr "零";
            };
            { pattern = Ast.WildcardPattern; guard = None; expr = Ast.LitExpr (Ast.IntLit 1) };
          ] ));
  ] ->
      ()
  | _ -> failwith "模式匹配解析失败"

(** 测试代码生成 - 基本表达式求值 *)
let test_codegen_basic_evaluation () =
  let expr = Ast.BinaryOpExpr (Ast.LitExpr (Ast.IntLit 1), Ast.Add, Ast.LitExpr (Ast.IntLit 2)) in
  let result = Codegen.eval_expr [] expr in
  match result with Codegen.IntValue 3 -> () | _ -> failwith "求值结果不正确"

(** 测试代码生成 - 变量查找 *)
let test_codegen_variable_lookup () =
  let env = [ ("x", Codegen.IntValue 42) ] in
  let expr = Ast.VarExpr "x" in
  let result = Codegen.eval_expr env expr in
  match result with Codegen.IntValue 42 -> () | _ -> failwith "变量查找失败"

(** 测试代码生成 - 条件表达式 *)
let test_codegen_conditional () =
  let expr =
    Ast.CondExpr
      (Ast.LitExpr (Ast.BoolLit true), Ast.LitExpr (Ast.IntLit 1), Ast.LitExpr (Ast.IntLit 0))
  in
  let result = Codegen.eval_expr [] expr in
  match result with Codegen.IntValue 1 -> () | _ -> failwith "条件表达式求值失败"

(** 测试代码生成 - 函数调用 *)
let test_codegen_function_call () =
  let func_expr =
    Ast.FunExpr ([ "x" ], Ast.BinaryOpExpr (Ast.VarExpr "x", Ast.Add, Ast.LitExpr (Ast.IntLit 1)))
  in
  let call_expr = Ast.FunCallExpr (func_expr, [ Ast.LitExpr (Ast.IntLit 5) ]) in
  let result = Codegen.eval_expr [] call_expr in
  match result with Codegen.IntValue 6 -> () | _ -> failwith "函数调用求值失败"

(** 测试代码生成 - 内置函数 *)
let test_codegen_builtin_functions () =
  let env =
    [
      ( "打印",
        Codegen.BuiltinFunctionValue
          (function
          | [ Codegen.StringValue s ] ->
              print_endline s;
              Codegen.UnitValue
          | _ -> failwith "打印函数参数错误") );
    ]
  in
  let expr = Ast.FunCallExpr (Ast.VarExpr "打印", [ Ast.LitExpr (Ast.StringLit "测试") ]) in
  let result = Codegen.eval_expr env expr in
  match result with Codegen.UnitValue -> () | _ -> failwith "内置函数调用失败"

(** 测试代码生成 - 递归函数 *)
let test_codegen_recursive_function () =
  let program =
    [
      Ast.RecLetStmt
        ( "阶乘",
          Ast.FunExpr
            ( [ "n" ],
              Ast.CondExpr
                ( Ast.BinaryOpExpr (Ast.VarExpr "n", Ast.Le, Ast.LitExpr (Ast.IntLit 1)),
                  Ast.LitExpr (Ast.IntLit 1),
                  Ast.BinaryOpExpr
                    ( Ast.VarExpr "n",
                      Ast.Mul,
                      Ast.FunCallExpr
                        ( Ast.VarExpr "阶乘",
                          [
                            Ast.BinaryOpExpr (Ast.VarExpr "n", Ast.Sub, Ast.LitExpr (Ast.IntLit 1));
                          ] ) ) ) ) );
      Ast.LetStmt ("结果", Ast.FunCallExpr (Ast.VarExpr "阶乘", [ Ast.LitExpr (Ast.IntLit 5) ]));
    ]
  in
  let env = Codegen.empty_env in
  let final_env, _ =
    List.fold_left
      (fun (env, _) stmt -> Codegen.execute_stmt env stmt)
      (env, Codegen.UnitValue) program
  in
  let value = Codegen.lookup_var final_env "结果" in
  match value with Codegen.IntValue 120 -> () | _ -> failwith "递归函数求值失败"

(** 测试代码生成 - 模式匹配 *)
let test_codegen_pattern_matching () =
  let match_expr =
    Ast.MatchExpr
      ( Ast.LitExpr (Ast.IntLit 1),
        [
          {
            pattern = Ast.LitPattern (Ast.IntLit 0);
            guard = None;
            expr = Ast.LitExpr (Ast.StringLit "零");
          };
          {
            pattern = Ast.LitPattern (Ast.IntLit 1);
            guard = None;
            expr = Ast.LitExpr (Ast.StringLit "一");
          };
          { pattern = Ast.WildcardPattern; guard = None; expr = Ast.LitExpr (Ast.StringLit "其他") };
        ] )
  in
  let result = Codegen.eval_expr [] match_expr in
  match result with Codegen.StringValue "一" -> () | _ -> failwith "模式匹配求值失败"

(** 测试代码生成 - 取模运算 *)
let test_codegen_modulo () =
  let expr = Ast.BinaryOpExpr (Ast.LitExpr (Ast.IntLit 7), Ast.Mod, Ast.LitExpr (Ast.IntLit 3)) in
  let result = Codegen.eval_expr [] expr in
  match result with Codegen.IntValue 1 -> () (* 7 % 3 = 1 *) | _ -> failwith "取模运算求值失败"

(** 测试代码生成 - 列表模式匹配 *)
let test_codegen_list_pattern_matching () =
  let match_expr =
    Ast.MatchExpr
      ( Ast.ListExpr [ Ast.LitExpr (Ast.IntLit 1); Ast.LitExpr (Ast.IntLit 2) ],
        [
          { pattern = Ast.EmptyListPattern; guard = None; expr = Ast.LitExpr (Ast.StringLit "空列表") };
          {
            pattern = Ast.ConsPattern (Ast.VarPattern "head", Ast.VarPattern "tail");
            guard = None;
            expr = Ast.VarExpr "head";
          };
          { pattern = Ast.WildcardPattern; guard = None; expr = Ast.LitExpr (Ast.StringLit "其他") };
        ] )
  in
  let result = Codegen.eval_expr [] match_expr in
  match result with Codegen.IntValue 1 -> () (* 应该匹配到第一个元素 *) | _ -> failwith "列表模式匹配求值失败"

(** 测试代码生成 - 复杂递归函数 *)
let test_codegen_complex_recursive () =
  let program =
    [
      Ast.RecLetStmt
        ( "斐波那契",
          Ast.FunExpr
            ( [ "n" ],
              Ast.MatchExpr
                ( Ast.VarExpr "n",
                  [
                    {
                      pattern = Ast.LitPattern (Ast.IntLit 0);
                      guard = None;
                      expr = Ast.LitExpr (Ast.IntLit 0);
                    };
                    {
                      pattern = Ast.LitPattern (Ast.IntLit 1);
                      guard = None;
                      expr = Ast.LitExpr (Ast.IntLit 1);
                    };
                    {
                      pattern = Ast.WildcardPattern;
                      guard = None;
                      expr =
                        Ast.BinaryOpExpr
                          ( Ast.FunCallExpr
                              ( Ast.VarExpr "斐波那契",
                                [
                                  Ast.BinaryOpExpr
                                    (Ast.VarExpr "n", Ast.Sub, Ast.LitExpr (Ast.IntLit 1));
                                ] ),
                            Ast.Add,
                            Ast.FunCallExpr
                              ( Ast.VarExpr "斐波那契",
                                [
                                  Ast.BinaryOpExpr
                                    (Ast.VarExpr "n", Ast.Sub, Ast.LitExpr (Ast.IntLit 2));
                                ] ) );
                    };
                  ] ) ) );
      Ast.LetStmt ("结果", Ast.FunCallExpr (Ast.VarExpr "斐波那契", [ Ast.LitExpr (Ast.IntLit 6) ]));
    ]
  in
  let env = Codegen.empty_env in
  let final_env, _ =
    List.fold_left
      (fun (env, _) stmt -> Codegen.execute_stmt env stmt)
      (env, Codegen.UnitValue) program
  in
  let value = Codegen.lookup_var final_env "结果" in
  match value with Codegen.IntValue 8 -> () (* F(6) = 8 *) | _ -> failwith "复杂递归函数求值失败"

(** 测试错误处理 - 词法错误 *)
let test_error_handling_lexer () =
  try
    let _ = Lexer.tokenize "让 「x」 为 『unclosed_string" "test" in
    failwith "应该检测到词法错误"
  with
  | Lexer.LexError _ -> () (* 期望的错误 *)
  | _ -> failwith "意外的错误类型"

(** 测试错误处理 - 语法错误 *)
let test_error_handling_parser () =
  try
    let tokens = Lexer.tokenize "定义 加 加 一" "test" in
    let _ = Parser.parse_program tokens in
    failwith "应该检测到语法错误"
  with
  | Parser.SyntaxError _ -> () (* 期望的错误 *)
  | _ -> failwith "意外的错误类型"

(** 测试错误处理 - 运行时错误 *)
let test_error_handling_runtime () =
  try
    let expr = Ast.FunCallExpr (Ast.VarExpr "未定义函数", []) in
    let _ = Codegen.eval_expr [] expr in
    failwith "应该检测到运行时错误"
  with
  | Codegen.RuntimeError _ -> () (* 期望的错误 *)
  | _ -> failwith "意外的错误类型"

(** 测试模块系统 - 基础功能 *)
let test_module_basic () =
  let program =
    [
      Ast.ModuleDefStmt
        {
          module_def_name = "测试模块";
          module_type_annotation = None;
          exports = [];
          statements =
            [
              Ast.LetStmt ("x", Ast.LitExpr (Ast.IntLit 42));
              Ast.LetStmt ("y", Ast.LitExpr (Ast.StringLit "hello"));
            ];
        };
      Ast.LetStmt ("结果", Ast.VarExpr "测试模块.x");
    ]
  in
  let env = Codegen.empty_env in
  let final_env, _ =
    List.fold_left
      (fun (env, _) stmt -> Codegen.execute_stmt env stmt)
      (env, Codegen.UnitValue) program
  in
  let value = Codegen.lookup_var final_env "结果" in
  match value with Codegen.IntValue 42 -> () | _ -> failwith "模块变量访问失败"

(** 测试模块系统 - 函数访问 *)
let test_module_function () =
  let program =
    [
      Ast.ModuleDefStmt
        {
          module_def_name = "数学";
          module_type_annotation = None;
          exports = [];
          statements =
            [
              Ast.LetStmt
                ( "加法",
                  Ast.FunExpr
                    ([ "x"; "y" ], Ast.BinaryOpExpr (Ast.VarExpr "x", Ast.Add, Ast.VarExpr "y")) );
            ];
        };
      Ast.LetStmt
        ( "结果",
          Ast.FunCallExpr
            (Ast.VarExpr "数学.加法", [ Ast.LitExpr (Ast.IntLit 3); Ast.LitExpr (Ast.IntLit 4) ]) );
    ]
  in
  let env = Codegen.empty_env in
  let final_env, _ =
    List.fold_left
      (fun (env, _) stmt -> Codegen.execute_stmt env stmt)
      (env, Codegen.UnitValue) program
  in
  let value = Codegen.lookup_var final_env "结果" in
  match value with Codegen.IntValue 7 -> () | _ -> failwith "模块函数调用失败"

(** 集成测试 - 完整程序编译和执行 *)
let test_integration_complete_program () =
  let program =
    [
      Ast.LetStmt ("x", Ast.LitExpr (Ast.IntLit 10));
      Ast.LetStmt ("y", Ast.LitExpr (Ast.IntLit 20));
      Ast.ExprStmt (Ast.BinaryOpExpr (Ast.VarExpr "x", Ast.Add, Ast.VarExpr "y"));
    ]
  in

  (* 执行 *)
  let result = Codegen.interpret program in
  check bool "程序执行成功" true result

(** 集成测试 - 阶乘计算程序 *)
let test_integration_factorial_program () =
  let program =
    [
      Ast.RecLetStmt
        ( "阶乘",
          Ast.FunExpr
            ( [ "n" ],
              Ast.CondExpr
                ( Ast.BinaryOpExpr (Ast.VarExpr "n", Ast.Le, Ast.LitExpr (Ast.IntLit 1)),
                  Ast.LitExpr (Ast.IntLit 1),
                  Ast.BinaryOpExpr
                    ( Ast.VarExpr "n",
                      Ast.Mul,
                      Ast.FunCallExpr
                        ( Ast.VarExpr "阶乘",
                          [
                            Ast.BinaryOpExpr (Ast.VarExpr "n", Ast.Sub, Ast.LitExpr (Ast.IntLit 1));
                          ] ) ) ) ) );
      Ast.LetStmt ("结果", Ast.FunCallExpr (Ast.VarExpr "阶乘", [ Ast.LitExpr (Ast.IntLit 5) ]));
    ]
  in
  let env = Codegen.empty_env in
  let final_env, _ =
    List.fold_left
      (fun (env, _) stmt -> Codegen.execute_stmt env stmt)
      (env, Codegen.UnitValue) program
  in
  let value = Codegen.lookup_var final_env "结果" in
  match value with Codegen.IntValue 120 -> () | _ -> failwith "阶乘程序执行失败"

(** 测试套件 *)
let () =
  run "骆言编译器测试"
    [
      ( "词法分析器",
        [
          test_case "基本词法分析" `Quick test_lexer_basic;
          test_case "中文关键字识别" `Quick test_lexer_chinese_keywords;
          test_case "数字字面量" `Quick test_lexer_numbers;
          test_case "字符串字面量" `Quick test_lexer_strings;
          test_case "运算符识别" `Quick test_lexer_operators;
        ] );
      ( "语法分析器",
        [
          test_case "基本表达式解析" `Quick test_parser_basic;
          test_case "变量声明解析" `Quick test_parser_let_binding;
          test_case "函数定义解析" `Quick test_parser_function;
          test_case "条件表达式解析" `Quick test_parser_conditional;
          test_case "递归函数定义解析" `Quick test_parser_recursive_function;
          test_case "模式匹配解析" `Quick test_parser_pattern_matching;
        ] );
      ( "代码生成",
        [
          test_case "基本表达式求值" `Quick test_codegen_basic_evaluation;
          test_case "变量查找" `Quick test_codegen_variable_lookup;
          test_case "条件表达式求值" `Quick test_codegen_conditional;
          test_case "函数调用" `Quick test_codegen_function_call;
          test_case "内置函数" `Quick test_codegen_builtin_functions;
          test_case "递归函数" `Quick test_codegen_recursive_function;
          test_case "模式匹配" `Quick test_codegen_pattern_matching;
          test_case "取模运算" `Quick test_codegen_modulo;
          test_case "列表模式匹配" `Quick test_codegen_list_pattern_matching;
          test_case "复杂递归函数" `Quick test_codegen_complex_recursive;
        ] );
      ( "错误处理",
        [
          test_case "词法错误处理" `Quick test_error_handling_lexer;
          test_case "语法错误处理" `Quick test_error_handling_parser;
          test_case "运行时错误处理" `Quick test_error_handling_runtime;
        ] );
      ( "模块系统",
        [
          test_case "模块定义和变量访问" `Quick test_module_basic;
          test_case "模块函数调用" `Quick test_module_function;
        ] );
      ( "集成测试",
        [
          test_case "完整程序编译和执行" `Quick test_integration_complete_program;
          test_case "阶乘计算程序" `Quick test_integration_factorial_program;
        ] );
    ]

