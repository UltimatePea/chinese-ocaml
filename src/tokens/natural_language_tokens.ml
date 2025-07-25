(** 骆言词法分析器 - 自然语言风格令牌类型定义 *)

(** 自然语言函数定义关键字 *)
type natural_function_keyword =
  | DefineKeyword (* 定义 - define *)
  | AcceptKeyword (* 接受 - accept *)
  | ReturnWhenKeyword (* 时返回 - return when *)
  | ElseReturnKeyword (* 否则返回 - else return *)
  | InputKeyword (* 输入 - input *)
  | OutputKeyword (* 输出 - output *)
[@@deriving show, eq]

(** 自然语言运算关键字 *)
type natural_arithmetic_keyword =
  | MultiplyKeyword (* 乘以 - multiply *)
  | DivideKeyword (* 除以 - divide *)
  | AddToKeyword (* 加上 - add to *)
  | SubtractKeyword (* 减去 - subtract *)
  | MinusOneKeyword (* 减一 - minus one *)
  | PlusKeyword (* 加 - plus *)
[@@deriving show, eq]

(** 自然语言比较关键字 *)
type natural_comparison_keyword =
  | IsKeyword (* 为 - is *)
  | EqualToKeyword (* 等于 - equal to *)
  | LessThanEqualToKeyword (* 小于等于 - less than or equal to *)
[@@deriving show, eq]

(** 自然语言数据结构关键字 *)
type natural_data_keyword =
  | FirstElementKeyword (* 首元素 - first element *)
  | RemainingKeyword (* 剩余 - remaining *)
  | EmptyKeyword (* 空 - empty *)
  | CharacterCountKeyword (* 字符数量 - character count *)
[@@deriving show, eq]

(** 自然语言语助词 *)
type natural_particle =
  | OfParticle (* 之 - possessive particle *)
  | TopicMarker (* 者 - topic marker *)
  | WhereKeyword (* 其中 - where *)
  | SmallKeyword (* 小 - small *)
  | ShouldGetKeyword (* 应得 - should get *)
[@@deriving show, eq]

(** 统一自然语言令牌类型 *)
type natural_language_token =
  | Function of natural_function_keyword
  | Arithmetic of natural_arithmetic_keyword
  | Comparison of natural_comparison_keyword
  | Data of natural_data_keyword
  | Particle of natural_particle
[@@deriving show, eq]

(** 自然语言令牌转换为字符串 *)
let natural_language_token_to_string = function
  | Function fk -> (match fk with
    | DefineKeyword -> "定义"
    | AcceptKeyword -> "接受"
    | ReturnWhenKeyword -> "时返回"
    | ElseReturnKeyword -> "否则返回"
    | InputKeyword -> "输入"
    | OutputKeyword -> "输出")
  | Arithmetic ak -> (match ak with
    | MultiplyKeyword -> "乘以"
    | DivideKeyword -> "除以"
    | AddToKeyword -> "加上"
    | SubtractKeyword -> "减去"
    | MinusOneKeyword -> "减一"
    | PlusKeyword -> "加")
  | Comparison ck -> (match ck with
    | IsKeyword -> "为"
    | EqualToKeyword -> "等于"
    | LessThanEqualToKeyword -> "小于等于")
  | Data dk -> (match dk with
    | FirstElementKeyword -> "首元素"
    | RemainingKeyword -> "剩余"
    | EmptyKeyword -> "空"
    | CharacterCountKeyword -> "字符数量")
  | Particle pk -> (match pk with
    | OfParticle -> "之"
    | TopicMarker -> "者"
    | WhereKeyword -> "其中"
    | SmallKeyword -> "小"
    | ShouldGetKeyword -> "应得")

(** 判断是否为自然语言函数相关 *)
let is_function_related = function
  | Function _ -> true
  | _ -> false

(** 判断是否为自然语言运算相关 *)
let is_arithmetic_related = function
  | Arithmetic _ -> true
  | _ -> false