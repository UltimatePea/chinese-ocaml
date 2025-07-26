(** 统一Token转换器 - Issue #1410核心模块
 *
 * 这个模块提供统一的Token转换接口，替代分散在15个模块中的转换逻辑。
 * 设计目标：
 * - 统一转换接口和错误处理
 * - 支持批量转换和性能优化
 * - 提供完整的向后兼容性
 * - 可扩展的转换器注册机制
 *
 * @author Charlie, 规划Agent - Issue #1410
 * @version 1.0 - 初始统一转换系统
 * @since 2025-07-26 *)

(* 重新导出核心类型 *)
include Token_types

(** 转换错误类型 *)
type conversion_error = {
  source_text : string;
  error_message : string;
  position : position option;
  conversion_type : string;
  timestamp : float;
}

(** 转换结果类型 *)
type conversion_result = 
  | Success of positioned_token
  | Failure of conversion_error

(** 转换器函数类型 *)
type converter_function = string -> position -> conversion_result

(** 转换器类型标识 *)
type converter_type = 
  | LiteralConverter
  | IdentifierConverter  
  | KeywordConverter
  | OperatorConverter
  | DelimiterConverter
  | SpecialConverter
  | CompositeConverter

(** 转换器注册条目 *)
type converter_entry = {
  converter_type : converter_type;
  name : string;
  priority : int;
  converter_func : converter_function;
  enabled : bool;
}

(** 转换器注册表 *)
module ConverterRegistry = struct
  (** 注册表存储 *)
  let registry : (converter_type, converter_entry list) Hashtbl.t = Hashtbl.create 16

  (** 注册转换器 *)
  let register_converter entry =
    let existing_converters = 
      try Hashtbl.find registry entry.converter_type 
      with Not_found -> [] in
    let updated_converters = entry :: existing_converters in
    Hashtbl.replace registry entry.converter_type updated_converters

  (** 获取转换器列表 *)
  let get_converters conv_type =
    try 
      let entries = Hashtbl.find registry conv_type in
      let enabled_entries = List.filter (fun e -> e.enabled) entries in
      List.sort (fun e1 e2 -> compare e1.priority e2.priority) enabled_entries
    with Not_found -> []

  (** 获取所有转换器 *)
  let get_all_converters () =
    Hashtbl.fold (fun conv_type entries acc ->
      (conv_type, List.filter (fun e -> e.enabled) entries) :: acc) registry []

  (** 清空注册表 *)
  let clear () = Hashtbl.clear registry

  (** 获取统计信息 *)
  let get_stats () =
    let total_converters = Hashtbl.length registry in
    let enabled_count = Hashtbl.fold (fun _ entries acc ->
      acc + List.length (List.filter (fun e -> e.enabled) entries)) registry 0 in
    (total_converters, enabled_count)
end

(** 内置字面量转换器 *)
module LiteralConverters = struct
  let convert_int_literal text pos =
    try
      let value = int_of_string text in
      Success ((LiteralToken (Literals.IntToken value)), pos)
    with _ -> 
      Failure { source_text = text; error_message = "Invalid integer literal"; 
                position = Some pos; conversion_type = "IntLiteral"; 
                timestamp = Unix.time () }

  let convert_float_literal text pos =
    try
      let value = float_of_string text in
      Success ((LiteralToken (Literals.FloatToken value)), pos)
    with _ ->
      Failure { source_text = text; error_message = "Invalid float literal";
                position = Some pos; conversion_type = "FloatLiteral";
                timestamp = Unix.time () }

  let convert_string_literal text pos =
    (* 移除引号 *)
    let cleaned_text = 
      if String.length text >= 2 && text.[0] = '"' && text.[String.length text - 1] = '"'
      then String.sub text 1 (String.length text - 2)
      else text in
    Success ((LiteralToken (Literals.StringToken cleaned_text)), pos)

  let convert_bool_literal text pos =
    match text with
    | "true" | "真" -> Success ((LiteralToken (Literals.BoolToken true)), pos)
    | "false" | "假" -> Success ((LiteralToken (Literals.BoolToken false)), pos)
    | _ -> Failure { source_text = text; error_message = "Invalid boolean literal";
                     position = Some pos; conversion_type = "BoolLiteral";
                     timestamp = Unix.time () }

  let convert_chinese_number text pos =
    (* 简化的中文数字转换 *)
    Success ((LiteralToken (Literals.ChineseNumberToken text)), pos)
end

