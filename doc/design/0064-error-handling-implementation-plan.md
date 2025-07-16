# 统一错误处理系统实施计划

## 实施概述

基于错误处理统一化分析，本文档详细描述了具体的实施步骤和代码示例。我们将通过四个阶段逐步建立统一的错误处理系统。

## 阶段1：基础设施建设

### 1.1 创建统一错误类型定义

```ocaml
(* src/unified_errors.ml *)
open Token_types

(** 统一位置信息 *)
type source_location = {
  filename: string;
  line: int;
  column: int;
} [@@deriving show]

(** 错误上下文信息 *)
type error_context = {
  module_name: string;
  function_name: string;
  call_stack: string list;
  related_variables: (string * string) list;
  timestamp: float;
} [@@deriving show]

(** 统一错误类型 *)
type unified_error_type =
  | LexicalError of string * source_location
  | SyntaxError of string * source_location  
  | SemanticError of string * source_location
  | TypeError of string * source_location
  | RuntimeError of string * source_location option
  | CodegenError of string * string
  | InternalError of string
  | PoetryParseError of string * source_location
  | ConfigError of string * string
  | IOError of string * string
[@@deriving show]

(** 错误严重程度 *)
type error_severity = 
  | Warning 
  | Error 
  | Fatal 
[@@deriving show]

(** 统一异常定义 *)
exception UnifiedCompilerError of unified_error_type * error_context option

(** 增强错误信息 *)
type enhanced_error = {
  error_type: unified_error_type;
  severity: error_severity;
  context: error_context option;
  suggestions: string list;
  fix_hints: string list;
  confidence: float;
} [@@deriving show]

(** 错误统计信息 *)
type error_statistics = {
  mutable total_errors: int;
  mutable warnings: int;
  mutable errors: int;
  mutable fatal_errors: int;
  mutable recovered_errors: int;
  mutable start_time: float;
} [@@deriving show]

(** 全局错误统计 *)
let global_error_stats = {
  total_errors = 0;
  warnings = 0;
  errors = 0;
  fatal_errors = 0;
  recovered_errors = 0;
  start_time = Unix.time ();
}

(** 兼容性类型别名 *)
type position = source_location
```

### 1.2 创建错误处理工具库

```ocaml
(* src/unified_error_utils.ml *)
open Unified_errors

(** 创建位置信息 *)
let make_location filename line column =
  { filename; line; column }

(** 从Token_types.position转换 *)
let from_token_position (pos: Token_types.position) =
  { filename = pos.filename; line = pos.line; column = pos.column }

(** 创建错误上下文 *)
let make_context ?(call_stack = []) ?(related_variables = []) 
                 module_name function_name =
  { 
    module_name; 
    function_name; 
    call_stack; 
    related_variables;
    timestamp = Unix.time ();
  }

(** 添加变量到上下文 *)
let add_variable context var_name var_value =
  { context with 
    related_variables = (var_name, var_value) :: context.related_variables }

(** 添加调用栈到上下文 *)
let add_call_frame context frame =
  { context with call_stack = frame :: context.call_stack }

(** 安全查找操作 *)
let safe_hashtbl_find ~table ~key ~error_msg ~location ~context =
  try Some (Hashtbl.find table key)
  with Not_found -> 
    let error_type = RuntimeError (error_msg, location) in
    raise (UnifiedCompilerError (error_type, context))

(** 安全列表查找 *)
let safe_list_assoc ~list ~key ~error_msg ~location ~context =
  try Some (List.assoc key list)
  with Not_found -> 
    let error_type = RuntimeError (error_msg, location) in
    raise (UnifiedCompilerError (error_type, context))

(** 安全类型转换 *)
let safe_int_of_string ~value ~error_msg ~location ~context =
  try int_of_string value
  with Failure _ -> 
    let error_type = RuntimeError (error_msg, location) in
    raise (UnifiedCompilerError (error_type, context))

(** 安全浮点数转换 *)
let safe_float_of_string ~value ~error_msg ~location ~context =
  try float_of_string value
  with Failure _ -> 
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
      let enhanced_context = add_call_frame existing_context 
        (module_name ^ "." ^ function_name) in
      raise (UnifiedCompilerError (error_type, Some enhanced_context))
  | exn ->
      let error_msg = Printf.sprintf "未处理的异常: %s" (Printexc.to_string exn) in
      let error_type = InternalError error_msg in
      raise (UnifiedCompilerError (error_type, Some context))

(** 错误收集器 *)
type error_collector = {
  mutable errors: enhanced_error list;
  mutable warnings: enhanced_error list;
  mutable has_fatal: bool;
}

let create_error_collector () = 
  { errors = []; warnings = []; has_fatal = false }

let add_enhanced_error collector enhanced_error =
  match enhanced_error.severity with
  | Warning -> collector.warnings <- enhanced_error :: collector.warnings
  | Error -> collector.errors <- enhanced_error :: collector.errors
  | Fatal -> 
      collector.errors <- enhanced_error :: collector.errors;
      collector.has_fatal <- true

let get_all_errors collector =
  List.rev collector.errors

let get_all_warnings collector =
  List.rev collector.warnings

let has_fatal_errors collector = collector.has_fatal
let error_count collector = List.length collector.errors
let warning_count collector = List.length collector.warnings

(** 错误严重程度判断 *)
let is_fatal_error = function
  | InternalError _ -> true
  | _ -> false

let determine_severity error_type =
  if is_fatal_error error_type then Fatal
  else Error

(** 统计更新 *)
let update_global_stats enhanced_error =
  global_error_stats.total_errors <- global_error_stats.total_errors + 1;
  match enhanced_error.severity with
  | Warning -> global_error_stats.warnings <- global_error_stats.warnings + 1
  | Error -> global_error_stats.errors <- global_error_stats.errors + 1
  | Fatal -> global_error_stats.fatal_errors <- global_error_stats.fatal_errors + 1

(** 重置统计 *)
let reset_global_stats () =
  global_error_stats.total_errors <- 0;
  global_error_stats.warnings <- 0;
  global_error_stats.errors <- 0;
  global_error_stats.fatal_errors <- 0;
  global_error_stats.recovered_errors <- 0;
  global_error_stats.start_time <- Unix.time ()
```

