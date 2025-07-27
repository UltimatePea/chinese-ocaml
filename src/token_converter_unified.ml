(** 统一Token转换器 - 技术债务清理 Issue #1375, 重构优化 Issue #1518

    整合所有Token转换逻辑到统一接口，消除重复实现。 替代模块：token_conversion_*.ml, lexer_token_converter.ml等
    
    重构优化：使用查找表替代深度嵌套模式匹配，提高性能和可维护性

    Author: Beta, 代码审查专员 Date: 2025-07-26
    Refactor: Alpha, 主要工作代理 Date: 2025-07-27 *)

open Token_unified

type converter_strategy =
  [ `Direct  (** 直接转换策略 *) | `Classical  (** 古典语言转换策略 *) | `Natural  (** 自然语言转换策略 *) ]
(** 转换策略类型 *)

type conversion_context = {
  strategy : converter_strategy;
  allow_deprecated : bool;
  fallback_enabled : bool;
  strict_mode : bool;
}
(** 转换上下文 *)

exception Unknown_token of string
(** 转换异常 *)

exception Conversion_failed of string * string (* token, reason *)

(** 默认转换上下文 *)
let default_context =
  { strategy = `Direct; allow_deprecated = false; fallback_enabled = true; strict_mode = false }

(** 字面量转换模块 *)
module Literal = struct
  (** 转换中文数字到Token *)
  let convert_chinese_number str =
    match str with
    | "零" -> Some (IntToken 0)
    | "一" -> Some (IntToken 1)
    | "二" -> Some (IntToken 2)
    | "三" -> Some (IntToken 3)
    | "四" -> Some (IntToken 4)
    | "五" -> Some (IntToken 5)
    | "六" -> Some (IntToken 6)
    | "七" -> Some (IntToken 7)
    | "八" -> Some (IntToken 8)
    | "九" -> Some (IntToken 9)
    | "十" -> Some (IntToken 10)
    | _ when String.contains str '.' -> (
        (* 处理浮点数 - 点字符 *)
        try Some (ChineseNumberToken str) with _ -> None)
    | _ -> Some (ChineseNumberToken str)

  (** 转换字面量 *)
  let convert str =
    (* 尝试转换为整数 *)
    try Some (IntToken (int_of_string str))
    with Failure _ -> (
      (* 尝试转换为浮点数 *)
      try Some (FloatToken (float_of_string str))
      with Failure _ -> (
        (* 尝试转换为布尔值 *)
        match str with
        | "真" | "true" -> Some (BoolToken true)
        | "假" | "false" -> Some (BoolToken false)
        | "()" -> Some UnitToken
        | _ when String.length str >= 2 && str.[0] = '"' && str.[String.length str - 1] = '"' ->
            Some (StringToken (String.sub str 1 (String.length str - 2)))
        | _ -> convert_chinese_number str))
end

(** 标识符转换模块 *)
module Identifier = struct
  (** 检查是否为引用标识符 *)
  let is_quoted_identifier str =
    String.length str >= 4
    && String.sub str 0 3 = "「"
    && String.sub str (String.length str - 3) 3 = "」"

  (** 检查是否为构造器 *)
  let is_constructor str =
    String.length str > 0
    &&
    let first_char = str.[0] in
    (first_char >= 'A' && first_char <= 'Z') || first_char > '\127'

  (** 转换标识符 *)
  let convert str =
    if is_quoted_identifier str then
      let content = String.sub str 1 (String.length str - 2) in
      Some (QuotedIdentifierToken content)
    else if is_constructor str then Some (ConstructorToken str)
    else if String.contains str '.' then Some (ModuleNameToken str)
    else Some (IdentifierToken str)
end

