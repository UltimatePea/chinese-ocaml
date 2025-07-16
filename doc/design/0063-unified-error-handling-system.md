# 统一错误处理系统设计规范

## 1. 设计概述

基于对骆言编译器代码库的深入分析，我们发现了以下关键问题：

1. **异常定义重复**：至少8个不同的异常类型分散在6个模块中
2. **错误消息格式不一致**：存在至少3种不同的位置信息格式
3. **错误处理模式重复**：`try...with Not_found`模式出现18次
4. **错误上下文信息缺失**：大多数错误缺少文件名、行号和调用栈信息
5. **错误恢复机制分散**：恢复逻辑分散在4个不同模块中

## 2. 现有错误处理模式分析

### 2.1 当前异常定义分布

```ocaml
(* 现有异常定义统计 *)
- types.ml: 4个异常 (TypeError, ParseError, CodegenError, SemanticError)
- semantic.ml: 1个异常 (SemanticError) - 与types.ml重复但签名不同
- lexer.ml: 1个异常 (LexError)
- value_operations.ml: 2个异常 (RuntimeError, ExceptionRaised)
- Parser_utils.ml: 1个异常 (SyntaxError)
- Parser_poetry.ml: 1个异常 (PoetryParseError)
- lexer_core.ml: 1个异常 (LexError) - 与lexer.ml重复
```

### 2.2 错误消息格式化不一致性

**当前存在的格式变体：**

```ocaml
(* 格式1: compiler_errors.ml *)
"语法错误 (%s): %s" (format_position pos) msg

(* 格式2: error_utils.ml *)
"语法错误 (行:%d, 列:%d): 期望 %s" pos.line pos.column expected

(* 格式3: 直接字符串拼接 *)
"未定义的变量: " ^ var

(* 格式4: 带上下文的格式 *)
"代码生成错误 [%s]: %s" context msg
```

### 2.3 重复的错误处理模式

**模式1: Not_found异常处理**
```ocaml
(* 出现在以下位置： *)
- value_operations.ml:54 (变量查找)
- keyword_matcher.ml:162 (关键字查找)
- types.ml:150 (类型替换查找)
- refactoring_analyzer.ml:185 (模式计数查找)
- ai/pattern_learning_system.ml:300 (模式存储查找)
```

**模式2: 类型转换错误处理**
```ocaml
(* 出现在以下位置： *)
- error_messages.ml:292-293 (字符串转整数)
- config.ml:218,220,226 (配置值转换)
```

## 3. 统一错误处理系统设计

### 3.1 核心异常类型定义

```ocaml
(* src/unified_errors.ml *)
module UnifiedErrors = struct
  
  (** 统一位置信息 *)
  type source_location = {
    filename: string;
    line: int;
    column: int;
  }
  
  (** 错误上下文信息 *)
  type error_context = {
    module_name: string;
    function_name: string;
    call_stack: string list;
    related_variables: (string * string) list; (* 变量名 -> 值 *)
  }
  
  (** 统一错误类型 *)
  type unified_error_type =
    | LexicalError of string * source_location
    | SyntaxError of string * source_location
    | SemanticError of string * source_location
    | TypeError of string * source_location
    | RuntimeError of string * source_location option
    | CodegenError of string * string (* 消息 * 上下文 *)
    | InternalError of string
    | PoetryParseError of string * source_location
    | ConfigError of string * string (* 配置项 * 错误描述 *)
  
  (** 统一异常定义 *)
  exception UnifiedCompilerError of unified_error_type * error_context option
  
  (** 错误严重程度 *)
  type error_severity = Warning | Error | Fatal
  
  (** 增强错误信息 *)
  type enhanced_error = {
    error_type: unified_error_type;
    severity: error_severity;
    context: error_context option;
    timestamp: float;
    suggestions: string list;
  }

end
```

### 3.2 统一错误消息格式化

