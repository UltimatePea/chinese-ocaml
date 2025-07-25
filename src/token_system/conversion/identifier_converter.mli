(** 骆言编译器 - 标识符转换器接口
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Token_system_core.Token_types
open Token_system_core.Token_errors
open Token_converter

(** 标识符转换器实例 *)
val identifier_converter : (module CONVERTER)

(** 标识符类型 *)
type identifier_type = [`Simple | `Quoted | `Special | `Invalid]

(** 检查是否为有效的标识符 *)
val is_valid_identifier : string -> bool

(** 检测标识符类型 *)
val detect_identifier_type : string -> identifier_type

(** 验证标识符名称 *)
val validate_identifier_name : string -> string token_result

(** 创建标识符Token *)
val create_identifier_token : identifier_type -> string -> token token_result

(** 提取标识符名称 *)
val extract_identifier_name : token -> string token_result

(** 检查标识符是否包含中文字符 *)
val contains_chinese_chars : string -> bool

(** 获取标识符统计信息 *)
val get_identifier_stats : token list -> (string * int) list