(** 关键字转换模块 - 优化版本使用查找表 *)
module Keyword = struct
  (** 查找表定义 *)
  let basic_keywords = Hashtbl.create 16
  let type_keywords = Hashtbl.create 16  
  let control_keywords = Hashtbl.create 20
  let classical_keywords = Hashtbl.create 16

  (** 初始化查找表 *)
  let init_tables () =
    (* 基础关键字 *)
    List.iter (fun (k, v) -> Hashtbl.add basic_keywords k v) [
      ("让", `Let); ("let", `Let);
      ("函数", `Fun); ("fun", `Fun);
      ("在", `In); ("in", `In);
      ("递归", `Rec); ("rec", `Rec);
      ("类型", `Type); ("type", `Type);
      ("私有", `Private); ("private", `Private);
      ("并且", `And); ("and", `And);
      ("作为", `As); ("as", `As);
    ];
    
    (* 类型关键字 *)
    List.iter (fun (k, v) -> Hashtbl.add type_keywords k v) [
      ("整数", `Int); ("int", `Int);
      ("浮点数", `Float); ("float", `Float);
      ("字符串", `String); ("string", `String);
      ("布尔", `Bool); ("bool", `Bool);
      ("单元", `Unit); ("unit", `Unit);
      ("列表", `List); ("list", `List);
      ("数组", `Array); ("array", `Array);
      ("选项", `Option); ("option", `Option);
      ("引用", `Ref); ("ref", `Ref);
    ];
    
    (* 控制流关键字 *)
    List.iter (fun (k, v) -> Hashtbl.add control_keywords k v) [
      ("如果", `If); ("if", `If);
      ("那么", `Then); ("then", `Then);
      ("否则", `Else); ("else", `Else);
      ("匹配", `Match); ("match", `Match);
      ("与", `With); ("with", `With);
      ("当", `When); ("when", `When);
      ("尝试", `Try); ("try", `Try);
      ("捕获", `Catch); ("catch", `Catch);
      ("最终", `Finally); ("finally", `Finally);
      ("抛出", `Raise); ("raise", `Raise);
    ];
    
    (* 古典语言关键字 *)
    List.iter (fun (k, v) -> Hashtbl.add classical_keywords k v) [
      ("有", `Have); ("have", `Have);
      ("一", `One); ("one", `One);
      ("名", `Name); ("name", `Name);
      ("设", `Set); ("set", `Set);
      ("亦", `Also); ("also", `Also);
      ("调", `Call); ("call", `Call);
      ("则得", `ThenGet); ("then_get", `ThenGet);
      ("亦有", `AlsoHave); ("also_have", `AlsoHave);
    ]

  (** 确保表已初始化 *)
  let ensure_initialized =
    let initialized = ref false in
    fun () ->
      if not !initialized then (
        init_tables ();
        initialized := true)

  (** 基础关键字转换 - O(1)查找 *)
  let convert_basic str =
    ensure_initialized ();
    Hashtbl.find_opt basic_keywords str

  (** 类型关键字转换 - O(1)查找 *)
  let convert_type str =
    ensure_initialized ();
    Hashtbl.find_opt type_keywords str

  (** 控制流关键字转换 - O(1)查找 *)
  let convert_control str =
    ensure_initialized ();
    Hashtbl.find_opt control_keywords str

  (** 古典语言关键字转换 - O(1)查找 *)
  let convert_classical str =
    ensure_initialized ();
    Hashtbl.find_opt classical_keywords str

  (** 统一关键字转换 - 优化版本 *)
  let convert str =
    ensure_initialized ();
    (* 使用短路求值，避免不必要的查找 *)
    match Hashtbl.find_opt basic_keywords str with
    | Some kw -> Some (BasicKeyword kw)
    | None -> (
        match Hashtbl.find_opt type_keywords str with
        | Some kw -> Some (TypeKeyword kw)
        | None -> (
            match Hashtbl.find_opt control_keywords str with
            | Some kw -> Some (ControlKeyword kw)
            | None -> (
                match Hashtbl.find_opt classical_keywords str with
                | Some kw -> Some (ClassicalKeyword kw)
                | None -> None)))
end