### 1.3 创建错误消息格式化器

```ocaml
(* src/unified_error_formatter.ml *)
open Unified_errors

(** 格式化位置信息 *)
let format_location loc =
  Printf.sprintf "%s:%d:%d" loc.filename loc.line loc.column

(** 格式化错误类型标识 *)
let format_error_type_name = function
  | LexicalError _ -> "词法错误"
  | SyntaxError _ -> "语法错误"
  | SemanticError _ -> "语义错误"
  | TypeError _ -> "类型错误"
  | RuntimeError _ -> "运行时错误"
  | CodegenError _ -> "代码生成错误"
  | InternalError _ -> "内部错误"
  | PoetryParseError _ -> "诗词解析错误"
  | ConfigError _ -> "配置错误"
  | IOError _ -> "输入输出错误"

(** 格式化错误消息 *)
let format_error_message error_type =
  match error_type with
  | LexicalError (msg, loc) ->
      Printf.sprintf "%s (%s): %s" 
        (format_error_type_name error_type) (format_location loc) msg
  | SyntaxError (msg, loc) ->
      Printf.sprintf "%s (%s): %s" 
        (format_error_type_name error_type) (format_location loc) msg
  | SemanticError (msg, loc) ->
      Printf.sprintf "%s (%s): %s" 
        (format_error_type_name error_type) (format_location loc) msg
  | TypeError (msg, loc) ->
      Printf.sprintf "%s (%s): %s" 
        (format_error_type_name error_type) (format_location loc) msg
  | RuntimeError (msg, Some loc) ->
      Printf.sprintf "%s (%s): %s" 
        (format_error_type_name error_type) (format_location loc) msg
  | RuntimeError (msg, None) ->
      Printf.sprintf "%s: %s" (format_error_type_name error_type) msg
  | CodegenError (msg, context) ->
      Printf.sprintf "%s [%s]: %s" 
        (format_error_type_name error_type) context msg
  | InternalError msg ->
      Printf.sprintf "%s: %s" (format_error_type_name error_type) msg
  | PoetryParseError (msg, loc) ->
      Printf.sprintf "%s (%s): %s" 
        (format_error_type_name error_type) (format_location loc) msg
  | ConfigError (setting, msg) ->
      Printf.sprintf "%s [%s]: %s" 
        (format_error_type_name error_type) setting msg
  | IOError (operation, msg) ->
      Printf.sprintf "%s [%s]: %s" 
        (format_error_type_name error_type) operation msg

(** 格式化上下文信息 *)
let format_context context =
  let module_info = Printf.sprintf "模块: %s" context.module_name in
  let function_info = Printf.sprintf "函数: %s" context.function_name in
  let timestamp_info = Printf.sprintf "时间: %.2f" context.timestamp in
  
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
  
  Printf.sprintf "\n[上下文] %s | %s | %s%s%s" 
    module_info function_info timestamp_info call_stack_info variables_info

(** 格式化建议信息 *)
let format_suggestions suggestions =
  if List.length suggestions > 0 then
    "\n💡 建议:\n" ^
    String.concat "\n"
      (List.mapi (fun i suggestion ->
        Printf.sprintf "  %d. %s" (i + 1) suggestion) suggestions)
  else ""

(** 格式化修复提示 *)
let format_fix_hints fix_hints =
  if List.length fix_hints > 0 then
    "\n🔧 修复提示:\n" ^
    String.concat "\n"
      (List.mapi (fun i hint ->
        Printf.sprintf "  %d. %s" (i + 1) hint) fix_hints)
  else ""

(** 格式化置信度 *)
let format_confidence confidence =
  Printf.sprintf "\n🎯 AI置信度: %.0f%%" (confidence *. 100.0)

(** 格式化严重程度 *)
let format_severity severity =
  match severity with
  | Warning -> "⚠️"
  | Error -> "🚨"
  | Fatal -> "💀"

(** 格式化完整错误报告 *)
let format_enhanced_error enhanced_error =
  let severity_emoji = format_severity enhanced_error.severity in
  let main_message = format_error_message enhanced_error.error_type in
  let context_info = match enhanced_error.context with
    | Some ctx -> format_context ctx
    | None -> ""
  in
  let suggestions_info = format_suggestions enhanced_error.suggestions in
  let fix_hints_info = format_fix_hints enhanced_error.fix_hints in
  let confidence_info = if enhanced_error.confidence > 0.0 then
    format_confidence enhanced_error.confidence
  else ""
  in
  
  Printf.sprintf "%s %s%s%s%s%s" 
    severity_emoji main_message context_info suggestions_info 
    fix_hints_info confidence_info

(** 彩色输出支持 *)
let colorize_message severity message =
  let runtime_cfg = Config.get_runtime_config () in
  if not runtime_cfg.colored_output then message
  else
    let color_code = match severity with
      | Warning -> "\027[33m" (* 黄色 *)
      | Error -> "\027[31m"   (* 红色 *)
      | Fatal -> "\027[91m"   (* 亮红色 *)
    in
    color_code ^ message ^ "\027[0m"

(** 格式化错误统计报告 *)
let format_error_statistics stats =
  let elapsed_time = Unix.time () -. stats.start_time in
  Printf.sprintf
    "=== 错误统计报告 ===\n\
     总错误数: %d\n\
     警告: %d\n\
     错误: %d\n\
     严重错误: %d\n\
     已恢复错误: %d\n\
     处理时间: %.2f秒\n\
     ==================="
    stats.total_errors stats.warnings stats.errors stats.fatal_errors
    stats.recovered_errors elapsed_time
```

