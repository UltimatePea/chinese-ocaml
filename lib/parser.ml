(** 骆言解析器 — 基于状态的解析器组合子，将骆言源码解析为 AST 节点列表 *)

(* ===== AST 节点类型 ===== *)

type punct =
  | LParen                      (** （ → ( *)
  | RParen                      (** ） → ) *)
  | LBracket                    (** 【 → [ *)
  | RBracket                    (** 】 → ] *)
  | Comma                       (** 、 → , *)
  | Period                      (** 。 → ;; *)
  | Semi                        (** ； → ; *)
  | Dot                         (** 之 → . *)

type node =
  | Comment of string           (** 「：...：」或 (* ... *) 注释内容 *)
  | Ident of string             (** 「名称」中的原始名称 *)
  | CnString of string          (** 『...』中的原始内容 *)
  | AsciiString of string       (** "..." 中的原始内容（含转义） *)
  | RawOcaml of string          (** 《...》中的原始 OCaml 代码 *)
  | CharLit of string           (** 'x' 或 '\n' 字符字面量（含引号） *)
  | Number of string            (** 数字字面量 *)
  | CjkWord of string           (** CJK 汉字序列（关键字或未知标识符） *)
  | TypeVar of string           (** 元「名称」中的名称 *)
  | Import of string            (** 引入 『路径』中的路径 *)
  | Punct of punct              (** 标点符号 *)
  | Ws of string                (** 空白 *)

(* ===== 解析器状态 ===== *)

type state = {
  src : string;
  len : int;
  pos : int ref;
}

(* ===== 基础组合子 ===== *)

let create src = { src; len = String.length src; pos = ref 0 }

let at_end st = !(st.pos) >= st.len

let peek_cp st =
  if at_end st then (0, 0)
  else Util.decode_utf8 st.src !(st.pos) st.len

let peek_byte st =
  if at_end st then '\x00' else st.src.[!(st.pos)]

let peek_byte_at st offset =
  let p = !(st.pos) + offset in
  if p >= st.len then '\x00' else st.src.[p]

let advance st n = st.pos := !(st.pos) + n

let slice st n = String.sub st.src !(st.pos) n

let skip_ws st =
  while not (at_end st) &&
    (let c = st.src.[!(st.pos)] in c = ' ' || c = '\t' || c = '\n' || c = '\r')
  do incr st.pos done

(** 读取内容直到遇到指定码点（消耗该码点） *)
let read_until st close_cp =
  let buf = Buffer.create 32 in
  let found = ref false in
  while not (at_end st) && not !found do
    let (cp, len) = Util.decode_utf8 st.src !(st.pos) st.len in
    if cp = close_cp then begin
      advance st len;
      found := true
    end else begin
      Buffer.add_string buf (String.sub st.src !(st.pos) len);
      advance st len
    end
  done;
  Buffer.contents buf

(* ===== 错误报告 ===== *)

let error fmt =
  Printf.ksprintf (fun msg -> Printf.eprintf "%s\n" msg; exit 1) fmt

(* ===== 分类谓词 ===== *)

let is_colon cp = cp = 0xFF1A || cp = 0x003A

let is_num_char c =
  (c >= '0' && c <= '9') || c = '.' || c = 'e' || c = 'E'
  || c = 'x' || c = 'X' || c = 'o' || c = 'O' || c = 'b' || c = 'B'
  || c = '_' || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')

let is_ws_char c = c = ' ' || c = '\t' || c = '\n' || c = '\r'

(* ===== 单元解析器 ===== *)

(** 解析注释体（已跳过开头的冒号），读到 ：」 结束 *)
let parse_comment_body st =
  let (_, len) = peek_cp st in
  advance st len;  (* 跳过开头冒号 *)
  let buf = Buffer.create 32 in
  let found = ref false in
  while not (at_end st) && not !found do
    let (cp, len) = Util.decode_utf8 st.src !(st.pos) st.len in
    if is_colon cp && !(st.pos) + len < st.len then begin
      let (cp2, len2) = Util.decode_utf8 st.src (!(st.pos) + len) st.len in
      if cp2 = 0x300D then begin  (* ：」 *)
        advance st (len + len2);
        found := true
      end else begin
        Buffer.add_string buf (String.sub st.src !(st.pos) len);
        advance st len
      end
    end else begin
      Buffer.add_string buf (String.sub st.src !(st.pos) len);
      advance st len
    end
  done;
  Comment (Buffer.contents buf)