```ocaml
(* src/unified_error_formatter.ml *)
module UnifiedErrorFormatter = struct
  open UnifiedErrors
  
  (** 格式化位置信息 *)
  let format_location loc =
    Printf.sprintf "%s:%d:%d" loc.filename loc.line loc.column
  
  (** 格式化错误类型标识 *)
  let format_error_type = function
    | LexicalError _ -> "词法错误"
    | SyntaxError _ -> "语法错误"
    | SemanticError _ -> "语义错误"
    | TypeError _ -> "类型错误"
    | RuntimeError _ -> "运行时错误"
    | CodegenError _ -> "代码生成错误"
    | InternalError _ -> "内部错误"
    | PoetryParseError _ -> "诗词解析错误"
    | ConfigError _ -> "配置错误"
  
  (** 格式化错误消息 *)
  let format_error_message error_type =
    match error_type with
    | LexicalError (msg, loc) ->
        Printf.sprintf "%s (%s): %s" 
          (format_error_type error_type) (format_location loc) msg
    | SyntaxError (msg, loc) ->
        Printf.sprintf "%s (%s): %s" 
          (format_error_type error_type) (format_location loc) msg
    | SemanticError (msg, loc) ->
        Printf.sprintf "%s (%s): %s" 
          (format_error_type error_type) (format_location loc) msg
    | TypeError (msg, loc) ->
        Printf.sprintf "%s (%s): %s" 
          (format_error_type error_type) (format_location loc) msg
    | RuntimeError (msg, Some loc) ->
        Printf.sprintf "%s (%s): %s" 
          (format_error_type error_type) (format_location loc) msg
    | RuntimeError (msg, None) ->
        Printf.sprintf "%s: %s" (format_error_type error_type) msg
    | CodegenError (msg, context) ->
        Printf.sprintf "%s [%s]: %s" 
          (format_error_type error_type) context msg
    | InternalError msg ->
        Printf.sprintf "%s: %s" (format_error_type error_type) msg
    | PoetryParseError (msg, loc) ->
        Printf.sprintf "%s (%s): %s" 
          (format_error_type error_type) (format_location loc) msg
    | ConfigError (setting, msg) ->
        Printf.sprintf "%s [%s]: %s" 
          (format_error_type error_type) setting msg
  
  (** 格式化上下文信息 *)
  let format_context context =
    let module_info = Printf.sprintf "模块: %s" context.module_name in
    let function_info = Printf.sprintf "函数: %s" context.function_name in
    let call_stack_info = 
      if List.length context.call_stack > 0 then
        "\n调用栈:\n" ^ 
        String.concat "\n" 
          (List.mapi (fun i frame -> 
            Printf.sprintf "  %d. %s" (i + 1) frame) context.call_stack)
      else ""
    in
    let variables_info =
      if List.length context.related_variables > 0 then
        "\n相关变量:\n" ^
        String.concat "\n"
          (List.map (fun (name, value) ->
            Printf.sprintf "  %s = %s" name value) context.related_variables)
      else ""
    in
    Printf.sprintf "\n[上下文] %s | %s%s%s" 
      module_info function_info call_stack_info variables_info
  
  (** 格式化建议信息 *)
  let format_suggestions suggestions =
    if List.length suggestions > 0 then
      "\n💡 建议:\n" ^
      String.concat "\n"
        (List.mapi (fun i suggestion ->
          Printf.sprintf "  %d. %s" (i + 1) suggestion) suggestions)
    else ""
  
  (** 格式化完整错误报告 *)
  let format_enhanced_error enhanced_error =
    let severity_emoji = match enhanced_error.severity with
      | Warning -> "⚠️"
      | Error -> "🚨"
      | Fatal -> "💀"
    in
    let main_message = format_error_message enhanced_error.error_type in
    let context_info = match enhanced_error.context with
      | Some ctx -> format_context ctx
      | None -> ""
    in
    let suggestions_info = format_suggestions enhanced_error.suggestions in
    
    Printf.sprintf "%s %s%s%s" 
      severity_emoji main_message context_info suggestions_info

end
```

### 3.3 统一错误处理工具

