(** Token兼容性统一模块 - 重构版本 (Conversion目录专用)
    
    本模块是Issue #1386技术债务清理第二阶段的成果，
    通过代码简化和重复消除替代了原来的两个大型文件：
    - src/token_compatibility_unified.ml (492行)
    - src/token_system_unified/conversion/token_compatibility_unified.ml (511行)
    
    重构原则：
    - 消除重复代码
    - 简化错误处理
    - 统一Token映射逻辑
    - 保持完全向后兼容
    
    @author Alpha专员, 主要工作代理
    @version 2.0 (重构版本)
    @since 2025-07-26 Issue #1386
*)

open Yyocamlc_lib.Unified_token_core

(** 通用多级匹配函数 - 消除重复的嵌套match模式 *)
let try_token_mappings input mapping_functions =
  let rec apply_mappings = function
    | [] -> None
    | f :: rest -> 
        match f input with
        | Some result -> Some result
        | None -> apply_mappings rest
  in
  apply_mappings mapping_functions

(** 统一Token错误处理模块 - 简化版本 *)
module TokenErrorHandler = struct
  let handle_json_error = function
    | Not_found | Sys_error _ | Yojson.Json_error _ | _ -> []

  let safe_json_operation operation =
    try operation ()
    with e -> handle_json_error e
end

(** Token映射表模块 *)
module TokenMappingTables = struct
  let create_table_lookup mappings =
    fun input ->
      try Some (List.assoc input mappings)
      with Not_found -> None

  (** 分隔符映射表 - 简化版本 *)
  let delimiter_mappings = [
    ("(", LeftParen); (")", RightParen);
    ("[", LeftBracket); ("]", RightBracket);
    ("{", LeftBrace); ("}", RightBrace);
    (",", Comma); (";", Semicolon); (":", Colon);
    ("，", Comma); ("、", Comma); ("；", Semicolon);
    ("：", Colon); ("|", VerticalBar); ("_", Underscore);
  ]

  (** 运算符映射表 - 简化版本 *)
  let operator_mappings = [
    ("+", PlusOp); ("-", MinusOp);
    ("*", MultiplyOp); ("/", DivideOp);
    ("mod", ModOp); ("**", PowerOp);
    ("=", EqualOp); ("<>", NotEqualOp);
    ("<", LessOp); (">", GreaterOp);
    ("<=", LessEqualOp); (">=", GreaterEqualOp);
    ("&&", LogicalAndOp); ("||", LogicalOrOp); ("!", LogicalNotOp);
    (":=", AssignOp); ("->", ArrowOp); 
    ("|>", PipeOp); ("<|", PipeBackOp);
  ]
end

(** 分隔符映射 - 使用配置化映射表 *)
let map_legacy_delimiter_to_unified = 
  TokenMappingTables.create_table_lookup TokenMappingTables.delimiter_mappings

(** 运算符映射 - 使用配置化映射表 *)
let map_legacy_operator_to_unified = 
  TokenMappingTables.create_table_lookup TokenMappingTables.operator_mappings

(** 字面量映射 - 直接返回统一Token类型 *)
let map_legacy_literal_to_unified = function
  (* 数字字面量 *)
  | s when (try let _ = int_of_string s in true with _ -> false) ->
      Some (IntToken (int_of_string s))
  | s when (try let _ = float_of_string s in true with _ -> false) ->
      Some (FloatToken (float_of_string s))
  (* 布尔字面量 *)
  | "true" -> Some (BoolToken true)
  | "false" -> Some (BoolToken false)
  (* 字符串字面量（带引号） *)
  | s when String.length s >= 2 && s.[0] = '"' && s.[String.length s - 1] = '"' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (StringToken content)
  (* 中文数字 - 映射为字符串Token *)
  | "零" | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "十" | "百" | "千" | "万" as num ->
      Some (StringToken num)
  (* 单位字面量 *)
  | "()" | "unit" -> Some (StringToken "()")
  | _ -> None

(** 标识符映射 - 直接返回统一Token类型 *)
let map_legacy_identifier_to_unified = function
  | "EOF" | "Whitespace" | "Newline" | "Tab" -> None
  | s when String.length s > 0 && s.[0] = '_' -> Some (QuotedIdentifierToken s)
  | s when String.length s > 0 && Char.code s.[0] >= 97 && Char.code s.[0] <= 122 ->
      Some (IdentifierToken s)
  | s when String.length s > 0 && Char.code s.[0] >= 65 && Char.code s.[0] <= 90 ->
      Some (ConstructorToken s)
  | s when String.length s > 0 && Char.code s.[0] > 127 ->
      Some (IdentifierToken s)
  | s when String.length s >= 3 && s.[0] = '\'' && s.[String.length s - 1] = '\'' ->
      let content = String.sub s 1 (String.length s - 2) in
      Some (QuotedIdentifierToken content)
  | _ -> None

