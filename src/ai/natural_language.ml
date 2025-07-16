(* 自然语言处理模块 *)

(* 中文词汇类型 *)
type word_type =
  | Verb of string (* 动词 *)
  | Noun of string (* 名词 *)
  | Adjective of string (* 形容词 *)
  | Number of int (* 数字 *)
  | Keyword of string (* 关键字 *)
  | Identifier of string (* 标识符 *)
  | Unknown of string (* 未知词汇 *)

(* 语义角色 *)
type semantic_role =
  | Agent (* 施事者 *)
  | Patient (* 受事者 *)
  | Instrument (* 工具 *)
  | Location (* 位置 *)
  | Time (* 时间 *)
  | Manner (* 方式 *)
  | Purpose (* 目的 *)

(* 语义单元 *)
type semantic_unit = {
  text : string; (* 原始文本 *)
  word_type : word_type; (* 词汇类型 *)
  role : semantic_role option; (* 语义角色 *)
  confidence : float; (* 置信度 *)
}

(* 意图类型 *)
type programming_intent =
  | DefineFunction of string * string list (* 定义函数：名称，参数 *)
  | ProcessData of string * string (* 处理数据：数据类型，操作 *)
  | ControlFlow of string (* 控制流：类型 *)
  | Calculate of string (* 计算：表达式 *)
  | Transform of string * string (* 变换：源，目标 *)
  | Query of string (* 查询：对象 *)

(* 中文编程词汇表 *)
let programming_vocabulary =
  [
    (* 动词 *)
    ("创建", Verb "create");
    ("定义", Verb "define");
    ("实现", Verb "implement");
    ("计算", Verb "calculate");
    ("处理", Verb "process");
    ("分析", Verb "analyze");
    ("排序", Verb "sort");
    ("过滤", Verb "filter");
    ("映射", Verb "map");
    ("查找", Verb "find");
    ("搜索", Verb "search");
    ("转换", Verb "convert");
    ("变换", Verb "transform");
    ("构建", Verb "build");
    ("生成", Verb "generate");
    (* 名词 *)
    ("函数", Noun "function");
    ("方法", Noun "method");
    ("算法", Noun "algorithm");
    ("数据", Noun "data");
    ("列表", Noun "list");
    ("数组", Noun "array");
    ("字符串", Noun "string");
    ("数字", Noun "number");
    ("变量", Noun "variable");
    ("参数", Noun "parameter");
    ("结果", Noun "result");
    ("值", Noun "value");
    ("类型", Noun "type");
    ("结构", Noun "structure");
    ("模式", Noun "pattern");
    (* 形容词 *)
    ("递归", Adjective "recursive");
    ("快速", Adjective "fast");
    ("简单", Adjective "simple");
    ("复杂", Adjective "complex");
    ("有效", Adjective "valid");
    ("正确", Adjective "correct");
    ("完整", Adjective "complete");
    ("部分", Adjective "partial");
  ]

(* 数字词汇映射 *)
let chinese_numbers =
  [
    ("零", 0);
    ("一", 1);
    ("二", 2);
    ("三", 3);
    ("四", 4);
    ("五", 5);
    ("六", 6);
    ("七", 7);
    ("八", 8);
    ("九", 9);
    ("十", 10);
    ("百", 100);
    ("千", 1000);
    ("万", 10000);
  ]

(* 编程关键字映射 *)
let programming_keywords =
  [
    ("如果", "if");
    ("那么", "then");
    ("否则", "else");
    ("当", "when");
    ("循环", "loop");
    ("重复", "repeat");
    ("直到", "until");
    ("匹配", "match");
    ("与", "with");
    ("让", "let");
    ("在", "in");
    ("返回", "return");
  ]

(* 简化的中文分词（基于空格和常用标点） *)
let segment_chinese (text : string) : string list =
  let separators = [ " "; "\t"; "\n"; "，"; "。"; "；"; "："; "！"; "？" ] in
  let rec split_by_separators str seps =
    match seps with
    | [] -> [ str ]
    | sep :: rest_seps ->
        let parts = String.split_on_char (String.get sep 0) str in
        List.fold_left (fun acc part -> acc @ split_by_separators part rest_seps) [] parts
  in
  let words = split_by_separators text separators in
  List.filter (fun word -> String.length word > 0) words