(** 操作符转换模块 - 优化版本使用查找表 *)
module Operator = struct
  (** 操作符查找表 *)
  let operator_table = Hashtbl.create 32
  
  (** 初始化操作符表 *)
  let init_table () =
    List.iter (fun (k, v) -> Hashtbl.add operator_table k v) [
      (* 算术操作符 *)
      ("+", `Plus); ("-", `Minus); ("*", `Multiply); ("/", `Divide);
      ("%", `Modulo); ("**", `Power);
      (* 比较操作符 *)
      ("=", `Equal); ("<>", `NotEqual); ("!=", `NotEqual);
      ("<", `LessThan); ("<=", `LessEqual);
      (">", `GreaterThan); (">=", `GreaterEqual);
      (* 逻辑操作符 *)
      ("&&", `LogicalAnd); ("||", `LogicalOr);
      ("not", `LogicalNot); ("非", `LogicalNot);
      (* 赋值和引用 *)
      (":=", `Assign); ("!", `Dereference);
      ("ref", `Reference); ("引用", `Reference);
      (* 函数组合 *)
      ("->", `Arrow); ("=>", `DoubleArrow);
      ("|>", `PipeForward); ("<|", `PipeBackward);
    ]
  
  (** 确保表已初始化 *)
  let ensure_initialized =
    let initialized = ref false in
    fun () ->
      if not !initialized then (
        init_table ();
        initialized := true)
  
  (** 转换操作符 - O(1)查找 *)
  let convert str =
    ensure_initialized ();
    Hashtbl.find_opt operator_table str
end

(** 分隔符转换模块 - 优化版本使用查找表 *)
module Delimiter = struct
  (** 分隔符查找表 *)
  let delimiter_table = Hashtbl.create 16
  
  (** 初始化分隔符表 *)
  let init_table () =
    List.iter (fun (k, v) -> Hashtbl.add delimiter_table k v) [
      ("(", `LeftParen); (")", `RightParen);
      ("{", `LeftBrace); ("}", `RightBrace);
      ("[", `LeftBracket); ("]", `RightBracket);
      (";", `Semicolon); (",", `Comma);
      (".", `Dot); (":", `Colon); ("::", `DoubleColon);
    ]
  
  (** 确保表已初始化 *)
  let ensure_initialized =
    let initialized = ref false in
    fun () ->
      if not !initialized then (
        init_table ();
        initialized := true)
  
  (** 转换分隔符 - O(1)查找 *)
  let convert str =
    ensure_initialized ();
    Hashtbl.find_opt delimiter_table str
end

(** 主转换函数 *)
let rec convert_token str context =
  (* 按优先级尝试转换 *)
  match context.strategy with
  | `Classical -> (
      (* 古典语言优先 *)
      match Keyword.convert_classical str with
      | Some kw -> Some (ClassicalKeyword kw)
      | None -> convert_token str { context with strategy = `Direct })
  | `Natural ->
      (* 自然语言优先，暂时等同于直接转换 *)
      convert_token str { context with strategy = `Direct }
  | `Direct -> (
      (* 直接转换策略 *)
      match Keyword.convert str with
      | Some token -> Some token
      | None -> (
          match Operator.convert str with
          | Some op -> Some (OperatorToken op)
          | None -> (
              match Delimiter.convert str with
              | Some delim -> Some (DelimiterToken delim)
              | None -> (
                  match Literal.convert str with
                  | Some token -> Some token
                  | None -> (
                      match Identifier.convert str with
                      | Some token -> Some token
                      | None ->
                          if context.fallback_enabled then Some (Error ("Unknown token: " ^ str))
                          else None)))))

(** 便利函数：使用默认上下文转换 *)
let convert str = convert_token str default_context

(** 严格模式转换：失败时抛出异常 *)
let convert_strict str =
  let context = { default_context with strict_mode = true; fallback_enabled = false } in
  match convert_token str context with Some token -> token | None -> raise (Unknown_token str)

(** 批量转换函数 *)
let convert_tokens str_list context =
  List.map
    (fun str ->
      match convert_token str context with
      | Some token -> token
      | None -> Error ("Failed to convert: " ^ str))
    str_list
