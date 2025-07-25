(** 骆言词法分析器 - 自然语言风格令牌类型定义接口 *)

(** 自然语言函数定义关键字 *)
type natural_function_keyword =
  | DefineKeyword
  | AcceptKeyword
  | ReturnWhenKeyword
  | ElseReturnKeyword
  | InputKeyword
  | OutputKeyword
[@@deriving show, eq]

(** 自然语言运算关键字 *)
type natural_arithmetic_keyword =
  | MultiplyKeyword
  | DivideKeyword
  | AddToKeyword
  | SubtractKeyword
  | MinusOneKeyword
  | PlusKeyword
[@@deriving show, eq]

(** 自然语言比较关键字 *)
type natural_comparison_keyword = IsKeyword | EqualToKeyword | LessThanEqualToKeyword
[@@deriving show, eq]

(** 自然语言数据结构关键字 *)
type natural_data_keyword =
  | FirstElementKeyword
  | RemainingKeyword
  | EmptyKeyword
  | CharacterCountKeyword
[@@deriving show, eq]

(** 自然语言语助词 *)
type natural_particle = OfParticle | TopicMarker | WhereKeyword | SmallKeyword | ShouldGetKeyword
[@@deriving show, eq]

(** 统一自然语言令牌类型 *)
type natural_language_token =
  | Function of natural_function_keyword
  | Arithmetic of natural_arithmetic_keyword
  | Comparison of natural_comparison_keyword
  | Data of natural_data_keyword
  | Particle of natural_particle
[@@deriving show, eq]

val natural_language_token_to_string : natural_language_token -> string
(** 自然语言令牌转换为字符串 *)

val is_function_related : natural_language_token -> bool
(** 判断是否为自然语言函数相关 *)

val is_arithmetic_related : natural_language_token -> bool
(** 判断是否为自然语言运算相关 *)
