(** 骆言词法分析器 - Chinese Programming Language Lexer *)

(* 导入模块化的词法分析器组件 *)
open Lexer_state  
open Lexer_utils

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

(* 从原始lexer.ml中保留的必要函数 *)

(** 检查UTF-8字符匹配 *)
let check_utf8_char state _byte1 byte2 byte3 =
  state.position + 2 < state.length
  && Char.code state.input.[state.position + 1] = byte2
  && Char.code state.input.[state.position + 2] = byte3

(* Custom variant_to_token function that handles only keywords defined in keyword tables *)
let variant_to_token = function
  (* Basic keywords *)
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
  | `OfKeyword -> OfKeyword
  
  (* Semantic keywords *)
  | `AsKeyword -> AsKeyword
  | `CombineKeyword -> CombineKeyword
  | `WithOpKeyword -> WithOpKeyword
  | `WhenKeyword -> WhenKeyword
  
  (* Error recovery keywords *)
  | `WithDefaultKeyword -> WithDefaultKeyword
  | `ExceptionKeyword -> ExceptionKeyword
  | `RaiseKeyword -> RaiseKeyword
  | `TryKeyword -> TryKeyword
  | `CatchKeyword -> CatchKeyword
  | `FinallyKeyword -> FinallyKeyword
  
  (* Module keywords *)
  | `ModuleKeyword -> ModuleKeyword
  | `ModuleTypeKeyword -> ModuleTypeKeyword
  | `RefKeyword -> RefKeyword
  | `IncludeKeyword -> IncludeKeyword
  | `FunctorKeyword -> FunctorKeyword
  | `SigKeyword -> SigKeyword
  | `EndKeyword -> EndKeyword
  
  (* Macro keywords *)
  | `MacroKeyword -> MacroKeyword
  | `ExpandKeyword -> ExpandKeyword
  
  (* Wenyan keywords *)
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
  
  (* Wenyan extended keywords *)
  | `WantExecuteKeyword -> WantExecuteKeyword
  | `MustFirstGetKeyword -> MustFirstGetKeyword
  | `ForThisKeyword -> ForThisKeyword
  | `TimesKeyword -> TimesKeyword
  | `EndCloudKeyword -> EndCloudKeyword
  | `IfWenyanKeyword -> IfWenyanKeyword
  | `ThenWenyanKeyword -> ThenWenyanKeyword
  | `GreaterThanWenyan -> GreaterThanWenyan
  | `LessThanWenyan -> LessThanWenyan
  
  (* Natural language keywords *)
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
  | `OfParticle -> OfParticle
  
  (* Type annotation keywords *)
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
  
  (* Variant keywords *)
  | `VariantKeyword -> VariantKeyword
  | `TagKeyword -> TagKeyword
  
  (* Ancient keywords *)
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
  
  (* Special keywords *)
  | `IdentifierTokenSpecial -> IdentifierTokenSpecial "数值"

(** 查找关键字 *)
let find_keyword str =
  match Keyword_tables.Keywords.find_keyword str with
  | Some variant -> Some (variant_to_token variant)
  | None -> None

(** 处理字母或中文字符 *)
let rec handle_letter_or_chinese_char state pos =
  (* 首先尝试处理中文数字序列 *)
  let ch, _ = next_utf8_char state.input state.position in
  if is_chinese_digit_char ch then
    let sequence, temp_state = read_chinese_number_sequence state in
    if sequence <> "" then
      (* 检查是否是多字符的中文数字序列 *)
      let sequence_len = String.length sequence in
      let char_count = ref 0 in
      let pos_ref = ref 0 in
      while !pos_ref < sequence_len do
        let _, char_len = next_utf8_char sequence !pos_ref in
        incr char_count;
        pos_ref := !pos_ref + char_len;
      done;
      if !char_count > 1 then
        (* 多字符数字序列，优先作为数字处理 *)
        let token = convert_chinese_number_sequence sequence in
        (token, pos, temp_state)
      else
        (* 单字符，尝试关键字匹配 *)
        match try_match_keyword state with
        | Some (_, token, keyword_len) ->
            let new_state =
              {
                state with
                position = state.position + keyword_len;
                current_column = state.current_column + keyword_len;
              }
            in
            (token, pos, new_state)
        | None ->
            (* 不是关键字，作为数字处理 *)
            let token = convert_chinese_number_sequence sequence in
            (token, pos, temp_state)
    else
      (* 不是中文数字，尝试关键字匹配 *)
      match try_match_keyword state with
      | Some (_, token, keyword_len) ->
          let new_state =
            {
              state with
              position = state.position + keyword_len;
              current_column = state.current_column + keyword_len;
            }
          in
          (token, pos, new_state)
      | None ->
          (* 不是关键字，检查是否为ASCII字母 *)
          let (utf8_char, _) = next_utf8_char state.input state.position in
          if String.length utf8_char = 1 then
            let cur_char = utf8_char.[0] in
            if (cur_char >= 'a' && cur_char <= 'z') || (cur_char >= 'A' && cur_char <= 'Z') then
              raise (LexError ("ASCII字母已禁用，请使用中文标识符。禁用字母: " ^ String.make 1 cur_char, pos))
            else
              raise (LexError ("意外的字符: " ^ utf8_char, pos))
          else
            raise (LexError ("意外的字符: " ^ utf8_char, pos))
  else
    (* 不是中文数字，尝试关键字匹配 *)
    match try_match_keyword state with
    | Some (_, token, keyword_len) ->
        let new_state =
          {
            state with
            position = state.position + keyword_len;
            current_column = state.current_column + keyword_len;
          }
        in
        (token, pos, new_state)
    | None ->
        (* 不是关键字，检查是否为ASCII字母 *)
        let (utf8_char, _) = next_utf8_char state.input state.position in
        if String.length utf8_char = 1 then
          let cur_char = utf8_char.[0] in
          if (cur_char >= 'a' && cur_char <= 'z') || (cur_char >= 'A' && cur_char <= 'Z') then
            raise (LexError ("ASCII字母已禁用，请使用中文标识符。禁用字母: " ^ String.make 1 cur_char, pos))
          else
            raise (LexError ("意外的字符: " ^ utf8_char, pos))
        else
          raise (LexError ("意外的字符: " ^ utf8_char, pos))

(** 尝试匹配关键字 *)
and try_match_keyword state =
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
                let next_utf8_char, _ = next_utf8_char state.input next_pos in
                (* 修复UTF-8边界检查 *)
                if String.length next_utf8_char = 1 then
                  let next_char = next_utf8_char.[0] in
                  if is_separator_char next_char || next_char = ' ' || next_char = '\t' || next_char = '\n' then true
                  else if is_digit next_char then true  (* 允许关键字后面跟数字 *)
                  else if next_char >= 'a' && next_char <= 'z' then false
                  else if next_char >= 'A' && next_char <= 'Z' then false
                  else true
                else
                  (* 对于UTF-8字符，允许中文关键字匹配 *)
                  (* 简化：总是允许中文关键字匹配 *)
                  true
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
    (List.map (fun (str, variant) -> (str, variant_to_token variant)) Keyword_tables.Keywords.all_keywords_list)
    None

(** 读取字符串字面量 *)
let read_string_literal state : (token * lexer_state) =
  let rec read state acc =
    match current_char state with
    | Some c when Char.code c = 0xE3 && check_utf8_char state 0xE3 0x80 0x8F ->
        (* 』 (U+300F) - 结束字符串字面量 *)
        let new_state =
          { state with position = state.position + 3; current_column = state.current_column + 1 }
        in
        (StringToken acc, new_state)
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
            raise (LexError ("Unterminated string", {
                     line = state.current_line;
                     column = state.current_column;
                     filename = state.filename;
                   })))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None ->
        raise (LexError ("Unterminated string", {
                 line = state.current_line;
                 column = state.current_column;
                 filename = state.filename;
               }))
  in
  read state ""

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

(** 读取引用标识符 *)
let read_quoted_identifier state =
  let rec loop pos acc =
    if pos >= state.length then
      failwith "未闭合的引用标识符"
    else
      let ch, next_pos = next_utf8_char state.input pos in
      if ch = "」" then (acc, next_pos) (* 找到结束引号，返回内容和新位置 *)
      else if ch = "" then
        failwith "引用标识符中的无效字符"
      else loop next_pos (acc ^ ch)
  in
  let identifier, new_pos = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  let token = QuotedIdentifierToken identifier in
  (token, { state with position = new_pos; current_column = new_col })

(** 获取下一个词元 *)
let next_token state : (token * position * lexer_state) =
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
            | None -> (
              (* 检查当前字符是否存在 *)
              if state.position >= state.length then (EOF, pos, state)
              else (
                (* 尝试获取UTF-8字符 *)
                let (utf8_char, _next_pos) = next_utf8_char state.input state.position in
                if utf8_char = "" then (EOF, pos, state)
                else if utf8_char = "\n" then (Newline, pos, advance state)
                else if utf8_char = "\"" then
                  raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: \"", pos))
                else if String.length utf8_char = 1 then (
                    let c = utf8_char.[0] in
                    match c with
                    | ( '+' | '-' | '*' | '/' | '%' | '^' | '=' | '<' | '>' | '.' | '(' | ')' | '['
                       | ']' | '{' | '}' | ',' | ';' | ':' | '!' | '|' | '_' | '@' | '#' | '$' | '&'
                       | '?' | '\'' | '`' | '~' ) ->
                        raise (LexError ("ASCII符号已禁用，请使用中文标点符号。禁用字符: " ^ String.make 1 c, pos))
                    | _ when is_digit c ->
                        (* 阿拉伯数字 *)
                        let token, new_state = read_arabic_number state in
                        (token, pos, new_state)
                    | _ when is_letter_or_chinese c ->
                        handle_letter_or_chinese_char state pos
                    | _ ->
                        (* 其他ASCII字符，报错 *)
                        raise (LexError ("意外的字符: " ^ String.make 1 c, pos))
                  )
                else if utf8_char = "『" then
                  (* 『 (U+300E) - 开始字符串字面量 *)
                  let skip_state =
                    {
                      state with
                      position = state.position + 3;
                      current_column = state.current_column + 1;
                    }
                  in
                  let (token, new_state) = read_string_literal skip_state in
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
                  if is_chinese_utf8 utf8_char || Keyword_matcher.is_keyword utf8_char then
                    handle_letter_or_chinese_char state pos
                  else
                    (* 不支持的多字节字符 *)
                    raise (LexError ("意外的字符: " ^ utf8_char, pos))
                else
                  (* 单字节字符，应该在前面处理过，这里是fallback *)
                  raise (LexError ("意外的字符: " ^ utf8_char, pos))
                )
              ))
      with
      | LexError (msg, pos) -> raise (LexError (msg, pos))
  )

(** 词法分析主函数 *)
let tokenize input filename : positioned_token list =
  let rec analyze state acc =
    let (token, pos, new_state) = next_token state in
    let positioned_token = (token, pos) in
    (match token with
     | EOF -> List.rev (positioned_token :: acc)
     | Newline -> analyze new_state (positioned_token :: acc)
     | _ -> analyze new_state (positioned_token :: acc))
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []