(* 代码模式学习系统 - AI辅助编程增强功能第三阶段 *)

(* 简化的AST表示用于模式学习 *)
type simple_expr =
  | SLiteral of string
  | SVariable of string
  | SBinaryOp of string * simple_expr * simple_expr
  | SUnaryOp of string * simple_expr
  | SFunctionCall of string * simple_expr list
  | SIfThenElse of simple_expr * simple_expr * simple_expr
  | SLetIn of string * simple_expr * simple_expr
  | SFunctionDef of string list * simple_expr
  | SRecursiveFunctionDef of string * string list * simple_expr
  | SMatch of simple_expr * (string * simple_expr) list
  | STuple of simple_expr list
  | SList of simple_expr list
  | SRecord of (string * simple_expr) list

(** 代码模式类型 *)
type code_pattern = {
  pattern_id: string;                           (* 模式唯一标识 *)
  pattern_type: pattern_type;                   (* 模式类型 *)
  structure: simple_expr;                       (* 简化AST结构 *)
  frequency: int;                               (* 使用频率 *)
  confidence: float;                            (* 置信度 *)
  examples: string list;                        (* 示例代码 *)
  variations: code_pattern list;                (* 变体模式 *)
  context_tags: string list;                    (* 上下文标签 *)
  semantic_meaning: string;                     (* 语义含义 *)
}

(** 模式类型分类 *)
and pattern_type =
  | FunctionPattern                             (* 函数定义模式 *)
  | ConditionalPattern                          (* 条件表达式模式 *)
  | LoopPattern                                 (* 循环模式 *)
  | MatchPattern                                (* 模式匹配模式 *)
  | RecursionPattern                            (* 递归模式 *)
  | DataProcessingPattern                       (* 数据处理模式 *)
  | ErrorHandlingPattern                        (* 错误处理模式 *)
  | AlgorithmPattern                            (* 算法模式 *)
  | NamingPattern                               (* 命名模式 *)
  | ModulePattern                               (* 模块组织模式 *)

(** 学习统计信息 *)
type learning_stats = {
  total_patterns: int;                          (* 总模式数 *)
  new_patterns_found: int;                      (* 新发现模式数 *)
  pattern_confidence_avg: float;                (* 平均置信度 *)
  learning_accuracy: float;                     (* 学习准确率 *)
  analysis_time: float;                         (* 分析用时 *)
  memory_usage: int;                            (* 内存使用量 *)
}

(** 代码分析结果 *)
type analysis_result = {
  patterns_found: code_pattern list;            (* 发现的模式 *)
  complexity_metrics: complexity_metrics;       (* 复杂度指标 *)
  quality_score: float;                         (* 代码质量分数 *)
  suggestions: string list;                     (* 改进建议 *)
}

(** 复杂度指标 *)
and complexity_metrics = {
  cyclomatic_complexity: int;                   (* 圈复杂度 *)
  nesting_depth: int;                           (* 嵌套深度 *)
  function_length: int;                         (* 函数长度 *)
  parameter_count: int;                         (* 参数数量 *)
}

(** 模式存储结构 *)
type pattern_storage = {
  mutable patterns: code_pattern list;          (* 模式库 *)
  mutable pattern_count: (string, int) Hashtbl.t;  (* 使用计数 *)
  mutable learning_history: learning_stats list;   (* 学习历史 *)
}

(** 全局模式存储 *)
let pattern_store = {
  patterns = [];
  pattern_count = Hashtbl.create 1000;
  learning_history = [];
}

(** 生成模式ID *)
let generate_pattern_id (pattern_type: pattern_type) (structure_hash: string) : string =
  let type_prefix = match pattern_type with
    | FunctionPattern -> "FN"
    | ConditionalPattern -> "CD"
    | LoopPattern -> "LP"
    | MatchPattern -> "MT"
    | RecursionPattern -> "RC"
    | DataProcessingPattern -> "DP"
    | ErrorHandlingPattern -> "EH"
    | AlgorithmPattern -> "AL"
    | NamingPattern -> "NM"
    | ModulePattern -> "MD"
  in
  Printf.sprintf "%s_%s_%d" type_prefix structure_hash (int_of_float (Unix.time ()))

(** 计算结构哈希 *)
let calculate_structure_hash (expr: simple_expr) : string =
  let rec expr_to_string = function
    | SLiteral s -> Printf.sprintf "LIT(%s)" s
    | SVariable v -> Printf.sprintf "VAR(%s)" v
    | SBinaryOp (op, e1, e2) -> 
        Printf.sprintf "BIN(%s,%s,%s)" op (expr_to_string e1) (expr_to_string e2)
    | SUnaryOp (op, e) -> 
        Printf.sprintf "UN(%s,%s)" op (expr_to_string e)
    | SFunctionCall (name, args) -> 
        Printf.sprintf "CALL(%s,%s)" name (String.concat "," (List.map expr_to_string args))
    | SIfThenElse (cond, then_branch, else_branch) ->
        Printf.sprintf "IF(%s,%s,%s)" (expr_to_string cond) (expr_to_string then_branch) (expr_to_string else_branch)
    | SLetIn (name, value, body) ->
        Printf.sprintf "LET(%s,%s,%s)" name (expr_to_string value) (expr_to_string body)
    | SFunctionDef (params, body) ->
        Printf.sprintf "FUN(%s,%s)" (String.concat "," params) (expr_to_string body)
    | SRecursiveFunctionDef (name, params, body) ->
        Printf.sprintf "REC(%s,%s,%s)" name (String.concat "," params) (expr_to_string body)
    | SMatch (expr, cases) ->
        let cases_str = String.concat ";" (List.map (fun (p, e) -> Printf.sprintf "%s->%s" p (expr_to_string e)) cases) in
        Printf.sprintf "MATCH(%s,%s)" (expr_to_string expr) cases_str
    | STuple exprs ->
        Printf.sprintf "TUP(%s)" (String.concat "," (List.map expr_to_string exprs))
    | SList exprs ->
        Printf.sprintf "LST(%s)" (String.concat "," (List.map expr_to_string exprs))
    | SRecord fields ->
        let fields_str = String.concat "," (List.map (fun (name, expr) -> Printf.sprintf "%s:%s" name (expr_to_string expr)) fields) in
        Printf.sprintf "REC(%s)" fields_str
  in
  let structure_str = expr_to_string expr in
  Digest.to_hex (Digest.string structure_str)

(** AST结构分析器 *)
let analyze_ast_structure (expr: simple_expr) : pattern_type list =
  let rec analyze_expr acc = function
    | SFunctionDef (_, _) -> FunctionPattern :: acc
    | SRecursiveFunctionDef (_, _, _) -> RecursionPattern :: FunctionPattern :: acc
    | SIfThenElse (_, _, _) -> ConditionalPattern :: acc
    | SMatch (_, _) -> MatchPattern :: acc
    | SBinaryOp (_, e1, e2) -> 
        let acc1 = analyze_expr acc e1 in
        analyze_expr acc1 e2
    | SUnaryOp (_, e) -> analyze_expr acc e
    | SFunctionCall (_, args) ->
        List.fold_left analyze_expr acc args
    | SLetIn (_, value, body) ->
        let acc1 = analyze_expr acc value in
        analyze_expr acc1 body
    | STuple exprs | SList exprs ->
        List.fold_left analyze_expr (DataProcessingPattern :: acc) exprs
    | SRecord fields ->
        List.fold_left (fun acc (_, expr) -> analyze_expr acc expr) (DataProcessingPattern :: acc) fields
    | _ -> acc
  in
  List.rev (analyze_expr [] expr)

(** 提取代码模式 *)
let extract_pattern (expr: simple_expr) : code_pattern =
  let pattern_types = analyze_ast_structure expr in
  let primary_type = match pattern_types with
    | [] -> FunctionPattern
    | t :: _ -> t
  in
  let structure_hash = calculate_structure_hash expr in
  let pattern_id = generate_pattern_id primary_type structure_hash in
  
  {
    pattern_id = pattern_id;
    pattern_type = primary_type;
    structure = expr;
    frequency = 1;
    confidence = 0.8;
    examples = [];
    variations = [];
    context_tags = List.map (function
      | FunctionPattern -> "函数定义"
      | ConditionalPattern -> "条件判断"
      | LoopPattern -> "循环"
      | MatchPattern -> "模式匹配"
      | RecursionPattern -> "递归"
      | DataProcessingPattern -> "数据处理"
      | ErrorHandlingPattern -> "错误处理"
      | AlgorithmPattern -> "算法"
      | NamingPattern -> "命名"
      | ModulePattern -> "模块"
    ) pattern_types;
    semantic_meaning = Printf.sprintf "这是一个%s模式，主要用于%s"
      (match primary_type with
       | FunctionPattern -> "函数定义"
       | ConditionalPattern -> "条件判断"
       | LoopPattern -> "循环处理"
       | MatchPattern -> "模式匹配"
       | RecursionPattern -> "递归计算"
       | DataProcessingPattern -> "数据处理"
       | ErrorHandlingPattern -> "错误处理"
       | AlgorithmPattern -> "算法实现"
       | NamingPattern -> "命名规范"
       | ModulePattern -> "模块组织")
      (String.concat "、" (List.map (function
        | FunctionPattern -> "代码复用"
        | ConditionalPattern -> "逻辑分支"
        | LoopPattern -> "重复操作"
        | MatchPattern -> "类型解构"
        | RecursionPattern -> "分治处理"
        | DataProcessingPattern -> "数据变换"
        | ErrorHandlingPattern -> "异常处理"
        | AlgorithmPattern -> "问题求解"
        | NamingPattern -> "代码可读性"
        | ModulePattern -> "代码组织"
      ) pattern_types));
  }

(** 计算复杂度指标 *)
let calculate_complexity (expr: simple_expr) : complexity_metrics =
  let rec count_complexity acc_cyclo acc_depth current_depth acc_length = function
    | SIfThenElse (_, then_branch, else_branch) ->
        let cyclo1 = acc_cyclo + 1 in
        let (cyclo2, depth2, length2) = count_complexity cyclo1 acc_depth (current_depth + 1) (acc_length + 1) then_branch in
        count_complexity cyclo2 (max acc_depth depth2) (current_depth + 1) length2 else_branch
    | SMatch (_, cases) ->
        let cyclo1 = acc_cyclo + List.length cases in
        List.fold_left (fun (c, d, l) (_, e) ->
          count_complexity c d (current_depth + 1) l e
        ) (cyclo1, max acc_depth (current_depth + 1), acc_length + 1) cases
    | SFunctionDef (params, body) ->
        let param_count = List.length params in
        count_complexity acc_cyclo acc_depth (current_depth + 1) (acc_length + param_count + 1) body
    | SRecursiveFunctionDef (_, params, body) ->
        let param_count = List.length params in
        let cyclo1 = acc_cyclo + 1 in
        count_complexity cyclo1 acc_depth (current_depth + 1) (acc_length + param_count + 1) body
    | SLetIn (_, value, body) ->
        let (cyclo1, depth1, length1) = count_complexity acc_cyclo acc_depth current_depth (acc_length + 1) value in
        count_complexity cyclo1 depth1 current_depth length1 body
    | SBinaryOp (_, e1, e2) ->
        let (cyclo1, depth1, length1) = count_complexity acc_cyclo acc_depth current_depth (acc_length + 1) e1 in
        count_complexity cyclo1 depth1 current_depth length1 e2
    | SUnaryOp (_, e) ->
        count_complexity acc_cyclo acc_depth current_depth (acc_length + 1) e
    | SFunctionCall (_, args) ->
        List.fold_left (fun (c, d, l) arg ->
          count_complexity c d current_depth l arg
        ) (acc_cyclo, acc_depth, acc_length + 1) args
    | STuple exprs | SList exprs ->
        List.fold_left (fun (c, d, l) expr ->
          count_complexity c d current_depth l expr
        ) (acc_cyclo, acc_depth, acc_length + 1) exprs
    | SRecord fields ->
        List.fold_left (fun (c, d, l) (_, expr) ->
          count_complexity c d current_depth l expr
        ) (acc_cyclo, acc_depth, acc_length + 1) fields
    | _ -> (acc_cyclo, max acc_depth current_depth, acc_length + 1)
  in
  let (cyclomatic, depth, length) = count_complexity 1 0 0 0 expr in
  let param_count = match expr with
    | SFunctionDef (params, _) | SRecursiveFunctionDef (_, params, _) -> List.length params
    | _ -> 0
  in
  {
    cyclomatic_complexity = cyclomatic;
    nesting_depth = depth;
    function_length = length;
    parameter_count = param_count;
  }

