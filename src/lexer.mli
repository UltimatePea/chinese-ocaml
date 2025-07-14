(** 骆言词法分析器接口 - Chinese Programming Language Lexer Interface *)

(** 词元类型 *)
type token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  
  (* 标识符 *)
  | IdentifierToken of string
  | QuotedIdentifierToken of string   (* 「标识符」 *)
  | IdentifierTokenSpecial of string  (* 特殊保护的标识符，如"数值" *)
  
  (* 关键字 *)
  | LetKeyword                  (* 让 - let *)
  | RecKeyword                  (* 递归 - rec *)
  | InKeyword                   (* 在 - in *)
  | FunKeyword                  (* 函数 - fun *)
  | IfKeyword                   (* 如果 - if *)
  | ThenKeyword                 (* 那么 - then *)
  | ElseKeyword                 (* 否则 - else *)
  | MatchKeyword                (* 匹配 - match *)
  | WithKeyword                 (* 与 - with *)
  | OtherKeyword                (* 其他 - other/wildcard *)
  | TypeKeyword                 (* 类型 - type *)
  | TrueKeyword                 (* 真 - true *)
  | FalseKeyword                (* 假 - false *)
  | AndKeyword                  (* 并且 - and *)
  | OrKeyword                   (* 或者 - or *)
  | NotKeyword                  (* 非 - not *)
  
  (* 语义类型系统关键字 *)
  | AsKeyword                   (* 作为 - as *)
  | CombineKeyword              (* 组合 - combine *)
  | WithOpKeyword               (* 以及 - with_op *)
  | WhenKeyword                 (* 当 - when *)
  
  (* 错误恢复关键字 *)
  | OrElseKeyword               (* 否则返回 - or_else *)
  | WithDefaultKeyword          (* 默认为 - with_default *)
  
  (* 异常处理关键字 *)
  | ExceptionKeyword            (* 异常 - exception *)
  | RaiseKeyword                (* 抛出 - raise *)
  | TryKeyword                  (* 尝试 - try *)
  | CatchKeyword                (* 捕获 - catch/with *)
  | FinallyKeyword              (* 最终 - finally *)
  
  (* 类型关键字 *)
  | OfKeyword                   (* of - for type constructors *)
  
  (* 模块系统关键字 *)
  | ModuleKeyword               (* 模块 - module *)
  | ModuleTypeKeyword           (* 模块类型 - module type *)
  | SigKeyword                  (* 签名 - sig *)
  | EndKeyword                  (* 结束 - end *)
  | FunctorKeyword              (* 函子 - functor *)
  
  (* 可变性关键字 *)
  | RefKeyword                  (* 引用 - ref *)

  (* 新增模块系统关键字 *)
  | IncludeKeyword              (* 包含 - include *)
  
  (* 宏系统关键字 *)
  | MacroKeyword                (* 宏 - macro *)
  | ExpandKeyword               (* 展开 - expand *)
  
  (* wenyan风格关键字 *)
  | HaveKeyword                 (* 吾有 - I have *)
  | OneKeyword                  (* 一 - one *)
  | NameKeyword                 (* 名曰 - name it *)
  | SetKeyword                  (* 设 - set *)
  | AlsoKeyword                 (* 也 - also/end particle *)
  | ThenGetKeyword              (* 乃 - then/thus *)
  | CallKeyword                 (* 曰 - called/said *)
  | ValueKeyword                (* 其值 - its value *)
  | AsForKeyword                (* 为 - as for/regarding *)
  | NumberKeyword               (* 数 - number *)
  
  (* wenyan扩展关键字 *)
  | WantExecuteKeyword          (* 欲行 - want to execute *)
  | MustFirstGetKeyword         (* 必先得 - must first get *)
  | ForThisKeyword              (* 為是 - for this *)
  | TimesKeyword                (* 遍 - times/iterations *)
  | EndCloudKeyword             (* 云云 - end marker *)
  | IfWenyanKeyword             (* 若 - if (wenyan style) *)
  | ThenWenyanKeyword           (* 者 - then particle *)
  | GreaterThanWenyan           (* 大于 - greater than *)
  | LessThanWenyan              (* 小于 - less than *)
  
  (* 古雅体关键字 - Ancient Chinese Literary Style *)
  | AncientDefineKeyword        (* 夫...者 - ancient function definition *)
  | AncientEndKeyword           (* 是谓 - ancient end marker *)
  | AncientAlgorithmKeyword     (* 算法 - algorithm *)
  | AncientCompleteKeyword      (* 竟 - complete/finish *)
  | AncientObserveKeyword       (* 观 - observe/examine *)
  | AncientNatureKeyword        (* 性 - nature/essence *)
  | AncientIfKeyword            (* 若 - if (ancient style) *)
  | AncientThenKeyword          (* 则 - then (ancient) *)
  | AncientOtherwiseKeyword     (* 余者 - otherwise/others *)
  | AncientAnswerKeyword        (* 答 - answer/return *)
  | AncientRecursiveKeyword     (* 递归 - recursive (ancient) *)
  | AncientCombineKeyword       (* 合 - combine *)
  | AncientAsOneKeyword         (* 为一 - as one *)
  | AncientTakeKeyword          (* 取 - take/get *)
  | AncientReceiveKeyword       (* 受 - receive *)
  | AncientParticleOf           (* 之 - possessive particle *)
  | AncientParticleFun          (* 焉 - function parameter particle *)
  | AncientParticleThe          (* 其 - its/the *)
  | AncientCallItKeyword        (* 名曰 - call it *)
  | AncientListStartKeyword     (* 列开始 - list start *)
  | AncientListEndKeyword       (* 列结束 - list end *)
  | AncientItsFirstKeyword      (* 其一 - its first *)
  | AncientItsSecondKeyword     (* 其二 - its second *)
  | AncientItsThirdKeyword      (* 其三 - its third *)
  | AncientEmptyKeyword         (* 空空如也 - empty as void *)
  | AncientHasHeadTailKeyword   (* 有首有尾 - has head and tail *)
  | AncientHeadNameKeyword      (* 首名为 - head named as *)
  | AncientTailNameKeyword      (* 尾名为 - tail named as *)
  | AncientThusAnswerKeyword    (* 则答 - thus answer *)
  | AncientAddToKeyword         (* 并加 - and add *)
  | AncientObserveEndKeyword    (* 观察毕 - observation complete *)
  | AncientBeginKeyword         (* 始 - begin *)
  | AncientEndCompleteKeyword   (* 毕 - complete *)
  | AncientIsKeyword            (* 乃 - is/thus *)
  | AncientArrowKeyword         (* 故 - therefore/thus *)
  | AncientWhenKeyword          (* 当 - when *)
  | AncientCommaKeyword         (* 且 - and/also *)
  | AncientPeriodKeyword        (* 也 - particle for end of statement *)
  | AfterThatKeyword            (* 而后 - after that/then *)
  
  (* 自然语言函数定义关键字 *)
  | DefineKeyword               (* 定义 - define *)
  | AcceptKeyword               (* 接受 - accept *)
  | ReturnWhenKeyword           (* 时返回 - return when *)
  | ElseReturnKeyword           (* 否则返回 - else return *)
  | MultiplyKeyword             (* 乘以 - multiply *)
  | AddToKeyword                (* 加上 - add to *)
  | SubtractKeyword             (* 减去 - subtract *)
  | IsKeyword                   (* 为 - is *)
  | EqualToKeyword              (* 等于 - equal to *)
  | LessThanEqualToKeyword      (* 小于等于 - less than or equal to *)
  | FirstElementKeyword         (* 首元素 - first element *)
  | RemainingKeyword            (* 剩余 - remaining *)
  | EmptyKeyword                (* 空 - empty *)
  | CharacterCountKeyword       (* 字符数量 - character count *)
  | OfParticle                  (* 之 - possessive particle *)
  | TopicMarker                 (* 者 - topic marker *)
  
  (* 新增自然语言函数定义关键字 *)
  | InputKeyword                (* 输入 - input *)
  | OutputKeyword               (* 输出 - output *)
  | MinusOneKeyword             (* 减一 - minus one *)
  | PlusKeyword                 (* 加 - plus *)
  | WhereKeyword                (* 其中 - where *)
  | SmallKeyword                (* 小 - small *)
  
  (* 基本类型关键字 *)
  | IntTypeKeyword              (* 整数 - int *)
  | FloatTypeKeyword            (* 浮点数 - float *)
  | StringTypeKeyword           (* 字符串 - string *)
  | BoolTypeKeyword             (* 布尔 - bool *)
  | UnitTypeKeyword             (* 单元 - unit *)
  | ListTypeKeyword             (* 列表 - list *)
  | ArrayTypeKeyword            (* 数组 - array *)
  
  (* 运算符 *)
  | Plus                        (* + *)
  | Minus                       (* - *)
  | Multiply                    (* * *)
  | Star                        (* * - alias for Multiply *)
  | Divide                      (* / *)
  | Slash                       (* / - alias for Divide *)
  | Modulo                      (* % *)
  | Concat                      (* ^ - 字符串连接 *)
  | Assign                      (* = *)
  | Equal                       (* == *)
  | NotEqual                    (* <> *)
  | Less                        (* < *)
  | LessEqual                   (* <= *)
  | Greater                     (* > *)
  | GreaterEqual                (* >= *)
  | Arrow                       (* -> *)
  | DoubleArrow                 (* => *)
  | Dot                         (* . *)
  | DoubleDot                   (* .. *)
  | TripleDot                   (* ... *)
  | Bang                        (* ! - for dereferencing *)
  | RefAssign                   (* := - for reference assignment *)
  
  (* 分隔符 *)
  | LeftParen                   (* ( *)
  | RightParen                  (* ) *)
  | LeftBracket                 (* [ *)
  | RightBracket                (* ] *)
  | LeftBrace                   (* { *)
  | RightBrace                  (* } *)
  | Comma                       (* , *)
  | Semicolon                   (* ; *)
  | Colon                       (* : *)
  | Pipe                        (* | *)
  | Underscore                  (* _ *)
  | LeftArray                   (* [| *)
  | RightArray                  (* |] *)
  | AssignArrow                 (* <- *)
  | LeftQuote                   (* 「 *)
  | RightQuote                  (* 」 *)
  
  (* 中文标点符号 *)
  | ChineseLeftParen            (* （ *)
  | ChineseRightParen           (* ） *)
  | ChineseLeftBracket          (* 「 - 用于列表 *)
  | ChineseRightBracket         (* 」 - 用于列表 *)
  | ChineseComma                (* ， *)
  | ChineseSemicolon            (* ； *)
  | ChineseColon                (* ： *)
  | ChinesePipe                 (* ｜ *)
  | ChineseLeftArray            (* 「| *)
  | ChineseRightArray           (* |」 *)
  | ChineseArrow                (* → *)
  | ChineseDoubleArrow          (* ⇒ *)
  | ChineseAssignArrow          (* ← *)
  
  (* 特殊 *)
  | Newline
  | EOF
