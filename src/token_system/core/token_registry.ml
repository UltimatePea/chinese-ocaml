(** 骆言编译器 - 统一Token注册表
    
    提供Token的注册、查找、转换等核心功能。
    整合原本分散在多个模块中的Token管理功能。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Token_types

type registry_stats = {
  total_tokens : int;
  literal_tokens : int;
  keyword_tokens : int;
  operator_tokens : int;
  delimiter_tokens : int;
}
(** Token注册表统计信息 *)

(** Token查找结果 *)
type lookup_result = Found of token | NotFound | Ambiguous of token list

module TokenMap = Map.Make (String)
(** Token映射表类型 *)

type registry = {
  string_to_token : token TokenMap.t;  (** 字符串到Token的映射 *)
  token_to_string : string TokenMap.t;  (** Token到字符串的映射 *)
  aliases : token TokenMap.t;  (** 别名到Token的映射 *)
  stats : registry_stats;  (** 注册表统计信息 *)
}
(** 内部注册表状态 *)

(** 全局注册表实例 *)
let registry =
  ref
    {
      string_to_token = TokenMap.empty;
      token_to_string = TokenMap.empty;
      aliases = TokenMap.empty;
      stats =
        {
          total_tokens = 0;
          literal_tokens = 0;
          keyword_tokens = 0;
          operator_tokens = 0;
          delimiter_tokens = 0;
        };
    }

(** 辅助函数：Token转换为字符串键 *)
let token_to_key = function
  | Literal (IntToken i) -> "int:" ^ string_of_int i
  | Literal (FloatToken f) -> "float:" ^ string_of_float f
  | Literal (ChineseNumberToken s) -> "chinese_num:" ^ s
  | Literal (StringToken s) -> "string:" ^ s
  | Literal (BoolToken b) -> "bool:" ^ string_of_bool b
  | Identifier (QuotedIdentifierToken s) -> "quoted_id:" ^ s
  | Identifier (IdentifierTokenSpecial s) -> "special_id:" ^ s
  | Identifier (SimpleIdentifier s) -> "simple_id:" ^ s
  | CoreLanguage tok -> (
      "core:"
      ^
      match tok with
      | LetKeyword -> "let"
      | RecKeyword -> "rec"
      | InKeyword -> "in"
      | FunKeyword -> "fun"
      | ParamKeyword -> "param"
      | IfKeyword -> "if"
      | ThenKeyword -> "then"
      | ElseKeyword -> "else"
      | MatchKeyword -> "match"
      | WithKeyword -> "with"
      | OtherKeyword -> "other"
      | TypeKeyword -> "type"
      | PrivateKeyword -> "private"
      | OfKeyword -> "of"
      | TrueKeyword -> "true"
      | FalseKeyword -> "false"
      | AndKeyword -> "and"
      | OrKeyword -> "or"
      | NotKeyword -> "not")
  | Semantic tok -> (
      "semantic:"
      ^
      match tok with
      | AsKeyword -> "as"
      | CombineKeyword -> "combine"
      | WithOpKeyword -> "with_op"
      | WhenKeyword -> "when")
  | ErrorHandling tok -> (
      "error:"
      ^
      match tok with
      | OrElseKeyword -> "or_else"
      | WithDefaultKeyword -> "with_default"
      | ExceptionKeyword -> "exception"
      | RaiseKeyword -> "raise"
      | TryKeyword -> "try"
      | CatchKeyword -> "catch"
      | FinallyKeyword -> "finally")
  | ModuleSystem tok -> (
      "module:"
      ^
      match tok with
      | ModuleKeyword -> "module"
      | ModuleTypeKeyword -> "module_type"
      | SigKeyword -> "sig"
      | EndKeyword -> "end"
      | FunctorKeyword -> "functor"
      | IncludeKeyword -> "include"
      | RefKeyword -> "ref")
  | MacroSystem tok -> (
      "macro:" ^ match tok with MacroKeyword -> "macro" | ExpandKeyword -> "expand")
  | Wenyan tok -> (
      "wenyan:"
      ^
      match tok with
      | HaveKeyword -> "have"
      | OneKeyword -> "one"
      | NameKeyword -> "name"
      | SetKeyword -> "set"
      | AlsoKeyword -> "also"
      | ThenGetKeyword -> "then_get"
      | CallKeyword -> "call"
      | ValueKeyword -> "value"
      | AsForKeyword -> "as_for"
      | NumberKeyword -> "number"
      | WantExecuteKeyword -> "want_execute"
      | MustFirstGetKeyword -> "must_first_get"
      | ForThisKeyword -> "for_this"
      | TimesKeyword -> "times"
      | EndCloudKeyword -> "end_cloud"
      | IfWenyanKeyword -> "if_wenyan"
      | ThenWenyanKeyword -> "then_wenyan"
      | GreaterThanWenyan -> "gt_wenyan"
      | LessThanWenyan -> "lt_wenyan")
  | Ancient tok -> (
      "ancient:"
      ^
      match tok with
      | AncientDefineKeyword -> "define"
      | AncientEndKeyword -> "end"
      | AncientAlgorithmKeyword -> "algorithm"
      | AncientCompleteKeyword -> "complete"
      | AncientObserveKeyword -> "observe"
      | AncientNatureKeyword -> "nature"
      | AncientIfKeyword -> "if"
      | AncientThenKeyword -> "then"
      | AncientOtherwiseKeyword -> "otherwise"
      | AncientAnswerKeyword -> "answer"
      | AncientRecursiveKeyword -> "recursive"
      | AncientCombineKeyword -> "combine"
      | AncientAsOneKeyword -> "as_one"
      | AncientTakeKeyword -> "take"
      | AncientReceiveKeyword -> "receive"
      | AncientParticleOf -> "particle_of"
      | AncientParticleFun -> "particle_fun"
      | AncientParticleThe -> "particle_the"
      | AncientCallItKeyword -> "call_it"
      | AncientEmptyKeyword -> "empty"
      | AncientIsKeyword -> "is"
      | AncientArrowKeyword -> "arrow"
      | AncientWhenKeyword -> "when"
      | AncientCommaKeyword -> "comma"
      | AncientPeriodKeyword -> "period"
      | AfterThatKeyword -> "after_that")
  | NaturalLanguage tok -> (
      "natural:"
      ^
      match tok with
      | DefineKeyword -> "define"
      | AcceptKeyword -> "accept"
      | ReturnWhenKeyword -> "return_when"
      | ElseReturnKeyword -> "else_return"
      | MultiplyKeyword -> "multiply"
      | DivideKeyword -> "divide"
      | AddToKeyword -> "add_to"
      | SubtractKeyword -> "subtract"
      | IsKeyword -> "is"
      | EqualToKeyword -> "equal_to"
      | LessThanEqualToKeyword -> "lte"
      | FirstElementKeyword -> "first_element"
      | RemainingKeyword -> "remaining"
      | EmptyKeyword -> "empty"
      | CharacterCountKeyword -> "char_count"
      | OfParticle -> "of_particle")
  | Operator tok -> (
      "op:"
      ^
      match tok with
      | Plus -> "+"
      | Minus -> "-"
      | Multiply -> "*"
      | Divide -> "/"
      | Equal -> "="
      | NotEqual -> "<>"
      | LessThan -> "<"
      | LessThanOrEqual -> "<="
      | GreaterThan -> ">"
      | GreaterThanOrEqual -> ">="
      | LogicalAnd -> "&&"
      | LogicalOr -> "||"
      | Assignment -> ":="
      | Arrow -> "->"
      | DoubleArrow -> "=>")
  | Delimiter tok -> (
      "delim:"
      ^
      match tok with
      | LeftParen -> "("
      | RightParen -> ")"
      | LeftBracket -> "["
      | RightBracket -> "]"
      | LeftBrace -> "{"
      | RightBrace -> "}"
      | Semicolon -> ";"
      | Comma -> ","
      | Dot -> "."
      | Colon -> ":"
      | DoubleColon -> "::"
      | Pipe -> "|"
      | Underscore -> "_")
  | Special tok -> (
      "special:"
      ^
      match tok with
      | EOF -> "eof"
      | Newline -> "newline"
      | Whitespace _ -> "whitespace"
      | Comment _ -> "comment")

(** 注册Token到注册表 *)
let register_token token chinese_text aliases =
  let key = token_to_key token in
  let current = !registry in
  let new_string_to_token = TokenMap.add chinese_text token current.string_to_token in
  let new_token_to_string = TokenMap.add key chinese_text current.token_to_string in
  let new_aliases =
    List.fold_left (fun acc alias -> TokenMap.add alias token acc) current.aliases aliases
  in
  let category = get_token_category token in
  let new_stats =
    {
      total_tokens = current.stats.total_tokens + 1;
      literal_tokens = (current.stats.literal_tokens + if category = CategoryLiteral then 1 else 0);
      keyword_tokens = (current.stats.keyword_tokens + if category = CategoryKeyword then 1 else 0);
      operator_tokens =
        (current.stats.operator_tokens + if category = CategoryOperator then 1 else 0);
      delimiter_tokens =
        (current.stats.delimiter_tokens + if category = CategoryDelimiter then 1 else 0);
    }
  in
  registry :=
    {
      string_to_token = new_string_to_token;
      token_to_string = new_token_to_string;
      aliases = new_aliases;
      stats = new_stats;
    }

(** 根据中文文本查找Token *)
let lookup_token_by_text text =
  let current = !registry in
  try Found (TokenMap.find text current.string_to_token)
  with Not_found -> ( try Found (TokenMap.find text current.aliases) with Not_found -> NotFound)

(** 根据Token获取中文文本 *)
let get_token_text token =
  let key = token_to_key token in
  let current = !registry in
  try Some (TokenMap.find key current.token_to_string) with Not_found -> None

(** 获取注册表统计信息 *)
let get_stats () = !registry.stats

(** 清空注册表 *)
let clear_registry () =
  registry :=
    {
      string_to_token = TokenMap.empty;
      token_to_string = TokenMap.empty;
      aliases = TokenMap.empty;
      stats =
        {
          total_tokens = 0;
          literal_tokens = 0;
          keyword_tokens = 0;
          operator_tokens = 0;
          delimiter_tokens = 0;
        };
    }

(** 批量注册Token *)
let register_tokens token_list =
  List.iter (fun (token, text, aliases) -> register_token token text aliases) token_list

(** 检查Token是否已注册 *)
let is_registered token =
  let key = token_to_key token in
  let current = !registry in
  TokenMap.mem key current.token_to_string

(** 获取所有已注册的Token *)
let get_all_tokens () =
  let current = !registry in
  TokenMap.fold (fun _ token acc -> token :: acc) current.string_to_token []

(** 根据类别获取Token列表 *)
let get_tokens_by_category category =
  get_all_tokens () |> List.filter (fun token -> get_token_category token = category)

(** 初始化默认Token注册 *)
let initialize_default_tokens () =
  let default_registrations =
    [
      (* 核心语言关键字 *)
      (CoreLanguage LetKeyword, "让", [ "let" ]);
      (CoreLanguage RecKeyword, "递归", [ "rec" ]);
      (CoreLanguage InKeyword, "在", [ "in" ]);
      (CoreLanguage FunKeyword, "函数", [ "fun"; "λ" ]);
      (CoreLanguage IfKeyword, "如果", [ "if" ]);
      (CoreLanguage ThenKeyword, "那么", [ "then" ]);
      (CoreLanguage ElseKeyword, "否则", [ "else" ]);
      (CoreLanguage MatchKeyword, "匹配", [ "match" ]);
      (CoreLanguage WithKeyword, "与", [ "with" ]);
      (CoreLanguage TrueKeyword, "真", [ "true"; "是" ]);
      (CoreLanguage FalseKeyword, "假", [ "false"; "否" ]);
      (* 操作符 *)
      (Operator Plus, "加", [ "+" ]);
      (Operator Minus, "减", [ "-" ]);
      (Operator Multiply, "乘", [ "*"; "×" ]);
      (Operator Divide, "除", [ "/"; "÷" ]);
      (Operator Equal, "等于", [ "=" ]);
      (Operator NotEqual, "不等于", [ "<>"; "≠" ]);
      (Operator LessThan, "小于", [ "<" ]);
      (Operator GreaterThan, "大于", [ ">" ]);
      (Operator Assignment, "赋值", [ ":=" ]);
      (Operator Arrow, "箭头", [ "->" ]);
      (* 分隔符 *)
      (Delimiter LeftParen, "左括号", [ "(" ]);
      (Delimiter RightParen, "右括号", [ ")" ]);
      (Delimiter LeftBracket, "左方括号", [ "[" ]);
      (Delimiter RightBracket, "右方括号", [ "]" ]);
      (Delimiter Semicolon, "分号", [ ";" ]);
      (Delimiter Comma, "逗号", [ "," ]);
      (* 文言文关键字 *)
      (Wenyan HaveKeyword, "吾有", []);
      (Wenyan NameKeyword, "名曰", []);
      (Wenyan CallKeyword, "曰", []);
      (Wenyan AlsoKeyword, "也", []);
      (* 古雅体关键字 *)
      (Ancient AncientDefineKeyword, "夫", []);
      (Ancient AncientAnswerKeyword, "答", []);
      (Ancient AncientIfKeyword, "若", []);
      (Ancient AncientThenKeyword, "则", []);
    ]
  in
  register_tokens default_registrations