(** 分析代码库 *)
let analyze_codebase (code_files: string list) : code_pattern list =
  let patterns = ref [] in
  let start_time = Unix.time () in
  
  Printf.printf "🔍 开始分析代码库，共 %d 个文件\n" (List.length code_files);
  
  List.iteri (fun i code ->
    Printf.printf "📄 分析文件 %d/%d\n" (i + 1) (List.length code_files);
    try
      (* 这里应该解析代码为AST，为了示例简化 *)
      let dummy_expr = SLiteral code in
      let pattern = extract_pattern dummy_expr in
      patterns := pattern :: !patterns;
      
      (* 更新使用频率统计 *)
      let current_count = try Hashtbl.find pattern_store.pattern_count pattern.pattern_id with Not_found -> 0 in
      Hashtbl.replace pattern_store.pattern_count pattern.pattern_id (current_count + 1);
      
    with
    | e ->
        Printf.printf "⚠️  文件 %d 解析出错: %s\n" (i + 1) (Printexc.to_string e)
  ) code_files;
  
  let end_time = Unix.time () in
  let analysis_time = end_time -. start_time in
  
  Printf.printf "✅ 代码库分析完成，用时 %.2f 秒\n" analysis_time;
  Printf.printf "📊 发现 %d 个代码模式\n" (List.length !patterns);
  
  !patterns

(** 从代码学习 *)
let learn_from_code (expressions: simple_expr list) : unit =
  let start_time = Unix.time () in
  Printf.printf "🎓 开始从代码学习模式...\n";
  
  let new_patterns = List.map extract_pattern expressions in
  
  (* 更新模式库 *)
  pattern_store.patterns <- new_patterns @ pattern_store.patterns;
  
  (* 更新学习统计 *)
  let end_time = Unix.time () in
  let learning_time = end_time -. start_time in
  let stats = {
    total_patterns = List.length pattern_store.patterns;
    new_patterns_found = List.length new_patterns;
    pattern_confidence_avg = 
      (let confidences = List.map (fun p -> p.confidence) new_patterns in
       if confidences = [] then 0.0 
       else List.fold_left (+.) 0.0 confidences /. float_of_int (List.length confidences));
    learning_accuracy = 0.85; (* 简化的准确率计算 *)
    analysis_time = learning_time;
    memory_usage = (Gc.stat ()).Gc.heap_words * 8; (* 近似内存使用 *)
  } in
  
  pattern_store.learning_history <- stats :: pattern_store.learning_history;
  
  Printf.printf "✅ 学习完成！发现 %d 个新模式，总计 %d 个模式\n" 
    stats.new_patterns_found stats.total_patterns;
  Printf.printf "📈 平均置信度: %.2f%%, 学习准确率: %.2f%%\n" 
    (stats.pattern_confidence_avg *. 100.0) (stats.learning_accuracy *. 100.0)