[@@deriving show, eq]

(** 位置信息 *)
type position = {
  line: int;
  column: int;
  filename: string;
} [@@deriving show, eq]

(** 带位置信息的词元 *)
type positioned_token = token * position [@@deriving show, eq]

(** 词法分析器状态 *)
type lexer_state = {
  input: string;
  length: int;
  position: int;
  current_line: int;
  current_column: int;
  filename: string;
}

(** 词法错误异常 *)
exception LexError of string * position

(** 关键字表 *)
val keyword_table : (string * token) list

(** 保留字列表 *)
val reserved_words : string list

(** 主要词法分析函数 *)

(** 将输入字符串分解为词元列表 *)
val tokenize : string -> string -> positioned_token list

(** 创建词法分析器状态 *)
val create_lexer_state : string -> string -> lexer_state

(** 读取下一个词元 *)
val next_token : lexer_state -> token * position * lexer_state

(** 工具函数 *)

(** 检查是否为保留字 *)
val is_reserved_word : string -> bool

(** 查找关键字 *)
val find_keyword : string -> token option

(** 尝试匹配关键字 *)
val try_match_keyword : lexer_state -> (string * token * int) option

(** 字符分类函数 *)

(** 检查是否为中文字符 *)
val is_chinese_char : char -> bool

(** 检查是否为字母或中文字符 *)
val is_letter_or_chinese : char -> bool