## 阶段2：模块迁移

### 2.1 迁移lexer.ml

```ocaml
(* src/lexer.ml - 迁移示例 *)
open Unified_errors
open Unified_error_utils

(* 删除旧的异常定义 *)
(* exception LexError of string * position *)

(* 更新错误抛出点 *)
let lexer_error msg pos =
  let location = from_token_position pos in
  let context = make_context "Lexer" "tokenize" in
  let error_type = LexicalError (msg, location) in
  raise (UnifiedCompilerError (error_type, Some context))

(* 更新具体的错误抛出 *)
let rec tokenize_helper state =
  match state.input.[state.position] with
  | '$' when state.position < String.length state.input ->
      (* 原始: raise (LexError ("无效字符: $", state.pos)) *)
      lexer_error "无效字符: $" state.pos
  | c when not (is_valid_char c) ->
      (* 原始: raise (LexError ("无效字符: " ^ String.make 1 c, state.pos)) *)
      lexer_error ("无效字符: " ^ String.make 1 c) state.pos
  | _ -> (* 正常处理 *)
      ...

(* 更新错误捕获点 *)
let tokenize source =
  with_unified_context "Lexer" "tokenize" (fun () ->
    let state = create_lexer_state source in
    tokenize_helper state
  )
```

### 2.2 迁移Parser_utils.ml

```ocaml
(* src/Parser_utils.ml - 迁移示例 *)
open Unified_errors
open Unified_error_utils

(* 删除旧的异常定义 *)
(* exception SyntaxError of string * position *)

(* 更新错误抛出函数 *)
let syntax_error msg pos =
  let location = from_token_position pos in
  let context = make_context "Parser" "parse" in
  let error_type = SyntaxError (msg, location) in
  raise (UnifiedCompilerError (error_type, Some context))

(* 更新具体的错误抛出 *)
let expect_token expected_token actual_token pos =
  let msg = Printf.sprintf "期望 %s，但得到 %s" 
    (show_token expected_token) (show_token actual_token) in
  syntax_error msg pos

let unexpected_token token pos =
  let msg = Printf.sprintf "意外的词元: %s" (show_token token) in
  syntax_error msg pos

(* 更新错误处理包装 *)
let with_parse_context function_name f =
  with_unified_context "Parser" function_name f
```

### 2.3 迁移value_operations.ml

```ocaml
(* src/value_operations.ml - 迁移示例 *)
open Unified_errors
open Unified_error_utils

(* 删除旧的异常定义 *)
(* exception RuntimeError of string *)
(* exception ExceptionRaised of runtime_value *)

(* 更新变量查找函数 *)
let rec lookup_var env name =
  let context = make_context "ValueOperations" "lookup_var" 
    ~related_variables:[("name", name); ("env_size", string_of_int (List.length env))] in
  
  match String.split_on_char '.' name with
  | [] -> 
      let error_type = RuntimeError ("空变量名", None) in
      raise (UnifiedCompilerError (error_type, Some context))
  | [var] ->
      (match safe_list_assoc ~list:env ~key:var 
                            ~error_msg:("未定义的变量: " ^ var)
                            ~location:None ~context:(Some context) with
      | Some value -> value
      | None -> 
          (* 错误已经在safe_list_assoc中抛出 *)
          assert false)
  | mod_name :: path ->
      (* 处理模块访问 *)
      let module_value = match safe_list_assoc ~list:env ~key:mod_name
                                              ~error_msg:("未定义的模块: " ^ mod_name)
                                              ~location:None ~context:(Some context) with
        | Some value -> value
        | None -> assert false
      in
      lookup_module_member module_value path

(* 更新模块成员查找 *)
and lookup_module_member module_value path =
  let context = make_context "ValueOperations" "lookup_module_member" 
    ~related_variables:[("path", String.concat "." path)] in
  
  match module_value with
  | ModuleValue members ->
      (match path with
      | [] -> 
          let error_type = RuntimeError ("模块访问路径为空", None) in
          raise (UnifiedCompilerError (error_type, Some context))
      | [member_name] ->
          (match safe_list_assoc ~list:members ~key:member_name
                                ~error_msg:("模块中未找到成员: " ^ member_name)
                                ~location:None ~context:(Some context) with
          | Some value -> value
          | None -> assert false)
      | member_name :: rest_path ->
          let member_value = match safe_list_assoc ~list:members ~key:member_name
                                                  ~error_msg:("模块中未找到成员: " ^ member_name)
                                                  ~location:None ~context:(Some context) with
            | Some value -> value
            | None -> assert false
          in
          lookup_module_member member_value rest_path)
  | _ ->
      let error_type = RuntimeError ("尝试访问非模块类型的成员", None) in
      raise (UnifiedCompilerError (error_type, Some context))

(* 更新函数调用错误处理 *)
let call_function func_value args =
  with_unified_context "ValueOperations" "call_function" (fun () ->
    match func_value with
    | FunctionValue (params, body, closure_env) ->
        if List.length params <> List.length args then
          let error_msg = Printf.sprintf "函数参数数量不匹配: 期望 %d 个，得到 %d 个"
            (List.length params) (List.length args) in
          let error_type = RuntimeError (error_msg, None) in
          let context = make_context "ValueOperations" "call_function" 
            ~related_variables:[("expected_params", string_of_int (List.length params));
                               ("actual_args", string_of_int (List.length args))] in
          raise (UnifiedCompilerError (error_type, Some context))
        else
          let new_env = List.fold_left2 (fun acc param arg -> 
            (param, arg) :: acc) closure_env params args in
          eval_expr body new_env
    | _ ->
        let error_type = RuntimeError ("尝试调用非函数值", None) in
        let context = make_context "ValueOperations" "call_function" in
        raise (UnifiedCompilerError (error_type, Some context))
  )
```

### 2.4 迁移types.ml