(** 获取模式建议 *)
let get_pattern_suggestions (expr: simple_expr) : code_pattern list =
  let target_types = analyze_ast_structure expr in
  let target_complexity = calculate_complexity expr in
  
  (* 根据模式类型和复杂度筛选相似模式 *)
  let similar_patterns = List.filter (fun pattern ->
    List.exists (fun target_type -> pattern.pattern_type = target_type) target_types ||
    (let pattern_complexity = calculate_complexity pattern.structure in
     abs (pattern_complexity.cyclomatic_complexity - target_complexity.cyclomatic_complexity) <= 2)
  ) pattern_store.patterns in
  
  (* 按置信度和使用频率排序 *)
  let sorted_patterns = List.sort (fun p1 p2 ->
    let freq1 = try Hashtbl.find pattern_store.pattern_count p1.pattern_id with Not_found -> 0 in
    let freq2 = try Hashtbl.find pattern_store.pattern_count p2.pattern_id with Not_found -> 0 in
    let score1 = p1.confidence *. (1.0 +. log (float_of_int (freq1 + 1))) in
    let score2 = p2.confidence *. (1.0 +. log (float_of_int (freq2 + 1))) in
    compare score2 score1
  ) similar_patterns in
  
  (* 返回前5个建议 *)
  let rec take n = function
    | [] -> []
    | h :: t when n > 0 -> h :: take (n - 1) t
    | _ -> []
  in
  take 5 sorted_patterns

(** 导出学习数据 *)
let export_learning_data () : learning_stats =
  match pattern_store.learning_history with
  | [] -> {
      total_patterns = List.length pattern_store.patterns;
      new_patterns_found = 0;
      pattern_confidence_avg = 0.0;
      learning_accuracy = 0.0;
      analysis_time = 0.0;
      memory_usage = 0;
    }
  | latest :: _ -> latest

(** 格式化学习统计 *)
let format_learning_stats (stats: learning_stats) : string =
  Printf.sprintf 
    "📊 代码模式学习统计报告\n\
     ═══════════════════════════════\n\
     🔢 总模式数量: %d\n\
     🆕 新发现模式: %d\n\
     📈 平均置信度: %.1f%%\n\
     🎯 学习准确率: %.1f%%\n\
     ⏱️  分析用时: %.2f 秒\n\
     💾 内存使用: %.2f MB\n\
     ═══════════════════════════════"
    stats.total_patterns
    stats.new_patterns_found
    (stats.pattern_confidence_avg *. 100.0)
    (stats.learning_accuracy *. 100.0)
    stats.analysis_time
    (float_of_int stats.memory_usage /. 1024.0 /. 1024.0)

(** 清理过时模式 *)
let cleanup_patterns (max_age_days: int) : unit =
  let current_time = Unix.time () in
  let max_age_seconds = float_of_int (max_age_days * 24 * 3600) in
  
  let valid_patterns = List.filter (fun pattern ->
    try
      let pattern_time = float_of_string (String.sub pattern.pattern_id 
        (String.length pattern.pattern_id - 10) 10) in
      current_time -. pattern_time < max_age_seconds
    with _ -> true (* 保留无法解析时间的模式 *)
  ) pattern_store.patterns in
  
  let removed_count = List.length pattern_store.patterns - List.length valid_patterns in
  pattern_store.patterns <- valid_patterns;
  
  Printf.printf "🧹 清理完成，移除 %d 个过时模式\n" removed_count

(** 模式相似度计算 *)
let calculate_pattern_similarity (p1: code_pattern) (p2: code_pattern) : float =
  let type_similarity = if p1.pattern_type = p2.pattern_type then 1.0 else 0.0 in
  let context_similarity = 
    let common_tags = List.filter (fun tag -> List.mem tag p2.context_tags) p1.context_tags in
    let total_tags = List.length p1.context_tags + List.length p2.context_tags in
    if total_tags = 0 then 1.0
    else float_of_int (List.length common_tags * 2) /. float_of_int total_tags
  in
  (type_similarity *. 0.6) +. (context_similarity *. 0.4)

