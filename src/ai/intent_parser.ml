(* 智能编程意图解析器 *)

(* 编程意图类型定义 *)
type intent =
  | CreateFunction of string * string list * intent (* 创建函数：名称，参数，函数体意图 *)
  | ProcessList of string * intent (* 列表处理：操作类型，操作意图 *)
  | Calculate of string (* 计算表达式：计算描述 *)
  | Pattern of string (* 模式匹配：模式类型 *)
  | Sort of string (* 排序：排序方式 *)
  | Filter of string (* 过滤：过滤条件 *)
  | Map of string (* 映射：映射操作 *)
  | Reduce of string (* 归约：归约操作 *)
  | Unknown of string (* 未知意图 *)

(* 代码模板定义 *)
type template = {
  name : string; (* 模板名称 *)
  parameters : string list; (* 参数列表 *)
  body : string; (* 代码模板 *)
  description : string; (* 描述 *)
  category : string; (* 分类 *)
}

(* 补全建议 *)
type suggestion = {
  code : string; (* 生成的代码 *)
  confidence : float; (* 置信度 0.0-1.0 *)
  description : string; (* 建议描述 *)
  category : string; (* 建议分类 *)
  intent : intent; (* 识别的意图 *)
}

(* 关键词映射表 *)
let function_keywords =
  [
    ("阶乘", "factorial");
    ("斐波那契", "fibonacci");
    ("排序", "sort");
    ("求和", "sum");
    ("长度", "length");
    ("过滤", "filter");
    ("映射", "map");
    ("计算", "calculate");
    ("处理", "process");
  ]

let operation_keywords =
  [
    ("乘以", "multiply");
    ("加", "add");
    ("减", "subtract");
    ("除以", "divide");
    ("求和", "sum");
    ("计数", "count");
    ("排序", "sort");
    ("过滤", "filter");
    ("查找", "find");
  ]

(* 预定义代码模板 *)
let templates =
  [
    {
      name = "fibonacci";
      parameters = [ "n" ];
      body =
        "递归 让 「斐波那契」 = 函数 n →\n\
        \  匹配 n 与\n\
        \  ｜ 0 → 0\n\
        \  ｜ 1 → 1\n\
        \  ｜ _ → 「斐波那契」 (n - 1) + 「斐波那契」 (n - 2)";
      description = "计算斐波那契数列";
      category = "数学函数";
    };
    {
      name = "factorial";
      parameters = [ "n" ];
      body = "递归 让 「阶乘」 = 函数 n →\n  匹配 n 与\n  ｜ 0 ｜ 1 → 1\n  ｜ _ → n * 「阶乘」 (n - 1)";
      description = "计算阶乘";
      category = "数学函数";
    };
    {
      name = "list_sum";
      parameters = [ "列表" ];
      body = "递归 让 「求和」 = 函数 列表 →\n  匹配 列表 与\n  ｜ [] → 0\n  ｜ 头 :: 尾 → 头 + 「求和」 尾";
      description = "计算列表元素总和";
      category = "列表操作";
    };
    {
      name = "list_length";
      parameters = [ "列表" ];
      body = "递归 让 「长度」 = 函数 列表 →\n  匹配 列表 与\n  ｜ [] → 0\n  ｜ _ :: 尾 → 1 + 「长度」 尾";
      description = "计算列表长度";
      category = "列表操作";
    };
    {
      name = "quick_sort";
      parameters = [ "列表" ];
      body =
        "递归 让 「快速排序」 = 函数 列表 →\n\
        \  匹配 列表 与\n\
        \  ｜ [] → []\n\
        \  ｜ 基准 :: 其余 →\n\
        \    让 小的 = 过滤 (函数 x → x < 基准) 其余 以及\n\
        \    让 大的 = 过滤 (函数 x → x >= 基准) 其余 于\n\
        \    「快速排序」 小的 @ [基准] @ 「快速排序」 大的";
      description = "快速排序算法";
      category = "排序算法";
    };
    {
      name = "list_map";
      parameters = [ "函数"; "列表" ];
      body = "递归 让 「映射」 = 函数 f 列表 →\n  匹配 列表 与\n  ｜ [] → []\n  ｜ 头 :: 尾 → f 头 :: 「映射」 f 尾";
      description = "将函数应用到列表每个元素";
      category = "列表操作";
    };
  ]

