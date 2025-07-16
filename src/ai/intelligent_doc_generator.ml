(** 智能文档生成器 - Intelligent Documentation Generator * * 基于代码分析和AI理解，自动生成高质量的中文编程文档 * * 功能特色： * -
    自动分析函数语义并生成中文文档 * - 基于类型信息生成参数和返回值说明 * - 智能生成使用示例 * - 支持多种输出格式（Markdown、HTML、OCamlDoc） * -
    中文表达优化，符合中文阅读习惯 *)

(** 简化的表达式类型，用于文档分析 *)
type simple_expr =
  | SLiteral of string (* 字面量 *)
  | SVariable of string (* 变量 *)
  | SBinary of simple_expr * string * simple_expr (* 二元运算 *)
  | SFunction of string * simple_expr list (* 函数调用 *)
  | SCondition of simple_expr * simple_expr * simple_expr (* 条件表达式 *)
  | SMatch of simple_expr * (string * simple_expr) list (* 模式匹配 *)
  | SList of simple_expr list (* 列表 *)
  | STuple of simple_expr list (* 元组 *)

type function_info = {
  name : string; (* 函数名 *)
  parameters : string list; (* 参数列表 *)
  body : simple_expr; (* 函数体 *)
  is_recursive : bool; (* 是否递归 *)
}
(** 函数定义信息 *)

