(** 骆言编译器 - 统一Token类型系统
    
    将所有散布在不同模块中的Token类型定义统一到此模块，
    解决模块增殖问题，提供清晰的类型层次结构。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

(** 基础数据类型Token *)
type literal_token =
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string  (** 中文数字：一二三四五六七八九点 *)
  | StringToken of string
  | BoolToken of bool

(** 标识符Token类型 *)
type identifier_token =
  | QuotedIdentifierToken of string  (** 「标识符」- 引用标识符 *)
  | IdentifierTokenSpecial of string  (** 特殊保护标识符 *)
  | SimpleIdentifier of string  (** 简单标识符 *)

(** 核心语言关键字Token *)
type core_language_token =
  (* 基础语言构造 *)
  | LetKeyword  (** 让 - let *)
  | RecKeyword  (** 递归 - rec *)
  | InKeyword  (** 在 - in *)
  | FunKeyword  (** 函数 - fun *)
  | ParamKeyword  (** 参数 - param *)
  (* 控制流 *)
  | IfKeyword  (** 如果 - if *)
  | ThenKeyword  (** 那么 - then *)
  | ElseKeyword  (** 否则 - else *)
  | MatchKeyword  (** 匹配 - match *)
  | WithKeyword  (** 与 - with *)
  | OtherKeyword  (** 其他 - wildcard *)
  (* 类型系统 *)
  | TypeKeyword  (** 类型 - type *)
  | PrivateKeyword  (** 私有 - private *)
  | OfKeyword  (** of - 类型构造子 *)
  (* 逻辑操作 *)
  | TrueKeyword  (** 真 - true *)
  | FalseKeyword  (** 假 - false *)
  | AndKeyword  (** 并且 - and *)
  | OrKeyword  (** 或者 - or *)
  | NotKeyword  (** 非 - not *)

(** 语义增强关键字Token *)
type semantic_token =
  | AsKeyword  (** 作为 - as *)
  | CombineKeyword  (** 组合 - combine *)
  | WithOpKeyword  (** 以及 - with_op *)
  | WhenKeyword  (** 当 - when *)

(** 错误处理关键字Token *)
type error_handling_token =
  | OrElseKeyword  (** 否则返回 - or_else *)
  | WithDefaultKeyword  (** 默认为 - with_default *)
  | ExceptionKeyword  (** 异常 - exception *)
  | RaiseKeyword  (** 抛出 - raise *)
  | TryKeyword  (** 尝试 - try *)
  | CatchKeyword  (** 捕获 - catch *)
  | FinallyKeyword  (** 最终 - finally *)

(** 模块系统关键字Token *)
type module_system_token =
  | ModuleKeyword  (** 模块 - module *)
  | ModuleTypeKeyword  (** 模块类型 - module type *)
  | SigKeyword  (** 签名 - sig *)
  | EndKeyword  (** 结束 - end *)
  | FunctorKeyword  (** 函子 - functor *)
  | IncludeKeyword  (** 包含 - include *)
  | RefKeyword  (** 引用 - ref *)

(** 宏系统关键字Token *)
type macro_system_token = MacroKeyword  (** 宏 - macro *) | ExpandKeyword  (** 展开 - expand *)

(** 文言文风格关键字Token *)
type wenyan_token =
  | HaveKeyword  (** 吾有 - I have *)
  | OneKeyword  (** 一 - one *)
  | NameKeyword  (** 名曰 - name it *)
  | SetKeyword  (** 设 - set *)
  | AlsoKeyword  (** 也 - also/end particle *)
  | ThenGetKeyword  (** 乃 - then/thus *)
  | CallKeyword  (** 曰 - called/said *)
  | ValueKeyword  (** 其值 - its value *)
  | AsForKeyword  (** 为 - as for *)
  | NumberKeyword  (** 数 - number *)
  | WantExecuteKeyword  (** 欲行 - want to execute *)
  | MustFirstGetKeyword  (** 必先得 - must first get *)
  | ForThisKeyword  (** 為是 - for this *)
  | TimesKeyword  (** 遍 - times *)
  | EndCloudKeyword  (** 云云 - end marker *)
  | IfWenyanKeyword  (** 若 - if (wenyan) *)
  | ThenWenyanKeyword  (** 者 - then particle *)
  | GreaterThanWenyan  (** 大于 - greater than *)
  | LessThanWenyan  (** 小于 - less than *)

(** 古雅体关键字Token *)
type ancient_token =
  | AncientDefineKeyword  (** 夫...者 - ancient function definition *)
  | AncientEndKeyword  (** 也 - ancient end marker *)
  | AncientAlgorithmKeyword  (** 算法 - algorithm *)
  | AncientCompleteKeyword  (** 竟 - complete *)
  | AncientObserveKeyword  (** 观 - observe *)
  | AncientNatureKeyword  (** 性 - nature *)
  | AncientIfKeyword  (** 若 - if (ancient) *)
  | AncientThenKeyword  (** 则 - then (ancient) *)
  | AncientOtherwiseKeyword  (** 余者 - otherwise *)
  | AncientAnswerKeyword  (** 答 - return *)
  | AncientRecursiveKeyword  (** 递归 - recursive *)
  | AncientCombineKeyword  (** 合 - combine *)
  | AncientAsOneKeyword  (** 为一 - as one *)
  | AncientTakeKeyword  (** 取 - take *)
  | AncientReceiveKeyword  (** 受 - receive *)
  | AncientParticleOf  (** 之 - possessive *)
  | AncientParticleFun  (** 焉 - function parameter *)
  | AncientParticleThe  (** 其 - its/the *)
  | AncientCallItKeyword  (** 名曰 - call it *)
  | AncientEmptyKeyword  (** 空空如也 - empty *)
  | AncientIsKeyword  (** 乃 - is *)
  | AncientArrowKeyword  (** 故 - therefore *)
  | AncientWhenKeyword  (** 当 - when *)
  | AncientCommaKeyword  (** 且 - and *)
  | AncientPeriodKeyword  (** 也 - end particle *)
  | AfterThatKeyword  (** 而后 - after that *)

(** 自然语言函数关键字Token *)
type natural_language_token =
  | DefineKeyword  (** 定义 - define *)
  | AcceptKeyword  (** 接受 - accept *)
  | ReturnWhenKeyword  (** 时返回 - return when *)
  | ElseReturnKeyword  (** 否则返回 - else return *)
  | MultiplyKeyword  (** 乘以 - multiply *)
  | DivideKeyword  (** 除以 - divide *)
  | AddToKeyword  (** 加上 - add to *)
  | SubtractKeyword  (** 减去 - subtract *)
  | IsKeyword  (** 为 - is *)
  | EqualToKeyword  (** 等于 - equal to *)
  | LessThanEqualToKeyword  (** 小于等于 - less than or equal *)
  | FirstElementKeyword  (** 首元素 - first element *)
  | RemainingKeyword  (** 剩余 - remaining *)
  | EmptyKeyword  (** 空 - empty *)
  | CharacterCountKeyword  (** 字符数量 - character count *)
  | OfParticle  (** 之 - possessive particle *)

(** 操作符Token *)
type operator_token =
  | Plus  (** + *)
  | Minus  (** - *)
  | Multiply  (** * *)
  | Divide  (** / *)
  | Equal  (** = *)
  | NotEqual  (** <> *)
  | LessThan  (** < *)
  | LessThanOrEqual  (** <= *)
  | GreaterThan  (** > *)
  | GreaterThanOrEqual  (** >= *)
  | LogicalAnd  (** && *)
  | LogicalOr  (** || *)
  | Assignment  (** := *)
  | Arrow  (** -> *)
  | DoubleArrow  (** => *)

(** 分隔符Token *)
type delimiter_token =
  | LeftParen  (** ( *)
  | RightParen  (** ) *)
  | LeftBracket  (** [ *)
  | RightBracket  (** ] *)
  | LeftBrace  (** { *)
  | RightBrace  (** } *)
  | Semicolon  (** ; *)
  | Comma  (** , *)
  | Dot  (** . *)
  | Colon  (** : *)
  | DoubleColon  (** :: *)
  | Pipe  (** | *)
  | Underscore  (** _ *)

(** 特殊Token *)
type special_token =
  | EOF  (** 文件结束 *)
  | Newline  (** 换行符 *)
  | Whitespace of string  (** 空白字符 *)
  | Comment of string  (** 注释 *)

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

type position = { line : int; column : int; offset : int }
(** Token位置信息 *)

type positioned_token = { token : token; position : position; text : string  (** 原始文本 *) }
(** 带位置信息的Token *)

type token_stream = positioned_token list
(** Token流类型 *)

(** Token类别枚举 - 用于快速分类 *)
type token_category =
  | CategoryLiteral
  | CategoryIdentifier
  | CategoryKeyword
  | CategoryOperator
  | CategoryDelimiter
  | CategorySpecial

(** 获取Token的类别 *)
let get_token_category = function
  | Literal _ -> CategoryLiteral
  | Identifier _ -> CategoryIdentifier
  | CoreLanguage _ | Semantic _ | ErrorHandling _ | ModuleSystem _ | MacroSystem _ | Wenyan _
  | Ancient _ | NaturalLanguage _ ->
      CategoryKeyword
  | Operator _ -> CategoryOperator
  | Delimiter _ -> CategoryDelimiter
  | Special _ -> CategorySpecial

type precedence = int
(** Token优先级定义 - 用于解析器 *)

let get_operator_precedence = function
  | Operator LogicalOr -> 1
  | Operator LogicalAnd -> 2
  | Operator Equal | Operator NotEqual -> 3
  | Operator LessThan
  | Operator LessThanOrEqual
  | Operator GreaterThan
  | Operator GreaterThanOrEqual ->
      4
  | Operator Plus | Operator Minus -> 5
  | Operator Multiply | Operator Divide -> 6
  | _ -> 0

(** Token关联性 *)
type associativity = LeftAssoc | RightAssoc | NonAssoc

let get_operator_associativity = function
  | Operator (Plus | Minus | Multiply | Divide) -> LeftAssoc
  | Operator Arrow -> RightAssoc
  | Operator (Equal | NotEqual | LessThan | LessThanOrEqual | GreaterThan | GreaterThanOrEqual) ->
      NonAssoc
  | _ -> LeftAssoc
