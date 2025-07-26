(** 骆言Token系统整合重构 - Token注册和管理系统 提供统一的Token注册、查找、分类和管理功能 *)

open Token_types

type t = {
  keywords : (string, keyword_type) Hashtbl.t;
  operators : (string, operator_type) Hashtbl.t;
  delimiters : (string, delimiter_type) Hashtbl.t;
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
  | Some kw -> Some (KeywordToken (match kw with Basic k | Type k | Control k | Module k -> k))
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
  | KeywordToken kw -> Some (Token_types.Keywords.show_keyword_token (match kw with Basic k | Type k | Control k | Module k -> k))
  | OperatorToken op -> Some (Token_types.Operators.show_operator_token op)
  | DelimiterToken del -> Some (Token_types.Delimiters.show_delimiter_token del)
  | LiteralToken lit -> Some (Token_types.Literals.show_literal_token lit)
  | IdentifierToken id -> Some (Token_types.Identifiers.show_identifier_token id)
  | SpecialToken sp -> Some (Token_types.Special.show_special_token sp)

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
  register_keyword registry ~key:"让" ~keyword:(Basic LetKeyword);
  register_keyword registry ~key:"如果" ~keyword:(Basic IfKeyword);
  register_keyword registry ~key:"那么" ~keyword:(Basic ThenKeyword);
  register_keyword registry ~key:"否则" ~keyword:(Basic ElseKeyword);
  register_keyword registry ~key:"函数" ~keyword:(Basic FunctionKeyword);
  register_keyword registry ~key:"递归" ~keyword:(Basic RecKeyword);

  (* 注册类型关键字 *)
  register_keyword registry ~key:"整数" ~keyword:(Type IntKeyword);
  register_keyword registry ~key:"小数" ~keyword:(Type FloatKeyword);
  register_keyword registry ~key:"字符串" ~keyword:(Type StringKeyword);
  register_keyword registry ~key:"布尔" ~keyword:(Type BoolKeyword);
  register_keyword registry ~key:"列表" ~keyword:(Type ListKeyword);
  register_keyword registry ~key:"类型" ~keyword:(Type TypeKeyword);

  (* 注册控制流关键字 *)
  register_keyword registry ~key:"匹配" ~keyword:(Control MatchKeyword);
  register_keyword registry ~key:"与" ~keyword:(Control WithKeyword);
  register_keyword registry ~key:"当" ~keyword:(Control WhenKeyword);
  register_keyword registry ~key:"尝试" ~keyword:(Control TryKeyword);
  register_keyword registry ~key:"循环" ~keyword:(Control WhileKeyword);
  register_keyword registry ~key:"遍历" ~keyword:(Control ForKeyword);

  (* 注册算术操作符 *)
  register_operator registry ~key:"+" ~operator:(Arithmetic Plus);
  register_operator registry ~key:"-" ~operator:(Arithmetic Minus);
  register_operator registry ~key:"*" ~operator:(Arithmetic Multiply);
  register_operator registry ~key:"/" ~operator:(Arithmetic Divide);
  register_operator registry ~key:"%" ~operator:(Arithmetic Modulo);
  register_operator registry ~key:"**" ~operator:(Arithmetic Power);

  (* 注册比较操作符 *)
  register_operator registry ~key:"=" ~operator:(Comparison Equal);
  register_operator registry ~key:"!=" ~operator:(Comparison NotEqual);
  register_operator registry ~key:"<" ~operator:(Comparison LessThan);
  register_operator registry ~key:"<=" ~operator:(Comparison LessEqual);
  register_operator registry ~key:">" ~operator:(Comparison GreaterThan);
  register_operator registry ~key:">=" ~operator:(Comparison GreaterEqual);

  (* 注册分隔符 *)
  register_delimiter registry ~key:"(" ~delimiter:(Parenthesis LeftParen);
  register_delimiter registry ~key:")" ~delimiter:(Parenthesis RightParen);
  register_delimiter registry ~key:"[" ~delimiter:(Parenthesis LeftBracket);
  register_delimiter registry ~key:"]" ~delimiter:(Parenthesis RightBracket);
  register_delimiter registry ~key:"{" ~delimiter:(Parenthesis LeftBrace);
  register_delimiter registry ~key:"}" ~delimiter:(Parenthesis RightBrace);
  register_delimiter registry ~key:"," ~delimiter:(Punctuation Comma);
  register_delimiter registry ~key:";" ~delimiter:(Punctuation Semicolon);

  registry

(** 全局默认注册表 *)
let default_registry = lazy (init_default_registry ())

(** 获取默认注册表 *)
let get_default_registry () = Lazy.force default_registry