(** 解析 「...」 — 注释或标识符 *)
let parse_bracket st =
  let (_, len) = peek_cp st in
  advance st len;  (* 跳过 「 *)
  let (cp2, _) = peek_cp st in
  if is_colon cp2 then
    parse_comment_body st
  else
    Ident (read_until st 0x300D)  (* 读到 」 *)

(** 解析 『...』 中文字符串 *)
let parse_cn_string st =
  let (_, len) = peek_cp st in
  advance st len;  (* 跳过 『 *)
  CnString (read_until st 0x300F)  (* 读到 』 *)

(** 解析 《...》 原生 OCaml *)
let parse_raw_ocaml st =
  let (_, len) = peek_cp st in
  advance st len;  (* 跳过 《 *)
  RawOcaml (read_until st 0x300B)  (* 读到 》 *)

(** 解析 (* ... *) OCaml 嵌套注释 *)
let parse_ocaml_comment st =
  advance st 2;  (* 跳过注释开头 *)
  let buf = Buffer.create 32 in
  let depth = ref 1 in
  while !depth > 0 && not (at_end st) do
    if peek_byte st = '(' && peek_byte_at st 1 = '*' then begin
      Buffer.add_string buf "(*"; advance st 2; incr depth
    end else if peek_byte st = '*' && peek_byte_at st 1 = ')' then begin
      advance st 2; decr depth;
      if !depth > 0 then Buffer.add_string buf "*)"
    end else begin
      Buffer.add_char buf (peek_byte st); advance st 1
    end
  done;
  Comment (Buffer.contents buf)

(** 解析 "..." ASCII 字符串 *)
let parse_ascii_string st =
  advance st 1;
  let buf = Buffer.create 16 in
  let escaped = ref false in
  while not (at_end st) && (st.src.[!(st.pos)] <> '"' || !escaped) do
    let c = st.src.[!(st.pos)] in
    Buffer.add_char buf c;
    escaped := (c = '\\' && not !escaped);
    advance st 1
  done;
  if not (at_end st) then advance st 1;
  AsciiString (Buffer.contents buf)

(** 解析 'x' 或 '\n' 字符字面量；裸撇号报错 *)
let parse_char_literal st =
  let pos = !(st.pos) in
  if pos + 2 < st.len && st.src.[pos + 2] = '\'' then begin
    let lit = slice st 3 in advance st 3; CharLit lit
  end else if pos + 1 < st.len && st.src.[pos + 1] = '\\'
           && pos + 3 < st.len && st.src.[pos + 3] = '\'' then begin
    let lit = slice st 4 in advance st 4; CharLit lit
  end else begin
    let near = if pos + 1 < st.len
      then Printf.sprintf " (near '%c')" st.src.[pos + 1] else "" in
    error "骆言错误：类型变量请用 元「名称」 而非 ASCII 撇号%s" near
  end

(** 解析数字字面量 *)
let parse_number st =
  let start = !(st.pos) in
  while not (at_end st) && is_num_char (peek_byte st) do
    incr st.pos
  done;
  Number (String.sub st.src start (!(st.pos) - start))

(** 解析空白 *)
let parse_whitespace st =
  let start = !(st.pos) in
  while not (at_end st) && is_ws_char (peek_byte st) do
    incr st.pos
  done;
  Ws (String.sub st.src start (!(st.pos) - start))

(** 解析标点符号 *)
let parse_punct st cp =
  let (_, len) = peek_cp st in
  advance st len;
  let p = match cp with
    | 0xFF08 -> LParen    | 0xFF09 -> RParen
    | 0x3010 -> LBracket  | 0x3011 -> RBracket
    | 0x3001 -> Comma     | 0x3002 -> Period
    | 0xFF1B -> Semi      | 0x4E4B -> Dot
    | _ -> assert false
  in
  Punct p

(** 解析 元「名称」 类型变量 *)
let parse_type_var st =
  skip_ws st;
  if at_end st then error "骆言错误：元 后应跟 「名称」（类型变量语法）";
  let (cp, len) = peek_cp st in
  if cp = 0x300C then begin
    advance st len;
    TypeVar (read_until st 0x300D)
  end else
    error "骆言错误：元 后应跟 「名称」（类型变量语法）"

(** 解析 引入 『路径』 *)
let parse_import st =
  skip_ws st;
  if at_end st then CjkWord "\xe5\xbc\x95\xe5\x85\xa5"  (* 引入 as regular word *)
  else
    let (cp, len) = peek_cp st in
    if cp = 0x300E then begin
      advance st len;
      Import (read_until st 0x300F)
    end else
      CjkWord "\xe5\xbc\x95\xe5\x85\xa5"

(** 解析 CJK 汉字序列（可能为关键字、类型变量前缀、引入指令） *)
let parse_cjk_word st =
  let start = !(st.pos) in
  while not (at_end st) && (let (cp, _) = peek_cp st in Util.is_cjk cp) do
    let (_, len) = peek_cp st in
    advance st len
  done;
  let word = String.sub st.src start (!(st.pos) - start) in
  if word = "\xe5\x85\x83" then            (* 元 *)
    parse_type_var st
  else if word = "\xe5\xbc\x95\xe5\x85\xa5" then  (* 引入 *)
    parse_import st
  else
    CjkWord word

(** 禁止顶层 ASCII 标识符 *)
let error_ascii_ident st =
  let start = !(st.pos) in
  incr st.pos;
  while not (at_end st) && (
    let c = st.src.[!(st.pos)] in
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
    || (c >= '0' && c <= '9') || c = '_' || c = '\''
  ) do incr st.pos done;
  let word = String.sub st.src start (!(st.pos) - start) in
  error "骆言错误：顶层不允许 ASCII 标识符 %S\n（请用 「名称」 定义中文标识符，或用 《…》 包裹 OCaml 原生代码）" word

(* ===== 主解析循环 ===== *)

let is_punct_cp cp =
  cp = 0xFF08 || cp = 0xFF09 || cp = 0x3010 || cp = 0x3011
  || cp = 0x3001 || cp = 0x3002 || cp = 0xFF1B || cp = 0x4E4B

(** 解析一个节点 *)
let parse_one st =
  let (cp, _) = peek_cp st in

  if cp = 0x300C then                                       (* 「 *)
    parse_bracket st

  else if cp = 0x300E then                                  (* 『 *)
    parse_cn_string st

  else if cp = 0x300A then                                  (* 《 *)
    parse_raw_ocaml st

  else if cp = 0x28 && peek_byte_at st 1 = '*' then        (* OCaml注释 *)
    parse_ocaml_comment st

  else if cp = 0x22 then                                    (* 双引号 *)
    parse_ascii_string st

  else if cp = 0x27 then                                    (* 单引号 *)
    parse_char_literal st

  else if is_punct_cp cp then                               (* 标点 *)
    parse_punct st cp

  else if Util.is_cjk cp then                              (* CJK 汉字 *)
    parse_cjk_word st

  else if cp >= 0x30 && cp <= 0x39 then                    (* 数字 *)
    parse_number st

  else if (cp >= 0x41 && cp <= 0x5A)                       (* ASCII 标识符 → 错误 *)
       || (cp >= 0x61 && cp <= 0x7A)
       || cp = 0x5F then
    error_ascii_ident st

  else if cp > 0x20 && cp < 0x80 then                      (* 其他 ASCII → 错误 *)
    error "骆言错误：顶层不允许 ASCII 字符 '%c'\n（请使用对应的中文关键字或运算符）" (Char.chr cp)

  else                                                      (* 空白/控制字符 *)
    parse_whitespace st

(** 解析完整源码，返回节点列表 *)
let parse src =
  let st = create src in
  let nodes = ref [] in
  while not (at_end st) do
    nodes := parse_one st :: !nodes
  done;
  List.rev !nodes

(* ===== 节点工具函数 ===== *)

(** 跳过空白节点，返回下一个非空白节点 *)
let rec next_non_ws = function
  | [] -> None
  | Ws _ :: rest -> next_non_ws rest
  | node :: _ -> Some node
