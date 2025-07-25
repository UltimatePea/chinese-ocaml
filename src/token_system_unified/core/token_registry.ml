(** 骆言Token系统整合重构 - Token注册和管理系统 提供统一的Token注册、查找、分类和管理功能 *)

open Yyocamlc_lib.Token_types

type t = {
  keywords : (string, Keywords.keyword_token) Hashtbl.t;
  operators : (string, Operators.operator_token) Hashtbl.t;
  delimiters : (string, Delimiters.delimiter_token) Hashtbl.t;
  token_counter : int ref;
  creation_time : float;
}
(** Token注册表类型 *)

(** 创建新的Token注册表 *)
let create () =
  {
    keywords = Hashtbl.create 64;
    operators = Hashtbl.create 32;
    delimiters = Hashtbl.create 16;
    token_counter = ref 0;
    creation_time = Unix.time ();
  }

(** 获取下一个Token ID *)
let next_token_id registry =
  incr registry.token_counter;
  !(registry.token_counter)

(** 注册关键字 *)
let register_keyword registry ~key ~keyword = Hashtbl.replace registry.keywords key keyword

(** 注册操作符 *)
let register_operator registry ~key ~operator = Hashtbl.replace registry.operators key operator

(** 注册分隔符 *)
let register_delimiter registry ~key ~delimiter = Hashtbl.replace registry.delimiters key delimiter

(** 查找关键字 *)
let lookup_keyword registry key = Hashtbl.find_opt registry.keywords key

(** 查找操作符 *)
let lookup_operator registry key = Hashtbl.find_opt registry.operators key

(** 查找分隔符 *)
let lookup_delimiter registry key = Hashtbl.find_opt registry.delimiters key

(** 通用Token查找 *)
let lookup_token registry key =
  match lookup_keyword registry key with
  | Some kw -> Some (KeywordToken kw)
  | None -> (
      match lookup_operator registry key with
      | Some op -> Some (OperatorToken op)
      | None -> (
          match lookup_delimiter registry key with Some del -> Some (DelimiterToken del) | None -> None))

(** 检查Token是否已注册 *)
let is_registered registry key =
  match lookup_token registry key with Some _ -> true | None -> false

(** 获取所有已注册的关键字 *)
let get_all_keywords registry = Hashtbl.fold (fun k v acc -> (k, v) :: acc) registry.keywords []

(** 获取所有已注册的操作符 *)
let get_all_operators registry = Hashtbl.fold (fun k v acc -> (k, v) :: acc) registry.operators []

(** 获取所有已注册的分隔符 *)
let get_all_delimiters registry = Hashtbl.fold (fun k v acc -> (k, v) :: acc) registry.delimiters []

(** 获取Token的文本表示 *)
let get_token_text token =
  match token with
  | KeywordToken _ -> Some "keyword"
  | OperatorToken _ -> Some "operator"
  | DelimiterToken _ -> Some "delimiter"
  | LiteralToken _ -> Some "literal"
  | IdentifierToken _ -> Some "identifier"
  | SpecialToken _ -> Some "special"

(** 获取注册表统计信息 *)
let get_stats registry =
  {|
  关键字数量: |}
  ^ string_of_int (Hashtbl.length registry.keywords)
  ^ {|
  操作符数量: |}
  ^ string_of_int (Hashtbl.length registry.operators)
  ^ {|
  分隔符数量: |}
  ^ string_of_int (Hashtbl.length registry.delimiters)
  ^ {|
  Token总数: |}
  ^ string_of_int !(registry.token_counter)
  ^ {|
  创建时间: |}
  ^ string_of_float registry.creation_time

(** 清空注册表 *)
let clear registry =
  Hashtbl.clear registry.keywords;
  Hashtbl.clear registry.operators;
  Hashtbl.clear registry.delimiters;
  registry.token_counter := 0

(** 注册表大小 *)
let size registry =
  Hashtbl.length registry.keywords + Hashtbl.length registry.operators
  + Hashtbl.length registry.delimiters

(** 默认Token注册表初始化 *)
let init_default_registry () =
  let registry = create () in

  (* 注册基础关键字 *)
  register_keyword registry ~key:"让" ~keyword:LetKeyword;
  register_keyword registry ~key:"如果" ~keyword:IfKeyword;
  register_keyword registry ~key:"那么" ~keyword:ThenKeyword;
  register_keyword registry ~key:"否则" ~keyword:ElseKeyword;
  register_keyword registry ~key:"函数" ~keyword:FunKeyword;
  register_keyword registry ~key:"递归" ~keyword:RecKeyword;

  (* 注册类型关键字 *)
  register_keyword registry ~key:"整数" ~keyword:TypeKeyword;
  register_keyword registry ~key:"小数" ~keyword:TypeKeyword;
  register_keyword registry ~key:"字符串" ~keyword:TypeKeyword;
  register_keyword registry ~key:"布尔" ~keyword:TypeKeyword;
  register_keyword registry ~key:"列表" ~keyword:TypeKeyword;
  register_keyword registry ~key:"类型" ~keyword:TypeKeyword;

  (* 注册控制流关键字 *)
  register_keyword registry ~key:"匹配" ~keyword:MatchKeyword;
  register_keyword registry ~key:"与" ~keyword:WithKeyword;
  register_keyword registry ~key:"当" ~keyword:WhenKeyword;
  register_keyword registry ~key:"尝试" ~keyword:TryKeyword;
  register_keyword registry ~key:"循环" ~keyword:OtherKeyword;
  register_keyword registry ~key:"遍历" ~keyword:OtherKeyword;

  (* 注册算术操作符 *)
  register_operator registry ~key:"+" ~operator:Plus;
  register_operator registry ~key:"-" ~operator:Minus;
  register_operator registry ~key:"*" ~operator:Multiply;
  register_operator registry ~key:"/" ~operator:Divide;
  register_operator registry ~key:"%" ~operator:Modulo;
  register_operator registry ~key:"**" ~operator:Power;

  (* 注册比较操作符 *)
  register_operator registry ~key:"=" ~operator:Equal;
  register_operator registry ~key:"!=" ~operator:NotEqual;
  register_operator registry ~key:"<" ~operator:LessThan;
  register_operator registry ~key:"<=" ~operator:LessEqual;
  register_operator registry ~key:">" ~operator:GreaterThan;
  register_operator registry ~key:">=" ~operator:GreaterEqual;

  (* 注册分隔符 *)
  register_delimiter registry ~key:"(" ~delimiter:LeftParen;
  register_delimiter registry ~key:")" ~delimiter:RightParen;
  register_delimiter registry ~key:"[" ~delimiter:LeftBracket;
  register_delimiter registry ~key:"]" ~delimiter:RightBracket;
  register_delimiter registry ~key:"{" ~delimiter:LeftBrace;
  register_delimiter registry ~key:"}" ~delimiter:RightBrace;
  register_delimiter registry ~key:"," ~delimiter:Comma;
  register_delimiter registry ~key:";" ~delimiter:Semicolon;

  registry

(** 全局默认注册表 *)
let default_registry = lazy (init_default_registry ())

(** 获取默认注册表 *)
let get_default_registry () = Lazy.force default_registry
