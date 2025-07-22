(** 骆言统一字符串工具模块接口 - Unified String Utilities Interface *)

(** 字符串格式化工具 *)
module Formatting : sig
  val safe_sprintf : ('a, unit, string) format -> 'a
  (** 安全的sprintf实现，自动处理转义 *)

  val format_error : string -> string -> string
  (** 格式化错误消息，统一添加前缀 *)

  val format_position : string -> int -> string
  (** 格式化位置信息 *)

  val format_function_call : string -> string list -> string
  (** 格式化函数调用表示 *)

  val format_binary_operation : string -> string -> string -> string
  (** 格式化二元运算表示 *)

  val format_list : string -> string list -> string
  (** 格式化列表为字符串，使用指定分隔符 *)
end

(** 路径和文件名处理工具 *)
module Path : sig
  val join : string list -> string
  (** 安全的路径连接，处理分隔符 *)

  val basename : string -> string
  (** 提取文件名（不包含路径） *)

  val dirname : string -> string
  (** 提取目录名 *)

  val normalize_separators : string -> string
  (** 标准化路径分隔符 *)
end

(** 中文文本处理工具 *)
module Chinese : sig
  val contains_chinese : string -> bool
  (** 检查字符串是否包含中文字符 *)

  val display_width : string -> int
  (** 获取字符串的显示宽度（考虑中文字符） *)

  val truncate_by_width : int -> string -> string
  (** 按显示宽度截断字符串 *)

  val pad_chinese : int -> string -> string
  (** 中文友好的字符串填充 *)
end

(** 安全字符串操作工具 *)
module Safe : sig
  val concat : string -> string list -> string
  (** 安全的字符串连接，处理null和空字符串 *)

  val compare_normalized : string -> string -> int
  (** 安全的字符串比较，处理大小写和空格 *)

  val substring : string -> int -> int -> string option
  (** 安全的子字符串提取 *)

  val to_int_safe : string -> int option
  (** 安全的字符串转换为整数 *)
end
