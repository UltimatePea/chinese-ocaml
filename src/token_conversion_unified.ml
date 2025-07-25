(** 统一Token转换系统 - Issue #1318 技术债务重构
 *
 *  这个模块整合了之前分散在20+个模块中的Token转换逻辑，
 *  消除代码重复，提供统一的转换策略和异常处理。
 *
 *  ## 架构设计
 *  - 使用多态变体统一不同转换类型
 *  - 可配置的转换策略注册
 *  - 统一的异常处理和错误信息
 *  - 保持向后兼容性
 *
 *  @author 骆言技术债务清理团队 Issue #1318
 *  @version 1.0 - 初始统一转换系统
 *  @since 2025-07-25 *)

open Lexer_tokens

(** 转换器类型定义 *)
type converter_type = [
  | `Identifier
  | `Literal  
  | `BasicKeyword
  | `TypeKeyword
  | `Classical
]

(** 转换结果类型 *)
type conversion_result = 
  | ConversionSuccess of Lexer_tokens.token
  | ConversionFailure of string

(** 统一的转换异常 *)
exception Unified_conversion_failed of converter_type * string

(** 转换器注册表类型 *)
type converter_registry = (converter_type * (Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token)) list

(** 默认转换器注册表 *)
let default_converters : converter_registry = [
  (* 标识符转换器 *)
  (`Identifier, function
    | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> QuotedIdentifierToken s
    | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> IdentifierTokenSpecial s
    | token -> raise (Unified_conversion_failed (`Identifier, "Unknown identifier token: " ^ (Obj.tag (Obj.repr token) |> string_of_int)))
  );
  
  (* 字面量转换器 *)  
  (`Literal, function
    | Token_mapping.Token_definitions_unified.IntToken i -> IntToken i
    | Token_mapping.Token_definitions_unified.FloatToken f -> FloatToken f
    | Token_mapping.Token_definitions_unified.ChineseNumberToken s -> ChineseNumberToken s
    | Token_mapping.Token_definitions_unified.StringToken s -> StringToken s
    | Token_mapping.Token_definitions_unified.BoolToken b -> BoolToken b
    | token -> raise (Unified_conversion_failed (`Literal, "Unknown literal token: " ^ (Obj.tag (Obj.repr token) |> string_of_int)))
  );
  
  (* 基础关键字转换器 *)
  (`BasicKeyword, function
    | Token_mapping.Token_definitions_unified.LetKeyword -> LetKeyword
    | Token_mapping.Token_definitions_unified.RecKeyword -> RecKeyword
    | Token_mapping.Token_definitions_unified.InKeyword -> InKeyword
    | Token_mapping.Token_definitions_unified.FunKeyword -> FunKeyword
    | Token_mapping.Token_definitions_unified.IfKeyword -> IfKeyword
    | Token_mapping.Token_definitions_unified.ThenKeyword -> ThenKeyword
    | Token_mapping.Token_definitions_unified.ElseKeyword -> ElseKeyword
    | Token_mapping.Token_definitions_unified.MatchKeyword -> MatchKeyword
    | Token_mapping.Token_definitions_unified.WithKeyword -> WithKeyword
    | Token_mapping.Token_definitions_unified.AndKeyword -> AndKeyword
    | Token_mapping.Token_definitions_unified.OrKeyword -> OrKeyword
    | Token_mapping.Token_definitions_unified.NotKeyword -> NotKeyword
    | token -> raise (Unified_conversion_failed (`BasicKeyword, "Unknown basic keyword token: " ^ (Obj.tag (Obj.repr token) |> string_of_int)))
  );
  
  (* 类型关键字转换器 *)
  (`TypeKeyword, function
    | Token_mapping.Token_definitions_unified.IntTypeKeyword -> IntTypeKeyword
    | Token_mapping.Token_definitions_unified.FloatTypeKeyword -> FloatTypeKeyword
    | Token_mapping.Token_definitions_unified.StringTypeKeyword -> StringTypeKeyword
    | Token_mapping.Token_definitions_unified.BoolTypeKeyword -> BoolTypeKeyword
    | Token_mapping.Token_definitions_unified.ListTypeKeyword -> ListTypeKeyword
    | token -> raise (Unified_conversion_failed (`TypeKeyword, "Unknown type keyword token: " ^ (Obj.tag (Obj.repr token) |> string_of_int)))
  );
  
  (* 古典语言转换器 *)
  (`Classical, function
    (* 文言文关键字 *)
    | Token_mapping.Token_definitions_unified.HaveKeyword -> HaveKeyword
    | Token_mapping.Token_definitions_unified.OneKeyword -> OneKeyword
    | Token_mapping.Token_definitions_unified.NameKeyword -> NameKeyword
    | Token_mapping.Token_definitions_unified.SetKeyword -> SetKeyword
    | Token_mapping.Token_definitions_unified.AlsoKeyword -> AlsoKeyword
    | Token_mapping.Token_definitions_unified.ThenGetKeyword -> ThenGetKeyword
    | Token_mapping.Token_definitions_unified.CallKeyword -> CallKeyword
    | Token_mapping.Token_definitions_unified.ValueKeyword -> ValueKeyword
    (* 自然语言关键字 *)
    | Token_mapping.Token_definitions_unified.DefineKeyword -> DefineKeyword
    | Token_mapping.Token_definitions_unified.AcceptKeyword -> AcceptKeyword
    | Token_mapping.Token_definitions_unified.ReturnWhenKeyword -> ReturnWhenKeyword
    | Token_mapping.Token_definitions_unified.ElseReturnKeyword -> ElseReturnKeyword
    (* 古雅体关键字 *)
    | Token_mapping.Token_definitions_unified.AncientDefineKeyword -> AncientDefineKeyword
    | Token_mapping.Token_definitions_unified.AncientEndKeyword -> AncientEndKeyword
    | Token_mapping.Token_definitions_unified.AncientAlgorithmKeyword -> AncientAlgorithmKeyword
    | token -> raise (Unified_conversion_failed (`Classical, "Unknown classical token: " ^ (Obj.tag (Obj.repr token) |> string_of_int)))
  );
]

(** 当前活跃的转换器注册表 *)
let active_converters = ref default_converters

(** 转换器优先级顺序 *)
let conversion_priority = [`Identifier; `Literal; `BasicKeyword; `TypeKeyword; `Classical]

(** 注册新的转换器 *)
let register_converter (conv_type : converter_type) (converter : Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token) =
  active_converters := (conv_type, converter) :: (List.remove_assoc conv_type !active_converters)

(** 获取指定类型的转换器 *)
let get_converter (conv_type : converter_type) =
  List.assoc conv_type !active_converters

(** 尝试单个转换器转换 - 返回option类型 *)
let try_convert_with_type (conv_type : converter_type) (token : Token_mapping.Token_definitions_unified.token) =
  try
    let converter = get_converter conv_type in
    Some (converter token)
  with
  | Unified_conversion_failed _ -> None
  | Not_found -> None

(** 统一的Token转换接口 - 按优先级尝试转换 *)
let convert_token (token : Token_mapping.Token_definitions_unified.token) =
  let rec try_converters = function
    | [] -> None
    | conv_type :: rest ->
        (match try_convert_with_type conv_type token with
         | Some result -> Some result
         | None -> try_converters rest)
  in
  try_converters conversion_priority

(** 强制转换Token - 失败时抛出异常 *)
let convert_token_exn (token : Token_mapping.Token_definitions_unified.token) =
  match convert_token token with
  | Some result -> result
  | None -> 
      let token_info = Obj.tag (Obj.repr token) |> string_of_int in
      raise (Unified_conversion_failed (`Identifier, "No converter found for token type: " ^ token_info))

(** 批量转换Token列表 *)
let convert_token_list (tokens : Token_mapping.Token_definitions_unified.token list) =
  List.map convert_token_exn tokens

(** 批量转换Token列表 - option版本 *)
let convert_token_list_safe (tokens : Token_mapping.Token_definitions_unified.token list) =
  List.map convert_token tokens

(** 获取转换统计信息 *)
let get_conversion_stats () =
  let converter_count = List.length !active_converters in
  let priority_info = String.concat " -> " (List.map (function
    | `Identifier -> "标识符"
    | `Literal -> "字面量" 
    | `BasicKeyword -> "基础关键字"
    | `TypeKeyword -> "类型关键字"
    | `Classical -> "古典语言"
  ) conversion_priority) in
  Printf.sprintf "统一Token转换系统: %d个转换器 | 优先级顺序: %s"
    converter_count priority_info

(** 获取详细的转换器信息 *)
let get_converter_details () =
  List.map (fun (conv_type, _) ->
    let type_name = match conv_type with
      | `Identifier -> "标识符转换器"
      | `Literal -> "字面量转换器"
      | `BasicKeyword -> "基础关键字转换器" 
      | `TypeKeyword -> "类型关键字转换器"
      | `Classical -> "古典语言转换器"
    in
    (conv_type, type_name)
  ) !active_converters

(** 重置转换器到默认状态 *)
let reset_converters () =
  active_converters := default_converters

(** 向后兼容性接口 - 模拟原有的单独转换函数 *)
module CompatibilityInterface = struct
  (** 标识符转换 *)
  let convert_identifier_token token =
    match try_convert_with_type `Identifier token with
    | Some result -> result
    | None -> raise (Unified_conversion_failed (`Identifier, "Failed to convert identifier token"))
  
  (** 字面量转换 *)
  let convert_literal_token token =
    match try_convert_with_type `Literal token with
    | Some result -> result
    | None -> raise (Unified_conversion_failed (`Literal, "Failed to convert literal token"))
  
  (** 基础关键字转换 *)
  let convert_basic_keyword_token token =
    match try_convert_with_type `BasicKeyword token with
    | Some result -> result
    | None -> raise (Unified_conversion_failed (`BasicKeyword, "Failed to convert basic keyword token"))
  
  (** 类型关键字转换 *)
  let convert_type_keyword_token token =
    match try_convert_with_type `TypeKeyword token with
    | Some result -> result
    | None -> raise (Unified_conversion_failed (`TypeKeyword, "Failed to convert type keyword token"))
  
  (** 古典语言转换 *)
  let convert_classical_token token =
    match try_convert_with_type `Classical token with
    | Some result -> result
    | None -> raise (Unified_conversion_failed (`Classical, "Failed to convert classical token"))
end