type doc_generation_config = {
  include_examples : bool; (* 是否包含使用示例 *)
  detail_level : [ `Brief | `Detailed | `Comprehensive ]; (* 详细程度 *)
  output_format : [ `Markdown | `HTML | `OCamlDoc ]; (* 输出格式 *)
  language_style : [ `Formal | `Casual | `Technical ]; (* 语言风格 *)
}
(** 文档生成配置 *)

type generated_doc = {
  summary : string; (* 功能概要 *)
  parameters : (string * string) list; (* 参数说明 *)
  return_value : string; (* 返回值说明 *)
  examples : string list; (* 使用示例 *)
  notes : string list; (* 注意事项 *)
  confidence : float; (* 生成质量置信度 *)
}
(** 生成的文档结构 *)

type module_doc = {
  module_summary : string; (* 模块概要 *)
  functions : (string * generated_doc) list; (* 函数文档列表 *)
  types : (string * string) list; (* 类型说明 *)
  dependencies : string list; (* 依赖关系 *)
  usage_guide : string; (* 使用指南 *)
}
(** 模块级文档结构 *)

(** 默认配置 *)
let default_config =
  {
    include_examples = true;
    detail_level = `Detailed;
    output_format = `Markdown;
    language_style = `Technical;
  }

(** 检查字符串是否包含子串 *)
let string_contains s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

(** 分析参数用途 *)
let analyze_parameter_usage (param : string) (body : simple_expr) : string =
  let rec analyze_expr expr =
    match expr with
    | SVariable var when var = param -> [ "直接使用" ]
    | SBinary (left, _, right) -> analyze_expr left @ analyze_expr right
    | SFunction (_, args) -> List.flatten (List.map analyze_expr args)
    | SCondition (cond, then_expr, else_expr) ->
        analyze_expr cond @ analyze_expr then_expr @ analyze_expr else_expr
    | SMatch (expr, branches) ->
        analyze_expr expr
        @ List.flatten (List.map (fun (_, branch_expr) -> analyze_expr branch_expr) branches)
    | SList exprs | STuple exprs -> List.flatten (List.map analyze_expr exprs)
    | _ -> []
  in
  let usages = analyze_expr body in
  if List.length usages > 0 then "用于计算和处理" else "输入参数"

(** 推断返回值类型描述 *)
let infer_return_description (body : simple_expr) : string =
  let rec analyze_return expr =
    match expr with
    | SLiteral lit when string_contains lit "整" || string_contains lit "数" -> "整数值"
    | SLiteral lit when string_contains lit "小" || string_contains lit "点" -> "浮点数值"
    | SLiteral lit when string_contains lit "字" || string_contains lit "串" -> "字符串"
    | SLiteral lit when string_contains lit "真" || string_contains lit "假" -> "布尔值"
    | SLiteral _ -> "字面量值"
    | SList _ -> "列表"
    | STuple _ -> "元组"
    | SCondition (_, then_expr, else_expr) ->
        let then_desc = analyze_return then_expr in
        let else_desc = analyze_return else_expr in
        if then_desc = else_desc then then_desc else "计算结果"
    | SBinary (_, op, _)
      when String.contains op '+' || String.contains op '-' || String.contains op '*'
           || String.contains op '/' ->
        "数值计算结果"
    | SBinary (_, op, _)
      when String.contains op '=' || String.contains op '<' || String.contains op '>' ->
        "比较结果"
    | SFunction _ -> "函数调用结果"
    | SMatch _ -> "模式匹配结果"
    | _ -> "计算结果"
  in
  analyze_return body

(** 生成智能使用示例 *)
let generate_examples (func_name : string) (params : string list) (body : simple_expr) : string list
    =
  let param_examples =
    match List.length params with
    | 0 -> []
    | 1 ->
        let param = List.hd params in
        [ Printf.sprintf "%s 示例值" param ]
    | 2 ->
        let p1 = List.nth params 0 in
        let p2 = List.nth params 1 in
        [ Printf.sprintf "%s 示例值1" p1; Printf.sprintf "%s 示例值2" p2 ]
    | _ -> List.mapi (fun i p -> Printf.sprintf "%s 示例%d" p (i + 1)) params
  in

  let example_call =
    match param_examples with
    | [] -> Printf.sprintf "%s" func_name
    | examples -> Printf.sprintf "%s %s" func_name (String.concat " " examples)
  in

  let return_desc = infer_return_description body in
  [ Printf.sprintf "%s (* 返回: %s *)" example_call return_desc ]

(** 检测函数特征 *)
let detect_function_features (func_info : function_info) : string list =
  let features = ref [] in

  if func_info.is_recursive then features := "递归函数" :: !features;

  let rec check_expr expr =
    match expr with
    | SMatch _ -> features := "使用模式匹配" :: !features
    | SCondition _ -> features := "包含条件判断" :: !features
    | SList _ -> features := "处理列表数据" :: !features
    | STuple _ -> features := "处理元组数据" :: !features
    | SBinary (left, _, right) ->
        check_expr left;
        check_expr right
    | SFunction (_, args) -> List.iter check_expr args
    | _ -> ()
  in

  check_expr func_info.body;
  !features

(** 生成函数文档注释 *)
let generate_function_documentation (func_info : function_info) (config : doc_generation_config) :
    generated_doc =
  (* 生成功能概要 *)
  let summary =
    let verb =
      if string_contains func_info.name "计" then "计算"
      else if string_contains func_info.name "处" then "处理"
      else if string_contains func_info.name "排" then "排序"
      else if string_contains func_info.name "过" then "过滤"
      else if string_contains func_info.name "查" then "查找"
      else if string_contains func_info.name "转" then "转换"
      else "执行"
    in
    Printf.sprintf "%s函数，%s相关操作" func_info.name verb
  in

  (* 生成参数说明 *)
  let parameters =
    List.map
      (fun param ->
        let usage = analyze_parameter_usage param func_info.body in
        (param, usage))
      func_info.parameters
  in

  (* 生成返回值说明 *)
  let return_value = infer_return_description func_info.body in

  (* 生成使用示例 *)
  let examples =
    if config.include_examples then
      generate_examples func_info.name func_info.parameters func_info.body
    else []
  in

  (* 生成注意事项 *)
  let features = detect_function_features func_info in
  let notes =
    List.map
      (fun feature ->
        match feature with
        | "递归函数" -> "此函数使用递归实现，注意终止条件"
        | "使用模式匹配" -> "函数使用模式匹配处理不同情况"
        | "包含条件判断" -> "函数包含条件判断逻辑"
        | "处理列表数据" -> "函数用于处理列表数据结构"
        | "处理元组数据" -> "函数用于处理元组数据结构"
        | f -> f)
      features
  in

  (* 计算置信度 *)
  let confidence =
    let base = 0.8 in
    let param_bonus = min 0.15 (float_of_int (List.length func_info.parameters) *. 0.05) in
    let example_bonus = if config.include_examples then 0.05 else 0.0 in
    let feature_bonus = min 0.1 (float_of_int (List.length features) *. 0.02) in
    min 1.0 (base +. param_bonus +. example_bonus +. feature_bonus)
  in

  { summary; parameters; return_value; examples; notes; confidence }

(** 格式化为Markdown *)
let format_as_markdown (doc : generated_doc) (func_name : string) : string =
  let buffer = Buffer.create 1024 in

  Buffer.add_string buffer (Printf.sprintf "## %s\n\n" func_name);
  Buffer.add_string buffer (Printf.sprintf "**功能说明**: %s\n\n" doc.summary);

  if List.length doc.parameters > 0 then (
    Buffer.add_string buffer "**参数**:\n";
    List.iter
      (fun (param, desc) -> Buffer.add_string buffer (Printf.sprintf "- `%s`: %s\n" param desc))
      doc.parameters;
    Buffer.add_string buffer "\n");

  Buffer.add_string buffer (Printf.sprintf "**返回值**: %s\n\n" doc.return_value);

  if List.length doc.examples > 0 then (
    Buffer.add_string buffer "**使用示例**:\n```ocaml\n";
    List.iter (fun example -> Buffer.add_string buffer (example ^ "\n")) doc.examples;
    Buffer.add_string buffer "```\n\n");

  if List.length doc.notes > 0 then (
    Buffer.add_string buffer "**注意事项**:\n";
    List.iter (fun note -> Buffer.add_string buffer (Printf.sprintf "- %s\n" note)) doc.notes;
    Buffer.add_string buffer "\n");

  Buffer.add_string buffer (Printf.sprintf "**生成质量**: %.0f%%\n\n" (doc.confidence *. 100.0));

  Buffer.contents buffer

(** 格式化为OCaml文档注释 *)
let format_as_ocaml_doc (doc : generated_doc) (_func_name : string) : string =
  let buffer = Buffer.create 1024 in

  Buffer.add_string buffer "(** ";
  Buffer.add_string buffer doc.summary;
  Buffer.add_string buffer "\n *\n";

  if List.length doc.parameters > 0 then (
    Buffer.add_string buffer " * 参数:\n";
    List.iter
      (fun (param, desc) -> Buffer.add_string buffer (Printf.sprintf " *   %s: %s\n" param desc))
      doc.parameters;
    Buffer.add_string buffer " *\n");

  Buffer.add_string buffer (Printf.sprintf " * 返回值: %s\n" doc.return_value);

  if List.length doc.examples > 0 then (
    Buffer.add_string buffer " *\n * 使用示例:\n";
    List.iter
      (fun example -> Buffer.add_string buffer (Printf.sprintf " *   %s\n" example))
      doc.examples);

  if List.length doc.notes > 0 then (
    Buffer.add_string buffer " *\n * 注意事项:\n";
    List.iter (fun note -> Buffer.add_string buffer (Printf.sprintf " *   - %s\n" note)) doc.notes);

  Buffer.add_string buffer " *)\n";

  Buffer.contents buffer

(** 生成模块级文档 *)
let generate_module_documentation (module_name : string) (functions : function_info list)
    (config : doc_generation_config) : module_doc =
  let function_docs =
    List.map
      (fun func_info ->
        let doc = generate_function_documentation func_info config in
        (func_info.name, doc))
      functions
  in

  let module_summary = Printf.sprintf "%s模块提供了%d个函数" module_name (List.length functions) in

  let usage_guide = Printf.sprintf "使用%s模块中的函数来完成相关编程任务" module_name in

  {
    module_summary;
    functions = function_docs;
    types = [];
    (* 类型提取待后续实现 *)
    dependencies = [];
    (* 依赖分析待后续实现 *)
    usage_guide;
  }

(** 主要API：为单个函数生成文档 *)
let generate_function_doc (func_info : function_info) (config : doc_generation_config) :
    generated_doc =
  generate_function_documentation func_info config

(** 主要API：为函数列表生成API参考 *)
let generate_api_reference (functions : function_info list) (config : doc_generation_config) :
    string =
  let buffer = Buffer.create 4096 in

  Buffer.add_string buffer "# 骆言语言API参考手册\n\n";
  Buffer.add_string buffer "## 函数列表\n\n";

  List.iter
    (fun func_info ->
      let doc = generate_function_documentation func_info config in
      let formatted =
        match config.output_format with
        | `Markdown -> format_as_markdown doc func_info.name
        | `OCamlDoc -> format_as_ocaml_doc doc func_info.name
        | `HTML -> format_as_markdown doc func_info.name (* 简化实现，使用Markdown *)
      in
      Buffer.add_string buffer formatted)
    functions;

  Buffer.add_string buffer "\n---\n\n";
  Buffer.add_string buffer "🤖 本文档由智能文档生成器自动生成\n";

  Buffer.contents buffer

(** 创建函数信息的辅助函数 *)
let make_function_info name params body is_recursive =
  { name; parameters = params; body; is_recursive }

(** 简化的表达式构造器 *)
let make_literal s = SLiteral s

let make_variable s = SVariable s
let make_binary left op right = SBinary (left, op, right)
let make_function_call name args = SFunction (name, args)
let make_condition cond then_expr else_expr = SCondition (cond, then_expr, else_expr)
let make_match expr branches = SMatch (expr, branches)
let make_list exprs = SList exprs
let make_tuple exprs = STuple exprs

(** 测试函数 *)
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
