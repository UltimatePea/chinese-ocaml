(** 骆言C代码生成器接口 - Chinese Programming Language C Code Generator Interface *)

type codegen_config = {
  output_file : string;  (** 输出文件路径 *)
  include_debug : bool;  (** 是否包含调试信息 *)
  optimize : bool;  (** 是否启用优化 *)
  runtime_path : string;  (** 运行时库路径 *)
}
(** 代码生成配置 *)

type codegen_context
(** 代码生成上下文 - 内部实现已隐藏 *)

val create_context : codegen_config -> codegen_context
(** 创建代码生成上下文
    @param config 代码生成配置
    @return 新的代码生成上下文 *)

val generate_c_code : codegen_config -> Ast.program -> string
(** 生成C代码字符串
    @param config 代码生成配置
    @param program 要编译的程序AST
    @return 生成的C代码字符串 *)

val compile_to_c : codegen_config -> Ast.program -> unit
(** 主要编译函数 - 将程序编译到C代码文件
    @param config 代码生成配置，包含输出文件路径
    @param program 要编译的程序AST
    @return 编译成功时返回unit，失败时抛出异常 *)

val gen_label_name : codegen_context -> string -> string
(** 生成唯一标签名
    @param ctx 生成上下文
    @param prefix 标签前缀
    @return 唯一标签名 *)

val c_type_of_luoyan_type : Types.typ -> string
(** 将骆言类型转换为C类型名
    @param luoyan_type 骆言类型
    @return C类型名字符串 *)

val gen_tuple_expr : codegen_context -> Ast.expr list -> string
(** 生成元组表达式的C代码
    @param ctx 生成上下文
    @param exprs 表达式列表
    @return C代码字符串 *)
