(** 骆言编译器 - Token系统工具函数
    
    提供Token系统的通用工具函数和便利方法。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Token_system_core.Token_errors

(** Token打印和调试工具 *)
module Debug = struct
  (** 将Token转换为调试字符串 *)
  let rec token_to_debug_string = function
    | Literal (IntToken i) -> Printf.sprintf "Literal(Int(%d))" i
    | Literal (FloatToken f) -> Printf.sprintf "Literal(Float(%g))" f
    | Literal (StringToken s) -> Printf.sprintf "Literal(String(\"%s\"))" s
    | Literal (BoolToken b) -> Printf.sprintf "Literal(Bool(%b))" b
    | Literal (ChineseNumberToken s) -> Printf.sprintf "Literal(ChineseNumber(\"%s\"))" s
    | Identifier (SimpleIdentifier s) -> Printf.sprintf "Identifier(Simple(\"%s\"))" s
    | Identifier (QuotedIdentifierToken s) -> Printf.sprintf "Identifier(Quoted(\"%s\"))" s
    | Identifier (IdentifierTokenSpecial s) -> Printf.sprintf "Identifier(Special(\"%s\"))" s
    | CoreLanguage keyword -> Printf.sprintf "CoreLanguage(%s)" (core_keyword_to_string keyword)
    | Semantic keyword -> Printf.sprintf "Semantic(%s)" (semantic_keyword_to_string keyword)
    | ErrorHandling keyword -> Printf.sprintf "ErrorHandling(%s)" (error_keyword_to_string keyword)
    | ModuleSystem keyword -> Printf.sprintf "ModuleSystem(%s)" (module_keyword_to_string keyword)
    | MacroSystem keyword -> Printf.sprintf "MacroSystem(%s)" (macro_keyword_to_string keyword)
    | Wenyan keyword -> Printf.sprintf "Wenyan(%s)" (wenyan_keyword_to_string keyword)
    | Ancient keyword -> Printf.sprintf "Ancient(%s)" (ancient_keyword_to_string keyword)
    | NaturalLanguage keyword ->
        Printf.sprintf "NaturalLanguage(%s)" (natural_keyword_to_string keyword)
    | Operator op -> Printf.sprintf "Operator(%s)" (operator_to_string op)
    | Delimiter delim -> Printf.sprintf "Delimiter(%s)" (delimiter_to_string delim)
    | Special special -> Printf.sprintf "Special(%s)" (special_to_string special)

  (** 关键字子类型转字符串 *)
  and core_keyword_to_string = function
    | LetKeyword -> "Let"
    | RecKeyword -> "Rec"
    | InKeyword -> "In"
    | FunKeyword -> "Fun"
    | ParamKeyword -> "Param"
    | IfKeyword -> "If"
    | ThenKeyword -> "Then"
    | ElseKeyword -> "Else"
    | MatchKeyword -> "Match"
    | WithKeyword -> "With"
    | OtherKeyword -> "Other"
    | TypeKeyword -> "Type"
    | PrivateKeyword -> "Private"
    | OfKeyword -> "Of"
    | TrueKeyword -> "True"
    | FalseKeyword -> "False"
    | AndKeyword -> "And"
    | OrKeyword -> "Or"
    | NotKeyword -> "Not"

  and semantic_keyword_to_string = function
    | AsKeyword -> "As"
    | CombineKeyword -> "Combine"
    | WithOpKeyword -> "WithOp"
    | WhenKeyword -> "When"

  and error_keyword_to_string = function
    | OrElseKeyword -> "OrElse"
    | WithDefaultKeyword -> "WithDefault"
    | ExceptionKeyword -> "Exception"
    | RaiseKeyword -> "Raise"
    | TryKeyword -> "Try"
    | CatchKeyword -> "Catch"
    | FinallyKeyword -> "Finally"

  and module_keyword_to_string = function
    | ModuleKeyword -> "Module"
    | ModuleTypeKeyword -> "ModuleType"
    | SigKeyword -> "Sig"
    | EndKeyword -> "End"
    | FunctorKeyword -> "Functor"
    | IncludeKeyword -> "Include"
    | RefKeyword -> "Ref"

  and macro_keyword_to_string = function MacroKeyword -> "Macro" | ExpandKeyword -> "Expand"

  and wenyan_keyword_to_string = function
    | HaveKeyword -> "Have"
    | OneKeyword -> "One"
    | NameKeyword -> "Name"
    | SetKeyword -> "Set"
    | AlsoKeyword -> "Also"
    | ThenGetKeyword -> "ThenGet"
    | CallKeyword -> "Call"
    | ValueKeyword -> "Value"
    | AsForKeyword -> "AsFor"
    | NumberKeyword -> "Number"
    | WantExecuteKeyword -> "WantExecute"
    | MustFirstGetKeyword -> "MustFirstGet"
    | ForThisKeyword -> "ForThis"
    | TimesKeyword -> "Times"
    | EndCloudKeyword -> "EndCloud"
    | IfWenyanKeyword -> "IfWenyan"
    | ThenWenyanKeyword -> "ThenWenyan"
    | GreaterThanWenyan -> "GreaterThanWenyan"
    | LessThanWenyan -> "LessThanWenyan"

  and ancient_keyword_to_string = function
    | AncientDefineKeyword -> "Define"
    | AncientEndKeyword -> "End"
    | AncientAlgorithmKeyword -> "Algorithm"
    | AncientCompleteKeyword -> "Complete"
    | AncientObserveKeyword -> "Observe"
    | AncientNatureKeyword -> "Nature"
    | AncientIfKeyword -> "If"
    | AncientThenKeyword -> "Then"
    | AncientOtherwiseKeyword -> "Otherwise"
    | AncientAnswerKeyword -> "Answer"
    | AncientRecursiveKeyword -> "Recursive"
    | AncientCombineKeyword -> "Combine"
    | AncientAsOneKeyword -> "AsOne"
    | AncientTakeKeyword -> "Take"
    | AncientReceiveKeyword -> "Receive"
    | AncientParticleOf -> "ParticleOf"
    | AncientParticleFun -> "ParticleFun"
    | AncientParticleThe -> "ParticleThe"
    | AncientCallItKeyword -> "CallIt"
    | AncientEmptyKeyword -> "Empty"
    | AncientIsKeyword -> "Is"
    | AncientArrowKeyword -> "Arrow"
    | AncientWhenKeyword -> "When"
    | AncientCommaKeyword -> "Comma"
    | AncientPeriodKeyword -> "Period"
    | AfterThatKeyword -> "AfterThat"

  and natural_keyword_to_string = function
    | DefineKeyword -> "Define"
    | AcceptKeyword -> "Accept"
    | ReturnWhenKeyword -> "ReturnWhen"
    | ElseReturnKeyword -> "ElseReturn"
    | MultiplyKeyword -> "Multiply"
    | DivideKeyword -> "Divide"
    | AddToKeyword -> "AddTo"
    | SubtractKeyword -> "Subtract"
    | IsKeyword -> "Is"
    | EqualToKeyword -> "EqualTo"
    | LessThanEqualToKeyword -> "LessThanEqualTo"
    | FirstElementKeyword -> "FirstElement"
    | RemainingKeyword -> "Remaining"
    | EmptyKeyword -> "Empty"
    | CharacterCountKeyword -> "CharacterCount"
    | OfParticle -> "OfParticle"

  and operator_to_string = function
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
    | DoubleArrow -> "=>"

  and delimiter_to_string = function
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
    | Underscore -> "_"

  and special_to_string = function
    | EOF -> "EOF"
    | Newline -> "Newline"
    | Whitespace _ -> "Whitespace"
    | Comment _ -> "Comment"

  (** 打印Token列表 *)
  let print_token_list tokens =
    List.iteri (fun i token -> Printf.printf "%d: %s\n" i (token_to_debug_string token)) tokens

  (** 打印positioned_token列表 *)
  let print_positioned_token_list positioned_tokens =
    List.iteri
      (fun i pt ->
        Printf.printf "%d: %s at line %d, col %d\n" i (token_to_debug_string pt.token)
          pt.position.line pt.position.column)
      positioned_tokens
end

(** Token过滤和查找工具 *)
module Filter = struct
  (** 按类别过滤Token *)
  let filter_by_category category tokens =
    List.filter (fun token -> get_token_category token = category) tokens

  (** 过滤出所有关键字 *)
  let filter_keywords tokens = filter_by_category CategoryKeyword tokens

  (** 过滤出所有字面量 *)
  let filter_literals tokens = filter_by_category CategoryLiteral tokens

  (** 过滤出所有标识符 *)
  let filter_identifiers tokens = filter_by_category CategoryIdentifier tokens

  (** 过滤出所有操作符 *)
  let filter_operators tokens = filter_by_category CategoryOperator tokens

  (** 过滤出所有分隔符 *)
  let filter_delimiters tokens = filter_by_category CategoryDelimiter tokens

  (** 查找特定Token *)
  let find_token target_token tokens = List.find_opt (fun token -> token = target_token) tokens

  (** 计算Token出现次数 *)
  let count_token target_token tokens =
    List.fold_left (fun count token -> if token = target_token then count + 1 else count) 0 tokens

  (** 检查是否包含特定Token *)
  let contains_token target_token tokens = List.exists (fun token -> token = target_token) tokens
end

(** Token流处理工具 *)
module Stream = struct
  (** 创建positioned_token *)
  let create_positioned_token token line column offset text =
    { token; position = { line; column; offset }; text }

  (** 从Token列表创建Token流 *)
  let create_stream_from_tokens tokens =
    List.mapi (fun i token -> create_positioned_token token 1 (i + 1) i "") tokens

  (** 提取Token流中的Token *)
  let extract_tokens stream = List.map (fun pt -> pt.token) stream

  (** 提取Token流中的文本 *)
  let extract_texts stream = List.map (fun pt -> pt.text) stream

  (** 检查Token流是否为空 *)
  let is_empty = function [] -> true | _ -> false

  (** 获取Token流的第一个Token *)
  let peek_first = function [] -> error_result EmptyTokenStream | pt :: _ -> ok_result pt.token

  (** 获取Token流的最后一个Token *)
  let peek_last = function
    | [] -> error_result EmptyTokenStream
    | stream ->
        let last_pt = List.hd (List.rev stream) in
        ok_result last_pt.token

  (** 移除Token流的第一个Token *)
  let drop_first = function [] -> error_result EmptyTokenStream | _ :: rest -> ok_result rest

  (** 分割Token流 *)
  let split_at_position n stream =
    let rec split acc remaining count =
      if count = 0 || remaining = [] then (List.rev acc, remaining)
      else
        match remaining with
        | pt :: rest -> split (pt :: acc) rest (count - 1)
        | [] -> (List.rev acc, [])
    in
    split [] stream n
end

(** Token验证工具 *)
module Validation = struct
  (** 验证Token流语法基础规则 *)
  let validate_basic_syntax stream =
    let tokens = Stream.extract_tokens stream in

    (* 检查括号匹配 *)
    let rec check_brackets stack = function
      | [] ->
          if stack = [] then ok_result ()
          else error_result (ParsingError ("括号不匹配", { line = 0; column = 0; offset = 0 }))
      | token :: rest -> (
          match token with
          | Delimiter LeftParen -> check_brackets ('(' :: stack) rest
          | Delimiter LeftBracket -> check_brackets ('[' :: stack) rest
          | Delimiter LeftBrace -> check_brackets ('{' :: stack) rest
          | Delimiter RightParen -> (
              match stack with
              | '(' :: remaining -> check_brackets remaining rest
              | _ -> error_result (ParsingError ("右括号无匹配", { line = 0; column = 0; offset = 0 })))
          | Delimiter RightBracket -> (
              match stack with
              | '[' :: remaining -> check_brackets remaining rest
              | _ -> error_result (ParsingError ("右方括号无匹配", { line = 0; column = 0; offset = 0 })))
          | Delimiter RightBrace -> (
              match stack with
              | '{' :: remaining -> check_brackets remaining rest
              | _ -> error_result (ParsingError ("右大括号无匹配", { line = 0; column = 0; offset = 0 })))
          | _ -> check_brackets stack rest)
    in
    check_brackets [] tokens

  (** 验证Token是否有效 *)
  let validate_token token =
    match token with
    | Literal _ | Identifier _ | CoreLanguage _ | Semantic _ | ErrorHandling _ | ModuleSystem _
    | MacroSystem _ | Wenyan _ | Ancient _ | NaturalLanguage _ | Operator _ | Delimiter _
    | Special _ ->
        ok_result token

  (** 验证Token列表 *)
  let validate_token_list tokens =
    let rec validate acc = function
      | [] -> ok_result (List.rev acc)
      | token :: rest -> (
          match validate_token token with
          | Ok validated_token -> validate (validated_token :: acc) rest
          | Error err -> error_result err)
    in
    validate [] tokens
end

(** Token统计工具 *)
module Statistics = struct
  (** 生成全面的Token统计 *)
  let generate_comprehensive_stats tokens =
    let total = List.length tokens in
    let by_category =
      [
        ("literals", List.length (Filter.filter_literals tokens));
        ("identifiers", List.length (Filter.filter_identifiers tokens));
        ("keywords", List.length (Filter.filter_keywords tokens));
        ("operators", List.length (Filter.filter_operators tokens));
        ("delimiters", List.length (Filter.filter_delimiters tokens));
      ]
    in
    let by_type =
      List.fold_left
        (fun acc token ->
          let type_name =
            match token with
            | Literal _ -> "literals"
            | Identifier _ -> "identifiers"
            | CoreLanguage _ -> "core_keywords"
            | Wenyan _ -> "wenyan_keywords"
            | Ancient _ -> "ancient_keywords"
            | NaturalLanguage _ -> "natural_keywords"
            | Operator _ -> "operators"
            | Delimiter _ -> "delimiters"
            | Special _ -> "special"
            | _ -> "other"
          in
          let current = try List.assoc type_name acc with Not_found -> 0 in
          (type_name, current + 1) :: List.remove_assoc type_name acc)
        [] tokens
    in
    (("total", total) :: by_category) @ by_type

  (** 格式化统计报告 *)
  let format_stats_report stats =
    let lines = [ "Token统计报告"; "============" ] in
    let stat_lines = List.map (fun (name, count) -> Printf.sprintf "%s: %d" name count) stats in
    String.concat "\n" (lines @ stat_lines)
end
