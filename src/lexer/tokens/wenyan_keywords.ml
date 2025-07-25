(** 骆言词法分析器 - 文言风格关键字 *)

type wenyan_keyword =
  | HaveKeyword | OneKeyword | NameKeyword | SetKeyword | AlsoKeyword | ThenGetKeyword
  | CallKeyword | ValueKeyword | AsForKeyword | NumberKeyword
  | WantExecuteKeyword | MustFirstGetKeyword | ForThisKeyword | TimesKeyword | EndCloudKeyword
  | IfWenyanKeyword | ThenWenyanKeyword | GreaterThanWenyan | LessThanWenyan
  | DefineKeyword | AcceptKeyword | ReturnWhenKeyword | ElseReturnKeyword
  | MultiplyKeyword | DivideKeyword | AddToKeyword | SubtractKeyword
  | IsKeyword | EqualToKeyword | LessThanEqualToKeyword
  | FirstElementKeyword | RemainingKeyword | EmptyKeyword | CharacterCountKeyword
  | OfParticle | TopicMarker
  | InputKeyword | OutputKeyword | MinusOneKeyword | PlusKeyword | WhereKeyword
  | SmallKeyword | ShouldGetKeyword
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword
  | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword | VariantKeyword | TagKeyword
[@@deriving show, eq]

let to_string = function
  | HaveKeyword -> "吾有" | OneKeyword -> "一" | NameKeyword -> "名曰"
  | SetKeyword -> "设" | AlsoKeyword -> "也" | ThenGetKeyword -> "乃"
  | CallKeyword -> "曰" | ValueKeyword -> "其值" | AsForKeyword -> "为"
  | NumberKeyword -> "数"
  | WantExecuteKeyword -> "欲行" | MustFirstGetKeyword -> "必先得"
  | ForThisKeyword -> "為是" | TimesKeyword -> "遍" | EndCloudKeyword -> "云云"
  | IfWenyanKeyword -> "若" | ThenWenyanKeyword -> "者"
  | GreaterThanWenyan -> "大于" | LessThanWenyan -> "小于"
  | DefineKeyword -> "定义" | AcceptKeyword -> "接受"
  | ReturnWhenKeyword -> "时返回" | ElseReturnKeyword -> "否则返回"
  | MultiplyKeyword -> "乘以" | DivideKeyword -> "除以"
  | AddToKeyword -> "加上" | SubtractKeyword -> "减去"
  | IsKeyword -> "为" | EqualToKeyword -> "等于" | LessThanEqualToKeyword -> "小于等于"
  | FirstElementKeyword -> "首元素" | RemainingKeyword -> "剩余"
  | EmptyKeyword -> "空" | CharacterCountKeyword -> "字符数量"
  | OfParticle -> "之" | TopicMarker -> "者"
  | InputKeyword -> "输入" | OutputKeyword -> "输出" | MinusOneKeyword -> "减一"
  | PlusKeyword -> "加" | WhereKeyword -> "其中" | SmallKeyword -> "小"
  | ShouldGetKeyword -> "应得"
  | IntTypeKeyword -> "整数" | FloatTypeKeyword -> "浮点数"
  | StringTypeKeyword -> "字符串" | BoolTypeKeyword -> "布尔"
  | UnitTypeKeyword -> "单元" | ListTypeKeyword -> "列表"
  | ArrayTypeKeyword -> "数组" | VariantKeyword -> "变体" | TagKeyword -> "标签"

let from_string = function
  | "吾有" -> Some HaveKeyword | "一" -> Some OneKeyword | "名曰" -> Some NameKeyword
  | "设" -> Some SetKeyword | "也" -> Some AlsoKeyword | "乃" -> Some ThenGetKeyword
  | "曰" -> Some CallKeyword | "其值" -> Some ValueKeyword | "为" -> Some AsForKeyword
  | "数" -> Some NumberKeyword
  | "欲行" -> Some WantExecuteKeyword | "必先得" -> Some MustFirstGetKeyword
  | "為是" -> Some ForThisKeyword | "遍" -> Some TimesKeyword | "云云" -> Some EndCloudKeyword
  | "若" -> Some IfWenyanKeyword | "者" -> Some ThenWenyanKeyword
  | "大于" -> Some GreaterThanWenyan | "小于" -> Some LessThanWenyan
  | "定义" -> Some DefineKeyword | "接受" -> Some AcceptKeyword
  | "时返回" -> Some ReturnWhenKeyword | "否则返回" -> Some ElseReturnKeyword
  | "乘以" -> Some MultiplyKeyword | "除以" -> Some DivideKeyword
  | "加上" -> Some AddToKeyword | "减去" -> Some SubtractKeyword
  | "等于" -> Some EqualToKeyword | "小于等于" -> Some LessThanEqualToKeyword
  | "首元素" -> Some FirstElementKeyword | "剩余" -> Some RemainingKeyword
  | "空" -> Some EmptyKeyword | "字符数量" -> Some CharacterCountKeyword
  | "之" -> Some OfParticle
  | "输入" -> Some InputKeyword | "输出" -> Some OutputKeyword | "减一" -> Some MinusOneKeyword
  | "加" -> Some PlusKeyword | "其中" -> Some WhereKeyword | "小" -> Some SmallKeyword
  | "应得" -> Some ShouldGetKeyword
  | "整数" -> Some IntTypeKeyword | "浮点数" -> Some FloatTypeKeyword
  | "字符串" -> Some StringTypeKeyword | "布尔" -> Some BoolTypeKeyword
  | "单元" -> Some UnitTypeKeyword | "列表" -> Some ListTypeKeyword
  | "数组" -> Some ArrayTypeKeyword | "变体" -> Some VariantKeyword | "标签" -> Some TagKeyword
  | _ -> None

let is_basic_wenyan = function
  | HaveKeyword | OneKeyword | NameKeyword | SetKeyword | AlsoKeyword | ThenGetKeyword
  | CallKeyword | ValueKeyword | AsForKeyword | NumberKeyword -> true
  | _ -> false

let is_math_operation = function
  | MultiplyKeyword | DivideKeyword | AddToKeyword | SubtractKeyword | PlusKeyword | MinusOneKeyword -> true
  | _ -> false

let is_type_keyword = function
  | IntTypeKeyword | FloatTypeKeyword | StringTypeKeyword | BoolTypeKeyword
  | UnitTypeKeyword | ListTypeKeyword | ArrayTypeKeyword | VariantKeyword | TagKeyword -> true
  | _ -> false