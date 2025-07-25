(** 骆言编译器 - 统一Token类型系统接口
    
    提供所有Token类型定义和相关操作的统一接口。
    这是Token系统的核心模块，所有其他Token相关模块都应该依赖此模块。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

(** {1 基础类型定义} *)

(** 基础数据类型Token *)
type literal_token =
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string
  | StringToken of string
  | BoolToken of bool

(** 标识符Token类型 *)
type identifier_token =
  | QuotedIdentifierToken of string
  | IdentifierTokenSpecial of string
  | SimpleIdentifier of string

(** 核心语言关键字Token *)
type core_language_token =
  | LetKeyword | RecKeyword | InKeyword | FunKeyword | ParamKeyword
  | IfKeyword | ThenKeyword | ElseKeyword | MatchKeyword | WithKeyword | OtherKeyword
  | TypeKeyword | PrivateKeyword | OfKeyword
  | TrueKeyword | FalseKeyword | AndKeyword | OrKeyword | NotKeyword

(** 语义增强关键字Token *)
type semantic_token =
  | AsKeyword | CombineKeyword | WithOpKeyword | WhenKeyword

(** 错误处理关键字Token *)
type error_handling_token =
  | OrElseKeyword | WithDefaultKeyword
  | ExceptionKeyword | RaiseKeyword | TryKeyword | CatchKeyword | FinallyKeyword

(** 模块系统关键字Token *)
type module_system_token =
  | ModuleKeyword | ModuleTypeKeyword | SigKeyword | EndKeyword
  | FunctorKeyword | IncludeKeyword | RefKeyword

(** 宏系统关键字Token *)
type macro_system_token =
  | MacroKeyword | ExpandKeyword

(** 文言文风格关键字Token *)
type wenyan_token =
  | HaveKeyword | OneKeyword | NameKeyword | SetKeyword | AlsoKeyword
  | ThenGetKeyword | CallKeyword | ValueKeyword | AsForKeyword | NumberKeyword
  | WantExecuteKeyword | MustFirstGetKeyword | ForThisKeyword | TimesKeyword
  | EndCloudKeyword | IfWenyanKeyword | ThenWenyanKeyword
  | GreaterThanWenyan | LessThanWenyan

(** 古雅体关键字Token *)
type ancient_token =
  | AncientDefineKeyword | AncientEndKeyword | AncientAlgorithmKeyword
  | AncientCompleteKeyword | AncientObserveKeyword | AncientNatureKeyword
  | AncientIfKeyword | AncientThenKeyword | AncientOtherwiseKeyword
  | AncientAnswerKeyword | AncientRecursiveKeyword | AncientCombineKeyword
  | AncientAsOneKeyword | AncientTakeKeyword | AncientReceiveKeyword
  | AncientParticleOf | AncientParticleFun | AncientParticleThe
  | AncientCallItKeyword | AncientEmptyKeyword | AncientIsKeyword
  | AncientArrowKeyword | AncientWhenKeyword | AncientCommaKeyword
  | AncientPeriodKeyword | AfterThatKeyword

(** 自然语言函数关键字Token *)
type natural_language_token =
  | DefineKeyword | AcceptKeyword | ReturnWhenKeyword | ElseReturnKeyword
  | MultiplyKeyword | DivideKeyword | AddToKeyword | SubtractKeyword
  | IsKeyword | EqualToKeyword | LessThanEqualToKeyword
  | FirstElementKeyword | RemainingKeyword | EmptyKeyword
  | CharacterCountKeyword | OfParticle

(** 操作符Token *)
type operator_token =
  | Plus | Minus | Multiply | Divide
  | Equal | NotEqual | LessThan | LessThanOrEqual | GreaterThan | GreaterThanOrEqual
  | LogicalAnd | LogicalOr | Assignment | Arrow | DoubleArrow

(** 分隔符Token *)
type delimiter_token =
  | LeftParen | RightParen | LeftBracket | RightBracket | LeftBrace | RightBrace
  | Semicolon | Comma | Dot | Colon | DoubleColon | Pipe | Underscore

(** 特殊Token *)
type special_token =
  | EOF | Newline | Whitespace of string | Comment of string

(** {1 统一Token系统} *)

(** 统一Token类型 - 所有Token的总和类型 *)
type token =
  | Literal of literal_token
  | Identifier of identifier_token
  | CoreLanguage of core_language_token
  | Semantic of semantic_token
  | ErrorHandling of error_handling_token
  | ModuleSystem of module_system_token
  | MacroSystem of macro_system_token
  | Wenyan of wenyan_token
  | Ancient of ancient_token
  | NaturalLanguage of natural_language_token
  | Operator of operator_token
  | Delimiter of delimiter_token
  | Special of special_token

(** {1 位置和元数据} *)

(** Token位置信息 *)
type position = {
  line : int;
  column : int;
  offset : int;
}

(** 带位置信息的Token *)
type positioned_token = {
  token : token;
  position : position;
  text : string;
}

(** Token流类型 *)
type token_stream = positioned_token list

(** {1 Token分类和属性} *)

(** Token类别枚举 *)
type token_category =
  | CategoryLiteral
  | CategoryIdentifier
  | CategoryKeyword
  | CategoryOperator
  | CategoryDelimiter
  | CategorySpecial

(** 获取Token的类别
    @param token 要分类的token
    @return token的类别 *)
val get_token_category : token -> token_category

(** {1 操作符属性} *)

(** Token优先级 *)
type precedence = int

(** 获取操作符的优先级
    @param token 操作符token
    @return 优先级数值，数值越大优先级越高 *)
val get_operator_precedence : token -> precedence

(** Token关联性 *)
type associativity = LeftAssoc | RightAssoc | NonAssoc

(** 获取操作符的关联性
    @param token 操作符token
    @return 关联性类型 *)
val get_operator_associativity : token -> associativity