```ocaml
(* src/types.ml - 迁移示例 *)
open Unified_errors
open Unified_error_utils

(* 删除旧的异常定义 *)
(* exception TypeError of string *)
(* exception ParseError of string * int * int *)
(* exception CodegenError of string * string *)
(* exception SemanticError of string * string *)

(* 更新类型统一函数 *)
let rec unify typ1 typ2 =
  let context = make_context "Types" "unify" 
    ~related_variables:[("typ1", show_typ typ1); ("typ2", show_typ typ2)] in
  
  with_unified_context "Types" "unify" (fun () ->
    match (typ1, typ2) with
    | (IntType_T, IntType_T) | (FloatType_T, FloatType_T) 
    | (StringType_T, StringType_T) | (BoolType_T, BoolType_T) 
    | (UnitType_T, UnitType_T) -> empty_subst
    | (TypeVar_T var, typ) | (typ, TypeVar_T var) ->
        if occurs_check var typ then
          let error_msg = Printf.sprintf "循环类型检查失败: %s 出现在 %s" var (show_typ typ) in
          let location = make_location "<types>" 0 0 in
          let error_type = TypeError (error_msg, location) in
          raise (UnifiedCompilerError (error_type, Some context))
        else
          single_subst var typ
    | (FunType_T (param1, return1), FunType_T (param2, return2)) ->
        let subst1 = unify param1 param2 in
        let subst2 = unify (apply_subst subst1 return1) (apply_subst subst1 return2) in
        compose_subst subst1 subst2
    | (ListType_T elem1, ListType_T elem2) ->
        unify elem1 elem2
    | (TupleType_T types1, TupleType_T types2) ->
        unify_type_lists types1 types2
    | _ ->
        let error_msg = Printf.sprintf "无法统一类型: %s 与 %s" (show_typ typ1) (show_typ typ2) in
        let location = make_location "<types>" 0 0 in
        let error_type = TypeError (error_msg, location) in
        raise (UnifiedCompilerError (error_type, Some context))
  )

(* 更新类型推断函数 *)
and type_of_expr expr env =
  let context = make_context "Types" "type_of_expr" 
    ~related_variables:[("expr", show_expr expr)] in
  
  with_unified_context "Types" "type_of_expr" (fun () ->
    match expr with
    | LitExpr (IntLit _) -> (empty_subst, IntType_T)
    | LitExpr (FloatLit _) -> (empty_subst, FloatType_T)
    | LitExpr (StringLit _) -> (empty_subst, StringType_T)
    | LitExpr (BoolLit _) -> (empty_subst, BoolType_T)
    | VarExpr var_name ->
        (match safe_list_assoc ~list:env ~key:var_name
                              ~error_msg:("未定义的变量: " ^ var_name)
                              ~location:(Some (make_location "<types>" 0 0))
                              ~context:(Some context) with
        | Some scheme -> 
            let (_, typ) = instantiate scheme in
            (empty_subst, typ)
        | None -> assert false)
    | BinaryOpExpr (left, op, right) ->
        type_of_binary_op left op right env
    | _ ->
        let error_msg = "暂不支持的表达式类型" in
        let location = make_location "<types>" 0 0 in
        let error_type = TypeError (error_msg, location) in
        raise (UnifiedCompilerError (error_type, Some context))
  )

(* 更新二元操作类型推断 *)
and type_of_binary_op left op right env =
  let context = make_context "Types" "type_of_binary_op" 
    ~related_variables:[("op", show_binary_op op)] in
  
  with_unified_context "Types" "type_of_binary_op" (fun () ->
    let (subst1, left_type) = type_of_expr left env in
    let (subst2, right_type) = type_of_expr right (apply_subst_env subst1 env) in
    let subst12 = compose_subst subst1 subst2 in
    
    match op with
    | Add | Sub | Mul | Div ->
        let unified_subst = unify (apply_subst subst12 left_type) IntType_T in
        let final_subst = compose_subst subst12 unified_subst in
        let unified_subst2 = unify (apply_subst final_subst right_type) IntType_T in
        let result_subst = compose_subst final_subst unified_subst2 in
        (result_subst, IntType_T)
    | Eq | Ne | Lt | Le | Gt | Ge ->
        let unified_subst = unify (apply_subst subst12 left_type) (apply_subst subst12 right_type) in
        let final_subst = compose_subst subst12 unified_subst in
        (final_subst, BoolType_T)
    | And | Or ->
        let unified_subst = unify (apply_subst subst12 left_type) BoolType_T in
        let final_subst = compose_subst subst12 unified_subst in
        let unified_subst2 = unify (apply_subst final_subst right_type) BoolType_T in
        let result_subst = compose_subst final_subst unified_subst2 in
        (result_subst, BoolType_T)
  )
```

## 阶段3：错误恢复和智能诊断

### 3.1 创建错误恢复系统

