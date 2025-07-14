(** 骆言C代码生成器接口 - Chinese Programming Language C Code Generator Interface *)

(** 代码生成配置 *)
type codegen_config = {
  output_file: string;       (** 输出文件路径 *)
  include_debug: bool;       (** 是否包含调试信息 *)
  optimize: bool;            (** 是否启用优化 *)
  runtime_path: string;      (** 运行时库路径 *)
}

(** 代码生成上下文 - 内部实现已隐藏 *)
type codegen_context

(** 创建代码生成上下文
    @param config 代码生成配置
    @return 新的代码生成上下文 *)
val create_context : codegen_config -> codegen_context

(** 生成C代码字符串
    @param config 代码生成配置
    @param program 要编译的程序AST
    @return 生成的C代码字符串 *)
val generate_c_code : codegen_config -> Ast.program -> string

(** 主要编译函数 - 将程序编译到C代码文件
    @param config 代码生成配置，包含输出文件路径
    @param program 要编译的程序AST
    @return 编译成功时返回unit，失败时抛出异常 *)
val compile_to_c : codegen_config -> Ast.program -> unit