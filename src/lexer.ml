(** 骆言词法分析器 - Chinese Programming Language Lexer *)

(** 词元类型 *)
type token =
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
[@@deriving show, eq]

type position = { line : int; column : int; filename : string } [@@deriving show, eq]
(** 位置信息 *)

type positioned_token = token * position [@@deriving show, eq]
(** 带位置的词元 *)

exception LexError of string * position
(** 词法错误 *)

(* 关键字表现在在keyword_tables模块中定义 *)

(* 保留词表现在在keyword_tables模块中定义 *)

open Keyword_tables

(** 检查是否为保留词 *)
let is_reserved_word = ReservedWords.is_reserved_word

(** 将多态变体转换为token类型 *)
let variant_to_token = function
  | `LetKeyword -> LetKeyword
  | `RecKeyword -> RecKeyword
  | `InKeyword -> InKeyword
  | `FunKeyword -> FunKeyword
  | `IfKeyword -> IfKeyword
  | `ThenKeyword -> ThenKeyword
  | `ElseKeyword -> ElseKeyword
  | `MatchKeyword -> MatchKeyword
  | `WithKeyword -> WithKeyword
  | `OtherKeyword -> OtherKeyword
  | `TypeKeyword -> TypeKeyword
  | `PrivateKeyword -> PrivateKeyword
  | `TrueKeyword -> TrueKeyword
  | `FalseKeyword -> FalseKeyword
  | `AndKeyword -> AndKeyword
  | `OrKeyword -> OrKeyword
  | `NotKeyword -> NotKeyword
  | `AsKeyword -> AsKeyword
  | `CombineKeyword -> CombineKeyword
  | `WithOpKeyword -> WithOpKeyword
  | `WhenKeyword -> WhenKeyword
  | `WithDefaultKeyword -> WithDefaultKeyword
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  | `OfKeyword -> OfKeyword
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  | `HaveKeyword -> HaveKeyword
  | `OneKeyword -> OneKeyword
  | `NameKeyword -> NameKeyword
  | `SetKeyword -> SetKeyword
  | `AlsoKeyword -> AlsoKeyword
  | `ThenGetKeyword -> ThenGetKeyword
  | `CallKeyword -> CallKeyword
  | `ValueKeyword -> ValueKeyword
  | `AsForKeyword -> AsForKeyword
  | `NumberKeyword -> NumberKeyword
  | `WantExecuteKeyword -> WantExecuteKeyword
  | `MustFirstGetKeyword -> MustFirstGetKeyword
  | `ForThisKeyword -> ForThisKeyword
  | `TimesKeyword -> TimesKeyword
  | `EndCloudKeyword -> EndCloudKeyword
  | `IfWenyanKeyword -> IfWenyanKeyword
  | `ThenWenyanKeyword -> ThenWenyanKeyword
  | `GreaterThanWenyan -> GreaterThanWenyan
  | `LessThanWenyan -> LessThanWenyan
  | `OfParticle -> OfParticle
  | `DefineKeyword -> DefineKeyword
  | `AcceptKeyword -> AcceptKeyword
  | `ReturnWhenKeyword -> ReturnWhenKeyword
  | `ElseReturnKeyword -> ElseReturnKeyword
  | `MultiplyKeyword -> MultiplyKeyword
  | `DivideKeyword -> DivideKeyword
  | `AddToKeyword -> AddToKeyword
  | `SubtractKeyword -> SubtractKeyword
  | `EqualToKeyword -> EqualToKeyword
  | `LessThanEqualToKeyword -> LessThanEqualToKeyword
  | `FirstElementKeyword -> FirstElementKeyword
  | `RemainingKeyword -> RemainingKeyword
  | `EmptyKeyword -> EmptyKeyword
  | `CharacterCountKeyword -> CharacterCountKeyword
  | `InputKeyword -> InputKeyword
  | `OutputKeyword -> OutputKeyword
  | `MinusOneKeyword -> MinusOneKeyword
  | `PlusKeyword -> PlusKeyword
  | `WhereKeyword -> WhereKeyword
  | `SmallKeyword -> SmallKeyword
  | `ShouldGetKeyword -> ShouldGetKeyword
  | `IntTypeKeyword -> IntTypeKeyword
  | `FloatTypeKeyword -> FloatTypeKeyword
  | `StringTypeKeyword -> StringTypeKeyword
  | `BoolTypeKeyword -> BoolTypeKeyword
  | `UnitTypeKeyword -> UnitTypeKeyword
  | `ListTypeKeyword -> ListTypeKeyword
  | `ArrayTypeKeyword -> ArrayTypeKeyword
  | `VariantKeyword -> VariantKeyword
  | `TagKeyword -> TagKeyword
  | `AncientDefineKeyword -> AncientDefineKeyword
  | `AncientEndKeyword -> AncientEndKeyword
  | `AncientAlgorithmKeyword -> AncientAlgorithmKeyword
  | `AncientCompleteKeyword -> AncientCompleteKeyword
  | `AncientObserveKeyword -> AncientObserveKeyword
  | `AncientNatureKeyword -> AncientNatureKeyword
  | `AncientThenKeyword -> AncientThenKeyword
  | `AncientOtherwiseKeyword -> AncientOtherwiseKeyword
  | `AncientAnswerKeyword -> AncientAnswerKeyword
  | `AncientCombineKeyword -> AncientCombineKeyword
  | `AncientAsOneKeyword -> AncientAsOneKeyword
  | `AncientTakeKeyword -> AncientTakeKeyword
  | `AncientReceiveKeyword -> AncientReceiveKeyword
  | `AncientParticleThe -> AncientParticleThe
  | `AncientParticleFun -> AncientParticleFun
  | `AncientCallItKeyword -> AncientCallItKeyword
  | `AncientListStartKeyword -> AncientListStartKeyword
  | `AncientListEndKeyword -> AncientListEndKeyword
  | `AncientItsFirstKeyword -> AncientItsFirstKeyword
  | `AncientItsSecondKeyword -> AncientItsSecondKeyword
  | `AncientItsThirdKeyword -> AncientItsThirdKeyword
  | `AncientEmptyKeyword -> AncientEmptyKeyword
  | `AncientHasHeadTailKeyword -> AncientHasHeadTailKeyword
  | `AncientHeadNameKeyword -> AncientHeadNameKeyword
  | `AncientTailNameKeyword -> AncientTailNameKeyword
  | `AncientThusAnswerKeyword -> AncientThusAnswerKeyword
  | `AncientAddToKeyword -> AncientAddToKeyword
  | `AncientObserveEndKeyword -> AncientObserveEndKeyword
  | `AncientBeginKeyword -> AncientBeginKeyword
  | `AncientEndCompleteKeyword -> AncientEndCompleteKeyword
  | `AncientIsKeyword -> AncientIsKeyword
  | `AncientArrowKeyword -> AncientArrowKeyword
  | `AncientWhenKeyword -> AncientWhenKeyword
  | `AncientCommaKeyword -> AncientCommaKeyword
  | `AfterThatKeyword -> AfterThatKeyword
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial "数值"

