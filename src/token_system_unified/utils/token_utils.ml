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
  let rec token_to_debug_string = function
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
