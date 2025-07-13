(* 智能代码补全引擎 *)
open Intent_parser

(* 上下文信息 *)
type context = {
  current_scope: string;          (* 当前作用域 *)
  available_vars: string list;    (* 可用变量 *)
  imported_modules: string list;  (* 导入的模块 *)
  recent_patterns: string list;   (* 最近使用的模式 *)
}

(* 补全类型 *)
type completion_type = 
  | FunctionCompletion of string * string list  (* 函数补全：名称，参数 *)
  | VariableCompletion of string                (* 变量补全 *)
  | KeywordCompletion of string                 (* 关键字补全 *)
  | PatternCompletion of string                 (* 模式补全 *)
  | ExpressionCompletion of string              (* 表达式补全 *)

(* 补全结果 *)
type completion_result = {
  text: string;              (* 补全文本 *)
  display_text: string;      (* 显示文本 *)
  completion_type: completion_type;
  score: float;              (* 评分 0.0-1.0 *)
  documentation: string;     (* 文档说明 *)
}

(* 常用关键字和其描述 *)
let keywords_with_docs = [
  ("让", "变量声明关键字");
  ("函数", "函数定义关键字");
  ("匹配", "模式匹配关键字");
  ("与", "模式匹配连接词");
  ("如果", "条件判断关键字");
  ("那么", "条件结果关键字");
  ("否则", "条件分支关键字");
  ("递归", "递归函数声明");
  ("类型", "类型定义关键字");
  ("模块", "模块定义关键字");
  ("开放", "模块开放关键字");
  ("异常", "异常定义关键字");
]

(* 常用模式和其示例 *)
let common_patterns = [
  ("列表模式", "[] | 头 :: 尾");
  ("选项模式", "无 | 有 值");
  ("布尔模式", "真 | 假");
  ("数字模式", "0 | 1 | n");
  ("字符串模式", "\"\" | s");
  ("通配符模式", "_");
]

(* 内置函数补全 *)
let builtin_functions = [
  ("打印", ["值"], "打印值到控制台");
  ("打印行", ["值"], "打印值并换行");
  ("读取行", [], "从输入读取一行");
  ("字符串长度", ["字符串"], "获取字符串长度");
  ("整数转字符串", ["整数"], "将整数转换为字符串");
  ("字符串转整数", ["字符串"], "将字符串转换为整数");
  ("列表长度", ["列表"], "获取列表长度");
  ("列表头", ["列表"], "获取列表第一个元素");
  ("列表尾", ["列表"], "获取列表除第一个元素外的部分");
]

(* 创建默认上下文 *)
let create_default_context () : context = {
  current_scope = "全局";
  available_vars = [];
  imported_modules = ["标准库"];
  recent_patterns = [];
}

(* 分析输入文本，提取前缀 *)
let extract_prefix (input: string) (cursor_pos: int) : string =
  if cursor_pos <= 0 || cursor_pos > String.length input then ""
  else
    let before_cursor = String.sub input 0 cursor_pos in
    (* 找到最后一个空格或特殊字符的位置 *)
    let rec find_word_start pos =
      if pos <= 0 then 0
      else
        match before_cursor.[pos - 1] with
        | ' ' | '\t' | '\n' | '(' | ')' | '[' | ']' | '{' | '}' | ',' | ';' -> pos
        | _ -> find_word_start (pos - 1)
    in
    let start_pos = find_word_start cursor_pos in
    String.sub before_cursor start_pos (cursor_pos - start_pos)

(* 检查前缀是否匹配 *)
let prefix_matches (prefix: string) (candidate: string) : bool =
  let prefix_len = String.length prefix in
  let candidate_len = String.length candidate in
  if prefix_len > candidate_len then false
  else
    let prefix_lower = String.lowercase_ascii prefix in
    let candidate_lower = String.lowercase_ascii candidate in
    String.sub candidate_lower 0 prefix_len = prefix_lower

(* 计算匹配分数 *)
let calculate_score (prefix: string) (candidate: string) (context: context) : float =
  let base_score = 
    if prefix = "" then 0.5
    else if prefix_matches prefix candidate then
      let prefix_len = String.length prefix in
      let candidate_len = String.length candidate in
      (* 前缀匹配度 + 长度因子 *)
      let prefix_score = float_of_int prefix_len /. float_of_int candidate_len in
      let length_bonus = 1.0 -. (float_of_int candidate_len /. 20.0) in
      min 1.0 (prefix_score +. length_bonus *. 0.3)
    else 0.0
  in
  
  (* 上下文加分 *)
  let context_bonus = 
    if List.mem candidate context.recent_patterns then 0.2
    else if List.mem candidate context.available_vars then 0.1
    else 0.0
  in
  
  min 1.0 (base_score +. context_bonus)

(* 生成关键字补全 *)
let generate_keyword_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun (keyword, doc) ->
    if prefix_matches prefix keyword then
      Some {
        text = keyword;
        display_text = keyword;
        completion_type = KeywordCompletion keyword;
        score = calculate_score prefix keyword context;
        documentation = doc;
      }
    else None
  ) keywords_with_docs

(* 生成函数补全 *)
let generate_function_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun (name, params, doc) ->
    if prefix_matches prefix name then
      let param_text = String.concat " " params in
      let display_text = if params = [] then name else name ^ " " ^ param_text in
      Some {
        text = name;
        display_text = display_text;
        completion_type = FunctionCompletion (name, params);
        score = calculate_score prefix name context;
        documentation = doc ^ " - 参数: " ^ param_text;
      }
    else None
  ) builtin_functions

(* 生成模式补全 *)
let generate_pattern_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun (pattern_name, pattern_example) ->
    if prefix_matches prefix pattern_name then
      Some {
        text = pattern_example;
        display_text = pattern_name ^ ": " ^ pattern_example;
        completion_type = PatternCompletion pattern_example;
        score = calculate_score prefix pattern_name context;
        documentation = "模式匹配: " ^ pattern_name;
      }
    else None
  ) common_patterns

(* 生成变量补全 *)
let generate_variable_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun var_name ->
    if prefix_matches prefix var_name then
      Some {
        text = var_name;
        display_text = var_name;
        completion_type = VariableCompletion var_name;
        score = calculate_score prefix var_name context;
        documentation = "可用变量: " ^ var_name;
      }
    else None
  ) context.available_vars

(* 智能表达式补全 *)
let generate_expression_completions (prefix: string) (input: string) (context: context) : completion_result list =
  (* 检查是否在特定上下文中 *)
  let completions = ref [] in
  
  (* 检查是否在匹配表达式中 *)
  if (try let _ = Str.search_forward (Str.regexp_string "匹配") input 0 in true with Not_found -> false) then
    completions := (generate_pattern_completions prefix context) @ !completions;
  
  (* 检查是否在函数调用中 *)
  if (try let _ = Str.search_forward (Str.regexp_string "函数") input 0 in true with Not_found -> false) then
    completions := (generate_function_completions prefix context) @ !completions;
  
  (* 检查是否在变量声明中 *)
  if (try let _ = Str.search_forward (Str.regexp_string "让") input 0 in true with Not_found -> false) then
    completions := [
      {
        text = "= ";
        display_text = "= (赋值)";
        completion_type = ExpressionCompletion "赋值";
        score = 0.8;
        documentation = "变量赋值操作符";
      }
    ] @ !completions;
  
  !completions

(* 主要补全函数 *)
let complete_code (input: string) (cursor_pos: int) (context: context) : completion_result list =
  let prefix = extract_prefix input cursor_pos in
  
  (* 生成各种类型的补全 *)
  let keyword_completions = generate_keyword_completions prefix context in
  let function_completions = generate_function_completions prefix context in
  let variable_completions = generate_variable_completions prefix context in
  let pattern_completions = generate_pattern_completions prefix context in
  let expression_completions = generate_expression_completions prefix input context in
  
  (* 合并所有补全结果 *)
  let all_completions = 
    keyword_completions @ 
    function_completions @ 
    variable_completions @ 
    pattern_completions @ 
    expression_completions 
  in
  
  (* 按分数排序并限制数量 *)
  let sorted_completions = List.sort (fun c1 c2 -> 
    compare c2.score c1.score
  ) all_completions in
  
  (* 返回前10个结果 *)
  let take n lst = 
    let rec aux acc n = function
      | [] -> List.rev acc
      | h :: t when n > 0 -> aux (h :: acc) (n - 1) t
      | _ -> List.rev acc
    in
    aux [] n lst
  in
  take 10 sorted_completions

(* 更新上下文 *)
let update_context (context: context) (new_var: string) : context =
  { context with available_vars = new_var :: context.available_vars }

let add_recent_pattern (context: context) (pattern: string) : context =
  let patterns = pattern :: (List.filter (fun p -> p <> pattern) context.recent_patterns) in
  let recent = if List.length patterns > 5 then List.rev (List.tl (List.rev patterns)) else patterns in
  { context with recent_patterns = recent }

(* 格式化补全结果 *)
let format_completion (completion: completion_result) : string =
  Printf.sprintf "[%.0f%%] %s - %s"
    (completion.score *. 100.0)
    completion.display_text
    completion.documentation

let format_completions (completions: completion_result list) : string =
  let formatted = List.mapi (fun i c -> 
    Printf.sprintf "%d. %s" (i + 1) (format_completion c)
  ) completions in
  String.concat "\n" formatted

(* 基于意图的智能补全 *)
let intent_based_completion (input: string) : completion_result list =
  let intent = Intent_parser.parse_intent input in
  let suggestions = Intent_parser.generate_suggestions intent in
  
  List.map (fun suggestion ->
    {
      text = suggestion.code;
      display_text = suggestion.description;
      completion_type = ExpressionCompletion suggestion.category;
      score = suggestion.confidence;
      documentation = suggestion.description ^ " (" ^ suggestion.category ^ ")";
    }
  ) suggestions

(* 测试代码补全功能 *)
let test_code_completion () =
  let context = create_default_context () in
  let context = update_context context "用户列表" in
  let context = update_context context "计算结果" in
  
  let test_cases = [
    ("让 ", 3);
    ("函", 1);
    ("匹配 列表 与", 7);
    ("打", 1);
    ("用", 1);
  ] in
  
  List.iter (fun (input, cursor_pos) ->
    Printf.printf "\n=== 补全测试: '%s' (位置: %d) ===\n" input cursor_pos;
    let completions = complete_code input cursor_pos context in
    Printf.printf "%s\n" (format_completions completions);
    
    (* 测试意图补全 *)
    Printf.printf "\n--- 意图补全 ---\n";
    let intent_completions = intent_based_completion input in
    List.iteri (fun i c ->
      Printf.printf "%d. %s\n" (i + 1) (format_completion c)
    ) intent_completions
  ) test_cases