(** 查找关键字 *)
let find_keyword str =
  match Keywords.find_keyword str with
  | Some variant -> Some (variant_to_token variant)
  | None -> None

(** 是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  (* But for UTF-8 bytes, we need to check differently *)
  code >= Constants.UTF8.chinese_char_start || (code >= Constants.UTF8.chinese_char_mid_start && code <= Constants.UTF8.chinese_char_mid_end)

(** 是否为字母或中文 *)
let is_letter_or_chinese c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

(** 是否为数字 *)
let is_digit c = c >= '0' && c <= '9'

(** 是否为空白字符 - 空格仍需跳过，但不用于关键字消歧 *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\r'

(** 是否为分隔符字符 - 用于关键字边界检查（不包括空格） *)
let is_separator_char c = c = '\t' || c = '\r' || c = '\n'

type lexer_state = {
  input : string;
  length : int;
  position : int;
  current_line : int;
  current_column : int;
  filename : string;
}
(** 词法分析器状态 *)

(** 创建词法状态 *)
let create_lexer_state input filename =
  {
    input;
    length = String.length input;
    position = 0;
    current_line = 1;
    current_column = 1;
    filename;
  }

(** 尝试从当前位置匹配最长的关键字 *)
let try_match_keyword state =
  let rec try_keywords keywords best_match =
    match keywords with
    | [] -> best_match
    | (keyword, token) :: rest ->
        let keyword_len = String.length keyword in
        if state.position + keyword_len <= state.length then
          let substring = String.sub state.input state.position keyword_len in
          if substring = keyword then
            (* 检查关键字边界 *)
            let next_pos = state.position + keyword_len in
            let is_complete_word =
              if next_pos >= state.length then true (* 文件结尾 *)
              else
                let next_char = state.input.[next_pos] in
                (* 对于中文关键字，检查边界 *)
                if String.for_all (fun c -> Char.code c >= Constants.UTF8.chinese_char_threshold) keyword then
                  (* 中文关键字：检查下一个字符是否可能形成更长的关键字 *)
                  (* 简单方法：如果下一个字符也是中文字符，检查是否有更长的匹配 *)
                  let next_is_chinese = Char.code next_char >= Constants.UTF8.chinese_char_threshold in
                  if next_is_chinese then
                    (* 检查是否为引用标识符的引号，如果是则认为关键字完整 *)
                    let is_quote_punctuation =
                      Char.code next_char = Constants.UTF8.left_quote_byte1
                      && next_pos + 2 < state.length
                      && Char.code state.input.[next_pos + 1] = Constants.UTF8.left_quote_byte2
                      && (Char.code state.input.[next_pos + 2] = Constants.UTF8.left_quote_byte3
                         ||
                         (* 「 *)
                         Char.code state.input.[next_pos + 2] = Constants.UTF8.right_quote_byte3)
                      (* 」 *)
                    in
                    if is_quote_punctuation then true (* 引号字符，关键字完整 *)
                    else
                      (* 检查是否存在以当前关键字为前缀且与当前输入匹配的更长关键字 *)
                      let has_longer_actual_match =
                        List.exists
                          (fun (kw, _) ->
                            let kw_len = String.length kw in
                            kw_len > keyword_len
                            && String.sub kw 0 keyword_len = keyword
                            && state.position + kw_len <= state.length
                            && String.sub state.input state.position kw_len = kw)
                          (List.map
                             (fun (str, variant) -> (str, variant_to_token variant))
                             Keywords.all_keywords_list)
                      in
                      not has_longer_actual_match
                  else true (* 下一个字符不是中文，当前关键字完整 *)
                else
                  (* 英文关键字：减少对空格边界的依赖，使用更简单的分隔符检查 *)
                  is_separator_char next_char
                  || not (is_letter_or_chinese next_char || is_digit next_char)
            in
            if is_complete_word then
              match best_match with
              | None -> try_keywords rest (Some (keyword, token, keyword_len))
              | Some (_, _, best_len) when keyword_len > best_len ->
                  try_keywords rest (Some (keyword, token, keyword_len))
              | Some _ -> try_keywords rest best_match
            else try_keywords rest best_match
          else try_keywords rest best_match
        else try_keywords rest best_match
  in
  try_keywords
    (List.map (fun (str, variant) -> (str, variant_to_token variant)) Keywords.all_keywords_list)
    None

(** 获取当前字符 *)
let current_char state =
  if state.position >= state.length then None else Some state.input.[state.position]

(** 向前移动 *)
let advance state =
  if state.position >= state.length then state
  else
    let c = state.input.[state.position] in
    if c = '\n' then
      {
        state with
        position = state.position + 1;
        current_line = state.current_line + 1;
        current_column = 1;
      }
    else { state with position = state.position + 1; current_column = state.current_column + 1 }

(** 跳过单个注释 *)
let skip_comment state =
  let rec skip_until_close state depth =
    match current_char state with
    | None ->
        raise
          (LexError
             ( "Unterminated comment",
               {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               } ))
    | Some '(' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some '*' -> skip_until_close (advance state1) (depth + 1)
        | _ -> skip_until_close state1 depth)
    | Some '*' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some ')' ->
            if depth = 1 then advance state1 else skip_until_close (advance state1) (depth - 1)
        | _ -> skip_until_close state1 depth)
    | Some _ -> skip_until_close (advance state) depth
  in
  skip_until_close state 1