```ocaml
(* src/unified_error_utils.ml *)
module UnifiedErrorUtils = struct
  open UnifiedErrors
  
  (** 创建位置信息 *)
  let make_location filename line column =
    { filename; line; column }
  
  (** 创建错误上下文 *)
  let make_context ?(call_stack = []) ?(related_variables = []) 
                   module_name function_name =
    { module_name; function_name; call_stack; related_variables }
  
  (** 安全查找操作 *)
  let safe_lookup ~lookup_fn ~key ~error_msg ~location ~context =
    try Some (lookup_fn key)
    with Not_found -> 
      let error_type = RuntimeError (error_msg, location) in
      raise (UnifiedCompilerError (error_type, context))
  
  (** 安全类型转换 *)
  let safe_convert ~converter ~value ~error_msg ~location ~context =
    try converter value
    with _ -> 
      let error_type = RuntimeError (error_msg, location) in
      raise (UnifiedCompilerError (error_type, context))
  
  (** 带上下文的操作包装 *)
  let with_unified_context module_name function_name f =
    let context = make_context module_name function_name in
    try f ()
    with 
    | UnifiedCompilerError (error_type, None) ->
        raise (UnifiedCompilerError (error_type, Some context))
    | UnifiedCompilerError (error_type, Some existing_context) ->
        let enhanced_context = {
          existing_context with
          call_stack = (module_name ^ "." ^ function_name) :: existing_context.call_stack
        } in
        raise (UnifiedCompilerError (error_type, Some enhanced_context))
    | exn ->
        let error_type = InternalError (Printexc.to_string exn) in
        raise (UnifiedCompilerError (error_type, Some context))
  
  (** 错误收集器 *)
  type error_collector = {
    mutable errors: enhanced_error list;
    mutable warnings: enhanced_error list;
  }
  
  let create_collector () = 
    { errors = []; warnings = [] }
  
  let add_error collector enhanced_error =
    match enhanced_error.severity with
    | Warning -> collector.warnings <- enhanced_error :: collector.warnings
    | Error | Fatal -> collector.errors <- enhanced_error :: collector.errors
  
  let get_all_errors collector =
    List.rev collector.errors @ List.rev collector.warnings

end
```

### 3.4 统一错误恢复框架

```ocaml
(* src/unified_error_recovery.ml *)
module UnifiedErrorRecovery = struct
  open UnifiedErrors
  
  (** 恢复策略 *)
  type recovery_strategy =
    | NoRecovery
    | SkipAndContinue
    | UseDefault of string
    | SpellCorrection of string list (* 可选建议 *)
    | UserPrompt of string
    | Retry of int (* 重试次数 *)
  
  (** 恢复配置 *)
  type recovery_config = {
    enable_spell_correction: bool;
    enable_type_coercion: bool;
    max_retry_attempts: int;
    interactive_mode: bool;
  }
  
  (** 默认恢复配置 *)
  let default_recovery_config = {
    enable_spell_correction = true;
    enable_type_coercion = true;
    max_retry_attempts = 3;
    interactive_mode = false;
  }
  
  (** 根据错误类型确定恢复策略 *)
  let determine_recovery_strategy error_type config =
    match error_type with
    | LexicalError _ -> NoRecovery
    | SyntaxError _ -> SkipAndContinue
    | SemanticError _ -> SkipAndContinue
    | TypeError _ when config.enable_type_coercion -> UseDefault "类型转换"
    | RuntimeError _ when config.enable_spell_correction -> 
        SpellCorrection []
    | CodegenError _ -> UseDefault "默认代码生成"
    | InternalError _ -> NoRecovery
    | PoetryParseError _ -> UserPrompt "诗词解析需要用户干预"
    | ConfigError _ -> UseDefault "默认配置值"
  
  (** 执行恢复策略 *)
  let apply_recovery_strategy strategy error_type =
    match strategy with
    | NoRecovery -> None
    | SkipAndContinue -> Some "跳过错误并继续"
    | UseDefault default_action -> Some default_action
    | SpellCorrection suggestions -> 
        Some ("拼写纠正: " ^ String.concat ", " suggestions)
    | UserPrompt prompt -> Some prompt
    | Retry attempts -> Some (Printf.sprintf "重试 %d 次" attempts)

end
```

## 4. 迁移策略

