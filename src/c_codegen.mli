(** 骆言C代码生成器 - 将骆言AST转换为C代码

    此模块提供了将骆言抽象语法树(AST)转换为C代码的功能， 包括类型转换、表达式生成、语句生成和完整程序生成。 *)

type codegen_config = C_codegen_context.codegen_config
(** 代码生成配置 *)

type codegen_context = C_codegen_context.codegen_context
(** 代码生成上下文，包含生成过程中的状态信息 *)

val create_context : codegen_config -> codegen_context
(** 创建代码生成上下文
    @param config 代码生成配置
    @return 新的代码生成上下文 *)

val gen_var_name : codegen_context -> string -> string
(** 生成唯一变量名
    @param ctx 代码生成上下文
    @param prefix 变量名前缀
    @return 唯一的变量名 *)

val gen_label_name : codegen_context -> string -> string
(** 生成唯一标签名
    @param ctx 代码生成上下文
    @param prefix 标签名前缀
    @return 唯一的标签名 *)

val escape_identifier : string -> string
(** 转义标识符名称，将骆言标识符转换为C语言兼容的标识符 保留中文字符，只转义C语言不支持的字符
    @param name 原始标识符名称
    @return 转义后的标识符名称 *)

val c_type_of_luoyan_type : Types.typ -> string
(** 将骆言类型转换为对应的C类型名
    @param type_t 骆言类型
    @return 对应的C类型名字符串 *)

val gen_expr : codegen_context -> Ast.expr -> string
(** 生成表达式的C代码
    @param ctx 代码生成上下文
    @param expr 骆言表达式
    @return 生成的C代码字符串 *)

val gen_stmt : codegen_context -> Ast.stmt -> string
(** 生成语句的C代码
    @param ctx 代码生成上下文
    @param stmt 骆言语句
    @return 生成的C代码字符串 *)

val gen_program : codegen_context -> Ast.stmt list -> string
(** 生成程序的C代码
    @param ctx 代码生成上下文
    @param program 骆言程序（语句列表）
    @return 生成的C代码字符串 *)

val generate_c_code : codegen_config -> Ast.stmt list -> string
(** 生成完整的C代码，包含头文件引入、函数定义和主函数
    @param config 代码生成配置
    @param program 骆言程序（语句列表）
    @return 完整的C代码字符串 *)

val compile_to_c : codegen_config -> Ast.stmt list -> (unit, Compiler_errors.compiler_error) result
(** 主要编译函数，将骆言程序编译为C代码并写入文件
    @param config 代码生成配置
    @param program 骆言程序（语句列表）
    @return 成功时返回单位值，失败时返回错误 *)