(* 词汇分析 *)
let analyze_word (word : string) : word_type =
  (* 检查编程词汇表 *)
  try
    let _, word_type = List.find (fun (w, _) -> w = word) programming_vocabulary in
    word_type
  with Not_found -> (
    (* 检查关键字 *)
    try
      let _, keyword = List.find (fun (w, _) -> w = word) programming_keywords in
      Keyword keyword
    with Not_found -> (
      (* 检查数字 *)
      try
        let _, number = List.find (fun (w, _) -> w = word) chinese_numbers in
        Number number
      with Not_found ->
        (* 检查是否是引用标识符 *)
        if
          String.length word >= 3
          && String.get word 0 = String.get "「" 0
          && String.get word (String.length word - 1) = String.get "」" 0
        then Identifier (String.sub word 1 (String.length word - 2))
        else Unknown word))

(* 提取语义单元 *)
let extract_semantic_units (text : string) : semantic_unit list =
  let words = segment_chinese text in
  List.map
    (fun word ->
      let word_type = analyze_word word in
      let confidence =
        match word_type with
        | Verb _ | Noun _ | Keyword _ -> 0.9
        | Number _ | Identifier _ -> 0.95
        | Adjective _ -> 0.8
        | Unknown _ -> 0.3
      in
      {
        text = word;
        word_type;
        role = None;
        (* 语义角色分析需要更复杂的处理 *)
        confidence;
      })
    words

(* 识别编程意图 *)
let identify_intent (semantic_units : semantic_unit list) : programming_intent =
  let has_word_type predicate = List.exists (fun unit -> predicate unit.word_type) semantic_units in
  let get_words_of_type predicate =
    List.filter_map
      (fun unit -> if predicate unit.word_type then Some unit.text else None)
      semantic_units
  in

  (* 检查函数定义意图 *)
  if
    has_word_type (function Verb "define" | Verb "create" -> true | _ -> false)
    && has_word_type (function Noun "function" -> true | _ -> false)
  then
    let identifiers = get_words_of_type (function Identifier _ -> true | _ -> false) in
    let function_name = match identifiers with name :: _ -> name | [] -> "未知函数" in
    DefineFunction (function_name, []) (* 检查数据处理意图 *)
  else if
    has_word_type (function Verb "process" | Verb "sort" | Verb "filter" -> true | _ -> false)
  then
    let data_types =
      get_words_of_type (function Noun "list" | Noun "array" | Noun "data" -> true | _ -> false)
    in
    let operations = get_words_of_type (function Verb _ -> true | _ -> false) in
    let data_type = match data_types with h :: _ -> h | [] -> "数据" in
    let operation = match operations with h :: _ -> h | [] -> "处理" in
    ProcessData (data_type, operation) (* 检查控制流意图 *)
  else if
    has_word_type (function Keyword "if" | Keyword "match" | Keyword "loop" -> true | _ -> false)
  then
    let control_keywords = get_words_of_type (function Keyword _ -> true | _ -> false) in
    let control_type = match control_keywords with h :: _ -> h | [] -> "条件" in
    ControlFlow control_type (* 检查计算意图 *)
  else if
    has_word_type (function Verb "calculate" -> true | _ -> false)
    || has_word_type (function Number _ -> true | _ -> false)
  then
    let numbers = get_words_of_type (function Number _ -> true | _ -> false) in
    let calculation = String.concat " " numbers in
    Calculate calculation (* 检查变换意图 *)
  else if has_word_type (function Verb "convert" | Verb "transform" -> true | _ -> false) then
    Transform ("源数据", "目标格式")
  (* 默认为查询意图 *)
    else
    let nouns = get_words_of_type (function Noun _ -> true | _ -> false) in
    let query_object = match nouns with h :: _ -> h | [] -> "信息" in
    Query query_object

