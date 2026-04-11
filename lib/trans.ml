(** 骆言转换器 — 将中文OCaml语法转换为标准OCaml

    词法规则（优先级从高到低）：
    1. 「：...：」           → (* ... *)   注释
    2. 「...」               → ...         用户标识符（去掉括号）
    3. 『...』               → "..."       字符串字面量
    4. (* ... *)             →             OCaml原生注释（原样保留）
    5. "..."                 →             ASCII字符串（原样保留）
    6. '.'                   →             字符字面量或类型变量（原样保留）
    7. 全角括号与运算符      → 对应ASCII符号
    8. CJK汉字序列           → 查关键字表，否则编码为 luo__hex
    9. ASCII字母序列         → 原样输出（OCaml内置名称）
   10. 其他                  → 原样输出
*)

(* ===== Token类型（词法单元，用于AST转储） ===== *)

type token =
  | TImport   of string          (** 引入 路径 *)
  | TComment  of string          (** 「：注释内容：」 *)
  | TKeyword  of string * string (** 中文词 → OCaml关键字 *)
  | TIdent    of string * string (** 原始名称 → 值标识符（luo__hex） *)
  | TModIdent of string * string (** 原始名称 → 模块标识符（Luo__hex） *)
  | TString   of string          (** 字符串字面量内容 *)
  | TRaw      of string          (** 《内嵌OCaml》内容 *)
  | TNum      of string          (** 数字字面量 *)
  | TOp       of string          (** 运算符/标点 *)

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

(* ===== 关键字对照表 ===== *)

let keywords =
  let tbl = Hashtbl.create 128 in
  List.iter (fun (k, v) -> Hashtbl.add tbl k v) [
    (* 绑定 *)
    "让",   "let";
    "递归", "rec";
    "在",   "in";
    "以及", "and";
    (* 控制流 *)
    "如果", "if";
    "那么", "then";
    "否则", "else";
    (* 函数与模式匹配 *)
    "函数", "fun";
    "匹配", "match";
    "与",   "with";
    "当",   "when";
    (* 等号：binding、类型定义、模块定义、相等比较 *)
    "是",   "=";
    (* 类型系统 *)
    "类型", "type";
    "的",   "of";
    "可变", "mutable";
    "约束", "constraint";
    (* 异常处理 *)
    "异常", "exception";
    "尝试", "try";
    "抛出", "raise";
    (* 布尔值 *)
    "真",   "true";
    "假",   "false";
    (* 模块系统 *)
    "模块", "module";
    "函子", "functor";
    "结构", "struct";
    "签名", "sig";
    "结束", "end";
    "开始", "begin";
    "打开", "open";
    "包含", "include";
    "外部", "external";
    (* 其他语言关键字 *)
    "为",     "as";
    "断言",   "assert";
    "延迟",   "lazy";
    (* 面向对象（完整性） *)
    "值",     "val";
    "方法",   "method";
    "对象",   "object";
    "类",     "class";
    "新建",   "new";
    "虚拟",   "virtual";
    "私有",   "private";
    "继承",   "inherit";
    "初始化", "initializer";
    (* ── 内置构造子（必须保留：mangling 会产生小写标识符，不能用作构造子） ── *)
    "有",  "Some";
    "无",  "None";
    (* ── 逻辑中缀运算符（替换为 OCaml 运算符） ── *)
    "且",  "&&";
    "或",  "||";
    "非",  "not";
    (* ── 模式匹配与函数箭头 ── *)
    "案",  "|";    (* 模式/类型分支 *)
    "则",  "->";   (* 模式臂或函数体箭头 *)
    "赋",  "<-";   (* 可变字段赋值 *)
    "设",  ":=";   (* 引用赋值 *)
    (* ── 算术运算符 ── *)
    "加",  "+";
    "减",  "-";
    "乘",  "*";
    "除",  "/";
    "余",  "mod";
    (* ── 比较运算符 ── *)
    "小于", "<";
    "大于", ">";
    "不超", "<=";
    "不低", ">=";
    "不等", "<>";
    (* ── 其他运算符 ── *)
    "空",  "_";    (* 通配符 *)
    "连",  "^";    (* 字符串连接 *)
    "接",  "::";   (* 列表构造 *)
    "取",  "!";    (* 引用读取 *)
    "追",  "@";    (* 列表追加 *)
  ];
  tbl

