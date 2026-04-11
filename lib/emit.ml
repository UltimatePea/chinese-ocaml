(** 骆言发射器 — 将 AST 节点列表转换为 OCaml 源码 *)

(* ===== 发射器状态 ===== *)

type state = {
  buf : Buffer.t;
  last_kw : string ref;
  constructors : (string, bool) Hashtbl.t;
  basedir : string;
}

let put st s = Buffer.add_string st.buf s
let putc st c = Buffer.add_char st.buf c

(* ===== 标点映射 ===== *)

let punct_string = function
  | Parser.LParen   -> "("
  | Parser.RParen   -> ")"
  | Parser.LBracket -> "["
  | Parser.RBracket -> "]"
  | Parser.Comma    -> ","
  | Parser.Period   -> ";;"
  | Parser.Semi     -> ";"
  | Parser.Dot      -> "."

(* ===== 中文字符串转义 ===== *)

let emit_cn_string st s =
  put st "\"";
  let n = String.length s in
  let i = ref 0 in
  while !i < n do
    let c = s.[!i] in
    if c = '"' then begin
      put st "\\\""; incr i
    end else if c = '\\' then begin
      putc st '\\'; incr i;
      if !i < n then begin putc st s.[!i]; incr i end
    end else begin
      putc st c; incr i
    end
  done;
  put st "\""

(* ===== 节点发射（核心） ===== *)

let rec emit_all buf ~basedir nodes =
  let st = {
    buf;
    last_kw = ref "";
    constructors = Hashtbl.create 8;
    basedir;
  } in
  emit_nodes st nodes

and emit_nodes st = function
  | [] -> ()
  | node :: rest ->
    emit_one st rest node;
    emit_nodes st rest

and emit_one st rest = function
  | Parser.Comment s ->
    put st "(* "; put st s; put st " *)"

  | Parser.Ident name ->
    let is_mod_ctx =
      !(st.last_kw) = "module" || !(st.last_kw) = "open" || !(st.last_kw) = "include"
    in
    let is_constr_ctx = !(st.last_kw) = "|" in
    let is_dot_next = match Parser.next_non_ws rest with
      | Some (Parser.Punct Parser.Dot) -> true | _ -> false
    in
    let is_known = Hashtbl.mem st.constructors name in
    st.last_kw := "";
    if is_mod_ctx || is_dot_next then
      put st (Util.mangle_module name)
    else if is_constr_ctx || is_known then begin
      Hashtbl.replace st.constructors name true;
      put st (Util.mangle_module name)
    end else
      put st (Util.mangle name)

  | Parser.CnString s ->
    emit_cn_string st s

  | Parser.AsciiString s ->
    put st "\""; put st s; put st "\""

  | Parser.RawOcaml s ->
    put st s

  | Parser.CharLit s ->
    put st s

  | Parser.Number s ->
    put st s

  | Parser.CjkWord word ->
    let ocaml = match Hashtbl.find_opt Util.keywords word with
      | Some kw -> kw
      | None -> Util.mangle word
    in
    st.last_kw := ocaml;
    put st ocaml

  | Parser.TypeVar name ->
    let var_name = if Util.has_non_ascii name then Util.mangle name else name in
    put st "'"; put st var_name

  | Parser.Import rel_path ->
    let full_path =
      if st.basedir = "" then rel_path
      else Filename.concat st.basedir rel_path
    in
    (try
       let content = Util.read_file full_path in
       let sub_basedir = Filename.dirname full_path in
       let sub_nodes = Parser.parse content in
       putc st '\n';
       emit_all st.buf ~basedir:sub_basedir sub_nodes;
       putc st '\n'
     with Sys_error msg ->
       Printf.eprintf "骆言错误：无法引入 %s：%s\n" full_path msg;
       exit 1)

  | Parser.Punct p ->
    put st (punct_string p)

  | Parser.Ws s ->
    put st s

(** 将节点列表发射为 OCaml 源码 *)
let emit ~basedir nodes =
  let buf = Buffer.create 4096 in
  emit_all buf ~basedir nodes;
  Buffer.contents buf

(* ===== 还原注解（demangling） ===== *)

let demangle_line line =
  let n = String.length line in
  let buf = Buffer.create n in
  let i = ref 0 in
  while !i < n do
    if !i + 5 <= n
       && (String.sub line !i 5 = "luo__" || String.sub line !i 5 = "Luo__")
    then begin
      let j = ref (!i + 5) in
      while !j < n && (let c = line.[!j] in
        (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')) do
        incr j
      done;
      let hex = String.sub line (!i + 5) (!j - !i - 5) in
      let hex_len = String.length hex in
      if hex_len > 0 && hex_len mod 2 = 0 then begin
        let bytes = Bytes.create (hex_len / 2) in
        for k = 0 to hex_len / 2 - 1 do
          let hi = Char.code hex.[2 * k] in
          let lo = Char.code hex.[2 * k + 1] in
          let hv = if hi >= Char.code 'a' then hi - Char.code 'a' + 10
                   else hi - Char.code '0' in
          let lv = if lo >= Char.code 'a' then lo - Char.code 'a' + 10
                   else lo - Char.code '0' in
          Bytes.set bytes k (Char.chr (hv * 16 + lv))
        done;
        Buffer.add_string buf (Bytes.to_string bytes);
        i := !j
      end else begin
        Buffer.add_char buf line.[!i]; incr i
      end
    end else begin
      Buffer.add_char buf line.[!i]; incr i
    end
  done;
  Buffer.contents buf

let add_line_annotations output =
  let lines = String.split_on_char '\n' output in
  let lines = match List.rev lines with
    | "" :: rest -> List.rev rest
    | _ -> lines
  in
  let buf = Buffer.create (String.length output * 2) in
  List.iter (fun line ->
    let trimmed = String.trim line in
    let is_comment =
      String.length trimmed >= 2 && trimmed.[0] = '(' && trimmed.[1] = '*'
    in
    if trimmed <> "" && not is_comment then begin
      let demangled = demangle_line line in
      if demangled <> line then begin
        let ws_end = ref 0 in
        while !ws_end < String.length line &&
          (line.[!ws_end] = ' ' || line.[!ws_end] = '\t') do
          incr ws_end
        done;
        Buffer.add_string buf (String.sub line 0 !ws_end);
        Buffer.add_string buf "(* ";
        Buffer.add_string buf (String.trim demangled);
        Buffer.add_string buf " *)\n"
      end
    end;
    Buffer.add_string buf line;
    Buffer.add_char buf '\n'
  ) lines;
  Buffer.contents buf
