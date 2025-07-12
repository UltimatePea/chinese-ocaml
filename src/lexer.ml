(** 骆言词法分析器 - Chinese Programming Language Lexer *)

(** 词元类型 *)
type token =
  (* 字面量 *)
  | IntToken of int
  | FloatToken of float
  | StringToken of string
  | BoolToken of bool
  
  (* 标识符 *)
  | IdentifierToken of string
  
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

  (* 面向对象关键字 *)
  | ClassKeyword                (* 类 - class *)
  | InheritKeyword              (* 继承 - inherit *) 
  | MethodKeyword               (* 方法 - method *)
  | NewKeyword                  (* 新建 - new *)
  | SelfKeyword                 (* 自己 - self *)
  | PrivateKeyword              (* 私有 - private *)
  | VirtualKeyword              (* 虚拟 - virtual *)
  | Hash                        (* # - for method calls *)
  
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
  | MethodKeywordWenyan         (* 術 - method/technique *)
  | WantExecuteKeyword          (* 欲行 - want to execute *)
  | MustFirstGetKeyword         (* 必先得 - must first get *)
  | ForThisKeyword              (* 為是 - for this *)
  | TimesKeyword                (* 遍 - times/iterations *)
  | EndCloudKeyword             (* 云云 - end marker *)
  | IfWenyanKeyword             (* 若 - if (wenyan style) *)
  | ThenWenyanKeyword           (* 者 - then particle *)
  | GreaterThanWenyan           (* 大於 - greater than *)
  | LessThanWenyan              (* 小於 - less than *)
  | OfParticle                  (* 之 - possessive particle *)
  | TopicMarker                 (* 者 - topic marker *)
  
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

(** 带位置的词元 *)
type positioned_token = token * position [@@deriving show, eq]

(** 词法错误 *)
exception LexError of string * position

(** 关键字映射表 *)
let keyword_table = [
  ("让", LetKeyword);
  ("递归", RecKeyword);
  ("在", InKeyword);
  ("函数", FunKeyword);
  ("如果", IfKeyword);
  ("那么", ThenKeyword);
  ("否则", ElseKeyword);
  ("匹配", MatchKeyword);
  ("与", WithKeyword);
  ("类型", TypeKeyword);
  ("真", TrueKeyword);
  ("假", FalseKeyword);
  ("并且", AndKeyword);
  ("或者", OrKeyword);
  ("非", NotKeyword);
  
  (* 语义类型系统关键字 *)
  ("作为", AsKeyword);
  ("组合", CombineKeyword);
  ("以及", WithOpKeyword);
  ("当", WhenKeyword);
  
  (* 错误恢复关键字 *)
  ("否则返回", OrElseKeyword);
  ("默认为", WithDefaultKeyword);
  ("异常", ExceptionKeyword);
  ("抛出", RaiseKeyword);
  ("尝试", TryKeyword);
  ("捕获", CatchKeyword);
  ("最终", FinallyKeyword);
  ("of", OfKeyword);
  
  (* 模块系统关键字 *)
  ("模块", ModuleKeyword);
  ("模块类型", ModuleTypeKeyword);
  ("签名", SigKeyword);
  ("结束", EndKeyword);
  ("函子", FunctorKeyword);
  
  ("引用", RefKeyword);
  
  (* 面向对象关键字 *)
  ("类", ClassKeyword);
  ("继承", InheritKeyword);
  ("方法", MethodKeyword);
  ("新建", NewKeyword);
  ("自己", SelfKeyword);
  ("私有", PrivateKeyword);
  ("虚拟", VirtualKeyword);
  
  (* 宏系统关键字 *)
  ("宏", MacroKeyword);
  ("展开", ExpandKeyword);
  
  (* wenyan风格关键字 *)
  ("吾有", HaveKeyword);
  ("一", OneKeyword);
  ("名曰", NameKeyword);
  ("设", SetKeyword);
  ("也", AlsoKeyword);
  ("乃", ThenGetKeyword);
  ("曰", CallKeyword);
  ("其值", ValueKeyword);
  ("为", AsForKeyword);
  ("数", NumberKeyword);
  
  (* wenyan扩展关键字 *)
  ("術", MethodKeywordWenyan);
  ("欲行", WantExecuteKeyword);
  ("必先得", MustFirstGetKeyword);
  ("為是", ForThisKeyword);
  ("遍", TimesKeyword);
  ("云云", EndCloudKeyword);
  ("若", IfWenyanKeyword);
  ("者", ThenWenyanKeyword);
  ("大於", GreaterThanWenyan);
  ("小於", LessThanWenyan);
  ("之", OfParticle);
]

(** 查找关键字 *)
let find_keyword str =
  try Some (List.assoc str keyword_table)
  with Not_found -> None

(** 是否为中文字符 *)
let is_chinese_char c =
  let code = Char.code c in
  (* CJK Unified Ideographs range: U+4E00-U+9FFF *)
  (* But for UTF-8 bytes, we need to check differently *)
  code >= 0xE4 || (code >= 0xE5 && code <= 0xE9)

(** 是否为字母或中文 *)
let is_letter_or_chinese c =
  (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || is_chinese_char c

(** 是否为数字 *)
let is_digit c = c >= '0' && c <= '9'

(** 是否为标识符字符 *)
let is_identifier_char c = is_letter_or_chinese c || is_digit c || c = '_'

(** 是否为空白字符 *)
let is_whitespace c = c = ' ' || c = '\t' || c = '\r'

(** 词法分析器状态 *)
type lexer_state = {
  input: string;
  length: int;
  position: int;
  current_line: int;
  current_column: int;
  filename: string;
}

(** 创建词法状态 *)
let create_lexer_state input filename = {
  input;
  length = String.length input;
  position = 0;
  current_line = 1;
  current_column = 1;
  filename;
}

(** 获取当前字符 *)
let current_char state =
  if state.position >= state.length then None
  else Some state.input.[state.position]

(** 向前移动 *)
let advance state =
  if state.position >= state.length then state
  else
    let c = state.input.[state.position] in
    if c = '\n' then
      { state with position = state.position + 1; current_line = state.current_line + 1; current_column = 1 }
    else
      { state with position = state.position + 1; current_column = state.current_column + 1 }

(** 跳过单个注释 *)
let skip_comment state =
  let rec skip_until_close state depth =
    match current_char state with
    | None -> raise (LexError ("Unterminated comment", { line = state.current_line; column = state.current_column; filename = state.filename }))
    | Some '(' ->
      let state1 = advance state in
      (match current_char state1 with
       | Some '*' -> skip_until_close (advance state1) (depth + 1)
       | _ -> skip_until_close state1 depth)
    | Some '*' ->
      let state1 = advance state in
      (match current_char state1 with
       | Some ')' -> 
         if depth = 1 then advance state1 
         else skip_until_close (advance state1) (depth - 1)
       | _ -> skip_until_close state1 depth)
    | Some _ -> skip_until_close (advance state) depth
  in
  skip_until_close state 1

(** 跳过空白字符和注释 *)
let rec skip_whitespace_and_comments state =
  match current_char state with
  | Some c when is_whitespace c -> skip_whitespace_and_comments (advance state)
  | Some '(' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '*' -> skip_whitespace_and_comments (skip_comment (advance state1))
     | _ -> state)  (* 不是注释，返回原状态 *)
  | _ -> state

(** 读取字符串直到满足条件 *)
let rec read_while state condition acc =
  match current_char state with
  | Some c when condition c -> read_while (advance state) condition (acc ^ String.make 1 c)
  | _ -> (acc, state)

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

(* 读取标识符（支持中文和英文） *)
let read_identifier_utf8 state =
  let rec loop pos acc =
    if pos >= state.length then (acc, pos)
    else
      let (ch, next_pos) = next_utf8_char state.input pos in
      if ch = "" then (acc, pos)
      else if
        (String.length ch = 1 && is_letter_or_chinese ch.[0]) || is_chinese_utf8 ch || (String.length ch = 1 && is_digit ch.[0]) || ch = "_"
      then loop next_pos (acc ^ ch)
      else (acc, pos)
  in
  let (id, new_pos) = loop state.position "" in
  let new_col = state.current_column + (new_pos - state.position) in
  (id, { state with position = new_pos; current_column = new_col })

(** 读取数字 *)
let read_number state =
  let (integer_part, state1) = read_while state is_digit "" in
  match current_char state1 with
  | Some '.' ->
    let (decimal_part, state2) = read_while (advance state1) is_digit "" in
    if decimal_part = "" then
      (IntToken (int_of_string integer_part), state1)
    else
      (FloatToken (float_of_string (integer_part ^ "." ^ decimal_part)), state2)
  | _ -> (IntToken (int_of_string integer_part), state1)

(** 读取字符串字面量 *)
let read_string_literal state =
  let rec read state acc =
    match current_char state with
    | Some '"' -> (acc, advance state)
    | Some '\\' ->
      let state1 = advance state in
      (match current_char state1 with
       | Some 'n' -> read (advance state1) (acc ^ "\n")
       | Some 't' -> read (advance state1) (acc ^ "\t")
       | Some 'r' -> read (advance state1) (acc ^ "\r")
       | Some '"' -> read (advance state1) (acc ^ "\"")
       | Some '\\' -> read (advance state1) (acc ^ "\\")
       | Some c -> read (advance state1) (acc ^ String.make 1 c)
       | None -> raise (LexError ("Unterminated string", { line = state.current_line; column = state.current_column; filename = state.filename })))
    | Some c -> read (advance state) (acc ^ String.make 1 c)
    | None -> raise (LexError ("Unterminated string", { line = state.current_line; column = state.current_column; filename = state.filename }))
  in
  let (content, new_state) = read (advance state) "" in
  (StringToken content, new_state)

(** 获取下一个词元 *)
let next_token state =
  let state = skip_whitespace_and_comments state in
  let pos = { line = state.current_line; column = state.current_column; filename = state.filename } in
  
  match current_char state with
  | None -> (EOF, pos, state)
  | Some '\n' -> (Newline, pos, advance state)
  | Some '+' -> (Plus, pos, advance state)
  | Some '-' -> 
    let state1 = advance state in
    (match current_char state1 with
     | Some '>' -> (Arrow, pos, advance state1)
     | _ -> (Minus, pos, state1))
  | Some '*' -> (Multiply, pos, advance state)
  | Some '/' -> (Divide, pos, advance state)
  | Some '%' -> (Modulo, pos, advance state)
  | Some '^' -> (Concat, pos, advance state)
  | Some '=' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '=' -> (Equal, pos, advance state1)
     | Some '>' -> (DoubleArrow, pos, advance state1)
     | _ -> (Assign, pos, state1))
  | Some '<' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '>' -> (NotEqual, pos, advance state1)
     | Some '=' -> (LessEqual, pos, advance state1)
     | Some '-' -> (AssignArrow, pos, advance state1)
     | _ -> (Less, pos, state1))
  | Some '>' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '=' -> (GreaterEqual, pos, advance state1)
     | _ -> (Greater, pos, state1))
  | Some '.' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '.' ->
       let state2 = advance state1 in
       (match current_char state2 with
        | Some '.' -> (TripleDot, pos, advance state2)
        | _ -> (DoubleDot, pos, state2))
     | _ -> (Dot, pos, state1))
  | Some '(' -> (LeftParen, pos, advance state)
  | Some ')' -> (RightParen, pos, advance state)
  | Some '[' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some '|' -> (LeftArray, pos, advance state1)
     | _ -> (LeftBracket, pos, state1))
  | Some ']' -> (RightBracket, pos, advance state)
  | Some '{' -> (LeftBrace, pos, advance state)
  | Some '}' -> (RightBrace, pos, advance state)
  | Some ',' -> (Comma, pos, advance state)
  | Some ';' -> (Semicolon, pos, advance state)
  | Some ':' -> 
    let state1 = advance state in
    (match current_char state1 with
     | Some '=' -> (RefAssign, pos, advance state1)
     | _ -> (Colon, pos, state1))
  | Some '!' -> (Bang, pos, advance state)
  | Some '#' -> (Hash, pos, advance state)
  | Some '|' ->
    let state1 = advance state in
    (match current_char state1 with
     | Some ']' -> (RightArray, pos, advance state1)
     | _ -> (Pipe, pos, state1))
  | Some '_' -> (Underscore, pos, advance state)
  | Some '"' -> 
    let (token, new_state) = read_string_literal state in
    (token, pos, new_state)
  | Some c when is_digit c ->
    let (token, new_state) = read_number state in
    (token, pos, new_state)
  | Some c when is_letter_or_chinese c || is_chinese_utf8 (String.make 1 c) ->
    let (identifier, new_state) = read_identifier_utf8 state in
    let token = match find_keyword identifier with
      | Some keyword -> 
        (match keyword with
         | TrueKeyword -> BoolToken true
         | FalseKeyword -> BoolToken false
         | _ -> keyword)
      | None -> IdentifierToken identifier
    in
    (token, pos, new_state)
  | Some c -> 
    raise (LexError ("Unknown character: " ^ String.make 1 c, pos))

(** 词法分析主函数 *)
let tokenize input filename =
  let rec analyze state acc =
    let (token, pos, new_state) = next_token state in
    let positioned_token = (token, pos) in
    match token with
    | EOF -> List.rev (positioned_token :: acc)
    | Newline -> analyze new_state (positioned_token :: acc)  (* 包含换行符作为语句分隔符 *)
    | _ -> analyze new_state (positioned_token :: acc)
  in
  let initial_state = create_lexer_state input filename in
  analyze initial_state []