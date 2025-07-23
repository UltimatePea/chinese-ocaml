(** 骆言编译器C代码生成格式化模块接口

    本模块专注于C代码生成的格式化功能，提供类型安全的C代码格式化接口。
    主要包含骆言特定的C运行时函数调用、标准C语言结构格式化和高级代码生成工具。
    
    从unified_formatter.ml中拆分而来，专注于代码生成过程中的格式化需求。
    
    @author 骆言AI代理  
    @version 1.0
    @since 2025-07-22 *)

(** C代码生成格式化核心模块 *)
module CCodegen : sig
  (** 基础函数调用格式化 *)
  val function_call : string -> string list -> string
  val binary_function_call : string -> string -> string -> string
  val unary_function_call : string -> string -> string

  (** 骆言特定的C运行时函数调用 *)
  val luoyan_call : string -> int -> string -> string
  val luoyan_bind_var : string -> string -> string
  val luoyan_string : string -> string
  val luoyan_int : int -> string
  val luoyan_float : float -> string
  val luoyan_bool : bool -> string
  val luoyan_unit : unit -> string
  val luoyan_equals : string -> string -> string
  val luoyan_let : string -> string -> string -> string
  val luoyan_function_create : string -> string -> string
  val luoyan_pattern_match : string -> string
  val luoyan_var_expr : string -> string -> string

  (** 环境绑定格式化 *)
  val luoyan_env_bind : string -> string -> string
  val luoyan_function_create_with_args : string -> string -> string

  (** 字符串处理 *)
  val luoyan_string_equality_check : string -> string -> string

  (** 编译过程消息 *)
  val compilation_start_message : string -> string
  val compilation_status_message : string -> string -> string

  (** 异常处理格式化 *)
  val luoyan_catch : string -> string
  val luoyan_try_catch : string -> string -> string -> string
  val luoyan_raise : string -> string
  
  (** 组合表达式格式化 *)
  val luoyan_combine : string list -> string
  
  (** 模式匹配格式化 *)
  val luoyan_match_constructor : string -> string -> string
  
  (** 模块操作格式化 *)
  val luoyan_include_module : string -> string
  
  (** C语句格式化 *)
  val c_statement : string -> string
  val c_statement_sequence : string -> string -> string
  val c_statement_block : string list -> string

  (** C代码模板格式化 *)
  val c_template_with_includes : string -> string -> string -> string

  (** 变量声明 *)
  val c_variable_declaration : string -> string -> string -> string
  val c_const_declaration : string -> string -> string -> string

  (** 控制流结构 *)
  val c_if_statement : string -> string -> string
  val c_if_else_statement : string -> string -> string -> string
  val c_while_loop : string -> string -> string
  val c_for_loop : string -> string -> string -> string -> string

  (** 函数定义 *)
  val c_function_declaration : string -> string -> string list -> string
  val c_function_definition : string -> string -> string list -> string -> string

  (** 结构体和类型定义 *)
  val c_struct_definition : string -> (string * string) list -> string
  val c_enum_definition : string -> string list -> string
end

(** 增强C代码生成模块 *)
module EnhancedCCodegen : sig
  (** 类型转换 *)
  val type_cast : string -> string -> string
  
  (** 构造器匹配 *)
  val constructor_match : string -> string -> string
  
  (** 字符串相等性检查 *)
  val string_equality_escaped : string -> string -> string
  
  (** 扩展的骆言函数调用 *)
  val luoyan_call_with_cast : string -> string -> string list -> string
  
  (** 复合C代码模式 *)
  val luoyan_conditional_binding : string -> string -> string -> string -> string

  (** 高级函数调用 *)
  val luoyan_dynamic_call : string -> string -> string
  val luoyan_partial_application : string -> string -> string

  (** 内存管理 *)
  val luoyan_alloc : int -> string
  val luoyan_free : string -> string
  val luoyan_gc_collect : unit -> string

  (** 数据结构操作 *)
  val luoyan_array_create : int -> string
  val luoyan_array_get : string -> int -> string
  val luoyan_array_set : string -> int -> string -> string
  val luoyan_record_create : int -> string
  val luoyan_record_get : string -> string -> string
  val luoyan_record_set : string -> string -> string -> string

  (** 类型检查 *)
  val luoyan_type_check : string -> string -> string
  val luoyan_is_type : string -> string -> string

  (** 错误处理 *)
  val luoyan_error_throw : int -> string -> string
  val luoyan_error_propagate : string -> string
  val luoyan_error_check : string -> string

  (** 调试和性能 *)
  val luoyan_debug_trace : string -> string -> string
  val luoyan_profile_start : string -> string
  val luoyan_profile_end : string -> string
end

(** C代码生成工具模块 *)
module CodeGenUtilities : sig
  (** 代码注释 *)
  val c_line_comment : string -> string
  val c_block_comment : string -> string
  val c_doc_comment : string -> string

  (** 代码格式化 *)
  val c_indent_block : string -> int -> string
  val c_format_parameter_list : string list -> string

  (** 预处理器指令 *)
  val c_include_system : string -> string
  val c_include_local : string -> string
  val c_define : string -> string -> string
  val c_ifdef : string -> string
  val c_ifndef : string -> string
  val c_endif : unit -> string

  (** 代码块管理 *)
  val c_scope_block : string list -> string
  val c_namespace_block : string -> string -> string
end