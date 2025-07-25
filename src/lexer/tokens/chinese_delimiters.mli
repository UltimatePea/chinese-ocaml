(** 骆言词法分析器 - 中文标点符号Token *)

(** 中文标点符号token，支持中文编程的标点符号体系 *)
type chinese_delimiter =
  (* 中文圆括号 *)
  | ChineseLeftParen  (** （ *)
  | ChineseRightParen  (** ） *)
  (* 中文方括号 *)
  | ChineseLeftBracket  (** 「 - 用于列表 *)
  | ChineseRightBracket  (** 」 - 用于列表 *)
  | ChineseSquareLeftBracket  (** 【 - 方形左括号 *)
  | ChineseSquareRightBracket  (** 】 - 方形右括号 *)
  (* 中文数组括号 *)
  | ChineseLeftArray  (** 「| *)
  | ChineseRightArray  (** |」 *)
  (* 中文标点符号 *)
  | ChineseComma  (** ， *)
  | ChineseSemicolon  (** ； *)
  | ChineseColon  (** ： *)
  | ChineseDoubleColon  (** ：： - 类型注解 *)
  | ChinesePipe  (** ｜ *)
  (* 中文箭头 *)
  | ChineseArrow  (** → *)
  | ChineseDoubleArrow  (** ⇒ *)
  | ChineseAssignArrow  (** ← *)
[@@deriving show, eq]

val to_string : chinese_delimiter -> string
(** 将中文分隔符token转换为字符串表示 *)

val from_string : string -> chinese_delimiter option
(** 将字符串转换为中文分隔符token（如果匹配） *)

val is_chinese_left_delimiter : chinese_delimiter -> bool
(** 检查是否为中文左括号类型 *)

val is_chinese_right_delimiter : chinese_delimiter -> bool
(** 检查是否为中文右括号类型 *)

val is_chinese_bracket_pair : chinese_delimiter -> bool
(** 检查是否为中文配对括号类型 *)

val get_matching_chinese_bracket : chinese_delimiter -> chinese_delimiter option
(** 获取配对的中文括号（如果存在） *)

val is_chinese_punctuation : chinese_delimiter -> bool
(** 检查是否为中文标点符号 *)

val is_chinese_arrow : chinese_delimiter -> bool
(** 检查是否为中文箭头符号 *)