(* 检查字符串是否包含子字符串 *)
let contains_substring str sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) str 0 in
    true
  with Not_found -> false

(* 增强的关键词检查函数 *)
let check_function_creation_keywords input =
  contains_substring input "函数" || contains_substring input "创建" || contains_substring input "定义"
  || contains_substring input "实现" || contains_substring input "写"

let check_list_operation_keywords input =
  contains_substring input "列表" || contains_substring input "排序" || contains_substring input "过滤"
  || contains_substring input "处理"

let check_calculation_keywords input =
  contains_substring input "计算" || contains_substring input "求" || contains_substring input "算"

(* 解析中文意图文本 *)
let parse_intent (input : string) : intent =
  (* 优先检查具体的函数类型 *)
  if contains_substring input "斐波那契" then CreateFunction ("斐波那契", [ "n" ], Calculate "斐波那契数列计算")
  else if contains_substring input "阶乘" then CreateFunction ("阶乘", [ "n" ], Calculate "阶乘计算")
    (* 检查排序操作 - 可能是函数或列表操作 *)
  else if contains_substring input "排序" then
    if check_function_creation_keywords input then CreateFunction ("排序", [ "列表" ], Sort "快速排序")
    else ProcessList ("排序", Sort "对列表排序") (* 检查过滤操作 *)
  else if contains_substring input "过滤" then
    if contains_substring input "正数" then ProcessList ("过滤正数", Filter "过滤出正数")
    else ProcessList ("过滤", Filter "根据条件过滤元素") (* 检查函数创建关键词 *)
  else if check_function_creation_keywords input then
    if contains_substring input "求和" then CreateFunction ("求和", [ "列表" ], Reduce "列表求和")
    else if contains_substring input "长度" then CreateFunction ("长度", [ "列表" ], Calculate "列表长度计算")
    else CreateFunction ("未知函数", [], Unknown "无法识别的函数类型") (* 检查列表操作 *)
  else if check_list_operation_keywords input then
    if contains_substring input "乘" then ProcessList ("乘法", Map "每个元素乘以某个值")
    else ProcessList ("未知操作", Unknown "无法识别的列表操作") (* 检查条件和模式匹配 *)
  else if contains_substring input "条件" || contains_substring input "判断" then Pattern "条件判断模式"
    (* 检查计算操作 *)
  else if check_calculation_keywords input then Calculate input
  else Unknown input