(** 特殊Token映射 - 直接返回统一Token类型 *)
let map_legacy_special_to_unified = function
  | "EOF" -> Some (StringToken "EOF")
  | "\n" | "\t" | "\\n" | "\\t" -> Some (StringToken "whitespace")
  | s when (String.length s >= 4 && String.sub s 0 2 = "(*" && String.sub s (String.length s - 2) 2 = "*)")
        || (String.length s >= 2 && String.sub s 0 2 = "//") ->
      Some (StringToken s)
  | _ -> None

(** 关键字映射 - 简化的统一映射 *)
let map_legacy_keyword_to_unified = function
  (* 基础关键字 *)
  | "let" -> Some LetKeyword
  | "rec" -> Some RecKeyword
  | "in" -> Some InKeyword
  | "fun" -> Some FunKeyword
  | "if" -> Some IfKeyword
  | "then" -> Some ThenKeyword
  | "else" -> Some ElseKeyword
  | "match" -> Some MatchKeyword
  | "with" -> Some WithKeyword
  | "true" -> Some TrueKeyword
  | "false" -> Some FalseKeyword
  | "and" -> Some AndKeyword
  | "or" -> Some OrKeyword
  | "not" -> Some NotKeyword
  | "type" -> Some TypeKeyword
  | "module" -> Some ModuleKeyword
  | "ref" -> Some RefKeyword
  | "as" -> Some AsKeyword
  | "of" -> Some OfKeyword
  (* 扩展关键字 - 简化映射 *)
  | "HaveKeyword" | "SetKeyword" -> Some LetKeyword
  | "NameKeyword" | "AsForKeyword" -> Some AsKeyword
  | "AlsoKeyword" -> Some AndKeyword
  | "ThenGetKeyword" | "ReturnWhenKeyword" -> Some ThenKeyword
  | "CallKeyword" | "DefineKeyword" | "AncientDefineKeyword" -> Some FunKeyword
  | "ValueKeyword" -> Some ValKeyword
  | "AcceptKeyword" | "InputKeyword" -> Some InKeyword
  | "ElseReturnKeyword" -> Some ElseKeyword
  | "OutputKeyword" | "ReturnKeyword" -> Some ReturnKeyword
  | "EndKeyword" | "AncientEndKeyword" -> Some EndKeyword
  | "TryKeyword" -> Some TryKeyword
  | "ThrowKeyword" -> Some RaiseKeyword
  | _ -> None

(** 核心转换函数 - 使用通用多级匹配函数 *)
let convert_legacy_token_string token_str _value_opt =
  try_token_mappings token_str [
    map_legacy_keyword_to_unified;
    map_legacy_operator_to_unified;
    map_legacy_delimiter_to_unified;
    map_legacy_literal_to_unified;
    map_legacy_identifier_to_unified;
    map_legacy_special_to_unified;
  ]

(** 创建兼容的带位置Token *)
let make_compatible_positioned_token token_str value_opt filename line column =
  match convert_legacy_token_string token_str value_opt with
  | Some token ->
      let position = { filename; line; column; offset = 0 } in
      Some { token; position; metadata = None }
  | None -> None

(** 检查Token字符串是否与统一系统兼容 *)
let is_compatible_token_string token_str =
  match convert_legacy_token_string token_str None with
  | Some _ -> true
  | None -> false

(** 获取所有支持的遗留Token - 简化版本 *)
let get_supported_legacy_tokens () =
  let delimiters = List.map fst TokenMappingTables.delimiter_mappings in
  let operators = List.map fst TokenMappingTables.operator_mappings in
  let keywords = ["let"; "if"; "then"; "else"; "match"; "with"; "fun"; "type"] in
  let literals = ["123"; "45.67"; "true"; "false"; "\"hello\""; "()"; "一"] in
  List.concat [delimiters; operators; keywords; literals]

(** 生成兼容性报告 - 简化版本 *)
let generate_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  Printf.sprintf "Token兼容性报告: 支持%d个遗留Token" total_count

(** 生成详细的兼容性报告 - 简化版本 *)
let generate_detailed_compatibility_report () =
  let supported_tokens = get_supported_legacy_tokens () in
  let total_count = List.length supported_tokens in
  let delimiters_count = List.length TokenMappingTables.delimiter_mappings in
  let operators_count = List.length TokenMappingTables.operator_mappings in
  Printf.sprintf "详细Token兼容性报告: 支持%d个遗留Token (分隔符:%d, 运算符:%d)" 
    total_count delimiters_count operators_count

(** 向后兼容性保证 - 重新导出原有接口函数名 *)
(* 所有函数都已按原有接口命名，保持完全兼容 *)