(** 聚类相似模式 *)
let cluster_similar_patterns () : unit =
  Printf.printf "🔗 开始聚类相似模式...\n";
  let patterns = pattern_store.patterns in
  let clustered_patterns = ref [] in
  
  List.iter (fun pattern ->
    let similar_patterns = List.filter (fun other ->
      pattern.pattern_id <> other.pattern_id &&
      calculate_pattern_similarity pattern other > 0.7
    ) patterns in
    
    if similar_patterns <> [] then (
      let updated_pattern = { pattern with variations = similar_patterns } in
      clustered_patterns := updated_pattern :: !clustered_patterns
    ) else (
      clustered_patterns := pattern :: !clustered_patterns
    )
  ) patterns;
  
  pattern_store.patterns <- !clustered_patterns;
  Printf.printf "✅ 模式聚类完成\n"

(** 测试模式学习系统 *)
let test_pattern_learning_system () =
  Printf.printf "\n🧪 代码模式学习系统测试\n";
  Printf.printf "═══════════════════════════════════\n";
  
  (* 测试用例 *)
  let test_expressions = [
    SRecursiveFunctionDef ("阶乘", ["n"], 
      SIfThenElse (
        SBinaryOp ("<=", SVariable "n", SLiteral "1"),
        SLiteral "1",
        SBinaryOp ("*", SVariable "n", 
          SFunctionCall ("阶乘", [SBinaryOp ("-", SVariable "n", SLiteral "1")]))
      ));
    
    SIfThenElse (
      SBinaryOp (">", SVariable "年龄", SLiteral "18"),
      SLiteral "成年人",
      SLiteral "未成年人");
    
    SMatch (SVariable "结果", [
      ("成功", SVariable "值");
      ("失败", SFunctionCall ("处理错误", [SVariable "错误"]));
    ]);
  ] in
  
  (* 从表达式学习模式 *)
  List.iteri (fun i expr ->
    Printf.printf "\n🔍 测试表达式 %d:\n" (i + 1);
    let pattern = extract_pattern expr in
    Printf.printf "   模式类型: %s\n" (match pattern.pattern_type with
      | FunctionPattern -> "函数模式"
      | ConditionalPattern -> "条件模式"
      | MatchPattern -> "匹配模式"
      | RecursionPattern -> "递归模式"
      | _ -> "其他模式");
    Printf.printf "   置信度: %.0f%%\n" (pattern.confidence *. 100.0);
    Printf.printf "   语义含义: %s\n" pattern.semantic_meaning;
    
    (* 计算复杂度 *)
    let complexity = calculate_complexity expr in
    Printf.printf "   复杂度指标:\n";
    Printf.printf "     - 圈复杂度: %d\n" complexity.cyclomatic_complexity;
    Printf.printf "     - 嵌套深度: %d\n" complexity.nesting_depth;
    Printf.printf "     - 函数长度: %d\n" complexity.function_length;
    
    (* 添加到模式库 *)
    pattern_store.patterns <- pattern :: pattern_store.patterns;
  ) test_expressions;
  
  (* 测试模式建议 *)
  Printf.printf "\n🎯 测试模式建议:\n";
  let suggestions = get_pattern_suggestions (List.hd test_expressions) in
  List.iteri (fun i suggestion ->
    Printf.printf "%d. %s (置信度: %.0f%%)\n" 
      (i + 1)
      (match suggestion.pattern_type with
       | FunctionPattern -> "函数模式"
       | ConditionalPattern -> "条件模式"
       | RecursionPattern -> "递归模式"
       | _ -> "其他模式")
      (suggestion.confidence *. 100.0)
  ) suggestions;
  
  (* 导出学习统计 *)
  let stats = export_learning_data () in
  Printf.printf "\n%s\n" (format_learning_stats stats);
  
  Printf.printf "\n🎉 代码模式学习系统测试完成！\n"