(* ===== 标识符名称处理 ===== *)

(** 判断字符串是否含有非ASCII字节（汉字等） *)
let has_non_ascii s =
  let n = String.length s in
  let i = ref 0 in
  while !i < n && Char.code s.[!i] < 0x80 do incr i done;
  !i < n

(** 将用户标识符转换为合法的OCaml值标识符（小写前缀）。
    - 纯ASCII名称保持不变（如 「x」→ x，「Node」→ Node）
    - 含汉字等非ASCII字符时，编码为 luo__ + 十六进制UTF-8字节
      （如 「斐波那契」→ luo__e69690e6b3a2e982a3e5a591）
    注意：构造子需要大写开头，请用ASCII大写字母命名（如 「Node」「Leaf」）。 *)
let mangle name =
  if has_non_ascii name then begin
    let buf = Buffer.create (6 + String.length name * 2) in
    Buffer.add_string buf "luo__";
    String.iter (fun c -> Printf.bprintf buf "%02x" (Char.code c)) name;
    Buffer.contents buf
  end else
    name

(** 将用户标识符转换为合法的OCaml模块标识符（大写前缀）。
    - 纯ASCII名称首字母大写后返回（如 「list」→ List）
    - 含汉字等非ASCII字符时，编码为 Luo__ + 十六进制UTF-8字节
      （如 「输出」→ Luo__e8be93e587ba）
    OCaml要求模块名以大写字母开头，故前缀用大写 Luo__。 *)
let mangle_module name =
  if has_non_ascii name then begin
    let buf = Buffer.create (6 + String.length name * 2) in
    Buffer.add_string buf "Luo__";
    String.iter (fun c -> Printf.bprintf buf "%02x" (Char.code c)) name;
    Buffer.contents buf
  end else if String.length name > 0 then
    String.make 1 (Char.uppercase_ascii name.[0])
    ^ String.sub name 1 (String.length name - 1)
  else
    name

(* ===== UTF-8 工具 ===== *)

(** 从字符串 [s] 的位置 [i]（长度为 [n]）解码一个UTF-8码点。
    返回 (码点, 该字符占用的字节数)。
    对于无效字节序列，返回原始字节和长度1。 *)
let decode_utf8 s i n =
  if i >= n then (0, 0)
  else
    let b0 = Char.code s.[i] in
    if b0 < 0x80 then (b0, 1)
    else if b0 < 0xC0 then (b0, 1)
    else if b0 < 0xE0 then
      if i + 1 < n then
        (((b0 land 0x1F) lsl 6) lor (Char.code s.[i+1] land 0x3F), 2)
      else (b0, 1)
    else if b0 < 0xF0 then
      if i + 2 < n then
        let b1 = Char.code s.[i+1] and b2 = Char.code s.[i+2] in
        (((b0 land 0x0F) lsl 12) lor ((b1 land 0x3F) lsl 6) lor (b2 land 0x3F), 3)
      else (b0, 1)
    else
      if i + 3 < n then
        let b1 = Char.code s.[i+1] and b2 = Char.code s.[i+2] and b3 = Char.code s.[i+3] in
        (((b0 land 0x07) lsl 18) lor ((b1 land 0x3F) lsl 12)
         lor ((b2 land 0x3F) lsl 6) lor (b3 land 0x3F), 4)
      else (b0, 1)

(** 判断码点是否为CJK统一汉字（用于收集关键字词）。
    注意：之（U+4E4B）被排除，因为它用作模块访问符 → . *)
let is_cjk cp =
  cp <> 0x4E4B &&                        (* 之 用作模块访问符，单独处理 *)
  ((cp >= 0x4E00 && cp <= 0x9FFF)        (* CJK统一汉字 *)
   || (cp >= 0x3400 && cp <= 0x4DBF)     (* CJK扩展A *)
   || (cp >= 0x20000 && cp <= 0x2A6DF)   (* CJK扩展B *)
   || (cp >= 0xF900 && cp <= 0xFAFF))    (* CJK兼容汉字 *)

(* ===== 词法分析（tokenize） ===== *)

(** [tokenize ?basedir src] 将骆言源码词法分析为 token 列表。
    不展开 引入 指令（仅发出 TImport token），不含空白 token。 *)
