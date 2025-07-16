(** 自然语言处理模块接口 - Natural Language Processing Module Interface *)

(** 中文词汇类型 *)
type word_type =
  | Verb of string (* 动词 *)
  | Noun of string (* 名词 *)
  | Adjective of string (* 形容词 *)
  | Number of int (* 数字 *)
  | Keyword of string (* 关键字 *)
  | Identifier of string (* 标识符 *)
  | Unknown of string (* 未知词汇 *)

(** 语义角色 *)
type semantic_role =
  | Agent (* 施事者 *)
  | Patient (* 受事者 *)
  | Instrument (* 工具 *)
  | Location (* 位置 *)
  | Time (* 时间 *)
  | Manner (* 方式 *)
  | Purpose (* 目的 *)

type semantic_unit = {
  text : string; (* 原始文本 *)
  word_type : word_type; (* 词汇类型 *)
  role : semantic_role option; (* 语义角色 *)
  confidence : float; (* 置信度 *)
}
(** 语义单元 *)

(** 意图类型 *)
type programming_intent =
  | DefineFunction of string * string list (* 定义函数：名称，参数 *)
  | ProcessData of string * string (* 处理数据：数据类型，操作 *)
  | ControlFlow of string (* 控制流：类型 *)
  | Calculate of string (* 计算：表达式 *)
  | Transform of string * string (* 变换：源，目标 *)
  | Query of string (* 查询：对象 *)

val segment_chinese : string -> string list
(** 简化的中文分词 *)

val analyze_word : string -> word_type
(** 词汇分析 *)

val extract_semantic_units : string -> semantic_unit list
(** 提取语义单元 *)

val identify_intent : semantic_unit list -> programming_intent
(** 识别编程意图 *)

val generate_code_suggestions : programming_intent -> string list
(** 生成代码建议 *)

val natural_language_to_code : string -> string list
(** 自然语言到代码的转换 *)

val code_to_natural_language : string -> string
(** 代码到自然语言的转换 *)

val extract_key_information : string -> (string * string) list
(** 提取关键信息 *)

val suggest_corrections : string -> string -> string list
(** 智能错误建议 *)