(* 根据意图生成代码建议 *)
let generate_suggestions (intent : intent) : suggestion list =
  match intent with
  | CreateFunction (name, _params, _body_intent) -> (
      match name with
      | "斐波那契" ->
          let template = List.find (fun t -> t.name = "fibonacci") templates in
          [
            {
              code = template.body;
              confidence = 0.95;
              description = template.description;
              category = template.category;
              intent;
            };
          ]
      | "阶乘" ->
          let template = List.find (fun t -> t.name = "factorial") templates in
          [
            {
              code = template.body;
              confidence = 0.95;
              description = template.description;
              category = template.category;
              intent;
            };
          ]
      | "排序" ->
          let template = List.find (fun t -> t.name = "quick_sort") templates in
          [
            {
              code = template.body;
              confidence = 0.90;
              description = template.description;
              category = template.category;
              intent;
            };
          ]
      | "求和" ->
          let template = List.find (fun t -> t.name = "list_sum") templates in
          [
            {
              code = template.body;
              confidence = 0.90;
              description = template.description;
              category = template.category;
              intent;
            };
          ]
      | "长度" ->
          let template = List.find (fun t -> t.name = "list_length") templates in
          [
            {
              code = template.body;
              confidence = 0.90;
              description = template.description;
              category = template.category;
              intent;
            };
          ]
      | _ ->
          [
            {
              code = "(* 无法生成代码建议 *)";
              confidence = 0.0;
              description = "未知函数类型";
              category = "错误";
              intent;
            };
          ])
  | ProcessList (operation, _sub_intent) -> (
      match operation with
      | "乘法" ->
          [
            {
              code = "让 「乘以二」 = 函数 列表 → 映射 (函数 x → x * 2) 列表";
              confidence = 0.85;
              description = "将列表中每个元素乘以2";
              category = "列表操作";
              intent;
            };
          ]
      | "过滤" | "过滤正数" ->
          [
            {
              code = "让 「过滤正数」 = 函数 列表 → 过滤 (函数 x → x > 0) 列表";
              confidence = 0.80;
              description = "过滤出列表中的正数";
              category = "列表操作";
              intent;
            };
          ]
      | "排序" ->
          let template = List.find (fun t -> t.name = "quick_sort") templates in
          [
            {
              code = template.body;
              confidence = 0.90;
              description = template.description;
              category = template.category;
              intent;
            };
          ]
      | _ ->
          [
            {
              code = "(* 无法生成列表操作建议 *)";
              confidence = 0.0;
              description = "未知列表操作";
              category = "错误";
              intent;
            };
          ])
  | Calculate description ->
      [
        {
          code = Printf.sprintf "(* 计算: %s *)" description;
          confidence = 0.50;
          description = "通用计算模板";
          category = "计算";
          intent;
        };
      ]
  | Sort _ ->
      let template = List.find (fun t -> t.name = "quick_sort") templates in
      [
        {
          code = template.body;
          confidence = 0.90;
          description = template.description;
          category = template.category;
          intent;
        };
      ]
  | Filter _ ->
      [
        {
          code = "让 「过滤器」 = 函数 条件 列表 → 过滤 条件 列表";
          confidence = 0.75;
          description = "通用过滤器";
          category = "列表操作";
          intent;
        };
      ]
  | Map _ ->
      let template = List.find (fun t -> t.name = "list_map") templates in
      [
        {
          code = template.body;
          confidence = 0.85;
          description = template.description;
          category = template.category;
          intent;
        };
      ]
  | Reduce _ ->
      let template = List.find (fun t -> t.name = "list_sum") templates in
      [
        {
          code = template.body;
          confidence = 0.85;
          description = template.description;
          category = template.category;
          intent;
        };
      ]
  | Pattern _ ->
      [
        {
          code = "匹配 输入 与\n｜ 模式1 → 结果1\n｜ 模式2 → 结果2\n｜ _ → 默认结果";
          confidence = 0.70;
          description = "通用模式匹配模板";
          category = "模式匹配";
          intent;
        };
      ]
  | Unknown input ->
      [
        {
          code = Printf.sprintf "(* 无法识别意图: %s *)" input;
          confidence = 0.0;
          description = "无法识别的编程意图";
          category = "错误";
          intent;
        };
      ]

(* 智能代码补全主函数 *)
let intelligent_completion (input : string) : suggestion list =
  let intent = parse_intent input in
  let suggestions = generate_suggestions intent in
  (* 按置信度排序 *)
  List.sort (fun s1 s2 -> compare s2.confidence s1.confidence) suggestions

(* 格式化建议输出 *)
let format_suggestion (suggestion : suggestion) : string =
  Printf.sprintf "建议 [%.0f%%]: %s\n分类: %s\n代码:\n%s\n" (suggestion.confidence *. 100.0)
    suggestion.description suggestion.category suggestion.code

(* 批量格式化建议 *)
let format_suggestions (suggestions : suggestion list) : string =
  let formatted =
    List.mapi (fun i s -> Printf.sprintf "%d. %s" (i + 1) (format_suggestion s)) suggestions
  in
  String.concat "\n" formatted

(* 测试函数 *)
let test_intent_parser () =
  let test_cases =
    [ "创建一个计算斐波那契数列的函数"; "实现阶乘计算函数"; "对列表中的所有元素乘以2"; "将列表从小到大排序"; "计算列表的长度"; "过滤出列表中的正数" ]
  in

  List.iter
    (fun input ->
      Printf.printf "\n=== 测试输入: %s ===\n" input;
      let suggestions = intelligent_completion input in
      Printf.printf "%s\n" (format_suggestions suggestions))
    test_cases

