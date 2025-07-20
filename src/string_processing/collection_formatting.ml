(** 列表和集合格式化模块
    
    本模块提供各种集合和列表的格式化功能，
    统一处理不同分隔符和格式的需求。
    
    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 中文逗号分隔 *)
let join_chinese items = String.concat "、" items

(** 英文逗号分隔 *)
let join_english items = String.concat ", " items

(** 分号分隔 *)
let join_semicolon items = String.concat "; " items

(** 换行分隔 *)
let join_newline items = String.concat "\n" items

(** 带缩进的项目列表 *)
let indented_list items = String.concat "\n" (List.map (fun s -> "  - " ^ s) items)

(** 数组/元组格式 *)
let array_format items = "[" ^ join_semicolon items ^ "]"

let tuple_format items = "(" ^ join_english items ^ ")"

(** 类型签名格式 *)
let type_signature_format types = String.concat " * " types