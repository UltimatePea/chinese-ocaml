(** 编译器错误创建函数测试 - 骆言编译器 *)

open Yyocamlc_lib.Compiler_errors_types
open Yyocamlc_lib.Compiler_errors_creation

(** 测试位置信息创建 *)
let test_make_position () =
  let pos1 = make_position 1 5 in
  assert (pos1.filename = "");
  assert (pos1.line = 1);
  assert (pos1.column = 5);
  
  let pos2 = make_position ~filename:"test.ly" 10 20 in
  assert (pos2.filename = "test.ly");
  assert (pos2.line = 10);
  assert (pos2.column = 20);
  print_endline "✓ 位置信息创建测试通过"

(** 测试错误信息创建 *)
let test_make_error_info () =
  let error = LexError ("测试词法错误", make_position 1 1) in
  let info1 = make_error_info error in
  assert (info1.error = error);
  assert (info1.severity = Error);
  assert (info1.context = None);
  assert (info1.suggestions = []);
  
  let suggestions = ["建议1"; "建议2"] in
  let context = Some "测试上下文" in
  let info2 = make_error_info ~severity:Warning ~context ~suggestions error in
  assert (info2.severity = Warning);
  assert (info2.context = context);
  assert (info2.suggestions = suggestions);
  print_endline "✓ 错误信息创建测试通过"

(** 测试词法错误创建 *)
let test_lex_error () =
  let pos = make_position ~filename:"test.ly" 1 5 in
  let result = lex_error "非法字符" pos in
  match result with
  | Error info ->
    (match info.error with
     | LexError (msg, p) ->
       assert (msg = "非法字符");
       assert (p = pos);
       assert (info.severity = Error);
       print_endline "✓ 词法错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试语法解析错误创建 *)
let test_parse_error () =
  let pos = make_position ~filename:"test.ly" 2 10 in
  let suggestions = ["检查语法格式"; "查阅语言参考"] in
  let result = parse_error ~suggestions "意外的符号" pos in
  match result with
  | Error info ->
    (match info.error with
     | ParseError (msg, p) ->
       assert (msg = "意外的符号");
       assert (p = pos);
       assert (info.suggestions = suggestions);
       print_endline "✓ 语法解析错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试语法错误创建 *)
let test_syntax_error () =
  let pos = make_position ~filename:"syntax.ly" 5 15 in
  let result = syntax_error "语法结构错误" pos in
  match result with
  | Error info ->
    (match info.error with
     | SyntaxError (msg, p) ->
       assert (msg = "语法结构错误");
       assert (p = pos);
       print_endline "✓ 语法错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试诗词解析错误创建 *)
let test_poetry_parse_error () =
  let pos = Some (make_position ~filename:"poem.ly" 3 8) in
  let result = poetry_parse_error "诗词格式不正确" pos in
  match result with
  | Error info ->
    (match info.error with
     | PoetryParseError (msg, p) ->
       assert (msg = "诗词格式不正确");
       assert (p = pos);
       print_endline "✓ 诗词解析错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试类型错误创建 *)
let test_type_error () =
  let pos = Some (make_position ~filename:"type.ly" 7 20) in
  let suggestions = ["检查类型声明"; "确认变量类型"] in
  let result = type_error ~suggestions "类型不匹配" pos in
  match result with
  | Error info ->
    (match info.error with
     | TypeError (msg, p) ->
       assert (msg = "类型不匹配");
       assert (p = pos);
       assert (info.suggestions = suggestions);
       print_endline "✓ 类型错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试语义错误创建 *)
let test_semantic_error () =
  let pos = Some (make_position ~filename:"semantic.ly" 12 25) in
  let result = semantic_error "变量未定义" pos in
  match result with
  | Error info ->
    (match info.error with
     | SemanticError (msg, p) ->
       assert (msg = "变量未定义");
       assert (p = pos);
       print_endline "✓ 语义错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试代码生成错误创建 *)
let test_codegen_error () =
  let context = "函数调用生成" in
  let result = codegen_error ~context "无法生成C代码" in
  match result with
  | Error info ->
    (match info.error with
     | CodegenError (msg, ctx) ->
       assert (msg = "无法生成C代码");
       assert (ctx = context);
       print_endline "✓ 代码生成错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 测试未实现功能错误创建 *)
let test_unimplemented_feature () =
  let feature = "模式匹配" in
  let context = "C代码生成器" in
  let custom_suggestions = ["可以使用解释器"] in
  let result = unimplemented_feature ~context ~suggestions:custom_suggestions feature in
  match result with
  | Error info ->
    (match info.error with
     | UnimplementedFeature (f, ctx) ->
       assert (f = feature);
       assert (ctx = context);
       assert (List.length info.suggestions = 4); (* 1 custom + 3 default *)
       assert (List.hd info.suggestions = "可以使用解释器");
       print_endline "✓ 未实现功能错误创建测试通过"
     | _ -> assert false)
  | Ok _ -> assert false

(** 运行所有测试 *)
let () =
  print_endline "开始运行编译器错误创建函数测试...";
  test_make_position ();
  test_make_error_info ();
  test_lex_error ();
  test_parse_error ();
  test_syntax_error ();
  test_poetry_parse_error ();
  test_type_error ();
  test_semantic_error ();
  test_codegen_error ();
  test_unimplemented_feature ();
  print_endline "🎉 所有编译器错误创建函数测试通过！"