(* 生成代码建议 *)
let generate_code_suggestions (intent : programming_intent) : string list =
  match intent with
  | DefineFunction (name, params) ->
      [
        Printf.sprintf "递归 让 「%s」 = 函数 %s →" name (String.concat " " params);
        Printf.sprintf "让 「%s」 = 函数 %s →" name (String.concat " " params);
      ]
  | ProcessData ("列表", "排序") ->
      [ "递归 让 「快速排序」 = 函数 列表 → 匹配 列表 与 ｜ [] → [] ｜ 基准 :: 其余 → ..."; "让 「排序结果」 = 排序 列表" ]
  | ProcessData ("列表", "过滤") ->
      [
        "让 「过滤结果」 = 过滤 (函数 x → 条件) 列表"; "匹配 列表 与 ｜ [] → [] ｜ 头 :: 尾 → 如果 条件 头 那么 头 :: 过滤 尾 否则 过滤 尾";
      ]
  | ProcessData ("列表", operation) -> [ Printf.sprintf "让 「%s结果」 = %s 列表" operation operation ]
  | ControlFlow "如果" -> [ "如果 条件 那么 结果1 否则 结果2"; "匹配 表达式 与 ｜ 真 → 结果1 ｜ 假 → 结果2" ]
  | ControlFlow "匹配" -> [ "匹配 表达式 与 ｜ 模式1 → 结果1 ｜ 模式2 → 结果2 ｜ _ → 默认结果" ]
  | Calculate expr -> [ Printf.sprintf "让 计算结果 = %s" expr; Printf.sprintf "(%s)" expr ]
  | Transform (source, target) -> [ Printf.sprintf "让 转换结果 = 转换 %s 到 %s" source target ]
  | Query obj -> [ Printf.sprintf "查询 %s" obj; Printf.sprintf "获取 %s 信息" obj ]
  | ProcessData (_, _) -> [ "让 「处理结果」 = 处理 数据" ]
  | ControlFlow _ -> [ "如果 条件 那么 结果1 否则 结果2" ]

(* 自然语言到代码的转换 *)
let natural_language_to_code (input : string) : string list =
  let semantic_units = extract_semantic_units input in
  let intent = identify_intent semantic_units in
  generate_code_suggestions intent

(* 代码到自然语言的转换 *)
let code_to_natural_language (code : string) : string =
  (* 简化的代码分析 *)
  if
    try
      let _ = Str.search_forward (Str.regexp_string "递归") code 0 in
      true
    with Not_found -> false
  then "这是一个递归函数定义"
  else if
    try
      let _ = Str.search_forward (Str.regexp_string "匹配") code 0 in
      true
    with Not_found -> false
  then "这是一个模式匹配表达式"
  else if
    try
      let _ = Str.search_forward (Str.regexp_string "如果") code 0 in
      true
    with Not_found -> false
  then "这是一个条件判断语句"
  else if
    try
      let _ = Str.search_forward (Str.regexp_string "让") code 0 in
      true
    with Not_found -> false
  then "这是一个变量定义"
  else "这是一段骆言代码"

(* 提取关键信息 *)
let extract_key_information (text : string) : (string * string) list =
  let semantic_units = extract_semantic_units text in
  List.filter_map
    (fun unit ->
      match unit.word_type with
      | Identifier name -> Some ("标识符", name)
      | Number n -> Some ("数字", string_of_int n)
      | Verb action -> Some ("动作", action)
      | Noun object_type -> Some ("对象", object_type)
      | Keyword kw -> Some ("关键字", kw)
      | _ -> None)
    semantic_units

(* 智能错误建议 *)
let suggest_corrections (error_text : string) (context : string) : string list =
  let suggestions = ref [] in

  (* 检查常见错误模式 *)
  if
    try
      let _ = Str.search_forward (Str.regexp_string "引用") error_text 0 in
      true
    with Not_found -> false
  then suggestions := "建议使用「引用标识符」语法" :: !suggestions;

  if
    try
      let _ = Str.search_forward (Str.regexp_string "语法") error_text 0 in
      true
    with Not_found -> false
  then suggestions := "检查语法结构是否正确" :: !suggestions;

  if
    try
      let _ = Str.search_forward (Str.regexp_string "类型") error_text 0 in
      true
    with Not_found -> false
  then suggestions := "检查类型匹配是否正确" :: !suggestions;

  (* 根据上下文提供建议 *)
  let semantic_units = extract_semantic_units context in
  let has_function =
    List.exists
      (fun unit -> match unit.word_type with Noun "function" -> true | _ -> false)
      semantic_units
  in

  if has_function then suggestions := "检查函数定义的参数和返回类型" :: !suggestions;

  !suggestions

