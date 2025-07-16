(** 智能编程意图解析器接口 - Intelligent Programming Intent Parser Interface *)

(** 编程意图类型定义 *)
type intent =
  | CreateFunction of string * string list * intent (* 创建函数：名称，参数，函数体意图 *)
  | ProcessList of string * intent (* 列表处理：操作类型，操作意图 *)
  | Calculate of string (* 计算表达式：计算描述 *)
  | Pattern of string (* 模式匹配：模式类型 *)
  | Sort of string (* 排序：排序方式 *)
  | Filter of string (* 过滤：过滤条件 *)
  | Map of string (* 映射：映射操作 *)
  | Reduce of string (* 归约：归约操作 *)
  | Unknown of string (* 未知意图 *)

type template = {
  name : string; (* 模板名称 *)
  parameters : string list; (* 参数列表 *)
  body : string; (* 代码模板 *)
  description : string; (* 描述 *)
  category : string; (* 分类 *)
}
(** 代码模板定义 *)

type suggestion = {
  code : string; (* 生成的代码 *)
  confidence : float; (* 置信度 0.0-1.0 *)
  description : string; (* 建议描述 *)
  category : string; (* 建议分类 *)
  intent : intent; (* 识别的意图 *)
}
(** 补全建议 *)

val parse_intent : string -> intent
(** 解析中文意图文本 *)

val generate_suggestions : intent -> suggestion list
(** 根据意图生成代码建议 *)

val intelligent_completion : string -> suggestion list
(** 智能代码补全主函数 *)

val format_suggestion : suggestion -> string
(** 格式化建议输出 *)

val format_suggestions : suggestion list -> string
(** 批量格式化建议 *)

val function_keywords : (string * string) list
(** 函数关键词映射表 *)

val operation_keywords : (string * string) list
(** 操作关键词映射表 *)

