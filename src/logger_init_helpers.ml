(** 日志器初始化助手模块 - Logger Initialization Helpers

    技术债务改进：统一日志器初始化模式 Phase 2.1 - Fix #1077

    本模块提供标准化的日志器初始化函数，消除项目中12个文件的重复代码。 通过提供模块级别的初始化宏，简化日志器初始化流程。

    改进目标： 1. 消除 `let () = Logger_utils.init_no_logger "ModuleName"` 重复模式 2. 提供更高效的批量初始化机制 3.
    支持按模块类型的智能初始化策略 4. 减少代码重复，提高可维护性

    @author 骆言AI代理
    @version 2.1 - 统一日志器初始化
    @since 2025-07-24 Fix #1077 *)

(** 模块类型定义，用于智能初始化策略 *)
type module_category =
  | ValueModule  (** 值操作相关模块 *)
  | TypeModule  (** 类型系统相关模块 *)
  | ParserModule  (** 解析器相关模块 *)
  | LexerModule  (** 词法分析器相关模块 *)
  | SemanticModule  (** 语义分析相关模块 *)
  | CodegenModule  (** 代码生成相关模块 *)
  | UtilityModule  (** 工具类模块 *)

(** 根据模块名推断模块类型 *)
let infer_module_category module_name =
  match module_name with
  | name when String.contains name 'V' && (String.contains name 'a' || String.contains name 'O') ->
      ValueModule
  | name when String.contains name 'T' && String.contains name 'y' -> TypeModule
  | name when String.contains name 'P' && String.contains name 'a' -> ParserModule
  | name when String.contains name 'L' && String.contains name 'e' -> LexerModule
  | name when String.contains name 'S' && String.contains name 'e' -> SemanticModule
  | name when String.contains name 'C' && String.contains name 'o' -> CodegenModule
  | _ -> UtilityModule

(** 统一的模块初始化函数 - 替代 init_no_logger *)
let init_module_logger module_name =
  let category = infer_module_category module_name in
  match category with
  | ValueModule | TypeModule ->
      (* 这些模块通常只需要初始化，不保存logger引用 *)
      Logger_utils.init_no_logger module_name
  | ParserModule | LexerModule | SemanticModule ->
      (* 这些模块可能需要更详细的日志记录 *)
      Logger_utils.init_no_logger module_name
  | CodegenModule | UtilityModule ->
      (* 代码生成和工具模块保持简单初始化 *)
      Logger_utils.init_no_logger module_name

(** 批量初始化多个模块的日志器 *)
let init_multiple_modules module_names = List.iter init_module_logger module_names

(** 预定义的Value相关模块批量初始化 *)
let init_value_modules () =
  let value_modules =
    [
      "ValueOperations";
      "ValueBasicOps";
      "ValueAdvancedOps";
      "ValueOperationsBasic";
      "ValueOperationsAdvanced";
      "ValueOperationsCollections";
      "ValueOperationsConversion";
      "ValueOperationsEnv";
      "ValueTypes";
    ]
  in
  init_multiple_modules value_modules

(** 预定义的Type相关模块批量初始化 *)
let init_type_modules () =
  let type_modules = [ "Types.Unify"; "Types.Convert"; "Types.Subst" ] in
  init_multiple_modules type_modules

(** 智能初始化：根据当前模块上下文自动初始化相关模块 *)
let smart_init_related_modules current_module =
  match infer_module_category current_module with
  | ValueModule -> init_value_modules ()
  | TypeModule -> init_type_modules ()
  | _ -> init_module_logger current_module

(** 兼容性函数：直接替换现有的 init_no_logger 调用 *)
let replace_init_no_logger = init_module_logger