(** 检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(** 跳过中文注释 「：注释内容：」 *)
let skip_chinese_comment state =
  let rec skip_until_close state =
    match current_char state with
    | None ->
        raise
          (LexError
             ( "Unterminated Chinese comment",
               {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               } ))
    | Some c when Char.code c = 0xEF ->
        if check_utf8_char state 0xEF 0xBC 0x9A then
          (* 找到 ： *)
          let state1 =
            { state with position = state.position + 3; current_column = state.current_column + 1 }
          in
          match current_char state1 with
          | Some c when Char.code c = 0xE3 ->
              if check_utf8_char state1 0xE3 0x80 0x8D then
                (* 找到 ：」 组合，注释结束 *)
                {
                  state1 with
                  position = state1.position + 3;
                  current_column = state1.current_column + 1;
                }
              else skip_until_close state1
          | _ -> skip_until_close state1
        else skip_until_close (advance state)
    | Some _ -> skip_until_close (advance state)
  in
  skip_until_close state

(** 跳过空白字符和注释 *)
let rec skip_whitespace_and_comments state =
  match current_char state with
  | Some c when is_whitespace c -> skip_whitespace_and_comments (advance state)
  | Some '(' -> (
      let state1 = advance state in
      match current_char state1 with
      | Some '*' -> skip_whitespace_and_comments (skip_comment (advance state1))
      | _ -> state
      (* 不是注释，返回原状态 *))
  | Some c when Char.code c = 0xE3 ->
      (* 检查中文注释 「： *)
      if check_utf8_char state 0xE3 0x80 0x8C then
        (* 找到 「 *)
        let state1 =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        match current_char state1 with
        | Some c when Char.code c = 0xEF ->
            if check_utf8_char state1 0xEF 0xBC 0x9A then
              (* 找到 「： 组合，开始中文注释 *)
              let state2 =
                {
                  state1 with
                  position = state1.position + 3;
                  current_column = state1.current_column + 1;
                }
              in
              skip_whitespace_and_comments (skip_chinese_comment state2)
            else state (* 不是中文注释，返回原状态 *)
        | _ -> state (* 不是中文注释，返回原状态 *)
      else state
  | _ -> state

(** 读取字符串直到满足条件 *)

(* 判断一个UTF-8字符串是否为中文字符（CJK Unified Ideographs） *)
let is_chinese_utf8 s =
  match Uutf.decode (Uutf.decoder (`String s)) with
  | `Uchar u ->
      let code = Uchar.to_int u in
      code >= 0x4E00 && code <= 0x9FFF
  | _ -> false

(* 读取下一个UTF-8字符，返回字符和新位置 *)
let next_utf8_char input pos =
  let dec = Uutf.decoder (`String (String.sub input pos (String.length input - pos))) in
  match Uutf.decode dec with
  | `Uchar u ->
      let buf = Buffer.create 8 in
      Uutf.Buffer.add_utf_8 buf u;
      let s = Buffer.contents buf in
      let len = Bytes.length (Bytes.of_string s) in
      (s, pos + len)
  | _ -> ("", pos)

(** 是否为中文数字字符 *)
let is_chinese_digit_char ch =
  match ch with
  | "一" | "二" | "三" | "四" | "五" | "六" | "七" | "八" | "九" | "十" | "零" | "点" -> true
  | _ -> false

(** 检查当前位置是否可能为保留词开头 *)
let _could_be_reserved_word state =
  let rec check_reserved_words words =
    match words with
    | [] -> false
    | word :: rest ->
        let word_len = String.length word in
        if state.position + word_len <= state.length then
          let substring = String.sub state.input state.position word_len in
          if substring = word then true else check_reserved_words rest
        else check_reserved_words rest
  in
  check_reserved_words (ReservedWords.all_reserved_words ())

(** 读取中文数字序列 *)
let read_chinese_number_sequence state =
  let input = state.input in
  let length = state.length in
  let rec loop pos acc =
    if pos >= length then (acc, pos)
    else
      let ch, next_pos = next_utf8_char input pos in
      if is_chinese_digit_char ch then loop next_pos (acc ^ ch) else (acc, pos)
  in
  let sequence, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (sequence, { state with position = new_pos; current_column = new_col })

(** 转换中文数字序列为数值 *)
let convert_chinese_number_sequence sequence =
  let char_to_digit = function
    | "一" -> 1
    | "二" -> 2
    | "三" -> 3
    | "四" -> 4
    | "五" -> 5
    | "六" -> 6
    | "七" -> 7
    | "八" -> 8
    | "九" -> 9
    | "零" -> 0
    | _ -> 0
  in

  (* 将UTF-8字符串解析为中文字符列表 *)
  let rec utf8_to_char_list input pos chars =
    if pos >= String.length input then List.rev chars
    else
      let ch, next_pos = next_utf8_char input pos in
      if ch = "" then List.rev chars else utf8_to_char_list input next_pos (ch :: chars)
  in

  let rec parse_chars chars acc =
    match chars with
    | [] -> acc
    | ch :: rest ->
        let digit = char_to_digit ch in
        parse_chars rest ((acc * 10) + digit)
  in

  (* 分割整数部分和小数部分 *)
  let parts = Str.split (Str.regexp "点") sequence in
  match parts with
  | [ integer_part ] ->
      (* 只有整数部分 *)
      let chars = utf8_to_char_list integer_part 0 [] in
      let int_val = parse_chars chars 0 in
      IntToken int_val
  | [ integer_part; decimal_part ] ->
      (* 有整数和小数部分 *)
      let int_chars = utf8_to_char_list integer_part 0 [] in
      let dec_chars = utf8_to_char_list decimal_part 0 [] in
      let int_val = parse_chars int_chars 0 in
      let dec_val = parse_chars dec_chars 0 in
      let decimal_places = List.length dec_chars in
      let float_val =
        float_of_int int_val +. (float_of_int dec_val /. (10. ** float_of_int decimal_places))
      in
      FloatToken float_val
  | _ -> IntToken 0 (* 错误情况，返回0 *)

(* 智能读取标识符：在关键字边界处停止 *)
let _read_identifier_utf8 state =
  let rec loop pos acc =
    if pos >= state.length then (acc, pos)
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if ch = "" then (acc, pos)
      else if
        (String.length ch = 1 && is_letter_or_chinese ch.[0])
        || is_chinese_utf8 ch
        || (String.length ch = 1 && is_digit ch.[0])
        || ch = "_"
      then
        (* 检查当前累积是否为保留词，如果是则不分割 *)
        let potential_acc = acc ^ ch in
        if acc <> "" && Char.code ch.[0] >= 128 then
          (* 当前已经有累积字符，遇到中文字符时检查关键字边界 *)
          let temp_state =
            {
              state with
              position = pos;
              current_column = state.current_column + (pos - state.position);
            }
          in
          match try_match_keyword temp_state with
          | Some (_keyword, _token, _len) ->
              (* 找到关键字匹配，但要检查当前累积或继续累积是否为保留词 *)
              if is_reserved_word acc then
                (* 当前累积是保留词，继续读取 *)
                loop next_pos potential_acc
              else if is_reserved_word potential_acc then
                (* 继续累积会形成保留词，继续读取 *)
                loop next_pos potential_acc
              else
                (* 检查是否可能形成保留词（前瞻性检查）*)
                let could_form_reserved =
                  List.exists
                    (fun word ->
                      String.length word > String.length potential_acc
                      && String.sub word 0 (String.length potential_acc) = potential_acc)
                    (ReservedWords.all_reserved_words ())
                in
                if could_form_reserved then
                  (* 可能形成保留词，继续读取 *)
                  loop next_pos potential_acc
                else
                  (* 都不是保留词，在关键字边界停止 *)
                  (acc, pos)
          | None ->
              (* 没有关键字匹配，继续读取 *)
              loop next_pos potential_acc
        else
          (* 英文或第一个字符，直接继续 *)
          loop next_pos potential_acc
      else (acc, pos)
  in
  let id, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (id, { state with position = new_pos; current_column = new_col })

(** 读取引用标识符 *)
let read_quoted_identifier state =
  let rec loop pos acc =
    if pos >= state.length then
      raise
        (LexError
           ( "未闭合的引用标识符",
             { line = state.current_line; column = state.current_column; filename = state.filename }
           ))
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if ch = "」" then (acc, next_pos) (* 找到结束引号，返回内容和新位置 *)
      else if ch = "" then
        raise
          (LexError
             ( "引用标识符中的无效字符",
               {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               } ))
      else loop next_pos (acc ^ ch)
    (* 继续累积字符 *)
  in
  let identifier, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (* 根据Issue #176：所有用「」引用的都是标识符，不管内容是什么 *)
  let token = QuotedIdentifierToken identifier in
  (token, { state with position = new_pos; current_column = new_col })

(** 读取数字 *)

(** 读取字符串字面量 *)
let read_string_literal state =
  let rec read state acc =
    match current_char state with
    | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8F ->
        (* 』 (U+300F) - 结束字符串字面量 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        (acc, new_state)
    | Some '\\' -> (
        let state1 = advance state in
        match current_char state1 with
        | Some 'n' -> read (advance state1) (acc ^ "\n")
        | Some 't' -> read (advance state1) (acc ^ "\t")
        | Some 'r' -> read (advance state1) (acc ^ "\r")
        | Some '"' -> read (advance state1) (acc ^ "\"")
        | Some '\\' -> read (advance state1) (acc ^ "\\")
        | Some c -> read (advance state1) (acc ^ String.make 1 c)
        | None ->
            raise
              (LexError
                 ( "Unterminated string",
                   {
                     line = state.current_line;
                     column = state.current_column;
                     filename = state.filename;
                   } )))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None ->
        raise
          (LexError
             ( "Unterminated string",
               {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               } ))
  in
  let content, new_state = read state "" in
  (StringToken content, new_state)

(** 读取阿拉伯数字 - Issue #192: 允许阿拉伯数字 *)
let read_arabic_number state =
  let rec read_digits pos acc =
    if pos >= state.length then (acc, pos)
    else
      let c = state.input.[pos] in
      if is_digit c then read_digits (pos + 1) (acc ^ String.make 1 c) else (acc, pos)
  in
  let digits, end_pos = read_digits state.position "" in
  let new_state =
    {
      state with
      position = end_pos;
      current_column = state.current_column + (end_pos - state.position);
    }
  in

  (* 检查是否有小数点 *)
  if end_pos < state.length && state.input.[end_pos] = '.' then
    (* 有小数点，尝试读取小数部分 *)
    let decimal_digits, final_pos = read_digits (end_pos + 1) "" in
    if decimal_digits = "" then
      (* 小数点后没有数字，只返回整数部分 *)
      (IntToken (int_of_string digits), new_state)
    else
      (* 有小数部分 *)
      let float_str = digits ^ "." ^ decimal_digits in
      let final_state =
        {
          state with
          position = final_pos;
          current_column = state.current_column + (final_pos - state.position);
        }
      in
      (FloatToken (float_of_string float_str), final_state)
  else
    (* 只是整数 *)
    (IntToken (int_of_string digits), new_state)

(* 识别中文标点符号 - 问题105: 仅支持「」『』：，。（） *)
let recognize_chinese_punctuation state pos =
  match current_char state with
  | Some c when Char.code c = 0xEF ->
      (* 全角符号范围 - 支持HEAD分支的功能，保持Issue #105的符号限制 *)
      if check_utf8_char state 0xEF 0xBC 0x88 then
        (* （ (U+FF08) - 保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (ChineseLeftParen, pos, new_state)
      else if check_utf8_char state 0xEF 0xBC 0x89 then
        (* ） (U+FF09) - 保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (ChineseRightParen, pos, new_state)
      else if check_utf8_char state 0xEF 0xBC 0x8C then
        (* ， (U+FF0C) - 保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (ChineseComma, pos, new_state)
      else if check_utf8_char state 0xEF 0xBC 0x9B then
        (* ； (U+FF1B) - 问题105禁用，只支持「」『』：，。（） *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
      else if check_utf8_char state 0xEF 0xBC 0x9A then
        (* ： (U+FF1A) - 检查是否为双冒号 *)
        let state_after_first_colon =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        if
          state_after_first_colon.position + 2 < state_after_first_colon.length
          && check_utf8_char state_after_first_colon 0xEF 0xBC 0x9A
        then
          (* ：： - 双冒号 *)
          let final_state =
            {
              state_after_first_colon with
              position = state_after_first_colon.position + 3;
              current_column = state_after_first_colon.current_column + 1;
            }
          in
          Some (ChineseDoubleColon, pos, final_state)
        else
          (* 单冒号 *)
          Some (ChineseColon, pos, state_after_first_colon)
      else if check_utf8_char state 0xEF 0xBD 0x9C then
        (* ｜ (U+FF5C) - 问题105禁用，只支持「」『』：，。（） *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
      else if check_utf8_char state 0xEF 0xBC 0x8E then
        (* ． (U+FF0E) - 全宽句号，但问题105要求中文句号 *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
      else
        (* 其他全角符号已禁用 *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
  | Some c when Char.code c = 0xE3 ->
      (* 中文标点符号范围 - 仅支持「」『』 *)
      if check_utf8_char state 0xE3 0x80 0x8C then
        (* 「 (U+300C) - 保留，用于引用标识符 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x8D then
        (* 」 (U+300D) - 保留，用于引用标识符 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x8E then
        (* 『 (U+300E) - 保留，用于字符串字面量 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x8F then
        (* 』 (U+300F) - 保留，用于字符串字面量 *)
        None (* 在主函数中专门处理 *)
      else if check_utf8_char state 0xE3 0x80 0x82 then
        (* 。 (U+3002) - 中文句号，保留 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        Some (Dot, pos, new_state)
      else
        (* 其他中文标点符号已禁用 *)
        let char_bytes = String.sub state.input state.position 3 in
        raise (LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
  | Some c when Char.code c = 0xE2 ->
      (* 箭头符号范围 - 全部禁用 *)
      let char_bytes = String.sub state.input state.position 3 in
      raise (LexError ("非支持的中文符号已禁用，只支持「」：，。（）。禁用符号: " ^ char_bytes, pos))
  | _ -> None

(** 问题105: ｜符号已禁用，数组符号不再支持 *)
let recognize_pipe_right_bracket _state _pos =
  (* 问题105禁用所有非指定符号，包括｜ *)
  None

(** 获取下一个词元 *)
let next_token state =
  let state = skip_whitespace_and_comments state in
  let pos =
    { line = state.current_line; column = state.current_column; filename = state.filename }
  in

  match current_char state with
  | None -> (EOF, pos, state)
  | Some '\n' -> (Newline, pos, advance state)
  | _ -> (
      (* 首先尝试识别中文标点符号 *)
      match recognize_chinese_punctuation state pos with
      | Some result -> result
      | None -> (
          (* 尝试识别｜」组合 *)
          match recognize_pipe_right_bracket state pos with
          | Some result -> result
          | None -> (
              (* ASCII符号现在被禁止使用 - 抛出错误 *)
              match current_char state with
              | None -> (EOF, pos, state) (* 这种情况应该已经在最外层处理了，但为了完整性保留 *)
              | Some '"' ->
                  (* 问题105: ASCII双引号已禁用，请使用中文标点符号 *)
                  raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: \"", pos))
              | Some
                  (( '+' | '-' | '*' | '/' | '%' | '^' | '=' | '<' | '>' | '.' | '(' | ')' | '['
                   | ']' | '{' | '}' | ',' | ';' | ':' | '!' | '|' | '_' | '@' | '#' | '$' | '&'
                   | '?' | '\'' | '`' | '~' ) as c) ->
                  (* 其他ASCII符号都被禁止，请使用中文标点符号 *)
                  raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: " ^ String.make 1 c, pos))
              | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8E ->
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
              | Some c
                when Char.code c = 0xE3
                     && state.position + 2 < state.length
                     && state.input.[state.position + 1] = '\x80'
                     && state.input.[state.position + 2] = '\x8C' ->
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
              | Some c
                when Char.code c = 0xE3
                     && state.position + 2 < state.length
                     && state.input.[state.position + 1] = '\x80'
                     && state.input.[state.position + 2] = '\x8D' ->
                  (* 」 (U+300D) *)
                  let new_state =
                    {
                      state with
                      position = state.position + 3;
                      current_column = state.current_column + 1;
                    }
                  in
                  (RightQuote, pos, new_state)
              | Some c when is_digit c ->
                  (* 根据Issue #192：允许阿拉伯数字 *)
                  let token, new_state = read_arabic_number state in
                  (token, pos, new_state)
              | Some c
                when Char.code c = 0xEF
                     && state.position + 2 < state.length
                     && state.input.[state.position + 1] = '\xBC'
                     && Char.code state.input.[state.position + 2] >= 0x90
                     && Char.code state.input.[state.position + 2] <= 0x99 ->
                  (* 根据Issue #192：禁用全角阿拉伯数字，只允许半角阿拉伯数字 *)
                  let char_bytes = String.sub state.input state.position 3 in
                  raise (LexError ("只允许半角阿拉伯数字，请勿使用全角数字。禁用字符: " ^ char_bytes, pos))
              | Some c
                when Char.code c = 0xEF
                     && state.position + 2 < state.length
                     && state.input.[state.position + 1] = '\xBC'
                     && not
                          (Char.code state.input.[state.position + 2] >= 0x90
                          && Char.code state.input.[state.position + 2] <= 0x99) ->
                  (* 问题105: 所有全宽运算符已禁用，只支持「」『』：，。（） *)
                  let char_bytes = String.sub state.input state.position 3 in
                  raise (LexError ("非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: " ^ char_bytes, pos))
              | Some c when is_letter_or_chinese c -> (
                  (* 检查是否为ASCII字母 *)
                  let is_ascii_letter = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') in
                  if is_ascii_letter then
                    (* ASCII字母只允许作为关键字使用 *)
                    match try_match_keyword state with
                    | Some (_keyword, token, keyword_len) ->
                        (* 找到关键字匹配，使用关键字 *)
                        let new_state =
                          {
                            state with
                            position = state.position + keyword_len;
                            current_column = state.current_column + keyword_len;
                          }
                        in
                        let final_token =
                          match token with
                          | TrueKeyword -> BoolToken true
                          | FalseKeyword -> BoolToken false
                          | IdentifierTokenSpecial name ->
                              (* 特殊标识符如"数值"在wenyan语法中允许直接使用 *)
                              QuotedIdentifierToken name
                          | _ -> token
                        in
                        (final_token, pos, new_state)
                    | None ->
                        (* ASCII字母不是关键字，禁止使用 *)
                        raise (LexError ("ASCII字母已禁用，只允许作为关键字使用。禁用字符: " ^ String.make 1 c, pos))
                  else
                    (* 中文字符，首先检查是否为中文数字序列 *)
                    let ch, _ = next_utf8_char state.input state.position in
                    if is_chinese_digit_char ch then
                      (* 检查是否为中文数字序列 *)
                      let sequence, temp_state = read_chinese_number_sequence state in
                      (* 计算中文字符数而不是字节数 *)
                      let char_count =
                        let rec count_chars s pos acc =
                          if pos >= String.length s then acc
                          else
                            let _, next_pos = next_utf8_char s pos in
                            count_chars s next_pos (acc + 1)
                        in
                        count_chars sequence 0 0
                      in
                      if char_count > 1 then
                        (* 多字符数字序列，优先作为数字处理 *)
                        let token = convert_chinese_number_sequence sequence in
                        (token, pos, temp_state)
                      else
                        (* 单字符，优先检查是否为关键字 *)
                        match try_match_keyword state with
                        | Some (_keyword, token, keyword_len) ->
                            (* 找到关键字匹配，使用关键字 *)
                            let new_state =
                              {
                                state with
                                position = state.position + keyword_len;
                                current_column = state.current_column + keyword_len;
                              }
                            in
                            let final_token =
                              match token with
                              | TrueKeyword -> BoolToken true
                              | FalseKeyword -> BoolToken false
                              | IdentifierTokenSpecial name ->
                                  (* 特殊标识符如"数值"在wenyan语法中允许直接使用 *)
                                  QuotedIdentifierToken name
                              | _ -> token
                            in
                            (final_token, pos, new_state)
                        | None ->
                            (* 不是关键字，作为单字符数字处理 *)
                            let token = convert_chinese_number_sequence sequence in
                            (token, pos, temp_state)
                    else
                      (* 不是中文数字字符，检查是否为关键字 *)
                      match try_match_keyword state with
                      | Some (_keyword, token, keyword_len) ->
                          (* 找到关键字匹配，使用关键字 *)
                          let new_state =
                            {
                              state with
                              position = state.position + keyword_len;
                              current_column = state.current_column + keyword_len;
                            }
                          in
                          let final_token =
                            match token with
                            | TrueKeyword -> BoolToken true
                            | FalseKeyword -> BoolToken false
                            | IdentifierTokenSpecial name ->
                                (* 特殊标识符如"数值"在wenyan语法中允许直接使用 *)
                                QuotedIdentifierToken name
                            | _ -> token
                          in
                          (final_token, pos, new_state)
                      | None ->
                          (* 不是关键字也不是中文数字，所有标识符必须使用「」引用 *)
                          raise (LexError ("标识符必须使用「」引用。未引用的标识符: " ^ String.make 1 c, pos)))
              | Some c -> raise (LexError ("Unknown character: " ^ String.make 1 c, pos)))))

(** 词法分析主函数 *)
let tokenize input filename =
  let rec analyze state acc =
    let token, pos, new_state = next_token state in
    let positioned_token = (token, pos) in
    match token with
    | EOF -> List.rev (positioned_token :: acc)
    | Newline -> analyze new_state (positioned_token :: acc) (* 包含换行符作为语句分隔符 *)
    | _ -> analyze new_state (positioned_token :: acc)
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []
