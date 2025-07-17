(** 骆言词法分析器 - Chinese Programming Language Lexer *)

(* 导入模块化的词法分析器组件 *)
open Lexer_state
open Lexer_utils
open Lexer_chars
open Lexer_parsers

(* 重新导出类型和函数以匹配接口 *)
type token = Lexer_tokens.token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | ChineseNumberToken of string (* 中文数字：一二三四五六七八九点 *)
  | StringToken of string
  | BoolToken of bool
  (* 标识符 *)
  | QuotedIdentifierToken of string (* 「标识符」 - 所有标识符必须引用 *)
  | IdentifierTokenSpecial of string (* 特殊保护的标识符，如"数值" *)
  (* 关键字 *)
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
  | SigKeyword (* 签名 - sig *)
  | EndKeyword (* 结束 - end *)
  | FunctorKeyword (* 函子 - functor *)
  (* 可变性关键字 *)
  | RefKeyword (* 引用 - ref *)
  (* 新增模块系统关键字 *)
  | IncludeKeyword (* 包含 - include *)
  (* 宏系统关键字 *)
  | MacroKeyword (* 宏 - macro *)
  | ExpandKeyword (* 展开 - expand *)
  (* wenyan风格关键字 *)
  | HaveKeyword (* 吾有 - I have *)
  | OneKeyword (* 一 - one *)
  | NameKeyword (* 名曰 - name it *)
  | SetKeyword (* 设 - set *)
  | AlsoKeyword (* 也 - also/end particle *)
  | ThenGetKeyword (* 乃 - then/thus *)
  | CallKeyword (* 曰 - called/said *)
  | ValueKeyword (* 其值 - its value *)
  | AsForKeyword (* 为 - as for/regarding *)
  | NumberKeyword (* 数 - number *)
  (* wenyan扩展关键字 *)
  | WantExecuteKeyword (* 欲行 - want to execute *)
  | MustFirstGetKeyword (* 必先得 - must first get *)
  | ForThisKeyword (* 為是 - for this *)
  | TimesKeyword (* 遍 - times/iterations *)
  | EndCloudKeyword (* 云云 - end marker *)
  | IfWenyanKeyword (* 若 - if (wenyan style) *)
  | ThenWenyanKeyword (* 者 - then particle *)
  | GreaterThanWenyan (* 大于 - greater than *)
  | LessThanWenyan (* 小于 - less than *)
  (* 古雅体关键字 - Ancient Chinese Literary Style *)
  | AncientDefineKeyword (* 夫...者 - ancient function definition *)
  | AncientEndKeyword (* 也 - ancient end marker *)
  | AncientAlgorithmKeyword (* 算法 - algorithm *)
  | AncientCompleteKeyword (* 竟 - complete/finish *)
  | AncientObserveKeyword (* 观 - observe/examine *)
  | AncientNatureKeyword (* 性 - nature/essence *)
  | AncientIfKeyword (* 若 - if (ancient style) *)
  | AncientThenKeyword (* 则 - then (ancient) *)
  | AncientOtherwiseKeyword (* 余者 - otherwise/others *)
  | AncientAnswerKeyword (* 答 - answer/return *)
  | AncientRecursiveKeyword (* 递归 - recursive (ancient) *)
  | AncientCombineKeyword (* 合 - combine *)
  | AncientAsOneKeyword (* 为一 - as one *)
  | AncientTakeKeyword (* 取 - take/get *)
  | AncientReceiveKeyword (* 受 - receive *)
  | AncientParticleOf (* 之 - possessive particle *)
  | AncientParticleFun (* 焉 - function parameter particle *)
  | AncientParticleThe (* 其 - its/the *)
  | AncientCallItKeyword (* 名曰 - call it *)
  | AncientListStartKeyword (* 列开始 - list start *)
  | AncientListEndKeyword (* 列结束 - list end *)
  | AncientItsFirstKeyword (* 其一 - its first *)
  | AncientItsSecondKeyword (* 其二 - its second *)
  | AncientItsThirdKeyword (* 其三 - its third *)
  | AncientEmptyKeyword (* 空空如也 - empty as void *)
  | AncientHasHeadTailKeyword (* 有首有尾 - has head and tail *)
  | AncientHeadNameKeyword (* 首名为 - head named as *)
  | AncientTailNameKeyword (* 尾名为 - tail named as *)
  | AncientThusAnswerKeyword (* 则答 - thus answer *)
  | AncientAddToKeyword (* 并加 - and add *)
  | AncientObserveEndKeyword (* 观察毕 - observation complete *)
  | AncientBeginKeyword (* 始 - begin *)
  | AncientEndCompleteKeyword (* 毕 - complete *)
  (* 古雅体记录类型关键词 *)
  | AncientRecordStartKeyword (* 据开始 - record start *)
  | AncientRecordEndKeyword (* 据结束 - record end *)
  | AncientRecordEmptyKeyword (* 据空 - record empty *)
  | AncientRecordUpdateKeyword (* 据更新 - record update *)
  | AncientRecordFinishKeyword (* 据毕 - record finish *)
  | AncientIsKeyword (* 乃 - is/thus *)
  | AncientArrowKeyword (* 故 - therefore/thus *)
  | AncientWhenKeyword (* 当 - when *)
  | AncientCommaKeyword (* 且 - and/also *)
  | AncientPeriodKeyword (* 也 - particle for end of statement *)
  | AfterThatKeyword (* 而后 - after that/then *)
  (* 自然语言函数定义关键字 *)
  | DefineKeyword (* 定义 - define *)
  | AcceptKeyword (* 接受 - accept *)
  | ReturnWhenKeyword (* 时返回 - return when *)
  | ElseReturnKeyword (* 否则返回 - else return *)
  | MultiplyKeyword (* 乘以 - multiply *)
  | DivideKeyword (* 除以 - divide *)
  | AddToKeyword (* 加上 - add to *)
  | SubtractKeyword (* 减去 - subtract *)
  | IsKeyword (* 为 - is *)
  | EqualToKeyword (* 等于 - equal to *)
  | LessThanEqualToKeyword (* 小于等于 - less than or equal to *)
  | FirstElementKeyword (* 首元素 - first element *)
  | RemainingKeyword (* 剩余 - remaining *)
  | EmptyKeyword (* 空 - empty *)
  | CharacterCountKeyword (* 字符数量 - character count *)
  | OfParticle (* 之 - possessive particle *)
  | TopicMarker (* 者 - topic marker *)
  (* 新增自然语言函数定义关键字 *)
  | InputKeyword (* 输入 - input *)
  | OutputKeyword (* 输出 - output *)
  | MinusOneKeyword (* 减一 - minus one *)
  | PlusKeyword (* 加 - plus *)
  | WhereKeyword (* 其中 - where *)
  | SmallKeyword (* 小 - small *)
  | ShouldGetKeyword (* 应得 - should get *)
  | IntTypeKeyword (* 整数 - int *)
  | FloatTypeKeyword (* 浮点数 - float *)
  | StringTypeKeyword (* 字符串 - string *)
  | BoolTypeKeyword (* 布尔 - bool *)
  | UnitTypeKeyword (* 单元 - unit *)
  | ListTypeKeyword (* 列表 - list *)
  | ArrayTypeKeyword (* 数组 - array *)
  (* 多态变体关键字 *)
  | VariantKeyword (* 变体 - variant *)
  | TagKeyword (* 标签 - tag (for polymorphic variants) *)
  (* 古典诗词音韵相关关键字 *)
  | RhymeKeyword (* 韵 - rhyme *)
  | ToneKeyword (* 调 - tone *)
  | ToneLevelKeyword (* 平 - level tone *)
  | ToneFallingKeyword (* 仄 - falling tone *)
  | ToneRisingKeyword (* 上 - rising tone *)
  | ToneDepartingKeyword (* 去 - departing tone *)
  | ToneEnteringKeyword (* 入 - entering tone *)
  | ParallelKeyword (* 对 - parallel/paired *)
  | PairedKeyword (* 偶 - paired/even *)
  | AntitheticKeyword (* 反 - antithetic *)
  | BalancedKeyword (* 衡 - balanced *)
  | PoetryKeyword (* 诗 - poetry *)
  | FourCharKeyword (* 四言 - four characters *)
  | FiveCharKeyword (* 五言 - five characters *)
  | SevenCharKeyword (* 七言 - seven characters *)
  | ParallelStructKeyword (* 骈体 - parallel structure *)
  | RegulatedVerseKeyword (* 律诗 - regulated verse *)
  | QuatrainKeyword (* 绝句 - quatrain *)
  | CoupletKeyword (* 对联 - couplet *)
  | AntithesisKeyword (* 对仗 - antithesis *)
  | MeterKeyword (* 韵律 - meter *)
  | CadenceKeyword (* 音律 - cadence *)
  (* 运算符 *)
  | Plus (* + *)
  | Minus (* - *)
  | Multiply (* * *)
  | Star (* * - alias for Multiply *)
  | Divide (* / *)
  | Slash (* / - alias for Divide *)
  | Modulo (* % *)
  | Concat (* ^ - 字符串连接 *)
  | Assign (* = *)
  | Equal (* == *)
  | NotEqual (* <> *)
  | Less (* < *)
  | LessEqual (* <= *)
  | Greater (* > *)
  | GreaterEqual (* >= *)
  | Arrow (* -> *)
  | DoubleArrow (* => *)
  | Dot (* . *)
  | DoubleDot (* .. *)
  | TripleDot (* ... *)
  | Bang (* ! - for dereferencing *)
  | RefAssign (* := - for reference assignment *)
  (* 分隔符 *)
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
  (* 中文标点符号 *)
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
  (* 特殊 *)
  | Newline
  | EOF