```ocaml
(* src/unified_error_recovery.ml *)
open Unified_errors
open Unified_error_utils

(** 恢复策略 *)
type recovery_strategy =
  | NoRecovery
  | SkipAndContinue  
  | UseDefault of string
  | SpellCorrection of string list
  | TypeCoercion of string
  | UserPrompt of string
  | Retry of int
  | Fallback of (unit -> string)

(** 恢复配置 *)
type recovery_config = {
  enable_spell_correction: bool;
  enable_type_coercion: bool;
  max_retry_attempts: int;
  interactive_mode: bool;
  verbose_recovery: bool;
}

(** 默认恢复配置 *)
let default_recovery_config = {
  enable_spell_correction = true;
  enable_type_coercion = true;
  max_retry_attempts = 3;
  interactive_mode = false;
  verbose_recovery = false;
}

(** 全局恢复配置 *)
let recovery_config = ref default_recovery_config

(** 拼写纠正功能 *)
let levenshtein_distance s1 s2 =
  let len1 = String.length s1 and len2 = String.length s2 in
  let matrix = Array.make_matrix (len1 + 1) (len2 + 1) 0 in
  for i = 0 to len1 do matrix.(i).(0) <- i done;
  for j = 0 to len2 do matrix.(0).(j) <- j done;
  for i = 1 to len1 do
    for j = 1 to len2 do
      let cost = if s1.[i - 1] = s2.[j - 1] then 0 else 1 in
      matrix.(i).(j) <- min (min (matrix.(i - 1).(j) + 1) (matrix.(i).(j - 1) + 1))
                           (matrix.(i - 1).(j - 1) + cost)
    done
  done;
  matrix.(len1).(len2)

let find_similar_identifiers target candidates =
  let similarities = List.map (fun candidate ->
    let distance = levenshtein_distance target candidate in
    let max_len = max (String.length target) (String.length candidate) in
    let similarity = 1.0 -. (float_of_int distance /. float_of_int max_len) in
    (candidate, similarity)
  ) candidates in
  let sorted = List.sort (fun (_, s1) (_, s2) -> compare s2 s1) similarities in
  List.filter (fun (_, similarity) -> similarity > 0.6) sorted

(** 根据错误类型确定恢复策略 *)
let determine_recovery_strategy error_type config available_context =
  match error_type with
  | LexicalError _ -> NoRecovery
  | SyntaxError _ -> SkipAndContinue
  | SemanticError _ -> SkipAndContinue
  | TypeError _ when config.enable_type_coercion -> 
      TypeCoercion "尝试自动类型转换"
  | RuntimeError (msg, _) when config.enable_spell_correction && 
                               String.contains msg "未定义的变量" ->
      let var_name = extract_variable_name msg in
      let candidates = get_available_variables available_context in
      let similar = find_similar_identifiers var_name candidates in
      SpellCorrection (List.map fst similar)
  | CodegenError _ -> UseDefault "使用默认代码生成策略"
  | InternalError _ -> NoRecovery
  | PoetryParseError _ -> UserPrompt "诗词解析需要人工干预"
  | ConfigError _ -> UseDefault "使用默认配置值"
  | IOError _ -> Retry 3

(** 应用恢复策略 *)
let apply_recovery_strategy strategy error_type =
  match strategy with
  | NoRecovery -> None
  | SkipAndContinue -> 
      global_error_stats.recovered_errors <- global_error_stats.recovered_errors + 1;
      Some "跳过错误并继续处理"
  | UseDefault default_action -> 
      global_error_stats.recovered_errors <- global_error_stats.recovered_errors + 1;
      Some default_action
  | SpellCorrection suggestions ->
      if List.length suggestions > 0 then (
        global_error_stats.recovered_errors <- global_error_stats.recovered_errors + 1;
        Some ("拼写纠正建议: " ^ String.concat ", " suggestions)
      ) else None
  | TypeCoercion description ->
      global_error_stats.recovered_errors <- global_error_stats.recovered_errors + 1;
      Some description
  | UserPrompt prompt -> Some prompt
  | Retry attempts -> Some (Printf.sprintf "重试 %d 次" attempts)
  | Fallback fallback_fn -> Some (fallback_fn ())

(** 生成智能建议 *)
let generate_intelligent_suggestions error_type context =
  match error_type with
  | LexicalError (msg, _) when String.contains msg "无效字符" ->
      ["检查是否使用了非法字符"; "确保使用正确的字符编码"]
  | SyntaxError (msg, _) when String.contains msg "期望" ->
      ["检查语法是否正确"; "确保括号、引号等符号配对"; "参考语法文档"]
  | SemanticError (msg, _) when String.contains msg "未定义" ->
      ["检查变量是否已定义"; "确保变量在正确的作用域中"; "检查拼写是否正确"]
  | TypeError (msg, _) when String.contains msg "类型不匹配" ->
      ["检查表达式的类型"; "考虑添加类型转换"; "确保函数参数类型正确"]
  | RuntimeError (msg, _) when String.contains msg "除零" ->
      ["检查除数是否为零"; "添加条件检查"; "使用异常处理"]
  | CodegenError (msg, _) ->
      ["检查代码生成配置"; "确保目标平台支持"; "考虑降级语言特性"]
  | InternalError _ ->
      ["这是编译器内部错误"; "请报告此问题给开发者"; "包含完整的错误信息和重现步骤"]
  | PoetryParseError (msg, _) ->
      ["检查诗词格式"; "确保平仄规则正确"; "参考诗词语法规范"]
  | ConfigError (setting, _) ->
      ["检查配置文件格式"; "确保配置项名称正确"; "查看配置文档"]
  | IOError (operation, _) ->
      ["检查文件路径"; "确保文件权限"; "验证文件是否存在"]
  | _ -> ["查看文档获取更多信息"; "使用调试模式获取详细信息"]

(** 生成修复提示 *)
let generate_fix_hints error_type context =
  match error_type with
  | SyntaxError (msg, _) when String.contains msg "期望" ->
      ["添加缺失的符号"; "检查语法结构"]
  | SemanticError (msg, _) when String.contains msg "未定义" ->
      ["定义缺失的变量或函数"; "检查导入语句"]
  | TypeError (msg, _) when String.contains msg "类型不匹配" ->
      ["添加类型转换"; "修改表达式类型"]
  | RuntimeError (msg, _) when String.contains msg "参数数量" ->
      ["调整函数参数数量"; "检查函数签名"]
  | _ -> ["根据错误信息修复问题"]

(** 计算建议置信度 *)
let calculate_confidence error_type context =
  match error_type with
  | LexicalError _ -> 0.9
  | SyntaxError _ -> 0.8
  | SemanticError _ -> 0.7
  | TypeError _ -> 0.8
  | RuntimeError _ -> 0.6
  | CodegenError _ -> 0.5
  | InternalError _ -> 0.3
  | PoetryParseError _ -> 0.6
  | ConfigError _ -> 0.8
  | IOError _ -> 0.7

(** 创建增强错误信息 *)
let create_enhanced_error error_type context =
  let suggestions = generate_intelligent_suggestions error_type context in
  let fix_hints = generate_fix_hints error_type context in
  let confidence = calculate_confidence error_type context in
  let severity = determine_severity error_type in
  {
    error_type;
    severity;
    context;
    suggestions;
    fix_hints;
    confidence;
  }

(** 智能错误处理主函数 *)
let handle_unified_error error_type context =
  let enhanced_error = create_enhanced_error error_type context in
  update_global_stats enhanced_error;
  
  (* 格式化并输出错误 *)
  let formatted_msg = Unified_error_formatter.format_enhanced_error enhanced_error in
  let colored_msg = Unified_error_formatter.colorize_message enhanced_error.severity formatted_msg in
  Printf.eprintf "%s\n" colored_msg;
  flush stderr;
  
  (* 尝试错误恢复 *)
  let recovery_strategy = determine_recovery_strategy error_type !recovery_config context in
  let recovery_result = apply_recovery_strategy recovery_strategy error_type in
  
  match recovery_result with
  | Some recovery_msg ->
      Printf.eprintf "🔄 错误恢复: %s\n" recovery_msg;
      flush stderr;
      enhanced_error
  | None ->
      enhanced_error

(** 批量错误处理 *)
let handle_multiple_errors errors context =
  let enhanced_errors = List.map (fun error_type ->
    handle_unified_error error_type context
  ) errors in
  
  let should_continue = 
    !recovery_config.max_retry_attempts > 0 &&
    global_error_stats.fatal_errors = 0 &&
    global_error_stats.total_errors < 100 in
  
  (enhanced_errors, should_continue)
```

