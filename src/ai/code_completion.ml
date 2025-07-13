(* 智能代码补全引擎 *)
open Intent_parser

(* 增强的上下文信息 *)
type syntax_context = 
  | GlobalContext                          (* 全局上下文 *)
  | FunctionDefContext                     (* 函数定义上下文 *)
  | FunctionBodyContext                    (* 函数体上下文 *)
  | PatternMatchContext                    (* 模式匹配上下文 *)
  | ConditionalContext                     (* 条件表达式上下文 *)
  | ListContext                           (* 列表上下文 *)
  | RecordContext                         (* 记录类型上下文 *)
  | VariableDefContext                    (* 变量定义上下文 *)
  | ParameterContext of string list       (* 参数上下文，包含参数类型信息 *)

type context = {
  current_scope: string;          (* 当前作用域 *)
  syntax_context: syntax_context; (* 语法上下文 *)
  available_vars: (string * string) list; (* 可用变量及其类型 *)
  available_functions: (string * string list * string) list; (* 函数名、参数、返回类型 *)
  imported_modules: string list;  (* 导入的模块 *)
  recent_patterns: string list;   (* 最近使用的模式 *)
  nesting_level: int;            (* 嵌套层级 *)
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
  syntax_context = GlobalContext;
  available_vars = [];
  available_functions = [
    ("打印", ["任意"], "单元");
    ("打印行", ["任意"], "单元");
    ("读取行", [], "字符串");
    ("字符串长度", ["字符串"], "整数");
    ("整数转字符串", ["整数"], "字符串");
    ("字符串转整数", ["字符串"], "整数");
    ("列表长度", ["列表"], "整数");
  ];
  imported_modules = ["标准库"];
  recent_patterns = [];
  nesting_level = 0;
}

(* 分析语法上下文 *)
let analyze_syntax_context (input: string) (cursor_pos: int) : syntax_context =
  let before_cursor = if cursor_pos <= String.length input then 
    String.sub input 0 cursor_pos else input in
  
  (* 检查是否在函数定义中 *)
  if Str.string_match (Str.regexp ".*函数.*->.*") before_cursor 0 then
    FunctionBodyContext
  else if Str.string_match (Str.regexp ".*函数") before_cursor 0 then
    FunctionDefContext
  (* 检查是否在模式匹配中 *)
  else if Str.string_match (Str.regexp ".*匹配.*与") before_cursor 0 then
    PatternMatchContext
  (* 检查是否在条件表达式中 *)
  else if Str.string_match (Str.regexp ".*如果.*那么.*") before_cursor 0 then
    ConditionalContext
  else if Str.string_match (Str.regexp ".*如果") before_cursor 0 then
    ConditionalContext
  (* 检查是否在变量定义中 *)
  else if Str.string_match (Str.regexp ".*让") before_cursor 0 then
    VariableDefContext
  (* 检查是否在列表操作中 *)
  else if Str.string_match (Str.regexp ".*\\[.*") before_cursor 0 then
    ListContext
  else
    GlobalContext

(* 获取参数建议 *)
let get_parameter_suggestions (func_name: string) (context: context) : string list =
  List.find_map (fun (name, params, _) ->
    if name = func_name then Some params else None
  ) context.available_functions
  |> Option.value ~default:[]

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

(* 计算匹配分数，增强上下文感知 *)
let calculate_score (prefix: string) (candidate: string) (context: context) (completion_type: completion_type) : float =
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
    else if List.exists (fun (var, _) -> var = candidate) context.available_vars then 0.15
    else 0.0
  in
  
  (* 语法上下文加分 *)
  let syntax_bonus = match context.syntax_context, completion_type with
    | FunctionDefContext, KeywordCompletion k when k = "函数" -> 0.3
    | FunctionBodyContext, VariableCompletion _ -> 0.2
    | PatternMatchContext, PatternCompletion _ -> 0.3
    | ConditionalContext, KeywordCompletion k when k = "那么" || k = "否则" -> 0.25
    | VariableDefContext, KeywordCompletion k when k = "=" -> 0.3
    | ListContext, FunctionCompletion (f, _) when List.mem f ["列表头"; "列表尾"; "列表长度"] -> 0.2
    | _ -> 0.0
  in
  
  min 1.0 (base_score +. context_bonus +. syntax_bonus)

(* 生成关键字补全 *)
let generate_keyword_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun (keyword, doc) ->
    if prefix_matches prefix keyword then
      let completion_type = KeywordCompletion keyword in
      Some {
        text = keyword;
        display_text = keyword;
        completion_type = completion_type;
        score = calculate_score prefix keyword context completion_type;
        documentation = doc;
      }
    else None
  ) keywords_with_docs

(* 生成函数补全 *)
let generate_function_completions (prefix: string) (context: context) : completion_result list =
  let all_functions = builtin_functions @ 
    (List.map (fun (name, params, ret_type) -> 
      (name, params, Printf.sprintf "返回 %s" ret_type)
    ) context.available_functions) in
    
  List.filter_map (fun (name, params, doc) ->
    if prefix_matches prefix name then
      let param_text = String.concat " " params in
      let display_text = if params = [] then name else name ^ " " ^ param_text in
      let completion_type = FunctionCompletion (name, params) in
      Some {
        text = name;
        display_text = display_text;
        completion_type = completion_type;
        score = calculate_score prefix name context completion_type;
        documentation = doc ^ " - 参数: " ^ param_text;
      }
    else None
  ) all_functions

(* 生成模式补全 *)
let generate_pattern_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun (pattern_name, pattern_example) ->
    if prefix_matches prefix pattern_name then
      let completion_type = PatternCompletion pattern_example in
      Some {
        text = pattern_example;
        display_text = pattern_name ^ ": " ^ pattern_example;
        completion_type = completion_type;
        score = calculate_score prefix pattern_name context completion_type;
        documentation = "模式匹配: " ^ pattern_name;
      }
    else None
  ) common_patterns

(* 生成变量补全 *)
let generate_variable_completions (prefix: string) (context: context) : completion_result list =
  List.filter_map (fun (var_name, var_type) ->
    if prefix_matches prefix var_name then
      let completion_type = VariableCompletion var_name in
      Some {
        text = var_name;
        display_text = var_name ^ " : " ^ var_type;
        completion_type = completion_type;
        score = calculate_score prefix var_name context completion_type;
        documentation = "可用变量: " ^ var_name ^ " (类型: " ^ var_type ^ ")";
      }
    else None
  ) context.available_vars

(* 增强的智能表达式补全 *)
let generate_expression_completions (prefix: string) (input: string) (context: context) : completion_result list =
  let syntax_ctx = analyze_syntax_context input (String.length input) in
  let completions = ref [] in
  
  (* 基于语法上下文生成补全 *)
  (match syntax_ctx with
   | FunctionDefContext ->
     (* 在函数定义上下文中，建议参数和箭头 *)
     if prefix = "" then
       completions := [
         {
           text = "参数 ->";
           display_text = "参数 -> (函数参数)";
           completion_type = ExpressionCompletion "函数参数";
           score = 0.9;
           documentation = "函数参数定义";
         }
       ] @ !completions
   
   | FunctionBodyContext ->
     (* 在函数体中，优先建议变量和函数调用 *)
     completions := (generate_variable_completions prefix context) @ 
                   (generate_function_completions prefix context) @ !completions
   
   | PatternMatchContext ->
     (* 在模式匹配中，建议模式 *)
     completions := (generate_pattern_completions prefix context) @ !completions
   
   | ConditionalContext ->
     (* 在条件上下文中，建议布尔表达式 *)
     completions := [
       {
         text = "那么";
         display_text = "那么 (条件结果)";
         completion_type = KeywordCompletion "那么";
         score = 0.85;
         documentation = "条件表达式结果分支";
       };
       {
         text = "否则";
         display_text = "否则 (条件分支)";
         completion_type = KeywordCompletion "否则";
         score = 0.8;
         documentation = "条件表达式备选分支";
       }
     ] @ !completions
   
   | VariableDefContext ->
     (* 在变量定义中，建议赋值操作符 *)
     completions := [
       {
         text = "= ";
         display_text = "= (赋值)";
         completion_type = ExpressionCompletion "赋值";
         score = 0.9;
         documentation = "变量赋值操作符";
       }
     ] @ !completions
   
   | ListContext ->
     (* 在列表上下文中，建议列表操作 *)
     let list_functions = ["列表头"; "列表尾"; "列表长度"] in
     let list_completions = List.filter_map (fun func ->
       if prefix_matches prefix func then
         Some {
           text = func;
           display_text = func ^ " (列表操作)";
           completion_type = FunctionCompletion (func, ["列表"]);
           score = 0.85;
           documentation = "列表操作函数";
         }
       else None
     ) list_functions in
     completions := list_completions @ !completions
   
   | GlobalContext ->
     (* 在全局上下文中，建议常用关键字 *)
     completions := (generate_keyword_completions prefix context) @ !completions
   
   | _ -> ()
  );
  
  !completions

(* 增强的主要补全函数 *)
let complete_code (input: string) (cursor_pos: int) (context: context) : completion_result list =
  let prefix = extract_prefix input cursor_pos in
  let syntax_ctx = analyze_syntax_context input cursor_pos in
  
  (* 更新上下文的语法信息 *)
  let updated_context = { context with syntax_context = syntax_ctx } in
  
  (* 基于语法上下文智能生成补全 *)
  let primary_completions = generate_expression_completions prefix input updated_context in
  
  (* 生成其他类型的补全作为补充 *)
  let keyword_completions = generate_keyword_completions prefix updated_context in
  let function_completions = generate_function_completions prefix updated_context in
  let variable_completions = generate_variable_completions prefix updated_context in
  let pattern_completions = generate_pattern_completions prefix updated_context in
  
  (* 合并所有补全结果，优先考虑上下文相关的补全 *)
  let all_completions = 
    primary_completions @ 
    keyword_completions @ 
    function_completions @ 
    variable_completions @ 
    pattern_completions
  in
  
  (* 去重并按分数排序 *)
  let unique_completions = List.fold_left (fun acc completion ->
    if List.exists (fun c -> c.text = completion.text) acc then acc
    else completion :: acc
  ) [] all_completions in
  
  let sorted_completions = List.sort (fun c1 c2 -> 
    compare c2.score c1.score
  ) unique_completions in
  
  (* 返回前12个结果（提高数量以展示更多上下文相关的选项） *)
  let take n lst = 
    let rec aux acc n = function
      | [] -> List.rev acc
      | h :: t when n > 0 -> aux (h :: acc) (n - 1) t
      | _ -> List.rev acc
    in
    aux [] n lst
  in
  take 12 sorted_completions

(* 更新上下文 *)
let update_context (context: context) (new_var: string) (var_type: string) : context =
  { context with available_vars = (new_var, var_type) :: context.available_vars }

let add_function_to_context (context: context) (func_name: string) (params: string list) (return_type: string) : context =
  { context with available_functions = (func_name, params, return_type) :: context.available_functions }

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
  let context = update_context context "用户列表" "列表" in
  let context = update_context context "计算结果" "整数" in
  let context = add_function_to_context context "自定义函数" ["参数1"; "参数2"] "字符串" in
  
  let test_cases = [
    ("让 ", 3, "变量定义");
    ("函数 ", 3, "函数定义");
    ("匹配 列表 与", 7, "模式匹配");
    ("如果 ", 3, "条件表达式");
    ("打", 1, "函数调用");
    ("用", 1, "变量引用");
  ] in
  
  List.iter (fun (input, cursor_pos, description) ->
    Printf.printf "\n=== 上下文感知补全测试: '%s' (位置: %d) - %s ===\n" input cursor_pos description;
    let completions = complete_code input cursor_pos context in
    Printf.printf "🔍 语法上下文: %s\n" (match analyze_syntax_context input cursor_pos with
      | GlobalContext -> "全局上下文"
      | FunctionDefContext -> "函数定义上下文"
      | FunctionBodyContext -> "函数体上下文"  
      | PatternMatchContext -> "模式匹配上下文"
      | ConditionalContext -> "条件表达式上下文"
      | ListContext -> "列表上下文"
      | RecordContext -> "记录类型上下文"
      | VariableDefContext -> "变量定义上下文"
      | ParameterContext _ -> "参数上下文");
    Printf.printf "✅ 获得 %d 个补全建议\n" (List.length completions);
    if List.length completions > 0 then (
      let best = List.hd completions in
      Printf.printf "   最佳建议: %s (评分: %.2f)\n" best.display_text best.score
    );
    
    (* 显示前3个补全结果 *)
    let take_n n lst = 
      let rec aux acc n = function
        | [] -> List.rev acc
        | h :: t when n > 0 -> aux (h :: acc) (n - 1) t
        | _ -> List.rev acc
      in
      aux [] n lst
    in
    let top_3 = take_n 3 completions in
    List.iteri (fun i c ->
      Printf.printf "%d. %s\n" (i + 1) (format_completion c)
    ) top_3;
    
    (* 测试意图补全 *)
    Printf.printf "\n--- 意图补全 ---\n";
    let intent_completions = intent_based_completion input in
    List.iteri (fun i c ->
      Printf.printf "%d. %s\n" (i + 1) (format_completion c)
    ) intent_completions
  ) test_cases