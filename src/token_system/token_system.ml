(** 骆言编译器 - 统一Token系统主模块
    
    整合所有Token系统组件，提供统一的访问接口。
    这是Token系统模块整合项目的主要成果。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

module Types = Token_system_core.Token_types
(** 导出核心类型和错误处理 *)

module Errors = Token_system_core.Token_errors
module Registry = Token_system_core.Token_registry

module Converter = Token_system_conversion.Token_converter
(** 导出转换器 *)

module KeywordConverter = Token_system_conversion.Keyword_converter
module IdentifierConverter = Token_system_conversion.Identifier_converter
module OperatorConverter = Token_system_conversion.Operator_converter

module Compatibility = Token_system_compatibility.Legacy_token_bridge
(** 导出兼容性层 *)

module Utils = Token_system_utils.Token_utils
(** 导出工具函数 *)

(** 系统版本信息 *)
let version = "2.0"

let build_date = "2025-07-25"
let issue_number = 1353

(** 初始化Token系统 *)
let initialize_token_system () =
  (* 初始化Token注册表 *)
  Registry.initialize_default_tokens ();

  (* 注册所有转换器 *)
  Converter.ConverterRegistry.register_converter KeywordConverter.keyword_converter;
  Converter.ConverterRegistry.register_converter IdentifierConverter.identifier_converter;
  Converter.ConverterRegistry.register_converter OperatorConverter.operator_converter;
  Converter.ConverterRegistry.register_converter OperatorConverter.delimiter_converter;

  (* 创建并注册字面量转换器 *)
  let literal_converter = Converter.ConverterFactory.create_literal_converter () in
  Converter.ConverterRegistry.register_converter literal_converter;

  Printf.printf "Token系统 v%s 初始化完成 (构建日期: %s, 问题 #%d)\n" version build_date issue_number

(** 便利的转换函数 *)
module ConversionAPI = struct
  (** 字符串转Token *)
  let string_to_token ?(config = Converter.default_config) text =
    Converter.UnifiedConverter.convert_string_to_token ~config text

  (** Token转字符串 *)
  let token_to_string ?(config = Converter.default_config) token =
    Converter.UnifiedConverter.convert_token_to_string ~config token

  (** 批量字符串转Token *)
  let strings_to_tokens ?(config = Converter.default_config) strings =
    Converter.UnifiedConverter.convert_strings_to_tokens ~config strings

  (** 批量Token转字符串 *)
  let tokens_to_strings ?(config = Converter.default_config) tokens =
    Converter.UnifiedConverter.convert_tokens_to_strings ~config tokens
end

(** 系统状态和统计 *)
module SystemInfo = struct
  (** 获取系统信息 *)
  let get_system_info () =
    let registry_stats = Registry.get_stats () in
    let converter_stats = Converter.UnifiedConverter.get_converter_stats () in
    [
      ("version", version);
      ("build_date", build_date);
      ("issue_number", string_of_int issue_number);
      ("total_registered_tokens", string_of_int registry_stats.total_tokens);
      ("total_converters", string_of_int (List.assoc "total" converter_stats));
    ]

  (** 生成系统状态报告 *)
  let generate_status_report () =
    let _info = get_system_info () in
    let registry_stats = Registry.get_stats () in
    let converter_stats = Converter.UnifiedConverter.get_converter_stats () in

    let lines =
      [
        "骆言编译器 - Token系统状态报告";
        "================================";
        "";
        "版本信息:";
        Printf.sprintf "  版本: %s" version;
        Printf.sprintf "  构建日期: %s" build_date;
        Printf.sprintf "  相关问题: #%d" issue_number;
        "";
        "Token注册表统计:";
        Printf.sprintf "  总Token数: %d" registry_stats.total_tokens;
        Printf.sprintf "  字面量Token: %d" registry_stats.literal_tokens;
        Printf.sprintf "  关键字Token: %d" registry_stats.keyword_tokens;
        Printf.sprintf "  操作符Token: %d" registry_stats.operator_tokens;
        Printf.sprintf "  分隔符Token: %d" registry_stats.delimiter_tokens;
        "";
        "转换器统计:";
      ]
    in

    let converter_lines =
      List.map (fun (name, count) -> Printf.sprintf "  %s: %d" name count) converter_stats
    in

    String.concat "\n" (lines @ converter_lines)

  (** 运行系统自检 *)
  let run_self_check () =
    let errors = ref [] in

    (* 检查注册表状态 *)
    let stats = Registry.get_stats () in
    if stats.total_tokens = 0 then errors := "Token注册表为空" :: !errors;

    (* 检查转换器注册 *)
    let converters = Converter.ConverterRegistry.get_all_converters () in
    if List.length converters = 0 then errors := "没有注册的转换器" :: !errors;

    (* 测试基本转换功能 *)
    (match ConversionAPI.string_to_token "让" with
    | Ok _ -> ()
    | Error _ -> errors := "关键字转换失败" :: !errors);

    (match ConversionAPI.string_to_token "123" with
    | Ok _ -> ()
    | Error _ -> errors := "字面量转换失败" :: !errors);

    if !errors = [] then Errors.ok_result "系统自检通过"
    else Errors.error_result (Errors.RegistryError (String.concat "; " !errors))
end

(** 便利的查找函数 *)
module LookupAPI = struct
  (** 查找Token *)
  let find_token text = Registry.lookup_token_by_text text

  (** 获取Token文本 *)
  let get_text token = Registry.get_token_text token

  (** 检查Token是否已注册 *)
  let is_registered token = Registry.is_registered token

  (** 按类别获取Token *)
  let get_by_category category = Registry.get_tokens_by_category category
end

(** 开发和调试API *)
module DebugAPI = struct
  (** 打印Token列表 *)
  let print_tokens tokens = Utils.Debug.print_token_list tokens

  (** 打印Token流 *)
  let print_token_stream stream = Utils.Debug.print_positioned_token_list stream

  (** 生成Token统计 *)
  let generate_stats tokens = Utils.Statistics.generate_comprehensive_stats tokens

  (** 验证Token流语法 *)
  let validate_syntax stream = Utils.Validation.validate_basic_syntax stream
end

(** 批量处理API *)
module BatchAPI = struct
  (** 处理Token文件 *)
  let process_token_file _filename =
    try
      let content =
        Errors.SafeOps.safe_process_token_stream [] (fun _ ->
            (* 这里应该读取文件并解析Token *)
            [])
      in
      content
    with exn ->
      Errors.error_result
        (Errors.ParsingError (Printexc.to_string exn, { line = 0; column = 0; offset = 0 }))

  (** 批量转换多个文本 *)
  let batch_convert_texts texts = ConversionAPI.strings_to_tokens texts
end

(** 主初始化函数 - 推荐在应用启动时调用 *)
let init () =
  try
    initialize_token_system ();
    match SystemInfo.run_self_check () with
    | Ok _ ->
        Printf.printf "Token系统初始化成功\n";
        Errors.ok_result ()
    | Error err ->
        Printf.eprintf "Token系统自检失败: %s\n" (Errors.error_to_string err);
        Errors.error_result err
  with exn ->
    Printf.eprintf "Token系统初始化失败: %s\n" (Printexc.to_string exn);
    Errors.error_result (Errors.RegistryError ("初始化失败: " ^ Printexc.to_string exn))