### 3.2 创建错误报告系统

```ocaml
(* src/unified_error_reporter.ml *)
open Unified_errors
open Unified_error_utils

(** 错误报告类型 *)
type error_report = {
  summary: string;
  total_errors: int;
  error_breakdown: (string * int) list;
  most_common_errors: (unified_error_type * int) list;
  suggestions_summary: string list;
  recovery_statistics: string;
  timestamp: float;
}

(** 生成错误摘要 *)
let generate_error_summary errors =
  let error_count = List.length errors in
  let warning_count = List.length (List.filter (fun e -> e.severity = Warning) errors) in
  let fatal_count = List.length (List.filter (fun e -> e.severity = Fatal) errors) in
  
  Printf.sprintf "总计 %d 个错误，其中 %d 个警告，%d 个严重错误" 
    error_count warning_count fatal_count

(** 分析错误类型分布 *)
let analyze_error_breakdown errors =
  let error_types = List.map (fun e -> Unified_error_formatter.format_error_type_name e.error_type) errors in
  let counts = List.fold_left (fun acc error_type ->
    let current_count = try List.assoc error_type acc with Not_found -> 0 in
    (error_type, current_count + 1) :: List.remove_assoc error_type acc
  ) [] error_types in
  List.sort (fun (_, c1) (_, c2) -> compare c2 c1) counts

(** 找出最常见的错误 *)
let find_most_common_errors errors =
  let error_counts = List.fold_left (fun acc error ->
    let current_count = try List.assoc error.error_type acc with Not_found -> 0 in
    (error.error_type, current_count + 1) :: List.remove_assoc error.error_type acc
  ) [] errors in
  let sorted = List.sort (fun (_, c1) (_, c2) -> compare c2 c1) error_counts in
  List.take 5 sorted

(** 生成建议摘要 *)
let generate_suggestions_summary errors =
  let all_suggestions = List.fold_left (fun acc error ->
    acc @ error.suggestions
  ) [] errors in
  let unique_suggestions = List.sort_uniq compare all_suggestions in
  List.take 10 unique_suggestions

(** 生成恢复统计 *)
let generate_recovery_statistics () =
  let total = global_error_stats.total_errors in
  let recovered = global_error_stats.recovered_errors in
  let recovery_rate = if total > 0 then 
    (float_of_int recovered /. float_of_int total) *. 100.0 
  else 0.0 in
  
  Printf.sprintf "错误恢复率: %.1f%% (%d/%d)" recovery_rate recovered total

(** 生成错误报告 *)
let generate_error_report errors =
  let summary = generate_error_summary errors in
  let total_errors = List.length errors in
  let error_breakdown = analyze_error_breakdown errors in
  let most_common_errors = find_most_common_errors errors in
  let suggestions_summary = generate_suggestions_summary errors in
  let recovery_statistics = generate_recovery_statistics () in
  let timestamp = Unix.time () in
  
  {
    summary;
    total_errors;
    error_breakdown;
    most_common_errors;
    suggestions_summary;
    recovery_statistics;
    timestamp;
  }

(** 打印错误报告 *)
let print_error_report report =
  Printf.printf "\n=== 错误报告 ===\n";
  Printf.printf "时间: %s\n" (Unix.ctime report.timestamp);
  Printf.printf "摘要: %s\n\n" report.summary;
  
  Printf.printf "错误类型分布:\n";
  List.iter (fun (error_type, count) ->
    Printf.printf "  %s: %d\n" error_type count
  ) report.error_breakdown;
  
  Printf.printf "\n最常见错误:\n";
  List.iter (fun (error_type, count) ->
    Printf.printf "  %s: %d 次\n" 
      (Unified_error_formatter.format_error_type_name error_type) count
  ) report.most_common_errors;
  
  Printf.printf "\n主要建议:\n";
  List.iteri (fun i suggestion ->
    Printf.printf "  %d. %s\n" (i + 1) suggestion
  ) report.suggestions_summary;
  
  Printf.printf "\n%s\n" report.recovery_statistics;
  Printf.printf "==================\n"

(** 导出错误报告到文件 *)
let export_error_report report filename =
  let oc = open_out filename in
  Printf.fprintf oc "骆言编译器错误报告\n";
  Printf.fprintf oc "生成时间: %s\n" (Unix.ctime report.timestamp);
  Printf.fprintf oc "摘要: %s\n\n" report.summary;
  
  Printf.fprintf oc "错误类型分布:\n";
  List.iter (fun (error_type, count) ->
    Printf.fprintf oc "  %s: %d\n" error_type count
  ) report.error_breakdown;
  
  Printf.fprintf oc "\n最常见错误:\n";
  List.iter (fun (error_type, count) ->
    Printf.fprintf oc "  %s: %d 次\n" 
      (Unified_error_formatter.format_error_type_name error_type) count
  ) report.most_common_errors;
  
  Printf.fprintf oc "\n主要建议:\n";
  List.iteri (fun i suggestion ->
    Printf.fprintf oc "  %d. %s\n" (i + 1) suggestion
  ) report.suggestions_summary;
  
  Printf.fprintf oc "\n%s\n" report.recovery_statistics;
  close_out oc

(** 生成JSON格式报告 *)
let export_json_report report filename =
  let json_content = Printf.sprintf {|{
  "timestamp": %.0f,
  "summary": "%s",
  "total_errors": %d,
  "error_breakdown": [%s],
  "most_common_errors": [%s],
  "suggestions_summary": [%s],
  "recovery_statistics": "%s"
}|} 
    report.timestamp
    report.summary
    report.total_errors
    (String.concat "," (List.map (fun (t, c) -> Printf.sprintf {|{"type":"%s","count":%d}|} t c) report.error_breakdown))
    (String.concat "," (List.map (fun (t, c) -> Printf.sprintf {|{"type":"%s","count":%d}|} (Unified_error_formatter.format_error_type_name t) c) report.most_common_errors))
    (String.concat "," (List.map (fun s -> Printf.sprintf {|"%s"|} s) report.suggestions_summary))
    report.recovery_statistics
  in
  
  let oc = open_out filename in
  Printf.fprintf oc "%s\n" json_content;
  close_out oc
```