### 4.1 第一阶段：建立基础设施

```ocaml
(* 创建新的统一错误处理模块 *)
1. 创建 src/unified_errors.ml
2. 创建 src/unified_error_formatter.ml  
3. 创建 src/unified_error_utils.ml
4. 创建 src/unified_error_recovery.ml
5. 更新 src/dune 文件添加新模块
```

### 4.2 第二阶段：逐步迁移现有模块

**优先级顺序：**
1. **lexer.ml** - 影响面小，异常类型简单
2. **Parser_utils.ml** - 被多个parser模块使用
3. **semantic.ml** - 语义分析错误
4. **types.ml** - 类型错误，影响面大
5. **value_operations.ml** - 运行时错误
6. **其他模块** - 逐步迁移

**迁移步骤（以lexer.ml为例）：**

```ocaml
(* 原始代码 *)
exception LexError of string * position

(* 迁移后 *)
open UnifiedErrors
open UnifiedErrorUtils

(* 替换异常抛出 *)
(* 原始: *)
raise (LexError ("无效字符: " ^ char, pos))

(* 迁移后: *)
let location = make_location pos.filename pos.line pos.column in
let context = make_context "Lexer" "tokenize" in
let error_type = LexicalError ("无效字符: " ^ char, location) in
raise (UnifiedCompilerError (error_type, Some context))
```

### 4.3 第三阶段：清理和优化

1. 删除旧的异常定义
2. 更新错误处理调用点
3. 添加更多上下文信息
4. 优化性能

## 5. 具体实施示例

### 5.1 value_operations.ml迁移示例

**原始代码：**
```ocaml
let rec lookup_var env name =
  try List.assoc name env
  with Not_found -> raise (RuntimeError ("未定义的变量: " ^ name))
```

**迁移后：**
```ocaml
let rec lookup_var env name =
  let context = make_context "ValueOperations" "lookup_var" 
    ~related_variables:[("name", name); ("env_size", string_of_int (List.length env))] in
  safe_lookup 
    ~lookup_fn:(List.assoc name)
    ~key:env
    ~error_msg:("未定义的变量: " ^ name)
    ~location:None
    ~context:(Some context)
```

### 5.2 types.ml迁移示例

**原始代码：**
```ocaml
let unify typ1 typ2 =
  match (typ1, typ2) with
  | (IntType_T, IntType_T) -> empty_subst
  | _ -> raise (TypeError ("无法统一类型: " ^ show_typ typ1 ^ " 与 " ^ show_typ typ2))
```

**迁移后：**
```ocaml
let unify typ1 typ2 =
  let context = make_context "Types" "unify" 
    ~related_variables:[("typ1", show_typ typ1); ("typ2", show_typ typ2)] in
  with_unified_context "Types" "unify" (fun () ->
    match (typ1, typ2) with
    | (IntType_T, IntType_T) -> empty_subst
    | _ -> 
        let error_type = TypeError ("无法统一类型: " ^ show_typ typ1 ^ " 与 " ^ show_typ typ2, 
                                  make_location "<types>" 0 0) in
        raise (UnifiedCompilerError (error_type, Some context))
  )
```

## 6. 测试策略

### 6.1 单元测试

```ocaml
(* test/test_unified_errors.ml *)
let test_error_formatting () =
  let loc = make_location "test.ly" 10 5 in
  let error_type = TypeError ("类型不匹配", loc) in
  let context = make_context "TestModule" "test_function" in
  let enhanced_error = {
    error_type;
    severity = Error;
    context = Some context;
    timestamp = Unix.time ();
    suggestions = ["检查类型注解"; "使用类型转换"];
  } in
  let formatted = UnifiedErrorFormatter.format_enhanced_error enhanced_error in
  assert (String.contains formatted "类型错误");
  assert (String.contains formatted "test.ly:10:5");
  assert (String.contains formatted "TestModule")
```

### 6.2 集成测试

