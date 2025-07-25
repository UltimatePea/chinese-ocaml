(** 骆言词法分析器 - 分隔符Token *)

(** 分隔符token，包括括号、方括号、大括号和其他标点符号 *)
type delimiter_token =
  (* 圆括号 *)
  | LeftParen  (** ( *)
  | RightParen  (** ) *)
  (* 方括号 *)
  | LeftBracket  (** [ *)
  | RightBracket  (** ] *)
  (* 大括号 *)
  | LeftBrace  (** { *)
  | RightBrace  (** } *)
  (* 数组括号 *)
  | LeftArray  (** [| *)
  | RightArray  (** |] *)
  (* 引号 *)
  | LeftQuote  (** 「 *)
  | RightQuote  (** 」 *)
  (* 标点符号 *)
  | Comma  (** , *)
  | Semicolon  (** ; *)
  | Colon  (** : *)
  | Pipe  (** | *)
  | Underscore  (** _ *)
  (* 特殊 *)
  | Newline
  | EOF
[@@deriving show, eq]

val to_string : delimiter_token -> string
(** 将分隔符token转换为字符串表示 *)

val from_string : string -> delimiter_token option
(** 将字符串转换为分隔符token（如果匹配） *)

val is_left_delimiter : delimiter_token -> bool
(** 检查是否为左括号类型 *)

val is_right_delimiter : delimiter_token -> bool
(** 检查是否为右括号类型 *)

val is_bracket_pair : delimiter_token -> bool
(** 检查是否为配对的括号类型 *)

val get_matching_bracket : delimiter_token -> delimiter_token option
(** 获取配对的括号（如果存在） *)

val is_punctuation : delimiter_token -> bool
(** 检查是否为标点符号 *)
