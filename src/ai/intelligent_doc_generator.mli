(** 智能文档生成器接口 - Intelligent Documentation Generator Interface *)

(** 简化的表达式类型，用于文档分析 *)
type simple_expr = 
  | SLiteral of string                    
  | SVariable of string                   
  | SBinary of simple_expr * string * simple_expr  
  | SFunction of string * simple_expr list        
  | SCondition of simple_expr * simple_expr * simple_expr  
  | SMatch of simple_expr * (string * simple_expr) list    
  | SList of simple_expr list             
  | STuple of simple_expr list            

(** 函数定义信息 *)
type function_info = {
  name: string;              (* 函数名 *)
  parameters: string list;   (* 参数列表 *)
  body: simple_expr;         (* 函数体 *)
  is_recursive: bool;        (* 是否递归 *)
}

(** 文档生成配置 *)
type doc_generation_config = {
  include_examples: bool;                              (* 是否包含使用示例 *)
  detail_level: [`Brief | `Detailed | `Comprehensive]; (* 详细程度 *)
  output_format: [`Markdown | `HTML | `OCamlDoc];     (* 输出格式 *)
  language_style: [`Formal | `Casual | `Technical];   (* 语言风格 *)
}

(** 生成的文档结构 *)
type generated_doc = {
  summary: string;                        (* 功能概要 *)
  parameters: (string * string) list;     (* 参数说明 *)
  return_value: string;                   (* 返回值说明 *)
  examples: string list;                  (* 使用示例 *)
  notes: string list;                     (* 注意事项 *)
  confidence: float;                      (* 生成质量置信度 *)
}

(** 模块级文档结构 *)
type module_doc = {
  module_summary: string;                 (* 模块概要 *)
  functions: (string * generated_doc) list; (* 函数文档列表 *)
  types: (string * string) list;         (* 类型说明 *)
  dependencies: string list;              (* 依赖关系 *)
  usage_guide: string;                    (* 使用指南 *)
}

(** 默认配置 *)
val default_config : doc_generation_config

(** 检查字符串是否包含子串 *)
val string_contains : string -> string -> bool

(** 生成函数文档注释 *)
val generate_function_documentation : function_info -> doc_generation_config -> generated_doc

(** 格式化为Markdown *)
val format_as_markdown : generated_doc -> string -> string

(** 格式化为OCaml文档注释 *)
val format_as_ocaml_doc : generated_doc -> string -> string

(** 生成模块级文档 *)
val generate_module_documentation : string -> function_info list -> doc_generation_config -> module_doc

(** 主要API：为单个函数生成文档 *)
val generate_function_doc : function_info -> doc_generation_config -> generated_doc

(** 主要API：为函数列表生成API参考 *)
val generate_api_reference : function_info list -> doc_generation_config -> string

(** 创建函数信息的辅助函数 *)
val make_function_info : string -> string list -> simple_expr -> bool -> function_info

(** 简化的表达式构造器 *)
val make_literal : string -> simple_expr
val make_variable : string -> simple_expr
val make_binary : simple_expr -> string -> simple_expr -> simple_expr
val make_function_call : string -> simple_expr list -> simple_expr
val make_condition : simple_expr -> simple_expr -> simple_expr -> simple_expr
val make_match : simple_expr -> (string * simple_expr) list -> simple_expr
val make_list : simple_expr list -> simple_expr
val make_tuple : simple_expr list -> simple_expr

(** 测试函数 *)
val test_doc_generation : unit -> unit