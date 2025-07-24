(** 骆言编译器统一缓冲区格式化工具模块接口 *)

(** {1 缓冲区大小常量} *)
module BufferSizes : sig
  (** 标识符、标签等微小内容的缓冲区大小 *)
  val tiny : int
  
  (** 简单值格式化的缓冲区大小 *)
  val small : int
  
  (** 标准容器（列表、数组、元组）的缓冲区大小 *)
  val standard : int
  
  (** 记录、方法等中等复杂结构的缓冲区大小 *)
  val medium : int
  
  (** 小型报告和错误信息的缓冲区大小 *)
  val large : int
  
  (** 错误消息、违规报告的缓冲区大小 *)
  val xlarge : int
  
  (** 大型报告的缓冲区大小 *)
  val xxlarge : int
  
  (** 超大型报告的缓冲区大小 *)
  val huge : int
end

(** {1 通用格式化函数} *)
module Formatting : sig
  
  (** 格式化列表，使用给定的分隔符
      @param buffer 目标缓冲区
      @param open_delim 开始分隔符
      @param close_delim 结束分隔符
      @param separator 元素间分隔符
      @param formatter 元素格式化函数
      @param items 待格式化的元素列表 *)
  val format_list : 
    buffer:Buffer.t -> 
    open_delim:string -> 
    close_delim:string -> 
    separator:string -> 
    formatter:('a -> string) -> 
    'a list -> unit

  (** 格式化键值对
      @param buffer 目标缓冲区
      @param open_delim 开始分隔符
      @param close_delim 结束分隔符
      @param pair_sep 键值对间分隔符
      @param kv_sep 键值分隔符
      @param key_formatter 键格式化函数
      @param value_formatter 值格式化函数
      @param pairs 待格式化的键值对列表 *)
  val format_pairs : 
    buffer:Buffer.t -> 
    open_delim:string -> 
    close_delim:string -> 
    pair_sep:string -> 
    kv_sep:string -> 
    key_formatter:('a -> string) -> 
    value_formatter:('b -> string) -> 
    ('a * 'b) list -> unit

  (** {2 OCaml风格容器格式化便利函数} *)
  
  (** 格式化OCaml列表 [elem1; elem2; elem3] *)
  val format_ocaml_list : formatter:('a -> string) -> 'a list -> string

  (** 格式化OCaml数组 [|elem1; elem2; elem3|] *)
  val format_ocaml_array : formatter:('a -> string) -> 'a list -> string

  (** 格式化OCaml元组 (elem1, elem2, elem3) *)
  val format_ocaml_tuple : formatter:('a -> string) -> 'a list -> string

  (** 格式化OCaml记录 {field1 = value1; field2 = value2} *)
  val format_ocaml_record : 
    key_formatter:('a -> string) -> 
    value_formatter:('b -> string) -> 
    ('a * 'b) list -> string
    
  (** 格式化函数参数 (arg1, arg2, arg3) *)
  val format_function_args : formatter:('a -> string) -> 'a list -> string

  (** 格式化构造器与参数 Constructor(arg1, arg2) *)
  val format_constructor : name:string -> formatter:('a -> string) -> 'a list -> string

  (** {2 类型格式化函数} *)
  
  (** 格式化方法签名列表 < method1: type1; method2: type2 > *)
  val format_method_list : 
    key_formatter:('a -> string) -> 
    value_formatter:('b -> string) -> 
    ('a * 'b) list -> string

  (** 格式化变体类型 Type1 | Type2 | Type3 *)
  val format_variant_types : formatter:('a -> string) -> 'a list -> string

  (** 格式化产品类型 Type1 * Type2 * Type3 *)
  val format_product_types : formatter:('a -> string) -> 'a list -> string

  (** 格式化函数类型 Type1 -> Type2 -> Type3 *)
  val format_function_type : formatter:('a -> string) -> 'a list -> string
end

(** {1 报告格式化工具} *)
module Reports : sig
  (** 创建标准报告缓冲区 *)
  val create_report_buffer : unit -> Buffer.t
  
  (** 创建大型报告缓冲区 *)
  val create_large_report_buffer : unit -> Buffer.t
  
  (** 添加报告标题（带下划线） *)
  val add_header : buffer:Buffer.t -> title:string -> unit
    
  (** 添加报告小节 *)
  val add_section : buffer:Buffer.t -> title:string -> content:string -> unit

  (** 添加无序项目列表 *)
  val add_item_list : buffer:Buffer.t -> items:string list -> unit

  (** 添加有序编号列表 *)
  val add_numbered_list : buffer:Buffer.t -> items:string list -> unit
end

(** {1 高级格式化工具} *)
module Advanced : sig
  (** 创建带缩进的格式化器 *)
  val create_indented_formatter : indent_size:int -> buffer:Buffer.t -> content:string -> unit

  (** 格式化嵌套结构（带缩进） *)
  val format_nested : formatter:('a -> string) -> indent_size:int -> 'a list -> string

  (** 条件格式化 - 仅当列表非空时才格式化 *)
  val format_if_non_empty : formatter:('a list -> string) -> empty_message:string -> 'a list -> string

  (** 限制长度的格式化（超出时截断） *)
  val format_with_limit : 
    formatter:('a list -> string) -> 
    limit:int -> 
    truncate_message:string -> 
    'a list -> string
end

(** {1 向后兼容性函数} *)

(** 创建标准大小缓冲区 *)
val create_standard_buffer : unit -> Buffer.t

(** 创建中等大小缓冲区 *)
val create_medium_buffer : unit -> Buffer.t

(** 创建大型缓冲区 *)
val create_large_buffer : unit -> Buffer.t

(** 格式化简单列表（OCaml风格） *)
val format_simple_list : string -> ('a -> string) -> 'a list -> string

(** 格式化简单记录（OCaml风格） *)
val format_simple_record : ('a -> string) -> ('b -> string) -> ('a * 'b) list -> string