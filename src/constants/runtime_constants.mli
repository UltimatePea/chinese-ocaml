(** C运行时函数名称常量模块接口 *)

(** 二元运算函数 *)
val add : string
val subtract : string
val multiply : string
val divide : string
val modulo : string
val equal : string
val not_equal : string
val less_than : string
val greater_than : string
val less_equal : string
val greater_equal : string
val logical_and : string
val logical_or : string
val concat : string

(** 一元运算函数 *)
val logical_not : string
val int_zero : string

(** 内存操作函数 *)
val ref_create : string
val deref : string
val assign : string

(** 文件扩展名 *)
val c_extension : string
val ly_extension : string
val temp_extension : string