```ocaml
(* test/test_unified_error_integration.ml *)
let test_lexer_error_integration () =
  let source = "让 x = 123$" in (* 包含无效字符 *)
  try
    let _ = Lexer.tokenize source in
    assert false
  with UnifiedCompilerError (error_type, context) ->
    match error_type with
    | LexicalError (msg, _) -> 
        assert (String.contains msg "无效字符");
        assert (context <> None)
    | _ -> assert false
```

## 7. 性能考虑

### 7.1 性能优化措施

1. **延迟上下文构建**：只在实际发生错误时构建详细上下文
2. **错误消息缓存**：缓存常见错误消息的格式化结果
3. **可配置详细程度**：根据配置控制上下文信息的详细程度

```ocaml
(* 延迟上下文构建示例 *)
let lazy_context_operation f =
  try f ()
  with UnifiedCompilerError (error_type, None) ->
    (* 只有在捕获到错误时才构建上下文 *)
    let context = make_context "LazyModule" "lazy_operation" in
    raise (UnifiedCompilerError (error_type, Some context))
```

### 7.2 性能基准测试

```ocaml
(* 性能测试：比较统一错误处理与原始方法 *)
let benchmark_error_handling () =
  let iterations = 10000 in
  
  (* 原始方法 *)
  let start_time = Unix.time () in
  for i = 1 to iterations do
    try raise (RuntimeError "test error")
    with RuntimeError _ -> ()
  done;
  let original_time = Unix.time () -. start_time in
  
  (* 统一错误处理 *)
  let start_time = Unix.time () in
  for i = 1 to iterations do
    try 
      let error_type = RuntimeError ("test error", None) in
      raise (UnifiedCompilerError (error_type, None))
    with UnifiedCompilerError _ -> ()
  done;
  let unified_time = Unix.time () -. start_time in
  
  Printf.printf "原始方法: %.6fs, 统一方法: %.6fs, 比率: %.2f\n" 
    original_time unified_time (unified_time /. original_time)
```

## 8. 向后兼容性

### 8.1 渐进式迁移

```ocaml
(* 兼容性包装器 *)
module LegacyErrorCompat = struct
  (* 保持旧的异常定义用于向后兼容 *)
  exception LexError of string * Lexer.position
  exception SyntaxError of string * Lexer.position
  exception RuntimeError of string
  
  (* 转换函数 *)
  let convert_to_unified = function
    | LexError (msg, pos) -> 
        let location = make_location pos.filename pos.line pos.column in
        LexicalError (msg, location)
    | SyntaxError (msg, pos) ->
        let location = make_location pos.filename pos.line pos.column in
        SyntaxError (msg, location)
    | RuntimeError msg ->
        RuntimeError (msg, None)
  
  (* 兼容性包装函数 *)
  let wrap_legacy_function f =
    try f ()
    with
    | LexError _ | SyntaxError _ | RuntimeError _ as legacy_error ->
        let unified_error = convert_to_unified legacy_error in
        raise (UnifiedCompilerError (unified_error, None))
end
```

## 9. 文档和培训

### 9.1 开发者指南

```markdown
# 统一错误处理使用指南

## 基本用法

### 抛出错误
```ocaml
let context = make_context "MyModule" "my_function" in
let error_type = TypeError ("类型不匹配", location) in
raise (UnifiedCompilerError (error_type, Some context))
```

### 捕获错误
```ocaml
try some_operation ()
with UnifiedCompilerError (error_type, context) ->
  let formatted = UnifiedErrorFormatter.format_enhanced_error {
    error_type; severity = Error; context; timestamp = Unix.time (); suggestions = []
  } in
  Printf.eprintf "%s\n" formatted
```

## 最佳实践

1. 始终提供有意义的错误消息
2. 包含足够的上下文信息
3. 提供有用的建议
4. 使用适当的错误严重级别
```

## 10. 总结

统一错误处理系统将为骆言编译器提供：

1. **一致的错误报告格式**
2. **丰富的错误上下文信息**
3. **智能的错误恢复机制**
4. **易于维护的错误处理代码**
5. **更好的开发者体验**

通过逐步迁移现有代码到统一系统，我们可以显著提高代码库的质量和可维护性，同时为用户提供更好的错误诊断和恢复体验。