## 阶段4：测试和优化

### 4.1 单元测试

```ocaml
(* test/test_unified_error_handling.ml *)
open Unified_errors
open Unified_error_utils
open Unified_error_formatter

(** 测试错误创建和格式化 *)
let test_error_creation_and_formatting () =
  let location = make_location "test.ly" 10 5 in
  let context = make_context "TestModule" "test_function" 
    ~related_variables:[("x", "42"); ("y", "hello")] in
  
  let error_type = TypeError ("类型不匹配", location) in
  let enhanced_error = Unified_error_recovery.create_enhanced_error error_type (Some context) in
  
  let formatted = format_enhanced_error enhanced_error in
  
  assert (String.contains formatted "类型错误");
  assert (String.contains formatted "test.ly:10:5");
  assert (String.contains formatted "TestModule");
  assert (String.contains formatted "test_function");
  Printf.printf "✓ 错误创建和格式化测试通过\n"

(** 测试错误恢复 *)
let test_error_recovery () =
  let location = make_location "test.ly" 5 10 in
  let context = make_context "TestModule" "test_recovery" in
  
  let error_type = RuntimeError ("未定义的变量: variabel", Some location) in
  let enhanced_error = Unified_error_recovery.handle_unified_error error_type (Some context) in
  
  assert (List.exists (fun s -> String.contains s "拼写") enhanced_error.suggestions);
  Printf.printf "✓ 错误恢复测试通过\n"

(** 测试错误收集 *)
let test_error_collection () =
  let collector = create_error_collector () in
  
  let error1 = Unified_error_recovery.create_enhanced_error 
    (TypeError ("类型错误1", make_location "test.ly" 1 1)) None in
  let error2 = Unified_error_recovery.create_enhanced_error 
    (RuntimeError ("运行时错误", None)) None in
  
  add_enhanced_error collector error1;
  add_enhanced_error collector error2;
  
  assert (error_count collector = 2);
  assert (warning_count collector = 0);
  Printf.printf "✓ 错误收集测试通过\n"

(** 测试错误报告 *)
let test_error_reporting () =
  let errors = [
    Unified_error_recovery.create_enhanced_error 
      (TypeError ("类型错误", make_location "test.ly" 1 1)) None;
    Unified_error_recovery.create_enhanced_error 
      (RuntimeError ("运行时错误", None)) None;
  ] in
  
  let report = Unified_error_reporter.generate_error_report errors in
  
  assert (report.total_errors = 2);
  assert (List.length report.error_breakdown >= 1);
  Printf.printf "✓ 错误报告测试通过\n"

(** 运行所有测试 *)
let run_all_tests () =
  Printf.printf "运行统一错误处理测试...\n";
  test_error_creation_and_formatting ();
  test_error_recovery ();
  test_error_collection ();
  test_error_reporting ();
  Printf.printf "所有测试通过！\n"

let () = run_all_tests ()
```

### 4.2 集成测试

