(** 骆言编译器 - 统一Token转换器
    
    整合原本分散在多个模块中的Token转换功能，
    提供统一的转换接口，简化Token转换逻辑。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types
open Token_system_unified_core.Token_errors

(** 转换器类型 *)
type converter_type =
  | KeywordConverter  (** 关键字转换器 *)
  | IdentifierConverter  (** 标识符转换器 *)
  | LiteralConverter  (** 字面量转换器 *)
  | OperatorConverter  (** 操作符转换器 *)
  | DelimiterConverter  (** 分隔符转换器 *)

type converter_config = {
  enable_legacy_support : bool;  (** 启用遗留支持 *)
  strict_mode : bool;  (** 严格模式 *)
  enable_aliases : bool;  (** 启用别名支持 *)
  case_sensitive : bool;  (** 大小写敏感 *)
}
(** 转换器配置 *)

(** 默认转换器配置 *)
let default_config =
  {
    enable_legacy_support = true;
    strict_mode = false;
    enable_aliases = true;
    case_sensitive = false;
  }

(** 转换器接口 *)
module type CONVERTER = sig
  val name : string
  (** 转换器名称 *)

  val converter_type : converter_type
  (** 转换器类型 *)

  val string_to_token : converter_config -> string -> token token_result
  (** 从字符串转换为Token *)

  val token_to_string : converter_config -> token -> string token_result
  (** 从Token转换为字符串 *)

  val can_handle_string : string -> bool
  (** 检查是否可以处理给定的字符串 *)

  val can_handle_token : token -> bool
  (** 检查是否可以处理给定的Token *)

  val supported_tokens : unit -> token list
  (** 获取支持的Token列表 *)
end

(** 转换器注册表 *)
module ConverterRegistry = struct
  (** 注册的转换器列表 *)
  let converters = ref []

  (** 注册转换器 *)
  let register_converter (module C : CONVERTER) =
    converters := (module C : CONVERTER) :: !converters

  (** 获取所有转换器 *)
  let get_all_converters () = !converters

  (** 根据类型获取转换器 *)
  let get_converters_by_type conv_type =
    List.filter (fun (module C : CONVERTER) -> C.converter_type = conv_type) !converters

  (** 查找能处理字符串的转换器 *)
  let find_converter_for_string text =
    List.find_opt (fun (module C : CONVERTER) -> C.can_handle_string text) !converters

  (** 查找能处理Token的转换器 *)
  let find_converter_for_token token =
    List.find_opt (fun (module C : CONVERTER) -> C.can_handle_token token) !converters
end

(** 主转换器模块 *)
module UnifiedConverter = struct
  (** 从字符串转换为Token *)
  let convert_string_to_token ?(config = default_config) text =
    match ConverterRegistry.find_converter_for_string text with
    | Some (module C) -> C.string_to_token config text
    | None -> error_result (UnknownToken (text, None))

  (** 从Token转换为字符串 *)
  let convert_token_to_string ?(config = default_config) token =
    match ConverterRegistry.find_converter_for_token token with
    | Some (module C) -> C.token_to_string config token
    | None -> error_result (ConversionError ("Token", "string"))

  (** 批量转换字符串列表为Token列表 *)
  let convert_strings_to_tokens ?(config = default_config) strings =
    let rec convert_all acc = function
      | [] -> ok_result (List.rev acc)
      | text :: rest -> (
          match convert_string_to_token ~config text with
          | Ok token -> convert_all (token :: acc) rest
          | Error err -> error_result err)
    in
    convert_all [] strings

  (** 批量转换Token列表为字符串列表 *)
  let convert_tokens_to_strings ?(config = default_config) tokens =
    let rec convert_all acc = function
      | [] -> ok_result (List.rev acc)
      | token :: rest -> (
          match convert_token_to_string ~config token with
          | Ok text -> convert_all (text :: acc) rest
          | Error err -> error_result err)
    in
    convert_all [] tokens

  (** 获取转换器统计信息 *)
  let get_converter_stats () =
    let converters = ConverterRegistry.get_all_converters () in
    let count_by_type conv_type =
      List.length (ConverterRegistry.get_converters_by_type conv_type)
    in
    [
      ("total", List.length converters);
      ("keyword", count_by_type KeywordConverter);
      ("identifier", count_by_type IdentifierConverter);
      ("literal", count_by_type LiteralConverter);
      ("operator", count_by_type OperatorConverter);
      ("delimiter", count_by_type DelimiterConverter);
    ]
end

(** 兼容性转换函数 - 用于向后兼容 *)
module LegacySupport = struct
  (** 从旧的Token类型转换 *)
  let convert_from_legacy_token _legacy_token =
    (* 这里需要根据实际的旧Token类型来实现转换逻辑 *)
    error_result (ConversionError ("legacy_token", "unified_token"))

  (** 转换为旧的Token类型 *)
  let convert_to_legacy_token _unified_token =
    (* 这里需要根据实际的旧Token类型来实现转换逻辑 *)
    error_result (ConversionError ("unified_token", "legacy_token"))
end

(** 转换器工厂 *)
module ConverterFactory = struct
  (** 创建关键字转换器 *)
  let create_keyword_converter keyword_map =
    let module KeywordConv = struct
      let name = "keyword_converter"
      let converter_type = KeywordConverter

      let string_to_token config text =
        if config.case_sensitive then
          match List.assoc_opt text keyword_map with
          | Some token -> ok_result token
          | None -> error_result (UnknownToken (text, None))
        else
          let lower_text = String.lowercase_ascii text in
          let lower_map = List.map (fun (k, v) -> (String.lowercase_ascii k, v)) keyword_map in
          match List.assoc_opt lower_text lower_map with
          | Some token -> ok_result token
          | None -> error_result (UnknownToken (text, None))

      let token_to_string _config token =
        match List.find_opt (fun (_, t) -> t = token) keyword_map with
        | Some (text, _) -> ok_result text
        | None -> error_result (ConversionError ("keyword_token", "string"))

      let can_handle_string text = List.exists (fun (k, _) -> k = text) keyword_map
      let can_handle_token token = List.exists (fun (_, t) -> t = token) keyword_map
      let supported_tokens () = List.map snd keyword_map
    end in
    (module KeywordConv : CONVERTER)

  (** 创建字面量转换器 *)
  let create_literal_converter () =
    let module LiteralConv = struct
      let name = "literal_converter"
      let converter_type = LiteralConverter

      let string_to_token config text =
        let _config = config in
        (* 尝试解析为不同类型的字面量 *)
        try
          (* 尝试解析为整数 *)
          let int_val = int_of_string text in
          ok_result (Literal (IntToken int_val))
        with Failure _ -> (
          try
            (* 尝试解析为浮点数 *)
            let float_val = float_of_string text in
            ok_result (Literal (FloatToken float_val))
          with Failure _ -> (
            (* 检查是否为布尔值 *)
            match text with
            | "true" | "真" -> ok_result (Literal (BoolToken true))
            | "false" | "假" -> ok_result (Literal (BoolToken false))
            | _ ->
                (* 检查是否为字符串字面量 *)
                if
                  String.length text >= 2
                  && String.get text 0 = '"'
                  && String.get text (String.length text - 1) = '"'
                then
                  let content = String.sub text 1 (String.length text - 2) in
                  ok_result (Literal (StringToken content))
                else
                  error_result
                    (InvalidTokenFormat ("literal", text, { line = 0; column = 0; offset = 0 }))))

      let token_to_string config token =
        match token with
        | Literal (IntToken i) -> ok_result (string_of_int i)
        | Literal (FloatToken f) -> ok_result (string_of_float f)
        | Literal (StringToken s) -> ok_result ("\"" ^ s ^ "\"")
        | Literal (BoolToken true) -> ok_result (if config.enable_aliases then "真" else "true")
        | Literal (BoolToken false) -> ok_result (if config.enable_aliases then "假" else "false")
        | Literal (ChineseNumberToken s) -> ok_result s
        | _ -> error_result (ConversionError ("literal_token", "string"))

      let can_handle_string text =
        (* 简单的启发式检查 *)
        try
          ignore (int_of_string text);
          true
        with Failure _ -> (
          try
            ignore (float_of_string text);
            true
          with Failure _ ->
            text = "true" || text = "false" || text = "真" || text = "假"
            || String.length text >= 2
               && String.get text 0 = '"'
               && String.get text (String.length text - 1) = '"')

      let can_handle_token = function Literal _ -> true | _ -> false
      let supported_tokens () = [] (* 字面量Token是动态生成的 *)
    end in
    (module LiteralConv : CONVERTER)
end
