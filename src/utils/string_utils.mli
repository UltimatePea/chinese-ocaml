(** 字符串处理工具模块 - 高效字符串操作和格式化 *)

(** 高效字符串构建器 *)
module StringBuilder : sig
  type t
  
  val create : ?initial_size:int -> unit -> t
  (** [create ?initial_size ()] 创建新的字符串构建器，可选择初始缓冲区大小 *)
  
  val add_string : t -> string -> unit
  (** [add_string builder str] 向构建器添加字符串 *)
  
  val add_char : t -> char -> unit
  (** [add_char builder ch] 向构建器添加字符 *)
  
  val add_strings : t -> string list -> unit
  (** [add_strings builder strings] 向构建器添加字符串列表 *)
  
  val contents : t -> string
  (** [contents builder] 获取构建器中的字符串内容 *)
  
  val clear : t -> unit
  (** [clear builder] 清空构建器内容 *)
end

(** 常用字符串模板和格式化 *)
module Templates : sig
  val undefined_variable : string -> string
  val function_param_mismatch : string -> int -> int -> string
  val type_mismatch : string -> string -> string
  val file_not_found : string -> string
  val member_not_found : string -> string -> string
  val compiling_file : string -> string
  val compilation_complete : int -> float -> string
  val analysis_stats : int -> int -> string
  val variable_value : string -> string -> string
  val function_call : string -> string list -> string
  val type_inference : string -> string -> string
end

val concat_strings : ?separator:string -> string list -> string
(** [concat_strings ?separator strings] 高效连接字符串列表，可选分隔符 *)

(** 诗词格式化专用工具 *)
module PoetryFormatting : sig
  val format_couplet : string -> string -> string
  (** [format_couplet left right] 格式化对联 *)
  
  val format_poem_with_title : string -> string list -> string
  (** [format_poem_with_title title lines] 格式化带标题的诗词 *)
end

(** C代码生成格式化工具 *)
module CCodeGenFormatting : sig
  val format_function_call : string -> string list -> string
  val format_variable_declaration : string -> string -> string -> string
  val format_if_condition : string -> string
  val format_string_literal : string -> string
end

(** Unicode安全的字符串处理 *)
module UnicodeUtils : sig
  val is_chinese_char : char -> bool
  (** [is_chinese_char ch] 检测字符是否为中文字符 *)
  
  val count_chinese_chars : string -> int
  (** [count_chinese_chars str] 计算字符串中的中文字符数量 *)
end