```ocaml
(* test/test_unified_error_integration.ml *)
open Unified_errors
open Unified_error_utils

(** 测试lexer错误集成 *)
let test_lexer_integration () =
  let source = "让 x = 123$" in (* 包含无效字符 *)
  try
    let _ = Lexer.tokenize source in
    assert false (* 应该抛出异常 *)
  with UnifiedCompilerError (error_type, context) ->
    match error_type with
    | LexicalError (msg, location) -> 
        assert (String.contains msg "无效字符");
        assert (location.line = 1);
        assert (context <> None);
        Printf.printf "✓ Lexer错误集成测试通过\n"
    | _ -> assert false

(** 测试parser错误集成 *)
let test_parser_integration () =
  let source = "让 x =" in (* 缺少表达式 *)
  try
    let tokens = Lexer.tokenize source in
    let _ = Parser.parse tokens in
    assert false (* 应该抛出异常 *)
  with UnifiedCompilerError (error_type, context) ->
    match error_type with
    | SyntaxError (msg, location) -> 
        assert (String.contains msg "期望");
        assert (context <> None);
        Printf.printf "✓ Parser错误集成测试通过\n"
    | _ -> assert false

(** 测试类型错误集成 *)
let test_type_error_integration () =
  let source = "让 x = 42 + \"hello\"" in (* 类型不匹配 *)
  try
    let tokens = Lexer.tokenize source in
    let ast = Parser.parse tokens in
    let _ = Types.type_check ast in
    assert false (* 应该抛出异常 *)
  with UnifiedCompilerError (error_type, context) ->
    match error_type with
    | TypeError (msg, location) -> 
        assert (String.contains msg "类型");
        assert (context <> None);
        Printf.printf "✓ 类型错误集成测试通过\n"
    | _ -> assert false

(** 测试运行时错误集成 *)
let test_runtime_error_integration () =
  let source = "让 x = y" in (* 未定义变量 *)
  try
    let tokens = Lexer.tokenize source in
    let ast = Parser.parse tokens in
    let _ = Interpreter.eval ast [] in
    assert false (* 应该抛出异常 *)
  with UnifiedCompilerError (error_type, context) ->
    match error_type with
    | RuntimeError (msg, _) -> 
        assert (String.contains msg "未定义");
        assert (context <> None);
        Printf.printf "✓ 运行时错误集成测试通过\n"
    | _ -> assert false

(** 测试错误链传播 *)
let test_error_chain_propagation () =
  let source = "让 f = 函数 x → x + 1 在 f(\"hello\")" in (* 函数调用类型错误 *)
  try
    let tokens = Lexer.tokenize source in
    let ast = Parser.parse tokens in
    let _ = Interpreter.eval ast [] in
    assert false
  with UnifiedCompilerError (error_type, context) ->
    match context with
    | Some ctx ->
        assert (List.length ctx.call_stack > 0);
        Printf.printf "✓ 错误链传播测试通过\n"
    | None -> assert false

(** 运行所有集成测试 *)
let run_integration_tests () =
  Printf.printf "运行错误处理集成测试...\n";
  test_lexer_integration ();
  test_parser_integration ();
  test_type_error_integration ();
  test_runtime_error_integration ();
  test_error_chain_propagation ();
  Printf.printf "所有集成测试通过！\n"

let () = run_integration_tests ()
```

### 4.3 性能测试

```ocaml
(* test/test_unified_error_performance.ml *)
open Unified_errors
open Unified_error_utils

(** 性能测试：错误创建和格式化 *)
let benchmark_error_creation () =
  let iterations = 10000 in
  let location = make_location "test.ly" 10 5 in
  let context = make_context "PerfTest" "benchmark" in
  
  let start_time = Unix.time () in
  for i = 1 to iterations do
    let error_type = TypeError ("测试错误", location) in
    let enhanced_error = Unified_error_recovery.create_enhanced_error error_type (Some context) in
    let _ = Unified_error_formatter.format_enhanced_error enhanced_error in
    ()
  done;
  let end_time = Unix.time () in
  
  let elapsed = end_time -. start_time in
  Printf.printf "错误创建和格式化性能: %.6f秒 (%d次操作)\n" elapsed iterations;
  Printf.printf "平均每次操作: %.6f秒\n" (elapsed /. float_of_int iterations)

(** 性能测试：错误恢复 *)
let benchmark_error_recovery () =
  let iterations = 1000 in
  let location = make_location "test.ly" 10 5 in
  let context = make_context "PerfTest" "recovery_benchmark" in
  
  let start_time = Unix.time () in
  for i = 1 to iterations do
    let error_type = RuntimeError ("未定义的变量: test_var", Some location) in
    let _ = Unified_error_recovery.handle_unified_error error_type (Some context) in
    ()
  done;
  let end_time = Unix.time () in
  
  let elapsed = end_time -. start_time in
  Printf.printf "错误恢复性能: %.6f秒 (%d次操作)\n" elapsed iterations;
  Printf.printf "平均每次操作: %.6f秒\n" (elapsed /. float_of_int iterations)

(** 内存使用测试 *)
let test_memory_usage () =
  let gc_stat_before = Gc.stat () in
  
  let errors = ref [] in
  for i = 1 to 1000 do
    let location = make_location "test.ly" i 1 in
    let context = make_context "MemTest" "test_function" in
    let error_type = TypeError ("测试错误 " ^ string_of_int i, location) in
    let enhanced_error = Unified_error_recovery.create_enhanced_error error_type (Some context) in
    errors := enhanced_error :: !errors
  done;
  
  let gc_stat_after = Gc.stat () in
  let memory_used = gc_stat_after.Gc.heap_words - gc_stat_before.Gc.heap_words in
  
  Printf.printf "内存使用: %d words (约 %d bytes)\n" memory_used (memory_used * 8);
  Printf.printf "平均每个错误对象: %d words\n" (memory_used / 1000)

(** 运行性能测试 *)
let run_performance_tests () =
  Printf.printf "运行性能测试...\n";
  benchmark_error_creation ();
  benchmark_error_recovery ();
  test_memory_usage ();
  Printf.printf "性能测试完成！\n"

let () = run_performance_tests ()
```

## 总结

这个实施计划提供了统一错误处理系统的完整实现策略，包括：

1. **基础设施**：统一的错误类型定义、格式化器和工具库
2. **渐进式迁移**：逐步迁移现有模块到统一系统
3. **智能功能**：错误恢复、智能诊断和建议生成
4. **完整测试**：单元测试、集成测试和性能测试

通过这个实施计划，骆言编译器将获得：
- 一致的错误报告格式
- 丰富的错误上下文信息
- 智能的错误恢复机制
- 更好的开发者体验
- 可维护的错误处理代码

实施过程中需要注意向后兼容性，确保现有代码能够平滑迁移到新的统一错误处理系统。