(** 内置关键字转换器 *)
module KeywordConverters = struct
  (** 关键字映射表 *)
  let keyword_mappings = [
    (* 基础关键字 - 中文 *)
    ("让", Keywords.LetKeyword); ("设", Keywords.LetKeyword);
    ("函数", Keywords.FunKeyword); ("如果", Keywords.IfKeyword);
    ("那么", Keywords.ThenKeyword); ("否则", Keywords.ElseKeyword);
    ("匹配", Keywords.MatchKeyword); ("与", Keywords.WithKeyword);
    ("且", Keywords.AndKeyword); ("或", Keywords.OrKeyword);
    ("非", Keywords.NotKeyword); ("真", Keywords.TrueKeyword);
    ("假", Keywords.FalseKeyword); ("在", Keywords.InKeyword);
    ("递归", Keywords.RecKeyword);
    
    (* 基础关键字 - 英文 *)
    ("let", Keywords.LetKeyword); ("fun", Keywords.FunKeyword);
    ("function", Keywords.FunKeyword); ("if", Keywords.IfKeyword);
    ("then", Keywords.ThenKeyword); ("else", Keywords.ElseKeyword);
    ("match", Keywords.MatchKeyword); ("with", Keywords.WithKeyword);
    ("and", Keywords.AndKeyword); ("or", Keywords.OrKeyword);
    ("not", Keywords.NotKeyword); ("true", Keywords.TrueKeyword);
    ("false", Keywords.FalseKeyword); ("in", Keywords.InKeyword);
    ("rec", Keywords.RecKeyword);
    
    (* 类型关键字 *)
    ("type", Keywords.TypeKeyword); ("类型", Keywords.TypeKeyword);
    ("int", Keywords.IntTypeKeyword); ("整数", Keywords.IntTypeKeyword);
    ("float", Keywords.FloatTypeKeyword); ("浮点", Keywords.FloatTypeKeyword);
    ("string", Keywords.StringTypeKeyword); ("字符串", Keywords.StringTypeKeyword);
    ("bool", Keywords.BoolTypeKeyword); ("布尔", Keywords.BoolTypeKeyword);
    
    (* 文言文关键字 *)
    ("若", Keywords.WenyanIf); ("则", Keywords.WenyanThen);
    ("不然", Keywords.WenyanElse); ("有", Keywords.WenyanHave);
    ("是", Keywords.WenyanIs); ("凡", Keywords.WenyanAll);
    
    (* 古雅体关键字 *)
    ("起", Keywords.BeginKeyword); ("终", Keywords.FinishKeyword);
    ("曰", Keywords.ClassicalBe); ("行", Keywords.ClassicalDo);
    ("毕", Keywords.ClassicalEnd); ("得", Keywords.ClassicalReturn);
  ]

  let convert_keyword text pos =
    try
      let keyword_token = List.assoc text keyword_mappings in
      Success ((KeywordToken keyword_token), pos)
    with Not_found ->
      Failure { source_text = text; error_message = "Unknown keyword";
                position = Some pos; conversion_type = "Keyword";
                timestamp = Unix.time () }
end

(** 内置运算符转换器 *)
module OperatorConverters = struct
  let operator_mappings = [
    ("+", Operators.Plus); ("-", Operators.Minus);
    ("*", Operators.Multiply); ("/", Operators.Divide);
    ("=", Operators.Equal); ("<>", Operators.NotEqual);
    ("<", Operators.LessThan); (">", Operators.GreaterThan);
    ("<=", Operators.LessEqual); (">=", Operators.GreaterEqual);
    ("&&", Operators.LogicalAnd); ("||", Operators.LogicalOr);
    ("->", Operators.Arrow); ("=>", Operators.DoubleArrow);
    ("|>", Operators.PipeForward); ("<|", Operators.PipeBackward);
  ]

  let convert_operator text pos =
    try
      let operator_token = List.assoc text operator_mappings in
      Success ((OperatorToken operator_token), pos)
    with Not_found ->
      Failure { source_text = text; error_message = "Unknown operator";
                position = Some pos; conversion_type = "Operator";
                timestamp = Unix.time () }
end

(** 内置标识符转换器 *)
module IdentifierConverters = struct
  let convert_identifier text pos =
    if String.length text >= 2 && text.[0] = '「' && text.[String.length text - 1] = '」'
    then
      (* 带引号的标识符 *)
      let id_text = String.sub text 1 (String.length text - 2) in
      Success ((IdentifierToken (Identifiers.QuotedIdentifierToken id_text)), pos)
    else
      (* 普通标识符 *)
      Success ((IdentifierToken (Identifiers.QuotedIdentifierToken text)), pos)
end

(** 内置分隔符转换器 *)
module DelimiterConverters = struct
  let delimiter_mappings = [
    ("(", Delimiters.LeftParen); (")", Delimiters.RightParen);
    ("[", Delimiters.LeftBracket); ("]", Delimiters.RightBracket);
    ("{", Delimiters.LeftBrace); ("}", Delimiters.RightBrace);
    (",", Delimiters.Comma); (";", Delimiters.Semicolon);
    (":", Delimiters.Colon); ("|", Delimiters.Pipe);
    ("_", Delimiters.Underscore);
    (* 中文分隔符 *)
    ("（", Delimiters.ChineseLeftParen); ("）", Delimiters.ChineseRightParen);
    ("「", Delimiters.ChineseLeftBracket); ("」", Delimiters.ChineseRightBracket);
    ("，", Delimiters.ChineseComma); ("；", Delimiters.ChineseSemicolon);
    ("：", Delimiters.ChineseColon); ("｜", Delimiters.ChinesePipe);
  ]

  let convert_delimiter text pos =
    try
      let delimiter_token = List.assoc text delimiter_mappings in
      Success ((DelimiterToken delimiter_token), pos)
    with Not_found ->
      Failure { source_text = text; error_message = "Unknown delimiter";
                position = Some pos; conversion_type = "Delimiter";
                timestamp = Unix.time () }
