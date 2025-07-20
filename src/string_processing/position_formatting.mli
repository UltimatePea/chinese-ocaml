(** 位置信息格式化模块
    
    本模块专门处理源代码位置信息的格式化，
    提供统一的位置信息显示格式。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** {1 基础位置格式化} *)

(** [format_position_with_fields ~filename ~line ~column] 
    使用字段参数格式化位置信息
    @param filename 文件名
    @param line 行号
    @param column 列号
    @return 格式化的位置字符串 "filename:line:column" *)
val format_position_with_fields : filename:string -> line:int -> column:int -> string

(** [format_position_with_extractor pos ~get_filename ~get_line ~get_column] 
    使用提取函数格式化位置信息
    @param pos 位置对象
    @param get_filename 提取文件名的函数
    @param get_line 提取行号的函数
    @param get_column 提取列号的函数
    @return 格式化的位置字符串 *)
val format_position_with_extractor : 
  'a -> get_filename:('a -> string) -> get_line:('a -> int) -> get_column:('a -> int) -> string

(** {1 特定用途的位置格式化} *)

(** [format_compiler_error_position_from_fields filename line column] 
    为编译器错误模块准备的位置格式化函数 *)
val format_compiler_error_position_from_fields : string -> int -> int -> string

(** {1 可选位置处理} *)

(** [format_optional_position_with_extractor pos_opt ~get_filename ~get_line ~get_column] 
    格式化可选的位置信息，返回格式为 " (filename:line:column)" 或空字符串 *)
val format_optional_position_with_extractor : 
  'a option -> get_filename:('a -> string) -> get_line:('a -> int) -> get_column:('a -> int) -> string

(** {1 错误消息与位置结合} *)

(** [error_with_position_extractor pos_opt error_type msg ~get_filename ~get_line ~get_column] 
    生成带位置信息的错误消息
    @param pos_opt 可选的位置信息
    @param error_type 错误类型
    @param msg 错误消息
    @return 格式化的错误消息 *)
val error_with_position_extractor : 
  'a option -> string -> string -> get_filename:('a -> string) -> get_line:('a -> int) -> get_column:('a -> int) -> string