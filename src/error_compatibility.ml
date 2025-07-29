(** 错误处理兼容性层实现 - 为遗留错误类型提供现代化接口

    Author: Alpha, 主要工作代理 Purpose: Fix #1646 - 错误处理系统现代化 *)

open Compiler_errors_types

(** {1 位置信息工具} *)

let create_position ~filename ~line ~column = { filename; line; column }
let position_from_line_col ~filename ~line ~column = create_position ~filename ~line ~column
let unknown_position ~filename = create_position ~filename ~line:0 ~column:0

(** {1 错误建议工具} *)

let suggest_similar_identifier target candidates =
  (* 简单的编辑距离建议算法 *)
  let levenshtein_distance s1 s2 =
    let len1, len2 = (String.length s1, String.length s2) in
    let matrix = Array.make_matrix (len1 + 1) (len2 + 1) 0 in

    (* 初始化矩阵 *)
    for i = 0 to len1 do
      matrix.(i).(0) <- i
    done;
    for j = 0 to len2 do
      matrix.(0).(j) <- j
    done;

    (* 计算编辑距离 *)
    for i = 1 to len1 do
      for j = 1 to len2 do
        let cost = if s1.[i - 1] = s2.[j - 1] then 0 else 1 in
        matrix.(i).(j) <-
          min
            (matrix.(i - 1).(j) + 1) (* 删除 *)
            (min (matrix.(i).(j - 1) + 1) (* 插入 *) (matrix.(i - 1).(j - 1) + cost) (* 替换 *))
      done
    done;
    matrix.(len1).(len2)
  in

  (* 找到距离最近的候选项 *)
  let rec take n lst =
    match (n, lst) with 0, _ | _, [] -> [] | n, x :: xs -> x :: take (n - 1) xs
  in
  candidates
  |> List.map (fun candidate -> (candidate, levenshtein_distance target candidate))
  |> List.filter (fun (_, distance) -> distance <= 3) (* 只考虑距离 <= 3 的候选项 *)
  |> List.sort (fun (_, d1) (_, d2) -> compare d1 d2)
  |> List.map fst
  |> function
  | [] -> []
  | suggestions -> take (min 3 (List.length suggestions)) suggestions

let suggest_type_fix ~expected ~actual =
  [ Printf.sprintf "期望类型：%s，实际类型：%s" expected actual; "检查变量类型是否正确"; "考虑使用类型转换函数" ]

let suggest_syntax_fix ~expected = [ Printf.sprintf "期望：%s" expected; "检查语法是否正确"; "参考语言规范文档" ]

(** {1 现代错误创建函数} *)

let create_type_error ?pos ?(suggestions = []) msg =
  let error_info =
    { error = TypeError (msg, pos); severity = Error; context = None; suggestions }
  in
  raise (CompilerError error_info)

let create_parse_error ~pos ?(suggestions = []) msg =
  let error_info =
    { error = ParseError (msg, pos); severity = Error; context = None; suggestions }
  in
  raise (CompilerError error_info)

let create_syntax_error ~pos ?(suggestions = []) msg =
  let error_info =
    { error = SyntaxError (msg, pos); severity = Error; context = None; suggestions }
  in
  raise (CompilerError error_info)

let create_semantic_error ?pos ?context ?(suggestions = []) msg =
  let error_info = { error = SemanticError (msg, pos); severity = Error; context; suggestions } in
  raise (CompilerError error_info)

let create_codegen_error ~context ?(suggestions = []) msg =
  let error_info =
    { error = CodegenError (msg, context); severity = Error; context = Some context; suggestions }
  in
  raise (CompilerError error_info)

let create_runtime_error ?pos ?(suggestions = []) msg =
  let error_info =
    { error = RuntimeError (msg, pos); severity = Error; context = None; suggestions }
  in
  raise (CompilerError error_info)

(** {1 遗留异常适配器} *)

let legacy_type_error msg = create_type_error msg ~suggestions:[ "使用现代类型检查系统" ]

let legacy_parse_error msg line column =
  let pos = create_position ~filename:"<unknown>" ~line ~column in
  create_parse_error ~pos msg ~suggestions:[ "检查语法规范"; "使用现代解析器" ]

let legacy_codegen_error msg context =
  create_codegen_error ~context msg ~suggestions:[ "检查代码生成逻辑"; "使用现代代码生成器" ]

let legacy_semantic_error msg context =
  create_semantic_error msg ~context ~suggestions:[ "检查语义分析规则"; "使用现代语义分析器" ]