end

(** 智能转换器 - 自动检测token类型 *)
module SmartConverter = struct
  let is_numeric text =
    try ignore (int_of_string text); true
    with _ -> try ignore (float_of_string text); true
    with _ -> false

  let is_string_literal text =
    String.length text >= 2 && text.[0] = '"' && text.[String.length text - 1] = '"'

  let is_quoted_identifier text =
    String.length text >= 2 && text.[0] = '「' && text.[String.length text - 1] = '」'

  let has_chinese_chars text =
    let rec check i =
      if i >= String.length text then false
      else
        let c = Char.code text.[i] in
        if c > 127 then true  (* 简化的中文字符检测 *)
        else check (i + 1)
    in
    check 0

  let convert_smart text pos =
    (* 按优先级尝试不同的转换器 *)
    if is_string_literal text then
      LiteralConverters.convert_string_literal text pos
    else if is_quoted_identifier text then
      IdentifierConverters.convert_identifier text pos
    else if is_numeric text then
      if String.contains text '.' then
        LiteralConverters.convert_float_literal text pos
      else
        LiteralConverters.convert_int_literal text pos
    else
      (* 尝试关键字转换 *)
      match KeywordConverters.convert_keyword text pos with
      | Success _ as result -> result
      | Failure _ ->
          (* 尝试运算符转换 *)
          match OperatorConverters.convert_operator text pos with
          | Success _ as result -> result
          | Failure _ ->
              (* 尝试分隔符转换 *)
              match DelimiterConverters.convert_delimiter text pos with
              | Success _ as result -> result
              | Failure _ ->
                  (* 默认作为标识符 *)
                  IdentifierConverters.convert_identifier text pos
end

(** 注册默认转换器 *)
let register_default_converters () =
  let converters = [
    { converter_type = LiteralConverter; name = "IntLiteral"; priority = 1;
      converter_func = LiteralConverters.convert_int_literal; enabled = true };
    { converter_type = LiteralConverter; name = "FloatLiteral"; priority = 2;
      converter_func = LiteralConverters.convert_float_literal; enabled = true };
    { converter_type = LiteralConverter; name = "StringLiteral"; priority = 3;
      converter_func = LiteralConverters.convert_string_literal; enabled = true };
    { converter_type = LiteralConverter; name = "BoolLiteral"; priority = 4;
      converter_func = LiteralConverters.convert_bool_literal; enabled = true };
    { converter_type = KeywordConverter; name = "BasicKeyword"; priority = 1;
      converter_func = KeywordConverters.convert_keyword; enabled = true };
    { converter_type = OperatorConverter; name = "BasicOperator"; priority = 1;
      converter_func = OperatorConverters.convert_operator; enabled = true };
    { converter_type = IdentifierConverter; name = "BasicIdentifier"; priority = 1;
      converter_func = IdentifierConverters.convert_identifier; enabled = true };
    { converter_type = DelimiterConverter; name = "BasicDelimiter"; priority = 1;
      converter_func = DelimiterConverters.convert_delimiter; enabled = true };
  ] in
  List.iter ConverterRegistry.register_converter converters

(** 主要转换接口 *)
let convert text pos =
  SmartConverter.convert_smart text pos

(** 批量转换接口 *)
let batch_convert token_texts =
  List.map (fun (text, pos) -> (text, convert text pos)) token_texts

(** 类型特定转换接口 *)
let convert_with_type conv_type text pos =
  let converters = ConverterRegistry.get_converters conv_type in
  let rec try_converters = function
    | [] -> Failure { source_text = text; error_message = "No suitable converter found";
                      position = Some pos; conversion_type = "TypeSpecific";
                      timestamp = Unix.time () }
    | entry :: rest ->
        match entry.converter_func text pos with
        | Success _ as result -> result
        | Failure _ -> try_converters rest
  in
  try_converters converters

(** 获取转换统计信息 *)
let get_conversion_stats () =
  let (total_types, enabled_converters) = ConverterRegistry.get_stats () in
  Printf.sprintf "统一转换器: %d种类型, %d个活跃转换器" total_types enabled_converters

(** 验证转换结果 *)
let validate_conversion_result = function
  | Success (token, _) -> 
      Printf.printf "✅ 转换成功: %s\n" (TokenUtils.token_to_string token)
  | Failure error ->
      Printf.printf "❌ 转换失败: %s - %s\n" error.source_text error.error_message

(** 初始化转换器系统 *)
let initialize () =
  Printf.printf "🚀 初始化统一Token转换系统...\n";
  ConverterRegistry.clear ();
  register_default_converters ();
  Printf.printf "✅ 转换器初始化完成: %s\n" (get_conversion_stats ())

(** 模块初始化 *)
let () = initialize ()