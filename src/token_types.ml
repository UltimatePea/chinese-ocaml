(** 骆言词法分析器Token类型模块 - 按功能域分类管理 *)

(** 操作符类型Token *)
module Operators = struct
  type operator_token =
    (* 算术操作符 *)
    | Plus (* + *)
    | Minus (* - *)
    | Multiply (* * *)
    | Divide (* / *)
    | Modulo (* % *)
    | Power (* ** *)
    (* 比较操作符 *)
    | Equal (* = *)
    | NotEqual (* <> *)
    | LessThan (* < *)
    | LessEqual (* <= *)
    | GreaterThan (* > *)
    | GreaterEqual (* >= *)
    (* 逻辑操作符 *)
    | LogicalAnd (* && *)
    | LogicalOr (* || *)
    | LogicalNot (* not *)
    (* 位操作符 *)
    | BitwiseAnd (* land *)
    | BitwiseOr (* lor *)
    | BitwiseXor (* lxor *)
    | BitwiseNot (* lnot *)
    | ShiftLeft (* lsl *)
    | ShiftRight (* lsr *)
    | ArithShiftRight (* asr *)
    (* 赋值和引用 *)
    | Assign (* := *)
    | Dereference (* ! *)
    | Reference (* ref *)
    (* 函数组合 *)
    | Compose (* >> *)
    | PipeForward (* |> *)
    | PipeBackward (* <| *)
    (* 其他操作符 *)
    | Arrow (* -> *)
    | DoubleArrow (* => *)
    | DoubleDot (* .. *)
    | TripleDot (* ... *)
    | Bang (* ! *)
    | RefAssign (* := *)
  [@@deriving show, eq]
end

(** 关键字类型Token *)
module Keywords = struct
  type keyword_token =
    (* 基础关键字 *)
    | LetKeyword (* 让 - let *)
    | RecKeyword (* 递归 - rec *)
    | InKeyword (* 在 - in *)
    | FunKeyword (* 函数 - fun *)
    | IfKeyword (* 如果 - if *)
    | ThenKeyword (* 那么 - then *)
    | ElseKeyword (* 否则 - else *)
    | MatchKeyword (* 匹配 - match *)
    | WithKeyword (* 与 - with *)
    | OtherKeyword (* 其他 - other/wildcard *)
    | TypeKeyword (* 类型 - type *)
    | PrivateKeyword (* 私有 - private *)
    | TrueKeyword (* 真 - true *)
    | FalseKeyword (* 假 - false *)
    | AndKeyword (* 并且 - and *)
    | OrKeyword (* 或者 - or *)
    | NotKeyword (* 非 - not *)
    (* 语义类型系统关键字 *)
    | AsKeyword (* 作为 - as *)
    | CombineKeyword (* 组合 - combine *)
    | WithOpKeyword (* 以及 - with_op *)
    | WhenKeyword (* 当 - when *)
    (* 错误恢复关键字 *)
    | OrElseKeyword (* 否则返回 - or_else *)
    | WithDefaultKeyword (* 默认为 - with_default *)
    (* 异常处理关键字 *)
    | ExceptionKeyword (* 异常 - exception *)
    | RaiseKeyword (* 抛出 - raise *)
    | TryKeyword (* 尝试 - try *)
    | CatchKeyword (* 捕获 - catch/with *)
    | FinallyKeyword (* 最终 - finally *)
    (* 类型关键字 *)
    | OfKeyword (* of - for type constructors *)
    (* 模块系统关键字 *)
    | ModuleKeyword (* 模块 - module *)
    | ModuleTypeKeyword (* 模块类型 - module type *)
    | OpenKeyword (* 打开 - open *)
    | IncludeKeyword (* 包含 - include *)
    | SigKeyword (* 签名 - sig *)
    | StructKeyword (* 结构 - struct *)
    | EndKeyword (* 结束 - end *)
    | FunctorKeyword (* 函子 - functor *)
    | ValKeyword (* 值 - val *)
    | ExternalKeyword (* 外部 - external *)
    (* 古雅体增强关键字 *)
    | BeginKeyword (* 起 - begin (古雅体) *)
    | FinishKeyword (* 终 - end/finish (古雅体) *)
    | DefinedKeyword (* 定义为 - 自然语言函数定义 *)
    | DefinedAsKeyword (* 定义为 - 自然语言函数定义的别名 *)
    | ReturnKeyword (* 返回 - return (函数) *)
    | ResultKeyword (* 结果 - result (函数) *)
    | CallKeyword (* 调用 - call *)
    | InvokeKeyword (* 执行 - invoke *)
    | ApplyKeyword (* 应用 - apply *)
    (* wenyan风格关键字 *)
    | WenyanNow (* 今 - 当前作用域 *)
    | WenyanHave (* 有 - 存在 *)
    | WenyanIs (* 是 - 等于 *)
    | WenyanNot (* 非 - 否定 *)
    | WenyanAll (* 凡 - 全部 *)
    | WenyanSome (* 或 - 部分 *)
    | WenyanFor (* 为 - for循环 *)
    | WenyanWhile (* 当...时 - while循环 *)
    | WenyanIf (* 若 - if条件 *)
    | WenyanThen (* 则 - then结果 *)
    | WenyanElse (* 不然 - else分支 *)
    (* 古文关键字 *)
    | ClassicalLet (* 设 - 古文let *)
    | ClassicalIn (* 于 - 古文in *)
    | ClassicalBe (* 曰 - 古文赋值/定义 *)
    | ClassicalDo (* 行 - 古文执行 *)
    | ClassicalEnd (* 毕 - 古文结束 *)
    | ClassicalReturn (* 得 - 古文返回 *)
    | ClassicalCall (* 用 - 古文调用 *)
    | ClassicalDefine (* 制 - 古文定义 *)
    | ClassicalCreate (* 造 - 古文创建 *)
    | ClassicalDestroy (* 灭 - 古文销毁 *)
    | ClassicalTransform (* 化 - 古文转换 *)
    | ClassicalCombine (* 合 - 古文组合 *)
    | ClassicalSeparate (* 分 - 古文分离 *)
    (* 诗词语法关键字 *)
    | PoetryStart (* 诗起 - 诗词模式开始 *)
    | PoetryEnd (* 诗终 - 诗词模式结束 *)
    | VerseStart (* 句起 - 诗句开始 *)
    | VerseEnd (* 句终 - 诗句结束 *)
    | RhymePattern (* 韵律 - 韵律模式 *)
    | TonePattern (* 平仄 - 平仄模式 *)
    | ParallelStart (* 对起 - 对仗开始 *)
    | ParallelEnd (* 对终 - 对仗结束 *)
  [@@deriving show, eq]
end

(** 字面量类型Token *)
module Literals = struct
  type literal_token =
    (* 数值字面量 *)
    | IntToken of int
    | FloatToken of float
    | ChineseNumberToken of string (* 中文数字：一二三四五六七八九点 *)
    (* 文本字面量 *)
    | StringToken of string
    | CharToken of char
    (* 布尔字面量 *)
    | BoolToken of bool
    (* 特殊字面量 *)
    | UnitToken (* () *)
    | NullToken (* null/空 *)
  [@@deriving show, eq]
end

(** 标识符类型Token *)
module Identifiers = struct
  type identifier_token =
    | QuotedIdentifierToken of string (* 「标识符」 - 所有标识符必须引用 *)
    | IdentifierTokenSpecial of string (* 特殊保护的标识符，如"数值" *)
    | ConstructorToken of string (* 构造函数标识符 *)
    | ModuleIdToken of string (* 模块标识符 *)
    | TypeIdToken of string (* 类型标识符 *)
    | LabelToken of string (* 标签参数标识符 *)
  [@@deriving show, eq]
end

(** 分隔符类型Token *)
module Delimiters = struct
  type delimiter_token =
    (* ASCII分隔符 *)
    | LeftParen (* ( *)
    | RightParen (* ) *)
    | LeftBracket (* [ *)
    | RightBracket (* ] *)
    | LeftBrace (* { *)
    | RightBrace (* } *)
    | Comma (* , *)
    | Semicolon (* ; *)
    | Colon (* : *)
    | QuestionMark (* ? *)
    | Tilde (* ~ *)
    | Pipe (* | *)
    | Underscore (* _ *)
    | LeftArray (* [| *)
    | RightArray (* |] *)
    | AssignArrow (* <- *)
    | LeftQuote (* 「 *)
    | RightQuote (* 」 *)
    (* 中文分隔符 *)
    | ChineseLeftParen (* （ *)
    | ChineseRightParen (* ） *)
    | ChineseLeftBracket (* 「 - 用于列表 *)
    | ChineseRightBracket (* 」 - 用于列表 *)
    | ChineseComma (* ， *)
    | ChineseSemicolon (* ； *)
    | ChineseColon (* ： *)
    | ChineseDoubleColon (* ：： - 类型注解 *)
    | ChinesePipe (* ｜ *)
    | ChineseLeftArray (* 「| *)
    | ChineseRightArray (* |」 *)
    | ChineseArrow (* → *)
    | ChineseDoubleArrow (* ⇒ *)
    | ChineseAssignArrow (* ← *)
  [@@deriving show, eq]
end

(** 特殊Token *)
module Special = struct
  type special_token =
    | Newline
    | EOF
    | Comment of string
    | ChineseComment of string
    | Whitespace of string
  [@@deriving show, eq]
end

(** 统一的Token类型 - 将所有类型组合 *)
type token =
  | OperatorToken of Operators.operator_token
  | KeywordToken of Keywords.keyword_token
  | LiteralToken of Literals.literal_token
  | IdentifierToken of Identifiers.identifier_token
  | DelimiterToken of Delimiters.delimiter_token
  | SpecialToken of Special.special_token
[@@deriving show, eq]

type position = { line : int; column : int; filename : string } [@@deriving show, eq]
(** 位置信息 *)

type positioned_token = token * position [@@deriving show, eq]
(** 带位置的词元 *)

(** Token分类辅助函数 *)
module TokenUtils = struct
  let is_operator = function OperatorToken _ -> true | _ -> false
  let is_keyword = function KeywordToken _ -> true | _ -> false
  let is_literal = function LiteralToken _ -> true | _ -> false
  let is_identifier = function IdentifierToken _ -> true | _ -> false
  let is_delimiter = function DelimiterToken _ -> true | _ -> false
  let is_special = function SpecialToken _ -> true | _ -> false
  let is_eof = function SpecialToken Special.EOF -> true | _ -> false
  let is_newline = function SpecialToken Special.Newline -> true | _ -> false

  (** 获取Token的字符串表示 *)
  let token_to_string = function
    | OperatorToken op -> Operators.show_operator_token op
    | KeywordToken kw -> Keywords.show_keyword_token kw
    | LiteralToken lit -> Literals.show_literal_token lit
    | IdentifierToken id -> Identifiers.show_identifier_token id
    | DelimiterToken del -> Delimiters.show_delimiter_token del
    | SpecialToken sp -> Special.show_special_token sp
end
