(** 统一Token转换引擎 - Phase 6.2 重构
    
    这是Token系统Phase 6.2重构的核心引擎，整合所有转换逻辑到统一架构中。
    实现了设计文档中定义的4层架构中的转换层核心。
    
    重构目标：
    - 统一错误处理机制
    - 实现统一转换接口设计
    - 支持转换策略动态选择
    - 提供性能优化的快速路径
    
    架构设计：
    - Core Layer: 统一类型定义和错误处理
    - Conversion Layer: 转换引擎核心（本模块）
    - Compatibility Layer: 兼容性处理
    - Interface Layer: 统一对外API
    
    @author Alpha, 主工作代理 - Phase 6.2 Implementation
    @version 2.0 - 统一转换引擎
    @since 2025-07-25
    @fixes Issue #1340 *)

(** 统一错误处理机制 - 符合设计文档规范 *)
type token_error = 
  | ConversionError of string * string  (* source, target *)
  | CompatibilityError of string        (* compatibility issue *)
  | ValidationError of string           (* validation failure *)
  | SystemError of string               (* system level error *)

type 'a token_result = 
  | Success of 'a
  | Error of token_error

(* 统一的错误处理函数 *)
let handle_error = function
  | ConversionError (source, target) -> 
      Printf.eprintf "转换错误: 无法从 %s 转换到 %s\n" source target
  | CompatibilityError issue -> 
      Printf.eprintf "兼容性错误: %s\n" issue
  | ValidationError failure -> 
      Printf.eprintf "验证错误: %s\n" failure
  | SystemError error -> 
      Printf.eprintf "系统错误: %s\n" error

let error_to_string = function
  | ConversionError (source, target) -> 
      Printf.sprintf "转换错误: 无法从 %s 转换到 %s" source target
  | CompatibilityError issue -> 
      Printf.sprintf "兼容性错误: %s" issue
  | ValidationError failure -> 
      Printf.sprintf "验证错误: %s" failure
  | SystemError error -> 
      Printf.sprintf "系统错误: %s" error

(** 转换策略类型 - 符合设计文档规范 *)
type conversion_strategy = 
  | Classical     (* 古典诗词转换 *)
  | Modern        (* 现代中文转换 *)
  | Lexer         (* 词法器转换 *)
  | Auto          (* 自动选择策略 *)

(** 转换器注册类型 *)
type converter_function = Token_mapping.Token_definitions_unified.token -> Lexer_tokens.token option

(** 转换器注册表 *)
module ConverterRegistry = struct
  let classical_converters = ref []
  let modern_converters = ref []
  let lexer_converters = ref []
  
  let register_classical_converter converter =
    classical_converters := converter :: !classical_converters
    
  let register_modern_converter converter =
    modern_converters := converter :: !modern_converters
    
  let register_lexer_converter converter =
    lexer_converters := converter :: !lexer_converters
    
  let get_converters = function
    | Classical -> !classical_converters
    | Modern -> !modern_converters
    | Lexer -> !lexer_converters
    | Auto -> !classical_converters @ !modern_converters @ !lexer_converters
end

(** 统一转换函数签名 - 符合设计文档规范 *)
let convert_token ~strategy ~source ~target_format =
  let converters = ConverterRegistry.get_converters strategy in
  let rec try_converters = function
    | [] -> Error (ConversionError (source, target_format))
    | converter :: rest ->
        match converter (Obj.magic source) with  (* TODO: 需要安全的类型转换 *)
        | Some result -> Success (Obj.magic result)
        | None -> try_converters rest
  in
  try_converters converters

(** 批量转换函数 - 符合设计文档规范 *)
let batch_convert ~strategy ~tokens ~target_format =
  let convert_single token =
    convert_token ~strategy ~source:(Obj.magic token) ~target_format
  in
  let rec convert_all acc = function
    | [] -> Success (List.rev acc)
    | token :: rest ->
        match convert_single token with
        | Success result -> convert_all (result :: acc) rest
        | Error err -> Error err
  in
  convert_all [] tokens

(** 性能优化的快速路径转换 *)
module FastPath = struct
  open Lexer_tokens
  
  (* 常用转换的直接映射 - 避免函数调用开销 *)
  let convert_common_token = function
    | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
    | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
    | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
    | Token_mapping.Token_definitions_unified.ThenKeyword -> Some ThenKeyword
    | Token_mapping.Token_definitions_unified.ElseKeyword -> Some ElseKeyword
    | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
    | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
    | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
    | _ -> None
end

(** 转换引擎核心逻辑 *)
module Core = struct
  open Lexer_tokens
  
  (* 初始化默认转换器 *)
  let initialize_converters () =
    (* 注册现代语言转换器 *)
    ConverterRegistry.register_modern_converter (function
      | Token_mapping.Token_definitions_unified.LetKeyword -> Some LetKeyword
      | Token_mapping.Token_definitions_unified.RecKeyword -> Some RecKeyword
      | Token_mapping.Token_definitions_unified.InKeyword -> Some InKeyword
      | Token_mapping.Token_definitions_unified.FunKeyword -> Some FunKeyword
      | Token_mapping.Token_definitions_unified.IfKeyword -> Some IfKeyword
      | Token_mapping.Token_definitions_unified.ThenKeyword -> Some ThenKeyword
      | Token_mapping.Token_definitions_unified.ElseKeyword -> Some ElseKeyword
      | Token_mapping.Token_definitions_unified.IntToken i -> Some (IntToken i)
      | Token_mapping.Token_definitions_unified.FloatToken f -> Some (FloatToken f)
      | Token_mapping.Token_definitions_unified.StringToken s -> Some (StringToken s)
      | Token_mapping.Token_definitions_unified.BoolToken b -> Some (BoolToken b)
      | Token_mapping.Token_definitions_unified.QuotedIdentifierToken s -> Some (QuotedIdentifierToken s)
      | Token_mapping.Token_definitions_unified.IdentifierTokenSpecial s -> Some (IdentifierTokenSpecial s)
      | _ -> None);
    
    (* 注册古典语言转换器 - 使用现有的 Token_conversion_classical 模块 *)
    ConverterRegistry.register_classical_converter (fun token ->
      try Some (Token_conversion_classical.convert_classical_token token)
      with _ -> None)

  (* 主转换接口 *)
  let convert_with_fallback token =
    match FastPath.convert_common_token token with
    | Some result -> Success (Obj.magic result)
    | None ->
        (* 尝试不同策略按优先级顺序 *)
        let strategies = [Modern; Classical; Lexer] in
        let rec try_strategies = function
          | [] -> Error (ConversionError ("unknown", "lexer_token"))
          | strategy :: rest ->
              match convert_token ~strategy ~source:(Obj.magic token) ~target_format:"lexer_token" with
              | Success result -> Success result
              | Error _ -> try_strategies rest
        in
        try_strategies strategies
end

(** 向后兼容性接口 - 保持原有API *)
module BackwardCompatibility = struct
  let convert_token token =
    match Core.convert_with_fallback token with
    | Success result -> Some (Obj.magic result)
    | Error _ -> None
    
  let convert_token_exn token =
    match convert_token token with
    | Some result -> result
    | None -> failwith ("转换失败: " ^ (Obj.tag (Obj.repr token) |> string_of_int))
    
  let convert_token_list tokens =
    List.filter_map convert_token tokens
end

(** 统计信息模块 *)
module Statistics = struct
  let get_engine_stats () =
    let classical_count = List.length !(ConverterRegistry.classical_converters) in
    let modern_count = List.length !(ConverterRegistry.modern_converters) in
    let lexer_count = List.length !(ConverterRegistry.lexer_converters) in
    Printf.sprintf
      {|转换引擎统计信息:
- 古典语言转换器: %d个
- 现代语言转换器: %d个  
- 词法器转换器: %d个
- 总计: %d个转换器|}
      classical_count modern_count lexer_count
      (classical_count + modern_count + lexer_count)
end

(* 初始化转换引擎 *)
let () = Core.initialize_converters ()