let tokenize ?basedir:(_ = "") src =
  let n = String.length src in
  let toks = ref [] in
  let emit t = toks := t :: !toks in
  let i = ref 0 in
  let last_kw = ref "" in
  let sub () len = String.sub src !i len in

  while !i < n do
    let (cp, len) = decode_utf8 src !i n in

    (* 跳过空白 *)
    if cp = 0x20 || cp = 0x09 || cp = 0x0A || cp = 0x0D then
      i := !i + len

    (* ── 1. 「：注释：」 或 「标识符」 ── *)
    else if cp = 0x300C then begin
      i := !i + len;
      if !i < n then begin
        let (cp2, len2) = decode_utf8 src !i n in
        if cp2 = 0xFF1A || cp2 = 0x003A then begin
          (* 注释 *)
          i := !i + len2;
          let buf = Buffer.create 32 in
          (try
             while !i < n do
               let (cp3, len3) = decode_utf8 src !i n in
               if (cp3 = 0xFF1A || cp3 = 0x003A) && !i + len3 < n then begin
                 let (cp4, len4) = decode_utf8 src (!i + len3) n in
                 if cp4 = 0x300D then begin i := !i + len3 + len4; raise Exit end
                 else begin Buffer.add_string buf (sub () len3); i := !i + len3 end
               end else begin Buffer.add_string buf (sub () len3); i := !i + len3 end
             done
           with Exit -> ());
          emit (TComment (Buffer.contents buf))
        end else begin
          (* 标识符 *)
          let name_buf = Buffer.create 16 in
          (try
             while !i < n do
               let (cp2, len2) = decode_utf8 src !i n in
               if cp2 = 0x300D then begin i := !i + len2; raise Exit end
               else begin Buffer.add_string name_buf (sub () len2); i := !i + len2 end
             done
           with Exit -> ());
          let name = Buffer.contents name_buf in
          let is_mod_ctx =
            !last_kw = "module" || !last_kw = "open" || !last_kw = "include"
          in
          let j = ref !i in
          while !j < n &&
            (let c = src.[!j] in c=' '||c='\t'||c='\n'||c='\r') do incr j done;
          let is_mod_acc =
            !j < n && (let (cp2,_) = decode_utf8 src !j n in cp2 = 0x4E4B)
          in
          last_kw := "";
          if is_mod_ctx || is_mod_acc then
            emit (TModIdent (name, mangle_module name))
          else
            emit (TIdent (name, mangle name))
        end
      end
    end

    (* ── 2. 『字符串』 ── *)
    else if cp = 0x300E then begin
      i := !i + len;
      let buf = Buffer.create 32 in
      (try
         while !i < n do
           let (cp2, len2) = decode_utf8 src !i n in
           if cp2 = 0x300F then begin i := !i + len2; raise Exit end
           else begin Buffer.add_string buf (sub () len2); i := !i + len2 end
         done
       with Exit -> ());
      emit (TString (Buffer.contents buf))
    end

    (* ── 3. 《内嵌OCaml》 ── *)
    else if cp = 0x300A then begin
      i := !i + len;
      let buf = Buffer.create 32 in
      (try
         while !i < n do
           let (cp2, len2) = decode_utf8 src !i n in
           if cp2 = 0x300B then begin i := !i + len2; raise Exit end
           else begin Buffer.add_string buf (sub () len2); i := !i + len2 end
         done
       with Exit -> ());
      emit (TRaw (Buffer.contents buf))
    end

    (* ── 4. OCaml原生注释 (* ... *) ── *)
    else if cp = 0x28 && !i + 1 < n && src.[!i + 1] = '*' then begin
      i := !i + 2;
      let depth = ref 1 in
      let buf = Buffer.create 32 in
      while !depth > 0 && !i < n do
        if src.[!i] = '(' && !i + 1 < n && src.[!i + 1] = '*' then begin
          Buffer.add_string buf "(*"; i := !i + 2; incr depth
        end else if src.[!i] = '*' && !i + 1 < n && src.[!i + 1] = ')' then begin
          i := !i + 2; decr depth;
          if !depth > 0 then Buffer.add_string buf "*)"
        end else begin
          Buffer.add_char buf src.[!i]; incr i
        end
      done;
      emit (TComment (Buffer.contents buf))
    end

    (* ── 5. ASCII字符串 "..." ── *)
    else if cp = 0x22 then begin
      let buf = Buffer.create 16 in
      incr i;
      let esc = ref false in
      while !i < n && (src.[!i] <> '"' || !esc) do
        let c = src.[!i] in
        Buffer.add_char buf c;
        esc := (c = '\\' && not !esc);
        incr i
      done;
      if !i < n then incr i;
      emit (TString (Buffer.contents buf))
    end

    (* ── 6. 配对中文括号与句末全停 ── *)
    else if cp = 0xFF08 || cp = 0xFF09   (* （） *)
         || cp = 0x3010 || cp = 0x3011   (* 【】 *)
         || cp = 0x3001                   (* 、  *)
         || cp = 0x3002                   (* 。  *)
         || cp = 0xFF1B                   (* ；  *)
         || cp = 0x4E4B                   (* 之  *)
    then begin
      emit (TOp (sub () len));
      i := !i + len
    end

    (* ── 7. CJK汉字序列 ── *)
    else if is_cjk cp then begin
      let start = !i in
      while !i < n && (let (cp2,_) = decode_utf8 src !i n in is_cjk cp2) do
        let (_,l) = decode_utf8 src !i n in i := !i + l
      done;
      let word = String.sub src start (!i - start) in
      if word = "引入" then begin
        (* 跳过空白，读取 『路径』 *)
        while !i < n && (let c = src.[!i] in c=' '||c='\t'||c='\n'||c='\r') do incr i done;
        if !i < n then begin
          let (cp2, len2) = decode_utf8 src !i n in
          if cp2 = 0x300E then begin
            i := !i + len2;
            let pbuf = Buffer.create 32 in
            (try
               while !i < n do
                 let (cp3, len3) = decode_utf8 src !i n in
                 if cp3 = 0x300F then begin i := !i + len3; raise Exit end
                 else begin Buffer.add_string pbuf (sub () len3); i := !i + len3 end
               done
             with Exit -> ());
            (* TImport 记录源文件中书写的相对路径（不展开） *)
            emit (TImport (Buffer.contents pbuf))
          end
        end
      end else begin
        let out_kw = match Hashtbl.find_opt keywords word with
          | Some k -> k | None -> mangle word
        in
        last_kw := out_kw;
        (match Hashtbl.find_opt keywords word with
         | Some k -> emit (TKeyword (word, k))
         | None   -> emit (TIdent (word, mangle word)))
      end
    end

    (* ── 12. ASCII数字 ── *)
    else if cp >= 0x30 && cp <= 0x39 then begin
      let start = !i in
      while !i < n && (
        let c = src.[!i] in
        (c >= '0' && c <= '9') || c = '.' || c = 'e' || c = 'E'
        || c = 'x' || c = 'X' || c = 'b' || c = 'B'
        || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') || c = '_'
      ) do incr i done;
      emit (TNum (String.sub src start (!i - start)))
    end

    (* ── 13. ASCII标识符/运算符 ── *)
    else if (cp >= 0x41 && cp <= 0x5A) || (cp >= 0x61 && cp <= 0x7A) || cp = 0x5F then begin
      let start = !i in
      while !i < n && (
        let c = src.[!i] in
        (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
        || (c >= '0' && c <= '9') || c = '_' || c = '\''
      ) do incr i done;
      emit (TOp (String.sub src start (!i - start)))
    end

    (* ── 14. 其他ASCII符号 ── *)
    else begin
      emit (TOp (sub () len));
      i := !i + len
    end

  done;
  List.rev !toks

(* ===== 文件读取工具 ===== *)

let read_file_bytes path =
  let ic = open_in_bin path in
  let len = in_channel_length ic in
  let s = Bytes.create len in
  really_input ic s 0 len;
  close_in ic;
  Bytes.to_string s

(* ===== 主转换函数 ===== *)

let rec transpile_with_basedir basedir src =
  let n = String.length src in
  let out = Buffer.create (n + 256) in
  let i = ref 0 in

  let put s  = Buffer.add_string out s in
  let putc c = Buffer.add_char out c in
  let sub () len = String.sub src !i len in
  let skip_ws () =
    while !i < n && (let c = src.[!i] in c=' '||c='\t'||c='\n'||c='\r') do incr i done
  in
  (* 追踪上一个发出的OCaml关键字，用于判断 「name」 是值名还是模块名/构造子 *)
  let last_kw = ref "" in
  (* 已知构造子集合：案 「name」 注册后，后续 「name」 始终用 mangle_module *)
  let constructors : (string, bool) Hashtbl.t = Hashtbl.create 8 in

  (* 将位置 !i 处的完整UTF-8字符输出，并推进 i *)
  let emit_char () =
    let (_, len) = decode_utf8 src !i n in
    put (sub () len);
    i := !i + len
  in

  while !i < n do
    let (cp, len) = decode_utf8 src !i n in
    begin

    (* ── 1. 角括号：标识符 「...」 或注释 「：...：」 ── *)
    if cp = 0x300C then begin                        (* 「 U+300C *)
      i := !i + len;                                 (* 跳过 「 *)
      if !i < n then begin
        let (cp2, len2) = decode_utf8 src !i n in
        (* 全角冒号 ： U+FF1A 或 ASCII 冒号 : → 注释模式 *)
        if cp2 = 0xFF1A || cp2 = 0x003A then begin
          i := !i + len2;
          put "(* ";
          (try
             while !i < n do
               let (cp3, len3) = decode_utf8 src !i n in
               if (cp3 = 0xFF1A || cp3 = 0x003A) && !i + len3 < n then begin
                 let (cp4, len4) = decode_utf8 src (!i + len3) n in
                 if cp4 = 0x300D then begin           (* 」 U+300D *)
                   i := !i + len3 + len4;
                   raise Exit
                 end else begin
                   put (sub () len3);
                   i := !i + len3
                 end
               end else begin
                 put (sub () len3);
                 i := !i + len3
               end
             done
           with Exit -> ());
          put " *)"
        end else begin
          (* 普通标识符 「name」 *)
          let name_buf = Buffer.create 16 in
          (try
             while !i < n do
               let (cp2, len2) = decode_utf8 src !i n in
               if cp2 = 0x300D then begin             (* 」 U+300D *)
                 i := !i + len2;
                 raise Exit
               end else begin
                 Buffer.add_string name_buf (sub () len2);
                 i := !i + len2
               end
             done
           with Exit -> ());
          let name = Buffer.contents name_buf in
          (* 情形1：上一个关键字是 module / open / include → 此处是模块名定义/引用 *)
          let is_mod_context =
            !last_kw = "module" || !last_kw = "open" || !last_kw = "include"
          in
          (* 情形2：上一个关键字是 | (案) → 此处是构造子名 *)
          let is_constr_context = !last_kw = "|" in
          (* 情形3：向前扫描跳过空白，检查下一个字符是否为 之（U+4E4B）→ 模块访问 *)
          let j = ref !i in
          while !j < n &&
            (let c = src.[!j] in c = ' ' || c = '\t' || c = '\n' || c = '\r')
          do incr j done;
          let is_mod_access =
            !j < n &&
            (let (cp2, _) = decode_utf8 src !j n in cp2 = 0x4E4B)
          in
          (* 情形4：名称在已知构造子集合中（之前由 案 注册） *)
          let is_known_constr = Hashtbl.mem constructors name in
          last_kw := "";  (* 消费掉上下文标记 *)
          if is_mod_context || is_mod_access then
            put (mangle_module name)
          else if is_constr_context || is_known_constr then begin
            Hashtbl.replace constructors name true;   (* 注册/保持 *)
            put (mangle_module name)
          end else
            put (mangle name)
        end
      end
    end

    (* ── 2. 中文字符串字面量 『...』 ── *)
    else if cp = 0x300E then begin                   (* 『 U+300E *)
      put "\"";
      i := !i + len;
      (try
         while !i < n do
           let (cp2, len2) = decode_utf8 src !i n in
           if cp2 = 0x300F then begin                (* 』 U+300F *)
             i := !i + len2;
             raise Exit
           end else if cp2 = 0x22 then begin         (* 0x22 双引号，转义输出 *)
             put "\\\"";
             i := !i + len2
           end else if cp2 = 0x5C then begin         (* 0x5C 反斜杠，保留及其后字符 *)
             put (sub () len2);
             i := !i + len2;
             if !i < n then begin
               let (_, len3) = decode_utf8 src !i n in
               put (sub () len3);
               i := !i + len3
             end
           end else begin
             put (sub () len2);
             i := !i + len2
           end
         done
       with Exit -> ());
      put "\""
    end

    (* ── 3. OCaml原生嵌套注释 (* ... *) ── *)
    else if cp = 0x28 && !i + 1 < n && src.[!i + 1] = '*' then begin
      put "(*";
      i := !i + 2;
      let depth = ref 1 in
      while !depth > 0 && !i < n do
        if src.[!i] = '(' && !i + 1 < n && src.[!i + 1] = '*' then begin
          put "(*"; i := !i + 2; incr depth
        end else if src.[!i] = '*' && !i + 1 < n && src.[!i + 1] = ')' then begin
          put "*)"; i := !i + 2; decr depth
        end else begin
          putc src.[!i]; incr i
        end
      done
    end

    (* ── 4. 原生OCaml嵌入 《...》（书名号，U+300A/U+300B） ── *)
    else if cp = 0x300A then begin               (* 《 *)
      i := !i + len;
      (try
         while !i < n do
           let (cp2, len2) = decode_utf8 src !i n in
           if cp2 = 0x300B then begin            (* 》 *)
             i := !i + len2;
             raise Exit
           end else begin
             put (sub () len2);
             i := !i + len2
           end
         done
       with Exit -> ())
    end

    (* ── 5. ASCII字符串字面量 "..." ── *)
    else if cp = 0x22 then begin
      putc '"'; incr i;
      let escaped = ref false in
      while !i < n && (src.[!i] <> '"' || !escaped) do
        let c = src.[!i] in
        putc c;
        escaped := (c = '\\' && not !escaped);
        incr i
      done;
      if !i < n then begin putc '"'; incr i end
    end

    (* ── 5. 字符字面量 'x' 或 '\n'；裸撇号（类型变量）报错 ── *)
    else if cp = 0x27 then begin
      if !i + 2 < n && src.[!i + 2] = '\'' then begin
        (* 'x' — 单字符字面量 *)
        put (sub () 3); i := !i + 3
      end else if !i + 1 < n && src.[!i + 1] = '\\' && !i + 3 < n && src.[!i + 3] = '\'' then begin
        (* '\n' — 转义字符字面量 *)
        put (sub () 4); i := !i + 4
      end else begin
        (* 裸撇号：类型变量请用 元「名称」 *)
        let ctx = if !i + 1 < n then Printf.sprintf " (near '%c')" src.[!i + 1] else "" in
        Printf.eprintf "骆言错误：类型变量请用 元「名称」 而非 ASCII 撇号%s\n" ctx;
        exit 1
      end
    end

    (* ── 6. 全角括号 ── *)
    else if cp = 0xFF08 then begin put "("; i := !i + len end  (* （→ ( *)
    else if cp = 0xFF09 then begin put ")"; i := !i + len end  (* ）→ ) *)
    else if cp = 0x3010 then begin put "["; i := !i + len end  (* 【→ [ *)
    else if cp = 0x3011 then begin put "]"; i := !i + len end  (* 】→ ] *)

    (* ── 7. 中文标点 ── *)
    else if cp = 0x3001 then begin put ",";  i := !i + len end  (* 、→ ,  顿号/枚举逗号 *)
    else if cp = 0x3002 then begin put ";;"; i := !i + len end  (* 。→ ;; 句末全停 *)
    else if cp = 0xFF1B then begin put ";";  i := !i + len end  (* ；→ ;  中文分号/序列分隔 *)

    (* ── 9. 之（U+4E4B）→ 模块访问符 . ── *)
    else if cp = 0x4E4B then begin put "."; i := !i + len end

    (* ── 10. CJK汉字序列（不含之）：收集完整词，查关键字表 ── *)
    else if is_cjk cp then begin
      let start = !i in
      while !i < n && (let (cp2, _) = decode_utf8 src !i n in is_cjk cp2) do
        let (_, l) = decode_utf8 src !i n in
        i := !i + l
      done;
      let word = String.sub src start (!i - start) in
      if word = "元" then begin
        (* 元「名称」 → '名称  类型变量 *)
        skip_ws ();
        if !i < n then begin
          let (cp2, len2) = decode_utf8 src !i n in
          if cp2 = 0x300C then begin  (* 「 *)
            i := !i + len2;
            let name_buf = Buffer.create 8 in
            (try
               while !i < n do
                 let (cp3, len3) = decode_utf8 src !i n in
                 if cp3 = 0x300D then begin i := !i + len3; raise Exit end  (* 」 *)
                 else begin Buffer.add_string name_buf (sub () len3); i := !i + len3 end
               done
             with Exit -> ());
            let raw = Buffer.contents name_buf in
            (* 类型变量名必须是合法 OCaml 标识符；中文名称需 mangle *)
            let var_name = if has_non_ascii raw then mangle raw else raw in
            put "'";
            put var_name
          end else begin
            Printf.eprintf "骆言错误：元 后应跟 「名称」（类型变量语法）\n";
            exit 1
          end
        end
      end else if word = "引入" then begin
        (* 引入 『路径.ly』 — 读取并内联编译指定文件 *)
        skip_ws ();
        if !i < n then begin
          let (cp2, len2) = decode_utf8 src !i n in
          if cp2 = 0x300E then begin  (* 『 *)
            i := !i + len2;
            let path_buf = Buffer.create 64 in
            (try
               while !i < n do
                 let (cp3, len3) = decode_utf8 src !i n in
                 if cp3 = 0x300F then begin i := !i + len3; raise Exit end  (* 』 *)
                 else begin Buffer.add_string path_buf (sub () len3); i := !i + len3 end
               done
             with Exit -> ());
            let rel_path = Buffer.contents path_buf in
            let full_path =
              if basedir = "" then rel_path
              else Filename.concat basedir rel_path
            in
            (try
               let content = read_file_bytes full_path in
               let sub_basedir = Filename.dirname full_path in
               put "\n";
               put (transpile_with_basedir sub_basedir content);
               put "\n"
             with Sys_error msg ->
               Printf.eprintf "骆言错误：无法引入 %s：%s\n" full_path msg;
               exit 1)
          end
        end
      end else begin
        let out_kw = match Hashtbl.find_opt keywords word with
          | Some kw -> kw
          | None    -> mangle word
        in
        last_kw := out_kw;
        put out_kw
      end
    end

    (* ── 12. ASCII数字 ── *)
    else if cp >= 0x30 && cp <= 0x39 then begin
      while !i < n && (
        let c = src.[!i] in
        (c >= '0' && c <= '9') || c = '.' || c = 'e' || c = 'E'
        || c = 'x' || c = 'X' || c = 'o' || c = 'O'
        || c = 'b' || c = 'B' || c = '_'
        || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
      ) do
        putc src.[!i]; incr i
      done
    end

    (* ── 12. ASCII标识符：顶层禁止，报错 ── *)
    else if (cp >= 0x41 && cp <= 0x5A)   (* A-Z *)
         || (cp >= 0x61 && cp <= 0x7A)   (* a-z *)
         || cp = 0x5F then begin          (* _ *)
      let start = !i in
      incr i;  (* 跳过第一个 ASCII 字符 *)
      while !i < n && (
        let c = src.[!i] in
        (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
        || (c >= '0' && c <= '9') || c = '_' || c = '\''
      ) do
        incr i
      done;
      let word = String.sub src start (!i - start) in
      Printf.eprintf "骆言错误：顶层不允许 ASCII 标识符 %S\n（请用 「名称」 定义中文标识符，或用 《…》 包裹 OCaml 原生代码）\n" word;
      exit 1
    end

    (* ── 13. 其他：空白和数字内部字符原样，其余 ASCII 报错 ── *)
    else begin
      if cp > 0x20 && cp < 0x80 then begin
        Printf.eprintf "骆言错误：顶层不允许 ASCII 字符 '%c'\n（请使用对应的中文关键字或运算符）\n" (Char.chr cp);
        exit 1
      end;
      emit_char ()
    end

    end

  done;

  Buffer.contents out

(* ===== 生成OCaml注解（将 luo__hex 还原为原始中文标识符） ===== *)

(** 将一行 OCaml 中的 luo__hex / Luo__hex 还原为原始 UTF-8 名称 *)
let demangle_line line =
  let n = String.length line in
  let buf = Buffer.create n in
  let i = ref 0 in
  while !i < n do
    (* 匹配 luo__ 或 Luo__ 前缀 *)
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

(** 对生成的 OCaml 源码每一行，若含有 mangle 标识符则在其前插入还原注释。
    已是注释的行、空行不重复注释。 *)
let add_line_annotations output =
  let lines = String.split_on_char '\n' output in
  (* split 在末尾 \n 后会产生一个空字符串，去掉它 *)
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
        (* 保留原行缩进，注释使用去空白后的还原内容 *)
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

let transpile ?(basedir="") ?(annotate=true) src =
  let raw = transpile_with_basedir basedir src in
  if annotate then add_line_annotations raw else raw
