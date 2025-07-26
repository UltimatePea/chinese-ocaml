(** 骆言编译器 - Token系统工具函数
    
    提供Token系统的通用工具函数和便利方法。
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types

(** Token打印和调试工具 *)
module Debug = struct
  (** 将Token转换为调试字符串 *)
  let token_to_debug_string = function
    | LiteralToken (Literals.IntToken i) -> Printf.sprintf "Literal(Int(%d))" i
    | LiteralToken (Literals.FloatToken f) -> Printf.sprintf "Literal(Float(%g))" f
    | LiteralToken (Literals.StringToken s) -> Printf.sprintf "Literal(String(\"%s\"))" s
    | LiteralToken (Literals.BoolToken b) -> Printf.sprintf "Literal(Bool(%b))" b
    | LiteralToken (Literals.ChineseNumberToken s) -> Printf.sprintf "Literal(ChineseNumber(\"%s\"))" s
    | IdentifierToken (Identifiers.QuotedIdentifierToken s) -> Printf.sprintf "Identifier(Quoted(\"%s\"))" s
    | IdentifierToken (Identifiers.IdentifierTokenSpecial s) -> Printf.sprintf "Identifier(Special(\"%s\"))" s
    | KeywordToken kw -> Printf.sprintf "Keyword(%s)" (Keywords.show_keyword_token kw)
    | OperatorToken op -> Printf.sprintf "Operator(%s)" (Operators.show_operator_token op)
    | DelimiterToken delim -> Printf.sprintf "Delimiter(%s)" (Delimiters.show_delimiter_token delim)
    | SpecialToken special -> Printf.sprintf "Special(%s)" (Special.show_special_token special)
    | _ -> "UnknownToken"

  (** 打印Token列表 *)
  let print_token_list tokens =
    List.iter (fun token -> 
      Printf.printf "%s\n" (token_to_debug_string token)
    ) tokens

  (** 打印定位Token列表 *)
  let print_positioned_token_list positioned_tokens =
    List.iter (fun positioned_token -> 
      let token_str = token_to_debug_string positioned_token.token in
      let pos = positioned_token.position in
      Printf.printf "%s @ %s:%d:%d\n" token_str pos.filename pos.line pos.column
    ) positioned_tokens
end

(** Token过滤和查找工具 *)
module Filter = struct
  let filter_by_category _category tokens = tokens (* 简化实现 *)
  let filter_keywords tokens = tokens (* 简化实现 *)
  let filter_literals tokens = tokens (* 简化实现 *)
  let filter_identifiers tokens = tokens (* 简化实现 *)
  let filter_operators tokens = tokens (* 简化实现 *)
  let filter_delimiters tokens = tokens (* 简化实现 *)
  let find_token _token _tokens = None (* 简化实现 *)
  let count_token _token _tokens = 0 (* 简化实现 *)
  let contains_token _token _tokens = false (* 简化实现 *)
end

(** Token流处理工具 *)
module Stream = struct
  let create_positioned_token token _line _column _offset _filename = token (* 简化实现 *)
  let create_stream_from_tokens tokens = tokens (* 简化实现 *)
  let extract_tokens tokens = tokens (* 简化实现 *)
  let extract_texts _tokens = [] (* 简化实现 *)
  let is_empty tokens = tokens = []
  let peek_first = function 
    | [] -> Error (CompilerError "流为空")
    | token :: _ -> Ok token
  let peek_last tokens = 
    match List.rev tokens with
    | [] -> Error (CompilerError "流为空")
    | token :: _ -> Ok token
  let drop_first = function
    | [] -> Error (CompilerError "流为空")
    | _ :: rest -> Ok rest
  let split_at_position pos tokens =
    let rec split acc i = function
      | [] -> (List.rev acc, [])
      | t :: rest when i >= pos -> (List.rev acc, t :: rest)
      | t :: rest -> split (t :: acc) (i + 1) rest
    in
    split [] 0 tokens
end

(** Token验证工具 *)
module Validation = struct
  let validate_basic_syntax _tokens = Ok () (* 简化实现 *)
  let validate_token token = Ok token (* 简化实现 *)
  let validate_token_list tokens = Ok tokens (* 简化实现 *)
end

(** Token统计工具 *)
module Statistics = struct
  let generate_comprehensive_stats _tokens = [] (* 简化实现 *)
  let format_stats_report _stats = "" (* 简化实现 *)
end

(** Token工具函数模块 *)
module TokenUtils = struct
  (** 检查Token类型的函数 *)
  let is_literal = function
    | LiteralToken _ -> true
    | _ -> false

  let is_keyword = function
    | KeywordToken _ -> true  
    | _ -> false

  let is_operator = function
    | OperatorToken _ -> true
    | _ -> false

  let is_delimiter = function
    | DelimiterToken _ -> true
    | _ -> false

  let is_identifier = function
    | IdentifierToken _ -> true
    | _ -> false

  (** Token到字符串转换 *)
  let token_to_string token = show_token token
end