(** 检查是否为数字 *)
val is_digit : char -> bool

(** 检查是否为全角数字 *)
val is_fullwidth_digit_utf8 : string -> bool

(** 检查是否为英文标识符字符 *)
val is_english_identifier_char : char -> bool

(** 检查是否为标识符字符 *)
val is_identifier_char : char -> bool

(** 检查是否为空白字符 *)
val is_whitespace : char -> bool

(** 检查是否为分隔符 *)
val is_separator_char : char -> bool

(** 检查是否为中文UTF-8字符 *)
val is_chinese_utf8 : string -> bool

(** 字符串处理函数 *)

(** 全角数字转ASCII *)
val fullwidth_digit_to_ascii : string -> string

(** UTF-8字符计数 *)
val utf8_char_count : string -> int

(** UTF-8字符串前缀匹配 *)
val utf8_starts_with : string -> string -> bool

(** 获取UTF-8字符 *)
val utf8_get_char : string -> int -> string option

(** 获取下一个UTF-8字符 *)
val next_utf8_char : string -> int -> string * int

(** 状态导航函数 *)

(** 获取当前字符 *)
val current_char : lexer_state -> char option

(** 前进一个字符 *)
val advance : lexer_state -> lexer_state

(** 跳过空白和注释 *)
val skip_whitespace_and_comments : lexer_state -> lexer_state

(** 专用读取函数 *)

(** 条件读取字符串 *)
val read_while : lexer_state -> (char -> bool) -> string -> string * lexer_state

(** 读取UTF-8标识符 *)
val read_identifier_utf8 : lexer_state -> string * lexer_state

(** 读取引用标识符 *)
val read_quoted_identifier : lexer_state -> token * lexer_state

(** 读取数字 *)
val read_number : lexer_state -> token * lexer_state

(** 读取全角数字 *)
val read_fullwidth_number : lexer_state -> token * lexer_state

(** 读取字符串字面量 *)
val read_string_literal : lexer_state -> token * lexer_state

(** 读取ASCII字符串 *)
val read_ascii_string : lexer_state -> token * lexer_state

(** 符号识别函数 *)

(** 识别中文标点符号 *)
val recognize_chinese_punctuation : lexer_state -> position -> (token * position * lexer_state) option

(** 识别管道右括号 *)
val recognize_pipe_right_bracket : lexer_state -> position -> (token * position * lexer_state) option