type position = Lexer_tokens.position = { line : int; column : int; filename : string }
type positioned_token = Lexer_tokens.positioned_token

exception LexError = Lexer_tokens.LexError

(* 重新导出ppx_deriving生成的函数 *)
let pp_token = Lexer_tokens.pp_token

let show_token token =
  let s = Lexer_tokens.show_token token in
  (* 将 Lexer_tokens.* 替换为 Lexer.* 以匹配测试期望 *)
  Str.global_replace (Str.regexp "Lexer_tokens\\.") "Lexer." s

let equal_token = Lexer_tokens.equal_token
let pp_position = Lexer_tokens.pp_position
let show_position = Lexer_tokens.show_position
let equal_position = Lexer_tokens.equal_position
let pp_positioned_token = Lexer_tokens.pp_positioned_token
let show_positioned_token = Lexer_tokens.show_positioned_token
let equal_positioned_token = Lexer_tokens.equal_positioned_token

(* 函数从各个模块导入，保持向后兼容性 *)

(* 重新导出关键函数以满足接口要求 *)
let find_keyword = Lexer_keywords.find_keyword

(** 获取下一个词元 *)
let next_token state : token * position * lexer_state =
  let state = skip_whitespace_and_comments state in
  let pos =
    { line = state.current_line; column = state.current_column; filename = state.filename }
  in

  match current_char state with
  | None -> (EOF, pos, state)
  | Some '\n' -> (Newline, pos, advance state)
  | _ -> (
      (* 首先尝试识别中文标点符号 *)
      try
        match recognize_chinese_punctuation state pos with
        | Some result -> result
        | None -> (
            (* 尝试识别｜」组合 *)
            match recognize_pipe_right_bracket state pos with
            | Some result -> result
            | None ->
                if
                  (* 检查当前字符是否存在 *)
                  state.position >= state.length
                then (EOF, pos, state)
                else
                  (* 尝试获取UTF-8字符 *)
                  let utf8_char, _next_pos = next_utf8_char state.input state.position in
                  if utf8_char = "" then (EOF, pos, state)
                  else if utf8_char = "\n" then (Newline, pos, advance state)
                  else if utf8_char = "\"" then
                    raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: \"", pos))
                  else if String.length utf8_char = 1 then
                    let c = utf8_char.[0] in
                    match c with
                    | '+' | '-' | '*' | '/' | '%' | '^' | '=' | '<' | '>' | '.' | '(' | ')' | '['
                    | ']' | '{' | '}' | ',' | ';' | ':' | '!' | '|' | '_' | '@' | '#' | '$' | '&'
                    | '?' | '\'' | '`' | '~' ->
                        raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: " ^ String.make 1 c, pos))
                    | _ when is_digit c ->
                        (* 阿拉伯数字已禁用 - Issue #105 *)
                        raise (LexError (Constants.ErrorMessages.arabic_numbers_disabled, pos))
                    | _ when is_letter_or_chinese c -> handle_letter_or_chinese_char state pos
                    | _ ->
                        (* 其他ASCII字符，报错 *)
                        raise (LexError ("意外的字符: " ^ String.make 1 c, pos))
                  else if utf8_char = "『" then
                    (* 『 (U+300E) - 开始字符串字面量 *)
                    let skip_state =
                      {
                        state with
                        position = state.position + 3;
                        current_column = state.current_column + 1;
                      }
                    in
                    let token, new_state = read_string_literal skip_state in
                    (token, pos, new_state)
                  else if utf8_char = "「" then
                    (* 「 (U+300C) - 开始引用标识符 *)
                    let skip_state =
                      {
                        state with
                        position = state.position + 3;
                        current_column = state.current_column + 1;
                      }
                    in
                    let token, new_state = read_quoted_identifier skip_state in
                    (token, pos, new_state)
                  else if String.length utf8_char > 1 then
                    (* 多字节UTF-8字符，检查是否为中文或其他支持的字符 *)
                    if Utf8_utils.FullwidthDetection.is_fullwidth_digit_string utf8_char then
                      (* 全角数字字符，读取全角数字序列 *)
                      let sequence, new_state = Lexer_utils.read_fullwidth_number_sequence state in
                      let token = Lexer_utils.convert_fullwidth_number_sequence sequence in
                      (token, pos, new_state)
                    else if is_chinese_utf8 utf8_char || Keyword_matcher.is_keyword utf8_char then
                      handle_letter_or_chinese_char state pos
                    else
                      (* 不支持的多字节字符 *)
                      raise (LexError ("意外的字符: " ^ utf8_char, pos))
                  else
                    (* 单字节字符，应该在前面处理过，这里是fallback *)
                    raise (LexError ("意外的字符: " ^ utf8_char, pos)))
      with LexError (msg, pos) -> raise (LexError (msg, pos)))

(** 词法分析主函数 *)
let tokenize input filename : positioned_token list =
  let rec analyze state acc =
    let token, pos, new_state = next_token state in
    let positioned_token = (token, pos) in
    match token with
    | EOF -> List.rev (positioned_token :: acc)
    | Newline -> analyze new_state (positioned_token :: acc)
    | _ -> analyze new_state (positioned_token :: acc)
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []
