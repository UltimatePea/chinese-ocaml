(** 骆言转换器 — 公共 API

    将中文 OCaml 语法（骆言）转换为标准 OCaml 源码。
    内部流程：Parser.parse → Emit.emit → 注解处理 *)

(* ===== Token 类型（词法单元，用于 --ast 转储） ===== *)

type token =
  | TImport   of string
  | TComment  of string
  | TKeyword  of string * string
  | TIdent    of string * string
  | TModIdent of string * string
  | TString   of string
  | TRaw      of string
  | TNum      of string
  | TOp       of string

let pp_token = function
  | TImport p        -> Printf.sprintf "IMPORT\t%s" p
  | TComment c       -> Printf.sprintf "COMMENT\t%s" (String.trim c)
  | TKeyword(zh, en) -> Printf.sprintf "KW\t%s\t→ %s" zh en
  | TIdent(zh, mn)   -> Printf.sprintf "ID\t%s\t→ %s" zh mn
  | TModIdent(zh,mn) -> Printf.sprintf "MOD\t%s\t→ %s" zh mn
  | TString s        -> Printf.sprintf "STR\t%s" s
  | TRaw r           -> Printf.sprintf "RAW\t%s" r
  | TNum n           -> Printf.sprintf "NUM\t%s" n
  | TOp o            -> Printf.sprintf "OP\t%s" o

let print_tokens tokens =
  String.concat "\n" (List.map pp_token tokens) ^ "\n"

(* ===== 标识符转换（委托至 Util） ===== *)

let mangle = Util.mangle
let mangle_module = Util.mangle_module

(* ===== 节点 → Token 转换（用于 tokenize） ===== *)

let nodes_to_tokens nodes =
  let toks = ref [] in
  let last_kw = ref "" in
  let emit t = toks := t :: !toks in
  let rec convert = function
    | [] -> ()
    | node :: rest ->
      begin match node with
      | Parser.Comment s -> emit (TComment s)

      | Parser.Ident name ->
        let is_mod_ctx =
          !last_kw = "module" || !last_kw = "open" || !last_kw = "include"
        in
        let is_dot_next = match Parser.next_non_ws rest with
          | Some (Parser.Punct Parser.Dot) -> true | _ -> false
        in
        last_kw := "";
        if is_mod_ctx || is_dot_next then
          emit (TModIdent (name, Util.mangle_module name))
        else
          emit (TIdent (name, Util.mangle name))

      | Parser.CnString s -> emit (TString s)
      | Parser.AsciiString s -> emit (TString s)
      | Parser.RawOcaml s -> emit (TRaw s)
      | Parser.CharLit s -> emit (TOp s)
      | Parser.Number s -> emit (TNum s)

      | Parser.CjkWord word ->
        (match Hashtbl.find_opt Util.keywords word with
         | Some kw -> last_kw := kw; emit (TKeyword (word, kw))
         | None -> emit (TIdent (word, Util.mangle word)))

      | Parser.TypeVar name ->
        let var = if Util.has_non_ascii name then Util.mangle name else name in
        emit (TOp ("'" ^ var))

      | Parser.Import path -> emit (TImport path)

      | Parser.Punct p ->
        let s = match p with
          | Parser.LParen   -> "\xef\xbc\x88"   (* （ *)
          | Parser.RParen   -> "\xef\xbc\x89"   (* ） *)
          | Parser.LBracket -> "\xe3\x80\x90"   (* 【 *)
          | Parser.RBracket -> "\xe3\x80\x91"   (* 】 *)
          | Parser.Comma    -> "\xe3\x80\x81"   (* 、 *)
          | Parser.Period   -> "\xe3\x80\x82"   (* 。 *)
          | Parser.Semi     -> "\xef\xbc\x9b"   (* ； *)
          | Parser.Dot      -> "\xe4\xb9\x8b"   (* 之 *)
        in
        emit (TOp s)

      | Parser.Ws _ -> ()  (* tokenize 跳过空白 *)
      end;
      convert rest
  in
  convert nodes;
  List.rev !toks

(* ===== 公共 API ===== *)

let tokenize ?(basedir:_ = "") src =
  ignore basedir;
  let nodes = Parser.parse src in
  nodes_to_tokens nodes

let transpile ?(basedir="") ?(annotate=true) src =
  let nodes = Parser.parse src in
  let raw = Emit.emit ~basedir nodes in
  if annotate then Emit.add_line_annotations raw else raw
